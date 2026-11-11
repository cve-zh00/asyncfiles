"""Type stubs for asyncfiles package."""

import asyncio
from contextlib import AbstractAsyncContextManager
import os as _os
from pathlib import Path
from typing import (
    AsyncIterator,
    BinaryIO,
    Iterable,
    Literal,
    Optional,
    Union,
    overload,
)

from . import os as os, ospath as ospath


PathLike = Union[str, bytes, Path, _os.PathLike[str], _os.PathLike[bytes]]

OpenTextMode = Literal[
    "r",
    "w",
    "a",
    "x",
    "r+",
    "w+",
    "a+",
    "rt",
    "wt",
    "at",
    "xt",
    "r+t",
    "w+t",
    "a+t",
]

OpenBinaryMode = Literal[
    "rb",
    "wb",
    "ab",
    "xb",
    "r+b",
    "w+b",
    "a+b",
]

OpenMode = Union[OpenTextMode, OpenBinaryMode]

BackendType = Literal["auto", "io_uring", "libuv"]


class File:
    """Async file handle for I/O operations."""

    path: str
    mode: int
    buffer_size: int
    name: str
    closed: bool

    def __init__(
        self,
        path: PathLike,
        mode: int,
        buffer_size: int = 65536,
        loop: Optional[asyncio.AbstractEventLoop] = None,
    ) -> None: ...
    async def __aenter__(self) -> File: ...
    async def __aexit__(
        self,
        exc_type: Optional[type],
        exc_val: Optional[BaseException],
        exc_tb: Optional[object],
    ) -> None: ...
    async def read(self, size: Optional[int] = -1) -> Union[str, bytes]: ...
    async def readline(self, size: Optional[int] = -1) -> Union[str, bytes]: ...
    async def readlines(
        self, hint: Optional[int] = -1
    ) -> Union[list[str], list[bytes]]: ...
    async def write(self, data: Union[str, bytes, bytearray, memoryview]) -> int: ...
    async def writelines(
        self, lines: Iterable[Union[str, bytes, bytearray, memoryview]]
    ) -> None: ...
    async def flush(self) -> None: ...
    async def close(self) -> None: ...
    async def truncate(self, length: Optional[int] = None) -> int: ...
    def fileno(self) -> int: ...
    def seek(self, offset: int, whence: int = 0) -> int: ...
    def tell(self) -> int: ...
    def __aiter__(self) -> AsyncIterator[Union[str, bytes]]: ...


class TextFile(File):
    """Async text file handle for UTF-8 I/O operations."""

    async def __aenter__(self) -> TextFile: ...
    async def read(self, size: Optional[int] = -1) -> str: ...
    async def readline(self, size: Optional[int] = -1) -> str: ...
    async def readlines(self, hint: Optional[int] = -1) -> list[str]: ...
    async def write(self, data: str) -> int: ...
    async def writelines(self, lines: Iterable[str]) -> None: ...
    def __aiter__(self) -> AsyncIterator[str]: ...


class BinaryFile(File):
    """Async binary file handle for bytes I/O operations."""

    async def __aenter__(self) -> BinaryFile: ...
    async def read(self, size: Optional[int] = -1) -> bytes: ...
    async def readinto(self, b: Union[bytearray, memoryview]) -> int: ...
    async def readline(self, size: Optional[int] = -1) -> bytes: ...
    async def readlines(self, hint: Optional[int] = -1) -> list[bytes]: ...
    async def write(
        self, data: Union[bytes, bytearray, memoryview]
    ) -> int: ...
    async def writelines(
        self, lines: Iterable[Union[bytes, bytearray, memoryview]]
    ) -> None: ...
    def __aiter__(self) -> AsyncIterator[bytes]: ...


@overload
def open(
    path: PathLike,
    mode: OpenTextMode = "r",
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: BackendType = "auto",
) -> AbstractAsyncContextManager[TextFile]: ...
@overload
def open(
    path: PathLike,
    mode: OpenBinaryMode = ...,
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: BackendType = "auto",
) -> AbstractAsyncContextManager[BinaryFile]: ...
@overload
def open(
    path: PathLike,
    mode: str = ...,
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: BackendType = "auto",
) -> AbstractAsyncContextManager[File]: ...
def open(
    path: PathLike,
    mode: str = "r",
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: BackendType = "auto",
) -> AbstractAsyncContextManager[File]: ...


def get_loop(
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> asyncio.AbstractEventLoop: ...


class SendfileProtocol:
    def __init__(
        self,
        transport: asyncio.BaseTransport,
        loop: asyncio.AbstractEventLoop,
    ) -> None: ...
    def is_buffered_protocol(self) -> bool: ...
    async def drain(self) -> None: ...
    async def restore(self) -> None: ...
    def connection_made(self, transport: asyncio.BaseTransport) -> None: ...
    def connection_lost(self, exc: Optional[BaseException]) -> None: ...
    def pause_writing(self) -> None: ...
    def resume_writing(self) -> None: ...
    def data_received(self, data: bytes) -> None: ...
    def get_buffer(self, sizehint: int) -> object: ...
    def buffer_updated(self, nbytes: int) -> None: ...
    def eof_received(self) -> Optional[bool]: ...


async def sendfile(
    transport: asyncio.BaseTransport,
    file: Union[File, BinaryIO],
    offset: int = 0,
    count: Optional[int] = None,
    *,
    chunk_size: int = 1048576,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    backend: BackendType = "auto",
) -> int: ...


async def sendpath(
    transport: asyncio.BaseTransport,
    path: PathLike,
    offset: int = 0,
    count: Optional[int] = None,
    *,
    chunk_size: int = 1048576,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    backend: BackendType = "auto",
) -> int: ...


__version__: str
__all__: list[str]
