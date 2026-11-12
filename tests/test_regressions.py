"""Native completion lifetimes; Future checks do not measure raw C allocations."""

from __future__ import annotations

import asyncio
import errno
import gc
import os
import subprocess
import sys
import weakref
from collections.abc import Awaitable
from pathlib import Path
from typing import cast
from unittest.mock import patch

import pytest

import asyncfiles
import asyncfiles.os as aos
import asyncfiles.ospath as apath
from asyncfiles.event_loop import get_shared_pump, release_shared_pump
from asyncfiles.types import BackendType

REPETITIONS = 12
WORKER_TIMEOUT = 45


async def _missing(*operations: Awaitable[object]) -> None:
    errors = await asyncio.gather(*operations, return_exceptions=True)
    assert all(isinstance(error, FileNotFoundError) for error in errors), errors
    assert len({id(error) for error in errors}) == len(errors)


async def _optional(operation: Awaitable[object], *, symlink: bool = False) -> bool:
    """Omit only the unsupported operation, never the rest of a regression."""
    try:
        await operation
    except OSError as error:
        unsupported = {errno.ENOSYS, errno.ENOTSUP, errno.EOPNOTSUPP}
        if os.name == "nt" and symlink:
            unsupported.update({errno.EPERM, errno.EACCES})
        if error.errno not in unsupported:
            raise
        return False
    return True


async def _queries(root: Path, backend: BackendType) -> None:
    src, missing = root / "source", root / "missing"
    src.write_bytes(b"native")
    assert (await aos.stat(src, backend=backend)).st_size == 6
    assert (await aos.lstat(src, backend=backend)).st_size == 6
    assert await aos.access(src, os.F_OK, backend=backend)
    assert not await aos.access(missing, os.F_OK, backend=backend)
    assert await apath.exists(src, backend=backend)
    assert await apath.lexists(src, backend=backend)
    assert await apath.isfile(src, backend=backend)
    assert await apath.isdir(root, backend=backend)
    assert not await apath.islink(src, backend=backend)
    assert not await apath.exists(missing, backend=backend)
    assert await apath.getsize(src, backend=backend) == 6
    for query in (apath.getmtime, apath.getatime, apath.getctime):
        assert await query(src, backend=backend) >= 0
    assert await apath.samefile(src, src, backend=backend)
    resolved = await apath.realpath(src, strict=True, backend=backend)
    assert os.path.normcase(resolved) == os.path.normcase(os.path.realpath(src))
    await _missing(
        aos.stat(missing, backend=backend),
        aos.lstat(root / "also-missing", backend=backend),
        apath.getsize(missing, backend=backend),
        apath.realpath(missing, strict=True, backend=backend),
    )
    if await _optional(aos.statfs(root, backend=backend)):
        assert (await aos.statfs(root, backend=backend))["f_bsize"] > 0
        await _missing(aos.statfs(missing, backend=backend))


async def _mutations(root: Path, backend: BackendType) -> None:
    src, dst, copied, sub = (root / name for name in ("src", "dst", "copy", "sub"))
    src.write_bytes(b"native")
    await aos.mkdir(sub, backend=backend)
    with pytest.raises(FileExistsError):
        await aos.mkdir(sub, backend=backend)
    await aos.copyfile(src, copied, backend=backend)
    assert copied.read_bytes() == b"native"
    await aos.rename(src, dst, backend=backend)
    await aos.replace(copied, dst, backend=backend)
    assert dst.read_bytes() == b"native"
    await _missing(
        aos.rename(src, copied, backend=backend),
        aos.replace(src, copied, backend=backend),
        aos.copyfile(src, copied, backend=backend),
        aos.unlink(src, backend=backend),
        aos.rmdir(root / "missing-dir", backend=backend),
    )
    await aos.unlink(dst, backend=backend)
    await aos.rmdir(sub, backend=backend)


async def _fd(root: Path, backend: BackendType) -> None:
    src = root / "borrowed"
    src.write_bytes(b"native")
    with src.open("rb") as first, src.open("rb") as second:
        fd = first.fileno()
        assert (await aos.stat(fd, backend=backend)).st_size == 6
        assert await apath.exists(fd, backend=backend)
        assert await apath.sameopenfile(fd, second.fileno(), backend=backend)
        assert os.fstat(fd).st_size == 6  # Borrowed descriptors remain open.
    with pytest.raises(OSError) as failure:
        await aos.stat(-1, backend=backend)
    assert failure.value.errno == errno.EBADF
    assert not await apath.exists(-1, backend=backend)


