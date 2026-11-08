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
- **Generated**: 2026-11-08 00:29 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 6 |
| asyncfiles-io_uring | 5 |
| aiofile | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 648.3 | 2593.2 | 0.3 | 0.4 | 1.5 | 0.01 | 0 | 20 | 50 |
| aiofiles | 497.8 | 1991.2 | 0.5 | 0.6 | 1.1 | 0.02 | 0 | 20 | 50 |
| anyio | 441.8 | 1767.0 | 0.5 | 1.3 | 1.9 | 0.05 | 0 | 23 | 50 |
| aiofile | 407.3 | 1629.3 | 0.5 | 1.5 | 1.6 | 0.09 | 0 | 21 | 50 |
| asyncfiles-libuv | 289.7 | 1158.9 | 0.7 | 1.8 | 2.0 | 0.02 | 0 | 20 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 648.3 MB/s (2593.2 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **aiofiles**: 1.30x slower than asyncfiles-io_uring
- **anyio**: 1.47x slower than asyncfiles-io_uring
- **aiofile**: 1.59x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.24x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 686.0 | 2743.9 | 1.9 | 4.2 | 5.7 | 0.36 | 0 | 29 | 50 |
| anyio | 611.5 | 2446.0 | 1.9 | 5.2 | 6.7 | 0.27 | 0 | 30 | 50 |
| asyncfiles-io_uring | 611.2 | 2445.0 | 1.2 | 6.5 | 7.3 | 0.09 | 0 | 26 | 50 |
| aiofiles | 608.6 | 2434.6 | 1.5 | 5.7 | 6.9 | 0.17 | 0 | 28 | 50 |
| asyncfiles-libuv | 597.7 | 2390.7 | 1.0 | 6.0 | 7.0 | 0.12 | 0 | 25 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 686.0 MB/s (2743.9 ops/s)
- **p95 Latency**: 4.2 ms
- **CPU Time**: 0.36 s
- **Peak Memory**: 29 MB

## Performance Comparison

- **anyio**: 1.12x slower than aiofile
- **asyncfiles-io_uring**: 1.12x slower than aiofile
- **aiofiles**: 1.13x slower than aiofile
- **asyncfiles-libuv**: 1.15x slower than aiofile


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 596.1 | 2384.5 | 2.3 | 8.6 | 8.8 | 0.16 | 0 | 35 | 50 |
| asyncfiles-libuv | 591.2 | 2364.8 | 1.8 | 8.2 | 8.6 | 0.25 | 0 | 35 | 50 |
| aiofiles | 493.9 | 1975.4 | 3.0 | 8.9 | 22.6 | 0.34 | 0 | 33 | 50 |
| aiofile | 480.2 | 1920.9 | 3.6 | 17.4 | 36.1 | 0.80 | 0 | 35 | 50 |
| anyio | 450.5 | 1801.9 | 3.6 | 19.6 | 36.7 | 0.47 | 0 | 35 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 596.1 MB/s (2384.5 ops/s)
- **p95 Latency**: 8.6 ms
- **CPU Time**: 0.16 s
- **Peak Memory**: 35 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **aiofiles**: 1.21x slower than asyncfiles-io_uring
- **aiofile**: 1.24x slower than asyncfiles-io_uring
- **anyio**: 1.32x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 581.8 | 2327.1 | 6.8 | 15.8 | 17.8 | 0.51 | 0 | 47 | 50 |
| aiofile | 455.0 | 1820.0 | 7.4 | 29.1 | 35.4 | 1.64 | 0 | 46 | 50 |
| anyio | 443.9 | 1775.4 | 8.0 | 30.0 | 43.4 | 0.84 | 0 | 44 | 50 |
| aiofiles | 437.7 | 1750.7 | 10.8 | 32.3 | 48.3 | 0.70 | 0 | 41 | 50 |
| asyncfiles-io_uring | 423.6 | 1694.5 | 8.0 | 33.9 | 43.5 | 0.37 | 0 | 47 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 581.8 MB/s (2327.1 ops/s)
- **p95 Latency**: 15.8 ms
- **CPU Time**: 0.51 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **aiofile**: 1.28x slower than asyncfiles-libuv
- **anyio**: 1.31x slower than asyncfiles-libuv
- **aiofiles**: 1.33x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.37x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 592.9 | 1185.9 | 0.6 | 2.9 | 3.0 | 0.01 | 0 | 35 | 50 |
| anyio | 589.8 | 1179.5 | 0.8 | 1.3 | 1.8 | 0.06 | 0 | 38 | 50 |
| aiofile | 589.1 | 1178.2 | 0.8 | 0.9 | 1.3 | 0.06 | 0 | 38 | 50 |
| aiofiles | 582.6 | 1165.2 | 0.8 | 1.5 | 2.3 | 0.02 | 0 | 36 | 50 |
| asyncfiles-libuv | 578.3 | 1156.6 | 0.7 | 1.9 | 2.2 | 0.02 | 0 | 35 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 592.9 MB/s (1185.9 ops/s)
- **p95 Latency**: 2.9 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 35 MB

## Performance Comparison

- **anyio**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.01x slower than asyncfiles-io_uring
- **aiofiles**: 1.02x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.03x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 592.2 | 1184.4 | 7.5 | 8.7 | 8.9 | 0.15 | 0 | 46 | 50 |
| asyncfiles-libuv | 582.7 | 1165.3 | 2.4 | 8.7 | 9.0 | 0.20 | 0 | 45 | 50 |
| aiofiles | 421.8 | 843.5 | 5.6 | 24.3 | 39.7 | 0.20 | 0 | 42 | 50 |
| anyio | 416.0 | 832.1 | 5.9 | 23.0 | 37.6 | 0.31 | 0 | 44 | 50 |
| aiofile | 415.6 | 831.3 | 3.3 | 21.1 | 32.8 | 0.72 | 0 | 45 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 592.2 MB/s (1184.4 ops/s)
- **p95 Latency**: 8.7 ms
- **CPU Time**: 0.15 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 1.40x slower than asyncfiles-io_uring
- **anyio**: 1.42x slower than asyncfiles-io_uring
- **aiofile**: 1.42x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 573.8 | 1147.6 | 8.1 | 17.0 | 17.9 | 0.40 | 0 | 55 | 50 |
| aiofiles | 424.7 | 849.3 | 9.3 | 37.2 | 46.8 | 0.44 | 0 | 52 | 50 |
| aiofile | 423.2 | 846.5 | 8.5 | 34.0 | 49.4 | 1.41 | 0 | 57 | 50 |
| anyio | 421.3 | 842.6 | 9.6 | 35.5 | 43.0 | 0.52 | 0 | 51 | 50 |
| asyncfiles-io_uring | 412.7 | 825.4 | 9.5 | 34.5 | 45.1 | 0.32 | 0 | 56 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 573.8 MB/s (1147.6 ops/s)
- **p95 Latency**: 17.0 ms
- **CPU Time**: 0.40 s
- **Peak Memory**: 55 MB

## Performance Comparison

- **aiofiles**: 1.35x slower than asyncfiles-libuv
- **aiofile**: 1.36x slower than asyncfiles-libuv
- **anyio**: 1.36x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.39x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 473.3 | 946.6 | 16.3 | 41.4 | 55.0 | 0.78 | 0 | 74 | 50 |
| aiofiles | 419.9 | 839.9 | 30.2 | 57.4 | 59.8 | 0.82 | 0 | 62 | 50 |
| aiofile | 414.6 | 829.1 | 25.5 | 47.8 | 59.0 | 2.88 | 0 | 71 | 50 |
| anyio | 413.7 | 827.3 | 27.9 | 49.3 | 59.1 | 1.02 | 0 | 61 | 50 |
| asyncfiles-io_uring | 410.2 | 820.5 | 29.8 | 47.9 | 59.4 | 0.65 | 0 | 74 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 473.3 MB/s (946.6 ops/s)
- **p95 Latency**: 41.4 ms
- **CPU Time**: 0.78 s
- **Peak Memory**: 74 MB

## Performance Comparison

- **aiofiles**: 1.13x slower than asyncfiles-libuv
- **aiofile**: 1.14x slower than asyncfiles-libuv
- **anyio**: 1.14x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 596.7 | 596.7 | 1.0 | 5.5 | 5.7 | 0.01 | 0 | 46 | 50 |
| anyio | 594.1 | 594.1 | 1.1 | 4.8 | 5.3 | 0.11 | 0 | 53 | 50 |
| aiofile | 591.6 | 591.6 | 1.1 | 5.0 | 5.1 | 0.10 | 0 | 53 | 50 |
| asyncfiles-libuv | 589.4 | 589.4 | 1.0 | 5.2 | 5.4 | 0.02 | 0 | 46 | 50 |
| aiofiles | 584.8 | 584.8 | 1.1 | 4.9 | 8.4 | 0.02 | 0 | 53 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 596.7 MB/s (596.7 ops/s)
- **p95 Latency**: 5.5 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **anyio**: about the same as asyncfiles-io_uring
- **aiofile**: 1.01x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **aiofiles**: 1.02x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 565.6 | 565.6 | 9.0 | 18.3 | 18.7 | 0.32 | 0 | 67 | 50 |
| aiofile | 420.3 | 420.3 | 9.6 | 38.3 | 41.9 | 1.28 | 0 | 67 | 50 |
| anyio | 419.9 | 419.9 | 10.4 | 38.9 | 46.7 | 0.33 | 0 | 61 | 50 |
| aiofiles | 414.7 | 414.7 | 11.0 | 39.8 | 50.6 | 0.25 | 0 | 59 | 50 |
| asyncfiles-io_uring | 410.0 | 410.0 | 11.1 | 33.8 | 46.4 | 0.27 | 0 | 67 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 565.6 MB/s (565.6 ops/s)
- **p95 Latency**: 18.3 ms
- **CPU Time**: 0.32 s
- **Peak Memory**: 67 MB

## Performance Comparison

- **aiofile**: 1.35x slower than asyncfiles-libuv
- **anyio**: 1.35x slower than asyncfiles-libuv
- **aiofiles**: 1.36x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.38x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 465.2 | 465.2 | 17.6 | 43.6 | 56.4 | 0.65 | 0 | 84 | 50 |
| anyio | 412.1 | 412.1 | 29.5 | 54.7 | 61.3 | 0.61 | 0 | 77 | 50 |
| aiofiles | 409.7 | 409.7 | 29.1 | 57.5 | 58.5 | 0.52 | 0 | 75 | 50 |
| aiofile | 409.1 | 409.1 | 27.6 | 48.7 | 58.7 | 2.60 | 0 | 89 | 50 |
| asyncfiles-io_uring | 403.0 | 403.0 | 37.7 | 48.5 | 58.4 | 0.53 | 0 | 84 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 465.2 MB/s (465.2 ops/s)
- **p95 Latency**: 43.6 ms
- **CPU Time**: 0.65 s
- **Peak Memory**: 84 MB

## Performance Comparison

- **anyio**: 1.13x slower than asyncfiles-libuv
- **aiofiles**: 1.14x slower than asyncfiles-libuv
- **aiofile**: 1.14x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 430.3 | 430.3 | 36.0 | 79.1 | 95.0 | 1.30 | 0 | 118 | 50 |
| anyio | 408.4 | 408.4 | 60.0 | 95.4 | 105.5 | 1.37 | 0 | 92 | 50 |
| aiofiles | 406.7 | 406.7 | 67.7 | 89.8 | 99.5 | 1.27 | 0 | 94 | 50 |
| asyncfiles-io_uring | 404.4 | 404.4 | 65.7 | 93.5 | 102.4 | 1.05 | 0 | 119 | 50 |
| aiofile | 402.7 | 402.7 | 64.4 | 94.8 | 105.5 | 5.24 | 0 | 112 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 430.3 MB/s (430.3 ops/s)
- **p95 Latency**: 79.1 ms
- **CPU Time**: 1.30 s
- **Peak Memory**: 118 MB

## Performance Comparison

- **anyio**: 1.05x slower than asyncfiles-libuv
- **aiofiles**: 1.06x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.06x slower than asyncfiles-libuv
- **aiofile**: 1.07x slower than asyncfiles-libuv
