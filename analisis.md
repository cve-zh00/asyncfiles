# Análisis Detallado — `asyncfiles` (Cython + libuv)

Revisión a fondo del código. La arquitectura por capas (uv → callbacks → io_operations → file_io → base/text/binary) es sólida, pero hay varios problemas serios de **performance**, **corrección** y **orden** que vale la pena atacar. Se clasifican por severidad.

---

## 🔴 Críticos (corrección / bugs latentes)

### 1. `EventLoopPump._pump` usa `await sleep(0)` → 100% CPU y latencia alta

```python
while True:
    err = self.run_nowait()       # no-bloqueante: retorna de inmediato
    await sleep(0)                # cede 1 tick pero se vuelve a programar YA
```

Esto es un **busy loop cooperativo**: en cada iteración del asyncio loop drena libuv sin esperar nada. Consume CPU al 100% mientras hay un archivo abierto y, peor, monopoliza el scheduler de asyncio.

**Solución correcta**: integrar el `backend_fd` de libuv con el selector de asyncio.

```cython
# uv_backend_fd(loop) + uv_backend_timeout(loop) → loop.add_reader(fd, callback)
# El callback hace uv_run(loop, UV_RUN_NOWAIT)
```

Es el patrón que usa **uvloop**. Elimina el polling y baja el uso de CPU a ~0% cuando no hay I/O pendiente. **Esto solo, probablemente, da el mayor salto de performance.**

**Nota de implementación**: `uv_backend_fd()` y `uv_backend_timeout()` no están declarados en `uv.pxd` actualmente — hay que agregarlos. En macOS el backend es kqueue; `loop.add_reader()` funciona correctamente con kqueue fds. En Python 3.12+ `add_reader` está deprecated en `ProactorEventLoop` (Windows), pero no aplica aquí por ser POSIX-only.

### 2. `uv_default_loop()` compartido entre instancias

```cython
self.uv_loop = uv.uv_default_loop()
```

Si se abren 2 archivos en paralelo, **ambos arrancan su propio `EventLoopPump` apuntando al mismo `uv_loop`** → carrera de drenado, callbacks duplicados, doble free potencial.

**Solución**: un único `EventLoopPump` singleton por event loop de asyncio. Usar `WeakValueDictionary` keyed por `id(loop)` (los event loops no son hashables por defecto en todas las versiones de Python, así que `WeakKeyDictionary[loop, Pump]` no funciona directamente).

```python
import weakref
_pumps: dict[int, weakref.ref[EventLoopPump]] = {}

def get_pump(asyncio_loop, uv_loop) -> EventLoopPump:
    loop_id = id(asyncio_loop)
    ref = _pumps.get(loop_id)
    pump = ref() if ref else None
    if pump is None:
        pump = EventLoopPump.create(uv_loop)
        _pumps[loop_id] = weakref.ref(pump)
    return pump
```

### 3. `cb_open` mapea errno por números mágicos negativos

```cython
if err == -2:   future.set_exception(FileNotFoundError())
elif err == -17: future.set_exception(FileExistsError())
```

Esos códigos son **constantes libuv (`UV_ENOENT`, `UV_EEXIST`)** que no son portables como literales. En macOS y Linux coinciden hoy, pero el contrato no lo garantiza.

**Solución**: usar `OSError(errno, strerror)` que deja a Python mapear automáticamente a la subclase correcta (PEP 3151):

```cython
# Agregar a uv.pxd:
#   const char* uv_strerror(int err)

# En callbacks:
future.set_exception(OSError(-err, uv.uv_strerror(err)))
# Python automáticamente retorna FileNotFoundError si errno==ENOENT, etc.
```

Además, los demás callbacks (`cb_stat`, `cb_close`, `cb_ftruncate`) construyen `OSError(err)` con `err` **negativo** → `errno` queda inválido y el mensaje sale como `[Errno -22] ...`. Siempre negar: `OSError(-err, ...)`.

### 4. `PyUnicode_AsUTF8` — lifetime del puntero

