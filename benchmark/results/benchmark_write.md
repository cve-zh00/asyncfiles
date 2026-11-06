# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-06 23:15 UTC

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
| asyncfiles-io_uring | 736.8 | 2947.3 | 0.3 | 0.3 | 0.4 | 0.01 | 0 | 22 | 50 |
| asyncfiles-libuv | 646.4 | 2585.4 | 0.3 | 0.4 | 0.5 | 0.02 | 0 | 23 | 50 |
| aiofiles | 589.7 | 2358.8 | 0.4 | 0.4 | 1.4 | 0.02 | 0 | 23 | 50 |
| anyio | 510.2 | 2040.8 | 0.4 | 0.5 | 0.6 | 0.09 | 0 | 23 | 50 |
| aiofile | 255.8 | 1023.2 | 0.8 | 1.2 | 1.4 | 0.07 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 736.8 MB/s (2947.3 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.14x slower than asyncfiles-io_uring
- **aiofiles**: 1.25x slower than asyncfiles-io_uring
- **anyio**: 1.44x slower than asyncfiles-io_uring
- **aiofile**: 2.88x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2058.5 | 8234.1 | 0.7 | 0.9 | 1.0 | 0.09 | 0 | 30 | 50 |
| asyncfiles-io_uring | 1933.7 | 7734.7 | 0.8 | 0.9 | 1.4 | 0.08 | 0 | 30 | 50 |
| aiofiles | 816.9 | 3267.6 | 2.1 | 2.4 | 2.5 | 0.20 | 0 | 32 | 50 |
| anyio | 692.3 | 2769.2 | 2.6 | 3.0 | 3.1 | 0.28 | 0 | 32 | 50 |
| aiofile | 244.8 | 979.1 | 7.4 | 7.9 | 28.4 | 0.60 | 0 | 32 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2058.5 MB/s (8234.1 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.09 s
- **Peak Memory**: 30 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.06x slower than asyncfiles-libuv
- **aiofiles**: 2.52x slower than asyncfiles-libuv
- **anyio**: 2.97x slower than asyncfiles-libuv
- **aiofile**: 8.41x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2330.7 | 9322.9 | 1.2 | 1.5 | 1.6 | 0.18 | 0 | 32 | 50 |
| aiofiles | 890.2 | 3560.9 | 3.7 | 4.1 | 4.2 | 0.38 | 0 | 36 | 50 |
| asyncfiles-io_uring | 853.3 | 3413.1 | 1.6 | 3.9 | 86.5 | 0.18 | 0 | 36 | 50 |
| anyio | 760.1 | 3040.3 | 4.7 | 5.3 | 5.5 | 0.50 | 0 | 35 | 50 |
| aiofile | 231.1 | 924.5 | 13.6 | 33.0 | 37.5 | 1.25 | 0 | 36 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2330.7 MB/s (9322.9 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 32 MB

## Performance Comparison

- **aiofiles**: 2.62x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 2.73x slower than asyncfiles-libuv
- **anyio**: 3.07x slower than asyncfiles-libuv
- **aiofile**: 10.08x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2593.0 | 10371.9 | 2.3 | 2.6 | 3.2 | 0.35 | 0 | 44 | 50 |
| asyncfiles-io_uring | 2124.5 | 8498.0 | 3.1 | 3.4 | 3.6 | 0.33 | 0 | 36 | 50 |
| aiofiles | 1037.6 | 4150.5 | 6.8 | 7.4 | 7.9 | 0.72 | 0 | 36 | 50 |
| anyio | 854.5 | 3418.1 | 8.3 | 9.1 | 9.5 | 0.92 | 0 | 37 | 50 |
| aiofile | 135.7 | 542.7 | 26.4 | 139.2 | 248.4 | 3.73 | 0 | 45 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2593.0 MB/s (10371.9 ops/s)
- **p95 Latency**: 2.6 ms
- **CPU Time**: 0.35 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.22x slower than asyncfiles-libuv
- **aiofiles**: 2.50x slower than asyncfiles-libuv
- **anyio**: 3.03x slower than asyncfiles-libuv
- **aiofile**: 19.11x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1264.6 | 2529.2 | 0.4 | 0.4 | 0.5 | 0.02 | 0 | 40 | 50 |
| asyncfiles-libuv | 1106.3 | 2212.7 | 0.4 | 0.5 | 0.6 | 0.06 | 0 | 40 | 50 |
| aiofiles | 887.4 | 1774.8 | 0.5 | 0.6 | 0.8 | 0.03 | 0 | 40 | 50 |
| anyio | 804.1 | 1608.2 | 0.6 | 0.7 | 1.0 | 0.12 | 0 | 39 | 50 |
| aiofile | 178.0 | 355.9 | 1.9 | 10.3 | 22.0 | 0.17 | 0 | 40 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1264.6 MB/s (2529.2 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.14x slower than asyncfiles-io_uring
- **aiofiles**: 1.43x slower than asyncfiles-io_uring
- **anyio**: 1.57x slower than asyncfiles-io_uring
- **aiofile**: 7.11x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 3157.7 | 6315.4 | 0.9 | 1.1 | 1.2 | 0.15 | 0 | 42 | 50 |
| asyncfiles-io_uring | 2905.5 | 5810.9 | 1.0 | 1.2 | 1.4 | 0.13 | 0 | 42 | 50 |
| aiofiles | 1472.1 | 2944.3 | 2.3 | 2.7 | 2.8 | 0.24 | 0 | 42 | 50 |
| anyio | 1170.1 | 2340.1 | 3.0 | 3.4 | 4.2 | 0.37 | 0 | 42 | 50 |
| aiofile | 238.3 | 476.6 | 13.9 | 34.2 | 35.8 | 1.08 | 0 | 46 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 3157.7 MB/s (6315.4 ops/s)
- **p95 Latency**: 1.1 ms
- **CPU Time**: 0.15 s
- **Peak Memory**: 42 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.09x slower than asyncfiles-libuv
- **aiofiles**: 2.14x slower than asyncfiles-libuv
- **anyio**: 2.70x slower than asyncfiles-libuv
- **aiofile**: 13.25x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3168.8 | 6337.7 | 1.9 | 2.7 | 3.0 | 0.24 | 0 | 43 | 50 |
| asyncfiles-libuv | 1706.4 | 3412.7 | 1.4 | 13.6 | 25.2 | 0.27 | 0 | 51 | 50 |
| aiofiles | 1691.5 | 3383.0 | 4.1 | 4.5 | 4.7 | 0.46 | 0 | 43 | 50 |
| anyio | 1398.4 | 2796.8 | 5.1 | 5.7 | 6.0 | 0.61 | 0 | 44 | 50 |
| aiofile | 229.6 | 459.1 | 28.7 | 48.1 | 147.7 | 2.22 | 0 | 52 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3168.8 MB/s (6337.7 ops/s)
- **p95 Latency**: 2.7 ms
- **CPU Time**: 0.24 s
- **Peak Memory**: 43 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.86x slower than asyncfiles-io_uring
- **aiofiles**: 1.87x slower than asyncfiles-io_uring
- **anyio**: 2.27x slower than asyncfiles-io_uring
- **aiofile**: 13.80x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3594.6 | 7189.1 | 3.4 | 4.5 | 7.2 | 0.46 | 0 | 41 | 50 |
| asyncfiles-libuv | 1957.2 | 3914.4 | 2.6 | 26.6 | 40.7 | 0.49 | 0 | 57 | 50 |
| aiofiles | 1876.1 | 3752.3 | 7.4 | 8.2 | 14.0 | 0.89 | 0 | 41 | 50 |
| anyio | 1556.8 | 3113.5 | 9.2 | 10.0 | 13.1 | 1.07 | 0 | 41 | 50 |
| aiofile | 256.5 | 512.9 | 45.2 | 62.4 | 72.0 | 4.12 | 0 | 58 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3594.6 MB/s (7189.1 ops/s)
- **p95 Latency**: 4.5 ms
- **CPU Time**: 0.46 s
- **Peak Memory**: 41 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.84x slower than asyncfiles-io_uring
- **aiofiles**: 1.92x slower than asyncfiles-io_uring
- **anyio**: 2.31x slower than asyncfiles-io_uring
- **aiofile**: 14.02x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1974.0 | 1974.0 | 0.5 | 0.5 | 0.6 | 0.02 | 0 | 50 | 50 |
| asyncfiles-libuv | 1781.5 | 1781.5 | 0.5 | 0.6 | 1.2 | 0.02 | 0 | 50 | 50 |
| aiofiles | 1497.0 | 1497.0 | 0.6 | 0.7 | 0.8 | 0.03 | 0 | 50 | 50 |
| anyio | 522.0 | 522.0 | 0.6 | 1.0 | 60.7 | 0.11 | 0 | 49 | 50 |
| aiofile | 221.8 | 221.8 | 3.9 | 11.4 | 22.0 | 0.27 | 0 | 49 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1974.0 MB/s (1974.0 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 50 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.11x slower than asyncfiles-io_uring
- **aiofiles**: 1.32x slower than asyncfiles-io_uring
- **anyio**: 3.78x slower than asyncfiles-io_uring
- **aiofile**: 8.90x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4748.3 | 4748.3 | 1.3 | 1.5 | 1.6 | 0.20 | 0 | 54 | 50 |
| anyio | 2094.5 | 2094.5 | 3.4 | 3.8 | 4.0 | 0.42 | 0 | 53 | 50 |
| asyncfiles-libuv | 1875.7 | 1875.7 | 1.2 | 1.8 | 85.2 | 0.23 | 0 | 54 | 50 |
| aiofiles | 1077.8 | 1077.8 | 2.7 | 40.8 | 81.7 | 0.33 | 0 | 62 | 50 |
| aiofile | 262.9 | 262.9 | 29.2 | 32.7 | 53.1 | 1.87 | 0 | 62 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4748.3 MB/s (4748.3 ops/s)
- **p95 Latency**: 1.5 ms
- **CPU Time**: 0.20 s
- **Peak Memory**: 54 MB

## Performance Comparison

- **anyio**: 2.27x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.53x slower than asyncfiles-io_uring
- **aiofiles**: 4.41x slower than asyncfiles-io_uring
- **aiofile**: 18.06x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4773.4 | 4773.4 | 2.7 | 3.3 | 3.6 | 0.39 | 0 | 60 | 50 |
| anyio | 2193.0 | 2193.0 | 5.9 | 6.6 | 41.8 | 0.73 | 0 | 54 | 50 |
| asyncfiles-libuv | 1618.4 | 1618.4 | 1.9 | 31.3 | 67.8 | 0.40 | 0 | 76 | 50 |
| aiofiles | 1149.4 | 1149.4 | 4.6 | 8.7 | 197.4 | 0.61 | 0 | 75 | 50 |
| aiofile | 217.2 | 217.2 | 60.4 | 95.9 | 258.2 | 4.20 | 0 | 71 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4773.4 MB/s (4773.4 ops/s)
- **p95 Latency**: 3.3 ms
- **CPU Time**: 0.39 s
- **Peak Memory**: 60 MB

## Performance Comparison

- **anyio**: 2.18x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.95x slower than asyncfiles-io_uring
- **aiofiles**: 4.15x slower than asyncfiles-io_uring
- **aiofile**: 21.98x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 343.6 | 343.6 | 3.6 | 94.2 | 104.0 | 0.83 | 0 | 90 | 50 |
| asyncfiles-io_uring | 337.6 | 337.6 | 92.0 | 96.9 | 100.3 | 0.80 | 0 | 90 | 50 |
| aiofiles | 314.0 | 314.0 | 8.9 | 103.5 | 116.9 | 1.22 | 0 | 90 | 50 |
| anyio | 308.4 | 308.4 | 10.3 | 105.0 | 114.3 | 1.37 | 0 | 86 | 50 |
| aiofile | 237.0 | 237.0 | 97.7 | 149.7 | 227.4 | 7.98 | 0 | 88 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 343.6 MB/s (343.6 ops/s)
- **p95 Latency**: 94.2 ms
- **CPU Time**: 0.83 s
- **Peak Memory**: 90 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.02x slower than asyncfiles-libuv
- **aiofiles**: 1.09x slower than asyncfiles-libuv
- **anyio**: 1.11x slower than asyncfiles-libuv
- **aiofile**: 1.45x slower than asyncfiles-libuv
