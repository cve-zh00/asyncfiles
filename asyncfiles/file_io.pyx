# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .callbacks cimport cb_read, cb_readinto, cb_write, _ReadResult, _uv_oserror
from .context cimport FSReadContext, FSWriteContext
from .cpython cimport PyObject
from .event_loop cimport EventLoopPump
from .utils cimport new_future, _PinnedBuffer, _NativeReadBuffer, ASYNCFILES_PYPY
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .memory_utils cimport _cleanup_read_context, _cleanup_write_context
from libc.stdlib cimport malloc, free
from libc.stdint cimport int64_t
from cpython.bytes cimport (
    PyBytes_CheckExact,
    PyBytes_GET_SIZE,
    PyBytes_AsString,
    PyBytes_FromStringAndSize,
    PyBytes_AS_STRING,
)
from cpython.unicode cimport PyUnicode_Check, PyUnicode_AsUTF8AndSize
from cpython.ref cimport Py_INCREF, Py_DECREF
cimport cython

DEF _MAX_SINGLE_UV_BUF = 0x7ffff000


@cython.cdivision(True)
cdef inline object _submit_uv_read_buf(
    IOOperation io_op,
    int64_t offset,
    bint binary,
    char* chunk_ptr,
    Py_ssize_t total,
    object keep_obj,
    uv.uv_fs_cb cb,
):
    cdef:
        object future = new_future(io_op.loop)
        int err
        FSReadContext* ctx
        uv.uv_fs_t* req
        uv.uv_buf_t stack_buf
        uv.uv_buf_t* p_uvbufs
        Py_ssize_t nbufs, i, chunk_len
        Py_ssize_t chunk_size = _MAX_SINGLE_UV_BUF

    ctx = <FSReadContext*>malloc(sizeof(FSReadContext))
    if ctx == NULL:
        future.set_exception(MemoryError())
        return future

    ctx.future = <PyObject*>future
    ctx.binary = binary
    ctx.requested_size = total
    ctx.buffer_mem = NULL

    if total <= _MAX_SINGLE_UV_BUF:
        nbufs = 1
        ctx.nbufs = 1
        ctx.bufs = NULL
        stack_buf = uv.uv_buf_init(chunk_ptr, <unsigned int>total)
        p_uvbufs = &stack_buf
    else:
        nbufs = (total + chunk_size - 1) // chunk_size
        ctx.nbufs = nbufs
        ctx.bufs = <uv.uv_buf_t*>malloc(nbufs * sizeof(uv.uv_buf_t))
        if ctx.bufs == NULL:
            free(ctx)
            future.set_exception(MemoryError())
            return future
        p_uvbufs = ctx.bufs
        for i in range(nbufs):
            chunk_len = chunk_size if i < nbufs - 1 else total - chunk_size * (nbufs - 1)
            p_uvbufs[i] = uv.uv_buf_init(
                chunk_ptr + (i * chunk_size), <unsigned int>chunk_len
            )

    Py_INCREF(keep_obj)
    ctx.py_buf = <PyObject*>keep_obj
    Py_INCREF(future)

    req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
    if req == NULL:
        if ctx.bufs != NULL:
            free(ctx.bufs)
        Py_DECREF(keep_obj)
        free(ctx)
        Py_DECREF(future)
        future.set_exception(MemoryError())
        return future

    req.data = <void*>ctx

    err = uv.uv_fs_read(
        io_op.uv_loop,
        req,
        io_op.fd,
        p_uvbufs,
        <unsigned int>nbufs,
        offset,
        cb,
    )

    if err < 0:
        if ctx.bufs != NULL:
            free(ctx.bufs)
        Py_DECREF(keep_obj)
        free(ctx)
        free(req)
        Py_DECREF(future)
        future.set_exception(_uv_oserror(err, "read failed"))
        return future

    return future


cdef object submit_uv_read(
    IOOperation io_op,
    int64_t offset,
    int64_t size,
    bint binary,
    Py_ssize_t length,
    EventLoopPump pump,
):
    cdef:
        object future
        Py_ssize_t total = length if length >= 0 else max(0, size - offset)
        bytes py_buf
        _NativeReadBuffer native_buf

    if total <= 0:
        future = new_future(io_op.loop)
        future.set_result(b"")
        return future

    if ASYNCFILES_PYPY:
        native_buf = _NativeReadBuffer(total)
        future = _submit_uv_read_buf(
            io_op, offset, binary, native_buf.data, total, native_buf, cb_read
        )
    else:
        py_buf = PyBytes_FromStringAndSize(NULL, total)
        if py_buf is None:
            future = new_future(io_op.loop)
            future.set_exception(MemoryError())
            return future
        future = _submit_uv_read_buf(
            io_op, offset, binary, PyBytes_AS_STRING(py_buf), total, py_buf, cb_read
        )
    if pump is not None:
        pump.prime()
    return future


