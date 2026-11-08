import asyncio
import io
import os
import socket
from pathlib import Path

import pytest

import asyncfiles
from asyncfiles import SendfileProtocol, open as async_open, sendfile, sendpath


class _CollectorServerProtocol(asyncio.Protocol):
    def __init__(self, done_fut: asyncio.Future):
        self.chunks = bytearray()
        self.done_fut = done_fut

    def data_received(self, data: bytes) -> None:
        self.chunks.extend(data)

    def connection_lost(self, exc) -> None:
        if not self.done_fut.done():
            if exc is not None:
                self.done_fut.set_exception(exc)
            else:
                self.done_fut.set_result(bytes(self.chunks))


async def _run_over_tcp(sender_coro):
    loop = asyncio.get_running_loop()
    received_fut = loop.create_future()

    server = await loop.create_server(
        lambda: _CollectorServerProtocol(received_fut),
        "127.0.0.1",
        0,
    )
    addr = server.sockets[0].getsockname()
    client_transport, client_proto = await loop.create_connection(
        asyncio.Protocol, addr[0], addr[1]
    )
    try:
        sent = await sender_coro(client_transport, client_proto)
    finally:
        client_transport.close()
    received = await asyncio.wait_for(received_fut, timeout=5.0)
    server.close()
    await server.wait_closed()
    return sent, received


async def test_sendpath_full_file(tmp_path):
    payload = os.urandom(200 * 1024 + 37)
    file_path = tmp_path / "payload.bin"
    file_path.write_bytes(payload)

    async def _send(transport, proto):
        sent = await sendpath(transport, file_path, chunk_size=16 * 1024)
        assert transport.get_protocol() is proto
        assert transport.is_reading()
        return sent

    sent, received = await _run_over_tcp(_send)
    assert sent == len(payload)
    assert received == payload


async def test_sendpath_str_and_ranges(tmp_path):
    payload = b"0123456789abcdefghijklmnopqrstuvwxyz" * 1024
    file_path = str(tmp_path / "range.bin")
    with open(file_path, "wb") as f:
        f.write(payload)

    # Slice in the middle
    sent, received = await _run_over_tcp(
        lambda t, _p: sendpath(t, file_path, offset=100, count=5000, chunk_size=1024)
    )
    assert sent == 5000
    assert received == payload[100:5100]

    # Offset with count=None (until EOF)
    sent, received = await _run_over_tcp(
        lambda t, _p: sendpath(t, file_path, offset=len(payload) - 777)
    )
    assert sent == 777
    assert received == payload[-777:]

    # Count exceeding remaining bytes
    sent, received = await _run_over_tcp(
        lambda t, _p: sendpath(
            t, file_path, offset=len(payload) - 300, count=10_000
        )
    )
    assert sent == 300
    assert received == payload[-300:]

    # Offset past EOF returns 0
    sent, received = await _run_over_tcp(
        lambda t, _p: sendpath(t, file_path, offset=len(payload) + 500)
    )
    assert sent == 0
    assert received == b""


async def test_sendfile_with_asyncfiles_binary_file(tmp_path):
    payload = os.urandom(150 * 1024 + 19)
    file_path = tmp_path / "af_binary.bin"
    file_path.write_bytes(payload)

    async with async_open(file_path, "rb") as af:
        sent1, received1 = await _run_over_tcp(
            lambda t, _p: sendfile(
                t, af, offset=1024, count=4096, chunk_size=1024
            )
        )
        assert sent1 == 4096
        assert received1 == payload[1024 : 1024 + 4096]
        assert af.tell() == 1024 + 4096

        # Full transfer from offset 0
        sent2, received2 = await _run_over_tcp(
            lambda t, _p: sendfile(t, af, offset=0, chunk_size=32 * 1024)
        )
        assert sent2 == len(payload)
        assert received2 == payload
        assert af.tell() == len(payload)


async def test_sendfile_with_stdlib_binary_file(tmp_path):
    payload = os.urandom(128 * 1024 + 11)
    file_path = tmp_path / "stdlib.bin"
    file_path.write_bytes(payload)

    with open(file_path, "rb") as f:
        sent, received = await _run_over_tcp(
            lambda t, _p: sendfile(
                t, f, offset=500, count=70_000, chunk_size=8192
            )
        )
        assert not f.closed
        assert os.lseek(f.fileno(), 0, os.SEEK_CUR) == 70_500

    assert sent == 70_000
    assert received == payload[500:70_500]


