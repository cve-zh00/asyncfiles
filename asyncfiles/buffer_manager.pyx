# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from libc.stdlib cimport malloc, free, calloc
from .memory_utils cimport _free_uv_bufs
cimport cython


cdef inline uv.uv_buf_t* _make_uv_bufs(char* data_ptr, Py_ssize_t size, size_t buffer_size, int count) noexcept nogil:
    cdef uv.uv_buf_t* bufs = <uv.uv_buf_t*>malloc(count * sizeof(uv.uv_buf_t))
    cdef char* ptr
    if bufs == NULL:
        return NULL

    # Optimización: Buffer único - usar malloc siempre (calloc es más lento)
    if count == 1:
        ptr = <char*>malloc(size)
        if ptr == NULL:
            free(bufs)
            return NULL
        bufs[0] = uv.uv_buf_init(ptr, <unsigned int>size)
        return bufs

    # Optimización: Múltiples buffers
    cdef Py_ssize_t i
    cdef Py_ssize_t chunk_len
    cdef char* chunk_ptr
    cdef Py_ssize_t remaining = size

    for i in range(count):
        # Último buffer toma solo lo que queda
        chunk_len = buffer_size if remaining > buffer_size else remaining
        chunk_ptr = <char*>malloc(chunk_len)
        if chunk_ptr == NULL:
            _free_uv_bufs(bufs, i)
            free(bufs)
            return NULL
        bufs[i] = uv.uv_buf_init(chunk_ptr, <unsigned int>chunk_len)
        remaining -= chunk_len

    return bufs


cdef class BufferManager:
    def __init__(self, size_t buffer_size):
        self.buffer_size = buffer_size



    @cython.cdivision(True)
    cdef uv.uv_buf_t* create_read_buffers(self, Py_ssize_t total_size, Py_ssize_t* out_nbufs):
        cdef Py_ssize_t chunk_size, total_bufs
        
        if total_size <= 0:
            out_nbufs[0] = 0
            return NULL

        # Optimización 1: Buffer único para archivos pequeños (mejor cache locality)
        if total_size <= self.buffer_size:
            out_nbufs[0] = 1
            return _make_uv_bufs(NULL, total_size, total_size, 1)
        
        # Optimización 2: Limitar nbufs para aprovechar preadv eficientemente
        # macOS iovmax ~1024, pero menos buffers = menos overhead
        total_bufs = (total_size + self.buffer_size - 1) // self.buffer_size
        
        # Limitar a 128 buffers para balance overhead vs syscalls
        if total_bufs > 128:
            total_bufs = 128
            chunk_size = (total_size + 127) // 128
        else:
            chunk_size = self.buffer_size

        out_nbufs[0] = total_bufs
        return _make_uv_bufs(NULL, total_size, chunk_size, total_bufs)

    @cython.cdivision(True)
    cdef uv.uv_buf_t* create_write_buffers(self, char* base_ptr, Py_ssize_t total_bytes, int* out_nbufs):
        cdef:
            int nbufs = <int>((total_bytes + self.buffer_size - 1) // self.buffer_size)
            uv.uv_buf_t* bufs = <uv.uv_buf_t*>malloc(nbufs * sizeof(uv.uv_buf_t))
            int i, chunk_len
            Py_ssize_t offset

        if bufs == NULL:
            out_nbufs[0] = 0
            return NULL

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
