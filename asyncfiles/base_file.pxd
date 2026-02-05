# cython: language_level=3

from . cimport uv
from .utils cimport FileMode
from .event_loop cimport EventLoopPump
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from libc.stdint cimport int64_t

cdef class BaseFile:
    cdef:
        str path
        const char* path_cstr
        int fd, flags
        int64_t size, offset
        object loop
        uv.uv_loop_t* uv_loop
        size_t buffer_size
        FileMode file_mode
        EventLoopPump pump
        IOOperation io_op
        BufferManager buffer_mgr

    cpdef seek(self, int64_t offset, int whence=*)
    cpdef tell(self)
    cdef object _read_internal(self, int length=*)
    cdef object _write_internal(self, bytes bdata)
