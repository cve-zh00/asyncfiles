# cython: language_level=3

from . cimport uv
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from libc.stdint cimport int64_t

cdef class FileReader:
    cdef:
        IOOperation io_op
        BufferManager buffer_mgr
        int64_t offset, size
        bint binary

    cdef object read(self, int length=*)


cdef class FileWriter:
    cdef:
        IOOperation io_op
        BufferManager buffer_mgr
        int64_t offset

    cdef object write(self, bytes bdata)
