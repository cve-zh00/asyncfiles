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
- **Generated**: 2026-11-08 16:02 UTC

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
| aiofile | 392.7 | 1570.7 | 0.6 | 0.7 | 1.1 | 0.08 | 0 | 21 | 50 |
| asyncfiles-io_uring | 265.2 | 1060.9 | 0.9 | 1.0 | 1.0 | 0.01 | 0 | 20 | 50 |
| anyio | 237.1 | 948.6 | 0.8 | 1.8 | 5.7 | 0.06 | 0 | 23 | 50 |
| asyncfiles-libuv | 223.8 | 895.0 | 1.1 | 1.2 | 1.4 | 0.02 | 0 | 21 | 50 |
| aiofiles | 188.9 | 755.7 | 1.1 | 1.3 | 21.6 | 0.02 | 0 | 21 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 392.7 MB/s (1570.7 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.08 s
- **Peak Memory**: 21 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.48x slower than aiofile
- **anyio**: 1.66x slower than aiofile
- **asyncfiles-libuv**: 1.75x slower than aiofile
- **aiofiles**: 2.08x slower than aiofile


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 467.8 | 1871.4 | 2.4 | 4.0 | 8.2 | 0.08 | 0 | 26 | 50 |
| asyncfiles-libuv | 431.7 | 1726.7 | 2.5 | 5.0 | 11.6 | 0.13 | 0 | 25 | 50 |
| aiofiles | 418.4 | 1673.4 | 2.9 | 4.7 | 9.8 | 0.19 | 0 | 25 | 50 |
| anyio | 401.5 | 1605.9 | 3.3 | 5.3 | 10.5 | 0.29 | 0 | 31 | 50 |
| aiofile | 381.2 | 1524.7 | 3.1 | 6.4 | 10.7 | 0.47 | 0 | 29 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 467.8 MB/s (1871.4 ops/s)
- **p95 Latency**: 4.0 ms
- **CPU Time**: 0.08 s
- **Peak Memory**: 26 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.08x slower than asyncfiles-io_uring
- **aiofiles**: 1.12x slower than asyncfiles-io_uring
- **anyio**: 1.17x slower than asyncfiles-io_uring
- **aiofile**: 1.23x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 466.1 | 1864.3 | 4.5 | 9.9 | 16.3 | 0.16 | 0 | 36 | 50 |
| asyncfiles-libuv | 442.4 | 1769.6 | 4.6 | 8.9 | 15.9 | 0.26 | 0 | 37 | 50 |
| aiofiles | 405.3 | 1621.4 | 6.3 | 11.5 | 15.9 | 0.36 | 0 | 34 | 50 |
| anyio | 399.7 | 1598.9 | 6.1 | 10.0 | 16.2 | 0.50 | 0 | 35 | 50 |
| aiofile | 394.8 | 1579.1 | 5.9 | 9.5 | 24.2 | 0.88 | 0 | 36 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 466.1 MB/s (1864.3 ops/s)
- **p95 Latency**: 9.9 ms
- **CPU Time**: 0.16 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.05x slower than asyncfiles-io_uring
- **aiofiles**: 1.15x slower than asyncfiles-io_uring
- **anyio**: 1.17x slower than asyncfiles-io_uring
- **aiofile**: 1.18x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 463.3 | 1853.4 | 8.5 | 15.8 | 28.0 | 0.55 | 0 | 39 | 50 |
| asyncfiles-io_uring | 436.0 | 1744.2 | 8.8 | 24.2 | 35.5 | 0.33 | 0 | 47 | 50 |
| anyio | 408.0 | 1632.2 | 11.4 | 21.1 | 30.5 | 0.89 | 0 | 43 | 50 |
| aiofile | 406.5 | 1625.9 | 11.0 | 21.5 | 34.4 | 1.70 | 0 | 46 | 50 |
| aiofiles | 393.1 | 1572.6 | 15.4 | 26.7 | 33.2 | 0.69 | 0 | 41 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 463.3 MB/s (1853.4 ops/s)
- **p95 Latency**: 15.8 ms
- **CPU Time**: 0.55 s
- **Peak Memory**: 39 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.06x slower than asyncfiles-libuv
- **anyio**: 1.14x slower than asyncfiles-libuv
- **aiofile**: 1.14x slower than asyncfiles-libuv
- **aiofiles**: 1.18x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 530.4 | 1060.8 | 0.9 | 1.1 | 1.1 | 0.01 | 0 | 35 | 50 |
| anyio | 398.1 | 796.3 | 1.2 | 1.4 | 1.6 | 0.09 | 0 | 39 | 50 |
| aiofiles | 381.3 | 762.7 | 1.3 | 1.4 | 1.5 | 0.03 | 0 | 38 | 50 |
| aiofile | 300.4 | 600.7 | 1.4 | 3.2 | 6.3 | 0.11 | 0 | 38 | 50 |
| asyncfiles-libuv | 259.7 | 519.4 | 2.0 | 3.2 | 6.4 | 0.02 | 0 | 35 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 530.4 MB/s (1060.8 ops/s)
- **p95 Latency**: 1.1 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 35 MB

## Performance Comparison

- **anyio**: 1.33x slower than asyncfiles-io_uring
- **aiofiles**: 1.39x slower than asyncfiles-io_uring
- **aiofile**: 1.77x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.04x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 495.2 | 990.4 | 6.0 | 7.8 | 15.8 | 0.14 | 0 | 45 | 50 |
| asyncfiles-libuv | 486.3 | 972.6 | 6.0 | 8.0 | 16.0 | 0.22 | 0 | 45 | 50 |
| aiofiles | 458.8 | 917.6 | 6.6 | 10.3 | 17.8 | 0.23 | 0 | 42 | 50 |
| aiofile | 408.4 | 816.8 | 7.1 | 14.0 | 19.1 | 0.73 | 0 | 46 | 50 |
| anyio | 402.9 | 805.9 | 7.0 | 14.5 | 31.3 | 0.34 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 495.2 MB/s (990.4 ops/s)
- **p95 Latency**: 7.8 ms
- **CPU Time**: 0.14 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 1.08x slower than asyncfiles-io_uring
- **aiofile**: 1.21x slower than asyncfiles-io_uring
- **anyio**: 1.23x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 478.2 | 956.3 | 9.9 | 16.1 | 28.7 | 0.41 | 0 | 54 | 50 |
| asyncfiles-io_uring | 416.0 | 832.0 | 12.8 | 29.8 | 37.0 | 0.27 | 0 | 54 | 50 |
| anyio | 403.7 | 807.5 | 14.2 | 29.4 | 37.3 | 0.55 | 0 | 48 | 50 |
| aiofile | 397.7 | 795.4 | 13.8 | 31.8 | 36.5 | 1.44 | 0 | 55 | 50 |
| aiofiles | 393.6 | 787.2 | 14.1 | 33.2 | 39.3 | 0.45 | 0 | 50 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 478.2 MB/s (956.3 ops/s)
- **p95 Latency**: 16.1 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 54 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv
- **anyio**: 1.18x slower than asyncfiles-libuv
- **aiofile**: 1.20x slower than asyncfiles-libuv
- **aiofiles**: 1.21x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 446.3 | 892.7 | 18.5 | 39.5 | 49.4 | 0.81 | 0 | 71 | 50 |
| asyncfiles-io_uring | 412.3 | 824.6 | 29.4 | 46.3 | 54.3 | 0.54 | 0 | 71 | 50 |
| anyio | 406.6 | 813.2 | 29.8 | 41.2 | 55.0 | 1.09 | 0 | 60 | 50 |
| aiofile | 403.5 | 807.0 | 28.8 | 45.8 | 52.7 | 2.90 | 0 | 70 | 50 |
| aiofiles | 400.0 | 800.0 | 34.6 | 52.0 | 54.5 | 0.86 | 0 | 60 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 446.3 MB/s (892.7 ops/s)
- **p95 Latency**: 39.5 ms
- **CPU Time**: 0.81 s
- **Peak Memory**: 71 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.08x slower than asyncfiles-libuv
- **anyio**: 1.10x slower than asyncfiles-libuv
- **aiofile**: 1.11x slower than asyncfiles-libuv
- **aiofiles**: 1.12x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 501.2 | 501.2 | 2.0 | 2.1 | 2.1 | 0.02 | 0 | 45 | 50 |
| anyio | 474.4 | 474.4 | 2.1 | 2.3 | 2.4 | 0.10 | 0 | 51 | 50 |
| aiofiles | 448.2 | 448.2 | 2.2 | 2.4 | 2.5 | 0.04 | 0 | 51 | 50 |
| aiofile | 434.8 | 434.8 | 2.3 | 2.3 | 2.4 | 0.14 | 0 | 50 | 50 |
| asyncfiles-libuv | 415.9 | 415.9 | 2.1 | 3.3 | 3.5 | 0.03 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 501.2 MB/s (501.2 ops/s)
- **p95 Latency**: 2.1 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **anyio**: 1.06x slower than asyncfiles-io_uring
- **aiofiles**: 1.12x slower than asyncfiles-io_uring
- **aiofile**: 1.15x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.21x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 508.2 | 508.2 | 13.8 | 15.6 | 15.7 | 0.34 | 0 | 64 | 50 |
| asyncfiles-io_uring | 419.9 | 419.9 | 14.1 | 31.3 | 40.2 | 0.24 | 0 | 64 | 50 |
| anyio | 419.6 | 419.6 | 15.1 | 24.3 | 38.6 | 0.39 | 0 | 60 | 50 |
| aiofiles | 401.5 | 401.5 | 15.0 | 36.2 | 38.7 | 0.28 | 0 | 56 | 50 |
| aiofile | 398.1 | 398.1 | 15.2 | 23.9 | 38.8 | 1.32 | 0 | 64 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 508.2 MB/s (508.2 ops/s)
- **p95 Latency**: 15.6 ms
- **CPU Time**: 0.34 s
- **Peak Memory**: 64 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.21x slower than asyncfiles-libuv
- **anyio**: 1.21x slower than asyncfiles-libuv
- **aiofiles**: 1.27x slower than asyncfiles-libuv
- **aiofile**: 1.28x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 458.8 | 458.8 | 21.6 | 39.2 | 53.4 | 0.68 | 0 | 80 | 50 |
| anyio | 411.4 | 411.4 | 34.6 | 52.5 | 55.1 | 0.71 | 0 | 75 | 50 |
| aiofile | 406.6 | 406.6 | 31.4 | 50.8 | 54.7 | 2.57 | 0 | 85 | 50 |
| asyncfiles-io_uring | 398.9 | 398.9 | 35.9 | 53.3 | 55.5 | 0.50 | 0 | 80 | 50 |
| aiofiles | 397.7 | 397.7 | 34.9 | 54.2 | 56.5 | 0.60 | 0 | 72 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 458.8 MB/s (458.8 ops/s)
- **p95 Latency**: 39.2 ms
- **CPU Time**: 0.68 s
- **Peak Memory**: 80 MB

## Performance Comparison

- **anyio**: 1.12x slower than asyncfiles-libuv
- **aiofile**: 1.13x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.15x slower than asyncfiles-libuv
- **aiofiles**: 1.15x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 423.5 | 423.5 | 38.3 | 79.5 | 93.9 | 1.34 | 0 | 113 | 50 |
| asyncfiles-io_uring | 401.5 | 401.5 | 67.8 | 92.9 | 95.5 | 1.01 | 0 | 111 | 50 |
| anyio | 399.5 | 399.5 | 66.4 | 93.8 | 97.0 | 1.39 | 0 | 98 | 50 |
| aiofile | 399.1 | 399.1 | 64.1 | 92.5 | 95.7 | 5.24 | 0 | 114 | 50 |
| aiofiles | 398.1 | 398.1 | 73.7 | 92.3 | 95.3 | 1.20 | 0 | 90 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 423.5 MB/s (423.5 ops/s)
- **p95 Latency**: 79.5 ms
- **CPU Time**: 1.34 s
- **Peak Memory**: 113 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.05x slower than asyncfiles-libuv
- **anyio**: 1.06x slower than asyncfiles-libuv
- **aiofile**: 1.06x slower than asyncfiles-libuv
- **aiofiles**: 1.06x slower than asyncfiles-libuv
