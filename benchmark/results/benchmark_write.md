# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.8.0-117-generic (aarch64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-12 13:25 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 9 |
| asyncfiles-io_uring | 2 |
| anyio | 1 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 1413.6 | 5654.2 | 0.1 | 0.2 | 0.3 | 0.03 | 0 | 22 | 50 |
| anyio | 985.2 | 3940.7 | 0.2 | 0.3 | 0.4 | 0.04 | 0 | 22 | 50 |
| asyncfiles-io_uring | 966.9 | 3867.5 | 0.2 | 0.3 | 0.3 | 0.01 | 0 | 22 | 50 |
| aiofiles | 680.7 | 2722.9 | 0.3 | 0.4 | 0.6 | 0.02 | 0 | 22 | 50 |
| aiofile | 394.6 | 1578.2 | 0.6 | 0.8 | 0.9 | 0.05 | 0 | 22 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 1413.6 MB/s (5654.2 ops/s)
- **p95 Latency**: 0.2 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **anyio**: 1.43x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.46x slower than asyncfiles-libuv
- **aiofiles**: 2.08x slower than asyncfiles-libuv
- **aiofile**: 3.58x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2430.0 | 9720.0 | 0.6 | 0.9 | 1.0 | 0.07 | 0 | 29 | 50 |
| asyncfiles-io_uring | 2408.2 | 9632.8 | 0.5 | 0.8 | 1.0 | 0.07 | 0 | 29 | 50 |
| aiofiles | 1279.8 | 5119.1 | 1.3 | 1.7 | 1.8 | 0.11 | 0 | 30 | 50 |
| anyio | 857.6 | 3430.3 | 1.9 | 3.5 | 4.6 | 0.18 | 0 | 32 | 50 |
| aiofile | 552.1 | 2208.5 | 2.5 | 5.2 | 6.2 | 0.25 | 0 | 32 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2430.0 MB/s (9720.0 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.07 s
- **Peak Memory**: 29 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.01x slower than asyncfiles-libuv
- **aiofiles**: 1.90x slower than asyncfiles-libuv
- **anyio**: 2.83x slower than asyncfiles-libuv
- **aiofile**: 4.40x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3460.2 | 13840.6 | 0.8 | 1.1 | 1.3 | 0.11 | 0 | 37 | 50 |
| asyncfiles-libuv | 2738.4 | 10953.4 | 1.1 | 1.5 | 1.7 | 0.13 | 0 | 36 | 50 |
| aiofiles | 1558.2 | 6232.8 | 2.1 | 2.6 | 3.1 | 0.19 | 0 | 40 | 50 |
| anyio | 1081.6 | 4326.4 | 3.1 | 4.8 | 5.6 | 0.32 | 0 | 40 | 50 |
| aiofile | 656.7 | 2626.8 | 4.0 | 7.3 | 10.3 | 0.52 | 0 | 40 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3460.2 MB/s (13840.6 ops/s)
- **p95 Latency**: 1.1 ms
- **CPU Time**: 0.11 s
- **Peak Memory**: 37 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.26x slower than asyncfiles-io_uring
- **aiofiles**: 2.22x slower than asyncfiles-io_uring
- **anyio**: 3.20x slower than asyncfiles-io_uring
- **aiofile**: 5.27x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 4031.3 | 16125.1 | 1.5 | 2.1 | 2.4 | 0.18 | 0 | 54 | 50 |
| asyncfiles-io_uring | 3825.7 | 15302.9 | 1.3 | 1.9 | 2.2 | 0.20 | 0 | 50 | 50 |
| aiofiles | 1713.6 | 6854.4 | 4.0 | 4.8 | 5.0 | 0.35 | 0 | 54 | 50 |
| anyio | 1099.1 | 4396.5 | 6.2 | 7.7 | 8.6 | 0.59 | 0 | 54 | 50 |
| aiofile | 847.4 | 3389.7 | 5.9 | 11.5 | 17.8 | 0.83 | 0 | 54 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 4031.3 MB/s (16125.1 ops/s)
- **p95 Latency**: 2.1 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 54 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.05x slower than asyncfiles-libuv
- **aiofiles**: 2.35x slower than asyncfiles-libuv
- **anyio**: 3.67x slower than asyncfiles-libuv
- **aiofile**: 4.76x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 1772.4 | 3544.8 | 0.3 | 0.3 | 0.4 | 0.05 | 0 | 45 | 50 |
| asyncfiles-io_uring | 1738.3 | 3476.6 | 0.3 | 0.3 | 0.3 | 0.02 | 0 | 45 | 50 |
| asyncfiles-libuv | 1263.8 | 2527.7 | 0.3 | 0.7 | 1.7 | 0.04 | 0 | 46 | 50 |
| aiofiles | 928.8 | 1857.6 | 0.4 | 0.9 | 0.9 | 0.03 | 0 | 46 | 50 |
| aiofile | 655.1 | 1310.3 | 0.7 | 0.9 | 2.9 | 0.06 | 0 | 45 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 1772.4 MB/s (3544.8 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.05 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.02x slower than anyio
- **asyncfiles-libuv**: 1.40x slower than anyio
- **aiofiles**: 1.91x slower than anyio
- **aiofile**: 2.71x slower than anyio


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 3293.2 | 6586.4 | 0.9 | 1.3 | 1.7 | 0.11 | 0 | 50 | 50 |
| asyncfiles-io_uring | 2761.0 | 5522.0 | 0.9 | 1.4 | 1.6 | 0.12 | 0 | 46 | 50 |
| aiofiles | 1866.5 | 3733.1 | 1.7 | 2.3 | 2.5 | 0.17 | 0 | 46 | 50 |
| anyio | 1665.2 | 3330.4 | 2.0 | 2.4 | 2.7 | 0.32 | 0 | 50 | 50 |
| aiofile | 757.8 | 1515.7 | 3.7 | 5.5 | 6.0 | 0.43 | 0 | 50 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 3293.2 MB/s (6586.4 ops/s)
- **p95 Latency**: 1.3 ms
- **CPU Time**: 0.11 s
- **Peak Memory**: 50 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.19x slower than asyncfiles-libuv
- **aiofiles**: 1.76x slower than asyncfiles-libuv
- **anyio**: 1.98x slower than asyncfiles-libuv
- **aiofile**: 4.35x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4657.5 | 9315.0 | 1.5 | 1.7 | 2.0 | 0.16 | 0 | 59 | 50 |
| asyncfiles-libuv | 4167.1 | 8334.2 | 1.5 | 2.1 | 2.4 | 0.18 | 0 | 50 | 50 |
| aiofiles | 2491.2 | 4982.4 | 2.6 | 4.2 | 5.5 | 0.24 | 0 | 58 | 50 |
| anyio | 2315.3 | 4630.6 | 2.9 | 4.4 | 5.0 | 0.32 | 0 | 59 | 50 |
| aiofile | 1287.2 | 2574.5 | 4.0 | 7.2 | 8.0 | 0.52 | 0 | 59 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4657.5 MB/s (9315.0 ops/s)
- **p95 Latency**: 1.7 ms
- **CPU Time**: 0.16 s
- **Peak Memory**: 59 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.12x slower than asyncfiles-io_uring
- **aiofiles**: 1.87x slower than asyncfiles-io_uring
- **anyio**: 2.01x slower than asyncfiles-io_uring
- **aiofile**: 3.62x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 5773.8 | 11547.5 | 2.2 | 2.8 | 3.0 | 0.27 | 0 | 83 | 50 |
| asyncfiles-io_uring | 5126.3 | 10252.6 | 2.5 | 3.1 | 3.4 | 0.29 | 0 | 83 | 50 |
| aiofiles | 3010.1 | 6020.3 | 4.6 | 5.4 | 5.7 | 0.44 | 0 | 76 | 50 |
| anyio | 1676.8 | 3353.7 | 7.7 | 12.2 | 14.1 | 0.72 | 0 | 83 | 50 |
| aiofile | 1556.3 | 3112.6 | 7.5 | 10.5 | 11.7 | 0.97 | 0 | 83 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 5773.8 MB/s (11547.5 ops/s)
- **p95 Latency**: 2.8 ms
- **CPU Time**: 0.27 s
- **Peak Memory**: 83 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.13x slower than asyncfiles-libuv
- **aiofiles**: 1.92x slower than asyncfiles-libuv
- **anyio**: 3.44x slower than asyncfiles-libuv
- **aiofile**: 3.71x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2872.8 | 2872.8 | 0.3 | 0.4 | 0.5 | 0.02 | 0 | 66 | 50 |
| asyncfiles-io_uring | 2328.4 | 2328.4 | 0.4 | 0.5 | 0.6 | 0.02 | 0 | 66 | 50 |
| aiofiles | 1502.1 | 1502.1 | 0.6 | 0.8 | 2.0 | 0.03 | 0 | 67 | 50 |
| anyio | 709.4 | 709.4 | 1.4 | 2.6 | 3.3 | 0.09 | 0 | 66 | 50 |
| aiofile | 456.9 | 456.9 | 1.9 | 3.5 | 4.2 | 0.14 | 0 | 67 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2872.8 MB/s (2872.8 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 66 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.23x slower than asyncfiles-libuv
- **aiofiles**: 1.91x slower than asyncfiles-libuv
- **anyio**: 4.05x slower than asyncfiles-libuv
- **aiofile**: 6.29x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 4965.6 | 4965.6 | 1.3 | 1.7 | 2.0 | 0.15 | 0 | 75 | 50 |
| asyncfiles-io_uring | 4330.9 | 4330.9 | 1.3 | 1.9 | 2.1 | 0.16 | 0 | 75 | 50 |
| aiofiles | 3414.2 | 3414.2 | 1.9 | 2.7 | 3.1 | 0.20 | 0 | 75 | 50 |
| anyio | 2764.7 | 2764.7 | 2.4 | 3.1 | 3.4 | 0.28 | 0 | 74 | 50 |
| aiofile | 1614.2 | 1614.2 | 4.0 | 5.7 | 6.6 | 0.45 | 0 | 75 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 4965.6 MB/s (4965.6 ops/s)
- **p95 Latency**: 1.7 ms
- **CPU Time**: 0.15 s
- **Peak Memory**: 75 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv
- **aiofiles**: 1.45x slower than asyncfiles-libuv
- **anyio**: 1.80x slower than asyncfiles-libuv
- **aiofile**: 3.08x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 6865.0 | 6865.0 | 1.9 | 2.4 | 2.9 | 0.22 | 0 | 80 | 50 |
| asyncfiles-io_uring | 6684.7 | 6684.7 | 2.1 | 2.5 | 2.7 | 0.22 | 0 | 90 | 50 |
| aiofiles | 4191.1 | 4191.1 | 3.1 | 4.0 | 4.3 | 0.34 | 0 | 90 | 50 |
| anyio | 3122.9 | 3122.9 | 4.4 | 5.4 | 5.6 | 0.45 | 0 | 90 | 50 |
| aiofile | 1952.5 | 1952.5 | 6.5 | 9.5 | 10.4 | 0.69 | 0 | 90 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 6865.0 MB/s (6865.0 ops/s)
- **p95 Latency**: 2.4 ms
- **CPU Time**: 0.22 s
- **Peak Memory**: 80 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.03x slower than asyncfiles-libuv
- **aiofiles**: 1.64x slower than asyncfiles-libuv
- **anyio**: 2.20x slower than asyncfiles-libuv
- **aiofile**: 3.52x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 4800.6 | 4800.6 | 5.3 | 7.1 | 8.5 | 0.65 | 0 | 136 | 50 |
| asyncfiles-io_uring | 4575.3 | 4575.3 | 4.8 | 7.2 | 8.3 | 0.65 | 0 | 135 | 50 |
| aiofiles | 3496.4 | 3496.4 | 7.8 | 9.4 | 11.2 | 0.80 | 0 | 103 | 50 |
| anyio | 2824.1 | 2824.1 | 9.8 | 12.0 | 13.3 | 0.96 | 0 | 136 | 50 |
| aiofile | 1992.6 | 1992.6 | 12.3 | 17.2 | 18.7 | 1.51 | 0 | 136 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 4800.6 MB/s (4800.6 ops/s)
- **p95 Latency**: 7.1 ms
- **CPU Time**: 0.65 s
- **Peak Memory**: 136 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.05x slower than asyncfiles-libuv
- **aiofiles**: 1.37x slower than asyncfiles-libuv
- **anyio**: 1.70x slower than asyncfiles-libuv
- **aiofile**: 2.41x slower than asyncfiles-libuv
