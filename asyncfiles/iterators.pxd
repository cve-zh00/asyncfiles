# cython: language_level=3

cdef class BaseFileIterator:
    cdef:
        object file
        object buffer
        int chunk_size
        bint exhausted
        bint is_binary
