"""Async wrappers around os.path functions."""

from __future__ import annotations

import asyncio
from collections.abc import Callable, Coroutine
import functools
import os.path as _os_path
from typing import Any, TypeVar


_R = TypeVar("_R")


def wrap(func: Callable[..., _R]) -> Callable[..., Coroutine[Any, Any, _R]]:
    @functools.wraps(func)
    async def run(
        *args: Any,
        loop: asyncio.AbstractEventLoop | None = None,
        executor: Any = None,
        **kwargs: Any,
    ) -> _R:
        if loop is None:
            loop = asyncio.get_running_loop()
        if kwargs:
            pfunc = functools.partial(func, *args, **kwargs)
            return await loop.run_in_executor(executor, pfunc)
        return await loop.run_in_executor(executor, func, *args)

    return run


abspath = wrap(_os_path.abspath)
exists = wrap(_os_path.exists)
getatime = wrap(_os_path.getatime)
getctime = wrap(_os_path.getctime)
getmtime = wrap(_os_path.getmtime)
getsize = wrap(_os_path.getsize)
isdir = wrap(_os_path.isdir)
isfile = wrap(_os_path.isfile)
islink = wrap(_os_path.islink)
ismount = wrap(_os_path.ismount)
realpath = wrap(_os_path.realpath)
samefile = wrap(_os_path.samefile)
sameopenfile = wrap(_os_path.sameopenfile)

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
    "realpath",
    "samefile",
    "sameopenfile",
    "wrap",
]
