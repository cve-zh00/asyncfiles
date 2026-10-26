#!/usr/bin/env python3
"""Read/write benchmark meant to run inside a resource-limited container.

Compares asyncfiles (libuv / io_uring) against aiofiles, aiofile and anyio under
the same cgroup limits (CPU, memory, pids, optional block I/O throttling).

Usage (inside the container, see scripts/run_docker_benchmark.sh):
    python benchmark/benchmark_docker.py --dir /bench --output /results
"""

import argparse
import asyncio
import json
import os
import statistics
import time
from pathlib import Path
from typing import Awaitable, Callable, Dict, List, Optional

KB = 1024
MB = 1024 * KB
SIZES = {"4KB": 4 * KB, "1MB": MB, "16MB": 16 * MB}
CHUNK = 64 * KB


# --------------------------------------------------------------------------- #
# cgroup helpers
# --------------------------------------------------------------------------- #
def _read(path: str) -> Optional[str]:
    try:
        return Path(path).read_text().strip()
    except OSError:
        return None


def cgroup_limits() -> Dict[str, object]:
    """Return the limits applied to this container (cgroup v2, then v1)."""
    limits: Dict[str, object] = {"cpus": os.cpu_count(), "memory_bytes": None}
    cpu_max = _read("/sys/fs/cgroup/cpu.max")
    if cpu_max:
        quota, period = cpu_max.split()
        limits["cpus"] = None if quota == "max" else int(quota) / int(period)
    else:
        quota = _read("/sys/fs/cgroup/cpu/cpu.cfs_quota_us")
        period = _read("/sys/fs/cgroup/cpu/cpu.cfs_period_us")
        if quota and period and int(quota) > 0:
            limits["cpus"] = int(quota) / int(period)
    mem = _read("/sys/fs/cgroup/memory.max") or _read(
        "/sys/fs/cgroup/memory/memory.limit_in_bytes"
    )
    if mem and mem != "max" and int(mem) < 1 << 60:
        limits["memory_bytes"] = int(mem)
    return limits


def cpu_throttled() -> int:
    """Number of CPU throttling periods so far (cgroup v2/v1)."""
    for path in ("/sys/fs/cgroup/cpu.stat", "/sys/fs/cgroup/cpu/cpu.stat"):
        raw = _read(path)
        if raw:
            for line in raw.splitlines():
                key, _, value = line.partition(" ")
                if key in ("nr_throttled", "throttled_periods"):
                    return int(value)
    return 0


def memory_current() -> int:
    raw = _read("/sys/fs/cgroup/memory.current") or _read(
        "/sys/fs/cgroup/memory/memory.usage_in_bytes"
    )
    return int(raw) if raw else 0


def rss_bytes() -> int:
    """Resident set size of this process (anon + file mapped), no psutil needed."""
    try:
        with open("/proc/self/statm") as fh:
            return int(fh.read().split()[1]) * os.sysconf("SC_PAGE_SIZE")
    except OSError:
        return 0


async def peak_sampler(stop: asyncio.Event, out: Dict[str, int]) -> None:
    while not stop.is_set():
        out["rss"] = max(out.get("rss", 0), rss_bytes())
        out["cgroup"] = max(out.get("cgroup", 0), memory_current())
        await asyncio.sleep(0.05)


def evict_cache(paths: List[str]) -> None:
    """Drop page cache for the files so reads hit the (throttled) device."""
    if not hasattr(os, "posix_fadvise"):
        return
    for p in paths:
        try:
            fd = os.open(p, os.O_RDONLY)
            try:
                os.fsync(fd)
                os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_DONTNEED)
            finally:
                os.close(fd)
        except OSError:
            pass


# --------------------------------------------------------------------------- #
# Implementations (all binary mode, same chunking semantics)
# --------------------------------------------------------------------------- #
ReadFn = Callable[[str], Awaitable[int]]
WriteFn = Callable[[str, bytes], Awaitable[int]]


def asyncfiles_impls(backend: str):
    import asyncfiles

    async def read(path: str) -> int:
        async with asyncfiles.open(path, "rb", backend=backend) as f:
            return len(await f.read())

    async def write(path: str, data: bytes) -> int:
        async with asyncfiles.open(path, "wb", backend=backend) as f:
            await f.write(data)
        return len(data)

    return read, write


def aiofiles_impls():
    import aiofiles

    async def read(path: str) -> int:
        async with aiofiles.open(path, "rb") as f:
            return len(await f.read())

    async def write(path: str, data: bytes) -> int:
        async with aiofiles.open(path, "wb") as f:
            await f.write(data)
        return len(data)

    return read, write


def aiofile_impls():
    from aiofile import async_open

    async def read(path: str) -> int:
        async with async_open(path, "rb") as f:
            return len(await f.read())

    async def write(path: str, data: bytes) -> int:
        async with async_open(path, "wb") as f:
            await f.write(data)
        return len(data)

    return read, write


