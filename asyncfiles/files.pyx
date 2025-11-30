# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
from .callbacks cimport cb_read, cb_write, cb_open, cb_close, cb_stat, cb_ftruncate
from . cimport uv
from .cpython cimport PyObject
from .utils cimport new_future, FileMode
from .context cimport FSReadContext, FSWriteContext, FSOpenContext
cimport cython
from .utils cimport get_pump, Pump
from libc.stdlib cimport malloc, free
from libc.stdint cimport int64_t
from cpython.bytearray cimport PyByteArray_FromStringAndSize, PyByteArray_Resize, PyByteArray_AsString, PyByteArray_Size
from cpython.bytes  cimport  PyBytes_GET_SIZE,  PyBytes_AsString, PyBytes_FromStringAndSize
from cpython.ref    cimport Py_INCREF, Py_DECREF
from cpython.unicode cimport  PyUnicode_AsUTF8, PyUnicode_AsUTF8String
from asyncio import sleep



cdef inline void _free_uv_bufs(uv.uv_buf_t* bufs, Py_ssize_t count)noexcept nogil:
    """Libera un array de buffers uv_buf_t"""
    cdef Py_ssize_t j
    for j in range(count):
        if bufs[j].base != NULL:
            free(bufs[j].base)
    free(bufs)



cdef inline uv.uv_fs_t* make_libuv_request(const char* path_cstr, int flags, int fd, object loop):
    cdef:
        object future = new_future(loop)
        FSOpenContext* ctx = <FSOpenContext*>malloc(sizeof(FSOpenContext))
    if ctx == NULL:
        raise MemoryError("Cannot allocate FSOpenContext")

    ctx.name_file = path_cstr
    ctx.flags = flags
    ctx.future = <PyObject*>future
    ctx.fd = fd

    Py_INCREF(future)
    cdef uv.uv_fs_t* req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
    if req == NULL:
        raise MemoryError("Cannot allocate uv_fs_t")

    req.data = <void*>ctx
    return req

cdef inline uv.uv_buf_t* _make_uv_bufs(char* data_ptr, Py_ssize_t size, size_t buffer_size, int count) noexcept nogil:
    """Crea un array de buffers uv_buf_t para operaciones de I/O"""
    cdef uv.uv_buf_t* bufs = <uv.uv_buf_t*>malloc(count * sizeof(uv.uv_buf_t))
    if bufs == NULL:
        return NULL

    cdef Py_ssize_t i
    cdef Py_ssize_t chunk_len
    cdef char* ptr

    for i in range(min(count,1024)):
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


cdef inline object fail_future(object future, const char* msg):
    future.set_exception(OSError(msg))
    return future

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


