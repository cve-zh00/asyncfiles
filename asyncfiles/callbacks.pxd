from .cpython cimport PyObject
from . cimport uv
from .context cimport FSReadContext


cdef class _ReadResult:
    cdef:
        FSReadContext* ctx
        Py_ssize_t bytes_read


cdef void cb_open(uv.uv_fs_t* req) noexcept with gil
cdef void cb_close(uv.uv_fs_t* req) noexcept with gil
cdef void cb_write(uv.uv_fs_t* req) noexcept with gil
cdef void cb_read(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat(uv.uv_fs_t* req) noexcept with gil
cdef void cb_ftruncate(uv.uv_fs_t* req) noexcept with gil
