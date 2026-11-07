# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Page cache**: cold (evicted)
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-07 23:11 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 6 |
| asyncfiles-io_uring | 5 |
| aiofile | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 498.4 | 1993.5 | 0.5 | 0.7 | 0.9 | 0.01 | 0 | 20 | 50 |
| asyncfiles-libuv | 389.0 | 1556.0 | 0.6 | 0.9 | 1.0 | 0.01 | 0 | 20 | 50 |
| aiofiles | 325.1 | 1300.3 | 0.7 | 1.1 | 1.2 | 0.02 | 0 | 21 | 50 |
| anyio | 266.8 | 1067.2 | 0.8 | 1.3 | 4.9 | 0.07 | 0 | 22 | 50 |
| aiofile | 233.3 | 933.2 | 0.7 | 1.1 | 7.9 | 0.10 | 0 | 21 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 498.4 MB/s (1993.5 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.28x slower than asyncfiles-io_uring
- **aiofiles**: 1.53x slower than asyncfiles-io_uring
- **anyio**: 1.87x slower than asyncfiles-io_uring
- **aiofile**: 2.14x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 544.0 | 2176.0 | 2.5 | 3.7 | 18.5 | 0.41 | 0 | 29 | 50 |
| anyio | 539.5 | 2157.8 | 3.1 | 4.1 | 4.7 | 0.32 | 0 | 30 | 50 |
| asyncfiles-io_uring | 512.3 | 2049.1 | 1.3 | 7.5 | 20.0 | 0.07 | 0 | 25 | 50 |
| asyncfiles-libuv | 504.9 | 2019.5 | 1.4 | 5.9 | 7.1 | 0.13 | 0 | 26 | 50 |
| aiofiles | 500.4 | 2001.5 | 2.5 | 4.5 | 20.0 | 0.20 | 0 | 27 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 544.0 MB/s (2176.0 ops/s)
- **p95 Latency**: 3.7 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 29 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofile
- **asyncfiles-io_uring**: 1.06x slower than aiofile
- **asyncfiles-libuv**: 1.08x slower than aiofile
- **aiofiles**: 1.09x slower than aiofile


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 508.9 | 2035.4 | 2.9 | 9.4 | 20.8 | 0.14 | 0 | 34 | 50 |
| aiofiles | 503.9 | 2015.5 | 4.7 | 9.5 | 28.5 | 0.39 | 0 | 33 | 50 |
| asyncfiles-libuv | 501.8 | 2007.3 | 2.5 | 8.8 | 20.2 | 0.26 | 0 | 35 | 50 |
| aiofile | 466.6 | 1866.4 | 4.9 | 16.9 | 32.3 | 0.83 | 0 | 35 | 50 |
| anyio | 403.3 | 1613.3 | 5.4 | 19.3 | 34.5 | 0.51 | 0 | 35 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 508.9 MB/s (2035.4 ops/s)
- **p95 Latency**: 9.4 ms
- **CPU Time**: 0.14 s
- **Peak Memory**: 34 MB

## Performance Comparison

- **aiofiles**: 1.01x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.09x slower than asyncfiles-io_uring
- **anyio**: 1.26x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 513.6 | 2054.5 | 8.0 | 17.2 | 28.9 | 0.51 | 0 | 47 | 50 |
| aiofile | 414.6 | 1658.3 | 9.5 | 29.9 | 38.2 | 1.70 | 0 | 48 | 50 |
| aiofiles | 409.8 | 1639.4 | 11.2 | 35.4 | 57.6 | 0.82 | 0 | 42 | 50 |
| asyncfiles-io_uring | 399.4 | 1597.5 | 9.6 | 32.5 | 40.6 | 0.29 | 0 | 47 | 50 |
| anyio | 382.1 | 1528.3 | 10.1 | 37.4 | 46.4 | 0.97 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 513.6 MB/s (2054.5 ops/s)
- **p95 Latency**: 17.2 ms
- **CPU Time**: 0.51 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **aiofile**: 1.24x slower than asyncfiles-libuv
- **aiofiles**: 1.25x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.29x slower than asyncfiles-libuv
- **anyio**: 1.34x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 547.5 | 1094.9 | 0.9 | 1.1 | 1.4 | 0.01 | 0 | 36 | 50 |
| asyncfiles-libuv | 453.7 | 907.5 | 1.1 | 1.2 | 1.5 | 0.02 | 0 | 36 | 50 |
| aiofile | 373.4 | 746.8 | 1.3 | 1.4 | 1.5 | 0.09 | 0 | 39 | 50 |
| aiofiles | 320.2 | 640.4 | 1.2 | 2.9 | 10.8 | 0.03 | 0 | 38 | 50 |
| anyio | 314.7 | 629.3 | 1.2 | 1.3 | 10.3 | 0.09 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 547.5 MB/s (1094.9 ops/s)
- **p95 Latency**: 1.1 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.21x slower than asyncfiles-io_uring
- **aiofile**: 1.47x slower than asyncfiles-io_uring
- **aiofiles**: 1.71x slower than asyncfiles-io_uring
- **anyio**: 1.74x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 500.8 | 1001.6 | 8.2 | 10.0 | 20.3 | 0.12 | 0 | 45 | 50 |
| aiofiles | 500.6 | 1001.3 | 6.9 | 9.6 | 21.1 | 0.23 | 0 | 42 | 50 |
| asyncfiles-libuv | 497.7 | 995.3 | 3.0 | 9.1 | 27.0 | 0.20 | 0 | 45 | 50 |
| aiofile | 449.3 | 898.6 | 4.5 | 19.4 | 28.8 | 0.72 | 0 | 45 | 50 |
| anyio | 423.5 | 847.0 | 6.1 | 18.8 | 28.4 | 0.32 | 0 | 43 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 500.8 MB/s (1001.6 ops/s)
- **p95 Latency**: 10.0 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **aiofiles**: about the same as asyncfiles-io_uring
- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.11x slower than asyncfiles-io_uring
- **anyio**: 1.18x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 508.8 | 1017.7 | 8.9 | 19.1 | 29.6 | 0.41 | 0 | 55 | 50 |
| aiofiles | 401.0 | 802.0 | 10.1 | 38.3 | 48.6 | 0.49 | 0 | 51 | 50 |
| asyncfiles-io_uring | 391.2 | 782.4 | 10.5 | 38.9 | 45.7 | 0.24 | 0 | 55 | 50 |
| anyio | 391.1 | 782.2 | 10.3 | 34.9 | 36.5 | 0.65 | 0 | 48 | 50 |
| aiofile | 387.9 | 775.7 | 9.6 | 38.8 | 43.3 | 1.56 | 0 | 56 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 508.8 MB/s (1017.7 ops/s)
- **p95 Latency**: 19.1 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 55 MB

## Performance Comparison

- **aiofiles**: 1.27x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.30x slower than asyncfiles-libuv
- **anyio**: 1.30x slower than asyncfiles-libuv
- **aiofile**: 1.31x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 467.1 | 934.2 | 17.2 | 39.1 | 50.5 | 0.88 | 0 | 71 | 50 |
| aiofiles | 411.4 | 822.7 | 34.1 | 49.6 | 60.2 | 0.94 | 0 | 59 | 50 |
| anyio | 405.2 | 810.4 | 27.9 | 49.4 | 56.5 | 1.23 | 0 | 59 | 50 |
| asyncfiles-io_uring | 403.6 | 807.2 | 29.6 | 54.9 | 60.6 | 0.51 | 0 | 71 | 50 |
| aiofile | 403.2 | 806.5 | 27.7 | 48.2 | 76.9 | 2.97 | 0 | 69 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 467.1 MB/s (934.2 ops/s)
- **p95 Latency**: 39.1 ms
- **CPU Time**: 0.88 s
- **Peak Memory**: 71 MB

## Performance Comparison

- **aiofiles**: 1.14x slower than asyncfiles-libuv
- **anyio**: 1.15x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.16x slower than asyncfiles-libuv
- **aiofile**: 1.16x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 545.6 | 545.6 | 1.5 | 3.4 | 3.7 | 0.02 | 0 | 46 | 50 |
| asyncfiles-libuv | 540.9 | 540.9 | 1.7 | 2.6 | 2.9 | 0.02 | 0 | 46 | 50 |
| anyio | 538.6 | 538.6 | 1.7 | 2.5 | 2.8 | 0.08 | 0 | 52 | 50 |
| aiofiles | 516.6 | 516.6 | 1.9 | 2.3 | 3.0 | 0.04 | 0 | 51 | 50 |
| aiofile | 504.6 | 504.6 | 1.9 | 2.2 | 2.5 | 0.13 | 0 | 51 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 545.6 MB/s (545.6 ops/s)
- **p95 Latency**: 3.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **anyio**: 1.01x slower than asyncfiles-io_uring
- **aiofiles**: 1.06x slower than asyncfiles-io_uring
- **aiofile**: 1.08x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 537.4 | 537.4 | 9.4 | 18.3 | 19.1 | 0.34 | 0 | 65 | 50 |
| aiofiles | 410.0 | 410.0 | 10.9 | 33.5 | 42.0 | 0.28 | 0 | 58 | 50 |
| anyio | 407.4 | 407.4 | 11.2 | 40.6 | 50.7 | 0.40 | 0 | 60 | 50 |
| asyncfiles-io_uring | 403.8 | 403.8 | 10.8 | 36.3 | 45.3 | 0.21 | 0 | 65 | 50 |
| aiofile | 401.3 | 401.3 | 9.9 | 35.4 | 41.6 | 1.34 | 0 | 66 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 537.4 MB/s (537.4 ops/s)
- **p95 Latency**: 18.3 ms
- **CPU Time**: 0.34 s
- **Peak Memory**: 65 MB

## Performance Comparison

- **aiofiles**: 1.31x slower than asyncfiles-libuv
- **anyio**: 1.32x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.33x slower than asyncfiles-libuv
- **aiofile**: 1.34x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 460.1 | 460.1 | 18.1 | 42.1 | 51.6 | 0.69 | 0 | 83 | 50 |
| anyio | 409.1 | 409.1 | 30.1 | 52.2 | 60.1 | 0.72 | 0 | 77 | 50 |
| aiofile | 406.1 | 406.1 | 28.3 | 49.0 | 57.8 | 2.66 | 0 | 88 | 50 |
| aiofiles | 404.0 | 404.0 | 29.7 | 49.3 | 59.1 | 0.62 | 0 | 75 | 50 |
| asyncfiles-io_uring | 398.7 | 398.7 | 35.6 | 60.2 | 60.9 | 0.47 | 0 | 83 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 460.1 MB/s (460.1 ops/s)
- **p95 Latency**: 42.1 ms
- **CPU Time**: 0.69 s
- **Peak Memory**: 83 MB

## Performance Comparison

- **anyio**: 1.12x slower than asyncfiles-libuv
- **aiofile**: 1.13x slower than asyncfiles-libuv
- **aiofiles**: 1.14x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 426.6 | 426.6 | 38.1 | 79.4 | 95.2 | 1.42 | 0 | 123 | 50 |
| anyio | 403.9 | 403.9 | 61.1 | 96.5 | 103.3 | 1.53 | 0 | 96 | 50 |
| aiofiles | 400.4 | 400.4 | 66.7 | 94.9 | 97.9 | 1.31 | 0 | 95 | 50 |
| aiofile | 400.2 | 400.2 | 58.3 | 95.6 | 98.8 | 5.38 | 0 | 118 | 50 |
| asyncfiles-io_uring | 399.6 | 399.6 | 65.9 | 96.9 | 103.0 | 1.03 | 0 | 123 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 426.6 MB/s (426.6 ops/s)
- **p95 Latency**: 79.4 ms
- **CPU Time**: 1.42 s
- **Peak Memory**: 123 MB

## Performance Comparison

- **anyio**: 1.06x slower than asyncfiles-libuv
- **aiofiles**: 1.07x slower than asyncfiles-libuv
- **aiofile**: 1.07x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.07x slower than asyncfiles-libuv
