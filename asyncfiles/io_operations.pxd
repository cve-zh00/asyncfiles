# cython: language_level=3

from . cimport uv
from libc.stdint cimport int64_t

cdef class IOOperation:
    cdef:
        object loop
        uv.uv_loop_t* uv_loop
        int fd
        const char* path_cstr

    @staticmethod
    cdef IOOperation create(object loop, uv.uv_loop_t* uv_loop, int fd, const char* path_cstr)
    cdef object open_file(self, int flags)
    cdef object close_file(self)
    cdef object get_stat(self)
    cdef object truncate_file(self, int64_t length)
