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
    char*       buffer_mem       # Single allocated memory block for all buffers
    Py_ssize_t chunk_size
    Py_ssize_t nbufs
    int flags
    bint binary
    Py_ssize_t requested_size
    int fd


ctypedef fused FSRWContext:
    FSReadContext
    FSWriteContext

cdef struct FSWriteContext:
    PyObject*   future
    uv_buf_t*   bufs
    Py_ssize_t nbufs
    PyObject* _refs
