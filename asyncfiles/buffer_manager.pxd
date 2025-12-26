# cython: language_level=3

from . cimport uv

cdef class BufferManager:
    cdef:
        size_t buffer_size

    cdef tuple calculate_buffer_layout(self, Py_ssize_t total_size)
    cdef uv.uv_buf_t* create_read_buffers(self, Py_ssize_t total_size, Py_ssize_t* out_nbufs)
    cdef uv.uv_buf_t* create_write_buffers(self, char* base_ptr, Py_ssize_t total_bytes, int* out_nbufs)
