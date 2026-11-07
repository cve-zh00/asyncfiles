# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-07 23:11 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 9 |
| asyncfiles-libuv | 3 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 718.1 | 2872.4 | 0.3 | 0.4 | 0.4 | 0.02 | 0 | 22 | 50 |
| asyncfiles-io_uring | 619.3 | 2477.2 | 0.3 | 0.4 | 3.2 | 0.01 | 0 | 23 | 50 |
| anyio | 418.5 | 1674.0 | 0.5 | 0.6 | 3.5 | 0.08 | 0 | 22 | 50 |
| aiofiles | 343.8 | 1375.0 | 0.4 | 0.5 | 14.4 | 0.02 | 0 | 22 | 50 |
| aiofile | 256.2 | 1024.9 | 0.8 | 2.5 | 2.9 | 0.07 | 0 | 22 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 718.1 MB/s (2872.4 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.16x slower than asyncfiles-libuv
- **anyio**: 1.72x slower than asyncfiles-libuv
- **aiofiles**: 2.09x slower than asyncfiles-libuv
- **aiofile**: 2.80x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1858.0 | 7432.1 | 0.7 | 0.8 | 6.0 | 0.08 | 0 | 30 | 50 |
| asyncfiles-libuv | 1501.0 | 6004.1 | 0.6 | 0.8 | 8.5 | 0.09 | 0 | 30 | 50 |
| aiofiles | 686.0 | 2744.1 | 2.4 | 2.9 | 6.2 | 0.21 | 0 | 30 | 50 |
| anyio | 590.1 | 2360.3 | 2.9 | 3.6 | 5.8 | 0.30 | 0 | 31 | 50 |
| aiofile | 236.4 | 945.5 | 6.9 | 9.7 | 30.3 | 0.61 | 0 | 30 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1858.0 MB/s (7432.1 ops/s)
- **p95 Latency**: 0.8 ms
- **CPU Time**: 0.08 s
- **Peak Memory**: 30 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.24x slower than asyncfiles-io_uring
- **aiofiles**: 2.71x slower than asyncfiles-io_uring
- **anyio**: 3.15x slower than asyncfiles-io_uring
- **aiofile**: 7.86x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2764.7 | 11058.9 | 0.8 | 1.8 | 7.2 | 0.14 | 0 | 32 | 50 |
| asyncfiles-io_uring | 2756.4 | 11025.6 | 1.1 | 1.4 | 3.8 | 0.12 | 0 | 35 | 50 |
| aiofiles | 832.6 | 3330.5 | 3.9 | 6.3 | 12.9 | 0.34 | 0 | 35 | 50 |
| anyio | 670.4 | 2681.6 | 5.2 | 6.2 | 9.8 | 0.50 | 0 | 35 | 50 |
| aiofile | 239.9 | 959.8 | 10.4 | 30.1 | 40.2 | 1.18 | 0 | 35 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2764.7 MB/s (11058.9 ops/s)
- **p95 Latency**: 1.8 ms
- **CPU Time**: 0.14 s
- **Peak Memory**: 32 MB

## Performance Comparison

- **asyncfiles-io_uring**: about the same as asyncfiles-libuv
- **aiofiles**: 3.32x slower than asyncfiles-libuv
- **anyio**: 4.12x slower than asyncfiles-libuv
- **aiofile**: 11.52x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2843.3 | 11373.1 | 2.1 | 2.7 | 8.7 | 0.27 | 0 | 36 | 50 |
| asyncfiles-libuv | 1431.4 | 5725.6 | 1.7 | 9.7 | 29.7 | 0.30 | 0 | 44 | 50 |
| aiofiles | 880.1 | 3520.6 | 7.9 | 9.1 | 12.4 | 0.71 | 0 | 36 | 50 |
| anyio | 724.4 | 2897.5 | 9.7 | 12.5 | 18.2 | 0.90 | 0 | 44 | 50 |
| aiofile | 234.9 | 939.5 | 21.2 | 44.5 | 53.3 | 2.43 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2843.3 MB/s (11373.1 ops/s)
- **p95 Latency**: 2.7 ms
- **CPU Time**: 0.27 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.99x slower than asyncfiles-io_uring
- **aiofiles**: 3.23x slower than asyncfiles-io_uring
- **anyio**: 3.93x slower than asyncfiles-io_uring
- **aiofile**: 12.11x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1120.7 | 2241.4 | 0.4 | 0.7 | 0.9 | 0.02 | 0 | 38 | 50 |
| asyncfiles-libuv | 760.9 | 1521.8 | 0.4 | 2.9 | 5.8 | 0.02 | 0 | 39 | 50 |
| aiofiles | 702.7 | 1405.4 | 0.6 | 0.7 | 3.3 | 0.03 | 0 | 38 | 50 |
| anyio | 689.3 | 1378.6 | 0.6 | 1.1 | 2.9 | 0.12 | 0 | 38 | 50 |
| aiofile | 256.1 | 512.2 | 1.5 | 3.9 | 4.8 | 0.13 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1120.7 MB/s (2241.4 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 38 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.47x slower than asyncfiles-io_uring
- **aiofiles**: 1.59x slower than asyncfiles-io_uring
- **anyio**: 1.63x slower than asyncfiles-io_uring
- **aiofile**: 4.38x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2014.1 | 4028.2 | 0.8 | 1.2 | 6.3 | 0.11 | 0 | 43 | 50 |
| asyncfiles-libuv | 1250.3 | 2500.6 | 0.7 | 2.6 | 6.1 | 0.13 | 0 | 43 | 50 |
| aiofiles | 1237.6 | 2475.2 | 2.6 | 3.9 | 6.5 | 0.24 | 0 | 43 | 50 |
| anyio | 1138.8 | 2277.6 | 3.0 | 3.7 | 5.8 | 0.35 | 0 | 41 | 50 |
| aiofile | 235.8 | 471.6 | 13.9 | 30.6 | 39.6 | 1.07 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2014.1 MB/s (4028.2 ops/s)
- **p95 Latency**: 1.2 ms
- **CPU Time**: 0.11 s
- **Peak Memory**: 43 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.61x slower than asyncfiles-io_uring
- **aiofiles**: 1.63x slower than asyncfiles-io_uring
- **anyio**: 1.77x slower than asyncfiles-io_uring
- **aiofile**: 8.54x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4276.4 | 8552.9 | 1.5 | 1.7 | 1.8 | 0.20 | 0 | 40 | 50 |
| asyncfiles-libuv | 3935.7 | 7871.3 | 1.2 | 2.3 | 6.9 | 0.24 | 0 | 40 | 50 |
| aiofiles | 1601.5 | 3203.0 | 4.3 | 4.9 | 6.2 | 0.42 | 0 | 47 | 50 |
| anyio | 1245.5 | 2491.0 | 5.5 | 7.9 | 10.8 | 0.56 | 0 | 39 | 50 |
| aiofile | 254.8 | 509.7 | 29.1 | 38.5 | 50.4 | 1.98 | 0 | 47 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4276.4 MB/s (8552.9 ops/s)
- **p95 Latency**: 1.7 ms
- **CPU Time**: 0.20 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.09x slower than asyncfiles-io_uring
- **aiofiles**: 2.67x slower than asyncfiles-io_uring
- **anyio**: 3.43x slower than asyncfiles-io_uring
- **aiofile**: 16.78x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4401.1 | 8802.3 | 2.9 | 3.5 | 13.5 | 0.40 | 0 | 43 | 50 |
| asyncfiles-libuv | 1966.1 | 3932.3 | 2.1 | 23.9 | 49.3 | 0.42 | 0 | 59 | 50 |
| aiofiles | 1612.9 | 3225.8 | 8.6 | 10.1 | 14.1 | 0.88 | 0 | 43 | 50 |
| anyio | 1318.4 | 2636.8 | 10.7 | 15.8 | 18.2 | 1.07 | 0 | 44 | 50 |
| aiofile | 263.2 | 526.3 | 43.7 | 59.8 | 63.9 | 3.87 | 0 | 60 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4401.1 MB/s (8802.3 ops/s)
- **p95 Latency**: 3.5 ms
- **CPU Time**: 0.40 s
- **Peak Memory**: 43 MB

## Performance Comparison

- **asyncfiles-libuv**: 2.24x slower than asyncfiles-io_uring
- **aiofiles**: 2.73x slower than asyncfiles-io_uring
- **anyio**: 3.34x slower than asyncfiles-io_uring
- **aiofile**: 16.72x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1841.5 | 1841.5 | 0.4 | 0.7 | 2.5 | 0.02 | 0 | 51 | 50 |
| asyncfiles-libuv | 1632.0 | 1632.0 | 0.5 | 0.6 | 3.7 | 0.02 | 0 | 52 | 50 |
| anyio | 1501.2 | 1501.2 | 0.7 | 0.8 | 0.8 | 0.12 | 0 | 51 | 50 |
| aiofiles | 1062.3 | 1062.3 | 0.7 | 1.0 | 5.9 | 0.04 | 0 | 52 | 50 |
| aiofile | 259.9 | 259.9 | 4.6 | 7.2 | 8.3 | 0.23 | 0 | 52 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1841.5 MB/s (1841.5 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.13x slower than asyncfiles-io_uring
- **anyio**: 1.23x slower than asyncfiles-io_uring
- **aiofiles**: 1.73x slower than asyncfiles-io_uring
- **aiofile**: 7.09x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 5081.4 | 5081.4 | 1.2 | 1.5 | 1.9 | 0.20 | 0 | 52 | 50 |
| aiofiles | 2350.3 | 2350.3 | 2.9 | 3.7 | 4.8 | 0.32 | 0 | 53 | 50 |
| asyncfiles-libuv | 1909.6 | 1909.6 | 1.1 | 16.8 | 29.1 | 0.20 | 0 | 61 | 50 |
| anyio | 1511.8 | 1511.8 | 3.4 | 4.2 | 7.3 | 0.41 | 0 | 59 | 50 |
| aiofile | 266.7 | 266.7 | 29.4 | 30.1 | 39.6 | 1.82 | 0 | 61 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 5081.4 MB/s (5081.4 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.20 s
- **Peak Memory**: 52 MB

## Performance Comparison

- **aiofiles**: 2.16x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.66x slower than asyncfiles-io_uring
- **anyio**: 3.36x slower than asyncfiles-io_uring
- **aiofile**: 19.05x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 5654.2 | 5654.2 | 2.2 | 3.0 | 4.0 | 0.37 | 0 | 61 | 50 |
| aiofiles | 2542.3 | 2542.3 | 5.4 | 6.5 | 9.5 | 0.62 | 0 | 61 | 50 |
| anyio | 2265.7 | 2265.7 | 6.2 | 7.7 | 11.1 | 0.71 | 0 | 59 | 50 |
| asyncfiles-libuv | 1634.7 | 1634.7 | 2.0 | 29.3 | 49.0 | 0.45 | 0 | 77 | 50 |
| aiofile | 266.5 | 266.5 | 59.0 | 60.3 | 69.1 | 3.58 | 0 | 76 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 5654.2 MB/s (5654.2 ops/s)
- **p95 Latency**: 3.0 ms
- **CPU Time**: 0.37 s
- **Peak Memory**: 61 MB

## Performance Comparison

- **aiofiles**: 2.22x slower than asyncfiles-io_uring
- **anyio**: 2.50x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 3.46x slower than asyncfiles-io_uring
- **aiofile**: 21.22x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 348.8 | 348.8 | 3.6 | 94.0 | 99.7 | 0.86 | 0 | 95 | 50 |
| asyncfiles-io_uring | 338.4 | 338.4 | 90.3 | 95.3 | 184.6 | 0.78 | 0 | 95 | 50 |
| aiofiles | 324.8 | 324.8 | 10.4 | 99.3 | 105.9 | 1.28 | 0 | 93 | 50 |
| anyio | 308.6 | 308.6 | 11.8 | 100.2 | 112.6 | 1.43 | 0 | 92 | 50 |
| aiofile | 264.0 | 264.0 | 87.7 | 122.1 | 128.2 | 7.27 | 0 | 94 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 348.8 MB/s (348.8 ops/s)
- **p95 Latency**: 94.0 ms
- **CPU Time**: 0.86 s
- **Peak Memory**: 95 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.03x slower than asyncfiles-libuv
- **aiofiles**: 1.07x slower than asyncfiles-libuv
- **anyio**: 1.13x slower than asyncfiles-libuv
- **aiofile**: 1.32x slower than asyncfiles-libuv
