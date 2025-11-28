from .uv cimport uv_buf_t
from .cpython cimport PyObject


cdef struct FSOpenContext:
    PyObject* future       # Referencia al Future de asyncio
    char* name_file
    int flags
    int fd

cdef struct FSCloseContext:
    PyObject* future

cdef struct FSReadContext:
    PyObject*   future
    uv_buf_t*   bufs
    int chunk_size
    int nbufs
    int flags
    bint binary
    int requested_size

ctypedef fused FSRWContext:
    FSReadContext
    FSWriteContext

cdef struct FSWriteContext:
    PyObject*   future
    uv_buf_t*   bufs
    int nbufs
    PyObject* _refs
