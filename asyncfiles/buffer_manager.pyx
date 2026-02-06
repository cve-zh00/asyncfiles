# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from libc.stdlib cimport malloc, free
cimport cython


cdef class BufferManager:
    def __init__(self, size_t buffer_size):
        self.buffer_size = buffer_size

    @cython.cdivision(True)
    cdef uv.uv_buf_t* create_write_buffers(self, char* base_ptr, Py_ssize_t total_bytes, int* out_nbufs):
        cdef:
            int nbufs = <int>((total_bytes + self.buffer_size - 1) // self.buffer_size)
            uv.uv_buf_t* bufs
            int i, chunk_len
            Py_ssize_t offset

        if total_bytes <= 0:
            out_nbufs[0] = 0
            return NULL

        bufs = <uv.uv_buf_t*>malloc(nbufs * sizeof(uv.uv_buf_t))
        if bufs == NULL:
            out_nbufs[0] = 0
            return NULL

        # Write buffers just point to existing data
        if nbufs == 1:
            bufs[0] = uv.uv_buf_init(base_ptr, <unsigned int>total_bytes)
        else:
            for i in range(nbufs):
                offset = i * self.buffer_size
                chunk_len = total_bytes - offset
                if chunk_len > self.buffer_size:
                    chunk_len = self.buffer_size
                bufs[i] = uv.uv_buf_init(base_ptr + offset, <unsigned int>chunk_len)

        out_nbufs[0] = nbufs
        return bufs
