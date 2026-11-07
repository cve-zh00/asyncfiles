# cython: language_level=3

from libc.stdint cimport int64_t


cdef class SendfileProtocol:
    cdef:
        object _transport
        object _loop
        object _proto
        object _write_ready
        object _connection_lost_exc
        bint _should_pause
        bint _connection_lost
        bint _reading_paused

    cpdef is_buffered_protocol(self)


cpdef validate_sendfile_args(
    object transport,
    object offset,
    object count,
    Py_ssize_t chunk_size,
)

