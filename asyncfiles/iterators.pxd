# cython: language_level=3

cdef class BaseFileIterator:
    cdef:
        object file
        object buffer
        Py_ssize_t chunk_size
        bint exhausted
        bint is_binary
