# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

from . cimport uv
from .callbacks cimport (
    cb_open,
    cb_close,
    cb_stat,
    cb_ftruncate,
    cb_full_stat,
    cb_stat_exists,
    cb_stat_isfile,
    cb_stat_isdir,
    cb_stat_islink,
    cb_stat_mtime,
    cb_stat_atime,
    cb_stat_ctime,
    cb_access_bool,
    cb_ptr_bytes,
    cb_scandir_names_str,
    cb_scandir_names_bytes,
    cb_scandir_entries,
    cb_statfs,
    _uv_oserror,
)
from .cpython cimport PyObject
from .event_loop cimport EventLoopPump, _get_or_create_pump, release_shared_pump
from .utils cimport new_future
from . import backend as _backend
from libc.stdlib cimport malloc, free
from cpython.ref cimport Py_INCREF, Py_DECREF
cimport cython
import asyncio
import os

try:
    from .io_uring_pump import get_or_create_uring_pump as _get_uring_pump
    from .io_uring_pump import release_uring_pump as _release_uring_pump
    from .io_uring_operations import (
        uring_stat_query as _uring_stat_query,
        uring_fstat_full as _uring_fstat_full,
        uring_unlinkat as _uring_unlinkat,
        uring_mkdirat as _uring_mkdirat,
        uring_renameat as _uring_renameat,
        uring_symlinkat as _uring_symlinkat,
        uring_linkat as _uring_linkat,
    )
except ImportError:
    _get_uring_pump = None
    _release_uring_pump = None
    _uring_stat_query = None
    _uring_fstat_full = None
    _uring_unlinkat = None
    _uring_mkdirat = None
    _uring_renameat = None
    _uring_symlinkat = None
    _uring_linkat = None


cdef inline uv.uv_fs_t* _create_fs_request_for_future(object future) except NULL:
    cdef uv.uv_fs_t* req = <uv.uv_fs_t*>malloc(sizeof(uv.uv_fs_t))
    if req == NULL:
        raise MemoryError("Cannot allocate uv_fs_t")

    Py_INCREF(future)
    req.data = <void*><PyObject*>future
    return req


cdef inline void _abort_fs_request(uv.uv_fs_t* req, object future) noexcept:
    Py_DECREF(future)
    free(req)


@cython.freelist(8)
cdef class IOOperation:
    def __cinit__(self):
        self.loop = None
        self.uv_loop = NULL
        self.fd = -1
        self.path_cstr = NULL

    @staticmethod
    cdef IOOperation create(object loop, uv.uv_loop_t* uv_loop, int fd, const char* path_cstr):
        cdef IOOperation io_op = IOOperation.__new__(IOOperation)
        io_op.loop = loop
        io_op.uv_loop = uv_loop
        io_op.fd = fd
        io_op.path_cstr = path_cstr
        return io_op

    cdef object open_file(self, int flags):
        cdef:
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            req = _create_fs_request_for_future(future)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for open"))
            return future

        err = uv.uv_fs_open(self.uv_loop, req, self.path_cstr, flags, 0o644, cb_open)

        if err < 0:
            _abort_fs_request(req, future)
            future.set_exception(_uv_oserror(err, "uv_fs_open failed"))
            return future

        return future

    cdef object close_file(self):
        cdef:
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            req = _create_fs_request_for_future(future)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for close"))
            return future

        err = uv.uv_fs_close(self.uv_loop, req, self.fd, cb_close)

        if err < 0:
            _abort_fs_request(req, future)
            future.set_exception(_uv_oserror(err, "uv_fs_close failed"))
            return future

        return future

    cdef object get_stat(self):
        cdef:
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            req = _create_fs_request_for_future(future)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for stat"))
            return future

        err = uv.uv_fs_fstat(self.uv_loop, req, self.fd, cb_stat)

        if err < 0:
            _abort_fs_request(req, future)
            future.set_exception(_uv_oserror(err, "uv_fs_fstat failed"))
            return future

        return future

    cdef object truncate_file(self, int64_t length):
        cdef:
            uv.uv_fs_t* req
            object future = new_future(self.loop)
            int err

        try:
            req = _create_fs_request_for_future(future)
        except MemoryError:
            future.set_exception(MemoryError("Cannot allocate memory for truncate"))
            return future

        err = uv.uv_fs_ftruncate(self.uv_loop, req, self.fd, length, cb_ftruncate)

        if err < 0:
            _abort_fs_request(req, future)
            future.set_exception(_uv_oserror(err, "uv_fs_ftruncate failed"))
            return future

        return future


