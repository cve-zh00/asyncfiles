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
    char*       buffer_mem       # Single allocated memory block (NULL if zero-copy)
    PyObject*   py_buf           # Zero-copy: holds the bytes object libuv writes into
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
