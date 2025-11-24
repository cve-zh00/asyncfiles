import asyncio
from contextlib import asynccontextmanager
from functools import lru_cache
from typing import Optional
from .files import File
from .types import OpenTextMode
from .utils import FileMode, mode_to_posix


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
    path: str,
    mode: OpenTextMode = "r",
    buffer_size: int = 64 * 1024,
    loop: Optional[asyncio.AbstractEventLoop] = None,
):
    try:
        loop = get_loop(loop)
        if loop is None:
            raise ValueError("No event loop provided")
        async with File(
            path=path, mode=parse_mode(mode), buffer_size=buffer_size, loop=loop
        ) as f:
            yield f
    finally:
        pass