cdef object submit_uv_readinto(
    IOOperation io_op,
    int64_t offset,
    _PinnedBuffer pinned,
    Py_ssize_t total,
    EventLoopPump pump,
):
    cdef object future
    if total <= 0:
        future = new_future(io_op.loop)
        future.set_result(0)
        return future

    future = _submit_uv_read_buf(
        io_op, offset, True, <char*>pinned.view.buf, total, pinned, cb_readinto
    )
    if pump is not None:
        pump.prime()
    return future


@cython.cdivision(True)
cdef object submit_uv_write(
    IOOperation io_op,
    int64_t offset,
    object bdata,
    EventLoopPump pump,
):
    cdef:
        object future = new_future(io_op.loop)
        char* base_ptr
        Py_ssize_t total_bytes
        FSWriteContext* ctx
        uv.uv_buf_t stack_buf
        uv.uv_buf_t* p_uvbufs
        Py_ssize_t nbufs, i, chunk_len
        Py_ssize_t chunk_size = _MAX_SINGLE_UV_BUF
        int err
        uv.uv_fs_t* req

    try:
        if PyBytes_CheckExact(bdata):
            total_bytes = PyBytes_GET_SIZE(bdata)
            base_ptr = PyBytes_AS_STRING(bdata)
        elif PyUnicode_Check(bdata):
            base_ptr = <char*>PyUnicode_AsUTF8AndSize(bdata, &total_bytes)
        elif isinstance(bdata, _PinnedBuffer):
            total_bytes = (<_PinnedBuffer>bdata).view.len
            base_ptr = <char*>(<_PinnedBuffer>bdata).view.buf
        else:
            total_bytes = PyBytes_GET_SIZE(bdata)
            base_ptr = PyBytes_AsString(bdata)
    except Exception as exc:
        future.set_exception(exc)
        return future

    if total_bytes == 0:
        future.set_result(0)
        return future

    ctx = <FSWriteContext*>malloc(sizeof(FSWriteContext))
    if ctx == NULL:
        future.set_exception(MemoryError())
        return future

    if total_bytes <= _MAX_SINGLE_UV_BUF:
        nbufs = 1
        ctx.nbufs = 1
        ctx.bufs = NULL
        stack_buf = uv.uv_buf_init(base_ptr, <unsigned int>total_bytes)
        p_uvbufs = &stack_buf
    else:
        nbufs = (total_bytes + chunk_size - 1) // chunk_size
        ctx.nbufs = nbufs
        ctx.bufs = <uv.uv_buf_t*>malloc(nbufs * sizeof(uv.uv_buf_t))
        if ctx.bufs == NULL:
            free(ctx)
            future.set_exception(MemoryError())
            return future
        p_uvbufs = ctx.bufs
        for i in range(nbufs):
            chunk_len = chunk_size if i < nbufs - 1 else total_bytes - chunk_size * (nbufs - 1)
            p_uvbufs[i] = uv.uv_buf_init(
                base_ptr + (i * chunk_size), <unsigned int>chunk_len
            )

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

    err = uv.uv_fs_write(
        io_op.uv_loop, req, io_op.fd, p_uvbufs, <unsigned int>nbufs, offset, cb_write
    )

    if err < 0:
        _cleanup_write_context(ctx, req, future, bdata)
        future.set_exception(_uv_oserror(err, "write failed"))
        return future

    if pump is not None:
        pump.prime()
    return future


cdef class FileReader:
    def __init__(self, IOOperation io_op, BufferManager buffer_mgr, int64_t offset, int64_t size, bint binary):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset
        self.size = size
        self.binary = binary

    @staticmethod
    cdef FileReader create(
        IOOperation io_op,
        BufferManager buffer_mgr,
        int64_t offset,
        int64_t size,
        bint binary,
    ):
        cdef FileReader self = FileReader.__new__(FileReader)
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset
        self.size = size
        self.binary = binary
        return self

    def read(self, Py_ssize_t length=-1, EventLoopPump pump=None):
        return submit_uv_read(self.io_op, self.offset, self.size, self.binary, length, pump)

    def readinto(self, _PinnedBuffer pinned, Py_ssize_t length, EventLoopPump pump=None):
        return submit_uv_readinto(self.io_op, self.offset, pinned, length, pump)

    cdef object _submit_read(
        self, char* chunk_ptr, Py_ssize_t total, object keep_obj, uv.uv_fs_cb cb
    ):
        return _submit_uv_read_buf(
            self.io_op, self.offset, self.binary, chunk_ptr, total, keep_obj, cb
        )

    cdef object _readinto_internal(self, _PinnedBuffer pinned, Py_ssize_t total):
        return submit_uv_readinto(self.io_op, self.offset, pinned, total, None)

    cdef object _read_internal(self, Py_ssize_t length=-1):
        return submit_uv_read(self.io_op, self.offset, self.size, self.binary, length, None)


cdef class FileWriter:
    def __init__(self, IOOperation io_op, BufferManager buffer_mgr, int64_t offset):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset

    @staticmethod
    cdef FileWriter create(
        IOOperation io_op,
        BufferManager buffer_mgr,
        int64_t offset,
    ):
        cdef FileWriter self = FileWriter.__new__(FileWriter)
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset
        return self

    cdef object write(self, object bdata):
        return submit_uv_write(self.io_op, self.offset, bdata, None)
