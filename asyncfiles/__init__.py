import asyncio
from functools import lru_cache
from pathlib import Path
from typing import Literal, Optional, Union

from . import backend as _backend
from .files import BinaryFile, TextFile
from .types import OpenTextMode
from .utils import FileMode, mode_to_posix


__version__ = "1.7.0"
__author__ = "Bastián García"
__email__ = "bastiang@uc.cl"
__all__ = ["open", "__version__"]


def get_loop(
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> asyncio.AbstractEventLoop:
    return loop or asyncio.get_running_loop()


@lru_cache(maxsize=128)
def parse_mode(mode: str) -> FileMode:
    return mode_to_posix(mode.encode())


def open(
    path: Union[str, Path],
    mode: OpenTextMode = "r",
    buffer_size: int = 64 * 1024,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: Literal["auto", "io_uring", "libuv"] = "auto",
):
    loop = get_loop(loop)
    resolved = _backend.resolve_backend(backend)

    # Convert Path to str if necessary
    if isinstance(path, Path):
        path = str(path)
    file_mode = parse_mode(mode)
    FileClass = BinaryFile if file_mode.binary else TextFile

    # The file object is itself the async context manager (__aenter__/__aexit__)
    return FileClass(
        path=path, mode=file_mode, buffer_size=buffer_size,
        loop=loop, backend=resolved,
    )
