# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .utils cimport FileMode
from .event_loop cimport EventLoopPump
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .file_io cimport FileReader, FileWriter
from cpython.unicode cimport PyUnicode_AsUTF8
from libc.stdint cimport int64_t


cdef class BaseFile:
    def __init__(self, str path, FileMode mode, size_t buffer_size, object loop):
        self.path = path
        self.path_cstr = PyUnicode_AsUTF8(path)
        self.flags = mode.flags
        self.buffer_size = buffer_size
        self.loop = loop
        self.uv_loop = uv.uv_default_loop()
        self.file_mode = mode
        self.fd = -1
        self.size = -1

        self.offset = -1 if mode.appending else 0

        self.pump = EventLoopPump.create(self.uv_loop)
        self.io_op = IOOperation.create(loop, self.uv_loop, self.fd, self.path_cstr)
        self.buffer_mgr = BufferManager(buffer_size)

        self.pump.start()

    async def __aenter__(self):
        cdef int err

        self.io_op.fd = self.fd
        future = self.io_op.open_file(self.flags)
        self.fd = await future
        self.io_op.fd = self.fd

        if self.file_mode.readable:
            self.size = await self.io_op.get_stat()

        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.fd >= 0:
            await self.io_op.close_file()

        await self.pump.stop()

    async def truncate(self, int64_t length=0):
        await self.io_op.truncate_file(length)
        if self.file_mode.readable:
            self.size = length
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

    cdef object _read_internal(self, int length=-1):
        cdef FileReader reader = FileReader(
            self.io_op,
            self.buffer_mgr,
            self.offset,
            self.size,
            self.file_mode.binary
        )
        return reader.read(length)

    cdef object _write_internal(self, bytes bdata):
        cdef FileWriter writer = FileWriter(
            self.io_op,
            self.buffer_mgr,
            self.offset
        )
        return writer.write(bdata)