```cython
self.path_cstr = PyUnicode_AsUTF8(path)
```

El puntero es válido mientras `self.path` (el `str`) viva. Como `BaseFile` guarda `self.path` y `IOOperation` se usa solo dentro del lifetime de `BaseFile`, en la práctica no hay use-after-free: el `await` mantiene una referencia al frame que mantiene `self` vivo.

**Sin embargo**, es más defensivo y explícito convertir a `bytes`:

```cython
self.path_bytes = path.encode("utf-8")
self.path_cstr = PyBytes_AsString(self.path_bytes)
```

**Severidad real**: buena práctica, no crítico. El escenario de use-after-free requeriría que el GC colecte `BaseFile` mientras hay un `await` pendiente sobre él, lo cual no ocurre en uso normal.

### 5. Leak en cancelación: `_ReadResult` sin `__dealloc__`

`cb_read` crea un `_ReadResult` wrapper con el `ctx` y lo pasa como resultado del future. Si la coroutine que hace `await` es cancelada entre que el future se resuelve y `_process_read_result` se ejecuta, el `_ReadResult` se garbage-collecta **sin liberar `ctx`** → leak de hasta `total` bytes por operación cancelada.

**Solución**: agregar `__dealloc__` a `_ReadResult`:

```cython
cdef class _ReadResult:
    cdef FSReadContext* ctx
    cdef Py_ssize_t bytes_read

    def __dealloc__(self):
        if self.ctx != NULL:
            if self.ctx.buffer_mem != NULL:
                free(self.ctx.buffer_mem)
            if self.ctx.bufs != NULL:
                free(self.ctx.bufs)
            if self.ctx.future != NULL:
                Py_DECREF(<object>self.ctx.future)
            free(self.ctx)
            self.ctx = NULL
```

Y en `_process_read_result`, después de extraer los datos, setear `wrapper.ctx = NULL` para evitar doble-free.

### 6. `cb_write`: leak de `ctx` y ordering de DECREF

```cython
try:
    if err < 0:
        future.set_exception(OSError(err))
    else:
        future.set_result(err)

    if ctx._refs != NULL:
        Py_DECREF(<object> ctx._refs)
finally:
    uv.uv_fs_req_cleanup(req)
    free(req)
    Py_DECREF(future)
```

**Problemas**:
1. **Falta `free(ctx)`** — leak de `sizeof(FSWriteContext)` por cada write.
2. Si `set_result`/`set_exception` lanza (future cancelado → `InvalidStateError`), el `Py_DECREF(refs)` se salta en el path de error.
3. El `Py_DECREF(refs)` debería estar en el `finally`.

**Fix**:
```cython
try:
    if err < 0:
        future.set_exception(OSError(-err, uv.uv_strerror(err)))
    else:
        future.set_result(err)
finally:
    if ctx._refs != NULL:
        Py_DECREF(<object>ctx._refs)
    uv.uv_fs_req_cleanup(req)
    free(req)
    free(ctx)
    Py_DECREF(future)
```

### 7. `cb_stat` no hace `free(ctx)` — leak confirmado

```cython
cdef void cb_stat(uv.uv_fs_t* req) noexcept with gil:
    cdef FSOpenContext* ctx = <FSOpenContext*>req.data
    ...
    finally:
        uv.uv_fs_req_cleanup(req)
        free(req)
        Py_DECREF(future)
        # ← FALTA free(ctx)
```

Leak de `sizeof(FSOpenContext)` por cada `stat()`. Como `stat` se llama en cada `open()` de archivo readable, **cada apertura de archivo leakea**.

### 8. `truncate` no ajusta offset

```cython
async def truncate(self, int64_t length=0):
    await self.io_op.truncate_file(length)
    if self.file_mode.readable:
        self.size = length
    return 0
```

Si `self.offset > length` después del truncate, el offset queda apuntando más allá del final del archivo. Siguiente read retornaría 0 bytes (EOF) sin indicar error claro.

