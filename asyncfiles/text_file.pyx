# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .base_file cimport BaseFile
from .iterators cimport BaseFileIterator
from cpython.unicode cimport PyUnicode_AsUTF8String


cdef class TextFile(BaseFile):
    def __aiter__(self):
        return BaseFileIterator(self, 8192, False)

    async def read(self, int length=-1):
        cdef Py_ssize_t total_to_read = length if length >= 0 else self.size - self.offset

        if total_to_read <= 0:
            return ""

        data = await self._read_internal(total_to_read)

        if self.offset >= 0:
            self.offset += len(data)

        return data.decode("utf-8")

    async def write(self, str data):
        cdef:
            bytes bdata
            int result

        bdata = PyUnicode_AsUTF8String(data)
        if bdata is None:
            raise MemoryError("Error encoding data")

        result = await self._write_internal(bdata)
        if result > 0 and self.offset >= 0:
            self.offset += result
        return result
