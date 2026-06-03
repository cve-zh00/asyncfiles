# cython: language_level=3

cdef tuple _parse_kernel_version(str release)
cdef bint _detect_io_uring_support()
cpdef str resolve_backend(str backend)