**Fix**:
```cython
async def truncate(self, int64_t length=0):
    await self.io_op.truncate_file(length)
    if self.file_mode.readable:
        self.size = length
    if self.offset > length:
        self.offset = length
    return 0
```

### 9. `text_file.read()` rompe con multibyte UTF-8

```python
data = await self._read_internal(total_to_read)
return data.decode("utf-8")
```

Si `total_to_read` (en bytes) corta un code-point multibyte (ej: emoji de 4 bytes, carácter CJK de 3 bytes) → `UnicodeDecodeError`. El iterador (`BaseFileIterator`) también sufre porque llama `self.file.read(chunk_size)` con tamaño fijo en bytes.

**Solución**: `codecs.getincrementaldecoder("utf-8")` que conserva el remanente entre lecturas. Alternativa más simple para `read(n)`: si el decode falla, leer 1-3 bytes adicionales hasta completar el code point:

```cython
async def read(self, int length=-1):
    cdef Py_ssize_t total_to_read = length if length >= 0 else self.size - self.offset
    if total_to_read <= 0:
        return ""

    data = await self._read_internal(total_to_read)
    if self.offset >= 0:
        self.offset += len(data)

    # Handle incomplete multibyte at boundary
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        # Read up to 3 more bytes to complete the code point
        for extra in range(1, 4):
            extra_data = await self._read_internal(extra)
            if not extra_data:
                break
            data += extra_data
            self.offset += len(extra_data)
            try:
                return data.decode("utf-8")
            except UnicodeDecodeError:
                continue
        raise  # Still broken after 3 extra bytes
```

### 10. `__aexit__` no protege `pump.stop()` si `close_file()` falla

```cython
async def __aexit__(self, exc_type, exc_val, exc_tb):
    if self.fd >= 0:
        await self.io_op.close_file()
    await self.pump.stop()
```

Si `close_file()` lanza excepción, `pump.stop()` nunca se ejecuta → task zombie del pump queda corriendo indefinidamente.

**Fix**:
```cython
async def __aexit__(self, exc_type, exc_val, exc_tb):
    try:
        if self.fd >= 0:
            await self.io_op.close_file()
    finally:
        await self.pump.stop()
```

### 11. `new_future` hace `Py_INCREF` extra — posible leak de futures

```cython
cdef object new_future(object loop):
    cdef object future = Future(loop=loop)
    Py_INCREF(future)   # refcount = 2 (1 por variable local + 1 manual)
    return future
```

El caller guarda el future en una variable Python (refcount +1 por asignación). Luego `_create_fs_open_context` hace otro `Py_INCREF` al guardarlo en `ctx.future`. El callback hace 1 `Py_DECREF`. Cuando el caller pierde su referencia, queda **1 referencia extra** del `Py_INCREF` en `new_future` que nunca se libera.

**Análisis de refcount**:
1. `new_future` crea future (refcount=1), hace INCREF (refcount=2), retorna
2. Caller asigna a variable `future` (refcount sigue en 2, es la misma referencia)
3. `_create_fs_open_context` hace INCREF para `ctx.future` (refcount=3)
4. Callback hace DECREF (refcount=2)
5. Caller pierde referencia (refcount=1)
6. **Queda 1 referencia huérfana → leak**

**Fix**: `new_future` NO debería hacer `Py_INCREF`. El INCREF es responsabilidad de quien almacena en `PyObject*`:

```cython
cdef object new_future(object loop):
    return Future(loop=loop)  # refcount=1, normal
```

---

## 🟠 Performance

### 12. Zero-copy read: evitar `memcpy` en lecturas

Hoy, para `total <= buffer_size` se usa `nbufs=1`, pero se hace `malloc(total)` para el buffer y luego `PyBytes_FromStringAndSize(base, size)` que **copia** los datos al nuevo `bytes` object.

**Optimización**: usar el buffer interno del `bytes` como destino directo de libuv:

```cython
py_bytes = PyBytes_FromStringAndSize(NULL, total)   # bytes con buffer no-inicializado
buf.base = PyBytes_AS_STRING(py_bytes)              # libuv escribe directo aquí
buf.len  = total
# Guardar py_bytes en ctx (Py_INCREF), retornarlo tal cual → 0 copias
```

