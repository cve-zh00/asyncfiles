# cython: language_level=3
from . cimport uv
from libc.stdlib      cimport malloc, free
from libc.string      cimport memcpy

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

cdef inline void __free(FSRWContext* ctx):
    cdef:
        Py_ssize_t count = ctx.nbufs
        Py_ssize_t j

    if ctx == NULL:
        return

    if ctx.bufs != NULL:
        for j in range(count):
            if ctx.bufs[j].base != NULL:
                free(ctx.bufs[j].base)
                ctx.bufs[j].base = NULL
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
            if err == -2:  # ENOENT
                future.set_exception(FileNotFoundError(f"File not found"))
            elif err == -17:  # EEXIST
                future.set_exception(FileExistsError(f"File already exists"))
            else:
                future.set_exception(OSError(f"File operation failed: {err}"))
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
            future.set_exception(OSError(f"File operation failed: {err}"))
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
            future.set_exception(OSError(f"File operation failed: {err}"))
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
            future.set_exception(OSError(f"Truncate failed: {err}"))
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
            future.set_exception(OSError(f"Write failed: {err}"))
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
        bytes py_bytes
        char* dest
        char* default_msg = b"error"

        Py_ssize_t chunk_size, chunk_len, i
        Py_ssize_t offset = 0
        Py_ssize_t  total_size = err
        Py_ssize_t actual_size

    try:
        if err < 0:
            future.set_exception(OSError(f"File operation failed: {err}"))
        else:
            # Limitar a lo que se pidió originalmente
            actual_size = total_size
            if ctx.requested_size > 0 and actual_size > ctx.requested_size:
                actual_size = ctx.requested_size

            if ctx.nbufs == 1:

                result_obj = PyBytes_FromStringAndSize(ctx.bufs[0].base, actual_size)
                if actual_size <= 0 or ctx.bufs == NULL:
                    result_obj = PyBytes_FromStringAndSize(default_msg, 0)
            else:
                py_bytes = PyBytes_FromStringAndSize(NULL, actual_size)
                if py_bytes != None:
                    dest = PyBytes_AS_STRING(py_bytes)
                    for i in range(ctx.nbufs):
                        if offset >= actual_size:
                            break
                        if ctx.bufs[i].base == NULL:
                            continue

                        chunk_len = ctx.bufs[i].len

                        if chunk_len > actual_size - offset:
                            chunk_len = actual_size - offset

                        if chunk_len > 0:
                            memcpy(dest + offset, ctx.bufs[i].base, chunk_len)
                            offset += chunk_len

                    result_obj = <object>py_bytes
                else:
                    result_obj = PyBytes_FromStringAndSize("error", 0)

            future.set_result(result_obj)

    finally:

        uv.uv_fs_req_cleanup(req)
        free(req)
        __free(ctx)
        Py_DECREF(future)
