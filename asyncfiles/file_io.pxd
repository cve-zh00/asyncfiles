# cython: language_level=3

from . cimport uv
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .utils cimport _PinnedBuffer
from libc.stdint cimport int64_t

cdef class FileReader:
    cdef:
        IOOperation io_op
        BufferManager buffer_mgr
        int64_t offset, size
        bint binary

    cdef object _read_internal(self, Py_ssize_t length=*)
    cdef object _readinto_internal(self, _PinnedBuffer pinned, Py_ssize_t total)


cdef class FileWriter:
    cdef:
        IOOperation io_op
        BufferManager buffer_mgr
        int64_t offset

    cdef object write(self, object bdata)
