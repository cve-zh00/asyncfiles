# cython: language_level=3

from . cimport uv

cdef class EventLoopPump:
    cdef:
        uv.uv_loop_t* uv_loop
        object _pump_task

    @staticmethod
    cdef EventLoopPump create(uv.uv_loop_t* uv_loop)
    cdef int run_nowait(self) noexcept nogil
    cdef start(self)