async def _scandir(root: Path, backend: BackendType) -> None:
    src = root / "entry"
    src.write_bytes(b"native")
    assert src.name in await aos.listdir(root, backend=backend)
    assert os.fsencode(src.name) in await aos.listdir(
        os.fsencode(root), backend=backend
    )
    async with await aos.scandir(root, backend=backend) as entries:
        found = {entry.name for entry in entries}
    assert src.name in found
    async with await aos.scandir(os.fsencode(root), backend=backend) as entries:
        assert os.fsencode(src.name) in {entry.name for entry in entries}
    await _missing(
        aos.listdir(root / "missing", backend=backend),
        aos.scandir(root / "also-missing", backend=backend),
    )


async def _truncate(root: Path, backend: BackendType) -> None:
    src = root / "truncate"
    src.write_bytes(b"native")
    await aos.truncate(src, 4, backend=backend)
    assert src.stat().st_size == 4
    with src.open("r+b") as borrowed:
        await aos.truncate(borrowed.fileno(), 2, backend=backend)
        assert os.fstat(borrowed.fileno()).st_size == 2
        borrowed.seek(0)
        assert borrowed.read() == b"na"
    await _missing(aos.truncate(root / "missing", 1, backend=backend))
    with src.open("rb") as readonly:
        with pytest.raises(OSError):
            await aos.truncate(readonly.fileno(), 1, backend=backend)
        assert os.fstat(readonly.fileno()).st_size == 2


async def _links(root: Path, backend: BackendType) -> None:
    src, hard, sym = (root / name for name in ("target", "hard", "sym"))
    src.write_bytes(b"native")
    if await _optional(aos.link(src, hard, backend=backend)):
        assert await apath.samefile(src, hard, backend=backend)
        await aos.unlink(hard, backend=backend)
        await _missing(aos.link(root / "missing", hard, backend=backend))
    if await _optional(aos.symlink(src, sym, backend=backend), symlink=True):
        assert await apath.islink(sym, backend=backend)
        assert os.path.normcase(await aos.readlink(sym, backend=backend)) == (
            os.path.normcase(str(src))
        )
        assert (await aos.lstat(sym, backend=backend)).st_mode != src.stat().st_mode
        with pytest.raises(FileExistsError):
            await aos.symlink(src, sym, backend=backend)
        await aos.unlink(sym, backend=backend)
    with pytest.raises(OSError):
        await aos.readlink(src, backend=backend)


CASES = {
    "path1": _queries,
    "path2": _mutations,
    "fd": _fd,
    "scandir": _scandir,
    "truncate": _truncate,
    "links": _links,
}


def _assert_uv_idle(loop: asyncio.AbstractEventLoop) -> None:
    # Registries are cdef, not Python exports. This lookup acquires if present.
    pump = get_shared_pump(loop)
    if pump is not None:
        release_shared_pump(loop)  # Balance only our inspection reference.
    assert pump is None, "libuv shared pump still registered for this loop"


def _assert_uring_idle(loop: asyncio.AbstractEventLoop, backend: BackendType) -> None:
    if backend != "io_uring":
        return
    from asyncfiles.io_uring_pump import IOUringPump

    # Idle rings are intentionally cached. Check only this loop's ring using
    # Cython GC traversal, not unexported registry/pending/keepalive attributes.
    for obj in gc.get_objects():
        if isinstance(obj, IOUringPump):
            referents = gc.get_referents(obj)
            if any(referent is loop for referent in referents):
                assert not any(
                    isinstance(referent, dict) and referent for referent in referents
                ), "ring retains pending/keepalive entries"


async def _drain() -> None:
    for _ in range(4):
        await asyncio.sleep(0)
    gc.collect()


async def _exercise(root: Path, backend: BackendType, case: str) -> None:
    loop = asyncio.get_running_loop()
    operation = CASES[case]
    await operation(root, backend)  # Warm up before measuring this loop.
    await _drain()
    _assert_uv_idle(loop)
    refs: list[weakref.ReferenceType[asyncio.Future[object]]] = []
    create_future = loop.create_future

    def tracked_future() -> asyncio.Future[object]:
        future = create_future()
        refs.append(weakref.ref(future))
        return future

    with patch.object(loop, "create_future", tracked_future):
        for _ in range(REPETITIONS):
            await operation(root, backend)
            _assert_uv_idle(loop)
        await _drain()
    assert refs, "no native completion Futures observed"
    assert all(ref() is None for ref in refs), f"{case}: completion Future retained"
    _assert_uring_idle(loop, backend)


@pytest.mark.parametrize("case", CASES)
def test_native_completion_lifetimes(
    tmp_path: Path, backend: BackendType, case: str
) -> None:
    _worker("lifetimes", backend, tmp_path, case)


