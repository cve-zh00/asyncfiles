# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: initializedcheck=False
from . cimport uv
from libc.stdlib      cimport malloc, free
from libc.string      cimport memcpy

# PyObject y manejo de referencias
from cpython.ref      cimport Py_INCREF, Py_DECREF, Py_CLEAR
from cpython.object   cimport PyObject

# Bytes y bytearray
from cpython.bytes        cimport PyBytes_FromStringAndSize, PyBytes_AS_STRING, PyBytes_FromObject
from cpython.bytearray    cimport (
    PyByteArray_FromStringAndSize,
    PyByteArray_AsString,
    PyByteArray_Size,
    PyByteArray_Resize
)

from .context cimport FSOpenContext, FSRWContext, FSReadContext, FSWriteContext, FSCloseContext

cdef inline void __free(FSRWContext* ctx) noexcept:
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



cdef void cb_read(uv.uv_fs_t* req) noexcept with gil:
    cdef:
        FSReadContext* ctx = <FSReadContext*>req.data
        int err = req.result
        object future = <object>ctx.future
        object result_obj
        Py_ssize_t actual_size
        char* dest
        Py_ssize_t chunk_len, i, offset

    try:
        if err < 0:
            future.set_exception(OSError(err))
            return

        actual_size = err
        if ctx.requested_size > 0 and actual_size > ctx.requested_size:
            actual_size = ctx.requested_size

        if actual_size <= 0:
            future.set_result(b"")
            return

        if ctx.nbufs == 1:
            result_obj = PyBytes_FromStringAndSize(ctx.bufs[0].base, actual_size)
        else:
            result_obj = PyBytes_FromStringAndSize(NULL, actual_size)
            dest = PyBytes_AS_STRING(<bytes>result_obj)
            offset = 0
            for i in range(ctx.nbufs):
                chunk_len = ctx.bufs[i].len
                if offset + chunk_len > actual_size:
                    chunk_len = actual_size - offset
                if chunk_len > 0:
                    memcpy(dest + offset, ctx.bufs[i].base, chunk_len)
                    offset += chunk_len
                if offset >= actual_size:
                    break

        future.set_result(result_obj)

    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        __free(ctx)
        Py_DECREF(future)
