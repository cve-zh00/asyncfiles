# cython: language_level=3

from . cimport uv
from .event_loop cimport EventLoopPump
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .utils cimport _PinnedBuffer
from libc.stdint cimport int64_t

cdef object submit_uv_read(
    IOOperation io_op,
    int64_t offset,
    int64_t size,
    bint binary,
    Py_ssize_t length,
    EventLoopPump pump,
)
cdef object submit_uv_readinto(
    IOOperation io_op,
    int64_t offset,
    _PinnedBuffer pinned,
    Py_ssize_t total,
    EventLoopPump pump,
)
cdef object submit_uv_write(
    IOOperation io_op,
    int64_t offset,
    object bdata,
    EventLoopPump pump,
)


cdef class FileReader:
    cdef:
        IOOperation io_op
        BufferManager buffer_mgr
        int64_t offset, size
        bint binary

    @staticmethod
    cdef FileReader create(
        IOOperation io_op,
        BufferManager buffer_mgr,
        int64_t offset,
        int64_t size,
        bint binary,
    )
    cdef object _submit_read(
        self, char* chunk_ptr, Py_ssize_t total, object keep_obj, uv.uv_fs_cb cb
    )
    cdef object _read_internal(self, Py_ssize_t length=*)
    cdef object _readinto_internal(self, _PinnedBuffer pinned, Py_ssize_t total)


cdef class FileWriter:
    cdef:
        IOOperation io_op
        BufferManager buffer_mgr
        int64_t offset

    @staticmethod
    cdef FileWriter create(
        IOOperation io_op,
        BufferManager buffer_mgr,
        int64_t offset,
    )
    cdef object write(self, object bdata)

