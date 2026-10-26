"""Type stubs for asyncfiles package."""

import asyncio
from pathlib import Path
from typing import AsyncIterator, Literal, Optional, Union, overload

from contextlib import AbstractAsyncContextManager

PathLike = Union[str, Path]

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
    async def read(self, size: int = -1) -> Union[str, bytes]: ...
    async def write(self, data: Union[str, bytes]) -> int: ...
    async def close(self) -> None: ...
    async def truncate(self, length: int = 0) -> int: ...
    def seek(self, offset: int, whence: int = 0) -> int: ...
    def tell(self) -> int: ...
    def __aiter__(self) -> AsyncIterator[Union[str, bytes]]: ...


@overload
def open(
    path: PathLike,
    mode: OpenTextMode = "r",
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: BackendType = "auto",
) -> AbstractAsyncContextManager[File]: ...
@overload
def open(
    path: PathLike,
    mode: OpenBinaryMode = ...,
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: BackendType = "auto",
) -> AbstractAsyncContextManager[File]: ...
def open(
    path: PathLike,
    mode: OpenMode = "r",
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
    *,
    backend: BackendType = "auto",
) -> AbstractAsyncContextManager[File]: ...


def get_loop(
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> asyncio.AbstractEventLoop: ...


__version__: str
__all__: list[str]
