# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .uring cimport *
from libc.stdint cimport uint64_t, int32_t, uintptr_t
from libc.string cimport memset
from libc.stdlib cimport free
from cpython.ref cimport Py_INCREF, Py_DECREF
from cpython.long cimport PyLong_FromVoidPtr, PyLong_AsVoidPtr
import os

cdef extern from "sys/eventfd.h" nogil:
    int eventfd(unsigned int initval, int flags)
    int EFD_NONBLOCK
    int EFD_CLOEXEC

cdef extern from "unistd.h" nogil:
    int close(int fd)
    ssize_t read(int fd, void* buf, size_t count)

# Singleton registry: one IOUringPump per asyncio event loop
cdef dict _uring_pump_registry = {}


def _probe_io_uring():
    """Probe whether io_uring_queue_init succeeds. Returns True/False."""
    cdef io_uring ring
    cdef int ret = io_uring_queue_init(4, &ring, 0)
    if ret < 0:
        return False
    io_uring_queue_exit(&ring)
    return True


def get_or_create_uring_pump(asyncio_loop):
    """Python-accessible wrapper for _get_or_create_uring_pump."""
    return _get_or_create_uring_pump(asyncio_loop)


cdef IOUringPump _get_or_create_uring_pump(object asyncio_loop):
    cdef:
        object loop_id = id(asyncio_loop)
        IOUringPump pump

    if loop_id in _uring_pump_registry:
        pump = <IOUringPump>_uring_pump_registry[loop_id]
        pump.acquire()
        return pump

    pump = IOUringPump.create(asyncio_loop, 256)
    pump.acquire()
    pump.start()
    _uring_pump_registry[loop_id] = pump
    return pump


cpdef release_uring_pump(object asyncio_loop):
    cdef:
        object loop_id = id(asyncio_loop)
        IOUringPump pump

    if loop_id not in _uring_pump_registry:
        return

    pump = <IOUringPump>_uring_pump_registry[loop_id]
    if pump.release():
        pump._stop()
        del _uring_pump_registry[loop_id]


cdef class IOUringPump:

    def __cinit__(self):
        self.eventfd = -1
        self._ref_count = 0
        self._running = False
        self._asyncio_loop = None
        self._pending_futures = {}
        self._submit_scheduled = False
        self._next_ud = 1

    @staticmethod
    cdef IOUringPump create(object asyncio_loop, unsigned int queue_depth):
        cdef IOUringPump pump = IOUringPump.__new__(IOUringPump)
        cdef int ret

        pump._asyncio_loop = asyncio_loop
        pump._pending_futures = {}
        pump._ref_count = 0
        pump._running = False
        pump._submit_scheduled = False
        pump._next_ud = 1

        # Initialize io_uring
        ret = io_uring_queue_init(queue_depth, &pump.ring, 0)
        if ret < 0:
            raise OSError(-ret, "io_uring_queue_init failed")

        # Create eventfd for completion notification
        pump.eventfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC)
        if pump.eventfd < 0:
            io_uring_queue_exit(&pump.ring)
            raise OSError("Failed to create eventfd")

        # Register eventfd with io_uring
        ret = io_uring_register_eventfd(&pump.ring, pump.eventfd)
        if ret < 0:
            close(pump.eventfd)
            io_uring_queue_exit(&pump.ring)
            raise OSError(-ret, "io_uring_register_eventfd failed")

        return pump

    cdef uint64_t alloc_user_data(self) noexcept:
        """Per-instance user_data allocation. No global state."""
        cdef uint64_t ud = self._next_ud
        self._next_ud += 1
        return ud

    cdef acquire(self):
        self._ref_count += 1

    cdef bint release(self):
        self._ref_count -= 1
        return self._ref_count <= 0

    cdef start(self):
        """Register eventfd with asyncio's event loop via add_reader."""
        if self._running:
            return
        self._running = True
        self._asyncio_loop.add_reader(self.eventfd, self._on_event)

    cdef schedule_submit(self):
        """Schedule a deferred io_uring_submit at the end of the current tick.
        
        Multiple SQEs prepared in the same tick are batched into ONE syscall.
        This is the key optimization: N operations = 1 io_uring_enter syscall.
        """
        if not self._submit_scheduled:
            self._submit_scheduled = True
            self._asyncio_loop.call_soon(self._flush)

    def _flush(self):
        """Flush all pending SQEs with a single io_uring_submit syscall."""
        self._submit_scheduled = False
        # Opportunistic drain: reap any completions before submitting new ones
        self._reap_completions()
        # Single syscall for ALL SQEs accumulated this tick
        cdef int ret = io_uring_submit(&self.ring)
        if ret < 0:
            # Submit failed - this shouldn't happen normally
            pass

    def _on_event(self):
        """Called by asyncio when eventfd is readable (CQEs available)."""
        cdef uint64_t val
        # Drain the eventfd counter
        read(self.eventfd, &val, sizeof(val))
        self._reap_completions()

    cdef _reap_completions(self):
        """Reap all available CQEs and resolve corresponding Futures.
        
        Also called opportunistically before submit (drain before flush pattern).
        """
        cdef:
            io_uring_cqe* cqe
            int ret
            uint64_t user_data
            int32_t res
            object future
            object entry
            void* stx_ptr

        while True:
            ret = io_uring_peek_cqe(&self.ring, &cqe)
            if ret < 0:
                break  # No more CQEs

            user_data = cqe.user_data
            res = cqe.res
            io_uring_cqe_seen(&self.ring, cqe)

            # Look up and resolve the Future
            entry = self._pending_futures.pop(user_data, None)
            if entry is None:
                continue

            # Handle statx case: entry is (future, stx_ptr_as_PyLong)
            if isinstance(entry, tuple):
                future = entry[0]
                stx_ptr = PyLong_AsVoidPtr(entry[1])
                if res < 0:
                    free(stx_ptr)
                    if not future.cancelled():
                        future.set_exception(OSError(-res, "io_uring operation failed"))
                else:
                    # Resolve with file size from statx buffer
                    if not future.cancelled():
                        future.set_result((<statx*>stx_ptr).stx_size)
                    free(stx_ptr)
            else:
                future = entry
                if not future.cancelled():
                    if res < 0:
                        future.set_exception(OSError(-res, "io_uring operation failed"))
                    else:
                        future.set_result(res)

    cdef object submit_sqe(self, object future, uint64_t user_data):
        """Register future and schedule a deferred submit.
        
        Does NOT call io_uring_submit immediately. Instead, schedules
        a flush at the end of the current event loop tick. Multiple
        SQEs prepared in the same tick share a single syscall.
        """
        self._pending_futures[user_data] = future
        self.schedule_submit()
        return future

    cdef _stop(self):
        """Unregister eventfd and clean up io_uring resources."""
        if not self._running:
            return
        self._running = False

        try:
            self._asyncio_loop.remove_reader(self.eventfd)
        except (ValueError, OSError):
            pass

        close(self.eventfd)
        self.eventfd = -1
        io_uring_queue_exit(&self.ring)

    def __dealloc__(self):
        if self.eventfd >= 0:
            close(self.eventfd)
