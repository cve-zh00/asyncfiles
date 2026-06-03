# cython: language_level=3

from .uring cimport io_uring
from libc.stdint cimport uint64_t

cdef class IOUringPump:
    cdef:
        io_uring ring
        int eventfd
        int _ref_count
        bint _running
        bint _submit_scheduled
        uint64_t _next_ud
        object _asyncio_loop
        dict _pending_futures

    @staticmethod
    cdef IOUringPump create(object asyncio_loop, unsigned int queue_depth)
    cdef uint64_t alloc_user_data(self) noexcept
    cdef acquire(self)
    cdef bint release(self)
    cdef start(self)
    cdef schedule_submit(self)
    cdef _stop(self)
    cdef _reap_completions(self)
    cdef object submit_sqe(self, object future, uint64_t user_data)

cdef IOUringPump _get_or_create_uring_pump(object asyncio_loop)
cpdef release_uring_pump(object asyncio_loop)
