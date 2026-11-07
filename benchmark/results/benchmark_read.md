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
- **Generated**: 2026-11-07 02:44 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| aiofile | 6 |
| asyncfiles-io_uring | 2 |
| asyncfiles-libuv | 2 |
| anyio | 1 |
| aiofiles | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 411.1 | 1644.5 | 0.5 | 0.8 | 1.1 | 0.02 | 0 | 20 | 50 |
| asyncfiles-libuv | 319.7 | 1278.9 | 0.7 | 1.1 | 1.9 | 0.02 | 0 | 20 | 50 |
| aiofiles | 283.4 | 1133.7 | 0.8 | 1.0 | 1.2 | 0.03 | 0 | 20 | 50 |
| aiofile | 261.4 | 1045.5 | 0.9 | 1.1 | 1.7 | 0.11 | 0 | 21 | 50 |
| anyio | 261.1 | 1044.3 | 0.9 | 1.1 | 1.6 | 0.09 | 0 | 22 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 411.1 MB/s (1644.5 ops/s)
- **p95 Latency**: 0.8 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.29x slower than asyncfiles-io_uring
- **aiofiles**: 1.45x slower than asyncfiles-io_uring
- **aiofile**: 1.57x slower than asyncfiles-io_uring
- **anyio**: 1.57x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 865.0 | 3459.8 | 1.5 | 2.2 | 2.4 | 0.21 | 0 | 25 | 50 |
| asyncfiles-io_uring | 798.6 | 3194.3 | 2.1 | 2.6 | 2.8 | 0.13 | 0 | 25 | 50 |
| aiofiles | 535.4 | 2141.8 | 3.0 | 4.0 | 11.3 | 0.31 | 0 | 28 | 50 |
| aiofile | 446.3 | 1785.0 | 3.5 | 4.8 | 7.9 | 0.56 | 2 | 30 | 50 |
| anyio | 445.3 | 1781.3 | 3.7 | 6.0 | 7.7 | 0.42 | 0 | 31 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 865.0 MB/s (3459.8 ops/s)
- **p95 Latency**: 2.2 ms
- **CPU Time**: 0.21 s
- **Peak Memory**: 25 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.08x slower than asyncfiles-libuv
- **aiofiles**: 1.62x slower than asyncfiles-libuv
- **aiofile**: 1.94x slower than asyncfiles-libuv
- **anyio**: 1.94x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 497.4 | 1989.7 | 6.3 | 12.7 | 14.8 | 0.96 | 4 | 33 | 50 |
| aiofiles | 463.3 | 1853.1 | 5.4 | 19.1 | 33.0 | 0.59 | 0 | 34 | 50 |
| asyncfiles-libuv | 460.6 | 1842.5 | 2.3 | 27.5 | 44.2 | 0.42 | 0 | 37 | 50 |
| asyncfiles-io_uring | 460.0 | 1839.9 | 3.8 | 26.5 | 39.5 | 0.26 | 0 | 38 | 50 |
| anyio | 445.1 | 1780.4 | 6.5 | 12.1 | 15.4 | 0.73 | 2 | 37 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 497.4 MB/s (1989.7 ops/s)
- **p95 Latency**: 12.7 ms
- **CPU Time**: 0.96 s
- **Peak Memory**: 33 MB

## Performance Comparison

