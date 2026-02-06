# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .base_file cimport BaseFile
from .iterators cimport BaseFileIterator


cdef class BinaryFile(BaseFile):
    def __aiter__(self):
        return BaseFileIterator(self, 8192, True)

    async def write(self, bytes data):
        result = await self._write_internal(data)
        if result > 0 and self.offset >= 0:
            self.offset += result
        return result

    async def read(self, int length=-1):
        cdef Py_ssize_t total_to_read = length if length >= 0 else self.size - self.offset

        if total_to_read <= 0:
            return b""

        data = await self._read_internal(total_to_read)
        if self.offset >= 0:
            self.offset += len(data)

        return data
