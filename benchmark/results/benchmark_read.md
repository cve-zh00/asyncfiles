# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.8.0-117-generic (aarch64)
- **Iterations**: 5
- **Concurrency**: 1, 8, 32
- **File sizes**: 4KB, 1MB, 16MB
- **Page cache**: cold (evicted)
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32
- **Generated**: 2026-10-26 17:08 UTC

## Summary

Scenarios won (highest throughput) out of 8:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 3 |
| aiofiles | 3 |
| asyncfiles-libuv | 1 |
| anyio | 1 |


---

# Benchmark Results: 4KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 26.3 | 6723.3 | 0.1 | 0.1 | 0.1 | 0.00 | 0 | 21 | 5 |
| anyio | 25.7 | 6591.4 | 0.1 | 0.2 | 0.2 | 0.00 | 0 | 23 | 5 |
| asyncfiles-libuv | 18.1 | 4636.6 | 0.2 | 0.2 | 0.2 | 0.00 | 0 | 21 | 5 |
| aiofiles | 17.9 | 4588.2 | 0.2 | 0.2 | 0.2 | 0.00 | 0 | 21 | 5 |
| aiofile | 10.9 | 2788.5 | 0.3 | 0.5 | 0.5 | 0.00 | 0 | 22 | 5 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 26.3 MB/s (6723.3 ops/s)
- **p95 Latency**: 0.1 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 21 MB

## Performance Comparison

