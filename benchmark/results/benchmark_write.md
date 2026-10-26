# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.8.0-117-generic (aarch64)
- **Iterations**: 5
- **Concurrency**: 1, 8, 32
- **File sizes**: 4KB, 1MB, 16MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32
- **Generated**: 2026-10-26 17:08 UTC

## Summary

Scenarios won (highest throughput) out of 8:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 4 |
| anyio | 2 |
| asyncfiles-libuv | 2 |


---

# Benchmark Results: 4KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 28.3 | 7240.0 | 0.1 | 0.1 | 0.1 | 0.00 | 0 | 23 | 5 |
| anyio | 23.4 | 6003.1 | 0.1 | 0.2 | 0.2 | 0.00 | 0 | 23 | 5 |
| asyncfiles-libuv | 21.4 | 5474.8 | 0.1 | 0.2 | 0.2 | 0.00 | 0 | 23 | 5 |
| aiofiles | 19.8 | 5068.0 | 0.2 | 0.2 | 0.2 | 0.00 | 0 | 23 | 5 |
| aiofile | 8.6 | 2200.5 | 0.4 | 0.7 | 0.7 | 0.00 | 0 | 23 | 5 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 28.3 MB/s (7240.0 ops/s)
- **p95 Latency**: 0.1 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **anyio**: 1.21x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.32x slower than asyncfiles-io_uring
- **aiofiles**: 1.43x slower than asyncfiles-io_uring
- **aiofile**: 3.29x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 130.1 | 33311.5 | 0.1 | 0.2 | 0.2 | 0.00 | 0 | 24 | 5 |
| asyncfiles-libuv | 87.1 | 22305.1 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 24 | 5 |
| anyio | 46.4 | 11871.1 | 0.5 | 0.7 | 0.7 | 0.01 | 0 | 24 | 5 |
| aiofiles | 35.4 | 9053.2 | 0.7 | 0.9 | 0.9 | 0.01 | 0 | 24 | 5 |
| aiofile | 29.3 | 7509.0 | 0.9 | 1.1 | 1.1 | 0.01 | 0 | 24 | 5 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 130.1 MB/s (33311.5 ops/s)
- **p95 Latency**: 0.2 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 24 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.49x slower than asyncfiles-io_uring
- **anyio**: 2.81x slower than asyncfiles-io_uring
- **aiofiles**: 3.68x slower than asyncfiles-io_uring
- **aiofile**: 4.44x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 164.9 | 42206.4 | 0.5 | 0.6 | 0.7 | 0.01 | 0 | 26 | 5 |
| asyncfiles-libuv | 158.4 | 40545.7 | 0.4 | 0.6 | 1.1 | 0.01 | 0 | 26 | 5 |
| aiofiles | 41.5 | 10620.4 | 2.6 | 3.0 | 3.1 | 0.02 | 0 | 26 | 5 |
| aiofile | 30.0 | 7681.5 | 2.5 | 5.3 | 5.6 | 0.03 | 0 | 26 | 5 |
| anyio | 15.1 | 3876.0 | 6.6 | 13.3 | 13.4 | 0.06 | 0 | 26 | 5 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 164.9 MB/s (42206.4 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 26 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 3.97x slower than asyncfiles-io_uring
- **aiofile**: 5.49x slower than asyncfiles-io_uring
- **anyio**: 10.89x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 2802.8 | 2802.8 | 0.3 | 0.3 | 0.3 | 0.00 | 0 | 31 | 5 |
| asyncfiles-io_uring | 2675.1 | 2675.1 | 0.4 | 0.4 | 0.4 | 0.00 | 0 | 31 | 5 |
| asyncfiles-libuv | 2517.1 | 2517.1 | 0.4 | 0.4 | 0.4 | 0.00 | 0 | 31 | 5 |
| aiofiles | 2386.6 | 2386.6 | 0.4 | 0.4 | 0.4 | 0.00 | 0 | 31 | 5 |
| aiofile | 677.3 | 677.3 | 0.6 | 2.8 | 2.8 | 0.01 | 0 | 31 | 5 |

## 🏆 Winner: **anyio**

- **Throughput**: 2802.8 MB/s (2802.8 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 31 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.05x slower than anyio
- **asyncfiles-libuv**: 1.11x slower than anyio
- **aiofiles**: 1.17x slower than anyio
- **aiofile**: 4.14x slower than anyio


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 5985.9 | 5985.9 | 0.9 | 1.3 | 1.4 | 0.01 | 0 | 44 | 5 |
| aiofiles | 4569.3 | 4569.3 | 1.5 | 1.7 | 1.8 | 0.02 | 0 | 44 | 5 |
| asyncfiles-libuv | 4410.8 | 4410.8 | 1.1 | 3.2 | 3.2 | 0.02 | 0 | 44 | 5 |
| anyio | 3662.3 | 3662.3 | 1.8 | 2.1 | 2.4 | 0.03 | 0 | 44 | 5 |
| aiofile | 1366.6 | 1366.6 | 4.7 | 7.2 | 7.4 | 0.04 | 0 | 44 | 5 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 5985.9 MB/s (5985.9 ops/s)
- **p95 Latency**: 1.3 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **aiofiles**: 1.31x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.36x slower than asyncfiles-io_uring
- **anyio**: 1.63x slower than asyncfiles-io_uring
- **aiofile**: 4.38x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 7579.7 | 7579.7 | 3.2 | 4.4 | 4.5 | 0.04 | 0 | 56 | 5 |
| asyncfiles-io_uring | 7574.6 | 7574.6 | 3.2 | 4.0 | 4.3 | 0.04 | 0 | 56 | 5 |
| aiofiles | 5237.1 | 5237.1 | 5.3 | 6.0 | 6.1 | 0.05 | 0 | 57 | 5 |
| anyio | 3631.9 | 3631.9 | 7.2 | 9.3 | 9.9 | 0.11 | 0 | 56 | 5 |
| aiofile | 2576.8 | 2576.8 | 9.3 | 12.6 | 13.6 | 0.12 | 0 | 89 | 5 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 7579.7 MB/s (7579.7 ops/s)
- **p95 Latency**: 4.4 ms
- **CPU Time**: 0.04 s
- **Peak Memory**: 56 MB

## Performance Comparison

- **asyncfiles-io_uring**: about the same as asyncfiles-libuv
- **aiofiles**: 1.45x slower than asyncfiles-libuv
- **anyio**: 2.09x slower than asyncfiles-libuv
- **aiofile**: 2.94x slower than asyncfiles-libuv


---

# Benchmark Results: 16MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 3500.8 | 218.8 | 4.6 | 4.6 | 4.6 | 0.07 | 0 | 126 | 5 |
| asyncfiles-io_uring | 3394.4 | 212.2 | 4.6 | 5.1 | 5.1 | 0.03 | 0 | 126 | 5 |
| asyncfiles-libuv | 3385.7 | 211.6 | 4.8 | 4.8 | 4.8 | 0.03 | 0 | 126 | 5 |
| aiofiles | 3355.3 | 209.7 | 4.6 | 5.1 | 5.1 | 0.03 | 0 | 126 | 5 |
| aiofile | 2277.9 | 142.4 | 7.2 | 7.5 | 7.5 | 0.06 | 0 | 126 | 5 |

## 🏆 Winner: **anyio**

- **Throughput**: 3500.8 MB/s (218.8 ops/s)
- **p95 Latency**: 4.6 ms
- **CPU Time**: 0.07 s
- **Peak Memory**: 126 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.03x slower than anyio
- **asyncfiles-libuv**: 1.03x slower than anyio
- **aiofiles**: 1.04x slower than anyio
- **aiofile**: 1.54x slower than anyio


---

# Benchmark Results: 16MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 6170.1 | 385.6 | 15.7 | 23.2 | 25.5 | 0.19 | 0 | 371 | 5 |
| asyncfiles-io_uring | 6072.7 | 379.5 | 13.4 | 21.9 | 23.1 | 0.20 | 0 | 367 | 5 |
| anyio | 5229.2 | 326.8 | 18.7 | 38.6 | 40.4 | 0.25 | 0 | 374 | 5 |
| aiofiles | 5056.6 | 316.0 | 18.0 | 29.2 | 31.1 | 0.20 | 0 | 297 | 5 |
| aiofile | 3086.4 | 192.9 | 40.5 | 43.6 | 43.6 | 0.36 | 0 | 332 | 5 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 6170.1 MB/s (385.6 ops/s)
- **p95 Latency**: 23.2 ms
- **CPU Time**: 0.19 s
- **Peak Memory**: 371 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.02x slower than asyncfiles-libuv
- **anyio**: 1.18x slower than asyncfiles-libuv
- **aiofiles**: 1.22x slower than asyncfiles-libuv
- **aiofile**: 2.00x slower than asyncfiles-libuv
