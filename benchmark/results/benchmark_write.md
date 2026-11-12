# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-12 23:35 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 7 |
| asyncfiles-libuv | 5 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 707.5 | 2830.0 | 0.3 | 0.3 | 0.4 | 0.02 | 0 | 23 | 50 |
| asyncfiles-libuv | 648.1 | 2592.5 | 0.3 | 0.4 | 0.9 | 0.02 | 0 | 23 | 50 |
| aiofiles | 410.7 | 1642.7 | 0.6 | 0.6 | 0.7 | 0.03 | 0 | 23 | 50 |
| anyio | 366.4 | 1465.7 | 0.6 | 0.7 | 2.2 | 0.08 | 0 | 23 | 50 |
| aiofile | 267.0 | 1068.1 | 0.9 | 1.0 | 1.1 | 0.08 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 707.5 MB/s (2830.0 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.09x slower than asyncfiles-io_uring
- **aiofiles**: 1.72x slower than asyncfiles-io_uring
- **anyio**: 1.93x slower than asyncfiles-io_uring
- **aiofile**: 2.65x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1952.1 | 7808.6 | 0.8 | 0.9 | 1.1 | 0.11 | 0 | 34 | 50 |
| asyncfiles-libuv | 1872.0 | 7488.0 | 0.7 | 1.2 | 1.3 | 0.13 | 0 | 34 | 50 |
| aiofiles | 624.4 | 2497.7 | 2.7 | 3.2 | 3.7 | 0.28 | 0 | 34 | 50 |
| anyio | 490.7 | 1962.6 | 3.5 | 4.2 | 4.5 | 0.38 | 0 | 35 | 50 |
| aiofile | 394.5 | 1578.0 | 2.8 | 18.5 | 32.7 | 0.52 | 2 | 35 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1952.1 MB/s (7808.6 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.11 s
- **Peak Memory**: 34 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 3.13x slower than asyncfiles-io_uring
- **anyio**: 3.98x slower than asyncfiles-io_uring
- **aiofile**: 4.95x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2423.2 | 9692.7 | 1.1 | 1.5 | 3.2 | 0.23 | 0 | 42 | 50 |
| asyncfiles-io_uring | 2419.6 | 9678.4 | 1.3 | 1.5 | 1.6 | 0.20 | 0 | 40 | 50 |
| aiofiles | 709.7 | 2838.6 | 4.9 | 5.5 | 5.8 | 0.51 | 0 | 42 | 50 |
| anyio | 561.0 | 2244.0 | 6.2 | 7.2 | 12.0 | 0.67 | 1 | 43 | 50 |
| aiofile | 378.6 | 1514.5 | 4.8 | 30.7 | 39.7 | 1.04 | 0 | 43 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2423.2 MB/s (9692.7 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.23 s
- **Peak Memory**: 42 MB

## Performance Comparison

- **asyncfiles-io_uring**: about the same as asyncfiles-libuv
- **aiofiles**: 3.41x slower than asyncfiles-libuv
- **anyio**: 4.32x slower than asyncfiles-libuv
- **aiofile**: 6.40x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2706.1 | 10824.3 | 2.4 | 2.9 | 3.3 | 0.38 | 0 | 58 | 50 |
| asyncfiles-libuv | 1934.7 | 7738.9 | 1.9 | 2.9 | 15.3 | 0.42 | 0 | 58 | 50 |
| aiofiles | 773.2 | 3092.6 | 9.2 | 10.2 | 10.7 | 0.96 | 0 | 59 | 50 |
| anyio | 631.2 | 2524.9 | 11.5 | 12.6 | 13.1 | 1.17 | 0 | 59 | 50 |
| aiofile | 392.0 | 1568.2 | 9.1 | 32.4 | 47.6 | 1.98 | 0 | 59 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2706.1 MB/s (10824.3 ops/s)
- **p95 Latency**: 2.9 ms
- **CPU Time**: 0.38 s
- **Peak Memory**: 58 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.40x slower than asyncfiles-io_uring
- **aiofiles**: 3.50x slower than asyncfiles-io_uring
- **anyio**: 4.29x slower than asyncfiles-io_uring
- **aiofile**: 6.90x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1124.4 | 2248.8 | 0.4 | 0.4 | 0.4 | 0.02 | 0 | 51 | 50 |
| asyncfiles-libuv | 1100.8 | 2201.6 | 0.4 | 0.5 | 0.5 | 0.02 | 0 | 50 | 50 |
| aiofiles | 688.2 | 1376.3 | 0.7 | 0.7 | 0.8 | 0.04 | 0 | 51 | 50 |
| anyio | 670.0 | 1340.1 | 0.7 | 0.7 | 0.9 | 0.09 | 0 | 51 | 50 |
| aiofile | 423.6 | 847.2 | 1.0 | 1.7 | 4.4 | 0.10 | 0 | 51 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1124.4 MB/s (2248.8 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 1.63x slower than asyncfiles-io_uring
- **anyio**: 1.68x slower than asyncfiles-io_uring
- **aiofile**: 2.65x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 3407.1 | 6814.3 | 0.9 | 1.1 | 1.2 | 0.17 | 0 | 59 | 50 |
| asyncfiles-io_uring | 3049.6 | 6099.1 | 1.0 | 1.3 | 1.5 | 0.15 | 0 | 59 | 50 |
| aiofiles | 1178.9 | 2357.8 | 2.8 | 3.4 | 4.2 | 0.32 | 0 | 59 | 50 |
| anyio | 929.9 | 1859.8 | 3.7 | 4.4 | 5.8 | 0.46 | 0 | 59 | 50 |
| aiofile | 411.4 | 822.8 | 3.4 | 32.5 | 47.4 | 0.80 | 0 | 59 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 3407.1 MB/s (6814.3 ops/s)
- **p95 Latency**: 1.1 ms
- **CPU Time**: 0.17 s
- **Peak Memory**: 59 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.12x slower than asyncfiles-libuv
- **aiofiles**: 2.89x slower than asyncfiles-libuv
- **anyio**: 3.66x slower than asyncfiles-libuv
- **aiofile**: 8.28x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3511.0 | 7022.0 | 1.9 | 2.2 | 2.3 | 0.30 | 0 | 60 | 50 |
| asyncfiles-libuv | 2771.6 | 5543.3 | 1.5 | 2.0 | 16.7 | 0.32 | 0 | 64 | 50 |
| aiofiles | 1312.9 | 2625.9 | 5.2 | 6.0 | 6.2 | 0.60 | 0 | 65 | 50 |
| anyio | 1054.4 | 2108.9 | 6.6 | 7.9 | 8.3 | 0.76 | 0 | 66 | 50 |
| aiofile | 393.8 | 787.5 | 5.9 | 39.9 | 54.2 | 1.60 | 0 | 66 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3511.0 MB/s (7022.0 ops/s)
- **p95 Latency**: 2.2 ms
- **CPU Time**: 0.30 s
- **Peak Memory**: 60 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.27x slower than asyncfiles-io_uring
- **aiofiles**: 2.67x slower than asyncfiles-io_uring
- **anyio**: 3.33x slower than asyncfiles-io_uring
- **aiofile**: 8.92x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4190.2 | 8380.5 | 3.0 | 3.8 | 4.0 | 0.58 | 0 | 91 | 50 |
| asyncfiles-libuv | 3223.9 | 6447.8 | 2.7 | 3.6 | 31.1 | 0.60 | 0 | 91 | 50 |
| aiofiles | 1436.8 | 2873.6 | 10.0 | 10.9 | 11.1 | 1.13 | 0 | 91 | 50 |
| anyio | 1189.7 | 2379.4 | 12.1 | 13.4 | 13.9 | 1.33 | 0 | 92 | 50 |
| aiofile | 399.2 | 798.4 | 35.8 | 58.9 | 59.9 | 3.16 | 0 | 91 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4190.2 MB/s (8380.5 ops/s)
- **p95 Latency**: 3.8 ms
- **CPU Time**: 0.58 s
- **Peak Memory**: 91 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.30x slower than asyncfiles-io_uring
- **aiofiles**: 2.92x slower than asyncfiles-io_uring
- **anyio**: 3.52x slower than asyncfiles-io_uring
- **aiofile**: 10.50x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1779.1 | 1779.1 | 0.5 | 0.6 | 0.7 | 0.03 | 0 | 75 | 50 |
| asyncfiles-libuv | 1709.3 | 1709.3 | 0.5 | 0.7 | 0.7 | 0.03 | 0 | 76 | 50 |
| aiofiles | 1208.3 | 1208.3 | 0.8 | 1.0 | 1.2 | 0.04 | 0 | 76 | 50 |
| anyio | 1155.4 | 1155.4 | 0.8 | 0.9 | 1.3 | 0.14 | 0 | 76 | 50 |
| aiofile | 345.8 | 345.8 | 1.2 | 21.5 | 38.3 | 0.19 | 0 | 76 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1779.1 MB/s (1779.1 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 75 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 1.47x slower than asyncfiles-io_uring
- **anyio**: 1.54x slower than asyncfiles-io_uring
- **aiofile**: 5.14x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 4737.7 | 4737.7 | 1.3 | 1.6 | 1.9 | 0.25 | 0 | 86 | 50 |
| asyncfiles-io_uring | 4325.0 | 4325.0 | 1.4 | 1.8 | 2.2 | 0.24 | 0 | 86 | 50 |
| aiofiles | 2121.2 | 2121.2 | 3.3 | 3.8 | 3.9 | 0.40 | 0 | 86 | 50 |
| anyio | 1685.8 | 1685.8 | 4.1 | 5.0 | 5.5 | 0.50 | 0 | 85 | 50 |
| aiofile | 399.4 | 399.4 | 4.7 | 51.8 | 57.1 | 1.39 | 0 | 86 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 4737.7 MB/s (4737.7 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.25 s
- **Peak Memory**: 86 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.10x slower than asyncfiles-libuv
- **aiofiles**: 2.23x slower than asyncfiles-libuv
- **anyio**: 2.81x slower than asyncfiles-libuv
- **aiofile**: 11.86x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 5429.5 | 5429.5 | 2.3 | 2.8 | 3.0 | 0.48 | 0 | 99 | 50 |
| asyncfiles-io_uring | 4957.8 | 4957.8 | 2.5 | 3.3 | 3.5 | 0.47 | 0 | 100 | 50 |
| aiofiles | 2247.0 | 2247.0 | 6.3 | 7.2 | 7.8 | 0.77 | 0 | 100 | 50 |
| anyio | 1889.5 | 1889.5 | 7.5 | 8.6 | 9.2 | 0.93 | 0 | 100 | 50 |
| aiofile | 397.6 | 397.6 | 42.4 | 59.7 | 62.1 | 2.80 | 0 | 100 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 5429.5 MB/s (5429.5 ops/s)
- **p95 Latency**: 2.8 ms
- **CPU Time**: 0.48 s
- **Peak Memory**: 99 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.10x slower than asyncfiles-libuv
- **aiofiles**: 2.42x slower than asyncfiles-libuv
- **anyio**: 2.87x slower than asyncfiles-libuv
- **aiofile**: 13.66x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 6060.3 | 6060.3 | 4.1 | 5.1 | 5.3 | 0.95 | 0 | 148 | 50 |
| asyncfiles-io_uring | 5603.5 | 5603.5 | 4.2 | 6.1 | 6.4 | 0.96 | 0 | 147 | 50 |
| aiofiles | 2403.6 | 2403.6 | 12.1 | 13.4 | 14.1 | 1.52 | 0 | 148 | 50 |
| anyio | 2067.3 | 2067.3 | 14.0 | 15.4 | 22.1 | 1.78 | 0 | 131 | 50 |
| aiofile | 395.9 | 395.9 | 47.6 | 105.9 | 107.5 | 5.60 | 0 | 149 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 6060.3 MB/s (6060.3 ops/s)
- **p95 Latency**: 5.1 ms
- **CPU Time**: 0.95 s
- **Peak Memory**: 148 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.08x slower than asyncfiles-libuv
- **aiofiles**: 2.52x slower than asyncfiles-libuv
- **anyio**: 2.93x slower than asyncfiles-libuv
- **aiofile**: 15.31x slower than asyncfiles-libuv
