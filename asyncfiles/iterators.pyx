# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False


cdef class BaseFileIterator:
    def __init__(self, object file, int chunk_size, bint is_binary):
        self.file = file
        self.buffer = b"" if is_binary else ""
        self.chunk_size = chunk_size
        self.exhausted = False
        self.is_binary = is_binary

    def __aiter__(self):
        return self

    async def __anext__(self):
        cdef int newline_pos
        cdef object line, chunk, newline_char

        newline_char = b'\n' if self.is_binary else '\n'

        if self.exhausted and not self.buffer:
            raise StopAsyncIteration

        while True:
            newline_pos = self.buffer.find(newline_char)

            if newline_pos != -1:
                line = self.buffer[:newline_pos + 1]
                self.buffer = self.buffer[newline_pos + 1:]
                return line

            if self.exhausted:
                if self.buffer:
                    line = self.buffer
                    self.buffer = b"" if self.is_binary else ""
                    return line
                else:
                    raise StopAsyncIteration

            chunk = await self.file.read(self.chunk_size)

            if not chunk or len(chunk) == 0:
                self.exhausted = True
            else:
                self.buffer += chunk
