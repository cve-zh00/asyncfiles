import asyncio
import contextlib
import sys
import time
from pathlib import Path
from uuid import uuid4

from aiofile import AIOFile
from aiofiles import open as aio_open
from anyio import open_file as anyio_open
from tabulate import tabulate

from asyncfiles import open as asyncfiles_open

DATA_5MB = "x" * 1024 * 1024 * 5
WORKERS = 500
ITERATIONS = 10
SORT_RESULTS = True
RESULTS = []
TMP_DIR = Path("tmp")
READFILE_NAME = "readfile.txt"
READFILE_PATH = str(TMP_DIR / "readfile.txt")
USE_UVLOOP = False
if not TMP_DIR.exists():
    TMP_DIR.mkdir()

with open(READFILE_PATH, "w", encoding="UTF-8") as fp:
    fp.write(DATA_5MB)


async def asyncfiles_read():
    async with asyncfiles_open(READFILE_PATH, "r") as afp:
        return await afp.read()


async def asyncfiles_write():
    async with asyncfiles_open(f"tmp/{uuid4().hex}.txt", "w") as afp:
        await afp.write(DATA_5MB)


async def aiofile_read():
    async with AIOFile(READFILE_PATH, "r") as afp:
        return await afp.read()


async def aiofile_write():
    async with AIOFile(f"tmp/{uuid4().hex}.txt", "w") as afp:
        await afp.write(DATA_5MB)


async def aiofiles_read():
    async with aio_open(READFILE_PATH, "r") as afp:
        return await afp.read()


async def aiofiles_write():
    async with aio_open(f"tmp/{uuid4().hex}.txt", "w") as afp:
        await afp.write(DATA_5MB)


async def anyio_read():
    async with await anyio_open(READFILE_PATH, "r") as afp:
        return await afp.read()


async def anyio_write():
    async with await anyio_open(f"tmp/{uuid4().hex}.txt", "w") as afp:
        await afp.write(DATA_5MB)


def stdlib_read():
    with open(READFILE_PATH, "r", encoding="UTF-8") as fp:
        return fp.read()


def stdlib_write():
    with open(f"tmp/{uuid4().hex}.txt", "w", encoding="UTF-8") as fp:
        fp.write(DATA_5MB)


def start_run(name):
    for file in TMP_DIR.iterdir():
        if file.name != READFILE_NAME:
            file.unlink()
    if ITERATIONS > 1:
        print(
            f"Benchmarking '{name}' with {WORKERS} workers and {ITERATIONS} iterations."
        )


def finish_run(name, start_time):
    average_time = (time.time() - start_time) / ITERATIONS
    print(f"Finished {name} with average {average_time:.2f} seconds.")
    RESULTS.append((name, average_time))


def finish_iteration(name, run_num, start_time):
    if ITERATIONS > 1:
        print(f"Finished run #{run_num + 1} in {time.time() - start_time:.2f} seconds.")


def select_event_loop_policy():
    """Ask the user what event loop policy to use."""
    if sys.platform == "win32":
        policies = [
            asyncio.WindowsProactorEventLoopPolicy,
            asyncio.WindowsSelectorEventLoopPolicy,
        ]
    else:
        policies = [asyncio.DefaultEventLoopPolicy]
        with contextlib.suppress(ImportError):
            import uvloop

            policies.append(uvloop)

    print("Select an event loop policy:")
    for i, policy in enumerate(policies):
        print(f"{i}: {policy.__name__}", end="")
        if i == 0:
            print(" (default)")
        else:
            print()
    choice = int(input("Enter a number: "))

    if policies[choice].__name__ == "uvloop":
        global USE_UVLOOP
        USE_UVLOOP = True
    else:
        asyncio.set_event_loop_policy(policies[choice]())


if __name__ == "__main__":

    async def run_benchmark():
        print(
            f"Starting tests with {'uvloop' if USE_UVLOOP else asyncio.get_event_loop_policy().__class__.__name__}."
        )
        # Test async file io frameworks
        for func in [
            asyncfiles_write,
            asyncfiles_read,
            aiofile_read,
            aiofile_write,
            aiofiles_read,
            aiofiles_write,
            anyio_read,
            anyio_write,
        ]:
            name = func.__name__
            start_run(name)
            start = time.time()
            for x in range(ITERATIONS):
                current_start = time.time()
                await asyncio.gather(*[func() for _ in range(WORKERS)])
                finish_iteration(name, x, current_start)
            finish_run(name, start)

        # Test stdlib
        for func in [
            stdlib_read,
            stdlib_write,
        ]:
            name = func.__name__
            start_run(name)
            start = time.time()
            for x in range(ITERATIONS):
                current_start = time.time()
                for _ in range(WORKERS):
                    func()
                finish_iteration(name, x, current_start)
            finish_run(name, start)

        # Test stdlib with asyncio.to_thread
        for func in [
            stdlib_read,
            stdlib_write,
        ]:
            name = f"asyncio.to_thread({func.__name__})"
            start_run(name)
            start = time.time()
            for x in range(ITERATIONS):
                current_start = time.time()
                await asyncio.gather(*[asyncio.to_thread(func) for _ in range(WORKERS)])
                finish_iteration(name, x, current_start)
            finish_run(name, start)

        # Sort results by time
        if SORT_RESULTS:
            RESULTS.sort(key=lambda x: x[1])

        print(
            f"Finished running with {'uvloop' if USE_UVLOOP else asyncio.get_event_loop_policy().__class__.__name__}."
        )
        print(tabulate(RESULTS, headers=["Function", "Time (s)"], tablefmt="github"))

    select_event_loop_policy()
    if not USE_UVLOOP:
        asyncio.run(run_benchmark())
    else:
        import uvloop

        uvloop.run(run_benchmark())
