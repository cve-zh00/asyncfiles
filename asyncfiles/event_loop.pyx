# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

cimport cython
from . cimport uv
import weakref

cdef extern from * nogil:
    """
    #if defined(__GLIBC__)
    #include <malloc.h>
    static inline void _asyncfiles_tune_glibc_malloc(void) {
        static int _tuned = 0;
        if (!_tuned) {
            _tuned = 1;
            mallopt(M_TRIM_THRESHOLD, 64 * 1024 * 1024);
            mallopt(M_MMAP_THRESHOLD, 32 * 1024 * 1024);
        }
    }
    #else
    static inline void _asyncfiles_tune_glibc_malloc(void) {}
    #endif
    """
    void _asyncfiles_tune_glibc_malloc() noexcept nogil


# Singleton registry: one pump per asyncio event loop
cdef dict _pump_registry = {}
# Persistent reader registration per asyncio loop (avoids add_reader/remove_reader per file)
cdef dict _registered_loops = {}
cdef uv.uv_loop_t* _default_uv_loop = NULL
cdef bint _default_uv_loop_primed = False


def _on_default_uv_event():
    """Module-level reader callback for default uv_loop (holds no EventLoopPump ref)."""
    if _default_uv_loop != NULL:
        uv.uv_run(_default_uv_loop, uv.UV_RUN_NOWAIT)


cpdef EventLoopPump get_shared_pump(object asyncio_loop):
    """
    Get or create the shared EventLoopPump for the given asyncio loop.
    All files opened on the same asyncio loop share one pump instance.
    Uses the uv_loop from the first caller (all callers should use the same one).
    """
    cdef:
        object loop_id = id(asyncio_loop)
        EventLoopPump pump

    if loop_id in _pump_registry:
        pump = <EventLoopPump>_pump_registry[loop_id]
        pump.acquire()
        return pump

    # This should not be called without a uv_loop - use _get_or_create_pump instead
    return None


cdef EventLoopPump _get_or_create_pump(object asyncio_loop, uv.uv_loop_t* uv_loop):
    """Internal: get or create pump with explicit uv_loop pointer."""
    global _default_uv_loop
    cdef:
        object loop_id = id(asyncio_loop)
        EventLoopPump pump

    if loop_id in _pump_registry:
        pump = <EventLoopPump>_pump_registry[loop_id]
        pump.acquire()
        return pump

    if uv_loop == NULL:
        if _default_uv_loop == NULL:
            _asyncfiles_tune_glibc_malloc()
            _default_uv_loop = uv.uv_default_loop()
        uv_loop = _default_uv_loop
    pump = EventLoopPump.create(uv_loop, asyncio_loop)
    pump.acquire()
    pump.start()
    _pump_registry[loop_id] = pump
    return pump


cpdef release_shared_pump(object asyncio_loop):
    """
    Release a reference to the shared pump. When ref_count hits 0,
    the pump is stopped and removed from the registry.
    """
    cdef:
        object loop_id = id(asyncio_loop)
        EventLoopPump pump

    if loop_id not in _pump_registry:
        return

    pump = <EventLoopPump>_pump_registry[loop_id]
    if pump.release():
        pump._stop()
        del _pump_registry[loop_id]