cdef class BaseFile:
    """Clase base para operaciones de archivos asíncronas"""
    cdef:
        str path
        const char*  path_cstr
        int fd, flags, size
        int64_t offset
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
        # Inicializar offset basado en el modo
        if mode.appending:
            self.offset = -1  # -1 indica append al final
        else:
            self.offset = 0
        self.__configure__bg_tasks()

    cdef inline int run_nowait(self)noexcept nogil:
        return uv.uv_run(self.uv_loop, uv.UV_RUN_NOWAIT)

    cdef __configure__bg_tasks(self):
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

    async def __aenter__(self):
        cdef:
            FSOpenContext* ctx
            uv.uv_fs_t* req
            object future
            int err

        req = make_libuv_request(self.path_cstr, self.flags, self.fd, self.loop)
        ctx = <FSOpenContext*>req.data
        future = <object>ctx.future
        err = uv.uv_fs_open(
            self.uv_loop,
            req,
            self.path_cstr,
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

    cdef object _truncate(self, int64_t length):
        """Trunca el archivo al tamaño especificado"""
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
            future.set_exception(MemoryError("Cannot allocate memory for truncate"))
            return future

        err = uv.uv_fs_ftruncate(self.uv_loop, req, self.fd, length, cb_ftruncate)

        if err < 0:
            _cleanup_open_on_error(ctx, req, future)
            future.set_exception(OSError(f"uv_fs_ftruncate failed: {err}"))
            return future

        return future

    async def truncate(self, int64_t length=0):
        """Trunca el archivo al tamaño especificado"""
        await self._truncate(length)
        if self.file_mode.readable:
            self.size = length
        return 0

    cpdef seek(self, int64_t offset, int whence=0):

        if whence == 0:  # SEEK_SET
            self.offset = offset
        elif whence == 1:  # SEEK_CUR
            self.offset += offset
        elif whence == 2:  # SEEK_END
            if self.size >= 0:
                self.offset = self.size + offset
            else:
                raise OSError("Cannot seek from end without knowing file size")
        else:
            raise ValueError(f"Invalid whence value: {whence}")

        self.offset = max(0, self.offset)

        return self.offset

    cpdef tell(self):
        """Retorna la posición actual en el archivo"""
        return self.offset

    @cython.cdivision(True)
    cdef object _read_internal(self, int length=-1):
        """Implementación interna de lectura"""
        cdef:
            object future = new_future(self.loop)
            int err
            Py_ssize_t total
            Py_ssize_t total_bufs = 1
            Py_ssize_t chunk_size = self.buffer_size
            FSReadContext* ctx = NULL
            uv.uv_fs_t* req = NULL
            unsigned int nbufs_uint
            Py_ssize_t actual_read_size


        total = length if length >= 0 else max(0, self.size - self.offset)

        if total <= 0:
            future.set_result(b"" if self.file_mode.binary else "")
            return future



        if total <= self.buffer_size or total > self.buffer_size * 1024:
            chunk_size = total
            total_bufs = 1
        else:
            total_bufs = (total + self.buffer_size - 1) // self.buffer_size
            chunk_size = self.buffer_size
        actual_read_size = total

        # Crear contexto de lectura
        ctx = <FSReadContext*> malloc(sizeof(FSReadContext))
        if ctx == NULL:
            future.set_exception(MemoryError("Cannot allocate FSReadContext"))
            return future

        ctx.nbufs = min(1024,total_bufs)
        ctx.bufs = _make_uv_bufs(NULL, actual_read_size, chunk_size, total_bufs)
        ctx.future = <PyObject*>future
        ctx.binary = self.file_mode.binary
        ctx.requested_size = actual_read_size
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
        nbufs_uint = <unsigned int>ctx.nbufs

        err = uv.uv_fs_read(
            self.uv_loop,
            req,
            self.fd,
            ctx.bufs,
            nbufs_uint,
            self.offset,
            cb_read
        )

        if err < 0:
            _cleanup_read_on_error(ctx, req, future)
            future.set_exception(OSError(f"uv_fs_read failed: {err}"))
            return future

        return future

    @cython.cdivision(True)
    cdef object _write_internal(self, bytes bdata):
        """Implementación interna de escritura"""
        cdef:
            object future
            char* base_ptr
            Py_ssize_t total_bytes, offset, current_offset
            FSWriteContext* ctx = NULL
            int buf_size, nbufs, i, chunk_len, err
            uv.uv_fs_t* req = NULL

        future = new_future(self.loop)
        if len(bdata) == 0:
            future.set_result(0)
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

        # Configurar buffers correctamente
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


        err = uv.uv_fs_write(self.uv_loop, req, self.fd, ctx.bufs, ctx.nbufs, self.offset, cb_write)

        if err < 0:
            _cleanup_write_on_error(ctx, req, future, bdata)
            future.set_exception(OSError(f"uv_fs_write failed: {err}"))
            return future

        return future


cdef class BinaryFileIterator:
    """Iterador especializado para leer líneas de archivos binarios"""
    cdef:
        BinaryFile file
        bytes buffer
        int chunk_size
        bint exhausted

    def __init__(self, BinaryFile binary_file, int chunk_size=8192):
        """
        Inicializa el iterador binario

        Args:
            binary_file: Instancia de BinaryFile a iterar
            chunk_size: Tamaño del chunk para lectura (default 8192 bytes)
        """
        self.file = binary_file
        self.buffer = b""
        self.chunk_size = chunk_size
        self.exhausted = False

    def __aiter__(self):
        """Retorna el iterador asíncrono"""
        return self

    async def __anext__(self):
        """Lee la siguiente línea del archivo (separada por \\n)"""
        cdef bytes chunk
        cdef int newline_pos
        cdef bytes line

        # Si ya terminamos, no hay más líneas
        if self.exhausted and not self.buffer:
            raise StopAsyncIteration

        # Buscar salto de línea en el buffer actual
        while True:
            newline_pos = self.buffer.find(b'\n')

            if newline_pos != -1:
                # Encontramos un salto de línea
                line = self.buffer[:newline_pos + 1]
                self.buffer = self.buffer[newline_pos + 1:]
                return line

            # No hay salto de línea, necesitamos leer más datos
            if self.exhausted:
                # Ya no hay más datos y no hay salto de línea
                if self.buffer:
                    # Retornar la última línea sin salto de línea
                    line = self.buffer
                    self.buffer = b""
                    return line
                else:
                    raise StopAsyncIteration

            # Leer más datos del archivo
            chunk = await self.file.read(self.chunk_size)

            if not chunk or len(chunk) == 0:
                # Llegamos al final del archivo
                self.exhausted = True
            else:
                # Agregar chunk al buffer
                self.buffer += chunk


cdef class BinaryFile(BaseFile):
    """Clase para operaciones con archivos binarios"""

    def __aiter__(self):
        """Retorna un iterador especializado para leer líneas"""
        return BinaryFileIterator(self)

    async def write(self, bytes data):
        """Escribe datos binarios en el archivo"""
        result = await self._write_internal(data)
        # Actualizar offset después de que la escritura seomplete
        if result > 0 and self.offset >= 0:
            self.offset += result
        return result

    async def read(self, int length=-1):
        """Lee datos binarios del archivo de forma asíncrona"""


        total_to_read = length if length >= 0 else self.size - self.offset

        if total_to_read <= 0:
            return ""

        data = await self._read_internal(total_to_read)
        if self.offset >= 0:
            self.offset += len(data)

        return result



cdef class TextFileIterator:
    """Iterador especializado para leer líneas de archivos de texto"""
    cdef:
        TextFile file
        str buffer
        int chunk_size
        bint exhausted

    def __init__(self, TextFile text_file, int chunk_size=8192):
        """
        Inicializa el iterador de texto

        Args:
            text_file: Instancia de TextFile a iterar
            chunk_size: Tamaño del chunk para lectura (default 8192 bytes)
        """
        self.file = text_file
        self.buffer = ""
        self.chunk_size = chunk_size
        self.exhausted = False

    def __aiter__(self):
        """Retorna el iterador asíncrono"""
        return self

    async def __anext__(self):
        """Lee la siguiente línea del archivo"""
        cdef str chunk
        cdef int newline_pos
        cdef str line

        # Si ya terminamos, no hay más líneas
        if self.exhausted and not self.buffer:
            raise StopAsyncIteration

        # Buscar salto de línea en el buffer actual
        while True:
            newline_pos = self.buffer.find('\n')

            if newline_pos != -1:
                # Encontramos un salto de línea
                line = self.buffer[:newline_pos + 1]
                self.buffer = self.buffer[newline_pos + 1:]
                return line

            # No hay salto de línea, necesitamos leer más datos
            if self.exhausted:
                # Ya no hay más datos y no hay salto de línea
                if self.buffer:
                    # Retornar la última línea sin salto de línea
                    line = self.buffer
                    self.buffer = ""
                    return line
                else:
                    raise StopAsyncIteration

            # Leer más datos del archivo
            chunk = await self.file.read(self.chunk_size)

            if not chunk or len(chunk) == 0:
                # Llegamos al final del archivo
                self.exhausted = True
            else:
                # Agregar chunk al buffer
                self.buffer += chunk


cdef class TextFile(BaseFile):
    """Clase para operaciones con archivos de texto"""

    def __aiter__(self):
        """Retorna un iterador especializado para leer líneas"""
        return TextFileIterator(self)

    async def read(self, int length=-1):
        total_to_read = length if length >= 0 else self.size - self.offset

        if total_to_read <= 0:
            return ""

        data = await self._read_internal(total_to_read)

        if self.offset >= 0:
            self.offset += len(data)

        return data.decode("utf-8")

    async def write(self, str data):
        """Escribe texto en el archivo de forma asíncrona"""
        cdef bytes bdata

        bdata = PyUnicode_AsUTF8String(data)
        if bdata is None:
            raise MemoryError("Error encoding data")

        result = await self._write_internal(bdata)
        # Actualizar offset después de que la escritura se complete
        if result > 0 and self.offset >= 0:
            self.offset += result
        return result
