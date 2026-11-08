# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .utils cimport FileMode, new_future
from .event_loop cimport EventLoopPump, _get_or_create_pump, release_shared_pump
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .file_io cimport FileReader, FileWriter
from cpython.unicode cimport PyUnicode_AsUTF8
from libc.stdint cimport int64_t
from collections import deque
import errno
import io
import os


class _NegativeSeekError(OSError, ValueError):
    """Raised when seek() results in a negative stream position."""


def _consume_future_result(fut):
    if not fut.cancelled():
        fut.exception()


cdef class BaseFile:
    def __init__(self, str path, FileMode mode, size_t buffer_size, object loop,
                 str backend="libuv"):
        self.path = path
        self.path_cstr = PyUnicode_AsUTF8(path)
        self.flags = mode.flags
        self.buffer_size = buffer_size
        self.loop = loop
        self.file_mode = mode
        self.fd = -1
        self.size = -1
        self.backend = backend
        self._pump_acquired = False
        self._closed = False
        self._io_busy = False
        self._io_waiters = None

        self.offset = -1 if mode.appending else 0

        if backend == "io_uring":
            # Conditional imports to avoid errors on non-Linux platforms
            from .io_uring_pump import get_or_create_uring_pump
            from .io_uring_operations import create_io_uring_operation

            self.uring_pump = get_or_create_uring_pump(loop)
            self._pump_acquired = True
            self.io_op_uring = create_io_uring_operation(loop, self.uring_pump, self.fd, self.path)
            self.pump = None
            self.io_op = None
            self.uv_loop = NULL
        else:
            # Default libuv path — unchanged behavior
            self.pump = _get_or_create_pump(loop, NULL)
            self._pump_acquired = True
            self.uv_loop = self.pump.uv_loop
            self.io_op = IOOperation.create(loop, self.uv_loop, self.fd, self.path_cstr)
            self.uring_pump = None
            self.io_op_uring = None

        self.buffer_mgr = BufferManager(buffer_size)

    cdef void _release_pump(self):
        if not self._pump_acquired:
            return
        self._pump_acquired = False
        if self.backend == "io_uring":
            from .io_uring_pump import release_uring_pump
            release_uring_pump(self.loop)
            self.uring_pump = None
        else:
            release_shared_pump(self.loop)
            self.pump = None

    cdef object _wait_io_turn(self):
        if self._io_waiters is None:
            self._io_waiters = deque()
        cdef object waiter = new_future(self.loop)
        self._io_waiters.append(waiter)
        return waiter

    cdef void _release_io_turn(self):
        cdef object waiter
        if self._io_waiters is not None:
            while self._io_waiters:
                waiter = self._io_waiters.popleft()
                if not waiter.done():
                    waiter.set_result(None)
                    return
        self._io_busy = False

    def __dealloc__(self):
        if self._pump_acquired and self.loop is not None:
            try:
                self._release_pump()
            except Exception:
                pass

    @property
    def closed(self):
        return self._closed

    @property
    def name(self):
        return self.path

    def fileno(self):
        if self._closed or self.fd < 0:
            raise ValueError("I/O operation on closed file")
        return self.fd

    async def flush(self):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        return None

    async def close(self):
        await self.__aexit__(None, None, None)

    async def __aenter__(self):
        cdef int fd_to_close
        try:
            if self.backend == "io_uring":
                if self.file_mode.readable:
                    # open + statx are linked and submitted together (1 syscall)
                    open_future, stat_future = self.io_op_uring.py_open_and_stat(self.flags)
                    try:
                        self.fd = await open_future
                    except BaseException:
                        if stat_future.done() and not stat_future.cancelled():
                            stat_future.exception()  # mark retrieved (-ECANCELED)
                        else:
                            stat_future.add_done_callback(_consume_future_result)
                        raise
                    self.io_op_uring.fd = self.fd
                    self.size = await stat_future
                else:
                    self.fd = await self.io_op_uring.py_open_file(self.flags)
                    self.io_op_uring.fd = self.fd
            else:
                open_future = self.io_op.open_file(self.flags)
                self.pump.prime()
                self.fd = await open_future
                self.io_op.fd = self.fd
                if self.file_mode.readable:
                    stat_future = self.io_op.get_stat()
                    self.pump.prime()
                    self.size = await stat_future

            if self.file_mode.appending and self.size >= 0:
                self.offset = self.size
        except BaseException:
            if self.fd >= 0:
                fd_to_close = self.fd
                self.fd = -1
                if self.backend == "io_uring":
                    self.io_op_uring.fd = -1
                else:
                    self.io_op.fd = -1
                try:
                    os.close(fd_to_close)
                except OSError:
                    pass
            self._closed = True
            self._release_pump()
            raise

        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        self._closed = True
        try:
            if self.fd >= 0:
                if self.backend == "io_uring":
                    await self.io_op_uring.py_close_file()
                    self.io_op_uring.fd = -1
                else:
                    close_future = self.io_op.close_file()
                    self.pump.prime()
                    await close_future
                    self.io_op.fd = -1
                self.fd = -1
        finally:
            self._release_pump()

    async def truncate(self, object length=None):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.writable:
            raise io.UnsupportedOperation("File not open for writing")

        cdef int64_t target_length
        if length is not None:
            target_length = <int64_t>length
            if target_length < 0:
                raise ValueError(f"negative size value {target_length}")

        if self._io_busy:
            await self._wait_io_turn()
        else:
            self._io_busy = True

        try:
            if self._closed:
                raise ValueError("I/O operation on closed file")
            if length is None:
                target_length = self.offset
                if target_length < 0:
                    target_length = self.size if self.size >= 0 else 0

            if self.backend == "io_uring":
                await self.io_op_uring.py_truncate_file(target_length)
            else:
                trunc_future = self.io_op.truncate_file(target_length)
                self.pump.prime()
                await trunc_future

            if self.file_mode.readable or self.size >= 0:
                self.size = target_length
            return target_length
        finally:
            self._release_io_turn()

    cpdef seek(self, int64_t offset, int whence=0):
        if self._closed:
            raise ValueError("I/O operation on closed file")

        cdef int64_t target_offset
        if whence == 0:
            target_offset = offset
        elif whence == 1:
            target_offset = self.offset + offset
        elif whence == 2:
            if self.size >= 0:
                target_offset = self.size + offset
            else:
                raise OSError("Cannot seek from end without knowing file size")
        else:
            raise ValueError(f"Invalid whence value: {whence}")

        if target_offset < 0:
            raise _NegativeSeekError(
                errno.EINVAL, f"Negative seek position {target_offset}"
            )

        self.offset = target_offset
        return self.offset

    cpdef tell(self):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        return self.offset

    cdef object _read_internal(self, Py_ssize_t length=-1, int64_t read_offset=-1):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        cdef FileReader uv_reader
        cdef int64_t eff_offset = self.offset if read_offset < 0 else read_offset

        if self.backend == "io_uring":
            from .io_uring_file_io import IOUringFileReader
            reader = IOUringFileReader(
                self.io_op_uring,
                self.buffer_mgr,
                eff_offset,
                self.size,
                self.file_mode.binary
            )
            return reader.read(length)
        else:
            uv_reader = FileReader(
                self.io_op,
                self.buffer_mgr,
                eff_offset,
                self.size,
                self.file_mode.binary
            )
            return uv_reader.read(length, self.pump)

    cdef object _write_internal(self, object bdata, int64_t write_offset=-2):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        cdef FileWriter uv_writer
        cdef object write_future
        cdef int64_t eff_offset
        if write_offset == -2:
            eff_offset = -1 if self.file_mode.appending else self.offset
        else:
            eff_offset = write_offset

        if self.backend == "io_uring":
            from .io_uring_file_io import IOUringFileWriter
            writer = IOUringFileWriter(
                self.io_op_uring,
                self.buffer_mgr,
                eff_offset
            )
            return writer.write(bdata)
        else:
            uv_writer = FileWriter(
                self.io_op,
                self.buffer_mgr,
                eff_offset
            )
            write_future = uv_writer.write(bdata)
            self.pump.prime()
            return write_future