- **anyio**: 1.02x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.45x slower than asyncfiles-io_uring
- **aiofiles**: 1.47x slower than asyncfiles-io_uring
- **aiofile**: 2.41x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 171.0 | 43780.3 | 0.1 | 0.2 | 0.2 | 0.00 | 0 | 23 | 5 |
| aiofile | 55.9 | 14308.5 | 0.4 | 1.0 | 1.0 | 0.01 | 0 | 23 | 5 |
| asyncfiles-libuv | 52.5 | 13439.0 | 0.3 | 0.4 | 0.5 | 0.00 | 0 | 23 | 5 |
| aiofiles | 35.2 | 9017.9 | 0.6 | 1.0 | 1.0 | 0.01 | 0 | 23 | 5 |
| anyio | 12.7 | 3242.4 | 2.0 | 4.1 | 4.8 | 0.02 | 0 | 23 | 5 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 171.0 MB/s (43780.3 ops/s)
- **p95 Latency**: 0.2 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **aiofile**: 3.06x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 3.26x slower than asyncfiles-io_uring
- **aiofiles**: 4.85x slower than asyncfiles-io_uring
- **anyio**: 13.50x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 233.6 | 59800.9 | 0.3 | 0.4 | 0.5 | 0.00 | 0 | 24 | 5 |
| asyncfiles-libuv | 138.2 | 35373.4 | 0.5 | 0.8 | 0.8 | 0.01 | 0 | 24 | 5 |
| aiofile | 90.8 | 23234.1 | 1.0 | 2.0 | 2.1 | 0.02 | 0 | 24 | 5 |
| aiofiles | 41.4 | 10585.8 | 2.7 | 2.9 | 2.9 | 0.02 | 0 | 24 | 5 |
| anyio | 27.3 | 6983.5 | 3.0 | 9.2 | 9.3 | 0.04 | 0 | 25 | 5 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 233.6 MB/s (59800.9 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 24 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.69x slower than asyncfiles-io_uring
- **aiofile**: 2.57x slower than asyncfiles-io_uring
- **aiofiles**: 5.65x slower than asyncfiles-io_uring
- **anyio**: 8.56x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 3761.2 | 3761.2 | 0.2 | 0.4 | 0.4 | 0.00 | 0 | 27 | 5 |
| asyncfiles-io_uring | 3652.0 | 3652.0 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 28 | 5 |
| anyio | 3244.2 | 3244.2 | 0.2 | 0.4 | 0.4 | 0.00 | 0 | 31 | 5 |
| aiofile | 2418.6 | 2418.6 | 0.4 | 0.5 | 0.5 | 0.00 | 0 | 30 | 5 |
| aiofiles | 2226.7 | 2226.7 | 0.4 | 0.6 | 0.6 | 0.00 | 0 | 29 | 5 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 3761.2 MB/s (3761.2 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 27 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.03x slower than asyncfiles-libuv
- **anyio**: 1.16x slower than asyncfiles-libuv
- **aiofile**: 1.56x slower than asyncfiles-libuv
- **aiofiles**: 1.69x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 5414.8 | 5414.8 | 1.2 | 1.6 | 1.6 | 0.01 | 0 | 31 | 5 |
| asyncfiles-libuv | 4623.7 | 4623.7 | 1.2 | 1.6 | 1.8 | 0.01 | 0 | 31 | 5 |
| anyio | 3919.8 | 3919.8 | 1.7 | 2.6 | 2.6 | 0.02 | 0 | 38 | 5 |
| asyncfiles-io_uring | 3722.4 | 3722.4 | 1.9 | 2.1 | 2.2 | 0.01 | 0 | 31 | 5 |
| aiofile | 3295.9 | 3295.9 | 1.6 | 3.4 | 3.4 | 0.03 | 0 | 39 | 5 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 5414.8 MB/s (5414.8 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 31 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.17x slower than aiofiles
- **anyio**: 1.38x slower than aiofiles
- **asyncfiles-io_uring**: 1.45x slower than aiofiles
- **aiofile**: 1.64x slower than aiofiles


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 5817.5 | 5817.5 | 5.0 | 5.9 | 6.0 | 0.05 | 0 | 44 | 5 |
| asyncfiles-libuv | 4807.8 | 4807.8 | 3.5 | 8.9 | 9.5 | 0.07 | 0 | 45 | 5 |
| asyncfiles-io_uring | 4127.9 | 4127.9 | 7.0 | 7.2 | 7.7 | 0.04 | 0 | 45 | 5 |
| aiofile | 4058.1 | 4058.1 | 6.5 | 8.1 | 8.6 | 0.08 | 0 | 46 | 5 |
| anyio | 3236.7 | 3236.7 | 8.4 | 12.6 | 12.7 | 0.09 | 0 | 53 | 5 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 5817.5 MB/s (5817.5 ops/s)
- **p95 Latency**: 5.9 ms
- **CPU Time**: 0.05 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.21x slower than aiofiles
- **asyncfiles-io_uring**: 1.41x slower than aiofiles
- **aiofile**: 1.43x slower than aiofiles
- **anyio**: 1.80x slower than aiofiles


---

# Benchmark Results: 16MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 5360.0 | 335.0 | 2.9 | 3.3 | 3.3 | 0.03 | 0 | 127 | 5 |
| asyncfiles-libuv | 4820.0 | 301.2 | 3.5 | 4.0 | 4.0 | 0.02 | 0 | 68 | 5 |
| asyncfiles-io_uring | 4724.7 | 295.3 | 3.2 | 4.0 | 4.0 | 0.02 | 0 | 84 | 5 |
| aiofile | 4598.1 | 287.4 | 3.3 | 4.0 | 4.0 | 0.03 | 0 | 113 | 5 |
| aiofiles | 4245.6 | 265.3 | 3.4 | 5.1 | 5.1 | 0.02 | 0 | 98 | 5 |

## 🏆 Winner: **anyio**

- **Throughput**: 5360.0 MB/s (335.0 ops/s)
- **p95 Latency**: 3.3 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 127 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.11x slower than anyio
- **asyncfiles-io_uring**: 1.13x slower than anyio
- **aiofile**: 1.17x slower than anyio
- **aiofiles**: 1.26x slower than anyio


---

# Benchmark Results: 16MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 8732.4 | 545.8 | 13.9 | 16.4 | 17.0 | 0.15 | 0 | 328 | 5 |
| anyio | 6062.3 | 378.9 | 15.7 | 31.4 | 32.7 | 0.22 | 0 | 427 | 5 |
| asyncfiles-libuv | 5890.7 | 368.2 | 15.8 | 24.0 | 24.3 | 0.20 | 0 | 137 | 5 |
| aiofile | 4435.0 | 277.2 | 19.7 | 27.9 | 33.0 | 0.29 | 0 | 454 | 5 |
| asyncfiles-io_uring | 3314.8 | 207.2 | 35.4 | 39.3 | 40.1 | 0.21 | 0 | 367 | 5 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 8732.4 MB/s (545.8 ops/s)
- **p95 Latency**: 16.4 ms
- **CPU Time**: 0.15 s
- **Peak Memory**: 328 MB

## Performance Comparison

- **anyio**: 1.44x slower than aiofiles
- **asyncfiles-libuv**: 1.48x slower than aiofiles
- **aiofile**: 1.97x slower than aiofiles
- **asyncfiles-io_uring**: 2.63x slower than aiofiles
