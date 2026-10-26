# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv


# Singleton registry: one pump per asyncio event loop
cdef dict _pump_registry = {}


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
    cdef:
        object loop_id = id(asyncio_loop)
        EventLoopPump pump

    if loop_id in _pump_registry:
        pump = <EventLoopPump>_pump_registry[loop_id]
        pump.acquire()
        return pump

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
        self._backend_fd = -1
        self._running = False
        self._primed = False
        self._ref_count = 0

    @staticmethod
    cdef EventLoopPump create(uv.uv_loop_t* uv_loop, object asyncio_loop):
        cdef EventLoopPump pump = EventLoopPump.__new__(EventLoopPump)
        pump.uv_loop = uv_loop
        pump._asyncio_loop = asyncio_loop
        pump._backend_fd = uv.uv_backend_fd(uv_loop)
        pump._running = False
        pump._ref_count = 0
        return pump

    cdef inline int run_nowait(self) noexcept nogil:
        return uv.uv_run(self.uv_loop, uv.UV_RUN_NOWAIT)

    cdef inline void prime(self) noexcept:
        """Run one libuv iteration after the first request is submitted.

        libuv registers its internal async handle (the threadpool completion
        signal) with the backend fd lazily, inside the first uv_run() that
        sees an active request. On Linux the epoll fd stays silent until that
        happens, so add_reader() would never fire and the first operation
        would hang forever.
        """
        if not self._primed:
            self._primed = True
            self.run_nowait()

    cdef acquire(self):
        self._ref_count += 1

    cdef bint release(self):
        self._ref_count -= 1
        return self._ref_count <= 0

    cdef start(self):
        """Start the pump — registers with asyncio via add_reader."""
        if self._running:
            return
        self._running = True

        if self._backend_fd >= 0:
            try:
                self._asyncio_loop.add_reader(self._backend_fd, self._on_event)
            except (ValueError, OSError, NotImplementedError):
                # Fallback to call_soon polling if add_reader fails
                self._asyncio_loop.call_soon(self._tick)
        else:
            self._asyncio_loop.call_soon(self._tick)

    def _on_event(self):
        """Called by asyncio when libuv's backend fd is readable (completions ready)."""
        if not self._running:
            return
        self.run_nowait()

    def _tick(self):
        """Fallback polling for when add_reader is not available."""
        if not self._running:
            return
        self.run_nowait()
        if self._running:
            self._asyncio_loop.call_soon(self._tick)

    cdef _stop(self):
        """Stop the pump."""
        if not self._running:
            return
        self._running = False

        if self._backend_fd >= 0:
            try:
                self._asyncio_loop.remove_reader(self._backend_fd)
            except (ValueError, OSError):
                pass

    async def stop(self):
        """Async stop — kept for API compat."""
        pass