def _worker(mode: str, backend: BackendType, root: Path, case: str = "") -> None:
    # runpy keeps the repository importable via the child's cwd; no PYTHONPATH
    # assumptions, shell quoting, external tools or additional dependencies.
    command = [
        sys.executable,
        "-c",
        "import runpy; runpy.run_path('tests/test_regressions.py', run_name='__main__')",
        mode,
        backend,
        str(root),
        case,
    ]
    try:
        result = subprocess.run(
            command,
            cwd=Path(__file__).resolve().parents[1],
            capture_output=True,
            text=True,
            timeout=WORKER_TIMEOUT,
            check=False,
        )
    except subprocess.TimeoutExpired as error:
        pytest.fail(
            f"{mode}/{backend}/{case}: native worker timed out: {error.stderr!r}"
        )
    assert result.returncode == 0, f"{mode}/{backend}/{case}:\n{result.stderr}"


@pytest.mark.parametrize("backend", ["libuv"], indirect=True)
@pytest.mark.parametrize("case", CASES)
def test_libuv_without_add_reader(
    tmp_path: Path, backend: BackendType, case: str
) -> None:
    # A separate process AND untouched loop ensure an already-primed shared
    # pump/registered reader cannot accidentally make this regression pass.
    _worker("fallback", backend, tmp_path, case)


async def _fallback(root: Path, case: str) -> None:
    loop = asyncio.get_running_loop()
    call_soon = loop.call_soon
    ticks = 0

    def counting_call_soon(callback, *args, **kwargs):
        nonlocal ticks
        if getattr(callback, "__name__", "") == "_tick":
            ticks += 1
        return call_soon(callback, *args, **kwargs)

    _assert_uv_idle(loop)
    with patch.object(loop, "add_reader", side_effect=NotImplementedError) as reader:
        with patch.object(loop, "call_soon", counting_call_soon):
            await _exercise(root, "libuv", case)
            before_idle = ticks
            await asyncio.sleep(0.03)
            assert ticks == before_idle, "fallback polling continued while idle"
        if os.name != "nt":  # Windows libuv may have no backend fd to register.
            assert reader.called, "add_reader fallback was not exercised"


async def _mixed(
    root: Path,
    backend: BackendType,
    previous: list[weakref.ReferenceType[asyncio.AbstractEventLoop]],
) -> asyncio.AbstractEventLoop:
    src = root / "mixed"

    async def files() -> None:
        for _ in range(8):
            async with asyncfiles.open(src, "wb", backend=backend) as stream:
                await stream.write(b"native")
            async with asyncfiles.open(src, "rb", backend=backend) as stream:
                assert await stream.read() == b"native"
            with pytest.raises(FileNotFoundError):
                async with asyncfiles.open(
                    root / "missing-file", "rb", backend=backend
                ):
                    pass

    async def metadata() -> None:
        for _ in range(8):
            await _scandir(root, backend)
            await _queries(root, backend)

    await asyncio.gather(files(), metadata())
    # Check lifetime/registry ownership only after BOTH users release the
    # shared pump; an open concurrent file legitimately keeps it registered.
    await _exercise(root, backend, "fd")
    loop = asyncio.get_running_loop()
    _assert_uv_idle(loop)
    _assert_uring_idle(loop, backend)
    # io_uring purges idle rings from CLOSED loops on the next acquisition.
    # No leaked registry entry may keep one of our previous loops alive.
    assert all(ref() is None for ref in previous), "previous closed loop retained"
    return loop


def test_separate_event_loops(tmp_path: Path, backend: BackendType) -> None:
    """Synchronous parent/worker: never nest asyncio.run in pytest's loop."""
    _worker("loops", backend, tmp_path)


if __name__ == "__main__":
    mode, selected_backend, directory, selected_case = sys.argv[1:]
    assert selected_backend in ("libuv", "io_uring"), selected_backend
    worker_backend = cast(BackendType, selected_backend)
    root = Path(directory)
    sys.stderr.write(f"{mode}/{selected_backend}/{selected_case}\n")
    if mode == "fallback":
        asyncio.run(_fallback(root, selected_case))
    elif mode == "lifetimes":
        asyncio.run(_exercise(root, worker_backend, selected_case))
    elif mode == "loops":
        previous: list[weakref.ReferenceType[asyncio.AbstractEventLoop]] = []
        for index in range(4):
            loop_root = root / f"loop-{index}"
            loop_root.mkdir()
            closed = asyncio.run(_mixed(loop_root, worker_backend, previous))
            assert closed.is_closed()
            _assert_uv_idle(closed)
            previous.append(weakref.ref(closed))
            del closed
            gc.collect()
        # The last idle io_uring ring is cached until a subsequent acquisition
        # (or process exit), rather than being incorrectly asserted absent here.
    else:
        raise ValueError(f"unknown worker: {mode}")
