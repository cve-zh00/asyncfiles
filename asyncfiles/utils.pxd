from . cimport uv
from .cpython cimport PyObject


cdef Pump get_pump()
cdef struct FSContext:
    PyObject*   future       # Referencia al Future de asyncio
    PyObject*   async_loop   # Referencia al event loop de asyncio
    int         nbufs
    uv.uv_buf_t*   bufs
    uv.uv_buf_t    buf          # buffer único para operaciones simples
    PyObject*   _refs
    PyObject*   _cache

cdef class FSRequest:
    cdef:
        object future
        FSContext* ctx
        uv.uv_fs_t* req

    cdef FSContext* __create_ctx(self, object loop)
    cdef uv.uv_fs_t* __create_req(self)
    cdef void raise_fut_exception(self, int err, str message)

cdef object new_future(object loop)
cdef class Pump:
    cdef:
        object loop
        list async_cleanup_callbacks
        bint _cleanup_done
        list async_tasks
        int n_tasks
        list async_task_callbacks

    cdef inline void start(self, object loop)
    cdef register_async_cleanup(self, async_callback)
    cdef void register_async_task(self, async_callback)
    cdef void _execute_async_cleanup(self)

    cdef unregister_async_cleanup(self, async_callback)


cdef class FileMode:
    cdef:
        public bint readable
        public bint writable
        public bint plus
        public bint appending
        public bint created
        public int flags
        public bint binary