- **aiofiles**: 1.07x slower than aiofile
- **asyncfiles-libuv**: 1.08x slower than aiofile
- **asyncfiles-io_uring**: 1.08x slower than aiofile
- **anyio**: 1.12x slower than aiofile


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 452.4 | 1809.8 | 12.1 | 22.1 | 34.3 | 1.95 | 1 | 47 | 50 |
| aiofiles | 442.8 | 1771.0 | 10.7 | 37.0 | 45.2 | 1.13 | 0 | 43 | 50 |
| anyio | 440.1 | 1760.3 | 12.0 | 27.3 | 35.5 | 1.29 | 0 | 45 | 50 |
| asyncfiles-libuv | 436.0 | 1743.8 | 4.3 | 34.0 | 45.4 | 0.83 | 0 | 49 | 50 |
| asyncfiles-io_uring | 432.0 | 1727.9 | 7.4 | 33.4 | 45.0 | 0.51 | 0 | 49 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 452.4 MB/s (1809.8 ops/s)
- **p95 Latency**: 22.1 ms
- **CPU Time**: 1.95 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **aiofiles**: 1.02x slower than aiofile
- **anyio**: 1.03x slower than aiofile
- **asyncfiles-libuv**: 1.04x slower than aiofile
- **asyncfiles-io_uring**: 1.05x slower than aiofile


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 571.2 | 1142.4 | 0.8 | 0.9 | 1.6 | 0.03 | 0 | 37 | 50 |
| anyio | 507.2 | 1014.3 | 0.9 | 1.1 | 1.3 | 0.09 | 0 | 40 | 50 |
| aiofiles | 428.0 | 856.0 | 1.1 | 1.3 | 1.4 | 0.04 | 0 | 40 | 50 |
| aiofile | 417.9 | 835.7 | 1.2 | 1.2 | 1.3 | 0.14 | 0 | 40 | 50 |
| asyncfiles-libuv | 411.8 | 823.6 | 1.0 | 1.2 | 10.2 | 0.03 | 0 | 36 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 571.2 MB/s (1142.4 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 37 MB

## Performance Comparison

- **anyio**: 1.13x slower than asyncfiles-io_uring
- **aiofiles**: 1.33x slower than asyncfiles-io_uring
- **aiofile**: 1.37x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.39x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 940.3 | 1880.5 | 2.4 | 3.9 | 21.7 | 0.34 | 0 | 46 | 50 |
| aiofile | 487.9 | 975.8 | 4.2 | 21.3 | 37.3 | 0.82 | 0 | 49 | 50 |
| anyio | 461.3 | 922.6 | 4.0 | 26.2 | 39.1 | 0.48 | 0 | 48 | 50 |
| aiofiles | 435.0 | 870.1 | 3.2 | 28.4 | 45.3 | 0.38 | 0 | 46 | 50 |
| asyncfiles-io_uring | 425.9 | 851.8 | 3.6 | 28.1 | 45.0 | 0.23 | 0 | 47 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 940.3 MB/s (1880.5 ops/s)
- **p95 Latency**: 3.9 ms
- **CPU Time**: 0.34 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **aiofile**: 1.93x slower than asyncfiles-libuv
- **anyio**: 2.04x slower than asyncfiles-libuv
- **aiofiles**: 2.16x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 2.21x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 448.5 | 897.0 | 8.4 | 37.3 | 40.1 | 1.65 | 0 | 57 | 50 |
| anyio | 446.7 | 893.3 | 8.1 | 35.7 | 48.2 | 0.89 | 0 | 50 | 50 |
| asyncfiles-io_uring | 437.7 | 875.5 | 7.0 | 34.1 | 45.6 | 0.48 | 0 | 59 | 50 |
| asyncfiles-libuv | 430.9 | 861.8 | 3.7 | 35.6 | 51.6 | 0.69 | 0 | 59 | 50 |
| aiofiles | 417.6 | 835.2 | 6.2 | 46.5 | 51.3 | 0.75 | 0 | 53 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 448.5 MB/s (897.0 ops/s)
- **p95 Latency**: 37.3 ms
- **CPU Time**: 1.65 s
- **Peak Memory**: 57 MB

## Performance Comparison

- **anyio**: about the same as aiofile
- **asyncfiles-io_uring**: 1.02x slower than aiofile
- **asyncfiles-libuv**: 1.04x slower than aiofile
- **aiofiles**: 1.07x slower than aiofile


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 439.9 | 879.9 | 16.6 | 43.8 | 58.4 | 3.22 | 0 | 70 | 50 |
| anyio | 436.5 | 872.9 | 13.8 | 49.5 | 58.7 | 1.64 | 0 | 62 | 50 |
| asyncfiles-io_uring | 426.1 | 852.2 | 14.3 | 47.9 | 57.5 | 0.96 | 0 | 73 | 50 |
| aiofiles | 426.0 | 851.9 | 34.8 | 57.1 | 57.9 | 1.45 | 0 | 63 | 50 |
| asyncfiles-libuv | 423.1 | 846.1 | 7.1 | 51.5 | 56.6 | 1.39 | 0 | 72 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 439.9 MB/s (879.9 ops/s)
- **p95 Latency**: 43.8 ms
- **CPU Time**: 3.22 s
- **Peak Memory**: 70 MB

## Performance Comparison

- **anyio**: 1.01x slower than aiofile
- **asyncfiles-io_uring**: 1.03x slower than aiofile
- **aiofiles**: 1.03x slower than aiofile
- **asyncfiles-libuv**: 1.04x slower than aiofile


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 596.5 | 596.5 | 1.5 | 2.4 | 6.9 | 0.13 | 0 | 53 | 50 |
| asyncfiles-libuv | 567.3 | 567.3 | 1.5 | 2.4 | 14.1 | 0.05 | 0 | 47 | 50 |
| aiofiles | 561.3 | 561.3 | 1.5 | 2.1 | 13.7 | 0.06 | 0 | 52 | 50 |
| aiofile | 518.5 | 518.5 | 1.5 | 6.3 | 7.3 | 0.17 | 0 | 53 | 50 |
| asyncfiles-io_uring | 509.6 | 509.6 | 1.1 | 1.6 | 23.4 | 0.04 | 0 | 47 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 596.5 MB/s (596.5 ops/s)
- **p95 Latency**: 2.4 ms
- **CPU Time**: 0.13 s
- **Peak Memory**: 53 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.05x slower than anyio
- **aiofiles**: 1.06x slower than anyio
- **aiofile**: 1.15x slower than anyio
- **asyncfiles-io_uring**: 1.17x slower than anyio


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 449.0 | 449.0 | 5.9 | 36.6 | 43.9 | 1.47 | 0 | 70 | 50 |
| asyncfiles-io_uring | 444.4 | 444.4 | 6.8 | 35.7 | 50.7 | 0.45 | 0 | 67 | 50 |
| anyio | 438.4 | 438.4 | 4.5 | 45.6 | 52.9 | 0.62 | 0 | 65 | 50 |
| asyncfiles-libuv | 438.4 | 438.4 | 3.7 | 38.8 | 54.0 | 0.62 | 0 | 67 | 50 |
| aiofiles | 421.6 | 421.6 | 3.9 | 47.5 | 52.3 | 0.53 | 0 | 63 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 449.0 MB/s (449.0 ops/s)
- **p95 Latency**: 36.6 ms
- **CPU Time**: 1.47 s
- **Peak Memory**: 70 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.01x slower than aiofile
- **anyio**: 1.02x slower than aiofile
- **asyncfiles-libuv**: 1.02x slower than aiofile
- **aiofiles**: 1.07x slower than aiofile


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 443.5 | 443.5 | 11.3 | 45.8 | 58.2 | 2.88 | 0 | 88 | 50 |
| asyncfiles-io_uring | 427.3 | 427.3 | 14.1 | 49.2 | 56.3 | 0.92 | 0 | 87 | 50 |
| anyio | 426.1 | 426.1 | 9.0 | 51.7 | 60.2 | 1.19 | 0 | 72 | 50 |
| aiofiles | 422.3 | 422.3 | 35.2 | 53.0 | 58.0 | 1.13 | 0 | 77 | 50 |
| asyncfiles-libuv | 421.7 | 421.7 | 6.7 | 46.7 | 57.8 | 1.23 | 0 | 86 | 50 |

## 🏆 Winner: **aiofile**

- **Throughput**: 443.5 MB/s (443.5 ops/s)
- **p95 Latency**: 45.8 ms
- **CPU Time**: 2.88 s
- **Peak Memory**: 88 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.04x slower than aiofile
- **anyio**: 1.04x slower than aiofile
- **aiofiles**: 1.05x slower than aiofile
- **asyncfiles-libuv**: 1.05x slower than aiofile


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 430.6 | 430.6 | 44.1 | 101.4 | 102.7 | 2.35 | 0 | 95 | 50 |
| aiofile | 429.6 | 429.6 | 38.3 | 97.0 | 103.9 | 5.94 | 0 | 115 | 50 |
| asyncfiles-io_uring | 426.4 | 426.4 | 44.5 | 96.6 | 99.7 | 1.91 | 0 | 120 | 50 |
| anyio | 418.5 | 418.5 | 42.8 | 89.4 | 103.1 | 2.48 | 0 | 96 | 50 |
| asyncfiles-libuv | 416.9 | 416.9 | 38.4 | 86.7 | 101.1 | 2.56 | 0 | 118 | 50 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 430.6 MB/s (430.6 ops/s)
- **p95 Latency**: 101.4 ms
- **CPU Time**: 2.35 s
- **Peak Memory**: 95 MB

## Performance Comparison

- **aiofile**: about the same as aiofiles
- **asyncfiles-io_uring**: 1.01x slower than aiofiles
- **anyio**: 1.03x slower than aiofiles
- **asyncfiles-libuv**: 1.03x slower than aiofiles
