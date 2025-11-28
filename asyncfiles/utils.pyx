
from . cimport uv
from . cimport cpython as py
from posix.fcntl cimport (
    O_RDONLY, O_WRONLY, O_RDWR,
    O_CREAT, O_TRUNC, O_APPEND, O_EXCL, O_DSYNC, O_SYNC
)

cimport cython
from libc.string cimport strchr
from libc.stdlib cimport malloc, free
from . cimport uv
from cpython.ref    cimport Py_INCREF, Py_DECREF
cimport cython
from asyncio import create_task, sleep, get_running_loop, Future

cdef  object new_future(object loop):
    cdef object future = Future(loop = loop)
    Py_INCREF(future)
    return future

cdef class FileMode:

    def __cinit__(self, bint readable, bint writable, bint plus, bint appending, bint created, int flags, bint binary):
        self.readable = readable
        self.writable = writable
        self.plus = plus
        self.appending = appending
        self.created = created
        self.flags = flags
        self.binary = binary


cpdef FileMode mode_to_posix(const char* mode):
    cdef:
        bint base_mode_found = False
        bint readable = False
        bint writable = False
        bint plus = False
        bint appending = False
        bint created = False
        bint binary = False
        bint text_mode = False

        int flags = 0
        bytes ch

    # Iteración sobre el modo
    for ch in mode:

        # BASE MODES
        if ch == b"r":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            readable = True

        elif ch == b"w":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            writable = True
            created = True
            flags |= O_CREAT | O_TRUNC | O_WRONLY

        elif ch == b"x":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            writable = True
            created = True
            flags |= O_EXCL | O_CREAT

        elif ch == b"a":
            if base_mode_found:
                raise ValueError("Invalid mode: duplicate base mode")
            base_mode_found = True
            writable = True
            created = True
            appending = True
            flags |= O_CREAT | O_APPEND

        # MODIFICADORES
        elif ch == b"+":
            if plus:
                raise ValueError("Invalid mode: duplicate '+'")
            plus = True
            readable = True
            writable = True

        elif ch == b"b":
            binary = True

        elif ch == b"t":
            text_mode = True

        elif ch == b"U":
            # legacy universal-newline, ignorado
            readable = True

        else:
            raise ValueError(f"Invalid mode character: {ch!r}")

    # VALIDACIONES
    if not base_mode_found:
        raise ValueError("Invalid mode: must contain 'r', 'w', 'x', or 'a'")

    # ACCESS MODE
    if readable and writable:
        flags = (flags & ~3) | O_RDWR
    elif readable:
        flags = (flags & ~3) | O_RDONLY
    else:
        flags = (flags & ~3) | O_WRONLY

    return FileMode(
        readable=readable,
        writable=writable,
        plus=plus,
        appending=appending,
        created=created,
        flags=flags,
        binary=binary,
    )



cdef bint _started = False
pump = None

cdef inline Pump get_pump():
    global pump
    global _started

    if pump is None:
        pump = Pump()
        _started = True
    return pump


cdef class Pump:

    def __cinit__(self):
        self.loop = None
        self.async_cleanup_callbacks = []
        self.async_tasks = []
        self.n_tasks = 0
        self.async_task_callbacks = []
        self._cleanup_done = False

    cdef void register_async_task(self, async_callback):
        """
        Registra una función de tarea asíncrona.

        Args:
            async_callback: Función asíncrona a ejecutar
            loop: Loop de asyncio a usar (None para detectar automáticamente)
            *args, **kwargs: Argumentos para la función
        """
        if not self._cleanup_done:
            self.async_task_callbacks.append((async_callback))
            self.n_tasks += 1

    cdef inline void start(self, object loop):
        self.loop = loop
        for callback in self.async_task_callbacks:
            create_task(callback())

    cdef register_async_cleanup(self, async_callback):

            if not self._cleanup_done:
                self.async_cleanup_callbacks.append((async_callback))

    cdef unregister_async_cleanup(self, async_callback):
        """Desregistra una función de limpieza asíncrona"""
        self.async_cleanup_callbacks = [
            (cb) for cb in self.async_cleanup_callbacks
            if cb != async_callback
        ]

    cdef void _execute_async_cleanup(self):
        """Ejecuta la limpieza asíncrona sin bloquear"""
        cdef object loop_to_use
        print(f"Executing async cleanup with loop type: {type(self.loop)}")

        loop_to_use = self.loop
        if loop_to_use is None or loop_to_use.is_closed():
            loop_to_use = get_running_loop()
            print(f"Using running loop: {loop_to_use}")
        print(f"validate loop: {loop_to_use is not None}:{loop_to_use.is_closed()}")
        if self._cleanup_done or not self.async_cleanup_callbacks:
            return

        self._cleanup_done = True

        # Ejecutar callbacks asíncronos en orden inverso
        for callback in reversed(self.async_cleanup_callbacks):
            try:
                loop_to_use.create_task(callback())

            except Exception as e:

                print(f"Error scheduling async cleanup: {e}")

        self.async_cleanup_callbacks.clear()

    def __dealloc__(self):
        """Ejecuta la limpieza automáticamente cuando el objeto es destruido"""
        #self._execute_async_cleanup()
        pass



cdef class FSRequest:

    def __cinit__(self, object loop):
        self.future = loop.create_future()
        Py_INCREF(self.future)

        self.ctx = self.__create_ctx(loop)
        self.req = self.__create_req()

    cdef inline FSContext* __create_ctx(self, object loop):
        cdef FSContext* ctx = <FSContext*>malloc(sizeof(FSContext))
        if ctx == NULL:
            self.future.set_exception(MemoryError("Cannot allocate FSContext"))
            return NULL

        ctx.future = <py.PyObject*>self.future
        ctx.async_loop = <py.PyObject*>loop
        ctx.nbufs = 0
        ctx.bufs = NULL
        ctx.buf.base = NULL
        ctx._refs = NULL
        ctx._cache = NULL
        return ctx

    cdef inline uv.uv_fs_t* __create_req(self):
        cdef uv.uv_fs_t* req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))

        if req == NULL:
            Py_DECREF(self.future)
            free(self.ctx)
            self.future.set_exception(MemoryError("Cannot allocate uv.uv_fs_t"))
            return NULL
        req.data = <void*>self.ctx
        return req

    cdef inline void raise_fut_exception(self, int err, str message):
        if err < 0:

            Py_DECREF(self.future)
            free(self.ctx)
            free(self.req)
            self.future.set_exception(OSError(f"{message}: {err}"))
