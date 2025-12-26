# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .callbacks cimport cb_open, cb_close, cb_stat, cb_ftruncate
from .context cimport FSOpenContext
from .cpython cimport PyObject
from .utils cimport new_future
from .memory_utils cimport _cleanup_context
from libc.stdlib cimport malloc
from cpython.ref cimport Py_INCREF


cdef inline FSOpenContext* _create_fs_open_context(
    const char* path_cstr,
    int flags,
    int fd,
    object future
) except NULL:
    cdef FSOpenContext* ctx = <FSOpenContext*>malloc(sizeof(FSOpenContext))
    if ctx == NULL:
        raise MemoryError("Cannot allocate FSOpenContext")

    ctx.name_file = path_cstr
    ctx.flags = flags
    ctx.future = <PyObject*>future
    ctx.fd = fd

    Py_INCREF(future)
    return ctx


cdef inline uv.uv_fs_t* _create_fs_request(void* context_data) except NULL:
    cdef uv.uv_fs_t* req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
    if req == NULL:
        raise MemoryError("Cannot allocate uv_fs_t")

    req.data = context_data
    return req


cdef class IOOperation:
    def __cinit__(self):
        self.loop = None
        self.uv_loop = NULL
        self.fd = -1
        self.path_cstr = NULL

    @staticmethod
    cdef IOOperation create(object loop, uv.uv_loop_t* uv_loop, int fd, const char* path_cstr):
        cdef IOOperation io_op = IOOperation.__new__(IOOperation)
        io_op.loop = loop
        io_op.uv_loop = uv_loop
        io_op.fd = fd
        io_op.path_cstr = path_cstr
        return io_op

    cdef object open_file(self, int flags):
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            ctx = _create_fs_open_context(self.path_cstr, flags, self.fd, future)
            req = _create_fs_request(<void*>ctx)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for open"))
            return future

        err = uv.uv_fs_open(self.uv_loop, req, self.path_cstr, flags, 0o644, cb_open)

        if err < 0:
            _cleanup_context(<void*>ctx, req, future)
            future.set_exception(OSError(f"uv_fs_open failed: {err}"))
            return future

        return future

    cdef object close_file(self):
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            ctx = _create_fs_open_context(self.path_cstr, 0, self.fd, future)
            req = _create_fs_request(<void*>ctx)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for close"))
            return future

        err = uv.uv_fs_close(self.uv_loop, req, self.fd, cb_close)

        if err < 0:
            _cleanup_context(<void*>ctx, req, future)
            future.set_exception(OSError(f"uv_fs_close failed: {err}"))
            return future

        return future

    cdef object get_stat(self):
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            ctx = _create_fs_open_context(self.path_cstr, 0, self.fd, future)
            req = _create_fs_request(<void*>ctx)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for stat"))
            return future

        err = uv.uv_fs_stat(self.uv_loop, req, self.path_cstr, cb_stat)

        if err < 0:
            _cleanup_context(<void*>ctx, req, future)
            future.set_exception(OSError(f"uv_fs_stat failed: {err}"))
            return future

        return future

    cdef object truncate_file(self, int64_t length):
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            ctx = _create_fs_open_context(self.path_cstr, 0, self.fd, future)
            req = _create_fs_request(<void*>ctx)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for truncate"))
            return future

        err = uv.uv_fs_ftruncate(self.uv_loop, req, self.fd, length, cb_ftruncate)

        if err < 0:
            _cleanup_context(<void*>ctx, req, future)
            future.set_exception(OSError(f"uv_fs_ftruncate failed: {err}"))
            return future

        return future