class _FakeBackpressureTransport(asyncio.Transport):
    def __init__(
        self,
        loop: asyncio.AbstractEventLoop,
        proto: asyncio.BaseProtocol,
        *,
        pause_every: int = 2,
        initially_paused: bool = False,
        drop_after: int = 0,
    ):
        super().__init__()
        self._loop = loop
        self._proto = proto
        self._reading = True
        self._closing = False
        self._pause_every = pause_every
        self._initially_paused = initially_paused
        self._drop_after = drop_after
        self._write_calls = 0
        self.buffer = bytearray()
        self.pause_reading_calls = 0
        self.resume_reading_calls = 0

    def get_protocol(self):
        return self._proto

    def set_protocol(self, protocol):
        self._proto = protocol
        if self._initially_paused and isinstance(protocol, SendfileProtocol):
            self._initially_paused = False
            self._loop.call_soon(protocol.resume_writing)

    def is_reading(self):
        return self._reading

    def pause_reading(self):
        self._reading = False
        self.pause_reading_calls += 1

    def resume_reading(self):
        self._reading = True
        self.resume_reading_calls += 1

    def is_closing(self):
        return self._closing

    def get_write_buffer_size(self):
        return 100 if self._initially_paused else 0

    def get_write_buffer_limits(self):
        return (16, 64)

    def write(self, data):
        self._write_calls += 1
        self.buffer.extend(data)
        if self._drop_after and self._write_calls >= self._drop_after:
            self._closing = True
            self._loop.call_soon(
                self._proto.connection_lost,
                ConnectionResetError("connection lost mid-sendfile"),
            )
            self._proto.pause_writing()
            return
        if self._pause_every and self._write_calls % self._pause_every == 0:
            self._proto.pause_writing()
            self._loop.call_soon(self._proto.resume_writing)


async def test_sendfile_backpressure_and_protocol_restore(tmp_path):
    loop = asyncio.get_running_loop()
    payload = os.urandom(64 * 1024)
    file_path = tmp_path / "bp.bin"
    file_path.write_bytes(payload)

    orig_proto = asyncio.Protocol()
    transport = _FakeBackpressureTransport(loop, orig_proto, pause_every=2)

    sent = await sendpath(transport, file_path, chunk_size=4096)
    assert sent == len(payload)
    assert bytes(transport.buffer) == payload
    assert transport.get_protocol() is orig_proto
    assert transport.is_reading()
    assert transport.pause_reading_calls == 1
    assert transport.resume_reading_calls == 1


async def test_sendfile_initially_above_high_watermark(tmp_path):
    loop = asyncio.get_running_loop()
    payload = b"hello backpressure world" * 200
    file_path = tmp_path / "highwater.bin"
    file_path.write_bytes(payload)

    orig_proto = asyncio.Protocol()
    transport = _FakeBackpressureTransport(
        loop, orig_proto, pause_every=1, initially_paused=True
    )

    sent = await sendpath(transport, file_path, chunk_size=1024)
    assert sent == len(payload)
    assert bytes(transport.buffer) == payload
    assert transport.get_protocol() is orig_proto


async def test_sendfile_connection_lost_mid_transfer(tmp_path):
    loop = asyncio.get_running_loop()
    payload = os.urandom(32 * 1024)
    file_path = tmp_path / "connlost.bin"
    file_path.write_bytes(payload)

    orig_proto = asyncio.Protocol()
    transport = _FakeBackpressureTransport(
        loop, orig_proto, pause_every=0, drop_after=2
    )

    with pytest.raises(ConnectionError):
        await sendpath(transport, file_path, chunk_size=4096)

    assert transport.get_protocol() is orig_proto


class _DummyBufferedProtocol(asyncio.BufferedProtocol):
    def __init__(self):
        self.buf = bytearray(256)
        self.updated = 0
        self.eof = False
        self.lost_exc = None

    def get_buffer(self, sizehint: int):
        return memoryview(self.buf)

    def buffer_updated(self, nbytes: int):
        self.updated += nbytes

    def eof_received(self):
        self.eof = True
        return False

    def connection_lost(self, exc):
        self.lost_exc = exc


async def test_sendfile_protocol_buffered_forwarding():
    loop = asyncio.get_running_loop()
    inner = _DummyBufferedProtocol()
    transport = _FakeBackpressureTransport(loop, inner)

    proxy = SendfileProtocol(transport, loop)
    assert proxy.is_buffered_protocol() is True
    mv = proxy.get_buffer(64)
    mv[:5] = b"hello"
    proxy.buffer_updated(5)
    assert inner.updated == 5
    assert bytes(inner.buf[:5]) == b"hello"
    assert proxy.eof_received() is False
    assert inner.eof is True
    with pytest.raises(RuntimeError, match="Invalid state: connection_made"):
        proxy.connection_made(transport)
    await proxy.restore()
    assert transport.get_protocol() is inner


