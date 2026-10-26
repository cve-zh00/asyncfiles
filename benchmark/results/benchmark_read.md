# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.17.0-1022-azure (x86_64)
- **Iterations**: 10
- **Concurrency**: 1, 8, 32
- **File sizes**: 4KB, 1MB, 16MB
- **Page cache**: cold (evicted)
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32
- **Generated**: 2026-10-26 18:39 UTC

## Summary

Scenarios won (highest throughput) out of 8:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 4 |
| asyncfiles-libuv | 2 |
| aiofile | 1 |
| anyio | 1 |


---

# Benchmark Results: 4KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 20.1 | 5135.8 | 0.2 | 0.2 | 0.2 | 0.00 | 0 | 20 | 10 |
| asyncfiles-libuv | 15.9 | 4065.8 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 20 | 10 |
| aiofiles | 15.3 | 3929.3 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 20 | 10 |
| aiofile | 13.5 | 3461.4 | 0.3 | 0.4 | 0.4 | 0.01 | 0 | 20 | 10 |
| anyio | 11.0 | 2807.6 | 0.3 | 0.4 | 0.4 | 0.01 | 0 | 21 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 20.1 MB/s (5135.8 ops/s)
- **p95 Latency**: 0.2 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.26x slower than asyncfiles-io_uring
- **aiofiles**: 1.31x slower than asyncfiles-io_uring
- **aiofile**: 1.48x slower than asyncfiles-io_uring
- **anyio**: 1.83x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 96.1 | 24606.0 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 22 | 10 |
| asyncfiles-libuv | 54.3 | 13912.9 | 0.3 | 0.5 | 1.5 | 0.01 | 0 | 21 | 10 |
| aiofile | 19.8 | 5063.1 | 1.3 | 1.6 | 1.7 | 0.04 | 0 | 22 | 10 |
| aiofiles | 18.3 | 4687.8 | 1.5 | 1.8 | 2.2 | 0.03 | 0 | 22 | 10 |
| anyio | 16.5 | 4223.1 | 1.7 | 2.3 | 2.3 | 0.05 | 0 | 22 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 96.1 MB/s (24606.0 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.77x slower than asyncfiles-io_uring
- **aiofile**: 4.86x slower than asyncfiles-io_uring
- **aiofiles**: 5.25x slower than asyncfiles-io_uring
- **anyio**: 5.83x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 139.2 | 35646.4 | 0.7 | 0.9 | 0.9 | 0.01 | 0 | 23 | 10 |
| asyncfiles-libuv | 71.3 | 18253.1 | 1.0 | 1.4 | 1.5 | 0.04 | 0 | 23 | 10 |
| aiofile | 24.4 | 6242.8 | 4.4 | 5.0 | 5.0 | 0.14 | 0 | 23 | 10 |
| aiofiles | 23.7 | 6064.3 | 4.8 | 5.4 | 5.6 | 0.09 | 0 | 23 | 10 |
| anyio | 20.0 | 5116.2 | 5.6 | 7.6 | 8.2 | 0.15 | 0 | 25 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 139.2 MB/s (35646.4 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.95x slower than asyncfiles-io_uring
- **aiofile**: 5.71x slower than asyncfiles-io_uring
- **aiofiles**: 5.88x slower than asyncfiles-io_uring
- **anyio**: 6.97x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 640.2 | 640.2 | 1.6 | 1.8 | 1.8 | 0.02 | 0 | 35 | 10 |
| asyncfiles-io_uring | 608.2 | 608.2 | 1.4 | 3.9 | 3.9 | 0.00 | 0 | 27 | 10 |
| aiofiles | 607.9 | 607.9 | 1.6 | 2.1 | 2.1 | 0.01 | 0 | 28 | 10 |
| asyncfiles-libuv | 594.6 | 594.6 | 1.5 | 2.9 | 2.9 | 0.00 | 0 | 26 | 10 |
| anyio | 594.0 | 594.0 | 1.5 | 3.3 | 3.3 | 0.02 | 0 | 36 | 10 |

## 🏆 Winner: **aiofile**

- **Throughput**: 640.2 MB/s (640.2 ops/s)
- **p95 Latency**: 1.8 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 35 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.05x slower than aiofile
- **aiofiles**: 1.05x slower than aiofile
- **asyncfiles-libuv**: 1.08x slower than aiofile
- **anyio**: 1.08x slower than aiofile


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 590.1 | 590.1 | 9.7 | 19.2 | 19.4 | 0.14 | 0 | 48 | 10 |
| aiofiles | 588.4 | 588.4 | 9.8 | 19.1 | 19.3 | 0.04 | 0 | 41 | 10 |
| aiofile | 575.5 | 575.5 | 8.8 | 18.0 | 18.6 | 0.20 | 0 | 50 | 10 |
| asyncfiles-io_uring | 563.3 | 563.3 | 10.4 | 18.5 | 18.6 | 0.05 | 0 | 49 | 10 |
| asyncfiles-libuv | 554.4 | 554.4 | 8.9 | 18.3 | 18.7 | 0.09 | 0 | 49 | 10 |

## 🏆 Winner: **anyio**

- **Throughput**: 590.1 MB/s (590.1 ops/s)
- **p95 Latency**: 19.2 ms
- **CPU Time**: 0.14 s
- **Peak Memory**: 48 MB

## Performance Comparison

- **aiofiles**: about the same as anyio
- **aiofile**: 1.03x slower than anyio
- **asyncfiles-io_uring**: 1.05x slower than anyio
- **asyncfiles-libuv**: 1.06x slower than anyio


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 550.9 | 550.9 | 26.5 | 55.9 | 58.0 | 0.22 | 0 | 105 | 10 |
| asyncfiles-io_uring | 440.1 | 440.1 | 58.3 | 95.8 | 95.8 | 0.18 | 0 | 106 | 10 |
| anyio | 414.1 | 414.1 | 66.0 | 87.4 | 88.1 | 0.33 | 0 | 93 | 10 |
| aiofiles | 413.6 | 413.6 | 58.7 | 89.5 | 96.8 | 0.20 | 0 | 82 | 10 |
| aiofile | 411.5 | 411.5 | 59.2 | 89.7 | 90.1 | 1.01 | 0 | 98 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 550.9 MB/s (550.9 ops/s)
- **p95 Latency**: 55.9 ms
- **CPU Time**: 0.22 s
- **Peak Memory**: 105 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.25x slower than asyncfiles-libuv
- **anyio**: 1.33x slower than asyncfiles-libuv
- **aiofiles**: 1.33x slower than asyncfiles-libuv
- **aiofile**: 1.34x slower than asyncfiles-libuv


---

# Benchmark Results: 16MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 566.0 | 35.4 | 29.4 | 29.8 | 29.8 | 0.03 | 0 | 99 | 10 |
| asyncfiles-libuv | 547.9 | 34.2 | 29.7 | 29.8 | 29.8 | 0.02 | 0 | 98 | 10 |
| aiofiles | 476.6 | 29.8 | 29.8 | 41.2 | 41.2 | 0.03 | 0 | 178 | 10 |
| anyio | 424.7 | 26.5 | 39.9 | 53.3 | 53.3 | 0.11 | 0 | 210 | 10 |
| aiofile | 406.7 | 25.4 | 38.0 | 66.2 | 66.2 | 0.40 | 0 | 194 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 566.0 MB/s (35.4 ops/s)
- **p95 Latency**: 29.8 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 99 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.03x slower than asyncfiles-io_uring
- **aiofiles**: 1.19x slower than asyncfiles-io_uring
- **anyio**: 1.33x slower than asyncfiles-io_uring
- **aiofile**: 1.39x slower than asyncfiles-io_uring


---

# Benchmark Results: 16MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 431.4 | 27.0 | 225.4 | 328.9 | 332.5 | 0.36 | 0 | 431 | 10 |
| anyio | 401.3 | 25.1 | 310.5 | 348.4 | 348.8 | 0.33 | 0 | 442 | 10 |
| aiofiles | 400.0 | 25.0 | 307.7 | 327.4 | 341.1 | 0.28 | 0 | 337 | 10 |
| aiofile | 397.2 | 24.8 | 308.5 | 342.0 | 344.6 | 3.42 | 0 | 465 | 10 |
| asyncfiles-io_uring | 397.0 | 24.8 | 304.1 | 340.8 | 344.0 | 0.39 | 0 | 433 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 431.4 MB/s (27.0 ops/s)
- **p95 Latency**: 328.9 ms
- **CPU Time**: 0.36 s
- **Peak Memory**: 431 MB

## Performance Comparison

- **anyio**: 1.08x slower than asyncfiles-libuv
- **aiofiles**: 1.08x slower than asyncfiles-libuv
- **aiofile**: 1.09x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.09x slower than asyncfiles-libuv
