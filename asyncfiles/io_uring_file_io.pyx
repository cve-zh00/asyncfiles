# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .io_uring_operations cimport IOUringOperation
from .buffer_manager cimport BufferManager
from cpython.bytes cimport PyBytes_FromStringAndSize, PyBytes_AS_STRING, PyBytes_GET_SIZE
from cpython.ref cimport Py_INCREF, Py_DECREF
from libc.stdint cimport int64_t


import asyncio

# Large transfers are split so several io-wq workers/SQEs run in parallel
DEF CHUNK_SIZE = 2 * 1024 * 1024
DEF PARALLEL_THRESHOLD = 4 * 1024 * 1024


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

    async def _read_chunk(self, bytes py_buf, Py_ssize_t start, Py_ssize_t n,
                          int64_t file_off):
        """Read n bytes into py_buf[start:], retrying short reads until EOF."""
        cdef:
            char* base = PyBytes_AS_STRING(py_buf)
            Py_ssize_t done = 0
            int got

        while done < n:
            # py_buf is pinned by the pump until the CQE, even on cancellation
            got = await self.io_op.read(
                base + start + done, <unsigned int>(n - done),
                file_off + done, py_buf
            )
            if got <= 0:
                break
            done += got
        return done

    async def read(self, Py_ssize_t length=-1):
        """Zero-copy read into a preallocated bytes object."""
        cdef:
            Py_ssize_t total
            Py_ssize_t got
            Py_ssize_t pos
            Py_ssize_t n
            bytes py_buf
            list tasks

        total = length if length >= 0 else max(0, self.size - self.offset)
        if total <= 0:
            return b""

        py_buf = PyBytes_FromStringAndSize(NULL, total)
        if py_buf is None:
            raise MemoryError()

        if total < PARALLEL_THRESHOLD:
            got = await self._read_chunk(py_buf, 0, total, self.offset)
        else:
            tasks = []
            pos = 0
            while pos < total:
                n = min(CHUNK_SIZE, total - pos)
                tasks.append(self._read_chunk(py_buf, pos, n, self.offset + pos))
                pos += n
            counts = await asyncio.gather(*tasks)
            got = 0
            for c in counts:
                got += c
                if c < CHUNK_SIZE:
                    break  # EOF reached inside this chunk

        if got <= 0:
            return b""
        if got == total:
            return py_buf
        return py_buf[:got]

cdef class IOUringFileWriter:
    cdef:
        IOUringOperation io_op
        BufferManager buffer_mgr
        int64_t offset

    def __init__(self, IOUringOperation io_op, BufferManager buffer_mgr, int64_t offset):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset

    async def _write_chunk(self, bytes bdata, Py_ssize_t start, Py_ssize_t n,
                           int64_t file_off):
        """Write n bytes from bdata[start:], retrying short writes."""
        cdef:
            const char* base = PyBytes_AS_STRING(bdata)
            Py_ssize_t done = 0
            int put

        while done < n:
            put = await self.io_op.write(
                base + start + done, <unsigned int>(n - done),
                file_off + done, bdata
            )
            if put <= 0:
                raise OSError(5, "io_uring write made no progress")
            done += put
        return done

    async def write(self, bytes bdata):
        """Zero-copy write straight from the bytes buffer (pinned by the pump)."""
        cdef:
            Py_ssize_t total_bytes = PyBytes_GET_SIZE(bdata)
            Py_ssize_t pos
            Py_ssize_t n
            list tasks

        if total_bytes == 0:
            return 0

        # offset < 0 means O_APPEND: must stay a single, ordered write
        if self.offset < 0 or total_bytes < PARALLEL_THRESHOLD:
            return await self._write_chunk(bdata, 0, total_bytes, self.offset)

        tasks = []
        pos = 0
        while pos < total_bytes:
            n = min(CHUNK_SIZE, total_bytes - pos)
            tasks.append(self._write_chunk(bdata, pos, n, self.offset + pos))
            pos += n
        await asyncio.gather(*tasks)
        return total_bytes