# ---------------------------------------------------------------------------
# Native libuv / io_uring filesystem operations for asyncfiles.os & ospath
# ---------------------------------------------------------------------------

cdef inline tuple _encode_path(object path):
    """Return (bytes encoded_path, bint input_was_bytes)."""
    cdef object fspath = os.fspath(path)
    if isinstance(fspath, bytes):
        if b"\x00" in fspath:
            raise ValueError("embedded null byte")
        return fspath, True
    if isinstance(fspath, str):
        if "\x00" in fspath:
            raise ValueError("embedded null character")
        return os.fsencode(fspath), False
    raise TypeError(f"path should be string, bytes, or os.PathLike, not {type(path).__name__}")


cdef inline object _submit_uv_path1(
    object loop,
    uv.uv_loop_t* uv_loop,
    bytes path_bytes,
    int op_kind,
    int arg_int,
    uv.uv_fs_cb cb,
):
    cdef:
        object future = new_future(loop)
        uv.uv_fs_t* req
        const char* path_cstr = <const char*>path_bytes
        int err

    try:
        req = _create_fs_request_for_future(future)
    except MemoryError as exc:
        future.set_exception(exc)
        return future

    if op_kind == 1:
        err = uv.uv_fs_stat(uv_loop, req, path_cstr, cb)
    elif op_kind == 2:
        err = uv.uv_fs_lstat(uv_loop, req, path_cstr, cb)
    elif op_kind == 3:
        err = uv.uv_fs_unlink(uv_loop, req, path_cstr, cb)
    elif op_kind == 4:
        err = uv.uv_fs_mkdir(uv_loop, req, path_cstr, arg_int, cb)
    elif op_kind == 5:
        err = uv.uv_fs_rmdir(uv_loop, req, path_cstr, cb)
    elif op_kind == 6:
        err = uv.uv_fs_readlink(uv_loop, req, path_cstr, cb)
    elif op_kind == 7:
        err = uv.uv_fs_realpath(uv_loop, req, path_cstr, cb)
    elif op_kind == 8:
        err = uv.uv_fs_access(uv_loop, req, path_cstr, arg_int, cb)
    elif op_kind == 9:
        err = uv.uv_fs_scandir(uv_loop, req, path_cstr, 0, cb)
    elif op_kind == 10:
        err = uv.uv_fs_statfs(uv_loop, req, path_cstr, cb)
    else:
        err = -22

    if err < 0:
        _abort_fs_request(req, future)
        future.set_exception(_uv_oserror(err, "uv_fs operation failed"))
    return future


cdef inline object _submit_uv_path2(
    object loop,
    uv.uv_loop_t* uv_loop,
    bytes src_bytes,
    bytes dst_bytes,
    int op_kind,
    int flags,
    uv.uv_fs_cb cb,
):
    cdef:
        object future = new_future(loop)
        uv.uv_fs_t* req
        const char* src_cstr = <const char*>src_bytes
        const char* dst_cstr = <const char*>dst_bytes
        int err

    try:
        req = _create_fs_request_for_future(future)
    except MemoryError as exc:
        future.set_exception(exc)
        return future

    if op_kind == 1:
        err = uv.uv_fs_rename(uv_loop, req, src_cstr, dst_cstr, cb)
    elif op_kind == 2:
        err = uv.uv_fs_link(uv_loop, req, src_cstr, dst_cstr, cb)
    elif op_kind == 3:
        err = uv.uv_fs_symlink(uv_loop, req, src_cstr, dst_cstr, flags, cb)
    elif op_kind == 4:
        err = uv.uv_fs_copyfile(uv_loop, req, src_cstr, dst_cstr, flags, cb)
    else:
        err = -22

    if err < 0:
        _abort_fs_request(req, future)
        future.set_exception(_uv_oserror(err, "uv_fs operation failed"))
    return future


cdef inline object _submit_uv_fd(
    object loop,
    uv.uv_loop_t* uv_loop,
    int fd,
    uv.uv_fs_cb cb,
):
    cdef:
        object future = new_future(loop)
        uv.uv_fs_t* req
        int err

    try:
        req = _create_fs_request_for_future(future)
    except MemoryError as exc:
        future.set_exception(exc)
        return future

    err = uv.uv_fs_fstat(uv_loop, req, fd, cb)
    if err < 0:
        _abort_fs_request(req, future)
        future.set_exception(_uv_oserror(err, "uv_fs_fstat failed"))
    return future


async def fs_ftruncate_uv(object loop, int fd, int64_t length):
    """Truncate open fd via libuv (also used by io_uring on kernels < 6.9)."""
    cdef EventLoopPump pump = _get_or_create_pump(loop, NULL)
    cdef IOOperation op = IOOperation.create(loop, pump.uv_loop, fd, NULL)
    try:
        await op.truncate_file(length)
    finally:
        release_shared_pump(loop)