Es seguro porque el `bytes` no se expone a Python hasta después del callback. Ahorra **una copia completa del archivo** en cada `read()`. Para un archivo de 10MB, son 10MB menos de memcpy — típicamente el cuello de botella vs `aiofiles`.

**Caveat**: para multi-buffer reads (archivos grandes), se necesita un `bytearray` como destino y luego convertir a `bytes` al final, o aceptar retornar `bytearray` directamente.

### 13. Chunking: comentario dice 2MB pero el código es 256KB

```cython
chunk_size = 256 * 1024  # 2MB    ← comentario falso
```

256KB es un valor razonable. El comentario es incorrecto. Además, `max_bufs=64` está bien para macOS (IOV_MAX=1024) y Linux (IOV_MAX=1024). El valor 16 mencionado a veces para macOS es `UIO_MAXIOV` de BSDs antiguos — macOS moderno usa 1024.

**Acción**: corregir el comentario y documentar la decisión del chunk size.

### 14. `req` y `ctx` se asignan con `malloc` por cada operación

Para workloads de muchos reads pequeños (iterador línea-a-línea con chunks de 8192), son 2 `malloc` + 2 `free` por iteración, más `uv_buf_t*`, más `buffer_mem`.

**Solución**: freelist/pool por tipo:

```cython
# Module-level pool
cdef FSReadContext* _read_ctx_pool[8]
cdef int _read_ctx_pool_size = 0

cdef inline FSReadContext* acquire_read_ctx() noexcept:
    if _read_ctx_pool_size > 0:
        _read_ctx_pool_size -= 1
        return _read_ctx_pool[_read_ctx_pool_size]
    return <FSReadContext*>malloc(sizeof(FSReadContext))

cdef inline void release_read_ctx(FSReadContext* ctx) noexcept:
    if _read_ctx_pool_size < 8:
        _read_ctx_pool[_read_ctx_pool_size] = ctx
        _read_ctx_pool_size += 1
    else:
        free(ctx)
```

La constante `__PREALLOCED_BUFS = 16` ya está declarada en `file_io.pyx` pero **nunca se usa**. Aprovecharla.

### 15. `BaseFileIterator` usa `buffer += chunk` — concatenación cuadrática

```cython
self.buffer += chunk  # str/bytes inmutable → copia completa cada vez
```

Para un archivo de 100MB con líneas de 100 chars: ~1M concatenaciones, cada una copiando el buffer acumulado. Complejidad O(n²) en el peor caso.

**Fix**: usar `bytearray` con `extend`:

```cython
# En __init__:
self.buffer = bytearray() if is_binary else []

# En __anext__:
self.buffer.extend(chunk)  # O(len(chunk)) amortizado

# Para text mode, usar lista de chunks + join:
self._chunks.append(chunk)
joined = "".join(self._chunks)
```

### 16. `mode_to_posix` itera bytes con boxing

```cython
for ch in mode:   # ch es bytes de longitud 1 → boxing por cada byte
```

Iterar `bytes` en Cython produce objetos `bytes` de longitud 1 en cada paso (boxing). Mejor iterar como `char*`:

```cython
cdef Py_ssize_t i
cdef char c
for i in range(strlen(mode)):
    c = mode[i]
    if c == b'r': ...
```

**Impacto real**: despreciable. `mode_to_posix` se llama una vez por `open()` sobre strings de 1-4 caracteres. El boxing de 4 bytes es ~100ns. **No vale la pena optimizar**, pero es buen estilo Cython.

### 17. `parse_mode` con `@lru_cache` — overhead irrelevante

```python
@lru_cache(maxsize=128)
def parse_mode(mode: str) -> FileMode:
    return mode_to_posix(mode.encode())
```

El `@lru_cache` se llama una vez por `open()`, no en hot path. El overhead del dict lookup (~200ns) vs el parseo en Cython (~500ns) es irrelevante cuando `open()` implica syscalls de microsegundos. **No optimizar — dejarlo como está.**

