# cython: language_level=3

from . cimport uv

cdef class EventLoopPump:
    cdef:
        uv.uv_loop_t* uv_loop
        object _asyncio_loop
        int _backend_fd
        bint _running
        int _ref_count

    @staticmethod
    cdef EventLoopPump create(uv.uv_loop_t* uv_loop, object asyncio_loop)
    cdef inline int run_nowait(self) noexcept nogil
    cdef start(self)
    cdef acquire(self)
    cdef bint release(self)
    cdef _stop(self)


cdef EventLoopPump _get_or_create_pump(object asyncio_loop, uv.uv_loop_t* uv_loop)
cpdef EventLoopPump get_shared_pump(object asyncio_loop)
cpdef release_shared_pump(object asyncio_loop)
