# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .base_file cimport BaseFile
from .iterators cimport BaseFileIterator


cdef class BinaryFile(BaseFile):
    def __aiter__(self):
        return BaseFileIterator(self, 8192, True)

    async def write(self, object data):
        cdef bytes bdata = data if isinstance(data, bytes) else bytes(data)
        cdef Py_ssize_t result = await self._write_internal(bdata)
        if result > 0:
            if self.file_mode.appending:
                if self.size >= 0:
                    self.size += result
                    self.offset = self.size
            elif self.offset >= 0:
                self.offset += result
                if self.size >= 0 and self.offset > self.size:
                    self.size = self.offset
        return result

    async def read(self, object length=-1):
        if self._closed:
            raise ValueError("I/O operation on closed file")
        if not self.file_mode.readable:
            raise OSError(9, "Bad file descriptor")

        cdef Py_ssize_t n = -1 if length is None else <Py_ssize_t>length
        cdef Py_ssize_t remaining = self.size - self.offset

        if remaining <= 0 or n == 0:
            return b""

        cdef Py_ssize_t total_to_read = remaining if (n < 0 or n > remaining) else n

        data = await self._read_internal(total_to_read)
        if self.offset >= 0:
            self.offset += len(data)

        return data

    async def readline(self, object size=-1):
        cdef Py_ssize_t limit = -1 if size is None else <Py_ssize_t>size
        if limit == 0:
            return b""
        cdef bytearray buf = bytearray()
        cdef Py_ssize_t step, remaining_limit, nl_idx, unread
        cdef bytes chunk
        while True:
            step = 4096
            if limit > 0:
                remaining_limit = limit - len(buf)
                if remaining_limit <= 0:
                    break
                if remaining_limit < step:
                    step = remaining_limit
            chunk = await self.read(step)
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
