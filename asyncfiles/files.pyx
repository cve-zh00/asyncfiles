# distutils: language = c
# cython: language_level=3


from .callbacks cimport cb_read, cb_write, cb_open, cb_close, cb_stat
from . cimport uv
from .cpython cimport PyObject
from .utils cimport new_future, FileMode
from .context cimport FSReadContext, FSWriteContext, FSOpenContext
cimport cython
from .utils cimport get_pump, Pump
from libc.stdlib cimport malloc, free
from cpython.bytearray cimport PyByteArray_FromStringAndSize
from cpython.bytes  cimport  PyBytes_GET_SIZE,  PyBytes_AsString
from cpython.ref    cimport Py_INCREF, Py_DECREF
from cpython.unicode cimport  PyUnicode_AsUTF8, PyUnicode_AsUTF8String
from asyncio import sleep

# ============================================================================
# Funciones auxiliares para manejo de buffers
# ============================================================================

cdef inline void _free_uv_bufs(uv.uv_buf_t* bufs, Py_ssize_t count)noexcept nogil:
    """Libera un array de buffers uv_buf_t"""
    cdef Py_ssize_t j
    for j in range(count):
        if bufs[j].base != NULL:
            free(bufs[j].base)
    free(bufs)


cdef inline uv.uv_buf_t* _make_uv_bufs(char* data_ptr, Py_ssize_t size, size_t buffer_size, int count) noexcept nogil:
    """Crea un array de buffers uv_buf_t para operaciones de I/O"""
    cdef uv.uv_buf_t* bufs = <uv.uv_buf_t*>malloc(count * sizeof(uv.uv_buf_t))
    if bufs == NULL:
        return NULL

    cdef Py_ssize_t i
    cdef Py_ssize_t chunk_len
    cdef char* ptr

    for i in range(count):
        if i < count - 1:
            chunk_len = buffer_size
        else:
            # último fragmento: lo que quede
            chunk_len = size - buffer_size * (count - 1)

        # reservar payload
        ptr = <char*>malloc(chunk_len)
        if ptr == NULL:
            _free_uv_bufs(bufs, i)
            free(bufs)
            return NULL

        bufs[i] = uv.uv_buf_init(ptr, <unsigned int>chunk_len)

    return bufs


cdef inline FSOpenContext* _create_fs_open_context(
    const char* path_cstr,
    int flags,
    int fd,
    object future
) except NULL:
    """Crea y configura un FSOpenContext"""
    cdef FSOpenContext* ctx = <FSOpenContext*>malloc(sizeof(FSOpenContext))
    if ctx == NULL:
        raise MemoryError("Cannot allocate FSOpenContext")

    ctx.name_file = path_cstr
    ctx.flags = flags
    ctx.future = <PyObject*>future
    ctx.fd = fd

    Py_INCREF(future)

    return ctx


cdef inline uv.uv_fs_t* _create_fs_request(void* context_data) except NULL:
    """Crea un uv_fs_t request y asigna el contexto"""
    cdef uv.uv_fs_t* req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
    if req == NULL:
        raise MemoryError("Cannot allocate uv_fs_t")

    req.data = context_data
    return req


cdef inline void _cleanup_open_on_error(
    FSOpenContext* ctx,
    uv.uv_fs_t* req,
    object future
):
    """Limpia recursos de FSOpenContext en caso de error"""
    if ctx != NULL:
        free(ctx)

    if req != NULL:
        free(req)

    if future is not None:
        Py_DECREF(future)


cdef inline void _cleanup_read_on_error(
    FSReadContext* ctx,
    uv.uv_fs_t* req,
    object future
):
    """Limpia recursos de lectura en caso de error"""
    if ctx != NULL:
        if ctx.bufs != NULL:
            _free_uv_bufs(ctx.bufs, ctx.nbufs)
        free(ctx)

    if req != NULL:
        free(req)

    if future is not None:
        Py_DECREF(future)


