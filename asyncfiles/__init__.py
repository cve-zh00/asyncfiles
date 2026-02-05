import asyncio
from contextlib import asynccontextmanager
from functools import lru_cache
from pathlib import Path
from typing import Optional, Union

from .files import BinaryFile, TextFile
from .types import OpenTextMode
from .utils import FileMode, mode_to_posix

try:
    import uvloop

    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
except:
    pass

__version__ = "1.1.3"
__author__ = "Bastián García"
__email__ = "bastiang@uc.cl"
__all__ = ["open", "__version__"]


def get_loop(
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> Optional[asyncio.AbstractEventLoop]:
    try:
        return loop or asyncio.get_running_loop()
    except RuntimeError:
        if loop is None or not loop.is_running():
            new = asyncio.new_event_loop()
            asyncio.set_event_loop(new)
            return new


@lru_cache(maxsize=128)
def parse_mode(mode: str) -> FileMode:
    return mode_to_posix(mode.encode())


@asynccontextmanager
async def open(
    path: Union[str, Path],
    mode: OpenTextMode = "r",
    buffer_size: int = 64 * 1024,
    loop: Optional[asyncio.AbstractEventLoop] = None,
):
    try:
        loop = get_loop(loop)
        if loop is None:
            raise ValueError("No event loop provided")

        # Convert Path to str if necessary
        if isinstance(path, Path):
            path = str(path)
        file_mode = parse_mode(mode)
        # Seleccionar la clase apropiada según el modo
        FileClass = BinaryFile if file_mode.binary else TextFile

        async with FileClass(
            path=path, mode=file_mode, buffer_size=buffer_size, loop=loop
        ) as f:
            yield f
    finally:
        pass
