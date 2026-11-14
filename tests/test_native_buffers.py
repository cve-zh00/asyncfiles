"""Native buffers must be finalized before bytes escape to Python."""

from __future__ import annotations

import asyncio
import gc
import os
from pathlib import Path

import pytest

from asyncfiles import open as async_open
from asyncfiles import os as aos


@pytest.mark.parametrize("binary", [False, True], ids=["text", "binary"])
@pytest.mark.parametrize(
    "size", [37, 4 * 1024 * 1024 + 113], ids=["small", "multichunk"]
)
@pytest.mark.parametrize("short", [False, True], ids=["full", "short"])
async def test_native_read_finalization(
    tmp_path: Path, binary: bool, size: int, short: bool
) -> None:
    """Both single-SQE and parallel reads return only initialized data."""
    path = tmp_path / "finalization"
    payload = (b"native-buffer\n" * (size // 14 + 1))[:size]
    path.write_bytes(payload)
    async with async_open(path, "rb" if binary else "r") as stream:
        if short:
            # Metadata is intentionally stale: force a native short read/EOF.
            payload = payload[: size // 2 + 7]
            path.write_bytes(payload)
        result = await stream.read()
        assert stream.tell() == len(payload)
        assert await stream.read() == (b"" if binary else "")
    expected = payload if binary else payload.decode("ascii")
    assert result == expected
    # Force materialization before and after GC; neither may reveal stale C data.
    assert hash(result) == hash(expected)
    gc.collect()
    assert result == expected


@pytest.mark.parametrize("readonly", [b"readonly", memoryview(b"readonly")])
async def test_readinto_rejects_borrowed_readonly_buffer(
    tmp_path: Path, readonly: bytes | memoryview
) -> None:
    path = tmp_path / "readonly"
    path.write_bytes(b"native")
    async with async_open(path, "rb") as stream:
        with pytest.raises((TypeError, BufferError)):
            await stream.readinto(readonly)  # type: ignore[arg-type]
        assert stream.tell() == 0
        assert await stream.read() == b"native"


async def test_readinto_rejects_strided_writable_buffer(tmp_path: Path) -> None:
    path = tmp_path / "strided"
    path.write_bytes(b"abcd")
    target = bytearray(b"01234567")
    async with async_open(path, "rb") as stream:
        with pytest.raises((TypeError, BufferError)):
            await stream.readinto(memoryview(target)[::2])
        assert target == b"01234567"
        assert stream.tell() == 0
        assert await stream.read() == b"abcd"


@pytest.mark.parametrize("mutable", [False, True])
async def test_native_write_strided_buffer(tmp_path: Path, mutable: bool) -> None:
    path = tmp_path / "strided-write"
    source = bytearray(b"a0b0c0d0") if mutable else b"a0b0c0d0"
    async with async_open(path, "wb") as stream:
        assert await stream.write(memoryview(source)[::2]) == 4
    assert path.read_bytes() == b"abcd"


@pytest.mark.parametrize("binary", [False, True], ids=["text", "binary"])
async def test_native_write_temporary_data_lifetime(
    tmp_path: Path, binary: bool
) -> None:
    path = tmp_path / "temporary"
    text = "añ한🏁" * 500000
    expected = text.encode("utf-8")
    async with async_open(path, "wb" if binary else "w") as stream:
        operation = stream.write(text.encode("utf-8") if binary else text[:])
        del text
        task = asyncio.ensure_future(operation)
        await asyncio.sleep(0)
        gc.collect()
        assert await task == len(expected)
    assert path.read_bytes() == expected


async def test_native_stat_nanosecond_parity(tmp_path: Path) -> None:
    path = tmp_path / "stat"
    path.write_bytes(b"native")
    os.utime(path, ns=(1700000000123456789, 1700000000987654321))
    expected = path.stat()
    for actual in (
        await aos.stat(path),
        await aos.lstat(path),
    ):
        for field in ("st_atime_ns", "st_mtime_ns", "st_ctime_ns"):
            assert getattr(actual, field) == getattr(expected, field)
        assert actual.st_mtime == expected.st_mtime
    with path.open("rb") as borrowed:
        actual = await aos.stat(borrowed.fileno())
        assert actual.st_mtime_ns == expected.st_mtime_ns
        assert os.fstat(borrowed.fileno()).st_size == 6
