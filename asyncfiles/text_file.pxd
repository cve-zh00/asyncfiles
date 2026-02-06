# cython: language_level=3

from .base_file cimport BaseFile


cdef class TextFile(BaseFile):
    pass
