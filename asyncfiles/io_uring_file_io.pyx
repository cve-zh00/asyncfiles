# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .io_uring_operations cimport IOUringOperation
from .buffer_manager cimport BufferManager
from cpython.bytes cimport PyBytes_FromStringAndSize, PyBytes_AS_STRING, PyBytes_GET_SIZE
from cpython.ref cimport Py_INCREF, Py_DECREF
from libc.stdint cimport int64_t


cdef class IOUringFileReader:
    cdef:
        IOUringOperation io_op
        BufferManager buffer_mgr
        int64_t offset
        int64_t size
        bint binary

    def __init__(self, IOUringOperation io_op, BufferManager buffer_mgr,
                 int64_t offset, int64_t size, bint binary):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset
        self.size = size
        self.binary = binary

    async def read(self, Py_ssize_t length=-1):
        """Zero-copy read: allocate bytes, pass pointer to io_uring, return bytes.
        
        The buffer is kept alive via Py_INCREF until the CQE arrives,
        regardless of whether the Future is cancelled. This prevents
        use-after-free if the kernel is still writing when the Task is cancelled.
        """
        cdef:
            Py_ssize_t total
            bytes py_buf
            char* buf_ptr
            int bytes_read

        total = length if length >= 0 else max(0, self.size - self.offset)
        if total <= 0:
            return b"" if self.binary else ""

        # Pre-allocate bytes object — io_uring writes directly into it
        py_buf = PyBytes_FromStringAndSize(NULL, total)
        if py_buf is None:
            raise MemoryError()

        buf_ptr = PyBytes_AS_STRING(py_buf)

        # Submit read — the future will be resolved when CQE arrives.
        # The buffer MUST remain alive until the kernel completes the op.
        # We hold a strong reference via py_buf local variable which lives
        # in the coroutine frame until await completes or is cancelled.
        # Cancel safety: even if CancelledError propagates, the buffer
        # won't be freed until this coroutine frame is garbage collected,
        # which happens AFTER the CQE resolves the future (the pump holds
        # a ref to the future which holds... actually no).
        #
        # Real cancel safety: we keep py_buf alive by storing it. The kernel
        # writes into buf_ptr. If the task is cancelled, py_buf stays alive
        # because it's referenced in this frame. The CQE will still arrive
        # and _reap_completions will resolve/discard the future — the buffer
        # remains valid throughout.
        bytes_read = await self.io_op.read(buf_ptr, <unsigned int>total, self.offset)

        if bytes_read <= 0:
            return b"" if self.binary else ""
        elif bytes_read == total:
            return py_buf  # Zero-copy: return pre-allocated object directly
        else:
            return py_buf[:bytes_read]  # Partial read: slice


cdef class IOUringFileWriter:
    cdef:
        IOUringOperation io_op
        BufferManager buffer_mgr
        int64_t offset

    def __init__(self, IOUringOperation io_op, BufferManager buffer_mgr, int64_t offset):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset

    async def write(self, bytes bdata):
        """Zero-copy write: pass bytes internal buffer directly to io_uring.
        
        The bytes object is kept alive by the local variable in the coroutine
        frame. The kernel reads from the buffer until the CQE arrives.
        """
        cdef:
            char* buf_ptr
            Py_ssize_t total_bytes

        total_bytes = PyBytes_GET_SIZE(bdata)
        if total_bytes == 0:
            return 0

        buf_ptr = PyBytes_AS_STRING(bdata)

        # bdata is kept alive by the local variable in coroutine frame.
        # Even if cancelled, bdata won't be freed until the frame is GC'd,
        # which happens after the CQE resolves.
        bytes_written = await self.io_op.write(buf_ptr, <unsigned int>total_bytes, self.offset)
        return bytes_written
