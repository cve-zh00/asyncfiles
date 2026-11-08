# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .base_file cimport BaseFile
from .iterators cimport BaseFileIterator
from cpython.bytes cimport PyBytes_GET_SIZE
from cpython.unicode cimport PyUnicode_AsUTF8AndSize
from libc.stdint cimport int64_t
import io


cdef class TextFile(BaseFile):
    def __aiter__(self):
        return BaseFileIterator(self, 8192, False)

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
            int extra

        if remaining <= 0 or n == 0:
            return ""

        total_to_read = remaining if (n < 0 or n > remaining) else n
        read_offset = self.offset
        if read_offset >= 0:
            self.offset = read_offset + total_to_read

        data = await self._read_internal(total_to_read, read_offset)
        got = PyBytes_GET_SIZE(<bytes>data)
        if got != total_to_read and self.offset == read_offset + total_to_read:
            self.offset = read_offset + got

        # Handle incomplete multibyte UTF-8 at boundary
        try:
            return data.decode("utf-8")
        except UnicodeDecodeError:
            # The read may have cut a multibyte code point.
            # Read up to 3 more bytes (1 byte at a time) to complete it.
            for extra in range(3):
                if read_offset + got >= self.size:
                    break
                extra_data = await self._read_internal(1, read_offset + got)
                if not extra_data:
                    break
                data += extra_data
                if self.offset == read_offset + got:
                    self.offset += PyBytes_GET_SIZE(<bytes>extra_data)
                got += PyBytes_GET_SIZE(<bytes>extra_data)
                try:
                    return data.decode("utf-8")
                except UnicodeDecodeError:
                    continue
            # Still broken — raise the original error
            return data.decode("utf-8")

    async def write(self, str data):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.writable:
            raise io.UnsupportedOperation("File not open for writing")

        cdef:
            Py_ssize_t nbytes = 0
            int64_t write_offset
            Py_ssize_t result

        PyUnicode_AsUTF8AndSize(data, &nbytes)

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

        result = await self._write_internal(data, write_offset)
        return result

    async def readline(self, object size=-1):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.readable:
            raise io.UnsupportedOperation("File not open for reading")

        cdef Py_ssize_t limit = -1 if size is None else <Py_ssize_t>size
        if limit == 0:
            return ""

        if self._io_busy:
            await self._wait_io_turn()
        else:
            self._io_busy = True

        cdef list parts = []
        cdef Py_ssize_t chars = 0, step, remaining_limit, nl_idx, unread_bytes
        cdef str chunk, tail
        try:
            while True:
                step = 4096
                if limit > 0:
                    remaining_limit = limit - chars
                    if remaining_limit <= 0:
                        break
                    if remaining_limit < step:
                        step = remaining_limit
                chunk = await self.read(step)
                if not chunk:
                    break
                nl_idx = chunk.find("\n")
                if nl_idx != -1:
                    if limit > 0 and nl_idx + 1 > remaining_limit:
                        tail = chunk[remaining_limit:]
                        unread_bytes = len(tail.encode("utf-8"))
                        if unread_bytes > 0 and self.offset >= unread_bytes:
                            self.offset -= unread_bytes
                        parts.append(chunk[:remaining_limit])
                        break
                    tail = chunk[nl_idx + 1:]
                    unread_bytes = len(tail.encode("utf-8"))
                    if unread_bytes > 0 and self.offset >= unread_bytes:
                        self.offset -= unread_bytes
                    parts.append(chunk[:nl_idx + 1])
                    break
                if limit > 0 and len(chunk) > remaining_limit:
                    tail = chunk[remaining_limit:]
                    unread_bytes = len(tail.encode("utf-8"))
                    if unread_bytes > 0 and self.offset >= unread_bytes:
                        self.offset -= unread_bytes
                    parts.append(chunk[:remaining_limit])
                    break
                parts.append(chunk)
                chars += len(chunk)
            return "".join(parts)
        finally:
            self._release_io_turn()

    async def readlines(self, object hint=-1):
        cdef Py_ssize_t limit = -1 if hint is None else <Py_ssize_t>hint
        if limit <= 0:
            data = await self.read()
            return data.splitlines(True) if data else []
        cdef list lines = []
        cdef Py_ssize_t total = 0
        cdef str line
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