cdef inline void _cleanup_write_on_error(
    FSWriteContext* ctx,
    uv.uv_fs_t* req,
    object future,
    object refs = None
):
    if ctx != NULL:
        if ctx.bufs != NULL:
            free(ctx.bufs)
        free(ctx)

    if req != NULL:
        free(req)

    if refs is not None:
        Py_DECREF(refs)

    if future is not None:
        Py_DECREF(future)


# ============================================================================
# Clase File
# ============================================================================

cdef class File:
    cdef:
        str path
        const char*  path_cstr
        int fd, flags, size
        object       loop
        uv.uv_loop_t*   uv_loop
        size_t       buffer_size
        FileMode file_mode

    def __init__(self, str path, FileMode mode, size_t buffer_size, object loop):
        self.path = path
        self.path_cstr = PyUnicode_AsUTF8(path)
        self.flags = mode.flags
        self.buffer_size = buffer_size
        self.loop = loop
        self.uv_loop = uv.uv_default_loop()
        self.file_mode = mode
        self.fd = -1
        self.size = -1
        self.__configure__bg_tasks()

    cdef inline int run_nowait(self)noexcept nogil:
        return uv.uv_run(self.uv_loop, uv.UV_RUN_NOWAIT)

    cdef __configure__bg_tasks(self):
        """Configura las tareas en background"""
        cdef Pump pump = get_pump()
        pump.register_async_task(self._pump)
        pump.start(self.loop)

    async def _pump(self):
        """Pump para procesar eventos de libuv"""
        cdef int err
        while True:
            err = self.run_nowait()
            if err < 0:
                raise OSError(-err, "uv_run failed")
            await sleep(0)

    # ========================================================================
    # Context Manager
    # ========================================================================

    async def __aenter__(self):
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future
            int err

        future = new_future(self.loop)
        try:
            ctx = _create_fs_open_context(self.path_cstr, self.flags, -1, future)
            req = _create_fs_request(<void*>ctx)
        except MemoryError as e:
            if 'ctx' in locals() and ctx != NULL:
                free(ctx)
                Py_DECREF(future)
            raise e

        err = uv.uv_fs_open(
            self.uv_loop,
            req,
            ctx.name_file,
            self.flags,
            0o644,
            cb_open
        )

        if err < 0:
            _cleanup_open_on_error(ctx, req, future)
            raise OSError(f"uv_fs_open failed: {err}")

        self.fd = await future

        if self.file_mode.readable:
            self.size = await self._get_size()

        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Salida del context manager - cierra el archivo"""

        if self.fd >= 0:
            await self._close()

    cdef object _get_size(self):
        """Obtiene el tamaño del archivo de forma asíncrona"""
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future
            int err

        future = new_future(self.loop)

        try:
            ctx = _create_fs_open_context(
                self.path_cstr,
                self.flags,
                self.fd,
                future
            )
            req = _create_fs_request(<void*>ctx)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for stat"))
            return future

        err = uv.uv_fs_stat(self.uv_loop, req, ctx.name_file, cb_stat)

        if err < 0:
            _cleanup_open_on_error(ctx, req, future)
            future.set_exception(OSError(f"uv_fs_stat failed: {err}"))
            return future

        return future

    cdef object _close(self):
        """Cierra el archivo de forma asíncrona"""
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future
            int err

        future = new_future(self.loop)

        try:
            ctx = _create_fs_open_context(
                self.path_cstr,
                self.flags,
                self.fd,
                future
            )
            req = _create_fs_request(<void*>ctx)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for close"))
            return future

        err = uv.uv_fs_close(
            self.uv_loop,
            req,
            self.fd,
            cb_close
        )

        if err < 0:
            _cleanup_open_on_error(ctx, req, future)
            future.set_exception(OSError(f"uv_fs_close failed: {err}"))
            return future

        return future

    @cython.cdivision(True)
    cpdef object read(self, int length=-1):
        """Lee datos del archivo de forma asíncrona y devuelve un Future"""
        cdef:
            object future = new_future(self.loop)
            int err
            Py_ssize_t total
            int total_bufs
            Py_ssize_t chunk_size
            FSReadContext* ctx = NULL
            uv.uv_fs_t* req = NULL

        # Calcular tamaño total y número de buffers
        total = self.size if self.size >= 0 else length

        if total <= self.buffer_size:
            total_bufs = 1
            chunk_size = total
        else:
            total_bufs = <int>((total + self.buffer_size - 1) // self.buffer_size)
            chunk_size = self.buffer_size

        # Crear contexto de lectura
        ctx = <FSReadContext*> malloc(sizeof(FSReadContext))
        if ctx == NULL:
            future.set_exception(MemoryError("Cannot allocate FSReadContext"))
            return future

        ctx.nbufs = total_bufs
        ctx.bufs = _make_uv_bufs(NULL, total, chunk_size, total_bufs)
        ctx.future = <PyObject*>future

        if ctx.bufs == NULL:
            free(ctx)
            future.set_exception(MemoryError("Cannot allocate buffers"))
            return future

        Py_INCREF(future)

        # Crear request
        req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
        if req == NULL:
            _cleanup_read_on_error(ctx, NULL, future)
            future.set_exception(MemoryError("Cannot allocate request"))
            return future

        req.data = <void*>ctx

        # Ejecutar lectura asíncrona
        err = uv.uv_fs_read(
            self.uv_loop,
            req,
            self.fd,
            ctx.bufs,
            <unsigned int>ctx.nbufs,
            0,
            cb_read
        )

        if err < 0:
            _cleanup_read_on_error(ctx, req, future)
            future.set_exception(OSError(f"uv_fs_read failed: {err}"))
            return future

        return future

    # ========================================================================
    # Operaciones de escritura
    # ========================================================================

    @cython.cdivision(True)
    cpdef object write(self, str data):
        """Escribe datos al archivo de forma asíncrona"""
        cdef:
            object future
            bytes bdata
            char* base_ptr
            Py_ssize_t total_bytes, offset
            FSWriteContext* ctx = NULL
            int buf_size, nbufs, i, chunk_len, err
            uv.uv_fs_t* req = NULL

        future = new_future(self.loop)

        # Codificar datos
        bdata = PyUnicode_AsUTF8String(data)
        if bdata is None:
            future.set_exception(MemoryError("Error encoding data"))
            return future

        base_ptr = PyBytes_AsString(bdata)
        total_bytes = PyBytes_GET_SIZE(bdata)
        buf_size = self.buffer_size
        nbufs = <int>((total_bytes + buf_size - 1) // buf_size)

        # Crear contexto de escritura
        ctx = <FSWriteContext*> malloc(sizeof(FSWriteContext))
        if ctx == NULL:
            future.set_exception(MemoryError("Cannot allocate FSWriteContext"))
            return future

        ctx.future = <PyObject*>future
        ctx.bufs = <uv.uv_buf_t*> malloc(nbufs * sizeof(uv.uv_buf_t))
        if ctx.bufs == NULL:
            free(ctx)
            future.set_exception(MemoryError("Cannot allocate buffer structs"))
            return future

        # Configurar buffers (sin copiar datos, solo referencias)
        if nbufs == 1:
            ctx.bufs[0] = uv.uv_buf_init(base_ptr, <unsigned int>total_bytes)
        else:
            for i in range(nbufs):
                offset = i * buf_size
                chunk_len = total_bytes - offset
                if chunk_len > buf_size:
                    chunk_len = buf_size
                ctx.bufs[i] = uv.uv_buf_init(base_ptr + offset, <unsigned int>chunk_len)

        ctx.nbufs = nbufs

        # Mantener referencia a los datos
        Py_INCREF(bdata)
        Py_INCREF(future)
        ctx._refs = <PyObject*> bdata

        # Crear request
        req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
        if req == NULL:
            _cleanup_write_on_error(ctx, NULL, future, bdata)
            future.set_exception(MemoryError("Cannot allocate request"))
            return future

        req.data = <void*>ctx

        # Ejecutar escritura asíncrona
        err = uv.uv_fs_write(self.uv_loop, req, self.fd, ctx.bufs, ctx.nbufs, 0, cb_write)

        if err < 0:
            _cleanup_write_on_error(ctx, req, future, bdata)
            future.set_exception(OSError(f"uv_fs_write failed: {err}"))
            return future

        return future
