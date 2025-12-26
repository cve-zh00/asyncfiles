# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .callbacks cimport cb_read, cb_write
from .context cimport FSReadContext, FSWriteContext
from .cpython cimport PyObject
from .utils cimport new_future
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .memory_utils cimport _cleanup_read_context, _cleanup_write_context
from libc.stdlib cimport malloc, free
from libc.stdint cimport int64_t
from cpython.bytes cimport PyBytes_GET_SIZE, PyBytes_AsString
from cpython.ref cimport Py_INCREF


cdef class FileReader:
    def __init__(self, IOOperation io_op, BufferManager buffer_mgr, int64_t offset, int size, bint binary):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset
        self.size = size
        self.binary = binary

    cdef object read(self, int length=-1):
        cdef:
            object future = new_future(self.io_op.loop)
            int err
            Py_ssize_t total
            FSReadContext* ctx
            uv.uv_fs_t* req
            Py_ssize_t nbufs

        total = length if length >= 0 else max(0, self.size - self.offset)

        if total <= 0:
            future.set_result(b"" if self.binary else "")
            return future

        ctx = <FSReadContext*>malloc(sizeof(FSReadContext))
        if ctx == NULL:
            future.set_exception(MemoryError())
            return future

        ctx.bufs = self.buffer_mgr.create_read_buffers(total, &nbufs)
        if ctx.bufs == NULL:
            free(ctx)
            future.set_exception(MemoryError())
            return future

        ctx.nbufs = nbufs
        ctx.future = <PyObject*>future
        ctx.binary = self.binary
        ctx.requested_size = total

        Py_INCREF(future)

        req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
        if req == NULL:
            _cleanup_read_context(ctx, NULL, future)
            future.set_exception(MemoryError())
            return future

        req.data = <void*>ctx

        err = uv.uv_fs_read(
            self.io_op.uv_loop,
            req,
            self.io_op.fd,
            ctx.bufs,
            <unsigned int>ctx.nbufs,
            self.offset,
            cb_read
        )

        if err < 0:
            _cleanup_read_context(ctx, req, future)
            future.set_exception(OSError(err))
            return future

        return future


cdef class FileWriter:
    def __init__(self, IOOperation io_op, BufferManager buffer_mgr, int64_t offset):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset

    cdef object write(self, bytes bdata):
        cdef:
            object future = new_future(self.io_op.loop)
            char* base_ptr
            Py_ssize_t total_bytes
            FSWriteContext* ctx
            int nbufs, err
            uv.uv_fs_t* req

        total_bytes = PyBytes_GET_SIZE(bdata)
        if total_bytes == 0:
            future.set_result(0)
            return future

        base_ptr = PyBytes_AsString(bdata)

        ctx = <FSWriteContext*>malloc(sizeof(FSWriteContext))
        if ctx == NULL:
            future.set_exception(MemoryError())
            return future

        ctx.bufs = self.buffer_mgr.create_write_buffers(base_ptr, total_bytes, &nbufs)
        if ctx.bufs == NULL:
            free(ctx)
            future.set_exception(MemoryError())
            return future

        ctx.nbufs = nbufs
        ctx.future = <PyObject*>future
        ctx._refs = <PyObject*>bdata

        Py_INCREF(bdata)
        Py_INCREF(future)

        req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
        if req == NULL:
            _cleanup_write_context(ctx, NULL, future, bdata)
            future.set_exception(MemoryError())
            return future

        req.data = <void*>ctx

        err = uv.uv_fs_write(self.io_op.uv_loop, req, self.io_op.fd, ctx.bufs, ctx.nbufs, self.offset, cb_write)

        if err < 0:
            _cleanup_write_context(ctx, req, future, bdata)
            future.set_exception(OSError(err))
            return future

        return future
