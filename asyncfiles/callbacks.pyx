# cython: language_level=3
from . cimport uv
from libc.stdlib      cimport malloc, free
from libc.stdint      cimport int64_t

from cpython.ref      cimport Py_INCREF, Py_DECREF
from cpython.object   cimport PyObject

from .context cimport FSReadContext, FSWriteContext
from .utils cimport _NativeReadBuffer, ASYNCFILES_PYPY

import errno as _errno
import os as _os
import sys as _sys

cdef extern from "Python.h":
    object PyUnicode_DecodeFSDefault(const char* s)

cdef object _stat_result = _os.stat_result
# Older PyPy computes st_*_ns from integer tuple fields and nsec_* slots.
cdef bint _stat_result_needs_nsec = (
    _sys.implementation.name == "pypy"
    and isinstance(_stat_result.st_atime_ns, property)
    and hasattr(_stat_result, "nsec_atime")
)


cdef object _uv_oserror(int err, str msg):
    """Build an OSError from a negative libuv status.

    On POSIX libuv errors are -errno; on Windows they are distinct codes
    (e.g. UV_ENOENT == -4058), so translate through the symbolic name.
    """
    cdef bytes name = uv.uv_err_name(err)
    code = getattr(_errno, name.decode("ascii", "replace"), None)
    return OSError(code if code is not None else -err, msg)


cdef inline object _build_stat_result(const uv.uv_stat_t* st):
    cdef int64_t atime_sec = <int64_t>st.st_atim.tv_sec
    cdef int64_t atime_nsec = <int64_t>st.st_atim.tv_nsec
    cdef int64_t mtime_sec = <int64_t>st.st_mtim.tv_sec
    cdef int64_t mtime_nsec = <int64_t>st.st_mtim.tv_nsec
    cdef int64_t ctime_sec = <int64_t>st.st_ctim.tv_sec
    cdef int64_t ctime_nsec = <int64_t>st.st_ctim.tv_nsec
    cdef dict attrs = {
        "st_atime": atime_sec + atime_nsec * 1e-9,
        "st_mtime": mtime_sec + mtime_nsec * 1e-9,
        "st_ctime": ctime_sec + ctime_nsec * 1e-9,
        "st_atime_ns": atime_sec * 1000000000 + atime_nsec,
        "st_mtime_ns": mtime_sec * 1000000000 + mtime_nsec,
        "st_ctime_ns": ctime_sec * 1000000000 + ctime_nsec,
    }
    if _stat_result_needs_nsec:
        attrs["nsec_atime"] = atime_nsec
        attrs["nsec_mtime"] = mtime_nsec
        attrs["nsec_ctime"] = ctime_nsec
    return _stat_result(
        (
            st.st_mode,
            st.st_ino,
            st.st_dev,
            st.st_nlink,
            st.st_uid,
            st.st_gid,
            st.st_size,
            atime_sec,
            mtime_sec,
            ctime_sec,
        ),
        attrs,
    )


