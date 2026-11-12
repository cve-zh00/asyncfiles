"""Native async os filesystem operations powered by libuv and io_uring."""

from __future__ import annotations

import asyncio
import errno
import os as _os
import os.path as _os_path
import stat as _stat
from typing import Generic, Iterator, TypeVar, cast

from . import ospath as path
from .io_operations import (fs_access, fs_copyfile, fs_link, fs_listdir,
                            fs_mkdir, fs_readlink, fs_rename, fs_rmdir,
                            fs_scandir_raw, fs_stat, fs_statfs, fs_symlink,
                            fs_truncate, fs_unlink)
from .types import BackendType, PathType

_AnyStr = TypeVar("_AnyStr", str, bytes)

# uv_dirent_type_t constants from libuv
_UV_DIRENT_UNKNOWN = 0
_UV_DIRENT_FILE = 1
_UV_DIRENT_DIR = 2
_UV_DIRENT_LINK = 3


class AsyncDirEntry(Generic[_AnyStr]):
    """DirEntry returned by asyncfiles.os.scandir(), backed by uv_dirent_t."""

    __slots__ = ("name", "path", "_dtype", "_stat", "_lstat")

    def __init__(self, name: _AnyStr, full_path: _AnyStr, dtype: int) -> None:
        self.name: _AnyStr = name
        self.path: _AnyStr = full_path
        self._dtype: int = dtype
        self._stat: _os.stat_result | None = None
        self._lstat: _os.stat_result | None = None

    def __fspath__(self) -> _AnyStr:
        return self.path

    def __repr__(self) -> str:
        return f"<AsyncDirEntry {self.name!r}>"

    def is_symlink(self) -> bool:
        if self._dtype != _UV_DIRENT_UNKNOWN:
            return self._dtype == _UV_DIRENT_LINK
        try:
            st = self.stat(follow_symlinks=False)
        except FileNotFoundError:
            return False
        return _stat.S_ISLNK(st.st_mode)

    def is_dir(self, *, follow_symlinks: bool = True) -> bool:
        if self._dtype != _UV_DIRENT_UNKNOWN:
            if self._dtype == _UV_DIRENT_DIR:
                return True
            if self._dtype != _UV_DIRENT_LINK or not follow_symlinks:
                return False
        try:
            st = self.stat(follow_symlinks=follow_symlinks)
        except FileNotFoundError:
            return False
        return _stat.S_ISDIR(st.st_mode)

    def is_file(self, *, follow_symlinks: bool = True) -> bool:
        if self._dtype != _UV_DIRENT_UNKNOWN:
            if self._dtype == _UV_DIRENT_FILE:
                return True
            if self._dtype != _UV_DIRENT_LINK or not follow_symlinks:
                return False
        try:
            st = self.stat(follow_symlinks=follow_symlinks)
        except FileNotFoundError:
            return False
        return _stat.S_ISREG(st.st_mode)

    def stat(self, *, follow_symlinks: bool = True) -> _os.stat_result:
        if follow_symlinks:
            if self._stat is None:
                self._stat = _os.stat(self.path, follow_symlinks=True)
            return self._stat
        if self._lstat is None:
            self._lstat = _os.stat(self.path, follow_symlinks=False)
        return self._lstat

    def inode(self) -> int:
        return self.stat(follow_symlinks=False).st_ino


class ScandirIterator(Generic[_AnyStr]):
    """Iterator and (sync + async) context manager over AsyncDirEntry items."""

    __slots__ = ("_entries", "_index")

    def __init__(self, entries: list[AsyncDirEntry[_AnyStr]]) -> None:
        self._entries: list[AsyncDirEntry[_AnyStr]] = entries
        self._index: int = 0

    def __iter__(self) -> Iterator[AsyncDirEntry[_AnyStr]]:
        return self

    def __next__(self) -> AsyncDirEntry[_AnyStr]:
        if self._index >= len(self._entries):
            raise StopIteration
        entry = self._entries[self._index]
        self._index += 1
        return entry

    def __aiter__(self) -> ScandirIterator[_AnyStr]:
        return self

    async def __anext__(self) -> AsyncDirEntry[_AnyStr]:
        try:
            return next(self)
        except StopIteration:
            raise StopAsyncIteration from None

    def close(self) -> None:
        self._index = len(self._entries)

    def __enter__(self) -> ScandirIterator[_AnyStr]:
        return self

    def __exit__(self, exc_type: object, exc_val: object, exc_tb: object) -> None:
        self.close()

    async def __aenter__(self) -> ScandirIterator[_AnyStr]:
        return self

    async def __aexit__(
        self, exc_type: object, exc_val: object, exc_tb: object
    ) -> None:
        self.close()


