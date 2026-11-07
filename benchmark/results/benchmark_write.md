# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-07 02:14 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 10 |
| asyncfiles-libuv | 2 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 802.2 | 3208.7 | 0.3 | 0.3 | 0.3 | 0.01 | 0 | 22 | 50 |
| asyncfiles-libuv | 683.9 | 2735.7 | 0.3 | 0.4 | 0.6 | 0.01 | 0 | 22 | 50 |
| aiofiles | 562.9 | 2251.7 | 0.4 | 0.5 | 1.5 | 0.02 | 0 | 22 | 50 |
| anyio | 493.4 | 1973.4 | 0.5 | 0.5 | 0.8 | 0.07 | 0 | 22 | 50 |
| aiofile | 230.9 | 923.5 | 0.7 | 3.1 | 7.4 | 0.08 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 802.2 MB/s (3208.7 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.17x slower than asyncfiles-io_uring
- **aiofiles**: 1.42x slower than asyncfiles-io_uring
- **anyio**: 1.63x slower than asyncfiles-io_uring
- **aiofile**: 3.47x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 1905.3 | 7621.1 | 0.7 | 0.9 | 1.0 | 0.10 | 0 | 29 | 50 |
| asyncfiles-io_uring | 1815.7 | 7262.9 | 0.9 | 1.0 | 1.0 | 0.09 | 0 | 29 | 50 |
| aiofiles | 781.9 | 3127.7 | 2.2 | 2.5 | 2.7 | 0.20 | 0 | 29 | 50 |
| anyio | 644.6 | 2578.2 | 2.7 | 3.3 | 3.4 | 0.32 | 0 | 31 | 50 |
| aiofile | 232.1 | 928.4 | 7.1 | 9.8 | 30.0 | 0.63 | 0 | 31 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 1905.3 MB/s (7621.1 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.10 s
- **Peak Memory**: 29 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.05x slower than asyncfiles-libuv
- **aiofiles**: 2.44x slower than asyncfiles-libuv
- **anyio**: 2.96x slower than asyncfiles-libuv
- **aiofile**: 8.21x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2370.6 | 9482.3 | 1.2 | 1.4 | 1.5 | 0.18 | 0 | 34 | 50 |
| asyncfiles-io_uring | 2071.6 | 8286.3 | 1.6 | 1.7 | 1.8 | 0.16 | 0 | 32 | 50 |
| aiofiles | 929.9 | 3719.5 | 3.7 | 4.2 | 4.5 | 0.38 | 0 | 33 | 50 |
| anyio | 749.7 | 2998.9 | 4.7 | 5.4 | 5.8 | 0.53 | 0 | 36 | 50 |
| aiofile | 181.6 | 726.5 | 9.8 | 39.4 | 83.6 | 1.45 | 0 | 36 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2370.6 MB/s (9482.3 ops/s)
- **p95 Latency**: 1.4 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 34 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.14x slower than asyncfiles-libuv
- **aiofiles**: 2.55x slower than asyncfiles-libuv
- **anyio**: 3.16x slower than asyncfiles-libuv
- **aiofile**: 13.05x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2063.4 | 8253.7 | 3.1 | 3.4 | 12.9 | 0.31 | 0 | 35 | 50 |
| aiofiles | 990.3 | 3961.3 | 7.1 | 7.7 | 10.9 | 0.74 | 0 | 35 | 50 |
| asyncfiles-libuv | 775.2 | 3100.8 | 2.4 | 18.9 | 247.4 | 0.37 | 0 | 43 | 50 |
| anyio | 710.1 | 2840.4 | 8.8 | 10.2 | 75.1 | 0.97 | 0 | 43 | 50 |
| aiofile | 236.2 | 944.8 | 20.1 | 41.1 | 49.0 | 2.48 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2063.4 MB/s (8253.7 ops/s)
- **p95 Latency**: 3.4 ms
- **CPU Time**: 0.31 s
- **Peak Memory**: 35 MB

## Performance Comparison

- **aiofiles**: 2.08x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.66x slower than asyncfiles-io_uring
- **anyio**: 2.91x slower than asyncfiles-io_uring
- **aiofile**: 8.74x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1243.7 | 2487.3 | 0.3 | 0.5 | 0.5 | 0.02 | 0 | 39 | 50 |
| asyncfiles-libuv | 1092.5 | 2185.0 | 0.4 | 0.5 | 0.6 | 0.02 | 0 | 39 | 50 |
| aiofiles | 878.8 | 1757.6 | 0.5 | 0.7 | 0.8 | 0.03 | 0 | 39 | 50 |
| anyio | 827.7 | 1655.3 | 0.6 | 0.7 | 0.8 | 0.10 | 0 | 39 | 50 |
| aiofile | 195.7 | 391.5 | 1.0 | 12.4 | 17.5 | 0.16 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1243.7 MB/s (2487.3 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 39 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.14x slower than asyncfiles-io_uring
- **aiofiles**: 1.42x slower than asyncfiles-io_uring
- **anyio**: 1.50x slower than asyncfiles-io_uring
- **aiofile**: 6.35x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2910.6 | 5821.3 | 1.0 | 1.2 | 1.3 | 0.13 | 0 | 45 | 50 |
| asyncfiles-libuv | 2638.3 | 5276.7 | 0.9 | 1.1 | 1.2 | 0.15 | 0 | 45 | 50 |
| anyio | 1202.7 | 2405.5 | 2.9 | 3.4 | 3.5 | 0.32 | 0 | 45 | 50 |
| aiofiles | 981.2 | 1962.3 | 2.4 | 2.8 | 68.4 | 0.24 | 0 | 45 | 50 |
| aiofile | 152.7 | 305.4 | 10.1 | 42.1 | 111.2 | 1.55 | 0 | 45 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2910.6 MB/s (5821.3 ops/s)
- **p95 Latency**: 1.2 ms
- **CPU Time**: 0.13 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.10x slower than asyncfiles-io_uring
- **anyio**: 2.42x slower than asyncfiles-io_uring
- **aiofiles**: 2.97x slower than asyncfiles-io_uring
- **aiofile**: 19.06x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3347.2 | 6694.5 | 1.9 | 2.2 | 2.3 | 0.25 | 0 | 44 | 50 |
| aiofiles | 1695.0 | 3390.0 | 4.1 | 4.6 | 5.4 | 0.45 | 0 | 45 | 50 |
| asyncfiles-libuv | 1650.1 | 3300.2 | 1.4 | 9.6 | 28.9 | 0.27 | 0 | 52 | 50 |
| anyio | 735.7 | 1471.4 | 5.0 | 11.0 | 187.3 | 0.60 | 0 | 48 | 50 |
| aiofile | 245.0 | 490.0 | 28.8 | 50.0 | 58.9 | 2.10 | 0 | 52 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3347.2 MB/s (6694.5 ops/s)
- **p95 Latency**: 2.2 ms
- **CPU Time**: 0.25 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **aiofiles**: 1.97x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.03x slower than asyncfiles-io_uring
- **anyio**: 4.55x slower than asyncfiles-io_uring
- **aiofile**: 13.66x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3657.4 | 7314.8 | 3.4 | 4.4 | 4.5 | 0.46 | 0 | 41 | 50 |
| aiofiles | 1906.0 | 3812.0 | 7.4 | 8.2 | 8.4 | 0.85 | 0 | 41 | 50 |
| asyncfiles-libuv | 1675.7 | 3351.5 | 2.6 | 35.8 | 79.4 | 0.48 | 0 | 58 | 50 |
| anyio | 1548.2 | 3096.4 | 9.2 | 10.2 | 13.7 | 1.06 | 0 | 41 | 50 |
| aiofile | 232.9 | 465.8 | 47.4 | 99.3 | 118.7 | 4.36 | 0 | 58 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3657.4 MB/s (7314.8 ops/s)
- **p95 Latency**: 4.4 ms
- **CPU Time**: 0.46 s
- **Peak Memory**: 41 MB

## Performance Comparison

- **aiofiles**: 1.92x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.18x slower than asyncfiles-io_uring
- **anyio**: 2.36x slower than asyncfiles-io_uring
- **aiofile**: 15.70x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2013.8 | 2013.8 | 0.5 | 0.5 | 0.5 | 0.02 | 0 | 48 | 50 |
| asyncfiles-libuv | 1860.1 | 1860.1 | 0.5 | 0.6 | 0.6 | 0.02 | 0 | 48 | 50 |
| aiofiles | 1480.9 | 1480.9 | 0.6 | 0.8 | 0.8 | 0.03 | 0 | 48 | 50 |
| anyio | 1345.9 | 1345.9 | 0.7 | 0.8 | 0.9 | 0.12 | 0 | 48 | 50 |
| aiofile | 269.6 | 269.6 | 1.1 | 8.7 | 8.7 | 0.22 | 0 | 48 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2013.8 MB/s (2013.8 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 48 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.08x slower than asyncfiles-io_uring
- **aiofiles**: 1.36x slower than asyncfiles-io_uring
- **anyio**: 1.50x slower than asyncfiles-io_uring
- **aiofile**: 7.47x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4918.3 | 4918.3 | 1.2 | 1.5 | 1.6 | 0.18 | 0 | 49 | 50 |
| aiofiles | 2706.1 | 2706.1 | 2.5 | 3.0 | 3.2 | 0.31 | 0 | 49 | 50 |
| anyio | 2205.3 | 2205.3 | 3.2 | 3.8 | 3.9 | 0.42 | 0 | 48 | 50 |
| asyncfiles-libuv | 1582.3 | 1582.3 | 1.1 | 16.0 | 47.9 | 0.21 | 0 | 57 | 50 |
| aiofile | 251.0 | 251.0 | 29.3 | 31.6 | 103.2 | 1.89 | 0 | 57 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4918.3 MB/s (4918.3 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 49 MB

## Performance Comparison

- **aiofiles**: 1.82x slower than asyncfiles-io_uring
- **anyio**: 2.23x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 3.11x slower than asyncfiles-io_uring
- **aiofile**: 19.60x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 5220.8 | 5220.8 | 2.4 | 3.0 | 3.2 | 0.37 | 0 | 59 | 50 |
| aiofiles | 3051.2 | 3051.2 | 4.5 | 5.1 | 5.3 | 0.58 | 0 | 57 | 50 |
| anyio | 2421.3 | 2421.3 | 5.9 | 6.5 | 7.2 | 0.72 | 0 | 52 | 50 |
| asyncfiles-libuv | 2265.3 | 2265.3 | 1.8 | 28.9 | 48.7 | 0.39 | 0 | 76 | 50 |
| aiofile | 268.1 | 268.1 | 58.6 | 59.8 | 68.8 | 3.58 | 0 | 69 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 5220.8 MB/s (5220.8 ops/s)
- **p95 Latency**: 3.0 ms
- **CPU Time**: 0.37 s
- **Peak Memory**: 59 MB

## Performance Comparison

- **aiofiles**: 1.71x slower than asyncfiles-io_uring
- **anyio**: 2.16x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.30x slower than asyncfiles-io_uring
- **aiofile**: 19.47x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 352.1 | 352.1 | 87.6 | 95.9 | 96.1 | 0.77 | 0 | 92 | 50 |
| asyncfiles-libuv | 337.5 | 337.5 | 3.6 | 99.0 | 108.2 | 0.80 | 0 | 92 | 50 |
| aiofiles | 330.2 | 330.2 | 9.0 | 97.0 | 102.8 | 1.19 | 0 | 92 | 50 |
| anyio | 316.1 | 316.1 | 10.7 | 98.9 | 108.9 | 1.40 | 0 | 92 | 50 |
| aiofile | 264.8 | 264.8 | 88.1 | 123.6 | 127.6 | 7.28 | 0 | 93 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 352.1 MB/s (352.1 ops/s)
- **p95 Latency**: 95.9 ms
- **CPU Time**: 0.77 s
- **Peak Memory**: 92 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 1.07x slower than asyncfiles-io_uring
- **anyio**: 1.11x slower than asyncfiles-io_uring
- **aiofile**: 1.33x slower than asyncfiles-io_uring
