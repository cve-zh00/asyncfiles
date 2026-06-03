# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .uring cimport *
from .io_uring_pump cimport IOUringPump
from libc.stdint cimport int64_t, uint64_t, uintptr_t
from libc.stdlib cimport malloc, free
from libc.string cimport memset
from cpython.bytes cimport PyBytes_FromStringAndSize, PyBytes_AS_STRING
from cpython.ref cimport Py_INCREF, Py_DECREF
from cpython.long cimport PyLong_FromVoidPtr, PyLong_AsVoidPtr
from cpython.unicode cimport PyUnicode_AsUTF8


cdef inline object _new_future(object loop):
    return loop.create_future()


def create_io_uring_operation(object loop, IOUringPump pump, int fd, str path):
    """Python-accessible factory for IOUringOperation."""
    return IOUringOperation.create_from_path(loop, pump, fd, path)


cdef class IOUringOperation:

    def __cinit__(self):
        self.loop = None
        self.pump = None
        self.fd = -1
        self.path_cstr = NULL
        self._path_ref = None  # Strong reference to keep path_cstr valid

    @staticmethod
    cdef IOUringOperation create(object loop, IOUringPump pump, int fd, const char* path_cstr):
        cdef IOUringOperation op = IOUringOperation.__new__(IOUringOperation)
        op.loop = loop
        op.pump = pump
        op.fd = fd
        op.path_cstr = path_cstr
        op._path_ref = None
        return op

    @staticmethod
    def create_from_path(object loop, IOUringPump pump, int fd, str path):
        """Create from Python string — stores reference to keep path_cstr alive."""
        cdef IOUringOperation op = IOUringOperation.__new__(IOUringOperation)
        op.loop = loop
        op.pump = pump
        op.fd = fd
        op._path_ref = path  # Keep strong reference to prevent GC
        op.path_cstr = PyUnicode_AsUTF8(path)
        return op

    # Python-visible wrappers for base_file.pyx
    def py_open_file(self, int flags):
        return self.open_file(flags)

    def py_close_file(self):
        return self.close_file()

    def py_get_stat(self):
        return self.get_stat()

    def py_truncate_file(self, int64_t length):
        return self.truncate_file(length)

    cdef object open_file(self, int flags):
        """Submit IORING_OP_OPENAT SQE. Returns Future resolving to fd."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = io_uring_get_sqe(&self.pump.ring)
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_openat(sqe, -100, self.path_cstr, flags, 0o644)  # AT_FDCWD = -100
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)

    cdef object close_file(self):
        """Submit IORING_OP_CLOSE SQE."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = io_uring_get_sqe(&self.pump.ring)
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_close(sqe, self.fd)
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)

    cdef object read(self, char* buf, unsigned int nbytes, int64_t offset):
        """Submit IORING_OP_READ SQE. Buffer must remain valid until CQE."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = io_uring_get_sqe(&self.pump.ring)
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_read(sqe, self.fd, buf, nbytes, offset)
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)

    cdef object write(self, const char* buf, unsigned int nbytes, int64_t offset):
        """Submit IORING_OP_WRITE SQE. Buffer must remain valid until CQE."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = io_uring_get_sqe(&self.pump.ring)
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_write(sqe, self.fd, buf, nbytes, offset)
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)

    cdef object get_stat(self):
        """Submit IORING_OP_STATX SQE. Returns Future resolving to file size."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()
            statx* stx

        # Allocate statx buffer (freed in _reap_completions)
        stx = <statx*>malloc(sizeof(statx))
        if stx == NULL:
            future.set_exception(MemoryError())
            return future
        memset(stx, 0, sizeof(statx))

        sqe = io_uring_get_sqe(&self.pump.ring)
        if sqe == NULL:
            free(stx)
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_statx(sqe, self.fd, b"", 0x1000, 0x01, stx)  # AT_EMPTY_PATH, STATX_SIZE
        sqe.user_data = ud

        # Store (future, stx_ptr) — use PyLong_FromVoidPtr for safe pointer storage
        self.pump._pending_futures[ud] = (future, PyLong_FromVoidPtr(stx))
        self.pump.schedule_submit()
        return future

    cdef object truncate_file(self, int64_t length):
        """Submit IORING_OP_FTRUNCATE SQE."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = io_uring_get_sqe(&self.pump.ring)
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_ftruncate(sqe, self.fd, length)
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)