async def fs_stat(object path, bint follow_symlinks=True, object loop=None, str backend="auto"):
    """Async stat / lstat / fstat returning os.stat_result."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump
    cdef bytes path_bytes

    if isinstance(path, int):
        if resolved == "io_uring":
            uring_pump = _get_uring_pump(loop)
            try:
                return await _uring_fstat_full(loop, uring_pump, <int>path)
            finally:
                _release_uring_pump(loop)
        uv_pump = _get_or_create_pump(loop, NULL)
        try:
            return await _submit_uv_fd(loop, uv_pump.uv_loop, <int>path, cb_full_stat)
        finally:
            release_shared_pump(loop)

    path_bytes, _ = _encode_path(path)
    if resolved == "io_uring":
        uring_pump = _get_uring_pump(loop)
        try:
            # AT_SYMLINK_NOFOLLOW = 0x100, STATX_BASIC_STATS = 0x07FF, query_kind = 1
            return await _uring_stat_query(
                loop, uring_pump, path_bytes, 0 if follow_symlinks else 0x100, 0x07FF, 1
            )
        finally:
            _release_uring_pump(loop)

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        return await _submit_uv_path1(
            loop, uv_pump.uv_loop, path_bytes, 1 if follow_symlinks else 2, 0, cb_full_stat
        )
    finally:
        release_shared_pump(loop)


async def fs_stat_query(
    object path,
    int query_kind,
    bint follow_symlinks=True,
    object loop=None,
    str backend="auto",
):
    """Lightweight stat query without constructing os.stat_result.

    query_kind:
      2 = exists / lexists (bool)
      3 = isfile (bool)
      4 = isdir (bool)
      5 = islink (bool)
      6 = getsize (int)
      7 = getmtime (float)
      8 = getatime (float)
      9 = getctime (float)
    """
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump
    cdef bytes path_bytes
    cdef unsigned int mask
    cdef uv.uv_fs_cb cb

    if isinstance(path, int) and query_kind == 2:
        uv_pump = _get_or_create_pump(loop, NULL)
        try:
            return await _submit_uv_fd(loop, uv_pump.uv_loop, <int>path, cb_stat_exists)
        finally:
            release_shared_pump(loop)

    try:
        path_bytes, _ = _encode_path(path)
    except ValueError:
        if query_kind in (2, 3, 4, 5):
            return False
        raise

    if resolved == "io_uring":
        if query_kind in (2, 3, 4, 5):
            mask = 0x0001  # STATX_TYPE
        elif query_kind == 6:
            mask = 0x0200  # STATX_SIZE
        elif query_kind == 7:
            mask = 0x0040  # STATX_MTIME
        elif query_kind == 8:
            mask = 0x0020  # STATX_ATIME
        else:
            mask = 0x0080  # STATX_CTIME
        uring_pump = _get_uring_pump(loop)
        try:
            return await _uring_stat_query(
                loop, uring_pump, path_bytes, 0 if follow_symlinks else 0x100, mask, query_kind
            )
        finally:
            _release_uring_pump(loop)

    if query_kind == 2:
        cb = cb_stat_exists
    elif query_kind == 3:
        cb = cb_stat_isfile
    elif query_kind == 4:
        cb = cb_stat_isdir
    elif query_kind == 5:
        cb = cb_stat_islink
    elif query_kind == 6:
        cb = cb_stat
    elif query_kind == 7:
        cb = cb_stat_mtime
    elif query_kind == 8:
        cb = cb_stat_atime
    else:
        cb = cb_stat_ctime

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        return await _submit_uv_path1(
            loop, uv_pump.uv_loop, path_bytes, 1 if follow_symlinks else 2, 0, cb
        )
    finally:
        release_shared_pump(loop)


async def fs_unlink(object path, object loop=None, str backend="auto"):
    """Async unlink / remove."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes path_bytes = _encode_path(path)[0]
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump

    if resolved == "io_uring":
        uring_pump = _get_uring_pump(loop)
        try:
            await _uring_unlinkat(loop, uring_pump, path_bytes, 0)
            return
        finally:
            _release_uring_pump(loop)

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        await _submit_uv_path1(loop, uv_pump.uv_loop, path_bytes, 3, 0, cb_close)
    finally:
        release_shared_pump(loop)


