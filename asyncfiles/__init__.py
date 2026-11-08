import asyncio
from functools import lru_cache
import os
from pathlib import Path
from typing import BinaryIO, Literal, Optional, Union

from . import backend as _backend
from .files import BinaryFile, TextFile
from .sendfile import SendfileProtocol, sendfile_impl, validate_sendfile_args
from .types import OpenTextMode
from .utils import FileMode, mode_to_posix


__version__ = "1.10.1"
__author__ = "Bastián García"
__email__ = "bastiang@uc.cl"
__all__ = ["open", "sendfile", "sendpath", "SendfileProtocol", "__version__"]


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

    # Convert PathLike / bytes to str if necessary
    if not isinstance(path, str):
        path = os.fsdecode(path)
    file_mode = parse_mode(mode)
    FileClass = BinaryFile if file_mode.binary else TextFile

    # The file object is itself the async context manager (__aenter__/__aexit__)
    return FileClass(
        path=path,
        mode=file_mode,
        buffer_size=buffer_size,
        loop=loop,
        backend=resolved,
    )


async def sendfile(
    transport: asyncio.BaseTransport,
    file: Union[BinaryFile, BinaryIO],
    offset: int = 0,
    count: Optional[int] = None,
    *,
    chunk_size: int = 1024 * 1024,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    backend: Literal["auto", "io_uring", "libuv"] = "auto",
) -> int:
    """Send a binary file over an asyncio transport using asyncfiles backends."""
    loop = get_loop(loop)
    resolved = _backend.resolve_backend(backend)
    return await sendfile_impl(
        transport, file, offset, count, chunk_size, loop, resolved
    )


async def sendpath(
    transport: asyncio.BaseTransport,
    path: Union[str, Path],
    offset: int = 0,
    count: Optional[int] = None,
    *,
    chunk_size: int = 1024 * 1024,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    backend: Literal["auto", "io_uring", "libuv"] = "auto",
) -> int:
    """Open, send, and close a file by path over an asyncio transport."""
    validate_sendfile_args(transport, offset, count, chunk_size)
    loop = get_loop(loop)
    resolved = _backend.resolve_backend(backend)
    async with open(
        path, "rb", buffer_size=chunk_size, loop=loop, backend=resolved
    ) as af:
        return await sendfile_impl(
            transport, af, offset, count, chunk_size, loop, resolved
        )
