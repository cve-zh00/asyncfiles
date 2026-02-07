# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .callbacks cimport cb_read, cb_write, _ReadResult
from .context cimport FSReadContext, FSWriteContext
from .cpython cimport PyObject
from .utils cimport new_future
from .io_operations cimport IOOperation
from .buffer_manager cimport BufferManager
from .memory_utils cimport _cleanup_read_context, _cleanup_write_context
from libc.stdlib cimport malloc, free
from libc.stdint cimport int64_t
from libc.string cimport memcpy
from cpython.bytes cimport PyBytes_GET_SIZE, PyBytes_AsString, PyBytes_FromStringAndSize, PyBytes_AS_STRING
from cpython.ref cimport Py_INCREF, Py_DECREF
cimport cython

cdef enum:
    __PREALLOCED_BUFS = 16


cdef inline bytes _process_read_result(_ReadResult wrapper) noexcept:
    """Process read result after callback - all logic here"""
    cdef:
        FSReadContext* ctx = wrapper.ctx
        Py_ssize_t actual_size = wrapper.bytes_read
        Py_ssize_t requested_size = ctx.requested_size
        bytes py_bytes
        char* dest
        Py_ssize_t chunk_len, i, offset
        bytes result_obj

    try:
        # Clamp to requested size
        if requested_size > 0 and actual_size > requested_size:
            actual_size = requested_size

        # Handle empty or null buffers
        if actual_size <= 0 or ctx.bufs == NULL:
            result_obj = b""
        # Single buffer optimization
        elif ctx.nbufs == 1:
            result_obj = PyBytes_FromStringAndSize(ctx.bufs[0].base, actual_size)
        # Multiple buffers - copy and merge
        else:
            py_bytes = PyBytes_FromStringAndSize(NULL, actual_size)
            dest = PyBytes_AS_STRING(py_bytes)
            offset = 0
            for i in range(ctx.nbufs):
                if offset >= actual_size:
                    break
                chunk_len = ctx.bufs[i].len
                if chunk_len > actual_size - offset:
                    chunk_len = actual_size - offset
                memcpy(dest + offset, ctx.bufs[i].base, chunk_len)
                offset += chunk_len
            result_obj = py_bytes

        return result_obj
    finally:
        # Cleanup context
        if ctx.buffer_mem != NULL:
            free(ctx.buffer_mem)
        if ctx.bufs != NULL:
            free(ctx.bufs)
        if ctx.future != NULL:
            Py_DECREF(<object>ctx.future)
        free(ctx)


cdef class FileReader:
    def __init__(self, IOOperation io_op, BufferManager buffer_mgr, int64_t offset, int64_t size, bint binary):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset
        self.size = size
        self.binary = binary

    @cython.cdivision(True)
    async def read(self, int length=-1):
        """Read with post-callback processing"""
        cdef:
            object future_result
            _ReadResult wrapper
            bytes result

        # Start async read
        future_result = await self._read_internal(length)

        # Check if it's already bytes (early return case)
        if isinstance(future_result, bytes):
            return future_result

        # Process the wrapper
        wrapper = <_ReadResult>future_result
        result = _process_read_result(wrapper)

        return result
    @cython.cdivision(True)
    cdef object _read_internal(self, int length=-1):
        cdef:
            object future = new_future(self.io_op.loop)
            int err
            Py_ssize_t total
            FSReadContext* ctx
            uv.uv_fs_t* req
            Py_ssize_t nbufs
            uv.uv_buf_t* p_uvbufs
            Py_ssize_t chunk_size = self.buffer_mgr.buffer_size
            Py_ssize_t i, chunk_len
            char* chunk_ptr
            Py_ssize_t max_bufs = 64
            Py_ssize_t large_threshold = 10485760

        total = length if length >= 0 else max(0, self.size - self.offset)

        if total <= 0:
            future.set_result(b"" if self.binary else "")
            return future

        # Calculate number of buffers needed
        if total <= self.buffer_mgr.buffer_size:
            chunk_size = total
            nbufs = 1
        elif total > large_threshold:
            chunk_size = 256 * 1024  # 2MB
            nbufs = (total + chunk_size - 1) // chunk_size
            if nbufs > max_bufs:
                chunk_size = (total + max_bufs - 1) // max_bufs
                nbufs = max_bufs
        else:
            nbufs = (total + self.buffer_mgr.buffer_size - 1) // self.buffer_mgr.buffer_size
            if nbufs > max_bufs:
                chunk_size = (total + max_bufs - 1) // max_bufs
                nbufs = max_bufs

        # Allocate read context
        ctx = <FSReadContext*>malloc(sizeof(FSReadContext))
        if ctx == NULL:
            future.set_exception(MemoryError())
            return future

        ctx.future = <PyObject*>future
        ctx.binary = self.binary
        ctx.requested_size = total
        ctx.nbufs = nbufs
        ctx.bufs = NULL
        ctx.buffer_mem = NULL

        # Allocate buffer array
        ctx.bufs = <uv.uv_buf_t*>malloc(nbufs * sizeof(uv.uv_buf_t))
        if ctx.bufs == NULL:
            free(ctx)
            future.set_exception(MemoryError())
            return future

        # Allocate single memory block for all buffers
        ctx.buffer_mem = <char*>malloc(total)
        if ctx.buffer_mem == NULL:
            free(ctx.bufs)
            free(ctx)
            future.set_exception(MemoryError())
            return future

        p_uvbufs = ctx.bufs

        # Divide the memory block into chunks
        for i in range(nbufs):
            chunk_len = chunk_size if i < nbufs - 1 else total - chunk_size * (nbufs - 1)
            chunk_ptr = ctx.buffer_mem + (i * chunk_size)
            p_uvbufs[i] = uv.uv_buf_init(chunk_ptr, <unsigned int>chunk_len)

        Py_INCREF(future)

        req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
        if req == NULL:
            # Cleanup buffers
            if ctx.buffer_mem is not NULL:
                free(ctx.buffer_mem)
            if ctx.bufs is not NULL:
                free(ctx.bufs)
            free(ctx)
            Py_DECREF(future)
            future.set_exception(MemoryError())
            return future

        req.data = <void*>ctx

        err = uv.uv_fs_read(
            self.io_op.uv_loop,
            req,
            self.io_op.fd,
            p_uvbufs,
            <unsigned int>nbufs,
            self.offset,
            cb_read
        )

        if err < 0:
            # Cleanup buffers
            if ctx.buffer_mem is not NULL:
                free(ctx.buffer_mem)
            if ctx.bufs is not NULL:
                free(ctx.bufs)
            free(ctx)
            free(req)
            Py_DECREF(future)
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
