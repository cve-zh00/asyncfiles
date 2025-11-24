from .uv cimport uv_buf_t
from .cpython cimport PyObject


cdef struct FSOpenContext:
    PyObject* future       # Referencia al Future de asyncio
    char* name_file
    int flags
    int fd

cdef struct FSCloseContext:
    PyObject* future       # Referencia al Future de asyncio

cdef struct FSReadContext:
    PyObject*   future       # Referencia al Future de asyncio
    uv_buf_t*   bufs
    int chunk_size
    int nbufs
    int flags

ctypedef fused FSRWContext:
    FSReadContext
    FSWriteContext

cdef struct FSWriteContext:
    PyObject*   future
    uv_buf_t*   bufs
    int nbufs
    PyObject* _refs
