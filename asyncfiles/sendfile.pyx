# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

import asyncio
import io
import os

from . cimport uv
from .base_file cimport BaseFile
from .buffer_manager cimport BufferManager
from .event_loop cimport EventLoopPump, _get_or_create_pump, release_shared_pump
from .file_io cimport FileReader
from .io_operations cimport IOOperation
from .utils cimport new_future
from libc.stdint cimport int64_t


cdef extern from *:
    """
    #include <stdint.h>
    #include <sys/types.h>
    #include <sys/stat.h>

    #if defined(_WIN32)
        #include <io.h>
        #include <stdlib.h>

        static void af_noop_invalid_param(
            const wchar_t* expression,
            const wchar_t* function,
            const wchar_t* file,
            unsigned int line,
            uintptr_t pReserved
        ) {
            (void)expression;
            (void)function;
            (void)file;
            (void)line;
            (void)pReserved;
        }

        static inline int64_t af_regular_file_size(int fd)
        {
            struct _stat64 file_stat;
            _invalid_parameter_handler old_handler;
            int rc;

            if (fd < 0)
                return -1;

            old_handler = _set_thread_local_invalid_parameter_handler(af_noop_invalid_param);
            rc = _fstat64(fd, &file_stat);
            _set_thread_local_invalid_parameter_handler(old_handler);

            if (rc != 0 || (file_stat.st_mode & _S_IFMT) != _S_IFREG)
                return -1;

            return (int64_t)file_stat.st_size;
        }
    #else
        static inline int64_t af_regular_file_size(int fd)
        {
            struct stat file_stat;

            if (fd < 0)
                return -1;

            if (fstat(fd, &file_stat) != 0 || !S_ISREG(file_stat.st_mode))
                return -1;

            return (int64_t)file_stat.st_size;
        }
    #endif
    """
    int64_t af_regular_file_size(int fd) noexcept nogil


cpdef validate_sendfile_args(
    object transport,
    object offset,
    object count,
    Py_ssize_t chunk_size,
):
    if not isinstance(offset, int) or isinstance(offset, bool):
        raise TypeError(
            f"offset must be a non-negative integer (got {offset!r})"
        )
    if offset < 0:
        raise ValueError(
            f"offset must be a non-negative integer (got {offset!r})"
        )

    if count is not None:
        if not isinstance(count, int) or isinstance(count, bool):
            raise TypeError(
                f"count must be a positive integer (got {count!r})"
            )
        if count <= 0:
            raise ValueError(
                f"count must be a positive integer (got {count!r})"
            )

    if chunk_size <= 0:
        raise ValueError(
            f"chunk_size must be a positive integer (got {chunk_size!r})"
        )

    if transport is None or transport.is_closing():
        raise RuntimeError("Transport is closing")
    if transport.get_protocol() is None:
        raise RuntimeError("Transport has no protocol")


cdef class SendfileProtocol:
    """Protocol adapter that manages transport write backpressure during sendfile."""

    def __init__(self, object transport, object loop):
        if transport is None or transport.is_closing():
            raise RuntimeError("Transport is closing")

        self._transport = transport
        self._loop = loop
        self._proto = transport.get_protocol()
        if self._proto is None:
            raise RuntimeError("Transport has no protocol")

        self._write_ready = None
        self._connection_lost_exc = None
        self._should_pause = False
        self._connection_lost = False
        self._reading_paused = False

        is_reading = getattr(transport, "is_reading", None)
        if is_reading is not None and is_reading():
            transport.pause_reading()
            self._reading_paused = True

        get_size = getattr(transport, "get_write_buffer_size", None)
        get_limits = getattr(transport, "get_write_buffer_limits", None)
        if get_size is not None and get_limits is not None:
            low, high = get_limits()
            if get_size() > high:
                self._should_pause = True

        transport.set_protocol(self)

    cpdef is_buffered_protocol(self):
        if self._proto is None:
            return False
        try:
            ret = getattr(self._proto, "is_buffered_protocol")()
            if ret is not None:
                return ret
        except AttributeError:
            pass
        return isinstance(self._proto, asyncio.BufferedProtocol)

    async def drain(self):
        if self._connection_lost or self._transport.is_closing():
            if self._connection_lost_exc is not None:
                raise self._connection_lost_exc
            raise ConnectionError("Connection closed by peer")

        if not self._should_pause:
            return

        fut = new_future(self._loop)
        self._write_ready = fut
        await fut

    async def restore(self):
        try:
            if not self._connection_lost and not self._transport.is_closing():
                await self.drain()
        finally:
            self._transport.set_protocol(self._proto)
            if self._reading_paused and hasattr(self._transport, "resume_reading"):
                self._transport.resume_reading()
            if self._write_ready is not None and not self._write_ready.done():
                self._write_ready.cancel()
            self._write_ready = None

    def connection_made(self, transport):
        raise RuntimeError("Invalid state: connection_made called on SendfileProtocol")

    def connection_lost(self, exc):
        self._connection_lost = True
        self._connection_lost_exc = exc
        if self._write_ready is not None and not self._write_ready.done():
            if exc is None:
                self._write_ready.set_exception(
                    ConnectionError("Connection closed by peer")
                )
            else:
                self._write_ready.set_exception(exc)
        if self._proto is not None:
            self._proto.connection_lost(exc)

    def pause_writing(self):
        self._should_pause = True

    def resume_writing(self):
        self._should_pause = False
        if self._write_ready is not None and not self._write_ready.done():
            self._write_ready.set_result(None)
            self._write_ready = None

    def data_received(self, data):
        if self._proto is not None:
            self._proto.data_received(data)

    def get_buffer(self, sizehint):
        if self._proto is not None:
            return self._proto.get_buffer(sizehint)
        raise NotImplementedError()

    def buffer_updated(self, nbytes):
        if self._proto is not None:
            self._proto.buffer_updated(nbytes)

    def eof_received(self):
        if self._proto is not None:
            return self._proto.eof_received()
        return False


