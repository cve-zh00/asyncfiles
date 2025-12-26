# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .context cimport FSReadContext, FSWriteContext
from libc.stdlib cimport malloc, free
from cpython.ref cimport Py_DECREF


cdef inline void _free_uv_bufs(uv.uv_buf_t* bufs, Py_ssize_t count) noexcept nogil:
    cdef Py_ssize_t j
    for j in range(count):
        if bufs[j].base != NULL:
            free(bufs[j].base)
    free(bufs)


cdef inline void _cleanup_context(void* ctx, uv.uv_fs_t* req, object future) noexcept:
    if ctx != NULL:
        free(ctx)

    if req != NULL:
        free(req)

    if future is not None:
        Py_DECREF(future)


cdef inline void _cleanup_read_context(FSReadContext* ctx, uv.uv_fs_t* req, object future) noexcept:
    if ctx != NULL:
        if ctx.bufs != NULL:
            _free_uv_bufs(ctx.bufs, ctx.nbufs)
        free(ctx)

    if req != NULL:
        free(req)

    if future is not None:
        Py_DECREF(future)


cdef inline void _cleanup_write_context(FSWriteContext* ctx, uv.uv_fs_t* req, object future, object refs=None) noexcept:
    if ctx != NULL:
        if ctx.bufs != NULL:
            free(ctx.bufs)
        free(ctx)

    if req != NULL:
        free(req)

    if refs is not None:
        Py_DECREF(refs)

    if future is not None:
        Py_DECREF(future)
