# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.17.0-1022-azure (x86_64)
- **Iterations**: 10
- **Concurrency**: 1, 8, 32
- **File sizes**: 4KB, 1MB, 16MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32
- **Generated**: 2026-10-26 18:39 UTC

## Summary

Scenarios won (highest throughput) out of 8:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 4 |
| asyncfiles-io_uring | 2 |
| aiofiles | 2 |


---

# Benchmark Results: 4KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 16.3 | 4180.1 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 21 | 10 |
| asyncfiles-io_uring | 15.9 | 4081.2 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 21 | 10 |
| anyio | 11.9 | 3042.9 | 0.3 | 0.4 | 0.4 | 0.01 | 0 | 21 | 10 |
| aiofiles | 11.0 | 2805.1 | 0.3 | 0.4 | 0.4 | 0.00 | 0 | 21 | 10 |
| aiofile | 6.2 | 1594.0 | 0.6 | 0.7 | 0.7 | 0.01 | 0 | 21 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 16.3 MB/s (4180.1 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 21 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.02x slower than asyncfiles-libuv
- **anyio**: 1.37x slower than asyncfiles-libuv
- **aiofiles**: 1.49x slower than asyncfiles-libuv
- **aiofile**: 2.62x slower than asyncfiles-libuv


---

# Benchmark Results: 4KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 60.6 | 15509.3 | 0.3 | 0.5 | 0.5 | 0.02 | 0 | 22 | 10 |
| asyncfiles-io_uring | 60.6 | 15507.1 | 0.4 | 0.5 | 0.5 | 0.01 | 0 | 22 | 10 |
| aiofiles | 18.9 | 4838.4 | 1.4 | 1.6 | 1.7 | 0.03 | 0 | 22 | 10 |
| aiofile | 16.2 | 4139.7 | 1.4 | 2.3 | 2.4 | 0.04 | 0 | 22 | 10 |
| anyio | 16.1 | 4127.0 | 1.7 | 2.0 | 2.1 | 0.05 | 0 | 23 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 60.6 MB/s (15509.3 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-io_uring**: about the same as asyncfiles-libuv
- **aiofiles**: 3.21x slower than asyncfiles-libuv
- **aiofile**: 3.75x slower than asyncfiles-libuv
- **anyio**: 3.76x slower than asyncfiles-libuv


---

# Benchmark Results: 4KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 80.8 | 20695.4 | 1.3 | 1.4 | 1.4 | 0.03 | 0 | 25 | 10 |
| asyncfiles-io_uring | 72.1 | 18445.1 | 1.5 | 1.7 | 1.7 | 0.02 | 0 | 25 | 10 |
| aiofile | 22.9 | 5862.7 | 4.1 | 5.2 | 5.8 | 0.14 | 0 | 25 | 10 |
| aiofiles | 20.8 | 5317.0 | 4.6 | 10.5 | 11.2 | 0.10 | 0 | 25 | 10 |
| anyio | 18.4 | 4699.5 | 5.9 | 10.6 | 11.0 | 0.16 | 0 | 25 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 80.8 MB/s (20695.4 ops/s)
- **p95 Latency**: 1.4 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 25 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.12x slower than asyncfiles-libuv
- **aiofile**: 3.53x slower than asyncfiles-libuv
- **aiofiles**: 3.89x slower than asyncfiles-libuv
- **anyio**: 4.40x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2314.4 | 2314.4 | 0.4 | 0.5 | 0.5 | 0.00 | 0 | 36 | 10 |
| asyncfiles-libuv | 2008.0 | 2008.0 | 0.5 | 0.5 | 0.5 | 0.02 | 0 | 35 | 10 |
| anyio | 1839.7 | 1839.7 | 0.5 | 0.5 | 0.5 | 0.04 | 0 | 36 | 10 |
| aiofiles | 1196.7 | 1196.7 | 0.5 | 3.5 | 3.5 | 0.00 | 0 | 36 | 10 |
| aiofile | 259.7 | 259.7 | 1.4 | 8.8 | 8.8 | 0.04 | 0 | 36 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2314.4 MB/s (2314.4 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.15x slower than asyncfiles-io_uring
- **anyio**: 1.26x slower than asyncfiles-io_uring
- **aiofiles**: 1.93x slower than asyncfiles-io_uring
- **aiofile**: 8.91x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 7356.1 | 7356.1 | 0.8 | 1.0 | 1.1 | 0.03 | 0 | 42 | 10 |
| asyncfiles-io_uring | 4269.8 | 4269.8 | 1.0 | 7.2 | 7.3 | 0.03 | 0 | 42 | 10 |
| aiofiles | 3943.3 | 3943.3 | 1.7 | 2.2 | 2.3 | 0.05 | 0 | 42 | 10 |
| anyio | 3239.1 | 3239.1 | 2.2 | 2.5 | 2.6 | 0.14 | 0 | 42 | 10 |
| aiofile | 272.5 | 272.5 | 29.3 | 29.7 | 29.8 | 0.34 | 0 | 50 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 7356.1 MB/s (7356.1 ops/s)
- **p95 Latency**: 1.0 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 42 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.72x slower than asyncfiles-libuv
- **aiofiles**: 1.87x slower than asyncfiles-libuv
- **anyio**: 2.27x slower than asyncfiles-libuv
- **aiofile**: 26.99x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 341.4 | 341.4 | 93.7 | 96.7 | 96.8 | 0.12 | 0 | 90 | 10 |
| anyio | 335.7 | 335.7 | 7.6 | 95.5 | 102.9 | 0.29 | 0 | 91 | 10 |
| asyncfiles-libuv | 333.4 | 333.4 | 3.0 | 99.1 | 118.7 | 0.13 | 0 | 91 | 10 |
| aiofiles | 311.8 | 311.8 | 7.2 | 105.2 | 120.6 | 0.19 | 0 | 90 | 10 |
| aiofile | 268.1 | 268.1 | 92.1 | 121.8 | 123.8 | 1.38 | 0 | 91 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 341.4 MB/s (341.4 ops/s)
- **p95 Latency**: 96.7 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 90 MB

## Performance Comparison

- **anyio**: 1.02x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 1.10x slower than asyncfiles-io_uring
- **aiofile**: 1.27x slower than asyncfiles-io_uring


---

# Benchmark Results: 16MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 4108.9 | 256.8 | 3.8 | 4.1 | 4.1 | 0.04 | 0 | 194 | 10 |
| anyio | 4081.9 | 255.1 | 3.9 | 4.0 | 4.0 | 0.13 | 0 | 193 | 10 |
| asyncfiles-io_uring | 3715.4 | 232.2 | 4.0 | 6.7 | 6.7 | 0.05 | 0 | 193 | 10 |
| asyncfiles-libuv | 1139.4 | 71.2 | 4.1 | 59.1 | 59.1 | 0.04 | 0 | 210 | 10 |
| aiofile | 270.1 | 16.9 | 59.2 | 59.5 | 59.5 | 0.64 | 0 | 210 | 10 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 4108.9 MB/s (256.8 ops/s)
- **p95 Latency**: 4.1 ms
- **CPU Time**: 0.04 s
- **Peak Memory**: 194 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofiles
- **asyncfiles-io_uring**: 1.11x slower than aiofiles
- **asyncfiles-libuv**: 3.61x slower than aiofiles
- **aiofile**: 15.21x slower than aiofiles


---

# Benchmark Results: 16MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 313.5 | 19.6 | 274.2 | 455.3 | 473.0 | 0.58 | 0 | 447 | 10 |
| asyncfiles-libuv | 308.6 | 19.3 | 272.5 | 452.7 | 453.1 | 0.57 | 0 | 446 | 10 |
| asyncfiles-io_uring | 282.3 | 17.6 | 273.6 | 453.1 | 453.4 | 0.51 | 0 | 446 | 10 |
| anyio | 270.3 | 16.9 | 364.3 | 493.3 | 503.3 | 0.59 | 0 | 447 | 10 |
| aiofile | 268.5 | 16.8 | 468.0 | 488.3 | 488.4 | 3.82 | 0 | 447 | 10 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 313.5 MB/s (19.6 ops/s)
- **p95 Latency**: 455.3 ms
- **CPU Time**: 0.58 s
- **Peak Memory**: 447 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than aiofiles
- **asyncfiles-io_uring**: 1.11x slower than aiofiles
- **anyio**: 1.16x slower than aiofiles
- **aiofile**: 1.17x slower than aiofiles
