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
- **Generated**: 2026-11-08 03:15 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| aiofile | 7 |
| asyncfiles-io_uring | 3 |
| asyncfiles-libuv | 1 |
| anyio | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 466.8 | 1867.3 | 0.5 | 0.6 | 0.7 | 0.01 | 0 | 20 | 50 |
| asyncfiles-libuv | 297.0 | 1188.1 | 0.7 | 1.2 | 2.9 | 0.03 | 0 | 20 | 50 |
| aiofiles | 270.1 | 1080.6 | 0.8 | 1.1 | 3.5 | 0.03 | 0 | 21 | 50 |
| anyio | 269.3 | 1077.1 | 0.8 | 1.0 | 4.0 | 0.08 | 0 | 23 | 50 |
| aiofile | 255.0 | 1019.8 | 0.9 | 1.0 | 4.9 | 0.10 | 0 | 21 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 466.8 MB/s (1867.3 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.57x slower than asyncfiles-io_uring
- **aiofiles**: 1.73x slower than asyncfiles-io_uring
- **anyio**: 1.73x slower than asyncfiles-io_uring
- **aiofile**: 1.83x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 941.6 | 3766.2 | 1.8 | 2.0 | 3.3 | 0.12 | 0 | 25 | 50 |
| asyncfiles-libuv | 938.3 | 3753.3 | 1.4 | 2.0 | 3.6 | 0.20 | 0 | 25 | 50 |
| aiofiles | 573.6 | 2294.6 | 2.9 | 3.7 | 5.3 | 0.30 | 0 | 27 | 50 |
| aiofile | 451.8 | 1807.2 | 3.4 | 4.3 | 6.7 | 0.55 | 1 | 26 | 50 |
| anyio | 447.5 | 1789.8 | 3.7 | 5.5 | 6.1 | 0.40 | 0 | 30 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 941.6 MB/s (3766.2 ops/s)
- **p95 Latency**: 2.0 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 25 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as asyncfiles-io_uring
- **aiofiles**: 1.64x slower than asyncfiles-io_uring
- **aiofile**: 2.08x slower than asyncfiles-io_uring
- **anyio**: 2.10x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 468.7 | 1874.8 | 6.1 | 12.4 | 24.6 | 0.98 | 3 | 36 | 50 |
| asyncfiles-libuv | 467.1 | 1868.4 | 2.3 | 29.1 | 34.4 | 0.40 | 0 | 36 | 50 |
| asyncfiles-io_uring | 465.1 | 1860.3 | 3.4 | 27.5 | 43.0 | 0.24 | 0 | 37 | 50 |
| aiofiles | 434.0 | 1736.0 | 5.3 | 19.2 | 33.9 | 0.57 | 0 | 33 | 50 |
| anyio | 423.8 | 1695.0 | 6.5 | 13.2 | 27.3 | 0.71 | 0 | 36 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 468.7 MB/s (1874.8 ops/s)
- **p95 Latency**: 12.4 ms
- **CPU Time**: 0.98 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as aiofile
- **asyncfiles-io_uring**: 1.01x slower than aiofile
- **aiofiles**: 1.08x slower than aiofile
- **anyio**: 1.11x slower than aiofile


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 443.6 | 1774.5 | 11.7 | 28.8 | 31.9 | 1.93 | 0 | 47 | 50 |
| aiofiles | 441.2 | 1764.8 | 10.6 | 38.7 | 43.7 | 1.10 | 0 | 42 | 50 |
| asyncfiles-libuv | 436.7 | 1746.9 | 4.2 | 32.9 | 48.3 | 0.80 | 0 | 47 | 50 |
| anyio | 432.2 | 1728.9 | 12.0 | 29.5 | 34.2 | 1.27 | 1 | 44 | 50 |
| asyncfiles-io_uring | 430.4 | 1721.7 | 7.4 | 32.9 | 49.3 | 0.51 | 0 | 48 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 443.6 MB/s (1774.5 ops/s)
- **p95 Latency**: 28.8 ms
- **CPU Time**: 1.93 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **aiofiles**: 1.01x slower than aiofile
- **asyncfiles-libuv**: 1.02x slower than aiofile
- **anyio**: 1.03x slower than aiofile
- **asyncfiles-io_uring**: 1.03x slower than aiofile


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 636.3 | 1272.6 | 0.6 | 0.9 | 4.3 | 0.02 | 0 | 36 | 50 |
| asyncfiles-libuv | 575.9 | 1151.7 | 0.8 | 1.0 | 1.0 | 0.03 | 0 | 36 | 50 |
| aiofiles | 493.3 | 986.7 | 0.9 | 1.1 | 3.2 | 0.04 | 0 | 39 | 50 |
| anyio | 477.7 | 955.4 | 0.9 | 1.2 | 3.6 | 0.10 | 0 | 39 | 50 |
| aiofile | 432.5 | 864.9 | 1.0 | 1.3 | 4.4 | 0.15 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 636.3 MB/s (1272.6 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.10x slower than asyncfiles-io_uring
- **aiofiles**: 1.29x slower than asyncfiles-io_uring
- **anyio**: 1.33x slower than asyncfiles-io_uring
- **aiofile**: 1.47x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 755.2 | 1510.4 | 2.2 | 6.2 | 29.8 | 0.32 | 0 | 45 | 50 |
| aiofile | 479.5 | 958.9 | 4.1 | 21.3 | 38.0 | 0.82 | 0 | 50 | 50 |
| anyio | 455.4 | 910.7 | 3.9 | 27.1 | 44.0 | 0.48 | 0 | 47 | 50 |
| aiofiles | 436.6 | 873.2 | 3.2 | 29.8 | 43.4 | 0.37 | 0 | 47 | 50 |
| asyncfiles-io_uring | 425.8 | 851.5 | 3.2 | 30.1 | 39.4 | 0.22 | 0 | 47 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 755.2 MB/s (1510.4 ops/s)
- **p95 Latency**: 6.2 ms
- **CPU Time**: 0.32 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **aiofile**: 1.58x slower than asyncfiles-libuv
- **anyio**: 1.66x slower than asyncfiles-libuv
- **aiofiles**: 1.73x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.77x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 452.8 | 905.6 | 7.4 | 35.8 | 49.3 | 1.61 | 0 | 57 | 50 |
| aiofiles | 445.1 | 890.3 | 5.9 | 36.0 | 49.9 | 0.71 | 0 | 52 | 50 |
| anyio | 438.5 | 877.1 | 7.1 | 34.7 | 49.6 | 0.84 | 0 | 51 | 50 |
| asyncfiles-libuv | 434.9 | 869.8 | 3.5 | 35.8 | 51.9 | 0.64 | 0 | 58 | 50 |
| asyncfiles-io_uring | 425.4 | 850.8 | 6.7 | 45.3 | 48.9 | 0.45 | 0 | 58 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 452.8 MB/s (905.6 ops/s)
- **p95 Latency**: 35.8 ms
- **CPU Time**: 1.61 s
- **Peak Memory**: 57 MB

## Performance Comparison

- **aiofiles**: 1.02x slower than aiofile
- **anyio**: 1.03x slower than aiofile
- **asyncfiles-libuv**: 1.04x slower than aiofile
- **asyncfiles-io_uring**: 1.06x slower than aiofile


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 436.5 | 873.0 | 14.5 | 45.4 | 58.0 | 3.20 | 0 | 75 | 50 |
| aiofiles | 435.2 | 870.5 | 36.0 | 49.1 | 56.8 | 1.41 | 0 | 60 | 50 |
| anyio | 425.0 | 850.0 | 13.5 | 45.3 | 59.3 | 1.58 | 0 | 61 | 50 |
| asyncfiles-libuv | 422.3 | 844.7 | 7.4 | 51.0 | 56.3 | 1.32 | 0 | 73 | 50 |
| asyncfiles-io_uring | 418.7 | 837.3 | 13.7 | 49.2 | 60.5 | 0.91 | 0 | 73 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 436.5 MB/s (873.0 ops/s)
- **p95 Latency**: 45.4 ms
- **CPU Time**: 3.20 s
- **Peak Memory**: 75 MB

## Performance Comparison

- **aiofiles**: about the same as aiofile
- **anyio**: 1.03x slower than aiofile
- **asyncfiles-libuv**: 1.03x slower than aiofile
- **asyncfiles-io_uring**: 1.04x slower than aiofile


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 692.8 | 692.8 | 1.4 | 1.6 | 3.4 | 0.15 | 0 | 51 | 50 |
| anyio | 688.0 | 688.0 | 1.4 | 1.9 | 2.2 | 0.11 | 0 | 51 | 50 |
| asyncfiles-io_uring | 587.2 | 587.2 | 1.0 | 2.0 | 25.4 | 0.03 | 0 | 44 | 50 |
| asyncfiles-libuv | 535.8 | 535.8 | 1.2 | 5.9 | 14.3 | 0.04 | 0 | 44 | 50 |
| aiofiles | 438.6 | 438.6 | 1.4 | 5.8 | 18.1 | 0.06 | 0 | 52 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 692.8 MB/s (692.8 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.15 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofile
- **asyncfiles-io_uring**: 1.18x slower than aiofile
- **asyncfiles-libuv**: 1.29x slower than aiofile
- **aiofiles**: 1.58x slower than aiofile


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 449.0 | 449.0 | 5.8 | 37.4 | 48.9 | 1.46 | 0 | 68 | 50 |
| asyncfiles-io_uring | 446.1 | 446.1 | 6.4 | 35.6 | 47.1 | 0.43 | 0 | 67 | 50 |
| anyio | 442.9 | 442.9 | 4.3 | 49.5 | 51.3 | 0.60 | 0 | 68 | 50 |
| aiofiles | 435.0 | 435.0 | 3.7 | 39.8 | 54.0 | 0.50 | 0 | 63 | 50 |
| asyncfiles-libuv | 414.0 | 414.0 | 3.5 | 40.7 | 48.7 | 0.57 | 0 | 66 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 449.0 MB/s (449.0 ops/s)
- **p95 Latency**: 37.4 ms
- **CPU Time**: 1.46 s
- **Peak Memory**: 68 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.01x slower than aiofile
- **anyio**: 1.01x slower than aiofile
- **aiofiles**: 1.03x slower than aiofile
- **asyncfiles-libuv**: 1.08x slower than aiofile


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 432.7 | 432.7 | 11.8 | 46.0 | 57.1 | 2.89 | 0 | 87 | 50 |
| aiofiles | 431.9 | 431.9 | 35.3 | 57.9 | 59.4 | 1.07 | 0 | 77 | 50 |
| anyio | 424.2 | 424.2 | 8.5 | 52.2 | 59.9 | 1.10 | 0 | 74 | 50 |
| asyncfiles-io_uring | 423.9 | 423.9 | 13.1 | 52.4 | 60.1 | 0.87 | 0 | 88 | 50 |
| asyncfiles-libuv | 423.0 | 423.0 | 6.5 | 52.0 | 57.2 | 1.15 | 0 | 88 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 432.7 MB/s (432.7 ops/s)
- **p95 Latency**: 46.0 ms
- **CPU Time**: 2.89 s
- **Peak Memory**: 87 MB

## Performance Comparison

- **aiofiles**: about the same as aiofile
- **anyio**: 1.02x slower than aiofile
- **asyncfiles-io_uring**: 1.02x slower than aiofile
- **asyncfiles-libuv**: 1.02x slower than aiofile


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 426.4 | 426.4 | 43.2 | 102.4 | 104.2 | 2.12 | 0 | 98 | 50 |
| aiofile | 425.9 | 425.9 | 39.3 | 96.4 | 104.2 | 5.81 | 0 | 118 | 50 |
| aiofiles | 425.5 | 425.5 | 45.5 | 102.3 | 103.4 | 2.06 | 0 | 101 | 50 |
| asyncfiles-libuv | 418.3 | 418.3 | 39.5 | 97.7 | 101.9 | 2.28 | 0 | 121 | 50 |
| asyncfiles-io_uring | 418.2 | 418.2 | 43.7 | 98.5 | 100.0 | 1.71 | 0 | 122 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 426.4 MB/s (426.4 ops/s)
- **p95 Latency**: 102.4 ms
- **CPU Time**: 2.12 s
- **Peak Memory**: 98 MB

## Performance Comparison

- **aiofile**: about the same as anyio
- **aiofiles**: about the same as anyio
- **asyncfiles-libuv**: 1.02x slower than anyio
- **asyncfiles-io_uring**: 1.02x slower than anyio
