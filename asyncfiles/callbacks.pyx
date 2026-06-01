# cython: language_level=3
from . cimport uv
from libc.stdlib      cimport malloc, free
from libc.stdint      cimport int64_t

from cpython.ref      cimport Py_INCREF, Py_DECREF
from cpython.object   cimport PyObject

from .context cimport FSOpenContext, FSReadContext, FSWriteContext


cdef void cb_open(uv.uv_fs_t* req) noexcept with gil:
    cdef FSOpenContext* ctx = <FSOpenContext*>req.data
    cdef object future = <object>ctx.future
    cdef int err = req.result
    cdef int result_obj

    try:
        if err < 0:
            future.set_exception(OSError(-err, "open failed"))
        else:
            result_obj = req.result
            future.set_result(result_obj)

    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        free(ctx)
        Py_DECREF(future)

cdef void cb_stat(uv.uv_fs_t* req) noexcept with gil:

    cdef FSOpenContext* ctx = <FSOpenContext*>req.data
    cdef object future = <object>ctx.future
    cdef int err = req.result

    try:
        if err < 0:
            future.set_exception(OSError(-err, "stat failed"))
        else:
            future.set_result(req.statbuf.st_size)

    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        free(ctx)
        Py_DECREF(future)

cdef void cb_close(uv.uv_fs_t* req) noexcept with gil:

    cdef FSOpenContext* ctx = <FSOpenContext*>req.data
    cdef object future = <object>ctx.future
    cdef int err = req.result
    cdef int result_obj
    try:
        if err < 0:
            future.set_exception(OSError(-err, "close failed"))
        else:
            result_obj = req.result
            future.set_result(result_obj)

    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        free(ctx)
        Py_DECREF(future)


cdef void cb_ftruncate(uv.uv_fs_t* req) noexcept with gil:
    """Callback para operación ftruncate"""
    cdef FSOpenContext* ctx = <FSOpenContext*>req.data
    cdef object future = <object>ctx.future
    cdef int err = req.result

    try:
        if err < 0:
            future.set_exception(OSError(-err, "ftruncate failed"))
        else:
            future.set_result(0)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        free(ctx)
        Py_DECREF(future)


cdef void cb_write(uv.uv_fs_t* req) noexcept with gil:
    cdef FSWriteContext* ctx = <FSWriteContext*> req.data
    cdef object future = <object> ctx.future
    cdef Py_ssize_t err = req.result
    try:
        if err < 0:
            future.set_exception(OSError(<int>-err, "write failed"))
        else:
            future.set_result(err)
    finally:
        if ctx._refs != NULL:
            Py_DECREF(<object> ctx._refs)
        if ctx.bufs != NULL:
            free(ctx.bufs)
        uv.uv_fs_req_cleanup(req)
        free(req)
        free(ctx)
        Py_DECREF(future)



cdef class _ReadResult:
    """Lightweight wrapper to pass read context through Python.
    
    Has __dealloc__ to ensure cleanup if the wrapper gets GC'd without
    being processed (e.g. if the awaiting coroutine is cancelled).
    """
    
    def __cinit__(self):
        self.ctx = NULL
        self.bytes_read = 0

    def __dealloc__(self):
        cdef FSReadContext* ctx = self.ctx
        if ctx != NULL:
            if ctx.buffer_mem != NULL:
                free(ctx.buffer_mem)
            if ctx.bufs != NULL:
                free(ctx.bufs)
            if ctx.future != NULL:
                Py_DECREF(<object>ctx.future)
            free(ctx)
            self.ctx = NULL


cdef void cb_read(uv.uv_fs_t* req) noexcept with gil:
    """Minimal callback - just capture result and schedule processing"""
    cdef:
        FSReadContext* ctx = <FSReadContext*>req.data
        int result = req.result
        object future = <object>ctx.future
        _ReadResult wrapper

    try:
        if result < 0:
            future.set_exception(OSError(-result, "read failed"))
            # Free ctx on error path since no _ReadResult will own it
            if ctx.buffer_mem != NULL:
                free(ctx.buffer_mem)
            if ctx.bufs != NULL:
                free(ctx.bufs)
            Py_DECREF(future)
            free(ctx)
        else:
            # Create wrapper to pass context to post-processor
            # _ReadResult now owns ctx and will free it in __dealloc__
            # if _process_read_result doesn't consume it first
            wrapper = _ReadResult()
            wrapper.ctx = ctx
            wrapper.bytes_read = result
            future.set_result(wrapper)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
