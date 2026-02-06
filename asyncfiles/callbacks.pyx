# cython: language_level=3
from . cimport uv
from libc.stdlib      cimport malloc, free
from libc.string      cimport memcpy
from libc.stdint      cimport int64_t

# PyObject y manejo de referencias
from cpython.ref      cimport Py_INCREF, Py_DECREF, Py_CLEAR
from cpython.object   cimport PyObject

# Bytes y bytearray
from cpython.bytes        cimport PyBytes_FromStringAndSize, PyBytes_AS_STRING
from cpython.bytearray    cimport (
    PyByteArray_FromStringAndSize,
    PyByteArray_AsString,
    PyByteArray_Size,
    PyByteArray_Resize
)

from .context cimport FSOpenContext, FSRWContext, FSReadContext, FSWriteContext, FSCloseContext

cdef inline void __free_read_ctx(FSReadContext* ctx):
    """Free read context buffers"""
    if ctx == NULL:
        return

    # Free single memory block
    if ctx.buffer_mem != NULL:
        free(ctx.buffer_mem)
    
    # Free the buffer array (just the array of uv_buf_t, not individual bases)
    if ctx.bufs != NULL:
        free(ctx.bufs)

    if ctx.future != NULL:
        Py_DECREF(<object>ctx.future)
        ctx.future = NULL
    
    free(ctx)


cdef inline void __free(FSRWContext* ctx):
    cdef Py_ssize_t j
    if ctx == NULL:
        return

    if ctx.bufs != NULL:
        for j in range(ctx.nbufs):
            if ctx.bufs[j].base != NULL:
                free(ctx.bufs[j].base)
        free(ctx.bufs)
        ctx.bufs = NULL

    if ctx.future != NULL:
        Py_DECREF(<object>ctx.future)
        ctx.future = NULL
    free(ctx)


cdef void cb_open(uv.uv_fs_t* req) noexcept with gil:
    cdef FSOpenContext* ctx = <FSOpenContext*>req.data
    cdef object future = <object>ctx.future
    cdef int err = req.result
    cdef int result_obj

    try:
        if err < 0:
            if err == -2:
                future.set_exception(FileNotFoundError())
            elif err == -17:
                future.set_exception(FileExistsError())
            else:
                future.set_exception(OSError(err))
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
            future.set_exception(OSError(err))
        else:
            future.set_result(req.statbuf.st_size)

    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)

cdef void cb_close(uv.uv_fs_t* req) noexcept with gil:

    cdef FSOpenContext* ctx = <FSOpenContext*>req.data
    cdef object future = <object>ctx.future
    cdef int err = req.result
    cdef int result_obj
    try:
        if err < 0:
            future.set_exception(OSError(err))
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
            future.set_exception(OSError(err))
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
            future.set_exception(OSError(err))
        else:
            future.set_result(err)

        if ctx._refs != NULL:
            Py_DECREF(<object> ctx._refs)

    finally:

        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)



cdef class _ReadResult:
    """Lightweight wrapper to pass read context through Python"""
    
    def __cinit__(self):
        self.ctx = NULL
        self.bytes_read = 0


cdef void cb_read(uv.uv_fs_t* req) noexcept with gil:
    """Minimal callback - just capture result and schedule processing"""
    cdef:
        FSReadContext* ctx = <FSReadContext*>req.data
        int result = req.result
        object future = <object>ctx.future
        _ReadResult wrapper

    try:
        if result < 0:
            future.set_exception(OSError(result))
        else:
            # Create wrapper to pass context to post-processor
            wrapper = _ReadResult()
            wrapper.ctx = ctx
            wrapper.bytes_read = result
            future.set_result(wrapper)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