async def test_sendfile_validation_errors(tmp_path):
    loop = asyncio.get_running_loop()
    file_path = tmp_path / "valid.bin"
    file_path.write_bytes(b"abcdef")
    transport = _FakeBackpressureTransport(loop, asyncio.Protocol())

    # Empty file returns 0
    empty_path = tmp_path / "empty.bin"
    empty_path.write_bytes(b"")
    assert await sendpath(transport, empty_path) == 0

    # Offset past EOF on stdlib file returns 0 and updates lseek
    with open(file_path, "rb") as std_eof:
        assert await sendfile(transport, std_eof, offset=100) == 0
        assert os.lseek(std_eof.fileno(), 0, os.SEEK_CUR) == 100

    # Zero / negative / non-int / bool count
    with pytest.raises(ValueError, match="count must be a positive integer"):
        await sendpath(transport, file_path, count=0)
    with pytest.raises(ValueError, match="count must be a positive integer"):
        await sendpath(transport, file_path, count=-1)
    with pytest.raises(TypeError, match="count must be a positive integer"):
        await sendpath(transport, file_path, count="10")  # type: ignore[arg-type]
    with pytest.raises(TypeError, match="count must be a positive integer"):
        await sendpath(transport, file_path, count=True)  # type: ignore[arg-type]

    # Negative / non-int / bool offset
    with pytest.raises(
        ValueError, match="offset must be a non-negative integer"
    ):
        await sendpath(transport, file_path, offset=-5)
    with pytest.raises(
        TypeError, match="offset must be a non-negative integer"
    ):
        await sendpath(transport, file_path, offset="0")  # type: ignore[arg-type]
    with pytest.raises(
        TypeError, match="offset must be a non-negative integer"
    ):
        await sendpath(transport, file_path, offset=False)  # type: ignore[arg-type]

    # Invalid chunk_size
    with pytest.raises(
        ValueError, match="chunk_size must be a positive integer"
    ):
        await sendpath(transport, file_path, chunk_size=0)

    # Text mode file rejected (asyncfiles TextFile & stdlib text file)
    async with async_open(file_path, "r") as tf:
        with pytest.raises(ValueError, match="binary mode"):
            await sendfile(transport, tf)  # type: ignore[arg-type]

    with open(file_path, "r") as tf_std:
        with pytest.raises(ValueError, match="binary mode"):
            await sendfile(transport, tf_std)  # type: ignore[arg-type]

    # Unopened / closed BinaryFile rejected
    unopened = async_open(file_path, "rb")
    with pytest.raises(ValueError, match="closed file"):
        await sendfile(transport, unopened)

    # Closed stdlib file rejected
    closed_std = open(file_path, "rb")
    closed_std.close()
    with pytest.raises(ValueError, match="closed file"):
        await sendfile(transport, closed_std)

    # In-memory BytesIO (no fileno) raises SendfileNotAvailableError
    with pytest.raises(asyncio.SendfileNotAvailableError):
        await sendfile(transport, io.BytesIO(b"abc"))

    # Non-regular file (pipe or socket) raises SendfileNotAvailableError
    sock_a, sock_b = socket.socketpair()
    try:
        with sock_a.makefile("rb") as sock_file:
            with pytest.raises(asyncio.SendfileNotAvailableError):
                await sendfile(transport, sock_file)
    finally:
        sock_a.close()
        sock_b.close()

    # Transport without protocol rejected
    no_proto_transport = _FakeBackpressureTransport(
        loop, None  # type: ignore[arg-type]
    )
    with pytest.raises(RuntimeError, match="Transport has no protocol"):
        await sendpath(no_proto_transport, file_path)

    # Closing transport rejected
    transport._closing = True
    with pytest.raises(RuntimeError, match="Transport is closing"):
        await sendpath(transport, file_path)


async def test_sendfile_does_not_leak_futures(tmp_path):
    import gc

    loop = asyncio.get_running_loop()
    file_path = tmp_path / "noleak.bin"
    file_path.write_bytes(b"x" * 16384)
    transport = _FakeBackpressureTransport(loop, asyncio.Protocol(), pause_every=2)

    # Warm-up
    for _ in range(5):
        await sendpath(transport, file_path, chunk_size=4096)
    gc.collect()
    baseline = sum(1 for obj in gc.get_objects() if isinstance(obj, asyncio.Future))

    for _ in range(50):
        await sendpath(transport, file_path, chunk_size=4096)
    with open(file_path, "rb") as std_f:
        for _ in range(50):
            await sendfile(transport, std_f, offset=0, chunk_size=4096)

    gc.collect()
    after = sum(1 for obj in gc.get_objects() if isinstance(obj, asyncio.Future))
    assert after - baseline < 10

