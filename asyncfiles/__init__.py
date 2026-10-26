import asyncio
from contextlib import asynccontextmanager
from functools import lru_cache
from pathlib import Path
from typing import Literal, Optional, Union

from .files import BinaryFile, TextFile
from .types import OpenTextMode
from .utils import FileMode, mode_to_posix


__version__ = "1.5.1"
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


@asynccontextmanager
async def open(
    path: Union[str, Path],
    mode: OpenTextMode = "r",
    buffer_size: int = 64 * 1024,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: Literal["auto", "io_uring", "libuv"] = "auto",
):
    from .backend import resolve_backend

    loop = get_loop(loop)
    resolved = resolve_backend(backend)

    # Convert Path to str if necessary
    if isinstance(path, Path):
        path = str(path)
    file_mode = parse_mode(mode)
    FileClass = BinaryFile if file_mode.binary else TextFile

    async with FileClass(
        path=path, mode=file_mode, buffer_size=buffer_size,
        loop=loop, backend=resolved,
    ) as f:
        yield f
