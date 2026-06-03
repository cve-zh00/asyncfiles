#!/usr/bin/env python3
"""Benchmark: asyncfiles (io_uring) vs aiofiles vs aiofile vs anyio.

Tests concurrent file I/O — the scenario where io_uring excels.
Instead of opening 1 file at a time, opens N files concurrently.
io_uring batches all SQEs into a single syscall; thread-based libs
need N threads.

Usage:
    pip install aiofiles aiofile anyio
    python -m benchmark.benchmark_iouring_vs_others
"""

import asyncio
import os
import tempfile

import aiofiles
import anyio
from aiofile import async_open

from asyncfiles import open as open_asyncfiles
from benchmark import Benchmark


MB = 1048576
CONCURRENCY_LEVELS = [10, 50, 100]
FILE_SIZE = MB  # 1MB per file
ITERATIONS = 20


def create_test_files(tmpdir: str, count: int) -> list:
    """Create N test files with random content, return list of absolute paths."""
    paths = []
    data = os.urandom(FILE_SIZE)
    for i in range(count):
        path = os.path.join(tmpdir, f"test_{i:04d}.bin")
        with open(path, "wb") as f:
            f.write(data)
        paths.append(path)
    return paths, data


# --- Read implementations (concurrent) ---


async def benchmark_asyncfiles_iouring_read(paths):
    """Read all files concurrently using asyncfiles io_uring."""
    async def read_one(p):
        async with open_asyncfiles(p, "rb", backend="io_uring") as f:
            return await f.read()

    results = await asyncio.gather(*[read_one(p) for p in paths])
    return sum(len(r) for r in results)


async def benchmark_aiofiles_read(paths):
    """Read all files concurrently using aiofiles (threadpool)."""
    async def read_one(p):
        async with aiofiles.open(p, "rb") as f:
            return await f.read()

    results = await asyncio.gather(*[read_one(p) for p in paths])
    return sum(len(r) for r in results)


async def benchmark_aiofile_read(paths):
    """Read all files concurrently using aiofile."""
    async def read_one(p):
        async with async_open(p, "rb") as f:
            return await f.read()

    results = await asyncio.gather(*[read_one(p) for p in paths])
    return sum(len(r) for r in results)


async def benchmark_anyio_read(paths):
    """Read all files concurrently using anyio (threadpool)."""
    async def read_one(p):
        async with await anyio.open_file(p, "rb") as f:
            return await f.read()

    results = await asyncio.gather(*[read_one(p) for p in paths])
    return sum(len(r) for r in results)


# --- Write implementations (concurrent) ---


async def benchmark_asyncfiles_iouring_write(paths, data):
    """Write all files concurrently using asyncfiles io_uring."""
    async def write_one(p):
        async with open_asyncfiles(p, "wb", backend="io_uring") as f:
            await f.write(data)

    await asyncio.gather(*[write_one(p) for p in paths])
    return len(paths) * len(data)


async def benchmark_aiofiles_write(paths, data):
    """Write all files concurrently using aiofiles (threadpool)."""
    async def write_one(p):
        async with aiofiles.open(p, "wb") as f:
            await f.write(data)

    await asyncio.gather(*[write_one(p) for p in paths])
    return len(paths) * len(data)


async def benchmark_aiofile_write(paths, data):
    """Write all files concurrently using aiofile."""
    async def write_one(p):
        async with async_open(p, "wb") as f:
            await f.write(data)

    await asyncio.gather(*[write_one(p) for p in paths])
    return len(paths) * len(data)


async def benchmark_anyio_write(paths, data):
    """Write all files concurrently using anyio (threadpool)."""
    async def write_one(p):
        async with await anyio.open_file(p, "wb") as f:
            await f.write(data)

    await asyncio.gather(*[write_one(p) for p in paths])
    return len(paths) * len(data)


