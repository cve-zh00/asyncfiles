from . cimport uv


cdef object new_future(object loop)


cdef class FileMode:
    cdef:
        public bint readable
        public bint writable
        public bint plus
        public bint appending
        public bint created
        public int flags
        public bint binary
