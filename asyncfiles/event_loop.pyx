# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from asyncio import sleep


cdef class EventLoopPump:
    def __cinit__(self):
        self.uv_loop = NULL
        self._pump_task = None

    @staticmethod
    cdef EventLoopPump create(uv.uv_loop_t* uv_loop):
        cdef EventLoopPump pump = EventLoopPump.__new__(EventLoopPump)
        pump.uv_loop = uv_loop
        pump._pump_task = None
        return pump

    cdef inline int run_nowait(self) noexcept nogil:
        return uv.uv_run(self.uv_loop, uv.UV_RUN_NOWAIT)

    cdef start(self):
        from asyncio import create_task
        self._pump_task = create_task(self._pump())

    async def _pump(self):
        cdef int err
        while True:
            err = self.run_nowait()
            if err < 0:
                raise OSError(-err, "uv_run failed")
            await sleep(0)

    async def stop(self):
        if self._pump_task is not None and not self._pump_task.done():
            self._pump_task.cancel()
            try:
                await self._pump_task
            except:
                pass
