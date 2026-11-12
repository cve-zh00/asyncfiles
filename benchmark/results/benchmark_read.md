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
- **Generated**: 2026-11-12 23:35 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| aiofile | 5 |
| asyncfiles-io_uring | 3 |
| anyio | 2 |
| aiofiles | 1 |
| asyncfiles-libuv | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 417.2 | 1668.9 | 0.5 | 0.6 | 1.6 | 0.02 | 0 | 20 | 50 |
| asyncfiles-libuv | 381.7 | 1526.8 | 0.6 | 0.7 | 1.1 | 0.02 | 0 | 20 | 50 |
| aiofiles | 292.8 | 1171.3 | 0.8 | 0.9 | 1.0 | 0.03 | 0 | 21 | 50 |
| anyio | 269.5 | 1077.9 | 0.9 | 1.1 | 1.1 | 0.09 | 0 | 23 | 50 |
| aiofile | 268.1 | 1072.6 | 0.9 | 1.0 | 1.1 | 0.12 | 0 | 22 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 417.2 MB/s (1668.9 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.09x slower than asyncfiles-io_uring
- **aiofiles**: 1.42x slower than asyncfiles-io_uring
- **anyio**: 1.55x slower than asyncfiles-io_uring
- **aiofile**: 1.56x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1256.7 | 5026.7 | 1.5 | 1.6 | 1.8 | 0.07 | 0 | 27 | 50 |
| asyncfiles-libuv | 1105.5 | 4422.1 | 1.3 | 1.7 | 1.9 | 0.18 | 0 | 26 | 50 |
| aiofile | 539.7 | 2158.8 | 2.9 | 3.5 | 8.2 | 0.47 | 2 | 30 | 50 |
| anyio | 468.6 | 1874.4 | 3.6 | 4.4 | 6.7 | 0.41 | 0 | 34 | 50 |
| aiofiles | 438.9 | 1755.6 | 2.8 | 3.6 | 29.1 | 0.29 | 0 | 29 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1256.7 MB/s (5026.7 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.07 s
- **Peak Memory**: 27 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.14x slower than asyncfiles-io_uring
- **aiofile**: 2.33x slower than asyncfiles-io_uring
- **anyio**: 2.68x slower than asyncfiles-io_uring
- **aiofiles**: 2.86x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 475.0 | 1899.9 | 5.1 | 20.8 | 36.4 | 0.53 | 0 | 39 | 50 |
| aiofile | 465.9 | 1863.6 | 5.0 | 16.6 | 31.5 | 0.93 | 0 | 39 | 50 |
| asyncfiles-libuv | 464.4 | 1857.6 | 2.0 | 30.2 | 31.5 | 0.26 | 0 | 39 | 50 |
| asyncfiles-io_uring | 461.5 | 1845.9 | 2.3 | 34.4 | 38.8 | 0.14 | 0 | 38 | 50 |
| anyio | 422.2 | 1688.9 | 6.3 | 13.7 | 30.6 | 0.71 | 1 | 42 | 50 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 475.0 MB/s (1899.9 ops/s)
- **p95 Latency**: 20.8 ms
- **CPU Time**: 0.53 s
- **Peak Memory**: 39 MB

## Performance Comparison

- **aiofile**: 1.02x slower than aiofiles
- **asyncfiles-libuv**: 1.02x slower than aiofiles
- **asyncfiles-io_uring**: 1.03x slower than aiofiles
- **anyio**: 1.12x slower than aiofiles


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 463.8 | 1855.4 | 9.3 | 28.6 | 41.7 | 1.73 | 1 | 52 | 50 |
| asyncfiles-libuv | 444.8 | 1779.3 | 3.6 | 34.8 | 46.5 | 0.51 | 0 | 51 | 50 |
| asyncfiles-io_uring | 444.3 | 1777.2 | 3.3 | 40.9 | 54.9 | 0.26 | 0 | 51 | 50 |
| anyio | 433.2 | 1732.6 | 11.7 | 28.2 | 44.5 | 1.26 | 0 | 58 | 50 |
| aiofiles | 417.6 | 1670.6 | 10.0 | 32.1 | 40.1 | 1.03 | 0 | 52 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 463.8 MB/s (1855.4 ops/s)
- **p95 Latency**: 28.6 ms
- **CPU Time**: 1.73 s
- **Peak Memory**: 52 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than aiofile
- **asyncfiles-io_uring**: 1.04x slower than aiofile
- **anyio**: 1.07x slower than aiofile
- **aiofiles**: 1.11x slower than aiofile


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 676.7 | 1353.4 | 0.6 | 0.7 | 2.6 | 0.02 | 0 | 50 | 50 |
| asyncfiles-libuv | 600.5 | 1200.9 | 0.8 | 0.8 | 1.6 | 0.03 | 0 | 50 | 50 |
| aiofiles | 502.6 | 1005.1 | 0.9 | 1.2 | 1.4 | 0.04 | 0 | 51 | 50 |
| anyio | 475.7 | 951.4 | 1.0 | 1.2 | 1.5 | 0.09 | 0 | 51 | 50 |
| aiofile | 441.0 | 881.9 | 1.1 | 1.2 | 2.0 | 0.15 | 0 | 51 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 676.7 MB/s (1353.4 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 50 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.13x slower than asyncfiles-io_uring
- **aiofiles**: 1.35x slower than asyncfiles-io_uring
- **anyio**: 1.42x slower than asyncfiles-io_uring
- **aiofile**: 1.53x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 904.4 | 1808.7 | 1.7 | 3.4 | 38.4 | 0.19 | 0 | 54 | 50 |
| aiofiles | 496.0 | 992.1 | 3.4 | 26.8 | 43.3 | 0.36 | 0 | 57 | 50 |
| asyncfiles-io_uring | 470.2 | 940.5 | 2.1 | 35.8 | 51.2 | 0.13 | 0 | 55 | 50 |
| aiofile | 468.1 | 936.2 | 3.4 | 26.9 | 40.3 | 0.76 | 0 | 57 | 50 |
| anyio | 451.7 | 903.3 | 3.8 | 26.1 | 28.1 | 0.49 | 0 | 59 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 904.4 MB/s (1808.7 ops/s)
- **p95 Latency**: 3.4 ms
- **CPU Time**: 0.19 s
- **Peak Memory**: 54 MB

## Performance Comparison

- **aiofiles**: 1.82x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.92x slower than asyncfiles-libuv
- **aiofile**: 1.93x slower than asyncfiles-libuv
- **anyio**: 2.00x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 458.0 | 916.0 | 6.4 | 35.8 | 43.4 | 1.45 | 0 | 64 | 50 |
| anyio | 449.3 | 898.6 | 7.0 | 35.8 | 50.3 | 0.82 | 0 | 65 | 50 |
| asyncfiles-io_uring | 438.7 | 877.3 | 2.9 | 42.5 | 51.6 | 0.23 | 0 | 63 | 50 |
| asyncfiles-libuv | 437.3 | 874.5 | 2.7 | 38.0 | 53.6 | 0.39 | 0 | 64 | 50 |
| aiofiles | 434.3 | 868.7 | 5.6 | 48.6 | 52.2 | 0.66 | 0 | 64 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 458.0 MB/s (916.0 ops/s)
- **p95 Latency**: 35.8 ms
- **CPU Time**: 1.45 s
- **Peak Memory**: 64 MB

## Performance Comparison

- **anyio**: 1.02x slower than aiofile
- **asyncfiles-io_uring**: 1.04x slower than aiofile
- **asyncfiles-libuv**: 1.05x slower than aiofile
- **aiofiles**: 1.05x slower than aiofile


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 437.9 | 875.9 | 13.3 | 56.5 | 58.9 | 1.54 | 0 | 90 | 50 |
| aiofile | 437.2 | 874.3 | 13.0 | 44.2 | 58.8 | 2.90 | 0 | 84 | 50 |
| aiofiles | 425.8 | 851.6 | 35.5 | 57.7 | 58.7 | 1.30 | 0 | 84 | 50 |
| asyncfiles-io_uring | 425.1 | 850.1 | 6.8 | 53.0 | 60.6 | 0.48 | 0 | 82 | 50 |
| asyncfiles-libuv | 420.3 | 840.6 | 5.3 | 53.0 | 57.2 | 0.77 | 0 | 82 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 437.9 MB/s (875.9 ops/s)
- **p95 Latency**: 56.5 ms
- **CPU Time**: 1.54 s
- **Peak Memory**: 90 MB

## Performance Comparison

- **aiofile**: about the same as anyio
- **aiofiles**: 1.03x slower than anyio
- **asyncfiles-io_uring**: 1.03x slower than anyio
- **asyncfiles-libuv**: 1.04x slower than anyio


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 567.2 | 567.2 | 1.4 | 2.0 | 17.2 | 0.12 | 0 | 75 | 50 |
| aiofile | 561.3 | 561.3 | 1.4 | 2.3 | 9.6 | 0.16 | 0 | 76 | 50 |
| aiofiles | 548.5 | 548.5 | 1.3 | 1.5 | 17.6 | 0.05 | 0 | 76 | 50 |
| asyncfiles-io_uring | 446.6 | 446.6 | 1.0 | 1.4 | 40.9 | 0.03 | 0 | 76 | 50 |
| asyncfiles-libuv | 356.3 | 356.3 | 1.2 | 18.7 | 44.9 | 0.04 | 0 | 76 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 567.2 MB/s (567.2 ops/s)
- **p95 Latency**: 2.0 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 75 MB

## Performance Comparison

- **aiofile**: 1.01x slower than anyio
- **aiofiles**: 1.03x slower than anyio
- **asyncfiles-io_uring**: 1.27x slower than anyio
- **asyncfiles-libuv**: 1.59x slower than anyio


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 460.2 | 460.2 | 4.7 | 37.3 | 52.7 | 1.28 | 0 | 86 | 50 |
| asyncfiles-io_uring | 446.8 | 446.8 | 2.9 | 41.3 | 57.3 | 0.22 | 0 | 83 | 50 |
| asyncfiles-libuv | 438.5 | 438.5 | 2.4 | 40.9 | 54.2 | 0.32 | 0 | 83 | 50 |
| anyio | 432.9 | 432.9 | 4.4 | 39.3 | 51.3 | 0.62 | 0 | 86 | 50 |
| aiofiles | 410.4 | 410.4 | 3.6 | 40.7 | 52.8 | 0.49 | 0 | 86 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 460.2 MB/s (460.2 ops/s)
- **p95 Latency**: 37.3 ms
- **CPU Time**: 1.28 s
- **Peak Memory**: 86 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.03x slower than aiofile
- **asyncfiles-libuv**: 1.05x slower than aiofile
- **anyio**: 1.06x slower than aiofile
- **aiofiles**: 1.12x slower than aiofile


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 445.6 | 445.6 | 9.2 | 44.5 | 59.9 | 2.53 | 0 | 97 | 50 |
| asyncfiles-libuv | 429.0 | 429.0 | 4.6 | 55.5 | 60.3 | 0.63 | 0 | 94 | 50 |
| aiofiles | 426.8 | 426.8 | 36.8 | 54.9 | 59.8 | 0.91 | 0 | 97 | 50 |
| asyncfiles-io_uring | 425.2 | 425.2 | 6.2 | 56.4 | 61.4 | 0.45 | 0 | 94 | 50 |
| anyio | 422.5 | 422.5 | 8.3 | 53.8 | 59.2 | 1.10 | 0 | 99 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 445.6 MB/s (445.6 ops/s)
- **p95 Latency**: 44.5 ms
- **CPU Time**: 2.53 s
- **Peak Memory**: 97 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than aiofile
- **aiofiles**: 1.04x slower than aiofile
- **asyncfiles-io_uring**: 1.05x slower than aiofile
- **anyio**: 1.05x slower than aiofile


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 429.2 | 429.2 | 40.8 | 87.9 | 103.3 | 5.13 | 0 | 134 | 50 |
| anyio | 425.0 | 425.0 | 43.7 | 102.4 | 105.0 | 2.07 | 0 | 148 | 50 |
| aiofiles | 424.0 | 424.0 | 45.4 | 101.1 | 103.7 | 1.77 | 0 | 134 | 50 |
| asyncfiles-libuv | 419.4 | 419.4 | 41.7 | 88.0 | 102.6 | 1.29 | 0 | 132 | 50 |
| asyncfiles-io_uring | 417.0 | 417.0 | 43.7 | 89.6 | 105.3 | 0.92 | 0 | 131 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 429.2 MB/s (429.2 ops/s)
- **p95 Latency**: 87.9 ms
- **CPU Time**: 5.13 s
- **Peak Memory**: 134 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofile
- **aiofiles**: 1.01x slower than aiofile
- **asyncfiles-libuv**: 1.02x slower than aiofile
- **asyncfiles-io_uring**: 1.03x slower than aiofile