async def fs_mkdir(object path, int mode=0o777, object loop=None, str backend="auto"):
    """Async mkdir."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes path_bytes = _encode_path(path)[0]
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump

    if resolved == "io_uring":
        uring_pump = _get_uring_pump(loop)
        try:
            await _uring_mkdirat(loop, uring_pump, path_bytes, <unsigned int>mode)
            return
        finally:
            _release_uring_pump(loop)

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        await _submit_uv_path1(loop, uv_pump.uv_loop, path_bytes, 4, mode, cb_close)
    finally:
        release_shared_pump(loop)


async def fs_rmdir(object path, object loop=None, str backend="auto"):
    """Async rmdir."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes path_bytes = _encode_path(path)[0]
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump

    if resolved == "io_uring":
        uring_pump = _get_uring_pump(loop)
        try:
            # AT_REMOVEDIR = 0x200
            await _uring_unlinkat(loop, uring_pump, path_bytes, 0x200)
            return
        finally:
            _release_uring_pump(loop)

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        await _submit_uv_path1(loop, uv_pump.uv_loop, path_bytes, 5, 0, cb_close)
    finally:
        release_shared_pump(loop)


async def fs_rename(object src, object dst, object loop=None, str backend="auto"):
    """Async rename / replace."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes src_bytes = _encode_path(src)[0]
    cdef bytes dst_bytes = _encode_path(dst)[0]
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump

    if resolved == "io_uring":
        uring_pump = _get_uring_pump(loop)
        try:
            await _uring_renameat(loop, uring_pump, src_bytes, dst_bytes, 0)
            return
        finally:
            _release_uring_pump(loop)

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        await _submit_uv_path2(loop, uv_pump.uv_loop, src_bytes, dst_bytes, 1, 0, cb_close)
    finally:
        release_shared_pump(loop)


async def fs_link(
    object src,
    object dst,
    bint follow_symlinks=True,
    object loop=None,
    str backend="auto",
):
    """Async hard link."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes src_bytes = _encode_path(src)[0]
    cdef bytes dst_bytes = _encode_path(dst)[0]
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump

    if resolved == "io_uring":
        uring_pump = _get_uring_pump(loop)
        try:
            # AT_SYMLINK_FOLLOW = 0x400
            await _uring_linkat(
                loop, uring_pump, src_bytes, dst_bytes, 0x400 if follow_symlinks else 0
            )
            return
        finally:
            _release_uring_pump(loop)

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        await _submit_uv_path2(loop, uv_pump.uv_loop, src_bytes, dst_bytes, 2, 0, cb_close)
    finally:
        release_shared_pump(loop)


async def fs_symlink(
    object src,
    object dst,
    bint target_is_directory=False,
    object loop=None,
    str backend="auto",
):
    """Async symbolic link."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes src_bytes = _encode_path(src)[0]
    cdef bytes dst_bytes = _encode_path(dst)[0]
    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump
    cdef int flags = uv.UV_FS_SYMLINK_DIR if target_is_directory else 0

    if resolved == "io_uring":
        uring_pump = _get_uring_pump(loop)
        try:
            await _uring_symlinkat(loop, uring_pump, src_bytes, dst_bytes)
            return
        finally:
            _release_uring_pump(loop)

    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        await _submit_uv_path2(
            loop, uv_pump.uv_loop, src_bytes, dst_bytes, 3, flags, cb_close
        )
    finally:
        release_shared_pump(loop)


async def fs_readlink(object path, object loop=None):
    """Async readlink via uv_fs_readlink."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes path_bytes
    cdef bint is_bytes
    path_bytes, is_bytes = _encode_path(path)
    cdef EventLoopPump uv_pump = _get_or_create_pump(loop, NULL)
    cdef bytes raw
    try:
        raw = await _submit_uv_path1(
            loop, uv_pump.uv_loop, path_bytes, 6, 0, cb_ptr_bytes
        )
    finally:
        release_shared_pump(loop)
    return raw if is_bytes else os.fsdecode(raw)