### 18. `EventLoopPump.start` importa `create_task` dentro del método

```cython
cdef start(self):
    from asyncio import create_task
    self._pump_task = create_task(self._pump())
```

Import dinámico, pero `start()` se llama una vez por archivo. No es hot path. Moverlo al top-level es limpieza de código, no optimización de performance.

### 19. GIL en callbacks — no hay overhead real

Los callbacks `cb_*` están declarados `noexcept with gil`. Como las operaciones `uv_fs_*` con callback se ejecutan en el thread del event loop (el mismo thread de Python), el GIL ya está held. El `with gil` es requerido por la firma de Cython pero no implica un acquire real. **No hay overhead aquí.**

### 20. `BaseFile._read_internal` crea un `FileReader` por cada `read()`

```cython
cdef object _read_internal(self, int length=-1):
    cdef FileReader reader = FileReader(...)  # allocation por cada read
    result = reader.read(length)
    return result
```

`FileReader` es stateless — no guarda nada entre llamadas. Crear un `cdef class` por cada `read()` es ~200ns de overhead + GC pressure.

**Opciones**:
1. Inlinear la lógica de `FileReader.read` directamente en `BaseFile`
2. Hacer `FileReader` un atributo persistente de `BaseFile` (creado una vez en `__init__`)

### 21. Tipos: `int` para `length` limita a 2GB

```cython
async def read(self, int length=-1):
```

`int` en Cython es C `int` (32-bit signed). Para archivos >2GB, `length` overflow. Usar `Py_ssize_t` (64-bit en plataformas 64-bit) o `int64_t`.

### 22. Partial reads no manejados

`uv_fs_read` puede retornar menos bytes de los pedidos (partial read) en filesystems de red (NFS), FUSE, o bajo presión de memoria. `TextFile.read()` y `BinaryFile.read()` asumen que un solo `_read_internal` retorna todo lo pedido. Para robustez, implementar un loop de retry:

```cython
async def _read_all(self, Py_ssize_t total):
    """Read exactly `total` bytes, retrying on partial reads"""
    chunks = []
    remaining = total
    while remaining > 0:
        data = await self._read_internal(remaining)
        if not data:
            break  # EOF
        chunks.append(data)
        remaining -= len(data)
    return b"".join(chunks)
```

---

## 🟡 Orden / Diseño

### 23. `utils.pyx` está sobrecargado con código muerto

Contiene:
- `new_future` — usado ✓
- `FileMode` + `mode_to_posix` — usado ✓
- `Pump` — **DEAD CODE** con 4 `print()` de debug 😱
- `FSRequest` — **DEAD CODE** (usa un `FSContext` struct que ni existe en `context.pxd`)
- Variables globales `_started`, `pump`, `get_pump()` — **DEAD CODE**

**Acción**: eliminar `Pump`, `FSRequest`, `_started`, `pump`, `get_pump`. Opcionalmente separar en:
- `mode.pyx` ← `FileMode`, `mode_to_posix`
- `futures.pyx` ← `new_future`

### 24. Duplicación masiva en `IOOperation`

Los 4 métodos (`open_file`, `close_file`, `get_stat`, `truncate_file`) repiten el mismo patrón:
1. Crear future
2. Alloc ctx
3. Alloc req
4. Llamar uv_fs_*
5. Si error, cleanup + set_exception

**Matiz**: un helper genérico es difícil porque las firmas de `uv_fs_*` difieren (`open` toma path+flags+mode, `close` toma fd, `ftruncate` toma fd+offset). Se puede hacer un pattern "prepare + submit" pero introduce indirección. **Recomendación**: al menos extraer el error handling post-submit a un helper inline.

### 25. Tres "cleanup helpers" inconsistentes

- `_cleanup_context` en `memory_utils` — genérico
- `_cleanup_read_context` / `_cleanup_write_context` en `memory_utils` — específicos
- `__free_read_ctx` / `__free` en `callbacks.pyx` — **nunca se llaman**
- Lógica de free embebida en `_process_read_result`

