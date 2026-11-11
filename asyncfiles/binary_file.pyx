# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .base_file cimport BaseFile
from .iterators cimport BaseFileIterator
from .utils cimport _PinnedBuffer
from cpython.buffer cimport PyBUF_SIMPLE, PyBUF_WRITABLE
from cpython.bytes cimport PyBytes_GET_SIZE
from libc.stdint cimport int64_t
import io


cdef class BinaryFile(BaseFile):
    def __aiter__(self):
        return BaseFileIterator(self, 8192, True)

    async def write(self, object data):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.writable:
            raise io.UnsupportedOperation("File not open for writing")

        cdef:
            object bdata
            _PinnedBuffer pinned
            Py_ssize_t nbytes
            int64_t write_offset
            Py_ssize_t result

        if isinstance(data, bytes):
            bdata = data
            nbytes = PyBytes_GET_SIZE(<bytes>data)
        else:
            try:
                pinned = _PinnedBuffer(data, PyBUF_SIMPLE)
                bdata = pinned
                nbytes = pinned.view.len
            except BufferError:
                bdata = memoryview(data).tobytes()
                nbytes = PyBytes_GET_SIZE(<bytes>bdata)

        if self.file_mode.appending:
            write_offset = -1
            if self.size >= 0:
                self.size += nbytes
                self.offset = self.size
        else:
            write_offset = self.offset
            if write_offset >= 0:
                self.offset = write_offset + nbytes
                if self.size >= 0 and self.offset > self.size:
                    self.size = self.offset

        result = await self._write_internal(bdata, write_offset)
        return result

    async def read(self, object length=-1):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.readable:
            raise io.UnsupportedOperation("File not open for reading")

        cdef:
            Py_ssize_t n = -1 if length is None else <Py_ssize_t>length
            Py_ssize_t remaining = self.size - self.offset
            Py_ssize_t total_to_read
            int64_t read_offset
            Py_ssize_t got

        if remaining <= 0 or n == 0:
            return b""

        total_to_read = remaining if (n < 0 or n > remaining) else n
        read_offset = self.offset
        if read_offset >= 0:
            self.offset = read_offset + total_to_read

        data = await self._read_internal(total_to_read, read_offset)
        got = PyBytes_GET_SIZE(<bytes>data)
        if got != total_to_read and self.offset == read_offset + total_to_read:
            self.offset = read_offset + got
        return data

    async def readinto(self, object b):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.readable:
            raise io.UnsupportedOperation("File not open for reading")

        cdef:
            _PinnedBuffer pinned = _PinnedBuffer(b, PyBUF_WRITABLE)
            Py_ssize_t buf_len = pinned.view.len
            Py_ssize_t remaining = self.size - self.offset
            Py_ssize_t total_to_read
            int64_t read_offset
            Py_ssize_t got

        if remaining <= 0 or buf_len <= 0:
            return 0

        total_to_read = remaining if buf_len > remaining else buf_len
        read_offset = self.offset
        if read_offset >= 0:
            self.offset = read_offset + total_to_read

        got = await self._readinto_internal(pinned, total_to_read, read_offset)
        if got != total_to_read and self.offset == read_offset + total_to_read:
            self.offset = read_offset + got
        return got

    async def readline(self, object size=-1):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.readable:
            raise io.UnsupportedOperation("File not open for reading")

        cdef Py_ssize_t limit = -1 if size is None else <Py_ssize_t>size
        if limit == 0:
            return b""

        if self._io_busy:
            await self._wait_io_turn()
        else:
            self._io_busy = True

        cdef bytearray buf = bytearray()
        cdef Py_ssize_t step, remaining_limit, remaining, total_to_read, nl_idx, unread
        cdef bytes chunk
        try:
            while True:
                step = 4096
                if limit > 0:
                    remaining_limit = limit - len(buf)
                    if remaining_limit <= 0:
                        break
                    if remaining_limit < step:
                        step = remaining_limit
                remaining = self.size - self.offset
                if remaining <= 0:
                    break
                total_to_read = remaining if step > remaining else step
                chunk = await self._read_internal(total_to_read)
                if self.offset >= 0:
                    self.offset += len(chunk)
                if not chunk:
                    break
                nl_idx = chunk.find(b"\n")
                if nl_idx != -1:
                    unread = len(chunk) - (nl_idx + 1)
                    if unread > 0 and self.offset >= unread:
                        self.offset -= unread
                    buf.extend(chunk[:nl_idx + 1])
                    break
                buf.extend(chunk)
            return bytes(buf)
        finally:
            self._release_io_turn()

    async def readlines(self, object hint=-1):
        cdef Py_ssize_t limit = -1 if hint is None else <Py_ssize_t>hint
        if limit <= 0:
            data = await self.read()
            return data.splitlines(True) if data else []
        cdef list lines = []
        cdef Py_ssize_t total = 0
        cdef bytes line
        while True:
            line = await self.readline()
            if not line:
                break
            lines.append(line)
            total += len(line)
            if total >= limit:
                break
        return lines

    async def writelines(self, object lines):
        for line in lines:
            await self.write(line)
