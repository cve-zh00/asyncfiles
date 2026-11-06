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
- **Generated**: 2026-11-06 23:15 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 6 |
| asyncfiles-io_uring | 3 |
| aiofile | 2 |
| aiofiles | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 616.9 | 2467.7 | 0.3 | 1.0 | 1.0 | 0.01 | 0 | 20 | 50 |
| asyncfiles-libuv | 564.1 | 2256.4 | 0.3 | 0.7 | 1.9 | 0.01 | 0 | 20 | 50 |
| aiofiles | 559.5 | 2238.0 | 0.4 | 0.6 | 0.6 | 0.02 | 0 | 21 | 50 |
| anyio | 483.5 | 1934.0 | 0.5 | 0.6 | 0.7 | 0.05 | 0 | 22 | 50 |
| aiofile | 329.9 | 1319.8 | 0.4 | 0.7 | 13.5 | 0.09 | 0 | 21 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 616.9 MB/s (2467.7 ops/s)
- **p95 Latency**: 1.0 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.09x slower than asyncfiles-io_uring
- **aiofiles**: 1.10x slower than asyncfiles-io_uring
- **anyio**: 1.28x slower than asyncfiles-io_uring
- **aiofile**: 1.87x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 540.8 | 2163.1 | 2.5 | 3.7 | 13.3 | 0.45 | 0 | 29 | 50 |
| anyio | 515.3 | 2061.4 | 2.4 | 3.8 | 6.1 | 0.34 | 0 | 31 | 50 |
| asyncfiles-libuv | 403.3 | 1613.4 | 1.6 | 3.6 | 17.6 | 0.15 | 0 | 25 | 50 |
| asyncfiles-io_uring | 356.6 | 1426.5 | 1.7 | 3.7 | 5.6 | 0.10 | 0 | 25 | 50 |
| aiofiles | 331.5 | 1326.0 | 2.0 | 3.9 | 12.3 | 0.22 | 0 | 28 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 540.8 MB/s (2163.1 ops/s)
- **p95 Latency**: 3.7 ms
- **CPU Time**: 0.45 s
- **Peak Memory**: 29 MB

## Performance Comparison