**Acción**: unificar en `memory_utils` con un helper por tipo de contexto. Eliminar `__free_read_ctx` y `__free` de `callbacks.pyx` (dead code).

### 26. `get_loop` tiene código inalcanzable

```python
def get_loop(loop=None):
    try:
        return loop or asyncio.get_running_loop()
    except RuntimeError:
        new = asyncio.new_event_loop()
        asyncio.set_event_loop(new)
        return new
```

`open()` es un `@asynccontextmanager` — **siempre** hay un loop corriendo cuando se llama. El `except RuntimeError` es dead code.

**Fix**:
```python
def get_loop(loop=None):
    return loop or asyncio.get_running_loop()
```

### 27. `BaseFile.__init__` arranca el pump — task zombie si no se usa context manager

```cython
def __init__(self, ...):
    ...
    self.pump.start()  # Crea un asyncio Task
```

Si alguien construye `TextFile(...)` sin entrar al `async with`, queda un task corriendo indefinidamente. Mover `pump.start()` a `__aenter__`.

### 28. `IOOperation.fd` se setea dos veces en `__aenter__`

```cython
async def __aenter__(self):
    self.io_op.fd = self.fd        # fd = -1 (inútil)
    future = self.io_op.open_file(self.flags)
    self.fd = await future
    self.io_op.fd = self.fd        # fd = valor real
```

La primera asignación es ruido. Eliminar.

### 29. `files.pyx` solo re-exporta

```cython
from .base_file import BaseFile
from .binary_file import BinaryFile
from .text_file import TextFile
from .iterators import BaseFileIterator
__all__ = ['BaseFile', 'BinaryFile', 'TextFile', 'BaseFileIterator']
```

No hay nada Cython aquí. Podría ser `.py`. No causa daño real (el build system lo compila igual), pero es ruido conceptual.

### 30. `BufferManager.create_read_buffers` no existe — lógica duplicada

El análisis original decía "no se usa". En realidad, **nunca se implementó** para reads. Toda la lógica de buffer allocation para lectura está inline en `FileReader._read_internal`. `BufferManager` solo tiene `create_write_buffers`.

**Acción**: mover la lógica de cálculo de chunks de `FileReader._read_internal` a `BufferManager.create_read_buffers` para tener una sola fuente de verdad.

### 31. `uv_fs_stat` declarado con `char*` en vez de `const char*`

En `uv.pxd`:
```cython
int uv_fs_stat(uv_loop_t*, uv_fs_t* req, char* name_file, uv_fs_cb cb)
```

La firma real de libuv es `const char* path`. Puede causar warnings del compilador C. Corregir a `const char*`.

### 32. `BaseFileIterator` — atributos correctamente declarados

Los atributos están declarados en `iterators.pxd` como `cdef`:
```cython
cdef class BaseFileIterator:
    cdef:
        object file
        object buffer
        int chunk_size
        bint exhausted
        bint is_binary
```

**No hay problema aquí** — el punto #28 del análisis original era incorrecto.

---

## 🟢 Plan de acción priorizado

### Fase 1: Corrección (bugs y leaks) — hacer primero

| # | Cambio | Impacto | Dificultad |
|---|--------|---------|------------|
| 1 | `free(ctx)` en `cb_write`, `cb_stat` | Fix leak por cada write/stat | Trivial |
| 2 | `_ReadResult.__dealloc__` para cleanup en cancelación | Fix leak en cancel | Fácil |
| 3 | `__aexit__` con try/finally para proteger `pump.stop()` | Fix task zombie | Trivial |
| 4 | Mover `pump.start()` a `__aenter__` | Fix task zombie sin ctx mgr | Trivial |
| 5 | Fix refcount en `new_future` (quitar INCREF) | Fix future leak | Fácil |
| 6 | `OSError(-err, uv_strerror(err))` en todos los callbacks | Fix errno/mensajes | Fácil |
| 7 | DECREF de `refs` en `finally` de `cb_write` | Fix leak en cancel | Trivial |
| 8 | Ajustar offset en `truncate` | Fix offset inconsistente | Trivial |

