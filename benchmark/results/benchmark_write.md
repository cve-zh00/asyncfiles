# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-07 20:31 UTC

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
| asyncfiles-io_uring | 653.5 | 2614.0 | 0.3 | 0.4 | 0.4 | 0.02 | 0 | 23 | 50 |
| asyncfiles-libuv | 619.0 | 2475.9 | 0.4 | 0.4 | 0.5 | 0.02 | 0 | 23 | 50 |
| aiofiles | 390.9 | 1563.6 | 0.6 | 0.6 | 1.8 | 0.03 | 0 | 23 | 50 |
| anyio | 375.7 | 1502.9 | 0.6 | 0.7 | 1.5 | 0.08 | 0 | 22 | 50 |
| aiofile | 249.0 | 995.8 | 0.9 | 1.3 | 1.3 | 0.09 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 653.5 MB/s (2614.0 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.06x slower than asyncfiles-io_uring
- **aiofiles**: 1.67x slower than asyncfiles-io_uring
- **anyio**: 1.74x slower than asyncfiles-io_uring
- **aiofile**: 2.62x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2038.6 | 8154.5 | 0.7 | 0.9 | 1.9 | 0.13 | 0 | 28 | 50 |
| asyncfiles-io_uring | 1865.7 | 7462.9 | 0.8 | 1.1 | 1.1 | 0.11 | 0 | 30 | 50 |
| aiofiles | 634.4 | 2537.5 | 2.7 | 3.2 | 3.4 | 0.28 | 0 | 30 | 50 |
| anyio | 503.4 | 2013.5 | 3.5 | 4.0 | 4.3 | 0.37 | 0 | 30 | 50 |
| aiofile | 403.8 | 1615.3 | 2.9 | 11.6 | 19.5 | 0.52 | 0 | 31 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2038.6 MB/s (8154.5 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.13 s
- **Peak Memory**: 28 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.09x slower than asyncfiles-libuv
- **aiofiles**: 3.21x slower than asyncfiles-libuv
- **anyio**: 4.05x slower than asyncfiles-libuv
- **aiofile**: 5.05x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2062.0 | 8247.9 | 1.4 | 1.9 | 2.4 | 0.21 | 0 | 34 | 50 |
| asyncfiles-libuv | 1280.9 | 5123.7 | 1.3 | 2.1 | 22.0 | 0.24 | 0 | 35 | 50 |
| aiofiles | 710.1 | 2840.5 | 4.8 | 5.5 | 5.6 | 0.51 | 0 | 35 | 50 |
| anyio | 568.3 | 2273.3 | 6.2 | 7.4 | 8.1 | 0.66 | 1 | 35 | 50 |
| aiofile | 384.4 | 1537.7 | 5.1 | 27.3 | 36.9 | 1.03 | 0 | 35 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2062.0 MB/s (8247.9 ops/s)
- **p95 Latency**: 1.9 ms
- **CPU Time**: 0.21 s
- **Peak Memory**: 34 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.61x slower than asyncfiles-io_uring
- **aiofiles**: 2.90x slower than asyncfiles-io_uring
- **anyio**: 3.63x slower than asyncfiles-io_uring
- **aiofile**: 5.36x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2508.2 | 10032.7 | 2.4 | 2.9 | 3.2 | 0.41 | 0 | 43 | 50 |
| asyncfiles-libuv | 1522.2 | 6088.9 | 2.0 | 3.5 | 37.5 | 0.45 | 0 | 43 | 50 |
| aiofiles | 758.7 | 3034.9 | 9.3 | 10.3 | 13.2 | 0.99 | 0 | 43 | 50 |
| anyio | 614.9 | 2459.5 | 11.7 | 13.1 | 19.6 | 1.20 | 1 | 44 | 50 |
| aiofile | 388.6 | 1554.4 | 9.0 | 34.9 | 47.3 | 2.01 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2508.2 MB/s (10032.7 ops/s)
- **p95 Latency**: 2.9 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 43 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.65x slower than asyncfiles-io_uring
- **aiofiles**: 3.31x slower than asyncfiles-io_uring
- **anyio**: 4.08x slower than asyncfiles-io_uring
- **aiofile**: 6.45x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1092.4 | 2184.9 | 0.4 | 0.5 | 0.5 | 0.02 | 0 | 38 | 50 |
| asyncfiles-libuv | 941.9 | 1883.7 | 0.5 | 0.7 | 0.9 | 0.03 | 0 | 39 | 50 |
| aiofiles | 729.3 | 1458.7 | 0.6 | 0.7 | 0.8 | 0.04 | 0 | 39 | 50 |
| anyio | 657.1 | 1314.2 | 0.7 | 0.8 | 2.3 | 0.10 | 0 | 39 | 50 |
| aiofile | 362.1 | 724.2 | 1.3 | 1.7 | 3.9 | 0.11 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1092.4 MB/s (2184.9 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 38 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.16x slower than asyncfiles-io_uring
- **aiofiles**: 1.50x slower than asyncfiles-io_uring
- **anyio**: 1.66x slower than asyncfiles-io_uring
- **aiofile**: 3.02x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 3082.5 | 6165.0 | 0.9 | 1.2 | 1.4 | 0.18 | 0 | 47 | 50 |
| asyncfiles-io_uring | 2842.0 | 5684.0 | 1.0 | 1.5 | 1.7 | 0.16 | 0 | 48 | 50 |
| aiofiles | 1174.7 | 2349.4 | 2.9 | 3.5 | 3.6 | 0.33 | 0 | 48 | 50 |
| anyio | 920.7 | 1841.3 | 3.8 | 4.4 | 4.6 | 0.43 | 0 | 48 | 50 |
| aiofile | 401.0 | 802.0 | 3.6 | 33.5 | 45.4 | 0.82 | 0 | 48 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 3082.5 MB/s (6165.0 ops/s)
- **p95 Latency**: 1.2 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.08x slower than asyncfiles-libuv
- **aiofiles**: 2.62x slower than asyncfiles-libuv
- **anyio**: 3.35x slower than asyncfiles-libuv
- **aiofile**: 7.69x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3456.2 | 6912.3 | 1.7 | 2.2 | 2.8 | 0.31 | 0 | 50 | 50 |
| asyncfiles-libuv | 3091.2 | 6182.4 | 1.5 | 1.9 | 4.0 | 0.34 | 0 | 50 | 50 |
| aiofiles | 1289.6 | 2579.3 | 5.3 | 6.3 | 7.6 | 0.61 | 0 | 50 | 50 |
| anyio | 1048.2 | 2096.5 | 6.7 | 7.7 | 8.0 | 0.78 | 0 | 50 | 50 |
| aiofile | 411.2 | 822.3 | 6.1 | 46.1 | 52.6 | 1.59 | 0 | 50 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3456.2 MB/s (6912.3 ops/s)
- **p95 Latency**: 2.2 ms
- **CPU Time**: 0.31 s
- **Peak Memory**: 50 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.12x slower than asyncfiles-io_uring
- **aiofiles**: 2.68x slower than asyncfiles-io_uring
- **anyio**: 3.30x slower than asyncfiles-io_uring
- **aiofile**: 8.41x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3735.6 | 7471.1 | 3.3 | 4.1 | 4.2 | 0.63 | 0 | 62 | 50 |
| asyncfiles-libuv | 2806.9 | 5613.9 | 2.8 | 3.8 | 29.8 | 0.66 | 0 | 61 | 50 |
| aiofiles | 1384.6 | 2769.3 | 10.2 | 11.3 | 12.0 | 1.19 | 0 | 62 | 50 |
| anyio | 1145.3 | 2290.7 | 12.6 | 14.3 | 15.1 | 1.45 | 0 | 62 | 50 |
| aiofile | 400.5 | 800.9 | 29.4 | 58.6 | 60.8 | 3.22 | 0 | 62 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3735.6 MB/s (7471.1 ops/s)
- **p95 Latency**: 4.1 ms
- **CPU Time**: 0.63 s
- **Peak Memory**: 62 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.33x slower than asyncfiles-io_uring
- **aiofiles**: 2.70x slower than asyncfiles-io_uring
- **anyio**: 3.26x slower than asyncfiles-io_uring
- **aiofile**: 9.33x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1717.7 | 1717.7 | 0.5 | 0.7 | 1.4 | 0.03 | 0 | 51 | 50 |
| asyncfiles-libuv | 1555.6 | 1555.6 | 0.6 | 0.7 | 0.9 | 0.03 | 0 | 51 | 50 |
| aiofiles | 1238.8 | 1238.8 | 0.7 | 0.8 | 1.0 | 0.04 | 0 | 52 | 50 |
| anyio | 1118.0 | 1118.0 | 0.8 | 0.9 | 1.2 | 0.14 | 0 | 51 | 50 |
| aiofile | 359.0 | 359.0 | 1.3 | 14.8 | 35.3 | 0.19 | 0 | 52 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1717.7 MB/s (1717.7 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.10x slower than asyncfiles-io_uring
- **aiofiles**: 1.39x slower than asyncfiles-io_uring
- **anyio**: 1.54x slower than asyncfiles-io_uring
- **aiofile**: 4.78x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4000.7 | 4000.7 | 1.4 | 1.9 | 2.1 | 0.25 | 0 | 61 | 50 |
| asyncfiles-libuv | 3124.4 | 3124.4 | 1.5 | 1.8 | 2.2 | 0.27 | 0 | 61 | 50 |
| aiofiles | 2089.9 | 2089.9 | 3.3 | 3.9 | 4.1 | 0.41 | 0 | 61 | 50 |
| anyio | 1519.3 | 1519.3 | 4.6 | 6.2 | 7.2 | 0.56 | 0 | 60 | 50 |
| aiofile | 405.8 | 405.8 | 6.0 | 50.9 | 56.8 | 1.38 | 0 | 61 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4000.7 MB/s (4000.7 ops/s)
- **p95 Latency**: 1.9 ms
- **CPU Time**: 0.25 s
- **Peak Memory**: 61 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.28x slower than asyncfiles-io_uring
- **aiofiles**: 1.91x slower than asyncfiles-io_uring
- **anyio**: 2.63x slower than asyncfiles-io_uring
- **aiofile**: 9.86x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4707.9 | 4707.9 | 2.4 | 3.2 | 3.6 | 0.52 | 0 | 72 | 50 |
| asyncfiles-libuv | 4365.3 | 4365.3 | 2.5 | 3.2 | 4.3 | 0.54 | 0 | 72 | 50 |
| aiofiles | 2232.0 | 2232.0 | 6.3 | 7.1 | 7.5 | 0.81 | 0 | 69 | 50 |
| anyio | 1828.9 | 1828.9 | 7.7 | 8.8 | 9.6 | 0.98 | 0 | 69 | 50 |
| aiofile | 408.2 | 408.2 | 40.1 | 59.8 | 62.4 | 2.75 | 0 | 69 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4707.9 MB/s (4707.9 ops/s)
- **p95 Latency**: 3.2 ms
- **CPU Time**: 0.52 s
- **Peak Memory**: 72 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.08x slower than asyncfiles-io_uring
- **aiofiles**: 2.11x slower than asyncfiles-io_uring
- **anyio**: 2.57x slower than asyncfiles-io_uring
- **aiofile**: 11.53x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4983.3 | 4983.3 | 4.8 | 6.8 | 7.2 | 1.06 | 0 | 97 | 50 |
| asyncfiles-libuv | 4031.3 | 4031.3 | 4.7 | 5.7 | 8.6 | 1.08 | 0 | 97 | 50 |
| aiofiles | 2335.4 | 2335.4 | 12.3 | 13.5 | 14.1 | 1.61 | 0 | 97 | 50 |
| anyio | 1913.1 | 1913.1 | 14.9 | 19.0 | 22.6 | 1.85 | 0 | 91 | 50 |
| aiofile | 398.5 | 398.5 | 46.8 | 104.4 | 106.9 | 5.65 | 0 | 97 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4983.3 MB/s (4983.3 ops/s)
- **p95 Latency**: 6.8 ms
- **CPU Time**: 1.06 s
- **Peak Memory**: 97 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.24x slower than asyncfiles-io_uring
- **aiofiles**: 2.13x slower than asyncfiles-io_uring
- **anyio**: 2.60x slower than asyncfiles-io_uring
- **aiofile**: 12.51x slower than asyncfiles-io_uring