- **anyio**: 1.05x slower than aiofile
- **asyncfiles-libuv**: 1.34x slower than aiofile
- **asyncfiles-io_uring**: 1.52x slower than aiofile
- **aiofiles**: 1.63x slower than aiofile


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 562.2 | 2248.6 | 3.3 | 7.0 | 17.2 | 0.21 | 0 | 38 | 50 |
| asyncfiles-libuv | 542.8 | 2171.1 | 3.2 | 7.0 | 7.2 | 0.30 | 0 | 38 | 50 |
| anyio | 442.2 | 1768.9 | 4.9 | 7.5 | 18.9 | 0.57 | 0 | 36 | 50 |
| aiofiles | 423.5 | 1694.2 | 5.5 | 9.0 | 21.0 | 0.44 | 0 | 34 | 50 |
| aiofile | 372.6 | 1490.3 | 4.7 | 8.6 | 18.6 | 1.00 | 0 | 36 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 562.2 MB/s (2248.6 ops/s)
- **p95 Latency**: 7.0 ms
- **CPU Time**: 0.21 s
- **Peak Memory**: 38 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **anyio**: 1.27x slower than asyncfiles-io_uring
- **aiofiles**: 1.33x slower than asyncfiles-io_uring
- **aiofile**: 1.51x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 459.9 | 1839.7 | 6.3 | 14.3 | 24.0 | 0.61 | 0 | 47 | 50 |
| anyio | 453.0 | 1812.2 | 9.4 | 16.7 | 23.9 | 1.03 | 0 | 44 | 50 |
| asyncfiles-io_uring | 451.8 | 1807.1 | 6.7 | 14.6 | 34.0 | 0.43 | 0 | 47 | 50 |
| aiofiles | 437.6 | 1750.6 | 13.5 | 19.8 | 27.6 | 0.82 | 0 | 42 | 50 |
| aiofile | 394.7 | 1578.7 | 10.8 | 19.9 | 41.9 | 1.90 | 0 | 48 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 459.9 MB/s (1839.7 ops/s)
- **p95 Latency**: 14.3 ms
- **CPU Time**: 0.61 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **anyio**: 1.02x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.02x slower than asyncfiles-libuv
- **aiofiles**: 1.05x slower than asyncfiles-libuv
- **aiofile**: 1.17x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 601.2 | 1202.3 | 0.6 | 1.3 | 1.3 | 0.02 | 0 | 36 | 50 |
| asyncfiles-io_uring | 598.7 | 1197.5 | 0.5 | 1.4 | 1.4 | 0.01 | 0 | 36 | 50 |
| aiofile | 596.6 | 1193.1 | 0.7 | 1.1 | 1.3 | 0.07 | 0 | 39 | 50 |
| anyio | 570.8 | 1141.7 | 0.7 | 1.2 | 3.2 | 0.07 | 0 | 39 | 50 |
| aiofiles | 412.9 | 825.8 | 0.7 | 1.3 | 16.4 | 0.03 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 601.2 MB/s (1202.3 ops/s)
- **p95 Latency**: 1.3 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-io_uring**: about the same as asyncfiles-libuv
- **aiofile**: 1.01x slower than asyncfiles-libuv
- **anyio**: 1.05x slower than asyncfiles-libuv
- **aiofiles**: 1.46x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 529.3 | 1058.6 | 5.4 | 7.4 | 15.7 | 0.18 | 0 | 45 | 50 |
| asyncfiles-libuv | 505.6 | 1011.2 | 3.5 | 7.4 | 19.2 | 0.25 | 0 | 47 | 50 |
| aiofiles | 261.8 | 523.6 | 7.3 | 22.1 | 72.5 | 0.26 | 0 | 44 | 50 |
| anyio | 130.5 | 261.0 | 18.9 | 72.4 | 98.7 | 0.37 | 0 | 46 | 50 |
| aiofile | 104.0 | 208.1 | 20.7 | 76.0 | 112.2 | 2.25 | 0 | 48 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 529.3 MB/s (1058.6 ops/s)
- **p95 Latency**: 7.4 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.05x slower than asyncfiles-io_uring
- **aiofiles**: 2.02x slower than asyncfiles-io_uring
- **anyio**: 4.06x slower than asyncfiles-io_uring
- **aiofile**: 5.09x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 453.8 | 907.6 | 8.4 | 15.1 | 26.9 | 0.50 | 0 | 56 | 50 |
| aiofile | 438.9 | 877.8 | 12.3 | 21.2 | 25.3 | 1.49 | 0 | 55 | 50 |
| aiofiles | 438.5 | 877.1 | 10.7 | 15.3 | 25.4 | 0.55 | 0 | 50 | 50 |
| anyio | 415.9 | 831.7 | 11.4 | 28.8 | 38.6 | 0.64 | 0 | 51 | 50 |
| asyncfiles-io_uring | 412.7 | 825.3 | 10.7 | 20.7 | 42.0 | 0.36 | 0 | 56 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 453.8 MB/s (907.6 ops/s)
- **p95 Latency**: 15.1 ms
- **CPU Time**: 0.50 s
- **Peak Memory**: 56 MB

## Performance Comparison

- **aiofile**: 1.03x slower than asyncfiles-libuv
- **aiofiles**: 1.03x slower than asyncfiles-libuv
- **anyio**: 1.09x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.10x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 476.1 | 952.3 | 15.2 | 30.7 | 39.4 | 1.02 | 0 | 74 | 50 |
| aiofiles | 421.2 | 842.3 | 32.3 | 50.0 | 52.1 | 1.06 | 0 | 61 | 50 |
| anyio | 413.7 | 827.3 | 27.8 | 50.5 | 55.3 | 1.29 | 0 | 61 | 50 |
| asyncfiles-io_uring | 412.6 | 825.1 | 27.9 | 47.7 | 53.7 | 0.74 | 0 | 75 | 50 |
| aiofile | 410.6 | 821.2 | 26.4 | 46.6 | 52.2 | 3.11 | 0 | 71 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 476.1 MB/s (952.3 ops/s)
- **p95 Latency**: 30.7 ms
- **CPU Time**: 1.02 s
- **Peak Memory**: 74 MB

## Performance Comparison