### Fase 2: Performance crítica — mayor impacto en benchmarks

| # | Cambio | Impacto | Dificultad |
|---|--------|---------|------------|
| 9 | `uv_backend_fd` + `add_reader` (matar busy loop) | **Huge**: -90% CPU idle | Media |
| 10 | Singleton `EventLoopPump` por asyncio loop | Corrección + perf multi-file | Media |
| 11 | Zero-copy read (`PyBytes_FromStringAndSize(NULL, n)`) | **Big**: -1 memcpy por read | Fácil |
| 12 | `bytearray` en `BaseFileIterator` | Fix O(n²) → O(n) en iteración | Fácil |
| 13 | `FileReader` como atributo persistente (no crear por read) | -200ns/read + menos GC | Fácil |

### Fase 3: Robustez y correctitud funcional

| # | Cambio | Impacto | Dificultad |
|---|--------|---------|------------|
| 14 | `IncrementalDecoder` en `TextFile` | Fix UTF-8 multibyte | Media |
| 15 | Retry loop para partial reads | Robustez en NFS/FUSE | Fácil |
| 16 | `Py_ssize_t` para `length` (soportar >2GB) | Fix overflow | Trivial |
| 17 | `path.encode("utf-8")` defensivo | Robustez lifetime | Trivial |

### Fase 4: Limpieza y orden

| # | Cambio | Impacto | Dificultad |
|---|--------|---------|------------|
| 18 | Eliminar dead code (`Pump`, `FSRequest`, `__free*`, globals) | Orden | Trivial |
| 19 | Unificar cleanup helpers en `memory_utils` | Mantenibilidad | Fácil |
| 20 | Mover buffer logic a `BufferManager.create_read_buffers` | Single source of truth | Fácil |
| 21 | Corregir `const char*` en `uv.pxd` | Warnings compilador | Trivial |
| 22 | Eliminar primera asignación de `io_op.fd` en `__aenter__` | Ruido | Trivial |
| 23 | Simplificar `get_loop` (quitar dead code) | Orden | Trivial |

### Fase 5: Optimización avanzada (si los benchmarks lo justifican)

| # | Cambio | Impacto | Dificultad |
|---|--------|---------|------------|
| 24 | Pool/freelist de `ctx`/`req` | Perf en muchos reads pequeños | Media |
| 25 | Detectar `IOV_MAX` con `sysconf` | Óptimo en Linux | Fácil |
| 26 | Iterar `mode` como `char*` en `mode_to_posix` | Estilo (impacto ~0) | Trivial |

---

## Resumen ejecutivo

**Estado actual**: la librería funciona para el happy path pero tiene **memory leaks confirmados** en cada operación (write, stat), un **busy loop** que consume 100% CPU, y **race conditions** cuando se abren múltiples archivos. El diseño por capas es bueno y la separación de responsabilidades es clara — los problemas son de implementación, no de arquitectura.

**Recomendación de orden de ataque**:

1. **Fase 1 primero** (leaks y crashes) — son fixes triviales de 1-2 líneas cada uno. Hacerlos todos en un solo commit.
2. **Fase 2 después** — el `uv_backend_fd` integration es el cambio que más mueve la aguja en benchmarks y en la percepción de "real async". El singleton de pump es prerequisito para corrección en uso concurrente.
3. **Fase 3** — el `IncrementalDecoder` es el más importante aquí; los demás son edge cases.
4. **Fase 4-5** — limpieza y micro-optimizaciones, hacer cuando haya tiempo.

**Impacto estimado en benchmarks** (post Fase 1+2):
- CPU idle: 100% → ~0% (backend_fd)
- Read throughput: +30-50% (zero-copy)
- Multi-file: de "broken" a "correcto" (singleton pump)
- Iteración línea-a-línea: +2-5x para archivos grandes (bytearray)

---

*Última actualización: 2025-06-01 — Revisión con validación contra código fuente*
