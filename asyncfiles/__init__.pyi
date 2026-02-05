"""Type stubs for asyncfiles package."""

import asyncio
from pathlib import Path
from typing import Literal, Optional, Union, overload

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
    async def read(
        self,
        size: int = -1,
        offset: Optional[int] = None,
    ) -> Union[str, bytes]: ...
    async def write(
        self,
        data: Union[str, bytes],
        offset: Optional[int] = None,
    ) -> int: ...
    async def close(self) -> None: ...
    async def fsync(self) -> None: ...
    async def truncate(self, length: int) -> None: ...

@overload
async def open(
    path: PathLike,
    mode: OpenTextMode = "r",
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> File: ...
@overload
async def open(
    path: PathLike,
    mode: OpenBinaryMode,
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> File: ...
async def open(
    path: PathLike,
    mode: OpenMode = "r",
    buffer_size: int = 65536,
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> File: ...
def get_loop(
    loop: Optional[asyncio.AbstractEventLoop] = None,
) -> Optional[asyncio.AbstractEventLoop]: ...

__version__: str
__all__: list[str]