def anyio_impls():
    import anyio

    async def read(path: str) -> int:
        async with await anyio.open_file(path, "rb") as f:
            return len(await f.read())

    async def write(path: str, data: bytes) -> int:
        async with await anyio.open_file(path, "wb") as f:
            await f.write(data)
        return len(data)

    return read, write


def io_uring_available() -> bool:
    try:
        from asyncfiles.backend import resolve_backend

        resolve_backend("io_uring")
        return True
    except Exception:
        return False


def build_impls(selected: Optional[List[str]]) -> Dict[str, tuple]:
    impls: Dict[str, tuple] = {}
    factories = {
        "asyncfiles-libuv": lambda: asyncfiles_impls("libuv"),
        "asyncfiles-io_uring": lambda: asyncfiles_impls("io_uring"),
        "aiofiles": aiofiles_impls,
        "aiofile": aiofile_impls,
        "anyio": anyio_impls,
    }
    for name, factory in factories.items():
        if selected and name not in selected:
            continue
        if name == "asyncfiles-io_uring" and not io_uring_available():
            print(
                "  [skip] asyncfiles-io_uring: unavailable "
                "(kernel < 5.6 or blocked by seccomp; run with --security-opt "
                "seccomp=unconfined)"
            )
            continue
        try:
            impls[name] = factory()
        except ImportError as exc:
            print(f"  [skip] {name}: {exc}")
    return impls


# --------------------------------------------------------------------------- #
# Measurement
# --------------------------------------------------------------------------- #
def percentile(values: List[float], pct: float) -> float:
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, int(len(ordered) * pct))]


async def timed(coro_fn, *args) -> float:
    start = time.perf_counter()
    await coro_fn(*args)
    return time.perf_counter() - start


async def run_cell(
    op: str,
    fn,
    paths: List[str],
    data: Optional[bytes],
    iterations: int,
    cold: bool,
) -> Dict[str, float]:
    latencies: List[float] = []
    walls: List[float] = []
    peaks: Dict[str, int] = {}
    stop = asyncio.Event()
    sampler = asyncio.create_task(peak_sampler(stop, peaks))
    throttled_before = cpu_throttled()
    cpu_before = time.process_time()

    for _ in range(iterations):
        if cold:
            evict_cache(paths)
        start = time.perf_counter()
        if op == "read":
            lats = await asyncio.gather(*[timed(fn, p) for p in paths])
        else:
            lats = await asyncio.gather(*[timed(fn, p, data) for p in paths])
        walls.append(time.perf_counter() - start)
        latencies.extend(lats)

    cpu_used = time.process_time() - cpu_before
    stop.set()
    await sampler
    total_bytes = len(paths) * (len(data) if data else os.path.getsize(paths[0]))
    mean_wall = statistics.mean(walls)
    return {
        "throughput_mb_s": total_bytes / MB / mean_wall,
        "ops_s": len(paths) / mean_wall,
        "wall_mean_s": mean_wall,
        "lat_p50_ms": percentile(latencies, 0.50) * 1000,
        "lat_p95_ms": percentile(latencies, 0.95) * 1000,
        "lat_p99_ms": percentile(latencies, 0.99) * 1000,
        "cpu_s": cpu_used,
        "cpu_throttled_periods": cpu_throttled() - throttled_before,
        "peak_rss_mb": peaks.get("rss", 0) / MB,
        "peak_cgroup_mb": peaks.get("cgroup", 0) / MB,
    }


async def run_with_warmup(op, fn, paths, data, iterations, cold):
    await (fn(paths[0]) if op == "read" else fn(paths[0], data))
    return await run_cell(
        op, fn, paths, data if op == "write" else None, iterations, cold
    )


def fits_in_memory(size: int, concurrency: int, mem_limit: Optional[int]) -> bool:
    """Each in-flight op holds ~1x payload (+1x for the read buffer/copy)."""
    if not mem_limit:
        return True
    return size * concurrency * 2 <= mem_limit * 0.5


