# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-08 03:15 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 11 |
| asyncfiles-libuv | 1 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 637.8 | 2551.2 | 0.3 | 0.4 | 0.6 | 0.02 | 0 | 22 | 50 |
| asyncfiles-libuv | 488.5 | 1954.2 | 0.4 | 0.6 | 5.2 | 0.02 | 0 | 22 | 50 |
| aiofiles | 445.1 | 1780.3 | 0.5 | 0.6 | 1.6 | 0.03 | 0 | 23 | 50 |
| anyio | 335.0 | 1339.9 | 0.6 | 0.8 | 4.6 | 0.09 | 0 | 22 | 50 |
| aiofile | 256.1 | 1024.4 | 0.9 | 1.1 | 1.4 | 0.08 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 637.8 MB/s (2551.2 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.31x slower than asyncfiles-io_uring
- **aiofiles**: 1.43x slower than asyncfiles-io_uring
- **anyio**: 1.90x slower than asyncfiles-io_uring
- **aiofile**: 2.49x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2171.3 | 8685.1 | 0.7 | 0.9 | 1.0 | 0.12 | 0 | 30 | 50 |
| asyncfiles-io_uring | 1765.0 | 7060.2 | 0.8 | 1.1 | 3.5 | 0.12 | 0 | 30 | 50 |
| aiofiles | 624.3 | 2497.1 | 2.7 | 3.1 | 3.5 | 0.28 | 0 | 31 | 50 |
| anyio | 495.7 | 1982.7 | 3.5 | 4.2 | 4.4 | 0.38 | 0 | 31 | 50 |
| aiofile | 405.7 | 1622.9 | 3.0 | 8.9 | 28.4 | 0.52 | 2 | 31 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2171.3 MB/s (8685.1 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 30 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.23x slower than asyncfiles-libuv
- **aiofiles**: 3.48x slower than asyncfiles-libuv
- **anyio**: 4.38x slower than asyncfiles-libuv
- **aiofile**: 5.35x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2212.2 | 8849.0 | 1.4 | 1.6 | 1.8 | 0.22 | 0 | 32 | 50 |
| asyncfiles-libuv | 926.4 | 3705.7 | 1.2 | 2.0 | 35.3 | 0.24 | 0 | 36 | 50 |
| aiofiles | 704.1 | 2816.4 | 4.9 | 5.6 | 7.1 | 0.51 | 0 | 36 | 50 |
| anyio | 562.6 | 2250.5 | 6.2 | 7.3 | 8.1 | 0.69 | 1 | 36 | 50 |
| aiofile | 403.3 | 1613.0 | 5.0 | 23.7 | 37.5 | 1.00 | 2 | 36 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2212.2 MB/s (8849.0 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.22 s
- **Peak Memory**: 32 MB

## Performance Comparison

- **asyncfiles-libuv**: 2.39x slower than asyncfiles-io_uring
- **aiofiles**: 3.14x slower than asyncfiles-io_uring
- **anyio**: 3.93x slower than asyncfiles-io_uring
- **aiofile**: 5.49x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2493.5 | 9973.8 | 2.5 | 3.1 | 3.3 | 0.41 | 0 | 44 | 50 |
| asyncfiles-libuv | 1225.0 | 4900.1 | 1.9 | 3.6 | 36.9 | 0.44 | 0 | 44 | 50 |
| aiofiles | 763.9 | 3055.6 | 9.3 | 10.4 | 10.9 | 0.98 | 0 | 44 | 50 |
| anyio | 626.0 | 2503.9 | 11.6 | 12.7 | 16.0 | 1.17 | 0 | 44 | 50 |
| aiofile | 393.7 | 1575.0 | 9.3 | 34.2 | 49.3 | 2.00 | 3 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2493.5 MB/s (9973.8 ops/s)
- **p95 Latency**: 3.1 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **asyncfiles-libuv**: 2.04x slower than asyncfiles-io_uring
- **aiofiles**: 3.26x slower than asyncfiles-io_uring
- **anyio**: 3.98x slower than asyncfiles-io_uring
- **aiofile**: 6.33x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1247.0 | 2494.0 | 0.3 | 0.4 | 0.4 | 0.02 | 0 | 39 | 50 |
| asyncfiles-libuv | 1005.6 | 2011.2 | 0.4 | 0.5 | 1.1 | 0.03 | 0 | 39 | 50 |
| aiofiles | 737.4 | 1474.7 | 0.6 | 0.7 | 0.9 | 0.04 | 0 | 39 | 50 |
| anyio | 683.7 | 1367.5 | 0.7 | 0.8 | 1.0 | 0.09 | 0 | 40 | 50 |
| aiofile | 456.7 | 913.5 | 1.0 | 1.2 | 1.3 | 0.09 | 0 | 40 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1247.0 MB/s (2494.0 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 39 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.24x slower than asyncfiles-io_uring
- **aiofiles**: 1.69x slower than asyncfiles-io_uring
- **anyio**: 1.82x slower than asyncfiles-io_uring
- **aiofile**: 2.73x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2945.4 | 5890.9 | 1.0 | 1.3 | 1.4 | 0.16 | 0 | 48 | 50 |
| asyncfiles-libuv | 2764.8 | 5529.6 | 1.0 | 1.5 | 1.9 | 0.19 | 0 | 48 | 50 |
| aiofiles | 1201.2 | 2402.4 | 2.9 | 3.3 | 3.5 | 0.32 | 0 | 47 | 50 |
| anyio | 927.3 | 1854.6 | 3.7 | 4.5 | 4.9 | 0.47 | 0 | 47 | 50 |
| aiofile | 406.4 | 812.8 | 3.6 | 32.8 | 50.3 | 0.80 | 0 | 47 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2945.4 MB/s (5890.9 ops/s)
- **p95 Latency**: 1.3 ms
- **CPU Time**: 0.16 s
- **Peak Memory**: 48 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.07x slower than asyncfiles-io_uring
- **aiofiles**: 2.45x slower than asyncfiles-io_uring
- **anyio**: 3.18x slower than asyncfiles-io_uring
- **aiofile**: 7.25x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3428.0 | 6856.0 | 1.7 | 2.2 | 2.4 | 0.32 | 0 | 52 | 50 |
| asyncfiles-libuv | 1774.1 | 3548.3 | 1.6 | 2.6 | 22.8 | 0.33 | 0 | 52 | 50 |
| aiofiles | 1282.7 | 2565.5 | 5.4 | 6.1 | 8.2 | 0.62 | 0 | 50 | 50 |
| anyio | 1054.0 | 2108.1 | 6.6 | 7.6 | 7.9 | 0.78 | 0 | 51 | 50 |
| aiofile | 391.8 | 783.6 | 6.3 | 42.6 | 53.3 | 1.64 | 0 | 51 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3428.0 MB/s (6856.0 ops/s)
- **p95 Latency**: 2.2 ms
- **CPU Time**: 0.32 s
- **Peak Memory**: 52 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.93x slower than asyncfiles-io_uring
- **aiofiles**: 2.67x slower than asyncfiles-io_uring
- **anyio**: 3.25x slower than asyncfiles-io_uring
- **aiofile**: 8.75x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3852.5 | 7705.0 | 3.3 | 4.1 | 5.1 | 0.61 | 0 | 61 | 50 |
| asyncfiles-libuv | 2383.1 | 4766.1 | 2.9 | 4.0 | 43.3 | 0.62 | 0 | 61 | 50 |
| aiofiles | 1399.1 | 2798.1 | 10.2 | 11.3 | 13.9 | 1.16 | 0 | 61 | 50 |
| anyio | 1166.0 | 2332.0 | 12.3 | 13.7 | 14.9 | 1.41 | 0 | 60 | 50 |
| aiofile | 393.6 | 787.1 | 36.0 | 56.2 | 60.4 | 3.20 | 0 | 61 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3852.5 MB/s (7705.0 ops/s)
- **p95 Latency**: 4.1 ms
- **CPU Time**: 0.61 s
- **Peak Memory**: 61 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.62x slower than asyncfiles-io_uring
- **aiofiles**: 2.75x slower than asyncfiles-io_uring
- **anyio**: 3.30x slower than asyncfiles-io_uring
- **aiofile**: 9.79x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1753.2 | 1753.2 | 0.5 | 0.6 | 0.9 | 0.03 | 0 | 51 | 50 |
| asyncfiles-libuv | 1476.4 | 1476.4 | 0.6 | 0.7 | 2.8 | 0.03 | 0 | 51 | 50 |
| aiofiles | 1184.2 | 1184.2 | 0.8 | 0.9 | 1.2 | 0.05 | 0 | 52 | 50 |
| anyio | 1095.3 | 1095.3 | 0.8 | 1.1 | 1.2 | 0.11 | 0 | 52 | 50 |
| aiofile | 449.3 | 449.3 | 1.3 | 4.3 | 21.3 | 0.16 | 0 | 52 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1753.2 MB/s (1753.2 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.19x slower than asyncfiles-io_uring
- **aiofiles**: 1.48x slower than asyncfiles-io_uring
- **anyio**: 1.60x slower than asyncfiles-io_uring
- **aiofile**: 3.90x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4208.2 | 4208.2 | 1.4 | 1.9 | 2.1 | 0.25 | 0 | 67 | 50 |
| asyncfiles-libuv | 4140.2 | 4140.2 | 1.5 | 1.8 | 2.4 | 0.28 | 0 | 68 | 50 |
| aiofiles | 2087.1 | 2087.1 | 3.3 | 3.9 | 4.1 | 0.42 | 0 | 68 | 50 |
| anyio | 1704.7 | 1704.7 | 4.2 | 4.8 | 5.1 | 0.53 | 0 | 67 | 50 |
| aiofile | 411.7 | 411.7 | 5.1 | 51.2 | 57.0 | 1.39 | 0 | 68 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4208.2 MB/s (4208.2 ops/s)
- **p95 Latency**: 1.9 ms
- **CPU Time**: 0.25 s
- **Peak Memory**: 67 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 2.02x slower than asyncfiles-io_uring
- **anyio**: 2.47x slower than asyncfiles-io_uring
- **aiofile**: 10.22x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4467.4 | 4467.4 | 2.7 | 3.8 | 4.4 | 0.52 | 0 | 74 | 50 |
| asyncfiles-libuv | 3297.4 | 3297.4 | 2.6 | 3.2 | 36.6 | 0.54 | 0 | 72 | 50 |
| aiofiles | 2235.1 | 2235.1 | 6.3 | 7.2 | 7.7 | 0.81 | 0 | 74 | 50 |
| anyio | 1862.8 | 1862.8 | 7.7 | 8.7 | 9.1 | 0.99 | 0 | 75 | 50 |
| aiofile | 400.6 | 400.6 | 41.0 | 61.6 | 63.8 | 2.80 | 0 | 75 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4467.4 MB/s (4467.4 ops/s)
- **p95 Latency**: 3.8 ms
- **CPU Time**: 0.52 s
- **Peak Memory**: 74 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.35x slower than asyncfiles-io_uring
- **aiofiles**: 2.00x slower than asyncfiles-io_uring
- **anyio**: 2.40x slower than asyncfiles-io_uring
- **aiofile**: 11.15x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 5280.5 | 5280.5 | 4.2 | 6.5 | 6.7 | 1.02 | 0 | 99 | 50 |
| aiofiles | 2404.7 | 2404.7 | 12.1 | 13.2 | 13.6 | 1.53 | 0 | 99 | 50 |
| anyio | 2003.9 | 2003.9 | 14.3 | 15.6 | 22.1 | 1.83 | 0 | 77 | 50 |
| asyncfiles-libuv | 1892.8 | 1892.8 | 4.6 | 27.4 | 59.4 | 1.02 | 0 | 99 | 50 |
| aiofile | 398.9 | 398.9 | 47.4 | 105.2 | 107.4 | 5.62 | 0 | 99 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 5280.5 MB/s (5280.5 ops/s)
- **p95 Latency**: 6.5 ms
- **CPU Time**: 1.02 s
- **Peak Memory**: 99 MB

## Performance Comparison

- **aiofiles**: 2.20x slower than asyncfiles-io_uring
- **anyio**: 2.64x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.79x slower than asyncfiles-io_uring
- **aiofile**: 13.24x slower than asyncfiles-io_uring
