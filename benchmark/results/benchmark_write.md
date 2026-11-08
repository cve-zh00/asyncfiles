# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-08 16:02 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 8 |
| asyncfiles-libuv | 3 |
| anyio | 1 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 493.7 | 1974.6 | 0.4 | 0.8 | 0.8 | 0.01 | 0 | 23 | 50 |
| asyncfiles-libuv | 344.3 | 1377.4 | 0.5 | 1.3 | 2.6 | 0.01 | 0 | 22 | 50 |
| aiofiles | 340.7 | 1362.6 | 0.6 | 1.0 | 4.3 | 0.02 | 0 | 22 | 50 |
| anyio | 158.9 | 635.7 | 0.6 | 1.0 | 44.6 | 0.10 | 0 | 23 | 50 |
| aiofile | 158.1 | 632.6 | 1.6 | 1.9 | 1.9 | 0.10 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 493.7 MB/s (1974.6 ops/s)
- **p95 Latency**: 0.8 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.43x slower than asyncfiles-io_uring
- **aiofiles**: 1.45x slower than asyncfiles-io_uring
- **anyio**: 3.11x slower than asyncfiles-io_uring
- **aiofile**: 3.12x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1622.4 | 6489.6 | 0.9 | 1.2 | 1.8 | 0.07 | 0 | 29 | 50 |
| asyncfiles-libuv | 1161.5 | 4645.9 | 1.0 | 1.8 | 5.1 | 0.08 | 0 | 29 | 50 |
| aiofiles | 725.4 | 2901.6 | 2.4 | 2.9 | 3.0 | 0.18 | 0 | 31 | 50 |
| anyio | 594.5 | 2377.8 | 2.9 | 3.5 | 5.6 | 0.31 | 0 | 31 | 50 |
| aiofile | 201.0 | 803.9 | 8.8 | 11.7 | 29.8 | 0.66 | 0 | 31 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1622.4 MB/s (6489.6 ops/s)
- **p95 Latency**: 1.2 ms
- **CPU Time**: 0.07 s
- **Peak Memory**: 29 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.40x slower than asyncfiles-io_uring
- **aiofiles**: 2.24x slower than asyncfiles-io_uring
- **anyio**: 2.73x slower than asyncfiles-io_uring
- **aiofile**: 8.07x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2316.2 | 9264.7 | 1.3 | 1.6 | 1.7 | 0.14 | 0 | 34 | 50 |
| asyncfiles-io_uring | 1869.9 | 7479.4 | 1.7 | 2.2 | 3.9 | 0.12 | 0 | 35 | 50 |
| aiofiles | 852.2 | 3408.7 | 4.0 | 4.7 | 5.6 | 0.33 | 0 | 31 | 50 |
| anyio | 702.9 | 2811.7 | 4.9 | 5.8 | 6.2 | 0.45 | 0 | 31 | 50 |
| aiofile | 208.3 | 833.3 | 16.8 | 21.6 | 38.8 | 1.25 | 0 | 35 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2316.2 MB/s (9264.7 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.14 s
- **Peak Memory**: 34 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.24x slower than asyncfiles-libuv
- **aiofiles**: 2.72x slower than asyncfiles-libuv
- **anyio**: 3.30x slower than asyncfiles-libuv
- **aiofile**: 11.12x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2024.2 | 8096.8 | 3.3 | 4.4 | 4.8 | 0.22 | 0 | 34 | 50 |
| asyncfiles-libuv | 1694.1 | 6776.3 | 3.9 | 8.1 | 9.1 | 0.24 | 0 | 34 | 50 |
| aiofiles | 960.8 | 3843.1 | 7.3 | 8.3 | 9.4 | 0.60 | 0 | 35 | 50 |
| anyio | 786.6 | 3146.5 | 8.7 | 10.2 | 10.9 | 0.80 | 0 | 35 | 50 |
| aiofile | 217.9 | 871.6 | 26.2 | 50.0 | 53.0 | 2.41 | 0 | 43 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2024.2 MB/s (8096.8 ops/s)
- **p95 Latency**: 4.4 ms
- **CPU Time**: 0.22 s
- **Peak Memory**: 34 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.19x slower than asyncfiles-io_uring
- **aiofiles**: 2.11x slower than asyncfiles-io_uring
- **anyio**: 2.57x slower than asyncfiles-io_uring
- **aiofile**: 9.29x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 587.9 | 1175.8 | 0.8 | 1.3 | 4.1 | 0.01 | 0 | 38 | 50 |
| asyncfiles-libuv | 491.7 | 983.5 | 1.0 | 1.4 | 3.3 | 0.02 | 0 | 38 | 50 |
| anyio | 453.6 | 907.2 | 1.0 | 1.5 | 4.2 | 0.09 | 0 | 38 | 50 |
| aiofiles | 438.4 | 876.8 | 1.1 | 1.6 | 3.7 | 0.03 | 0 | 38 | 50 |
| aiofile | 152.9 | 305.9 | 2.8 | 3.5 | 23.1 | 0.19 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 587.9 MB/s (1175.8 ops/s)
- **p95 Latency**: 1.3 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 38 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.20x slower than asyncfiles-io_uring
- **anyio**: 1.30x slower than asyncfiles-io_uring
- **aiofiles**: 1.34x slower than asyncfiles-io_uring
- **aiofile**: 3.84x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2731.5 | 5462.9 | 0.9 | 1.5 | 6.1 | 0.11 | 0 | 40 | 50 |
| asyncfiles-io_uring | 2149.9 | 4299.9 | 1.2 | 1.6 | 6.0 | 0.10 | 0 | 43 | 50 |
| aiofiles | 1294.7 | 2589.4 | 2.5 | 3.9 | 5.8 | 0.21 | 0 | 44 | 50 |
| anyio | 1171.8 | 2343.6 | 3.0 | 3.5 | 3.8 | 0.33 | 0 | 41 | 50 |
| aiofile | 224.3 | 448.5 | 16.3 | 36.3 | 38.3 | 1.07 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2731.5 MB/s (5462.9 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.11 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.27x slower than asyncfiles-libuv
- **aiofiles**: 2.11x slower than asyncfiles-libuv
- **anyio**: 2.33x slower than asyncfiles-libuv
- **aiofile**: 12.18x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 3117.2 | 6234.5 | 1.8 | 2.5 | 5.4 | 0.19 | 0 | 40 | 50 |
| asyncfiles-io_uring | 2917.8 | 5835.6 | 2.0 | 3.5 | 7.8 | 0.18 | 0 | 40 | 50 |
| aiofiles | 1512.0 | 3024.1 | 4.2 | 5.0 | 24.3 | 0.38 | 0 | 40 | 50 |
| anyio | 1359.5 | 2719.0 | 5.1 | 6.1 | 6.5 | 0.52 | 0 | 40 | 50 |
| aiofile | 223.0 | 446.0 | 31.4 | 52.8 | 55.7 | 2.14 | 0 | 49 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 3117.2 MB/s (6234.5 ops/s)
- **p95 Latency**: 2.5 ms
- **CPU Time**: 0.19 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.07x slower than asyncfiles-libuv
- **aiofiles**: 2.06x slower than asyncfiles-libuv
- **anyio**: 2.29x slower than asyncfiles-libuv
- **aiofile**: 13.98x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3044.7 | 6089.5 | 4.5 | 5.8 | 6.9 | 0.32 | 0 | 44 | 50 |
| aiofiles | 1789.2 | 3578.5 | 7.8 | 10.3 | 14.1 | 0.70 | 0 | 44 | 50 |
| anyio | 1503.9 | 3007.8 | 9.3 | 11.2 | 12.3 | 0.92 | 0 | 43 | 50 |
| asyncfiles-libuv | 1449.2 | 2898.3 | 4.1 | 32.9 | 50.0 | 0.35 | 0 | 60 | 50 |
| aiofile | 253.2 | 506.4 | 47.0 | 63.4 | 67.0 | 3.83 | 0 | 60 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3044.7 MB/s (6089.5 ops/s)
- **p95 Latency**: 5.8 ms
- **CPU Time**: 0.32 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **aiofiles**: 1.70x slower than asyncfiles-io_uring
- **anyio**: 2.02x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.10x slower than asyncfiles-io_uring
- **aiofile**: 12.03x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 1107.1 | 1107.1 | 0.8 | 0.9 | 3.9 | 0.12 | 0 | 50 | 50 |
| asyncfiles-io_uring | 1060.0 | 1060.0 | 0.9 | 1.3 | 4.2 | 0.02 | 0 | 50 | 50 |
| asyncfiles-libuv | 1038.9 | 1038.9 | 0.9 | 1.3 | 2.9 | 0.02 | 0 | 50 | 50 |
| aiofiles | 849.1 | 849.1 | 1.1 | 1.5 | 4.3 | 0.03 | 0 | 50 | 50 |
| aiofile | 206.2 | 206.2 | 4.8 | 5.3 | 6.8 | 0.27 | 0 | 51 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 1107.1 MB/s (1107.1 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 50 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.04x slower than anyio
- **asyncfiles-libuv**: 1.07x slower than anyio
- **aiofiles**: 1.30x slower than anyio
- **aiofile**: 5.37x slower than anyio


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4979.6 | 4979.6 | 1.3 | 1.5 | 4.0 | 0.15 | 0 | 50 | 50 |
| aiofiles | 2616.7 | 2616.7 | 2.6 | 3.2 | 3.4 | 0.26 | 0 | 50 | 50 |
| anyio | 2202.5 | 2202.5 | 3.2 | 3.8 | 4.0 | 0.39 | 0 | 49 | 50 |
| asyncfiles-libuv | 1458.4 | 1458.4 | 1.1 | 15.5 | 26.8 | 0.16 | 0 | 58 | 50 |
| aiofile | 247.9 | 247.9 | 31.8 | 32.7 | 35.0 | 1.85 | 0 | 59 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4979.6 MB/s (4979.6 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.15 s
- **Peak Memory**: 50 MB

## Performance Comparison

- **aiofiles**: 1.90x slower than asyncfiles-io_uring
- **anyio**: 2.26x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 3.41x slower than asyncfiles-io_uring
- **aiofile**: 20.09x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 5703.7 | 5703.7 | 2.4 | 2.8 | 3.1 | 0.27 | 0 | 58 | 50 |
| aiofiles | 2919.0 | 2919.0 | 4.7 | 5.4 | 9.6 | 0.49 | 0 | 57 | 50 |
| anyio | 2153.2 | 2153.2 | 5.6 | 6.5 | 7.8 | 0.64 | 0 | 64 | 50 |
| asyncfiles-libuv | 1784.2 | 1784.2 | 1.6 | 29.3 | 51.8 | 0.31 | 0 | 74 | 50 |
| aiofile | 257.2 | 257.2 | 61.5 | 62.7 | 66.0 | 3.58 | 0 | 67 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 5703.7 MB/s (5703.7 ops/s)
- **p95 Latency**: 2.8 ms
- **CPU Time**: 0.27 s
- **Peak Memory**: 58 MB

## Performance Comparison

- **aiofiles**: 1.95x slower than asyncfiles-io_uring
- **anyio**: 2.65x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 3.20x slower than asyncfiles-io_uring
- **aiofile**: 22.18x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 334.2 | 334.2 | 6.7 | 96.7 | 101.1 | 0.54 | 0 | 97 | 50 |
| asyncfiles-libuv | 333.5 | 333.5 | 5.0 | 96.1 | 101.9 | 0.57 | 0 | 97 | 50 |
| anyio | 322.0 | 322.0 | 10.0 | 99.5 | 100.1 | 1.10 | 0 | 91 | 50 |
| aiofiles | 321.9 | 321.9 | 8.9 | 98.7 | 106.8 | 0.93 | 0 | 95 | 50 |
| aiofile | 259.5 | 259.5 | 89.4 | 123.2 | 128.3 | 7.04 | 0 | 92 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 334.2 MB/s (334.2 ops/s)
- **p95 Latency**: 96.7 ms
- **CPU Time**: 0.54 s
- **Peak Memory**: 97 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as asyncfiles-io_uring
- **anyio**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 1.04x slower than asyncfiles-io_uring
- **aiofile**: 1.29x slower than asyncfiles-io_uring
