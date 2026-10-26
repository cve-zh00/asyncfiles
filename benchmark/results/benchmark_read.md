# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.17.0-1022-azure (x86_64)
- **Iterations**: 10
- **Concurrency**: 1, 8, 32
- **File sizes**: 4KB, 1MB, 16MB
- **Page cache**: cold (evicted)
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32
- **Generated**: 2026-10-26 17:48 UTC

## Summary

Scenarios won (highest throughput) out of 8:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 4 |
| asyncfiles-libuv | 1 |
| aiofiles | 1 |
| aiofile | 1 |
| anyio | 1 |


---

# Benchmark Results: 4KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 15.4 | 3941.2 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 20 | 10 |
| asyncfiles-io_uring | 12.8 | 3267.6 | 0.2 | 0.6 | 0.6 | 0.00 | 0 | 20 | 10 |
| aiofiles | 12.5 | 3193.8 | 0.3 | 0.4 | 0.4 | 0.00 | 0 | 20 | 10 |
| anyio | 9.8 | 2508.8 | 0.4 | 0.5 | 0.5 | 0.01 | 0 | 21 | 10 |
| aiofile | 2.3 | 600.8 | 0.3 | 13.3 | 13.3 | 0.02 | 0 | 20 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 15.4 MB/s (3941.2 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.21x slower than asyncfiles-libuv
- **aiofiles**: 1.23x slower than asyncfiles-libuv
- **anyio**: 1.57x slower than asyncfiles-libuv
- **aiofile**: 6.56x slower than asyncfiles-libuv


---

# Benchmark Results: 4KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 68.1 | 17424.9 | 0.3 | 0.4 | 0.4 | 0.01 | 0 | 22 | 10 |
| asyncfiles-libuv | 51.6 | 13212.8 | 0.4 | 0.6 | 0.8 | 0.01 | 0 | 21 | 10 |
| aiofile | 14.2 | 3629.6 | 1.8 | 2.1 | 2.3 | 0.06 | 0 | 22 | 10 |
| anyio | 12.5 | 3201.6 | 2.2 | 2.9 | 3.0 | 0.06 | 0 | 22 | 10 |
| aiofiles | 3.1 | 783.4 | 1.9 | 2.7 | 79.5 | 0.04 | 0 | 22 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 68.1 MB/s (17424.9 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.32x slower than asyncfiles-io_uring
- **aiofile**: 4.80x slower than asyncfiles-io_uring
- **anyio**: 5.44x slower than asyncfiles-io_uring
- **aiofiles**: 22.24x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 114.5 | 29303.4 | 0.8 | 1.0 | 1.0 | 0.01 | 0 | 23 | 10 |
| asyncfiles-libuv | 66.5 | 17029.1 | 1.0 | 1.4 | 1.6 | 0.07 | 0 | 23 | 10 |
| aiofiles | 17.5 | 4489.0 | 6.4 | 6.9 | 7.0 | 0.12 | 0 | 23 | 10 |
| aiofile | 17.2 | 4401.5 | 5.8 | 6.3 | 12.1 | 0.18 | 0 | 24 | 10 |
| anyio | 14.6 | 3747.0 | 7.4 | 10.5 | 11.2 | 0.20 | 0 | 25 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 114.5 MB/s (29303.4 ops/s)
- **p95 Latency**: 1.0 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.72x slower than asyncfiles-io_uring
- **aiofiles**: 6.53x slower than asyncfiles-io_uring
- **aiofile**: 6.66x slower than asyncfiles-io_uring
- **anyio**: 7.82x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 612.3 | 612.3 | 1.8 | 2.1 | 2.1 | 0.00 | 0 | 27 | 10 |
| aiofile | 584.3 | 584.3 | 1.8 | 2.3 | 2.3 | 0.02 | 0 | 34 | 10 |
| asyncfiles-libuv | 578.5 | 578.5 | 1.8 | 3.9 | 3.9 | 0.01 | 0 | 26 | 10 |
| aiofiles | 570.0 | 570.0 | 1.7 | 2.2 | 2.2 | 0.01 | 0 | 28 | 10 |
| anyio | 521.1 | 521.1 | 1.8 | 4.2 | 4.2 | 0.03 | 0 | 35 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 612.3 MB/s (612.3 ops/s)
- **p95 Latency**: 2.1 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 27 MB

## Performance Comparison

- **aiofile**: 1.05x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.06x slower than asyncfiles-io_uring
- **aiofiles**: 1.07x slower than asyncfiles-io_uring
- **anyio**: 1.18x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 541.0 | 541.0 | 11.8 | 15.6 | 17.3 | 0.06 | 0 | 43 | 10 |
| asyncfiles-libuv | 469.1 | 469.1 | 9.1 | 15.8 | 39.8 | 0.11 | 0 | 48 | 10 |
| anyio | 350.7 | 350.7 | 11.6 | 15.2 | 100.8 | 0.12 | 0 | 50 | 10 |
| aiofile | 196.9 | 196.9 | 12.6 | 153.7 | 155.8 | 0.45 | 0 | 50 | 10 |
| asyncfiles-io_uring | 147.3 | 147.3 | 11.9 | 131.5 | 310.1 | 0.06 | 0 | 48 | 10 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 541.0 MB/s (541.0 ops/s)
- **p95 Latency**: 15.6 ms
- **CPU Time**: 0.06 s
- **Peak Memory**: 43 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.15x slower than aiofiles
- **anyio**: 1.54x slower than aiofiles
- **aiofile**: 2.75x slower than aiofiles
- **asyncfiles-io_uring**: 3.67x slower than aiofiles


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofile | 491.2 | 491.2 | 49.5 | 63.7 | 70.1 | 0.97 | 0 | 101 | 10 |
| anyio | 462.4 | 462.4 | 56.1 | 92.6 | 96.0 | 0.37 | 0 | 91 | 10 |
| asyncfiles-io_uring | 305.6 | 305.6 | 47.5 | 147.2 | 176.4 | 0.24 | 0 | 104 | 10 |
| aiofiles | 213.4 | 213.4 | 52.6 | 207.8 | 240.5 | 0.27 | 0 | 80 | 10 |
| asyncfiles-libuv | 190.3 | 190.3 | 34.0 | 259.6 | 303.7 | 0.30 | 0 | 104 | 10 |

## 🏆 Winner: **aiofile**

- **Throughput**: 491.2 MB/s (491.2 ops/s)
- **p95 Latency**: 63.7 ms
- **CPU Time**: 0.97 s
- **Peak Memory**: 101 MB

## Performance Comparison

- **anyio**: 1.06x slower than aiofile
- **asyncfiles-io_uring**: 1.61x slower than aiofile
- **aiofiles**: 2.30x slower than aiofile
- **asyncfiles-libuv**: 2.58x slower than aiofile


---

# Benchmark Results: 16MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 286.9 | 17.9 | 29.3 | 131.5 | 131.5 | 0.09 | 0 | 241 | 10 |
| asyncfiles-libuv | 285.3 | 17.8 | 31.3 | 173.9 | 173.9 | 0.04 | 0 | 101 | 10 |
| aiofiles | 272.9 | 17.1 | 34.0 | 229.3 | 229.3 | 0.05 | 0 | 228 | 10 |
| aiofile | 207.4 | 13.0 | 49.8 | 251.6 | 251.6 | 0.66 | 0 | 227 | 10 |
| asyncfiles-io_uring | 186.4 | 11.7 | 30.1 | 345.9 | 345.9 | 0.05 | 0 | 100 | 10 |

## 🏆 Winner: **anyio**

- **Throughput**: 286.9 MB/s (17.9 ops/s)
- **p95 Latency**: 131.5 ms
- **CPU Time**: 0.09 s
- **Peak Memory**: 241 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.01x slower than anyio
- **aiofiles**: 1.05x slower than anyio
- **aiofile**: 1.38x slower than anyio
- **asyncfiles-io_uring**: 1.54x slower than anyio


---

# Benchmark Results: 16MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 398.4 | 24.9 | 304.4 | 486.2 | 490.5 | 0.44 | 0 | 466 | 10 |
| aiofile | 391.8 | 24.5 | 315.5 | 365.6 | 372.2 | 3.48 | 0 | 466 | 10 |
| anyio | 388.8 | 24.3 | 278.9 | 484.8 | 495.4 | 0.40 | 0 | 439 | 10 |
| asyncfiles-libuv | 382.0 | 23.9 | 225.4 | 522.1 | 532.4 | 0.40 | 0 | 465 | 10 |
| aiofiles | 371.2 | 23.2 | 292.4 | 709.4 | 713.3 | 0.30 | 0 | 337 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 398.4 MB/s (24.9 ops/s)
- **p95 Latency**: 486.2 ms
- **CPU Time**: 0.44 s
- **Peak Memory**: 466 MB

## Performance Comparison

- **aiofile**: 1.02x slower than asyncfiles-io_uring
- **anyio**: 1.02x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 1.07x slower than asyncfiles-io_uring
