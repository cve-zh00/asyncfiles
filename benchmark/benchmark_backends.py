#!/usr/bin/env python3
"""Benchmark comparing libuv and io_uring backends for asyncfiles.

Measures read and write throughput for small (1KB), medium (1MB), and large (5MB)
file sizes across both backends. Reports latency (mean, p50, p95, p99) and
throughput (MB/s) for each combination.

Usage:
    python -m benchmark.benchmark_backends
"""

import asyncio
import os
import statistics
import tempfile
import time

import asyncfiles


FILE_SIZES = {
    "1KB": 1024,
    "1MB": 1024 * 1024,
    "5MB": 5 * 1024 * 1024,
}

ITERATIONS = 50


def io_uring_available() -> bool:
    """Check if io_uring backend is available on this system."""
    try:
        from asyncfiles.backend import resolve_backend

        resolve_backend("io_uring")
        return True
    except (OSError, ImportError):
        return False


def report_stats(label: str, times: list, data_size: int) -> None:
    """Report latency and throughput statistics for a set of timing measurements.

    Args:
        label: Description of the operation (e.g., "Read", "Write").
        times: List of elapsed times in seconds for each iteration.
        data_size: Size of data transferred per operation in bytes.
    """
    times_ms = [t * 1000 for t in times]
    mean = statistics.mean(times_ms)
    p50 = statistics.median(times_ms)
    sorted_times = sorted(times_ms)
    p95_idx = int(len(sorted_times) * 0.95)
    p99_idx = int(len(sorted_times) * 0.99)
    # Clamp indices to valid range
    p95_idx = min(p95_idx, len(sorted_times) - 1)
    p99_idx = min(p99_idx, len(sorted_times) - 1)
    p95 = sorted_times[p95_idx]
    p99 = sorted_times[p99_idx]
    mean_seconds = statistics.mean(times)
    throughput = (data_size / (1024 * 1024)) / mean_seconds if mean_seconds > 0 else 0

    print(f"  {label}:")
    print(
        f"    Latency: mean={mean:.3f}ms  p50={p50:.3f}ms  "
        f"p95={p95:.3f}ms  p99={p99:.3f}ms"
    )
    print(f"    Throughput: {throughput:.2f} MB/s")


async def bench_read(path: str, backend: str, iterations: int) -> list:
    """Benchmark read operations for a given backend.

    Args:
        path: Path to the file to read.
        backend: Backend to use ('libuv' or 'io_uring').
        iterations: Number of read iterations to perform.

    Returns:
        List of elapsed times in seconds for each iteration.
    """
    times = []
    for _ in range(iterations):
        start = time.perf_counter()
        async with asyncfiles.open(path, "rb", backend=backend) as f:
            await f.read()
        elapsed = time.perf_counter() - start
        times.append(elapsed)
    return times


async def bench_write(
    path: str, data: bytes, backend: str, iterations: int
) -> list:
    """Benchmark write operations for a given backend.

    Args:
        path: Path to the file to write.
        data: Data to write on each iteration.
        backend: Backend to use ('libuv' or 'io_uring').
        iterations: Number of write iterations to perform.

    Returns:
        List of elapsed times in seconds for each iteration.
    """
    times = []
    for _ in range(iterations):
        start = time.perf_counter()
        async with asyncfiles.open(path, "wb", backend=backend) as f:
            await f.write(data)
        elapsed = time.perf_counter() - start
        times.append(elapsed)
    return times


async def main():
    """Run benchmarks for both backends across all file sizes."""
    print("=" * 60)
    print("  asyncfiles Backend Benchmark: libuv vs io_uring")
    print("=" * 60)
    print(f"  Iterations per test: {ITERATIONS}")
    print(f"  File sizes: {', '.join(FILE_SIZES.keys())}")
    print()

    backends = ["libuv"]
    if io_uring_available():
        backends.append("io_uring")
        print("  Backends: libuv, io_uring")
    else:
        print("  NOTE: io_uring backend unavailable (requires Linux kernel 5.6+)")
        print("        Only benchmarking libuv backend.")

    print()

    with tempfile.TemporaryDirectory() as tmpdir:
        for size_name, size_bytes in FILE_SIZES.items():
            print(f"\n{'=' * 60}")
            print(f"  File size: {size_name} ({size_bytes:,} bytes)")
            print(f"{'=' * 60}")

            data = os.urandom(size_bytes)
            read_path = os.path.join(tmpdir, f"read_{size_name}.bin")
            write_path = os.path.join(tmpdir, f"write_{size_name}.bin")

            # Prepare read file
            with open(read_path, "wb") as f:
                f.write(data)

            for backend in backends:
                print(f"\n  Backend: {backend}")
                print(f"  {'-' * 40}")

                read_times = await bench_read(read_path, backend, ITERATIONS)
                report_stats("Read", read_times, size_bytes)

                write_times = await bench_write(write_path, data, backend, ITERATIONS)
                report_stats("Write", write_times, size_bytes)

    print(f"\n{'=' * 60}")
    print("  Benchmark complete.")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    asyncio.run(main())