- **aiofiles**: 1.13x slower than asyncfiles-libuv
- **anyio**: 1.15x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv
- **aiofile**: 1.16x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 455.2 | 455.2 | 1.9 | 3.8 | 20.5 | 0.14 | 0 | 49 | 50 |
| aiofiles | 433.8 | 433.8 | 1.8 | 2.0 | 32.2 | 0.03 | 0 | 49 | 50 |
| anyio | 412.3 | 412.3 | 1.8 | 8.0 | 24.7 | 0.09 | 0 | 50 | 50 |
| asyncfiles-io_uring | 245.2 | 245.2 | 1.9 | 18.1 | 55.1 | 0.02 | 0 | 43 | 50 |
| asyncfiles-libuv | 182.0 | 182.0 | 1.8 | 16.3 | 115.1 | 0.03 | 0 | 43 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 455.2 MB/s (455.2 ops/s)
- **p95 Latency**: 3.8 ms
- **CPU Time**: 0.14 s
- **Peak Memory**: 49 MB

## Performance Comparison

- **aiofiles**: 1.05x slower than aiofile
- **anyio**: 1.10x slower than aiofile
- **asyncfiles-io_uring**: 1.86x slower than aiofile
- **asyncfiles-libuv**: 2.50x slower than aiofile


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 482.7 | 482.7 | 9.0 | 15.4 | 95.5 | 0.42 | 0 | 63 | 50 |
| anyio | 435.3 | 435.3 | 11.7 | 15.2 | 41.5 | 0.41 | 0 | 62 | 50 |
| asyncfiles-io_uring | 420.6 | 420.6 | 11.6 | 17.4 | 54.1 | 0.31 | 0 | 63 | 50 |
| aiofile | 393.4 | 393.4 | 11.7 | 19.9 | 98.0 | 1.45 | 0 | 62 | 50 |
| aiofiles | 262.8 | 262.8 | 11.7 | 69.3 | 97.1 | 0.32 | 0 | 56 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 482.7 MB/s (482.7 ops/s)
- **p95 Latency**: 15.4 ms
- **CPU Time**: 0.42 s
- **Peak Memory**: 63 MB

## Performance Comparison

- **anyio**: 1.11x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv
- **aiofile**: 1.23x slower than asyncfiles-libuv
- **aiofiles**: 1.84x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 461.0 | 461.0 | 17.9 | 37.9 | 51.9 | 0.78 | 0 | 83 | 50 |
| anyio | 410.4 | 410.4 | 26.5 | 40.8 | 57.3 | 0.71 | 0 | 74 | 50 |
| aiofile | 409.8 | 409.8 | 25.7 | 41.1 | 80.5 | 2.71 | 0 | 84 | 50 |
| aiofiles | 406.9 | 406.9 | 30.8 | 49.0 | 55.2 | 0.66 | 0 | 75 | 50 |
| asyncfiles-io_uring | 404.0 | 404.0 | 33.0 | 52.9 | 55.5 | 0.61 | 0 | 83 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 461.0 MB/s (461.0 ops/s)
- **p95 Latency**: 37.9 ms
- **CPU Time**: 0.78 s
- **Peak Memory**: 83 MB

## Performance Comparison

- **anyio**: 1.12x slower than asyncfiles-libuv
- **aiofile**: 1.13x slower than asyncfiles-libuv
- **aiofiles**: 1.13x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.14x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 412.7 | 412.7 | 58.5 | 90.7 | 296.1 | 1.39 | 0 | 93 | 50 |
| anyio | 410.0 | 410.0 | 65.0 | 93.2 | 95.8 | 1.54 | 0 | 96 | 50 |
| aiofile | 400.0 | 400.0 | 55.9 | 87.6 | 130.2 | 5.61 | 0 | 114 | 50 |
| asyncfiles-libuv | 389.6 | 389.6 | 33.2 | 88.0 | 202.3 | 1.54 | 0 | 117 | 50 |
| asyncfiles-io_uring | 360.3 | 360.3 | 54.9 | 91.5 | 332.8 | 1.21 | 0 | 117 | 50 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 412.7 MB/s (412.7 ops/s)
- **p95 Latency**: 90.7 ms
- **CPU Time**: 1.39 s
- **Peak Memory**: 93 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofiles
- **aiofile**: 1.03x slower than aiofiles
- **asyncfiles-libuv**: 1.06x slower than aiofiles
- **asyncfiles-io_uring**: 1.15x slower than aiofiles