async def fs_realpath_strict(object path, object loop=None):
    """Async canonical realpath via uv_fs_realpath (for existing paths)."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes path_bytes
    cdef bint is_bytes
    path_bytes, is_bytes = _encode_path(path)
    cdef EventLoopPump uv_pump = _get_or_create_pump(loop, NULL)
    cdef bytes raw
    try:
        raw = await _submit_uv_path1(
            loop, uv_pump.uv_loop, path_bytes, 7, 0, cb_ptr_bytes
        )
    finally:
        release_shared_pump(loop)
    return raw if is_bytes else os.fsdecode(raw)


async def fs_access(
    object path,
    int mode,
    bint follow_symlinks=True,
    object loop=None,
    str backend="auto",
):
    """Async access check via uv_fs_access (or lstat when follow_symlinks=False)."""
    if loop is None:
        loop = asyncio.get_running_loop()
    if not follow_symlinks:
        if mode == os.F_OK:
            return await fs_stat_query(path, 2, False, loop, backend)
        try:
            st = await fs_stat(path, False, loop, backend)
        except OSError:
            return False
        return True

    cdef bytes path_bytes
    try:
        path_bytes, _ = _encode_path(path)
    except ValueError:
        return False
    cdef EventLoopPump uv_pump = _get_or_create_pump(loop, NULL)
    try:
        return await _submit_uv_path1(
            loop, uv_pump.uv_loop, path_bytes, 8, mode, cb_access_bool
        )
    finally:
        release_shared_pump(loop)


async def fs_listdir(object path=".", object loop=None):
    """Async listdir via uv_fs_scandir."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes path_bytes
    cdef bint is_bytes
    if path is None:
        path = "."
    path_bytes, is_bytes = _encode_path(path)
    cdef EventLoopPump uv_pump = _get_or_create_pump(loop, NULL)
    cdef uv.uv_fs_cb cb = cb_scandir_names_bytes if is_bytes else cb_scandir_names_str
    try:
        return await _submit_uv_path1(loop, uv_pump.uv_loop, path_bytes, 9, 0, cb)
    finally:
        release_shared_pump(loop)


async def fs_scandir_raw(object path=".", object loop=None):
    """Return (raw_entries, is_bytes, base_path) from uv_fs_scandir."""
    if loop is None:
        loop = asyncio.get_running_loop()
    if path is None:
        path = "."
    cdef object fspath = os.fspath(path)
    cdef bytes path_bytes
    cdef bint is_bytes
    path_bytes, is_bytes = _encode_path(fspath)
    cdef EventLoopPump uv_pump = _get_or_create_pump(loop, NULL)
    try:
        entries = await _submit_uv_path1(
            loop, uv_pump.uv_loop, path_bytes, 9, 0, cb_scandir_entries
        )
    finally:
        release_shared_pump(loop)
    return entries, is_bytes, fspath


async def fs_truncate(object path, int64_t length, object loop=None, str backend="auto"):
    """Async truncate for a file path or open file descriptor."""
    if loop is None:
        loop = asyncio.get_running_loop()
    if length < 0:
        raise ValueError("truncate length must be non-negative")

    cdef str resolved = _backend.resolve_backend(backend)
    cdef EventLoopPump uv_pump
    cdef object uring_pump
    cdef IOOperation uv_op
    cdef int fd = -1
    cdef bytes path_bytes

    if isinstance(path, int):
        if resolved == "io_uring":
            uring_pump = _get_uring_pump(loop)
            try:
                if uring_pump.has_ftruncate:
                    from .io_uring_operations import create_io_uring_operation
                    op = create_io_uring_operation(loop, uring_pump, <int>path, "")
                    await op.py_truncate_file(length)
                    return
            finally:
                _release_uring_pump(loop)
        await fs_ftruncate_uv(loop, <int>path, length)
        return

    path_bytes, _ = _encode_path(path)
    uv_pump = _get_or_create_pump(loop, NULL)
    try:
        uv_op = IOOperation.create(loop, uv_pump.uv_loop, -1, <const char*>path_bytes)
        fd = await uv_op.open_file(os.O_WRONLY)
        uv_op.fd = fd
        try:
            await uv_op.truncate_file(length)
        finally:
            await uv_op.close_file()
    finally:
        release_shared_pump(loop)


async def fs_copyfile(object src, object dst, int flags=0, object loop=None):
    """Async file copy via uv_fs_copyfile."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes src_bytes = _encode_path(src)[0]
    cdef bytes dst_bytes = _encode_path(dst)[0]
    cdef EventLoopPump uv_pump = _get_or_create_pump(loop, NULL)
    try:
        await _submit_uv_path2(
            loop, uv_pump.uv_loop, src_bytes, dst_bytes, 4, flags, cb_close
        )
    finally:
        release_shared_pump(loop)


async def fs_statfs(object path, object loop=None):
    """Async filesystem statistics via uv_fs_statfs."""
    if loop is None:
        loop = asyncio.get_running_loop()
    cdef bytes path_bytes = _encode_path(path)[0]
    cdef EventLoopPump uv_pump = _get_or_create_pump(loop, NULL)
    try:
        return await _submit_uv_path1(
            loop, uv_pump.uv_loop, path_bytes, 10, 0, cb_statfs
        )
    finally:
        release_shared_pump(loop)
