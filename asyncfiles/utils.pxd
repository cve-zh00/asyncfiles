from cpython.buffer cimport Py_buffer
from . cimport uv

cdef extern from *:
    """
    #ifdef PYPY_VERSION
    #define ASYNCFILES_PYPY 1
    #else
    #define ASYNCFILES_PYPY 0
    #endif
    """
    enum:
        ASYNCFILES_PYPY


cdef object new_future(object loop)

cdef class _NativeReadBuffer:
    cdef char* data
    cdef bytes finish(self, Py_ssize_t size)


cdef class _PinnedBuffer:
    cdef:
        Py_buffer view
        bint acquired


cdef class FileMode:
    cdef:
        public bint readable
        public bint writable
        public bint plus
        public bint appending
        public bint created
        public int flags
        public bint binary

