# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.17.0-1022-azure (x86_64)
- **Iterations**: 10
- **Concurrency**: 1, 8, 32
- **File sizes**: 4KB, 1MB, 16MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32
- **Generated**: 2026-10-26 17:48 UTC

## Summary

Scenarios won (highest throughput) out of 8:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 6 |
| asyncfiles-libuv | 1 |
| aiofiles | 1 |


---

# Benchmark Results: 4KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 13.2 | 3375.9 | 0.2 | 0.3 | 0.3 | 0.00 | 0 | 21 | 10 |
| asyncfiles-libuv | 12.1 | 3094.2 | 0.3 | 0.3 | 0.3 | 0.00 | 0 | 21 | 10 |
| anyio | 9.0 | 2295.2 | 0.4 | 0.4 | 0.4 | 0.02 | 0 | 21 | 10 |
| aiofiles | 6.8 | 1731.0 | 0.4 | 1.5 | 1.5 | 0.01 | 0 | 21 | 10 |
| aiofile | 5.6 | 1446.2 | 0.7 | 0.7 | 0.7 | 0.01 | 0 | 21 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 13.2 MB/s (3375.9 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 21 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.09x slower than asyncfiles-io_uring
- **anyio**: 1.47x slower than asyncfiles-io_uring
- **aiofiles**: 1.95x slower than asyncfiles-io_uring
- **aiofile**: 2.33x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 37.1 | 9489.5 | 0.6 | 0.7 | 0.8 | 0.01 | 0 | 22 | 10 |
| asyncfiles-libuv | 35.7 | 9131.2 | 0.6 | 0.7 | 0.7 | 0.03 | 0 | 23 | 10 |
| aiofiles | 12.6 | 3224.7 | 2.1 | 2.6 | 2.8 | 0.04 | 0 | 23 | 10 |
| anyio | 10.8 | 2762.0 | 2.5 | 2.9 | 3.1 | 0.07 | 0 | 23 | 10 |
| aiofile | 0.9 | 231.1 | 2.0 | 143.2 | 184.2 | 0.26 | 0 | 23 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 37.1 MB/s (9489.5 ops/s)
- **p95 Latency**: 0.7 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 2.94x slower than asyncfiles-io_uring
- **anyio**: 3.44x slower than asyncfiles-io_uring
- **aiofile**: 41.07x slower than asyncfiles-io_uring


---

# Benchmark Results: 4KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 46.9 | 12017.7 | 2.2 | 2.5 | 2.5 | 0.04 | 0 | 25 | 10 |
| asyncfiles-io_uring | 41.6 | 10642.9 | 2.6 | 2.8 | 2.8 | 0.03 | 0 | 25 | 10 |
| aiofiles | 17.2 | 4397.1 | 6.2 | 6.9 | 7.1 | 0.12 | 0 | 25 | 10 |
| aiofile | 14.8 | 3785.1 | 5.6 | 7.4 | 11.1 | 0.19 | 0 | 25 | 10 |
| anyio | 13.6 | 3469.9 | 8.1 | 9.0 | 10.5 | 0.22 | 1 | 25 | 10 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 46.9 MB/s (12017.7 ops/s)
- **p95 Latency**: 2.5 ms
- **CPU Time**: 0.04 s
- **Peak Memory**: 25 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.13x slower than asyncfiles-libuv
- **aiofiles**: 2.73x slower than asyncfiles-libuv
- **aiofile**: 3.17x slower than asyncfiles-libuv
- **anyio**: 3.46x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2035.0 | 2035.0 | 0.5 | 0.5 | 0.5 | 0.00 | 0 | 35 | 10 |
| asyncfiles-libuv | 1527.8 | 1527.8 | 0.6 | 0.7 | 0.7 | 0.02 | 0 | 35 | 10 |
| aiofiles | 1512.3 | 1512.3 | 0.6 | 0.7 | 0.7 | 0.01 | 0 | 35 | 10 |
| anyio | 1485.1 | 1485.1 | 0.6 | 0.7 | 0.7 | 0.04 | 0 | 35 | 10 |
| aiofile | 242.6 | 242.6 | 3.9 | 8.4 | 8.4 | 0.05 | 0 | 35 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2035.0 MB/s (2035.0 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.00 s
- **Peak Memory**: 35 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.33x slower than asyncfiles-io_uring
- **aiofiles**: 1.35x slower than asyncfiles-io_uring
- **anyio**: 1.37x slower than asyncfiles-io_uring
- **aiofile**: 8.39x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4827.7 | 4827.7 | 1.3 | 1.4 | 1.6 | 0.04 | 0 | 42 | 10 |
| aiofiles | 2641.4 | 2641.4 | 2.6 | 3.0 | 3.1 | 0.06 | 0 | 42 | 10 |
| anyio | 2186.3 | 2186.3 | 3.3 | 3.9 | 4.0 | 0.13 | 0 | 42 | 10 |
| asyncfiles-libuv | 1332.3 | 1332.3 | 1.1 | 15.1 | 23.1 | 0.04 | 0 | 42 | 10 |
| aiofile | 128.8 | 128.8 | 29.4 | 201.3 | 201.5 | 0.61 | 0 | 50 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4827.7 MB/s (4827.7 ops/s)
- **p95 Latency**: 1.4 ms
- **CPU Time**: 0.04 s
- **Peak Memory**: 42 MB

## Performance Comparison

- **aiofiles**: 1.83x slower than asyncfiles-io_uring
- **anyio**: 2.21x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 3.62x slower than asyncfiles-io_uring
- **aiofile**: 37.47x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 339.1 | 339.1 | 93.8 | 95.8 | 95.9 | 0.15 | 0 | 90 | 10 |
| anyio | 319.7 | 319.7 | 10.1 | 100.7 | 110.4 | 0.35 | 0 | 91 | 10 |
| asyncfiles-libuv | 317.5 | 317.5 | 4.0 | 101.3 | 112.1 | 0.16 | 0 | 90 | 10 |
| aiofiles | 306.3 | 306.3 | 8.6 | 102.9 | 129.5 | 0.24 | 0 | 90 | 10 |
| aiofile | 256.1 | 256.1 | 89.8 | 127.1 | 131.3 | 1.50 | 0 | 91 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 339.1 MB/s (339.1 ops/s)
- **p95 Latency**: 95.8 ms
- **CPU Time**: 0.15 s
- **Peak Memory**: 90 MB

## Performance Comparison

- **anyio**: 1.06x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.07x slower than asyncfiles-io_uring
- **aiofiles**: 1.11x slower than asyncfiles-io_uring
- **aiofile**: 1.32x slower than asyncfiles-io_uring


---

# Benchmark Results: 16MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3955.2 | 247.2 | 3.9 | 4.0 | 4.0 | 0.05 | 0 | 226 | 10 |
| aiofiles | 3813.2 | 238.3 | 4.0 | 4.2 | 4.2 | 0.05 | 0 | 226 | 10 |
| anyio | 3761.4 | 235.1 | 4.1 | 4.2 | 4.2 | 0.09 | 0 | 226 | 10 |
| asyncfiles-libuv | 560.2 | 35.0 | 43.4 | 60.9 | 60.9 | 0.05 | 0 | 243 | 10 |
| aiofile | 242.8 | 15.2 | 61.5 | 103.5 | 103.5 | 0.71 | 0 | 242 | 10 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3955.2 MB/s (247.2 ops/s)
- **p95 Latency**: 4.0 ms
- **CPU Time**: 0.05 s
- **Peak Memory**: 226 MB

## Performance Comparison

- **aiofiles**: 1.04x slower than asyncfiles-io_uring
- **anyio**: 1.05x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 7.06x slower than asyncfiles-io_uring
- **aiofile**: 16.29x slower than asyncfiles-io_uring


---

# Benchmark Results: 16MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 292.9 | 18.3 | 347.4 | 482.3 | 502.3 | 0.51 | 0 | 442 | 10 |
| asyncfiles-libuv | 261.8 | 16.4 | 276.3 | 527.0 | 619.3 | 0.50 | 0 | 442 | 10 |
| anyio | 252.7 | 15.8 | 370.5 | 529.5 | 671.0 | 0.62 | 0 | 443 | 10 |
| asyncfiles-io_uring | 245.0 | 15.3 | 275.0 | 544.8 | 671.1 | 0.48 | 0 | 442 | 10 |
| aiofile | 238.6 | 14.9 | 484.7 | 809.3 | 849.7 | 4.11 | 0 | 443 | 10 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 292.9 MB/s (18.3 ops/s)
- **p95 Latency**: 482.3 ms
- **CPU Time**: 0.51 s
- **Peak Memory**: 442 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.12x slower than aiofiles
- **anyio**: 1.16x slower than aiofiles
- **asyncfiles-io_uring**: 1.20x slower than aiofiles
- **aiofile**: 1.23x slower than aiofiles
