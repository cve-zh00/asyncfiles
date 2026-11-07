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
- **Generated**: 2026-11-07 20:31 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| aiofile | 5 |
| asyncfiles-io_uring | 4 |
| anyio | 2 |
| asyncfiles-libuv | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 365.7 | 1462.9 | 0.5 | 0.6 | 4.7 | 0.02 | 0 | 20 | 50 |
| asyncfiles-libuv | 338.7 | 1354.6 | 0.7 | 0.9 | 0.9 | 0.02 | 0 | 20 | 50 |
| aiofiles | 296.1 | 1184.4 | 0.8 | 0.9 | 1.0 | 0.03 | 0 | 21 | 50 |
| anyio | 254.7 | 1018.7 | 0.9 | 1.1 | 2.1 | 0.08 | 0 | 23 | 50 |
| aiofile | 220.9 | 883.8 | 1.0 | 1.2 | 4.5 | 0.16 | 0 | 21 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 365.7 MB/s (1462.9 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.08x slower than asyncfiles-io_uring
- **aiofiles**: 1.24x slower than asyncfiles-io_uring
- **anyio**: 1.44x slower than asyncfiles-io_uring
- **aiofile**: 1.66x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 805.8 | 3223.3 | 2.0 | 2.5 | 2.9 | 0.13 | 0 | 24 | 50 |
| asyncfiles-libuv | 769.9 | 3079.6 | 1.7 | 2.7 | 3.0 | 0.21 | 0 | 26 | 50 |
| aiofiles | 562.6 | 2250.6 | 2.9 | 3.5 | 7.1 | 0.30 | 0 | 28 | 50 |
| aiofile | 465.7 | 1862.9 | 3.4 | 4.4 | 7.9 | 0.55 | 2 | 28 | 50 |
| anyio | 454.0 | 1816.0 | 3.7 | 5.6 | 6.1 | 0.41 | 0 | 30 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 805.8 MB/s (3223.3 ops/s)
- **p95 Latency**: 2.5 ms
- **CPU Time**: 0.13 s
- **Peak Memory**: 24 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.05x slower than asyncfiles-io_uring
- **aiofiles**: 1.43x slower than asyncfiles-io_uring
- **aiofile**: 1.73x slower than asyncfiles-io_uring
- **anyio**: 1.77x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 473.3 | 1893.4 | 3.6 | 28.1 | 42.3 | 0.24 | 0 | 37 | 50 |
| aiofile | 460.5 | 1841.9 | 6.0 | 11.5 | 27.3 | 0.99 | 2 | 34 | 50 |
| asyncfiles-libuv | 458.3 | 1833.2 | 2.5 | 25.3 | 41.4 | 0.40 | 0 | 36 | 50 |
| anyio | 449.0 | 1795.8 | 7.2 | 9.7 | 23.8 | 0.75 | 0 | 34 | 50 |
| aiofiles | 431.3 | 1725.3 | 5.2 | 20.6 | 33.5 | 0.57 | 0 | 33 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 473.3 MB/s (1893.4 ops/s)
- **p95 Latency**: 28.1 ms
- **CPU Time**: 0.24 s
- **Peak Memory**: 37 MB

## Performance Comparison

- **aiofile**: 1.03x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.03x slower than asyncfiles-io_uring
- **anyio**: 1.05x slower than asyncfiles-io_uring
- **aiofiles**: 1.10x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 456.8 | 1827.3 | 11.7 | 27.5 | 31.7 | 1.92 | 2 | 45 | 50 |
| asyncfiles-io_uring | 440.6 | 1762.5 | 7.0 | 34.9 | 50.7 | 0.48 | 0 | 47 | 50 |
| asyncfiles-libuv | 440.4 | 1761.5 | 4.7 | 33.0 | 43.9 | 0.79 | 0 | 46 | 50 |
| anyio | 428.8 | 1715.2 | 11.8 | 28.4 | 37.2 | 1.29 | 1 | 43 | 50 |
| aiofiles | 424.4 | 1697.7 | 10.5 | 37.9 | 46.1 | 1.09 | 0 | 41 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 456.8 MB/s (1827.3 ops/s)
- **p95 Latency**: 27.5 ms
- **CPU Time**: 1.92 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.04x slower than aiofile
- **asyncfiles-libuv**: 1.04x slower than aiofile
- **anyio**: 1.07x slower than aiofile
- **aiofiles**: 1.08x slower than aiofile


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 633.5 | 1267.1 | 0.7 | 1.0 | 1.3 | 0.02 | 0 | 35 | 50 |
| asyncfiles-libuv | 460.8 | 921.6 | 1.0 | 1.3 | 3.2 | 0.03 | 0 | 36 | 50 |
| aiofiles | 431.2 | 862.4 | 1.1 | 1.4 | 1.6 | 0.04 | 0 | 39 | 50 |
| anyio | 429.9 | 859.8 | 1.1 | 1.3 | 1.4 | 0.10 | 0 | 39 | 50 |
| aiofile | 389.9 | 779.7 | 1.2 | 1.7 | 2.3 | 0.15 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 633.5 MB/s (1267.1 ops/s)
- **p95 Latency**: 1.0 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 35 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.37x slower than asyncfiles-io_uring
- **aiofiles**: 1.47x slower than asyncfiles-io_uring
- **anyio**: 1.47x slower than asyncfiles-io_uring
- **aiofile**: 1.63x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 920.6 | 1841.1 | 2.2 | 3.6 | 28.4 | 0.32 | 0 | 44 | 50 |
| aiofile | 479.6 | 959.2 | 4.1 | 21.7 | 38.7 | 0.84 | 0 | 48 | 50 |
| anyio | 459.4 | 918.8 | 3.9 | 25.7 | 42.6 | 0.48 | 0 | 47 | 50 |
| aiofiles | 443.5 | 886.9 | 3.2 | 29.4 | 44.8 | 0.37 | 0 | 45 | 50 |
| asyncfiles-io_uring | 423.7 | 847.5 | 3.6 | 26.6 | 42.6 | 0.23 | 0 | 46 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 920.6 MB/s (1841.1 ops/s)
- **p95 Latency**: 3.6 ms
- **CPU Time**: 0.32 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **aiofile**: 1.92x slower than asyncfiles-libuv
- **anyio**: 2.00x slower than asyncfiles-libuv
- **aiofiles**: 2.08x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 2.17x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 451.1 | 902.2 | 6.9 | 39.5 | 45.6 | 0.83 | 0 | 51 | 50 |
| aiofile | 450.6 | 901.2 | 7.4 | 33.2 | 39.4 | 1.61 | 0 | 57 | 50 |
| aiofiles | 430.8 | 861.6 | 6.0 | 36.7 | 47.6 | 0.73 | 0 | 52 | 50 |
| asyncfiles-io_uring | 430.5 | 861.0 | 6.7 | 40.7 | 46.1 | 0.45 | 0 | 59 | 50 |
| asyncfiles-libuv | 425.2 | 850.4 | 3.8 | 36.4 | 49.6 | 0.65 | 0 | 59 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 451.1 MB/s (902.2 ops/s)
- **p95 Latency**: 39.5 ms
- **CPU Time**: 0.83 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **aiofile**: about the same as anyio
- **aiofiles**: 1.05x slower than anyio
- **asyncfiles-io_uring**: 1.05x slower than anyio
- **asyncfiles-libuv**: 1.06x slower than anyio


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 436.3 | 872.7 | 15.8 | 43.8 | 58.9 | 3.23 | 0 | 72 | 50 |
| anyio | 433.9 | 867.9 | 13.6 | 56.7 | 59.1 | 1.65 | 0 | 62 | 50 |
| aiofiles | 425.4 | 850.8 | 34.7 | 57.9 | 58.4 | 1.40 | 0 | 61 | 50 |
| asyncfiles-io_uring | 423.7 | 847.5 | 13.4 | 57.6 | 58.2 | 0.89 | 0 | 73 | 50 |
| asyncfiles-libuv | 419.6 | 839.2 | 7.9 | 50.0 | 55.7 | 1.28 | 0 | 73 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 436.3 MB/s (872.7 ops/s)
- **p95 Latency**: 43.8 ms
- **CPU Time**: 3.23 s
- **Peak Memory**: 72 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofile
- **aiofiles**: 1.03x slower than aiofile
- **asyncfiles-io_uring**: 1.03x slower than aiofile
- **asyncfiles-libuv**: 1.04x slower than aiofile


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 681.0 | 681.0 | 1.4 | 1.6 | 3.2 | 0.10 | 0 | 52 | 50 |
| aiofile | 644.3 | 644.3 | 1.5 | 1.7 | 1.8 | 0.15 | 0 | 52 | 50 |
| asyncfiles-io_uring | 640.2 | 640.2 | 1.0 | 1.3 | 23.5 | 0.04 | 0 | 47 | 50 |
| aiofiles | 414.6 | 414.6 | 1.4 | 13.8 | 18.5 | 0.06 | 0 | 52 | 50 |
| asyncfiles-libuv | 407.3 | 407.3 | 1.2 | 18.6 | 23.4 | 0.05 | 0 | 47 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 681.0 MB/s (681.0 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.10 s
- **Peak Memory**: 52 MB

## Performance Comparison

- **aiofile**: 1.06x slower than anyio
- **asyncfiles-io_uring**: 1.06x slower than anyio
- **aiofiles**: 1.64x slower than anyio
- **asyncfiles-libuv**: 1.67x slower than anyio


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 444.5 | 444.5 | 6.1 | 43.1 | 51.1 | 1.48 | 0 | 69 | 50 |
| aiofiles | 438.4 | 438.4 | 3.8 | 39.3 | 53.9 | 0.51 | 0 | 61 | 50 |
| anyio | 435.0 | 435.0 | 4.4 | 42.5 | 54.0 | 0.63 | 0 | 64 | 50 |
| asyncfiles-io_uring | 424.2 | 424.2 | 6.6 | 34.9 | 51.9 | 0.44 | 0 | 65 | 50 |
| asyncfiles-libuv | 420.6 | 420.6 | 3.9 | 44.0 | 48.3 | 0.58 | 0 | 66 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 444.5 MB/s (444.5 ops/s)
- **p95 Latency**: 43.1 ms
- **CPU Time**: 1.48 s
- **Peak Memory**: 69 MB

## Performance Comparison

- **aiofiles**: 1.01x slower than aiofile
- **anyio**: 1.02x slower than aiofile
- **asyncfiles-io_uring**: 1.05x slower than aiofile
- **asyncfiles-libuv**: 1.06x slower than aiofile


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 441.8 | 441.8 | 13.4 | 44.9 | 58.6 | 2.89 | 0 | 82 | 50 |
| asyncfiles-libuv | 432.6 | 432.6 | 7.0 | 54.1 | 57.6 | 1.16 | 0 | 83 | 50 |
| anyio | 422.1 | 422.1 | 8.5 | 51.1 | 59.6 | 1.14 | 0 | 71 | 50 |
| asyncfiles-io_uring | 420.7 | 420.7 | 13.1 | 56.2 | 58.4 | 0.86 | 0 | 84 | 50 |
| aiofiles | 419.1 | 419.1 | 33.3 | 52.9 | 59.4 | 1.06 | 0 | 72 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 441.8 MB/s (441.8 ops/s)
- **p95 Latency**: 44.9 ms
- **CPU Time**: 2.89 s
- **Peak Memory**: 82 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than aiofile
- **anyio**: 1.05x slower than aiofile
- **asyncfiles-io_uring**: 1.05x slower than aiofile
- **aiofiles**: 1.05x slower than aiofile


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 430.4 | 430.4 | 38.5 | 88.8 | 101.2 | 5.81 | 0 | 117 | 50 |
| anyio | 425.2 | 425.2 | 43.0 | 88.3 | 104.4 | 2.19 | 0 | 100 | 50 |
| asyncfiles-io_uring | 424.2 | 424.2 | 43.9 | 85.8 | 100.7 | 1.70 | 0 | 116 | 50 |
| asyncfiles-libuv | 419.2 | 419.2 | 39.3 | 94.9 | 99.7 | 2.29 | 0 | 116 | 50 |
| aiofiles | 417.8 | 417.8 | 45.1 | 102.6 | 103.4 | 2.03 | 0 | 97 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 430.4 MB/s (430.4 ops/s)
- **p95 Latency**: 88.8 ms
- **CPU Time**: 5.81 s
- **Peak Memory**: 117 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofile
- **asyncfiles-io_uring**: 1.01x slower than aiofile
- **asyncfiles-libuv**: 1.03x slower than aiofile
- **aiofiles**: 1.03x slower than aiofile
