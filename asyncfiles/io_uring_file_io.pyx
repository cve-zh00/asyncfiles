# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .io_uring_operations cimport IOUringOperation
from .buffer_manager cimport BufferManager
from .utils cimport _PinnedBuffer, _NativeReadBuffer, ASYNCFILES_PYPY
from cpython.bytes cimport (
    PyBytes_CheckExact,
    PyBytes_FromStringAndSize,
    PyBytes_AS_STRING,
    PyBytes_GET_SIZE,
)
from cpython.ref cimport Py_INCREF, Py_DECREF
from cpython.unicode cimport PyUnicode_Check, PyUnicode_AsUTF8AndSize
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

    async def _read_chunk(self, object keep_obj, Py_ssize_t base_addr,
                          Py_ssize_t start, Py_ssize_t n, int64_t file_off):
        """Read n bytes into base_addr[start:], retrying short reads until EOF."""
        cdef:
            char* base = <char*><size_t>base_addr
            Py_ssize_t done = 0
            int got

        while done < n:
            # keep_obj is pinned by the pump until the CQE, even on cancellation
            got = await self.io_op.read(
                base + start + done, <unsigned int>(n - done),
                file_off + done, keep_obj
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
            Py_ssize_t base_addr
            char* base
            int res
            bytes py_buf
            _NativeReadBuffer native_buf
            object keep_obj
            list tasks

        total = length if length >= 0 else max(0, self.size - self.offset)
        if total <= 0:
            return b""

        if ASYNCFILES_PYPY:
            native_buf = _NativeReadBuffer(total)
            base = native_buf.data
            keep_obj = native_buf
        else:
            py_buf = PyBytes_FromStringAndSize(NULL, total)
            if py_buf is None:
                raise MemoryError()
            base = PyBytes_AS_STRING(py_buf)
            keep_obj = py_buf
        if total < PARALLEL_THRESHOLD:
            got = 0
            while got < total:
                res = await self.io_op.read(
                    base + got, <unsigned int>(total - got),
                    self.offset + got, keep_obj
                )
                if res <= 0:
                    break
                got += res
        else:
            base_addr = <Py_ssize_t><size_t>base
            tasks = []
            pos = 0
            while pos < total:
                n = min(CHUNK_SIZE, total - pos)
                tasks.append(self._read_chunk(keep_obj, base_addr, pos, n, self.offset + pos))
                pos += n
            counts = await asyncio.gather(*tasks)
            got = 0
            for c in counts:
                got += c
                if c < CHUNK_SIZE:
                    break  # EOF reached inside this chunk

        if got <= 0:
            return b""
        if ASYNCFILES_PYPY:
            return native_buf.finish(got)
        if got == total:
            return py_buf
        return py_buf[:got]

    async def readinto(self, _PinnedBuffer pinned, Py_ssize_t total):
        """Zero-copy read directly into a pinned writable buffer."""
        cdef:
            Py_ssize_t got
            Py_ssize_t pos
            Py_ssize_t n
            Py_ssize_t base_addr
            char* base
            int res
            list tasks

        if total <= 0:
            return 0

        base = <char*>pinned.view.buf
        if total < PARALLEL_THRESHOLD:
            got = 0
            while got < total:
                res = await self.io_op.read(
                    base + got, <unsigned int>(total - got),
                    self.offset + got, pinned
                )
                if res <= 0:
                    break
                got += res
        else:
            base_addr = <Py_ssize_t><size_t>base
            tasks = []
            pos = 0
            while pos < total:
                n = min(CHUNK_SIZE, total - pos)
                tasks.append(self._read_chunk(pinned, base_addr, pos, n, self.offset + pos))
                pos += n
            counts = await asyncio.gather(*tasks)
            got = 0
            for c in counts:
                got += c
                if c < CHUNK_SIZE:
                    break

        return 0 if got <= 0 else got

cdef class IOUringFileWriter:
    cdef:
        IOUringOperation io_op
        BufferManager buffer_mgr
        int64_t offset

    def __init__(self, IOUringOperation io_op, BufferManager buffer_mgr, int64_t offset):
        self.io_op = io_op
        self.buffer_mgr = buffer_mgr
        self.offset = offset

    async def _write_chunk(self, object bdata, Py_ssize_t base_addr, Py_ssize_t start,
                           Py_ssize_t n, int64_t file_off):
        """Write n bytes from the buffer of bdata[start:], retrying short writes."""
        cdef:
            const char* base = <const char*><size_t>base_addr
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

    async def write(self, object bdata):
        """Zero-copy write from a bytes/str/buffer (pinned by the pump)."""
        cdef:
            Py_ssize_t total_bytes
            const char* base
            Py_ssize_t base_addr
            Py_ssize_t done
            Py_ssize_t pos
            Py_ssize_t n
            int64_t off
            int put
            list tasks

        if PyBytes_CheckExact(bdata):
            total_bytes = PyBytes_GET_SIZE(bdata)
            base = PyBytes_AS_STRING(bdata)
        elif PyUnicode_Check(bdata):
            base = PyUnicode_AsUTF8AndSize(bdata, &total_bytes)
        elif isinstance(bdata, _PinnedBuffer):
            total_bytes = (<_PinnedBuffer>bdata).view.len
            base = <const char*>(<_PinnedBuffer>bdata).view.buf
        else:
            total_bytes = PyBytes_GET_SIZE(bdata)
            base = PyBytes_AS_STRING(bdata)

        if total_bytes == 0:
            return 0

        # offset < 0 means O_APPEND: must stay a single, ordered write
        if self.offset < 0 or total_bytes < PARALLEL_THRESHOLD:
            done = 0
            while done < total_bytes:
                off = -1 if self.offset < 0 else self.offset + done
                put = await self.io_op.write(
                    base + done, <unsigned int>(total_bytes - done),
                    off, bdata
                )
                if put <= 0:
                    raise OSError(5, "io_uring write made no progress")
                done += put
            return done

        base_addr = <Py_ssize_t><size_t>base
        tasks = []
        pos = 0
        while pos < total_bytes:
            n = min(CHUNK_SIZE, total_bytes - pos)
            tasks.append(self._write_chunk(bdata, base_addr, pos, n, self.offset + pos))
            pos += n
        await asyncio.gather(*tasks)
        return total_bytes
