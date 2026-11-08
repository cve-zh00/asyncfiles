# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-08 00:29 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 10 |
| asyncfiles-libuv | 1 |
| aiofiles | 1 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1020.4 | 4081.8 | 0.2 | 0.3 | 0.3 | 0.01 | 0 | 22 | 50 |
| asyncfiles-libuv | 897.5 | 3589.9 | 0.3 | 0.3 | 0.4 | 0.01 | 0 | 23 | 50 |
| aiofiles | 674.2 | 2696.8 | 0.3 | 0.4 | 1.6 | 0.02 | 0 | 23 | 50 |
| anyio | 655.8 | 2623.3 | 0.4 | 0.4 | 0.5 | 0.06 | 0 | 23 | 50 |
| aiofile | 251.6 | 1006.3 | 0.7 | 3.8 | 4.2 | 0.07 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1020.4 MB/s (4081.8 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.14x slower than asyncfiles-io_uring
- **aiofiles**: 1.51x slower than asyncfiles-io_uring
- **anyio**: 1.56x slower than asyncfiles-io_uring
- **aiofile**: 4.06x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2697.4 | 10789.5 | 0.5 | 0.7 | 2.5 | 0.06 | 0 | 30 | 50 |
| asyncfiles-libuv | 2453.9 | 9815.5 | 0.5 | 0.7 | 5.8 | 0.08 | 0 | 29 | 50 |
| aiofiles | 1098.5 | 4394.1 | 1.5 | 1.9 | 3.5 | 0.16 | 0 | 31 | 50 |
| anyio | 806.3 | 3225.2 | 1.9 | 3.0 | 7.3 | 0.26 | 0 | 30 | 50 |
| aiofile | 270.1 | 1080.4 | 8.1 | 9.7 | 10.1 | 0.52 | 0 | 31 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2697.4 MB/s (10789.5 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.06 s
- **Peak Memory**: 30 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.10x slower than asyncfiles-io_uring
- **aiofiles**: 2.46x slower than asyncfiles-io_uring
- **anyio**: 3.35x slower than asyncfiles-io_uring
- **aiofile**: 9.99x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2732.4 | 10929.6 | 1.1 | 1.4 | 1.8 | 0.14 | 0 | 31 | 50 |
| asyncfiles-libuv | 1496.8 | 5987.0 | 0.8 | 9.2 | 10.0 | 0.15 | 0 | 35 | 50 |
| aiofiles | 1198.0 | 4792.0 | 2.7 | 3.3 | 11.4 | 0.30 | 0 | 35 | 50 |
| anyio | 741.1 | 2964.6 | 3.4 | 13.0 | 15.1 | 0.53 | 0 | 35 | 50 |
| aiofile | 270.2 | 1080.8 | 9.8 | 19.4 | 19.6 | 1.05 | 0 | 36 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2732.4 MB/s (10929.6 ops/s)
- **p95 Latency**: 1.4 ms
- **CPU Time**: 0.14 s
- **Peak Memory**: 31 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.83x slower than asyncfiles-io_uring
- **aiofiles**: 2.28x slower than asyncfiles-io_uring
- **anyio**: 3.69x slower than asyncfiles-io_uring
- **aiofile**: 10.11x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1376.7 | 5506.9 | 2.1 | 10.9 | 61.1 | 0.27 | 0 | 36 | 50 |
| anyio | 1072.9 | 4291.5 | 6.5 | 7.4 | 10.3 | 0.79 | 0 | 36 | 50 |
| aiofiles | 1040.2 | 4160.8 | 5.1 | 10.2 | 10.6 | 0.60 | 0 | 42 | 50 |
| asyncfiles-libuv | 965.9 | 3863.7 | 1.6 | 19.2 | 68.1 | 0.32 | 0 | 43 | 50 |
| aiofile | 252.5 | 1010.0 | 19.7 | 29.9 | 72.3 | 2.22 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1376.7 MB/s (5506.9 ops/s)
- **p95 Latency**: 10.9 ms
- **CPU Time**: 0.27 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **anyio**: 1.28x slower than asyncfiles-io_uring
- **aiofiles**: 1.32x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.43x slower than asyncfiles-io_uring
- **aiofile**: 5.45x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 1458.0 | 2915.9 | 0.3 | 0.4 | 0.4 | 0.06 | 0 | 38 | 50 |
| asyncfiles-io_uring | 1457.8 | 2915.7 | 0.3 | 0.4 | 1.0 | 0.01 | 0 | 38 | 50 |
| aiofiles | 759.4 | 1518.8 | 0.4 | 1.6 | 5.1 | 0.02 | 0 | 38 | 50 |
| anyio | 442.4 | 884.8 | 0.5 | 3.0 | 9.5 | 0.12 | 0 | 38 | 50 |
| aiofile | 269.8 | 539.6 | 0.9 | 5.9 | 6.0 | 0.11 | 0 | 38 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 1458.0 MB/s (2915.9 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.06 s
- **Peak Memory**: 38 MB

## Performance Comparison

- **asyncfiles-io_uring**: about the same as asyncfiles-libuv
- **aiofiles**: 1.92x slower than asyncfiles-libuv
- **anyio**: 3.30x slower than asyncfiles-libuv
- **aiofile**: 5.40x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 1950.9 | 3901.9 | 1.8 | 2.1 | 2.3 | 0.21 | 0 | 40 | 50 |
| asyncfiles-libuv | 1738.6 | 3477.2 | 0.7 | 9.5 | 9.8 | 0.12 | 0 | 41 | 50 |
| anyio | 1480.5 | 2961.1 | 2.2 | 2.5 | 2.8 | 0.32 | 0 | 41 | 50 |
| asyncfiles-io_uring | 1108.1 | 2216.1 | 0.7 | 2.9 | 13.9 | 0.11 | 0 | 44 | 50 |
| aiofile | 271.0 | 542.1 | 10.0 | 19.6 | 20.5 | 0.94 | 0 | 45 | 50 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 1950.9 MB/s (3901.9 ops/s)
- **p95 Latency**: 2.1 ms
- **CPU Time**: 0.21 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.12x slower than aiofiles
- **anyio**: 1.32x slower than aiofiles
- **asyncfiles-io_uring**: 1.76x slower than aiofiles
- **aiofile**: 7.20x slower than aiofiles


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3961.0 | 7922.0 | 1.5 | 3.0 | 9.0 | 0.20 | 0 | 43 | 50 |
| asyncfiles-libuv | 2323.6 | 4647.2 | 1.1 | 9.8 | 19.5 | 0.22 | 0 | 43 | 50 |
| aiofiles | 2117.3 | 4234.7 | 3.0 | 3.5 | 6.4 | 0.37 | 0 | 43 | 50 |
| anyio | 1841.6 | 3683.2 | 3.7 | 4.3 | 10.7 | 0.50 | 0 | 42 | 50 |
| aiofile | 271.1 | 542.1 | 29.0 | 29.7 | 29.9 | 1.86 | 0 | 50 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3961.0 MB/s (7922.0 ops/s)
- **p95 Latency**: 3.0 ms
- **CPU Time**: 0.20 s
- **Peak Memory**: 43 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.70x slower than asyncfiles-io_uring
- **aiofiles**: 1.87x slower than asyncfiles-io_uring
- **anyio**: 2.15x slower than asyncfiles-io_uring
- **aiofile**: 14.61x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4481.8 | 8963.5 | 3.1 | 4.0 | 7.6 | 0.41 | 0 | 45 | 50 |
| asyncfiles-libuv | 2475.7 | 4951.4 | 2.0 | 27.3 | 31.9 | 0.45 | 0 | 61 | 50 |
| aiofiles | 2218.8 | 4437.6 | 5.8 | 8.9 | 21.5 | 0.75 | 0 | 45 | 50 |
| anyio | 1335.7 | 2671.3 | 7.1 | 10.6 | 12.6 | 0.96 | 0 | 59 | 50 |
| aiofile | 262.7 | 525.4 | 43.2 | 61.9 | 94.2 | 3.93 | 0 | 62 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4481.8 MB/s (8963.5 ops/s)
- **p95 Latency**: 4.0 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.81x slower than asyncfiles-io_uring
- **aiofiles**: 2.02x slower than asyncfiles-io_uring
- **anyio**: 3.36x slower than asyncfiles-io_uring
- **aiofile**: 17.06x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2263.8 | 2263.8 | 0.4 | 0.5 | 0.6 | 0.02 | 0 | 53 | 50 |
| asyncfiles-libuv | 1999.3 | 1999.3 | 0.5 | 0.6 | 0.6 | 0.02 | 0 | 53 | 50 |
| aiofiles | 1646.1 | 1646.1 | 0.6 | 0.7 | 0.8 | 0.03 | 0 | 53 | 50 |
| anyio | 1513.3 | 1513.3 | 0.6 | 0.8 | 1.9 | 0.11 | 0 | 53 | 50 |
| aiofile | 275.5 | 275.5 | 1.2 | 8.6 | 8.6 | 0.21 | 0 | 53 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2263.8 MB/s (2263.8 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 53 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.13x slower than asyncfiles-io_uring
- **aiofiles**: 1.38x slower than asyncfiles-io_uring
- **anyio**: 1.50x slower than asyncfiles-io_uring
- **aiofile**: 8.22x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 5097.2 | 5097.2 | 1.1 | 1.5 | 7.3 | 0.18 | 0 | 53 | 50 |
| aiofiles | 3102.6 | 3102.6 | 2.2 | 2.6 | 5.7 | 0.29 | 0 | 54 | 50 |
| anyio | 2607.4 | 2607.4 | 2.5 | 3.1 | 4.7 | 0.36 | 0 | 53 | 50 |
| asyncfiles-libuv | 1896.4 | 1896.4 | 1.1 | 15.3 | 19.9 | 0.20 | 0 | 53 | 50 |
| aiofile | 273.3 | 273.3 | 29.2 | 29.7 | 29.8 | 1.76 | 0 | 62 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 5097.2 MB/s (5097.2 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 53 MB

## Performance Comparison

- **aiofiles**: 1.64x slower than asyncfiles-io_uring
- **anyio**: 1.95x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.69x slower than asyncfiles-io_uring
- **aiofile**: 18.65x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4791.8 | 4791.8 | 2.2 | 2.9 | 7.2 | 0.38 | 0 | 61 | 50 |
| aiofiles | 3384.9 | 3384.9 | 3.9 | 5.9 | 10.5 | 0.55 | 0 | 61 | 50 |
| anyio | 2834.9 | 2834.9 | 4.7 | 6.7 | 13.9 | 0.67 | 0 | 56 | 50 |
| asyncfiles-libuv | 2271.4 | 2271.4 | 1.7 | 27.9 | 46.2 | 0.38 | 0 | 77 | 50 |
| aiofile | 271.6 | 271.6 | 58.4 | 59.5 | 79.1 | 3.50 | 0 | 72 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4791.8 MB/s (4791.8 ops/s)
- **p95 Latency**: 2.9 ms
- **CPU Time**: 0.38 s
- **Peak Memory**: 61 MB

## Performance Comparison

- **aiofiles**: 1.42x slower than asyncfiles-io_uring
- **anyio**: 1.69x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.11x slower than asyncfiles-io_uring
- **aiofile**: 17.65x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 354.8 | 354.8 | 88.4 | 93.4 | 98.6 | 0.77 | 0 | 90 | 50 |
| asyncfiles-libuv | 349.4 | 349.4 | 3.3 | 97.7 | 104.4 | 0.79 | 0 | 90 | 50 |
| aiofiles | 326.2 | 326.2 | 7.5 | 98.6 | 108.6 | 1.07 | 0 | 90 | 50 |
| anyio | 323.9 | 323.9 | 8.9 | 98.5 | 107.8 | 1.31 | 0 | 91 | 50 |
| aiofile | 268.3 | 268.3 | 88.4 | 124.5 | 127.4 | 7.15 | 0 | 91 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 354.8 MB/s (354.8 ops/s)
- **p95 Latency**: 93.4 ms
- **CPU Time**: 0.77 s
- **Peak Memory**: 90 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 1.09x slower than asyncfiles-io_uring
- **anyio**: 1.10x slower than asyncfiles-io_uring
- **aiofile**: 1.32x slower than asyncfiles-io_uring
