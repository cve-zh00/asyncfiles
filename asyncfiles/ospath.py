"""Native async os.path operations powered by libuv and io_uring."""

from __future__ import annotations

import asyncio
import os as _os
import os.path as _os_path
from typing import AnyStr, cast

from .io_operations import fs_realpath_strict, fs_stat, fs_stat_query
from .types import BackendType, PathType


async def exists(
    path: PathType | int,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if path refers to an existing path or open file descriptor."""
    return bool(await fs_stat_query(path, 2, True, loop, backend))


async def lexists(
    path: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if path refers to an existing path, including broken symlinks."""
    return bool(await fs_stat_query(path, 2, False, loop, backend))


async def isfile(
    path: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if path is an existing regular file."""
    return bool(await fs_stat_query(path, 3, True, loop, backend))


async def isdir(
    path: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if path is an existing directory."""
    return bool(await fs_stat_query(path, 4, True, loop, backend))


async def islink(
    path: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if path refers to an existing directory entry that is a symlink."""
    return bool(await fs_stat_query(path, 5, False, loop, backend))


async def getsize(
    filename: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> int:
    """Return the size, in bytes, of filename."""
    return int(await fs_stat_query(filename, 6, True, loop, backend))


async def getmtime(
    filename: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> float:
    """Return the time of last modification of filename."""
    return float(await fs_stat_query(filename, 7, True, loop, backend))


async def getatime(
    filename: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> float:
    """Return the time of last access of filename."""
    return float(await fs_stat_query(filename, 8, True, loop, backend))


async def getctime(
    filename: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> float:
    """Return the metadata change time of filename."""
    return float(await fs_stat_query(filename, 9, True, loop, backend))


async def samefile(
    f1: PathType,
    f2: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if both pathname arguments refer to the same file or directory."""
    s1, s2 = await asyncio.gather(
        fs_stat(f1, True, loop, backend),
        fs_stat(f2, True, loop, backend),
    )
    return _os_path.samestat(s1, s2)


async def sameopenfile(
    fp1: int,
    fp2: int,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if the file descriptors fp1 and fp2 refer to the same file."""
    s1, s2 = await asyncio.gather(
        fs_stat(int(fp1), True, loop, backend),
        fs_stat(int(fp2), True, loop, backend),
    )
    return _os_path.samestat(s1, s2)


async def ismount(
    path: PathType,
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> bool:
    """Return True if pathname path is a mount point."""
    try:
        if await islink(path, loop=loop, backend=backend):
            return False
        fspath = _os.fspath(path)
        parent = (
            _os_path.join(fspath, b"..")
            if isinstance(fspath, bytes)
            else _os_path.join(fspath, "..")
        )
        parent = _os_path.realpath(parent)
        s1, s2 = await asyncio.gather(
            fs_stat(fspath, False, loop, backend),
            fs_stat(parent, False, loop, backend),
        )
    except OSError:
        return False
    return bool(s1.st_dev != s2.st_dev or s1.st_ino == s2.st_ino)


async def abspath(
    path: AnyStr | _os.PathLike[AnyStr],
    *,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> AnyStr:
    """Return a normalized absolutized version of the pathname path."""
    return _os_path.abspath(path)


async def realpath(
    filename: AnyStr | _os.PathLike[AnyStr],
    *,
    strict: bool = False,
    loop: asyncio.AbstractEventLoop | None = None,
    backend: BackendType = "auto",
) -> AnyStr:
    """Return the canonical path of the specified filename via uv_fs_realpath."""
    try:
        return cast(AnyStr, await fs_realpath_strict(filename, loop=loop))
    except (FileNotFoundError, NotADirectoryError):
        if strict:
            raise
    except OSError:
        if _os.name == "nt":
            return _os_path.realpath(filename, strict=strict)
        raise

    fspath = _os.fspath(filename)
    abs_path = _os_path.abspath(fspath)
    missing_parts: list[AnyStr] = []
    cur = abs_path
    while True:
        head, tail = _os_path.split(cur)
        if not tail:
            return abs_path
        missing_parts.append(tail)
        try:
            resolved_head = await fs_realpath_strict(head, loop=loop)
            missing_parts.reverse()
            return _os_path.normpath(_os_path.join(resolved_head, *missing_parts))
        except (FileNotFoundError, NotADirectoryError):
            if head == cur:
                return abs_path
            cur = head
        except OSError:
            if _os.name == "nt":
                return _os_path.realpath(filename, strict=strict)
            raise


__all__ = [
    "abspath",
    "exists",
    "getatime",
    "getctime",
    "getmtime",
    "getsize",
    "isdir",
    "isfile",
    "islink",
    "ismount",
    "lexists",
    "realpath",
    "samefile",
    "sameopenfile",
]
