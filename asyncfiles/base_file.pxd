# cython: language_level=3

from . cimport uv
from .utils cimport FileMode, _PinnedBuffer
from .event_loop cimport EventLoopPump
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from libc.stdint cimport int64_t

cdef class BaseFile:
    cdef:
        readonly str path
        const char* path_cstr
        int fd, flags
        int64_t size, offset
        object loop
        uv.uv_loop_t* uv_loop
        readonly size_t buffer_size
        FileMode file_mode
        EventLoopPump pump
        IOOperation io_op
        BufferManager buffer_mgr
        str backend
        object uring_pump
        object io_op_uring
        bint _is_uring
        bint _pump_acquired
        bint _closed
        bint _io_busy
        object _io_waiters

    cdef void _release_pump(self)
    cdef object _wait_io_turn(self)
    cdef void _release_io_turn(self)
    cpdef seek(self, int64_t offset, int whence=*)
    cpdef tell(self)
    cdef object _read_internal(self, Py_ssize_t length=*, int64_t read_offset=*)
    cdef object _readinto_internal(self, _PinnedBuffer pinned, Py_ssize_t length, int64_t read_offset=*)
    cdef object _write_internal(self, object bdata, int64_t write_offset=*)