cdef void cb_open(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "open failed"))
            else:
                future.set_result(err)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "stat failed"))
            elif (req.statbuf.st_mode & 0o170000) == 0o040000:
                future.set_exception(_uv_oserror(-_errno.EISDIR, "Is a directory"))
            else:
                future.set_result(req.statbuf.st_size)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_close(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "close failed"))
            else:
                future.set_result(err)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_ftruncate(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "ftruncate failed"))
            else:
                future.set_result(0)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_ignore(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "filesystem operation failed"))
            else:
                future.set_result(None)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_full_stat(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "stat failed"))
            else:
                future.set_result(_build_stat_result(&req.statbuf))
    except Exception as error:
        if not future.done():
            future.set_exception(error)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat_exists(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    try:
        if not future.done():
            future.set_result(req.result >= 0)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat_isfile(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    try:
        if not future.done():
            future.set_result(
                req.result >= 0 and (req.statbuf.st_mode & 0o170000) == 0o100000
            )
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat_isdir(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    try:
        if not future.done():
            future.set_result(
                req.result >= 0 and (req.statbuf.st_mode & 0o170000) == 0o040000
            )
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat_islink(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    try:
        if not future.done():
            future.set_result(
                req.result >= 0 and (req.statbuf.st_mode & 0o170000) == 0o120000
            )
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat_mtime(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "stat failed"))
            else:
                future.set_result(
                    req.statbuf.st_mtim.tv_sec + req.statbuf.st_mtim.tv_nsec * 1e-9
                )
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat_atime(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "stat failed"))
            else:
                future.set_result(
                    req.statbuf.st_atim.tv_sec + req.statbuf.st_atim.tv_nsec * 1e-9
                )
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_stat_ctime(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "stat failed"))
            else:
                future.set_result(
                    req.statbuf.st_ctim.tv_sec + req.statbuf.st_ctim.tv_nsec * 1e-9
                )
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_access_bool(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    try:
        if not future.done():
            future.set_result(req.result >= 0)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_ptr_bytes(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    cdef bytes res_bytes
    try:
        if not future.done():
            if err < 0 or req.ptr == NULL:
                future.set_exception(_uv_oserror(err if err < 0 else -5, "path operation failed"))
            else:
                res_bytes = <bytes>(<const char*>req.ptr)
                future.set_result(res_bytes)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_scandir_names_str(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    cdef uv.uv_dirent_t ent
    cdef list names
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "scandir failed"))
            else:
                names = []
                while uv.uv_fs_scandir_next(req, &ent) != uv.UV_EOF:
                    names.append(PyUnicode_DecodeFSDefault(ent.name))
                future.set_result(names)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_scandir_names_bytes(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    cdef uv.uv_dirent_t ent
    cdef list names
    cdef bytes name_b
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "scandir failed"))
            else:
                names = []
                while uv.uv_fs_scandir_next(req, &ent) != uv.UV_EOF:
                    name_b = <bytes>ent.name
                    names.append(name_b)
                future.set_result(names)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_scandir_entries(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    cdef uv.uv_dirent_t ent
    cdef list entries
    cdef bytes name_b
    try:
        if not future.done():
            if err < 0:
                future.set_exception(_uv_oserror(err, "scandir failed"))
            else:
                entries = []
                while uv.uv_fs_scandir_next(req, &ent) != uv.UV_EOF:
                    name_b = <bytes>ent.name
                    entries.append((name_b, <int>ent.type))
                future.set_result(entries)
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_statfs(uv.uv_fs_t* req) noexcept with gil:
    cdef object future = <object>req.data
    cdef int err = <int>req.result
    cdef uv.uv_statfs_t* st
    try:
        if not future.done():
            if err < 0 or req.ptr == NULL:
                future.set_exception(_uv_oserror(err if err < 0 else -5, "statfs failed"))
            else:
                st = <uv.uv_statfs_t*>req.ptr
                future.set_result(
                    {
                        "f_type": st.f_type,
                        "f_bsize": st.f_bsize,
                        "f_blocks": st.f_blocks,
                        "f_bfree": st.f_bfree,
                        "f_bavail": st.f_bavail,
                        "f_files": st.f_files,
                        "f_ffree": st.f_ffree,
                    }
                )
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)


cdef void cb_write(uv.uv_fs_t* req) noexcept with gil:
    cdef FSWriteContext* ctx = <FSWriteContext*> req.data
    cdef object future = <object> ctx.future
    cdef Py_ssize_t err = req.result
    try:
        if err < 0:
            if not future.done():
                future.set_exception(_uv_oserror(<int>err, "write failed"))
        else:
            if not future.done():
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
            if ctx.py_buf != NULL:
                Py_DECREF(<object>ctx.py_buf)
            if ctx.bufs != NULL:
                free(ctx.bufs)
            if ctx.future != NULL:
                Py_DECREF(<object>ctx.future)
            free(ctx)
            self.ctx = NULL


cdef void cb_read(uv.uv_fs_t* req) noexcept with gil:
    """Resolve read future directly with zero-copy bytes and free context."""
    cdef:
        FSReadContext* ctx = <FSReadContext*>req.data
        Py_ssize_t result = req.result
        Py_ssize_t requested_size = ctx.requested_size
        object future = <object>ctx.future
        bytes py_buf
        bytes res_obj

    try:
        if not future.done():
            if result < 0:
                future.set_exception(_uv_oserror(<int>result, "read failed"))
            else:
                if requested_size > 0 and result > requested_size:
                    result = requested_size
                if result <= 0 or ctx.py_buf == NULL:
                    res_obj = b""
                elif ASYNCFILES_PYPY:
                    res_obj = (<_NativeReadBuffer><object>ctx.py_buf).finish(result)
                else:
                    py_buf = <bytes>ctx.py_buf
                    if result == requested_size:
                        res_obj = py_buf
                    else:
                        res_obj = py_buf[:result]
                future.set_result(res_obj)
    except Exception as error:
        if not future.done():
            future.set_exception(error)
    finally:
        if ctx.buffer_mem != NULL:
            free(ctx.buffer_mem)
        if ctx.py_buf != NULL:
            Py_DECREF(<object>ctx.py_buf)
        if ctx.bufs != NULL:
            free(ctx.bufs)
        uv.uv_fs_req_cleanup(req)
        free(req)
        free(ctx)
        Py_DECREF(future)


cdef void cb_readinto(uv.uv_fs_t* req) noexcept with gil:
    """Resolve readinto future directly with byte count and free context."""
    cdef:
        FSReadContext* ctx = <FSReadContext*>req.data
        Py_ssize_t result = req.result
        Py_ssize_t requested_size = ctx.requested_size
        object future = <object>ctx.future

    try:
        if not future.done():
            if result < 0:
                future.set_exception(_uv_oserror(<int>result, "read failed"))
            else:
                if requested_size > 0 and result > requested_size:
                    result = requested_size
                future.set_result(result if result > 0 else 0)
    finally:
        if ctx.buffer_mem != NULL:
            free(ctx.buffer_mem)
        if ctx.py_buf != NULL:
            Py_DECREF(<object>ctx.py_buf)
        if ctx.bufs != NULL:
            free(ctx.bufs)
        uv.uv_fs_req_cleanup(req)
        free(req)
        free(ctx)
        Py_DECREF(future)
