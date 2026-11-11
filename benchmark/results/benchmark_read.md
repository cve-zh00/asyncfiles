# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Page cache**: cold (evicted)
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-11 03:26 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 5 |
| asyncfiles-io_uring | 3 |
| aiofile | 2 |
| anyio | 1 |
| aiofiles | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 465.2 | 1860.8 | 0.5 | 0.5 | 0.9 | 0.01 | 0 | 20 | 50 |
| asyncfiles-io_uring | 427.6 | 1710.3 | 0.4 | 0.5 | 7.0 | 0.01 | 0 | 21 | 50 |
| anyio | 372.4 | 1489.5 | 0.6 | 0.7 | 0.8 | 0.06 | 0 | 23 | 50 |
| aiofiles | 100.2 | 400.9 | 0.6 | 0.7 | 93.9 | 0.02 | 0 | 21 | 50 |
| aiofile | 98.0 | 391.8 | 0.6 | 1.5 | 75.6 | 0.17 | 0 | 21 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 465.2 MB/s (1860.8 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.09x slower than asyncfiles-libuv
- **anyio**: 1.25x slower than asyncfiles-libuv
- **aiofiles**: 4.64x slower than asyncfiles-libuv
- **aiofile**: 4.75x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 430.0 | 1719.8 | 2.5 | 3.5 | 16.1 | 0.49 | 0 | 29 | 50 |
| asyncfiles-libuv | 240.0 | 960.1 | 1.4 | 5.9 | 23.5 | 0.16 | 0 | 26 | 50 |
| asyncfiles-io_uring | 236.2 | 945.0 | 1.6 | 6.1 | 46.8 | 0.12 | 0 | 26 | 50 |
| anyio | 198.9 | 795.7 | 2.5 | 9.4 | 32.2 | 0.33 | 0 | 32 | 50 |
| aiofiles | 127.5 | 510.1 | 2.1 | 10.2 | 100.2 | 0.23 | 0 | 28 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 430.0 MB/s (1719.8 ops/s)
- **p95 Latency**: 3.5 ms
- **CPU Time**: 0.49 s
- **Peak Memory**: 29 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.79x slower than aiofile
- **asyncfiles-io_uring**: 1.82x slower than aiofile
- **anyio**: 2.16x slower than aiofile
- **aiofiles**: 3.37x slower than aiofile


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 504.7 | 2018.8 | 4.7 | 11.0 | 18.7 | 0.54 | 0 | 37 | 50 |
| asyncfiles-io_uring | 358.9 | 1435.6 | 3.1 | 8.8 | 20.1 | 0.21 | 0 | 37 | 50 |
| aiofiles | 333.9 | 1335.7 | 4.6 | 10.1 | 26.6 | 0.44 | 0 | 35 | 50 |
| aiofile | 304.5 | 1218.0 | 4.7 | 8.6 | 19.3 | 0.92 | 0 | 37 | 50 |
| asyncfiles-libuv | 286.3 | 1145.2 | 2.5 | 15.3 | 27.2 | 0.32 | 0 | 38 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 504.7 MB/s (2018.8 ops/s)
- **p95 Latency**: 11.0 ms
- **CPU Time**: 0.54 s
- **Peak Memory**: 37 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.41x slower than anyio
- **aiofiles**: 1.51x slower than anyio
- **aiofile**: 1.66x slower than anyio
- **asyncfiles-libuv**: 1.76x slower than anyio


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 375.2 | 1500.8 | 8.9 | 25.2 | 37.5 | 1.92 | 1 | 46 | 50 |
| anyio | 271.1 | 1084.2 | 8.3 | 17.6 | 82.1 | 1.03 | 0 | 44 | 50 |
| asyncfiles-io_uring | 270.5 | 1081.9 | 8.3 | 19.7 | 80.0 | 0.44 | 0 | 48 | 50 |
| aiofiles | 217.0 | 867.9 | 11.2 | 79.9 | 99.4 | 0.83 | 0 | 43 | 50 |
| asyncfiles-libuv | 215.1 | 860.2 | 7.3 | 47.1 | 503.1 | 0.63 | 0 | 48 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 375.2 MB/s (1500.8 ops/s)
- **p95 Latency**: 25.2 ms
- **CPU Time**: 1.92 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **anyio**: 1.38x slower than aiofile
- **asyncfiles-io_uring**: 1.39x slower than aiofile
- **aiofiles**: 1.73x slower than aiofile
- **asyncfiles-libuv**: 1.74x slower than aiofile


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 525.9 | 1051.8 | 0.9 | 1.3 | 1.6 | 0.01 | 0 | 37 | 50 |
| asyncfiles-libuv | 445.8 | 891.6 | 1.0 | 1.5 | 1.8 | 0.02 | 0 | 37 | 50 |
| aiofiles | 438.4 | 876.9 | 1.1 | 1.4 | 1.7 | 0.03 | 0 | 40 | 50 |
| anyio | 341.3 | 682.6 | 1.2 | 2.8 | 7.1 | 0.10 | 0 | 40 | 50 |
| aiofile | 299.2 | 598.5 | 1.2 | 4.2 | 14.6 | 0.11 | 0 | 40 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 525.9 MB/s (1051.8 ops/s)
- **p95 Latency**: 1.3 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 37 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.18x slower than asyncfiles-io_uring
- **aiofiles**: 1.20x slower than asyncfiles-io_uring
- **anyio**: 1.54x slower than asyncfiles-io_uring
- **aiofile**: 1.76x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 575.5 | 1150.9 | 6.5 | 9.2 | 9.4 | 0.26 | 0 | 44 | 50 |
| aiofile | 497.4 | 994.7 | 4.1 | 9.1 | 22.4 | 0.70 | 0 | 47 | 50 |
| anyio | 341.8 | 683.7 | 6.0 | 9.4 | 12.4 | 0.35 | 0 | 45 | 50 |
| asyncfiles-io_uring | 244.8 | 489.5 | 7.3 | 8.7 | 275.6 | 0.19 | 0 | 47 | 50 |
| asyncfiles-libuv | 148.6 | 297.2 | 2.8 | 12.7 | 349.9 | 0.26 | 0 | 47 | 50 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 575.5 MB/s (1150.9 ops/s)
- **p95 Latency**: 9.2 ms
- **CPU Time**: 0.26 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **aiofile**: 1.16x slower than aiofiles
- **anyio**: 1.68x slower than aiofiles
- **asyncfiles-io_uring**: 2.35x slower than aiofiles
- **asyncfiles-libuv**: 3.87x slower than aiofiles


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 560.4 | 1120.8 | 7.8 | 16.9 | 17.8 | 0.49 | 0 | 57 | 50 |
| anyio | 501.4 | 1002.8 | 9.5 | 20.3 | 49.6 | 0.67 | 0 | 50 | 50 |
| asyncfiles-io_uring | 419.1 | 838.3 | 9.5 | 23.0 | 60.1 | 0.36 | 0 | 57 | 50 |
| aiofiles | 401.8 | 803.5 | 9.4 | 22.4 | 76.7 | 0.55 | 0 | 53 | 50 |
| aiofile | 374.2 | 748.4 | 8.4 | 22.9 | 64.8 | 1.52 | 0 | 57 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 560.4 MB/s (1120.8 ops/s)
- **p95 Latency**: 16.9 ms
- **CPU Time**: 0.49 s
- **Peak Memory**: 57 MB

## Performance Comparison

- **anyio**: 1.12x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.34x slower than asyncfiles-libuv
- **aiofiles**: 1.39x slower than asyncfiles-libuv
- **aiofile**: 1.50x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 473.6 | 947.2 | 16.0 | 36.7 | 49.1 | 0.93 | 0 | 72 | 50 |
| anyio | 425.7 | 851.4 | 20.7 | 45.4 | 59.1 | 1.26 | 0 | 61 | 50 |
| aiofile | 415.9 | 831.8 | 19.7 | 42.4 | 88.6 | 2.97 | 0 | 70 | 50 |
| aiofiles | 403.1 | 806.2 | 28.3 | 54.5 | 57.6 | 1.01 | 0 | 60 | 50 |
| asyncfiles-io_uring | 326.0 | 652.1 | 20.4 | 42.5 | 190.9 | 0.72 | 0 | 72 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 473.6 MB/s (947.2 ops/s)
- **p95 Latency**: 36.7 ms
- **CPU Time**: 0.93 s
- **Peak Memory**: 72 MB

## Performance Comparison

- **anyio**: 1.11x slower than asyncfiles-libuv
- **aiofile**: 1.14x slower than asyncfiles-libuv
- **aiofiles**: 1.17x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.45x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 570.3 | 570.3 | 1.2 | 4.2 | 4.5 | 0.02 | 0 | 46 | 50 |
| aiofiles | 569.0 | 569.0 | 1.4 | 3.5 | 3.7 | 0.03 | 0 | 52 | 50 |
| asyncfiles-libuv | 557.6 | 557.6 | 1.3 | 4.2 | 4.6 | 0.02 | 0 | 46 | 50 |
| aiofile | 545.1 | 545.1 | 1.4 | 3.6 | 7.5 | 0.12 | 0 | 52 | 50 |
| anyio | 317.0 | 317.0 | 1.4 | 18.2 | 37.7 | 0.12 | 0 | 52 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 570.3 MB/s (570.3 ops/s)
- **p95 Latency**: 4.2 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **aiofiles**: about the same as asyncfiles-io_uring
- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofile**: 1.05x slower than asyncfiles-io_uring
- **anyio**: 1.80x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 542.4 | 542.4 | 9.0 | 18.6 | 18.8 | 0.41 | 0 | 66 | 50 |
| aiofile | 416.8 | 416.8 | 9.2 | 33.7 | 50.2 | 1.37 | 0 | 66 | 50 |
| aiofiles | 412.0 | 412.0 | 10.1 | 35.4 | 51.6 | 0.33 | 0 | 58 | 50 |
| asyncfiles-io_uring | 402.5 | 402.5 | 11.6 | 38.2 | 43.7 | 0.31 | 0 | 66 | 50 |
| anyio | 400.8 | 400.8 | 10.4 | 31.7 | 47.6 | 0.40 | 0 | 59 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 542.4 MB/s (542.4 ops/s)
- **p95 Latency**: 18.6 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 66 MB

## Performance Comparison

- **aiofile**: 1.30x slower than asyncfiles-libuv
- **aiofiles**: 1.32x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.35x slower than asyncfiles-libuv
- **anyio**: 1.35x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 426.2 | 426.2 | 28.0 | 58.2 | 88.1 | 0.61 | 0 | 82 | 50 |
| aiofile | 416.3 | 416.3 | 25.1 | 47.1 | 56.7 | 2.71 | 0 | 88 | 50 |
| aiofiles | 411.8 | 411.8 | 28.4 | 51.3 | 83.3 | 0.66 | 0 | 74 | 50 |
| anyio | 403.6 | 403.6 | 36.2 | 49.8 | 57.3 | 0.78 | 0 | 75 | 50 |
| asyncfiles-libuv | 401.1 | 401.1 | 17.2 | 82.6 | 103.9 | 0.75 | 0 | 82 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 426.2 MB/s (426.2 ops/s)
- **p95 Latency**: 58.2 ms
- **CPU Time**: 0.61 s
- **Peak Memory**: 82 MB

## Performance Comparison

- **aiofile**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 1.04x slower than asyncfiles-io_uring
- **anyio**: 1.06x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.06x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 429.9 | 429.9 | 36.1 | 85.1 | 97.1 | 1.54 | 0 | 117 | 50 |
| aiofiles | 406.5 | 406.5 | 67.7 | 95.3 | 98.3 | 1.37 | 0 | 93 | 50 |
| asyncfiles-io_uring | 405.0 | 405.0 | 56.8 | 90.2 | 112.1 | 1.25 | 0 | 118 | 50 |
| anyio | 403.2 | 403.2 | 55.5 | 88.5 | 103.6 | 1.55 | 0 | 96 | 50 |
| aiofile | 384.8 | 384.8 | 59.6 | 94.8 | 101.2 | 5.71 | 0 | 114 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 429.9 MB/s (429.9 ops/s)
- **p95 Latency**: 85.1 ms
- **CPU Time**: 1.54 s
- **Peak Memory**: 117 MB

## Performance Comparison

- **aiofiles**: 1.06x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.06x slower than asyncfiles-libuv
- **anyio**: 1.07x slower than asyncfiles-libuv
- **aiofile**: 1.12x slower than asyncfiles-libuv
