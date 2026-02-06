# cython: language_level=3

from . cimport uv
from .context cimport FSReadContext, FSWriteContext

cdef void _free_uv_bufs(uv.uv_buf_t* bufs, Py_ssize_t count) noexcept nogil
cdef void _cleanup_context(void* ctx, uv.uv_fs_t* req, object future) noexcept
cdef void _cleanup_read_context(FSReadContext* ctx, uv.uv_fs_t* req, object future) noexcept
cdef void _cleanup_write_context(FSWriteContext* ctx, uv.uv_fs_t* req, object future, object refs=*) noexcept
