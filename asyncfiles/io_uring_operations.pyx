# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from .uring cimport *
from .io_uring_pump cimport IOUringPump
from .utils cimport _PinnedBuffer, ASYNCFILES_PYPY
from libc.stdint cimport int64_t, uint64_t, uintptr_t
from libc.stdlib cimport malloc, free
from libc.string cimport memset
from cpython.bytes cimport (
    PyBytes_CheckExact,
    PyBytes_FromStringAndSize,
    PyBytes_AS_STRING,
    PyBytes_GET_SIZE,
)
from cpython.ref cimport Py_INCREF, Py_DECREF
from cpython.long cimport PyLong_FromVoidPtr, PyLong_AsVoidPtr
from cpython.unicode cimport PyUnicode_Check, PyUnicode_AsUTF8, PyUnicode_AsUTF8AndSize
cimport cython
import asyncio
import os

DEF PARALLEL_THRESHOLD = 4 * 1024 * 1024


cdef inline object _new_future(object loop):
    return loop.create_future()


def create_io_uring_operation(object loop, IOUringPump pump, int fd, str path):
    """Python-accessible factory for IOUringOperation."""
    return IOUringOperation.create_from_path(loop, pump, fd, path)


@cython.freelist(8)
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

    def py_open_and_stat(self, int flags):
        return self.open_and_stat(flags)

    def py_close_file(self):
        return self.close_file()

    def py_get_stat(self):
        return self.get_stat()

    def py_truncate_file(self, int64_t length):
        return self.truncate_file(length)

    def py_submit_read_bytes(self, Py_ssize_t length, int64_t offset, int64_t size):
        return self.submit_read_bytes(length, offset, size)

    def py_submit_readinto(self, object pinned, Py_ssize_t total, int64_t offset):
        return self.submit_readinto(pinned, total, offset)

    def py_submit_write_data(self, object bdata, int64_t offset):
        return self.submit_write_data(bdata, offset)

    cdef object open_file(self, int flags):
        """Submit IORING_OP_OPENAT SQE. Returns Future resolving to fd."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_openat(sqe, -100, self.path_cstr, flags, 0o644)  # AT_FDCWD = -100
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)

    cdef tuple open_and_stat(self, int flags):
        """Submit OPENAT linked to STATX(path) in one submission.

        Returns (open_future, stat_future). The stat runs only after the open
        succeeds (IOSQE_IO_LINK), so it sees the file as created/truncated.
        """
        cdef:
            object open_future = _new_future(self.loop)
            object stat_future = _new_future(self.loop)
            io_uring_sqe* sqe_open
            io_uring_sqe* sqe_stat
            uint64_t ud_open = self.pump.alloc_user_data()
            uint64_t ud_stat = self.pump.alloc_user_data()
            statx* stx

        stx = <statx*>malloc(sizeof(statx))
        if stx == NULL:
            raise MemoryError()
        memset(stx, 0, sizeof(statx))

        sqe_open = self.pump.get_sqe()
        sqe_stat = self.pump.get_sqe() if sqe_open != NULL else NULL
        if sqe_open == NULL or sqe_stat == NULL:
            free(stx)
            if sqe_open != NULL:
                # Neutralise the already-prepared slot
                io_uring_prep_nop(sqe_open)
                sqe_open.user_data = 0
            open_future.set_exception(OSError(11, "SQ ring full"))
            stat_future.set_exception(OSError(11, "SQ ring full"))
            stat_future.exception()
            return open_future, stat_future

        io_uring_prep_openat(sqe_open, -100, self.path_cstr, flags, 0o644)
        sqe_open.flags |= 4  # IOSQE_IO_LINK
        sqe_open.user_data = ud_open
        io_uring_prep_statx(sqe_stat, -100, self.path_cstr, 0, 0x201, stx)
        sqe_stat.user_data = ud_stat

        self.pump._pending_futures[ud_open] = open_future
        self.pump._pending_futures[ud_stat] = (stat_future, PyLong_FromVoidPtr(stx))
        self.pump.schedule_submit()
        return open_future, stat_future

    cdef object close_file(self):
        """Submit IORING_OP_CLOSE SQE."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_close(sqe, self.fd)
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)

    cdef object read(self, char* buf, unsigned int nbytes, int64_t offset,
                     object keep=None):
        """Submit IORING_OP_READ SQE. `keep` pins the buffer until the CQE
        arrives, even if the awaiting task is cancelled."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_read(sqe, self.fd, buf, nbytes, offset)
        sqe.user_data = ud
        if keep is not None:
            self.pump._keepalive[ud] = keep
        return self.pump.submit_sqe(future, ud)

    cdef object write(self, const char* buf, unsigned int nbytes, int64_t offset,
                      object keep=None):
        """Submit IORING_OP_WRITE SQE. `keep` pins the buffer until the CQE."""
        cdef:
            object future = _new_future(self.loop)
            io_uring_sqe* sqe
            uint64_t ud = self.pump.alloc_user_data()

        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_write(sqe, self.fd, buf, nbytes, offset)
        sqe.user_data = ud
        if keep is not None:
            self.pump._keepalive[ud] = keep
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

        sqe = self.pump.get_sqe()
        if sqe == NULL:
            free(stx)
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_statx(sqe, self.fd, b"", 0x1000, 0x201, stx)  # AT_EMPTY_PATH, STATX_TYPE | STATX_SIZE
        sqe.user_data = ud

        # Store (future, stx_ptr) — use PyLong_FromVoidPtr for safe pointer storage
        self.pump._pending_futures[ud] = (future, PyLong_FromVoidPtr(stx))
        self.pump.schedule_submit()
        return future

    cdef object truncate_file(self, int64_t length):
        """Submit IORING_OP_FTRUNCATE SQE (thread fallback on kernels < 6.9)."""
        cdef:
            object future
            io_uring_sqe* sqe
            uint64_t ud

        if not self.pump.has_ftruncate:
            from .io_operations import fs_ftruncate_uv
            return asyncio.ensure_future(
                fs_ftruncate_uv(self.loop, self.fd, length), loop=self.loop
            )

        future = _new_future(self.loop)
        ud = self.pump.alloc_user_data()
        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_ftruncate(sqe, self.fd, length)
        sqe.user_data = ud
        return self.pump.submit_sqe(future, ud)

    cdef object submit_read_bytes(self, Py_ssize_t length, int64_t offset, int64_t size):
        """Fast-path zero-copy read returning a Future resolving to bytes."""
        cdef:
            Py_ssize_t total = length if length >= 0 else max(0, size - offset)
            object future
            bytes py_buf
            io_uring_sqe* sqe
            uint64_t ud

        if total <= 0:
            future = _new_future(self.loop)
            future.set_result(b"")
            return future

        if ASYNCFILES_PYPY or total >= PARALLEL_THRESHOLD:
            from .io_uring_file_io import IOUringFileReader
            return IOUringFileReader(self, None, offset, size, True).read(total)

        py_buf = PyBytes_FromStringAndSize(NULL, total)
        if py_buf is None:
            raise MemoryError()

        future = _new_future(self.loop)
        ud = self.pump.alloc_user_data()
        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_read(
            sqe, self.fd, PyBytes_AS_STRING(py_buf), <unsigned int>total, offset
        )
        sqe.user_data = ud
        self.pump._keepalive[ud] = py_buf
        self.pump._pending_futures[ud] = (future, py_buf)
        self.pump.schedule_submit()
        return future

    cdef object submit_readinto(self, object pinned_obj, Py_ssize_t total, int64_t offset):
        """Fast-path zero-copy readinto returning a Future resolving to int."""
        cdef:
            _PinnedBuffer pinned = <_PinnedBuffer>pinned_obj
            object future
            io_uring_sqe* sqe
            uint64_t ud

        if total <= 0:
            future = _new_future(self.loop)
            future.set_result(0)
            return future

        if total >= PARALLEL_THRESHOLD:
            from .io_uring_file_io import IOUringFileReader
            return IOUringFileReader(self, None, offset, 0, True).readinto(pinned, total)

        future = _new_future(self.loop)
        ud = self.pump.alloc_user_data()
        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_read(
            sqe, self.fd, <char*>pinned.view.buf, <unsigned int>total, offset
        )
        sqe.user_data = ud
        self.pump._keepalive[ud] = pinned
        self.pump._pending_futures[ud] = future
        self.pump.schedule_submit()
        return future

    cdef object submit_write_data(self, object bdata, int64_t offset):
        """Fast-path zero-copy write returning a Future resolving to int."""
        cdef:
            Py_ssize_t total_bytes
            const char* base
            _PinnedBuffer pinned = None
            object keep_obj
            object future
            io_uring_sqe* sqe
            uint64_t ud

        if PyBytes_CheckExact(bdata):
            total_bytes = PyBytes_GET_SIZE(bdata)
            base = PyBytes_AS_STRING(bdata)
            keep_obj = bdata
        elif PyUnicode_Check(bdata):
            base = PyUnicode_AsUTF8AndSize(bdata, &total_bytes)
            if base == NULL:
                raise RuntimeError("Failed to encode string as UTF-8")
            keep_obj = bdata
        elif isinstance(bdata, _PinnedBuffer):
            pinned = <_PinnedBuffer>bdata
            total_bytes = pinned.view.len
            base = <const char*>pinned.view.buf
            keep_obj = pinned
        else:
            pinned = _PinnedBuffer(bdata, False)
            total_bytes = pinned.view.len
            base = <const char*>pinned.view.buf
            keep_obj = pinned

        if total_bytes <= 0:
            future = _new_future(self.loop)
            future.set_result(0)
            return future

        if total_bytes >= PARALLEL_THRESHOLD:
            from .io_uring_file_io import IOUringFileWriter
            return IOUringFileWriter(self, None, offset).write(bdata)

        future = _new_future(self.loop)
        ud = self.pump.alloc_user_data()
        sqe = self.pump.get_sqe()
        if sqe == NULL:
            future.set_exception(OSError(11, "SQ ring full"))
            return future

        io_uring_prep_write(
            sqe, self.fd, base, <unsigned int>total_bytes, offset
        )
        sqe.user_data = ud
        self.pump._keepalive[ud] = keep_obj
        self.pump._pending_futures[ud] = future
        self.pump.schedule_submit()
        return future


def uring_stat_query(object loop, IOUringPump pump, bytes path_bytes,
                     int flags, unsigned int mask, int query_kind):
    """Submit IORING_OP_STATX for path_bytes with custom flags/mask/query_kind."""
    cdef:
        object future = _new_future(loop)
        io_uring_sqe* sqe
        uint64_t ud = pump.alloc_user_data()
        statx* stx

    stx = <statx*>malloc(sizeof(statx))
    if stx == NULL:
        future.set_exception(MemoryError())
        return future
    memset(stx, 0, sizeof(statx))

    sqe = pump.get_sqe()
    if sqe == NULL:
        free(stx)
        future.set_exception(OSError(11, "SQ ring full"))
        return future

    io_uring_prep_statx(sqe, -100, <const char*>path_bytes, flags, mask, stx)
    sqe.user_data = ud
    pump._keepalive[ud] = path_bytes

    cdef bint idle = not pump._pending_futures and not pump._submit_scheduled
    pump._pending_futures[ud] = (future, PyLong_FromVoidPtr(stx), query_kind)
    if idle:
        io_uring_submit(&pump.ring)
        pump._reap_completions()
    else:
        pump.schedule_submit()
    return future


def uring_fstat_full(object loop, IOUringPump pump, int fd):
    """Submit IORING_OP_STATX with AT_EMPTY_PATH for an open fd."""
    cdef:
        object future = _new_future(loop)
        io_uring_sqe* sqe
        uint64_t ud = pump.alloc_user_data()
        statx* stx

    stx = <statx*>malloc(sizeof(statx))
    if stx == NULL:
        future.set_exception(MemoryError())
        return future
    memset(stx, 0, sizeof(statx))

    sqe = pump.get_sqe()
    if sqe == NULL:
        free(stx)
        future.set_exception(OSError(11, "SQ ring full"))
        return future

    # AT_EMPTY_PATH = 0x1000, STATX_BASIC_STATS = 0x07ff
    io_uring_prep_statx(sqe, fd, b"", 0x1000, 0x07FF, stx)
    sqe.user_data = ud

    cdef bint idle = not pump._pending_futures and not pump._submit_scheduled
    pump._pending_futures[ud] = (future, PyLong_FromVoidPtr(stx), 1)
    if idle:
        io_uring_submit(&pump.ring)
        pump._reap_completions()
    else:
        pump.schedule_submit()
    return future


def uring_unlinkat(object loop, IOUringPump pump, bytes path_bytes, int flags):
    """Submit IORING_OP_UNLINKAT SQE (flags=0 for unlink, 0x200 for AT_REMOVEDIR)."""
    cdef:
        object future = _new_future(loop)
        io_uring_sqe* sqe = pump.get_sqe()
        uint64_t ud = pump.alloc_user_data()

    if sqe == NULL:
        future.set_exception(OSError(11, "SQ ring full"))
        return future

    io_uring_prep_unlinkat(sqe, -100, <const char*>path_bytes, flags)
    sqe.user_data = ud
    pump._keepalive[ud] = path_bytes
    return pump.submit_sqe(future, ud)


def uring_mkdirat(object loop, IOUringPump pump, bytes path_bytes, unsigned int mode):
    """Submit IORING_OP_MKDIRAT SQE."""
    cdef:
        object future = _new_future(loop)
        io_uring_sqe* sqe = pump.get_sqe()
        uint64_t ud = pump.alloc_user_data()

    if sqe == NULL:
        future.set_exception(OSError(11, "SQ ring full"))
        return future

    io_uring_prep_mkdirat(sqe, -100, <const char*>path_bytes, mode)
    sqe.user_data = ud
    pump._keepalive[ud] = path_bytes
    return pump.submit_sqe(future, ud)


def uring_renameat(object loop, IOUringPump pump, bytes src_bytes,
                   bytes dst_bytes, unsigned int flags=0):
    """Submit IORING_OP_RENAMEAT SQE."""
    cdef:
        object future = _new_future(loop)
        io_uring_sqe* sqe = pump.get_sqe()
        uint64_t ud = pump.alloc_user_data()

    if sqe == NULL:
        future.set_exception(OSError(11, "SQ ring full"))
        return future

    io_uring_prep_renameat(sqe, -100, <const char*>src_bytes,
                           -100, <const char*>dst_bytes, flags)
    sqe.user_data = ud
    pump._keepalive[ud] = (src_bytes, dst_bytes)
    return pump.submit_sqe(future, ud)


def uring_symlinkat(object loop, IOUringPump pump, bytes target_bytes,
                    bytes linkpath_bytes):
    """Submit IORING_OP_SYMLINKAT SQE."""
    cdef:
        object future = _new_future(loop)
        io_uring_sqe* sqe = pump.get_sqe()
        uint64_t ud = pump.alloc_user_data()

    if sqe == NULL:
        future.set_exception(OSError(11, "SQ ring full"))
        return future

    io_uring_prep_symlinkat(sqe, <const char*>target_bytes,
                            -100, <const char*>linkpath_bytes)
    sqe.user_data = ud
    pump._keepalive[ud] = (target_bytes, linkpath_bytes)
    return pump.submit_sqe(future, ud)


def uring_linkat(object loop, IOUringPump pump, bytes src_bytes,
                 bytes dst_bytes, int flags):
    """Submit IORING_OP_LINKAT SQE."""
    cdef:
        object future = _new_future(loop)
        io_uring_sqe* sqe = pump.get_sqe()
        uint64_t ud = pump.alloc_user_data()

    if sqe == NULL:
        future.set_exception(OSError(11, "SQ ring full"))
        return future

    io_uring_prep_linkat(sqe, -100, <const char*>src_bytes,
                         -100, <const char*>dst_bytes, flags)
    sqe.user_data = ud
    pump._keepalive[ud] = (src_bytes, dst_bytes)
    return pump.submit_sqe(future, ud)
