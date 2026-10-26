# cython: language_level=3

from .io_uring_pump cimport IOUringPump
from libc.stdint cimport int64_t, uint64_t

cdef class IOUringOperation:
    cdef:
        object loop
        IOUringPump pump
        public int fd
        const char* path_cstr
        object _path_ref

    @staticmethod
    cdef IOUringOperation create(object loop, IOUringPump pump, int fd, const char* path_cstr)
    cdef object open_file(self, int flags)
    cdef object close_file(self)
    cdef object read(self, char* buf, unsigned int nbytes, int64_t offset, object keep=*)
    cdef object write(self, const char* buf, unsigned int nbytes, int64_t offset, object keep=*)
    cdef object get_stat(self)
    cdef tuple open_and_stat(self, int flags)
    cdef object truncate_file(self, int64_t length)
