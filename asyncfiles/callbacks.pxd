from .cpython cimport PyObject
from . cimport uv



cdef void cb_open(uv.uv_fs_t* req) noexcept with gil
cdef void cb_close(uv.uv_fs_t* req) noexcept with gil
cdef void cb_write(uv.uv_fs_t* req) noexcept with gil
cdef void cb_read(uv.uv_fs_t* req) noexcept with gil
cdef void cb_stat(uv.uv_fs_t* req) noexcept with gil