def _check_unsupported_dir_fd(dir_fd: int | None) -> None:
    if dir_fd is not None:
        raise NotImplementedError("dir_fd is not supported")


async def stat(
    path: PathType | int,
    *,
    dir_fd: int | None = None,
    follow_symlinks: bool = True,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> _os.stat_result:
    """Get the status of a file or file descriptor natively via libuv / io_uring."""
    _check_unsupported_dir_fd(dir_fd)
    return cast(_os.stat_result, await fs_stat(path, follow_symlinks, loop, backend))


async def lstat(
    path: PathType,
    *,
    dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> _os.stat_result:
    """Like stat(), but do not follow symbolic links."""
    _check_unsupported_dir_fd(dir_fd)
    return cast(_os.stat_result, await fs_stat(path, False, loop, backend))


async def unlink(
    path: PathType,
    *,
    dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Remove a file (same as remove())."""
    _check_unsupported_dir_fd(dir_fd)
    await fs_unlink(path, loop, backend)


async def remove(
    path: PathType,
    *,
    dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Remove a file (same as unlink())."""
    _check_unsupported_dir_fd(dir_fd)
    await fs_unlink(path, loop, backend)


async def mkdir(
    path: PathType,
    mode: int = 0o777,
    *,
    dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Create a directory named path with numeric mode mode."""
    _check_unsupported_dir_fd(dir_fd)
    await fs_mkdir(path, mode, loop, backend)


async def makedirs(
    name: PathType,
    mode: int = 0o777,
    exist_ok: bool = False,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Super-mkdir; create a leaf directory and all intermediate ones asynchronously."""
    fspath = _os.fspath(name)
    head, tail = _os_path.split(fspath)
    if not tail:
        head, tail = _os_path.split(head)
    if head and tail and not await path.exists(head, loop=loop, backend=backend):
        try:
            await makedirs(head, exist_ok=exist_ok, loop=loop, backend=backend)
        except FileExistsError:
            pass
        cdir = b"." if isinstance(tail, bytes) else "."
        if tail == cdir:
            return
    try:
        await fs_mkdir(fspath, mode, loop, backend)
    except OSError as exc:
        if (
            not exist_ok
            or exc.errno != errno.EEXIST
            or not await path.isdir(fspath, loop=loop, backend=backend)
        ):
            raise


async def rmdir(
    path: PathType,
    *,
    dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Remove (delete) the directory path."""
    _check_unsupported_dir_fd(dir_fd)
    await fs_rmdir(path, loop, backend)


async def removedirs(
    name: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Super-rmdir; remove a leaf directory and all empty intermediate ones."""
    await fs_rmdir(name, loop, backend)
    head, tail = _os_path.split(_os.fspath(name))
    if not tail:
        head, tail = _os_path.split(head)
    while head and tail:
        try:
            await fs_rmdir(head, loop, backend)
        except OSError:
            break
        head, tail = _os_path.split(head)


async def rename(
    src: PathType,
    dst: PathType,
    *,
    src_dir_fd: int | None = None,
    dst_dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Rename the file or directory src to dst."""
    _check_unsupported_dir_fd(src_dir_fd)
    _check_unsupported_dir_fd(dst_dir_fd)
    await fs_rename(src, dst, loop, backend)


async def replace(
    src: PathType,
    dst: PathType,
    *,
    src_dir_fd: int | None = None,
    dst_dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Rename the file or directory src to dst, overwriting dst if it exists."""
    _check_unsupported_dir_fd(src_dir_fd)
    _check_unsupported_dir_fd(dst_dir_fd)
    await fs_rename(src, dst, loop, backend)


async def renames(
    old: PathType,
    new: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Super-rename; create directories as necessary and delete any left empty."""
    head, tail = _os_path.split(_os.fspath(new))
    if head and tail and not await path.exists(head, loop=loop, backend=backend):
        await makedirs(head, exist_ok=True, loop=loop, backend=backend)
    await fs_rename(old, new, loop, backend)
    head, tail = _os_path.split(_os.fspath(old))
    if head and tail:
        try:
            await removedirs(head, loop=loop, backend=backend)
        except OSError:
            pass


async def link(
    src: PathType,
    dst: PathType,
    *,
    src_dir_fd: int | None = None,
    dst_dir_fd: int | None = None,
    follow_symlinks: bool = True,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Create a hard link pointing to src named dst."""
    _check_unsupported_dir_fd(src_dir_fd)
    _check_unsupported_dir_fd(dst_dir_fd)
    await fs_link(src, dst, follow_symlinks, loop, backend)


async def symlink(
    src: PathType,
    dst: PathType,
    target_is_directory: bool = False,
    *,
    dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Create a symbolic link pointing to src named dst."""
    _check_unsupported_dir_fd(dir_fd)
    await fs_symlink(src, dst, target_is_directory, loop, backend)


async def readlink(
    path: PathType,
    *,
    dir_fd: int | None = None,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> str | bytes:
    """Return a string or bytes representing the path to which the symlink points."""
    _check_unsupported_dir_fd(dir_fd)
    return cast(str | bytes, await fs_readlink(path, loop))


async def access(
    path: PathType,
    mode: int,
    *,
    dir_fd: int | None = None,
    effective_ids: bool = False,
    follow_symlinks: bool = True,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Use the real uid/gid to test for access to path."""
    _check_unsupported_dir_fd(dir_fd)
    if effective_ids:
        raise NotImplementedError("effective_ids is not supported")
    return bool(await fs_access(path, mode, follow_symlinks, loop, backend))


async def truncate(
    path: PathType | int,
    length: int,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Truncate the file corresponding to path or fd to at most length bytes."""
    await fs_truncate(path, length, loop, backend)


async def listdir(
    path: PathType | None = ".",
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> list[str] | list[bytes]:
    """Return a list containing the names of the entries in the directory given by path."""
    return cast(list[str] | list[bytes], await fs_listdir(path, loop))


async def scandir(
    path: PathType | None = ".",
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> ScandirIterator[str] | ScandirIterator[bytes]:
    """Return an iterator of AsyncDirEntry objects for the given path via uv_fs_scandir."""
    raw_entries, is_bytes, base_path = await fs_scandir_raw(path, loop)
    if is_bytes:
        entries_b = [
            AsyncDirEntry(name_b, _os_path.join(base_path, name_b), dtype)
            for name_b, dtype in raw_entries
        ]
        return ScandirIterator(entries_b)
    entries_s = [
        AsyncDirEntry(
            name_s := _os.fsdecode(name_b),
            _os_path.join(base_path, name_s),
            dtype,
        )
        for name_b, dtype in raw_entries
    ]
    return ScandirIterator(entries_s)


async def copyfile(
    src: PathType,
    dst: PathType,
    flags: int = 0,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> None:
    """Copy src to dst natively via uv_fs_copyfile."""
    await fs_copyfile(src, dst, flags, loop)


async def statfs(
    path: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> dict[str, int]:
    """Return filesystem statistics via uv_fs_statfs."""
    return cast(dict[str, int], await fs_statfs(path, loop))


__all__ = [
    "AsyncDirEntry",
    "ScandirIterator",
    "access",
    "copyfile",
    "link",
    "listdir",
    "lstat",
    "makedirs",
    "mkdir",
    "path",
    "readlink",
    "remove",
    "removedirs",
    "rename",
    "renames",
    "replace",
    "rmdir",
    "scandir",
    "stat",
    "statfs",
    "symlink",
    "truncate",
    "unlink",
]

if hasattr(_os, "statvfs_result"):

    async def statvfs(
        path: PathType,
        *,
        loop: asyncio.AbstractEventLoop | None = None,
        backend: BackendType = "auto",
    ) -> _os.statvfs_result:
        """Return a statvfs_result object backed by uv_fs_statfs."""
        info = await fs_statfs(path, loop)
        bsize = info["f_bsize"]
        return _os.statvfs_result(
            (
                bsize,
                bsize,
                info["f_blocks"],
                info["f_bfree"],
                info["f_bavail"],
                info["f_files"],
                info["f_ffree"],
                info["f_ffree"],
                0,
                255,
                0,
            )
        )

    __all__.append("statvfs")