async def main():
    """Función principal del benchmark"""
    print("=== Benchmark: asyncfiles (io_uring) vs aiofile vs aiofiles vs anyio ===")
    print("=== Focus: Concurrent File I/O ===\n")

    results_dir = "benchmark/results"
    os.makedirs(results_dir, exist_ok=True)

    full_markdown = "# io_uring Concurrent I/O Benchmark\n\n"
    full_markdown += "Benchmark comparing asyncfiles (io_uring) against thread-based async file I/O libraries.\n\n"
    full_markdown += "## Key Insight\n\n"
    full_markdown += "io_uring batches multiple I/O operations into a single syscall. "
    full_markdown += "Thread-based libraries need one thread per operation. "
    full_markdown += "The advantage grows with concurrency.\n\n"
    full_markdown += "## Test Configuration\n\n"
    full_markdown += f"- **File size**: {FILE_SIZE // 1024} KB per file\n"
    full_markdown += f"- **Iterations**: {ITERATIONS}\n"
    full_markdown += f"- **Concurrency levels**: {CONCURRENCY_LEVELS}\n"
    full_markdown += "- **Libraries**: asyncfiles (io_uring), aiofile, aiofiles, anyio\n\n"

    with tempfile.TemporaryDirectory() as tmpdir:
        for concurrency in CONCURRENCY_LEVELS:
            # Create test files (absolute paths)
            paths, data = create_test_files(tmpdir, concurrency)
            write_paths = [os.path.join(tmpdir, f"write_{i:04d}.bin") for i in range(concurrency)]

            # --- READ BENCHMARK ---
            print(f"\n{'=' * 60}")
            print(f"CONCURRENT READ: {concurrency} files x {FILE_SIZE // 1024}KB = {concurrency * FILE_SIZE // MB}MB total")
            print(f"{'=' * 60}\n")

            bench = Benchmark(f"concurrent_read_{concurrency}_files")

            bench.add_implementation(
                "asyncfiles (io_uring)",
                lambda p=paths: benchmark_asyncfiles_iouring_read(p),
            )
            bench.add_implementation(
                "aiofiles",
                lambda p=paths: benchmark_aiofiles_read(p),
            )
            bench.add_implementation(
                "aiofile",
                lambda p=paths: benchmark_aiofile_read(p),
            )
            bench.add_implementation(
                "anyio",
                lambda p=paths: benchmark_anyio_read(p),
            )

            results = await bench._run(iterations=ITERATIONS, max_concurrency=1)
            bench.print_summary(results)

            total_mb = concurrency * FILE_SIZE / MB
            section_md = bench.generate_markdown_summary(results, total_mb)
            full_markdown += f"\n---\n\n{section_md}\n"

            # --- WRITE BENCHMARK ---
            print(f"\n{'=' * 60}")
            print(f"CONCURRENT WRITE: {concurrency} files x {FILE_SIZE // 1024}KB = {concurrency * FILE_SIZE // MB}MB total")
            print(f"{'=' * 60}\n")

            bench = Benchmark(f"concurrent_write_{concurrency}_files")

            bench.add_implementation(
                "asyncfiles (io_uring)",
                lambda p=write_paths, d=data: benchmark_asyncfiles_iouring_write(p, d),
            )
            bench.add_implementation(
                "aiofiles",
                lambda p=write_paths, d=data: benchmark_aiofiles_write(p, d),
            )
            bench.add_implementation(
                "aiofile",
                lambda p=write_paths, d=data: benchmark_aiofile_write(p, d),
            )
            bench.add_implementation(
                "anyio",
                lambda p=write_paths, d=data: benchmark_anyio_write(p, d),
            )

            results = await bench._run(iterations=ITERATIONS, max_concurrency=1)
            bench.print_summary(results)

            section_md = bench.generate_markdown_summary(results, total_mb)
            full_markdown += f"\n---\n\n{section_md}\n"

    # Save results
    readme_path = os.path.join(results_dir, "IOURING_BENCHMARK.md")
    with open(readme_path, "w") as f:
        f.write(full_markdown)

    print(f"\n✓ Resultados guardados en: {readme_path}")


if __name__ == "__main__":
    asyncio.run(main())