async def _sendfile_base_file(
    object transport,
    BaseFile file,
    int64_t offset,
    object count,
    Py_ssize_t chunk_size,
    object loop,
):
    cdef:
        int64_t file_size
        int64_t available
        int64_t to_send
        int64_t sent = 0
        Py_ssize_t n
        bytes chunk
        SendfileProtocol proto

    if not file.file_mode.binary:
        raise ValueError("file should be opened in binary mode")
    if file.fd < 0:
        raise ValueError("I/O operation on closed file")

    file_size = af_regular_file_size(file.fd)
    if file_size < 0:
        raise asyncio.SendfileNotAvailableError("not a regular file")
    file.size = file_size

    available = max(<int64_t>0, file_size - offset)
    if count is not None:
        to_send = min(<int64_t>count, available)
    else:
        to_send = available

    file.seek(offset)
    if to_send <= 0:
        return 0

    proto = SendfileProtocol(transport, loop)
    try:
        while sent < to_send:
            n = <Py_ssize_t>min(<int64_t>chunk_size, to_send - sent)
            chunk = await file.read(n)
            if not chunk:
                break
            await proto.drain()
            if proto._connection_lost or transport.is_closing():
                if proto._connection_lost_exc is not None:
                    raise proto._connection_lost_exc
                raise ConnectionError("Connection closed by peer")
            transport.write(chunk)
            sent += len(chunk)
    finally:
        await proto.restore()

    return sent


async def _sendfile_borrowed_fd(
    object transport,
    object file,
    int64_t offset,
    object count,
    Py_ssize_t chunk_size,
    object loop,
    str backend,
):
    cdef:
        int fd
        int64_t file_size
        int64_t available
        int64_t to_send
        int64_t sent = 0
        Py_ssize_t n
        bytes chunk
        BufferManager buffer_mgr
        uv.uv_loop_t* uv_loop = NULL
        EventLoopPump pump = None
        IOOperation io_op = None
        object uring_pump = None
        object io_op_uring = None
        FileReader uv_reader
        SendfileProtocol proto

    if "b" not in getattr(file, "mode", "b"):
        raise ValueError("file should be opened in binary mode")

    if getattr(file, "closed", False):
        raise ValueError("I/O operation on closed file")

    try:
        fd = file.fileno()
    except (AttributeError, io.UnsupportedOperation) as exc:
        raise asyncio.SendfileNotAvailableError("not a regular file") from exc

    file_size = af_regular_file_size(fd)
    if file_size < 0:
        raise asyncio.SendfileNotAvailableError("not a regular file")

    available = max(<int64_t>0, file_size - offset)
    if count is not None:
        to_send = min(<int64_t>count, available)
    else:
        to_send = available

    if to_send <= 0:
        try:
            os.lseek(fd, offset, os.SEEK_SET)
        except OSError:
            pass
        if hasattr(file, "seek"):
            try:
                file.seek(offset)
            except OSError:
                pass
        return 0

    buffer_mgr = BufferManager(chunk_size)

    if backend == "io_uring":
        from .io_uring_file_io import IOUringFileReader
        from .io_uring_operations import create_io_uring_operation
        from .io_uring_pump import get_or_create_uring_pump, release_uring_pump

        uring_pump = get_or_create_uring_pump(loop)
        io_op_uring = create_io_uring_operation(loop, uring_pump, fd, "")
    else:
        pump = _get_or_create_pump(loop, NULL)
        uv_loop = pump.uv_loop
        io_op = IOOperation.create(loop, uv_loop, fd, "")

    proto = SendfileProtocol(transport, loop)
    try:
        while sent < to_send:
            n = <Py_ssize_t>min(<int64_t>chunk_size, to_send - sent)
            if backend == "io_uring":
                reader = IOUringFileReader(
                    io_op_uring, buffer_mgr, offset + sent, file_size, True
                )
                chunk = await reader.read(n)
            else:
                uv_reader = FileReader(
                    io_op, buffer_mgr, offset + sent, file_size, True
                )
                chunk = await uv_reader.read(n, pump)

            if not chunk:
                break

            await proto.drain()
            if proto._connection_lost or transport.is_closing():
                if proto._connection_lost_exc is not None:
                    raise proto._connection_lost_exc
                raise ConnectionError("Connection closed by peer")
            transport.write(chunk)
            sent += len(chunk)
    finally:
        try:
            try:
                os.lseek(fd, offset + sent, os.SEEK_SET)
            except OSError:
                pass
            if hasattr(file, "seek"):
                try:
                    file.seek(offset + sent)
                except OSError:
                    pass
        finally:
            if backend == "io_uring":
                release_uring_pump(loop)
            else:
                release_shared_pump(loop)
            await proto.restore()

    return sent


async def sendfile_impl(
    object transport,
    object file,
    object offset,
    object count,
    Py_ssize_t chunk_size,
    object loop,
    str backend,
):
    validate_sendfile_args(transport, offset, count, chunk_size)

    if isinstance(file, BaseFile):
        return await _sendfile_base_file(
            transport, <BaseFile>file, <int64_t>offset, count, chunk_size, loop
        )

    return await _sendfile_borrowed_fd(
        transport, file, <int64_t>offset, count, chunk_size, loop, backend
    )
