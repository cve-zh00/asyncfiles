# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .utils cimport FileMode
from .event_loop cimport EventLoopPump, _get_or_create_pump, release_shared_pump
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .file_io cimport FileReader, FileWriter
from cpython.unicode cimport PyUnicode_AsUTF8
from libc.stdint cimport int64_t


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

        self.offset = -1 if mode.appending else 0

        if backend == "io_uring":
            # Conditional imports to avoid errors on non-Linux platforms
            from .io_uring_pump import get_or_create_uring_pump
            from .io_uring_operations import create_io_uring_operation

            self.uring_pump = get_or_create_uring_pump(loop)
            self.io_op_uring = create_io_uring_operation(loop, self.uring_pump, self.fd, self.path)
            self.pump = None
            self.io_op = None
            self.uv_loop = NULL
        else:
            # Default libuv path — unchanged behavior
            self.uv_loop = uv.uv_default_loop()
            self.pump = _get_or_create_pump(loop, self.uv_loop)
            self.io_op = IOOperation.create(loop, self.uv_loop, self.fd, self.path_cstr)
            self.uring_pump = None
            self.io_op_uring = None

        self.buffer_mgr = BufferManager(buffer_size)

    async def __aenter__(self):
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
                self.size = await self.io_op.get_stat()

        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        try:
            if self.fd >= 0:
                if self.backend == "io_uring":
                    await self.io_op_uring.py_close_file()
                else:
                    await self.io_op.close_file()
        finally:
            if self.backend == "io_uring":
                from .io_uring_pump import release_uring_pump
                release_uring_pump(self.loop)
            else:
                release_shared_pump(self.loop)

    async def truncate(self, int64_t length=0):
        if self.backend == "io_uring":
            await self.io_op_uring.py_truncate_file(length)
        else:
            await self.io_op.truncate_file(length)
        if self.file_mode.readable:
            self.size = length
        if self.offset > length:
            self.offset = length
        return 0

    cpdef seek(self, int64_t offset, int whence=0):
        if whence == 0:
            self.offset = offset
        elif whence == 1:
            self.offset += offset
        elif whence == 2:
            if self.size >= 0:
                self.offset = self.size + offset
            else:
                raise OSError("Cannot seek from end without knowing file size")
        else:
            raise ValueError(f"Invalid whence value: {whence}")

        self.offset = max(0, self.offset)
        return self.offset

    cpdef tell(self):
        return self.offset

    cdef object _read_internal(self, Py_ssize_t length=-1):
        cdef FileReader uv_reader

        if self.backend == "io_uring":
            from .io_uring_file_io import IOUringFileReader
            reader = IOUringFileReader(
                self.io_op_uring,
                self.buffer_mgr,
                self.offset,
                self.size,
                self.file_mode.binary
            )
            return reader.read(length)
        else:
            uv_reader = FileReader(
                self.io_op,
                self.buffer_mgr,
                self.offset,
                self.size,
                self.file_mode.binary
            )
            return uv_reader.read(length)

    cdef object _write_internal(self, object bdata):
        cdef FileWriter uv_writer

        if self.backend == "io_uring":
            from .io_uring_file_io import IOUringFileWriter
            writer = IOUringFileWriter(
                self.io_op_uring,
                self.buffer_mgr,
                self.offset
            )
            return writer.write(bdata)
        else:
            uv_writer = FileWriter(
                self.io_op,
                self.buffer_mgr,
                self.offset
            )
            return uv_writer.write(bdata)