async def main_async(args) -> Dict[str, object]:
    workdir = Path(args.dir) / f"run-{os.getpid()}"
    workdir.mkdir(parents=True, exist_ok=True)
    limits = cgroup_limits()
    mem_limit = limits["memory_bytes"]

    print("=" * 72)
    print("asyncfiles container benchmark")
    print(
        f"  limits: cpus={limits['cpus']} "
        f"memory={'unlimited' if not mem_limit else f'{mem_limit / MB:.0f}MB'}"
    )
    print(f"  sizes={args.sizes} concurrency={args.concurrency} iters={args.iterations}")
    print(f"  cold cache reads: {not args.warm}")
    print("=" * 72)

    impls = build_impls(args.libs)
    results: List[Dict[str, object]] = []
    skipped: List[str] = []
    failed: set = set()

    try:
        for size_name in args.sizes:
            size = SIZES[size_name]
            data = os.urandom(size)
            for conc in args.concurrency:
                if not fits_in_memory(size, conc, mem_limit):
                    skipped.append(f"{size_name} x{conc}")
                    print(f"[skip] {size_name} x{conc}: exceeds 50% of memory limit")
                    continue
                paths = [str(workdir / f"f_{size_name}_{i}.bin") for i in range(conc)]
                for p in paths:
                    Path(p).write_bytes(data)
                for op in ("read", "write"):
                    for name, (read_fn, write_fn) in impls.items():
                        if name in failed:
                            continue
                        fn = read_fn if op == "read" else write_fn
                        try:
                            metrics = await asyncio.wait_for(
                                run_with_warmup(
                                    op, fn, paths, data, args.iterations, not args.warm
                                ),
                                timeout=args.timeout,
                            )
                        except asyncio.TimeoutError:
                            failed.add(name)
                            print(f"[fail] {name}: no progress in {args.timeout}s, skipped")
                            continue
                        results.append(
                            {"op": op, "impl": name, "size": size_name,
                             "concurrency": conc, **metrics}
                        )
                        print(
                            f"{op:5} {size_name:>5} x{conc:<3} {name:20} "
                            f"{metrics['throughput_mb_s']:9.1f} MB/s  "
                            f"p95={metrics['lat_p95_ms']:8.1f}ms  "
                            f"cpu={metrics['cpu_s']:.2f}s  "
                            f"thr={metrics['cpu_throttled_periods']}  "
                            f"mem={metrics['peak_cgroup_mb']:.0f}MB"
                        )
                for p in paths:
                    Path(p).unlink(missing_ok=True)
    finally:
        for leftover in workdir.glob("*"):
            leftover.unlink(missing_ok=True)
        workdir.rmdir()

    return {"limits": limits, "args": vars(args), "skipped": skipped, "failed": sorted(failed), "results": results}


def to_markdown(report: Dict[str, object], label: str) -> str:
    limits = report["limits"]
    mem = limits["memory_bytes"]
    lines = [
        f"# Container benchmark: {label}",
        "",
        f"- **CPUs**: {limits['cpus']}",
        f"- **Memory**: {'unlimited' if not mem else f'{mem / MB:.0f} MB'}",
        f"- **Iterations**: {report['args']['iterations']}",
        f"- **Reads cold cache**: {not report['args']['warm']}",
    ]
    if report["skipped"]:
        lines.append(f"- **Skipped (memory)**: {', '.join(report['skipped'])}")
    if report.get("failed"):
        lines.append(f"- **Timed out (hang)**: {', '.join(report['failed'])}")
    for op in ("read", "write"):
        lines += ["", f"## {op.capitalize()}", ""]
        lines += [
            "| Size | Conc | Implementation | MB/s | ops/s | p50 ms | p95 ms "
            "| p99 ms | CPU s | Throttled | Peak mem MB |",
            "|---|---|---|---|---|---|---|---|---|---|---|",
        ]
        rows = [r for r in report["results"] if r["op"] == op]
        for r in rows:
            lines.append(
                f"| {r['size']} | {r['concurrency']} | {r['impl']} "
                f"| {r['throughput_mb_s']:.1f} | {r['ops_s']:.1f} "
                f"| {r['lat_p50_ms']:.1f} | {r['lat_p95_ms']:.1f} "
                f"| {r['lat_p99_ms']:.1f} | {r['cpu_s']:.2f} "
                f"| {r['cpu_throttled_periods']} | {r['peak_cgroup_mb']:.0f} |"
            )
    return "\n".join(lines) + "\n"


def parse_args():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dir", default="/bench", help="scratch dir (disk-backed volume)")
    p.add_argument("--output", default="/results", help="directory for json/md output")
    p.add_argument("--label", default=os.environ.get("BENCH_LABEL", "default"))
    p.add_argument("--sizes", nargs="+", default=list(SIZES), choices=list(SIZES))
    p.add_argument("--concurrency", nargs="+", type=int, default=[1, 8, 32])
    p.add_argument("--iterations", type=int, default=5)
    p.add_argument("--libs", nargs="+", default=None)
    p.add_argument("--timeout", type=float, default=120, help="per-cell timeout (s)")
    p.add_argument("--warm", action="store_true", help="do not evict page cache")
    return p.parse_args()


def main() -> None:
    args = parse_args()
    report = asyncio.run(main_async(args))
    out = Path(args.output)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"container_{args.label}.json").write_text(json.dumps(report, indent=2))
    (out / f"container_{args.label}.md").write_text(to_markdown(report, args.label))
    print(f"\nResults written to {out}/container_{args.label}.(json|md)")


if __name__ == "__main__":
    main()