@cython.freelist(8)
cdef class EventLoopPump:
    """
    Bridges libuv's event loop with asyncio's event loop.

    Strategy: call_soon-based ticking.
    
    Why not uv_backend_fd + add_reader?
    ------------------------------------
    libuv filesystem operations use a threadpool. The threadpool signals
    completion via an internal uv_async_t handle, which makes the backend fd
    readable. However, this only works if uv_run() is called to process the
    signal — creating a chicken-and-egg problem. uvloop solves this by
    REPLACING asyncio's event loop entirely (calling uv_run directly in
    _run_once). Since we embed libuv INTO asyncio, we use call_soon instead.
    
    Why call_soon is better than the old await sleep(0):
    ----------------------------------------------------
    1. No Task/Future allocation per tick (~200ns saved per iteration)
    2. No coroutine frame overhead (direct C function call)
    3. Singleton: one pump for ALL files vs one per file
    4. Stops immediately when _running=False (no zombie tasks)
    
    The pump ticks once per asyncio event loop iteration while active.
    When all files are closed (ref_count=0), it stops with zero residual cost.
    """

    def __cinit__(self):
        self.uv_loop = NULL
        self._asyncio_loop = None
        self._tick_handle = None
        self._backend_fd = -1
        self._running = False
        self._primed = False
        self._ref_count = 0

    @staticmethod
    cdef EventLoopPump create(uv.uv_loop_t* uv_loop, object asyncio_loop):
        cdef EventLoopPump pump = EventLoopPump.__new__(EventLoopPump)
        pump.uv_loop = uv_loop
        pump._asyncio_loop = asyncio_loop
        pump._tick_handle = None
        pump._backend_fd = uv.uv_backend_fd(uv_loop)
        pump._running = False
        pump._ref_count = 0
        return pump

    cdef void _prime_slow(self) noexcept:
        """Ensure the libuv loop is primed (Unix) or polling is active (fallback)."""
        global _default_uv_loop_primed
        cdef int rc
        if not self._primed:
            self._primed = True
            rc = self.run_nowait()
            if self.uv_loop == _default_uv_loop and self._backend_fd >= 0:
                _default_uv_loop_primed = True
            if (
                rc != 0
                and self._backend_fd < 0
                and self._tick_handle is None
                and self._running
            ):
                self._tick_handle = self._asyncio_loop.call_soon(self._tick)
        elif self._backend_fd < 0 and self._tick_handle is None and self._running:
            if self.run_nowait() != 0 and self._running:
                self._tick_handle = self._asyncio_loop.call_soon(self._tick)

    cdef acquire(self):
        self._ref_count += 1

    cdef bint release(self):
        self._ref_count -= 1
        return self._ref_count <= 0

    cdef start(self):
        """Start the pump — registers with asyncio via add_reader."""
        cdef object loop_id
        cdef object loop_ref
        if self._running:
            return
        self._running = True

        if self._backend_fd >= 0:
            if self.uv_loop == _default_uv_loop and _default_uv_loop != NULL:
                loop_id = id(self._asyncio_loop)
                loop_ref = _registered_loops.get(loop_id)
                if loop_ref is not None and loop_ref() is self._asyncio_loop:
                    self._primed = _default_uv_loop_primed
                    return
                try:
                    self._asyncio_loop.add_reader(
                        self._backend_fd, _on_default_uv_event
                    )
                    _registered_loops[loop_id] = weakref.ref(self._asyncio_loop)
                    self._primed = _default_uv_loop_primed
                    return
                except (ValueError, OSError, NotImplementedError, TypeError):
                    self._backend_fd = -1
            else:
                try:
                    self._asyncio_loop.add_reader(self._backend_fd, self._on_event)
                    return
                except (ValueError, OSError, NotImplementedError):
                    self._backend_fd = -1

        if self.run_nowait() != 0 and self._running:
            self._tick_handle = self._asyncio_loop.call_soon(self._tick)

    def _on_event(self):
        """Called by asyncio when libuv's backend fd is readable (completions ready)."""
        if not self._running:
            return
        self.run_nowait()

    def _tick(self):
        """Fallback polling for when add_reader is not available."""
        self._tick_handle = None
        if not self._running:
            return
        if self.run_nowait() != 0 and self._running:
            self._tick_handle = self._asyncio_loop.call_soon(self._tick)

    cdef _stop(self):
        """Stop the pump."""
        if not self._running:
            return
        self._running = False

        if self._tick_handle is not None:
            self._tick_handle.cancel()
            self._tick_handle = None

        if self._backend_fd >= 0 and self.uv_loop != _default_uv_loop:
            try:
                self._asyncio_loop.remove_reader(self._backend_fd)
            except (ValueError, OSError, NotImplementedError):
                pass

    async def stop(self):
        """Async stop — kept for API compat."""
        pass
