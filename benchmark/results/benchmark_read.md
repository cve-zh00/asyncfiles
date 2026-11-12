# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.8.0-117-generic (aarch64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Page cache**: cold (evicted)
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-12 13:25 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 7 |
| asyncfiles-libuv | 4 |
| anyio | 1 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1177.7 | 4710.7 | 0.2 | 0.2 | 0.2 | 0.01 | 0 | 20 | 50 |
| anyio | 855.4 | 3421.5 | 0.3 | 0.3 | 0.4 | 0.03 | 0 | 22 | 50 |
| asyncfiles-libuv | 715.4 | 2861.6 | 0.3 | 0.4 | 0.5 | 0.01 | 0 | 20 | 50 |
| aiofiles | 649.7 | 2598.8 | 0.4 | 0.4 | 0.5 | 0.02 | 0 | 20 | 50 |
| aiofile | 621.8 | 2487.1 | 0.3 | 0.5 | 2.3 | 0.04 | 0 | 20 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1177.7 MB/s (4710.7 ops/s)
- **p95 Latency**: 0.2 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **anyio**: 1.38x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.65x slower than asyncfiles-io_uring
- **aiofiles**: 1.81x slower than asyncfiles-io_uring
- **aiofile**: 1.89x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3439.2 | 13756.8 | 0.5 | 0.6 | 0.7 | 0.04 | 0 | 24 | 50 |
| asyncfiles-libuv | 2321.1 | 9284.5 | 0.6 | 0.9 | 1.3 | 0.09 | 0 | 24 | 50 |
| aiofile | 1744.0 | 6975.8 | 0.9 | 1.7 | 2.3 | 0.13 | 0 | 29 | 50 |
| aiofiles | 1275.0 | 5100.0 | 1.1 | 2.7 | 3.5 | 0.10 | 0 | 27 | 50 |
| anyio | 1229.8 | 4919.4 | 1.2 | 2.4 | 5.5 | 0.16 | 0 | 31 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3439.2 MB/s (13756.8 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.04 s
- **Peak Memory**: 24 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.48x slower than asyncfiles-io_uring
- **aiofile**: 1.97x slower than asyncfiles-io_uring
- **aiofiles**: 2.70x slower than asyncfiles-io_uring
- **anyio**: 2.80x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3559.7 | 14239.0 | 1.0 | 1.2 | 1.4 | 0.08 | 0 | 36 | 50 |
| asyncfiles-libuv | 3158.0 | 12631.8 | 0.8 | 1.3 | 1.5 | 0.12 | 0 | 36 | 50 |
| aiofiles | 1599.8 | 6399.1 | 2.1 | 2.6 | 2.8 | 0.19 | 0 | 36 | 50 |
| aiofile | 1303.4 | 5213.7 | 2.3 | 4.0 | 5.0 | 0.29 | 0 | 37 | 50 |
| anyio | 973.0 | 3892.1 | 2.9 | 6.5 | 11.6 | 0.31 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3559.7 MB/s (14239.0 ops/s)
- **p95 Latency**: 1.2 ms
- **CPU Time**: 0.08 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.13x slower than asyncfiles-io_uring
- **aiofiles**: 2.23x slower than asyncfiles-io_uring
- **aiofile**: 2.73x slower than asyncfiles-io_uring
- **anyio**: 3.66x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4226.3 | 16905.0 | 1.7 | 2.0 | 2.3 | 0.12 | 0 | 40 | 50 |
| asyncfiles-libuv | 3854.8 | 15419.1 | 1.2 | 2.0 | 2.3 | 0.20 | 0 | 43 | 50 |
| aiofiles | 2115.0 | 8460.1 | 3.3 | 3.8 | 4.1 | 0.29 | 0 | 51 | 50 |
| aiofile | 1482.9 | 5931.7 | 4.1 | 7.8 | 8.2 | 0.47 | 0 | 51 | 50 |
| anyio | 1342.8 | 5371.2 | 4.9 | 9.3 | 13.4 | 0.45 | 0 | 54 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4226.3 MB/s (16905.0 ops/s)
- **p95 Latency**: 2.0 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.10x slower than asyncfiles-io_uring
- **aiofiles**: 2.00x slower than asyncfiles-io_uring
- **aiofile**: 2.85x slower than asyncfiles-io_uring
- **anyio**: 3.15x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 1613.1 | 3226.1 | 0.3 | 0.4 | 0.4 | 0.03 | 0 | 45 | 50 |
| asyncfiles-io_uring | 1572.3 | 3144.6 | 0.3 | 0.4 | 0.5 | 0.01 | 0 | 46 | 50 |
| asyncfiles-libuv | 1102.4 | 2204.7 | 0.4 | 0.6 | 1.0 | 0.02 | 0 | 46 | 50 |
| aiofiles | 1086.9 | 2173.8 | 0.4 | 0.5 | 0.5 | 0.02 | 0 | 46 | 50 |
| aiofile | 997.4 | 1994.7 | 0.4 | 0.9 | 1.8 | 0.04 | 0 | 45 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 1613.1 MB/s (3226.1 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 45 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.03x slower than anyio
- **asyncfiles-libuv**: 1.46x slower than anyio
- **aiofiles**: 1.48x slower than anyio
- **aiofile**: 1.62x slower than anyio


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3596.0 | 7192.1 | 1.0 | 1.2 | 1.3 | 0.07 | 0 | 46 | 50 |
| asyncfiles-libuv | 3547.2 | 7094.4 | 0.8 | 1.2 | 1.3 | 0.12 | 0 | 46 | 50 |
| aiofiles | 2405.2 | 4810.4 | 1.4 | 1.8 | 1.9 | 0.13 | 0 | 50 | 50 |
| aiofile | 1545.1 | 3090.3 | 1.8 | 3.5 | 7.3 | 0.24 | 0 | 50 | 50 |
| anyio | 1513.8 | 3027.5 | 2.1 | 3.9 | 5.1 | 0.22 | 0 | 50 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3596.0 MB/s (7192.1 ops/s)
- **p95 Latency**: 1.2 ms
- **CPU Time**: 0.07 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **aiofiles**: 1.50x slower than asyncfiles-io_uring
- **aiofile**: 2.33x slower than asyncfiles-io_uring
- **anyio**: 2.38x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3800.7 | 7601.3 | 2.0 | 2.2 | 2.2 | 0.13 | 0 | 54 | 50 |
| asyncfiles-libuv | 3289.0 | 6578.0 | 1.6 | 2.6 | 3.0 | 0.23 | 0 | 54 | 50 |
| aiofiles | 2717.7 | 5435.5 | 2.4 | 3.1 | 3.4 | 0.24 | 0 | 57 | 50 |
| aiofile | 2170.5 | 4341.0 | 2.8 | 4.9 | 5.8 | 0.33 | 0 | 55 | 50 |
| anyio | 2079.8 | 4159.6 | 3.2 | 5.4 | 6.4 | 0.32 | 0 | 58 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3800.7 MB/s (7601.3 ops/s)
- **p95 Latency**: 2.2 ms
- **CPU Time**: 0.13 s
- **Peak Memory**: 54 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.16x slower than asyncfiles-io_uring
- **aiofiles**: 1.40x slower than asyncfiles-io_uring
- **aiofile**: 1.75x slower than asyncfiles-io_uring
- **anyio**: 1.83x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 6025.0 | 12050.1 | 1.5 | 2.5 | 2.7 | 0.26 | 0 | 63 | 50 |
| asyncfiles-io_uring | 4771.0 | 9542.0 | 3.2 | 3.6 | 3.7 | 0.20 | 0 | 74 | 50 |
| aiofiles | 4389.0 | 8778.0 | 3.3 | 4.4 | 5.1 | 0.30 | 0 | 74 | 50 |
| anyio | 2793.6 | 5587.1 | 5.0 | 6.0 | 9.9 | 0.48 | 0 | 83 | 50 |
| aiofile | 2668.9 | 5337.9 | 4.8 | 7.5 | 8.2 | 0.50 | 0 | 77 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 6025.0 MB/s (12050.1 ops/s)
- **p95 Latency**: 2.5 ms
- **CPU Time**: 0.26 s
- **Peak Memory**: 63 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.26x slower than asyncfiles-libuv
- **aiofiles**: 1.37x slower than asyncfiles-libuv
- **anyio**: 2.16x slower than asyncfiles-libuv
- **aiofile**: 2.26x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2512.4 | 2512.4 | 0.3 | 0.6 | 1.3 | 0.02 | 0 | 66 | 50 |
| asyncfiles-io_uring | 2417.7 | 2417.7 | 0.3 | 0.5 | 2.2 | 0.01 | 0 | 66 | 50 |
| aiofile | 1577.4 | 1577.4 | 0.5 | 1.3 | 1.6 | 0.03 | 0 | 66 | 50 |
| aiofiles | 1444.5 | 1444.5 | 0.7 | 0.9 | 0.9 | 0.02 | 0 | 66 | 50 |
| anyio | 673.4 | 673.4 | 1.4 | 2.3 | 2.6 | 0.09 | 0 | 67 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2512.4 MB/s (2512.4 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 66 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.04x slower than asyncfiles-libuv
- **aiofile**: 1.59x slower than asyncfiles-libuv
- **aiofiles**: 1.74x slower than asyncfiles-libuv
- **anyio**: 3.73x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3932.5 | 3932.5 | 1.9 | 2.4 | 2.9 | 0.12 | 0 | 74 | 50 |
| anyio | 3296.3 | 3296.3 | 2.1 | 3.0 | 3.4 | 0.22 | 0 | 75 | 50 |
| asyncfiles-libuv | 3214.1 | 3214.1 | 1.9 | 2.9 | 3.1 | 0.14 | 0 | 74 | 50 |
| aiofiles | 2538.0 | 2538.0 | 2.4 | 3.5 | 4.0 | 0.17 | 0 | 74 | 50 |
| aiofile | 2055.2 | 2055.2 | 3.1 | 5.5 | 6.8 | 0.30 | 0 | 74 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3932.5 MB/s (3932.5 ops/s)
- **p95 Latency**: 2.4 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 74 MB

## Performance Comparison

- **anyio**: 1.19x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.22x slower than asyncfiles-io_uring
- **aiofiles**: 1.55x slower than asyncfiles-io_uring
- **aiofile**: 1.91x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 6066.2 | 6066.2 | 1.8 | 2.6 | 2.9 | 0.26 | 0 | 74 | 50 |
| aiofiles | 5320.4 | 5320.4 | 2.6 | 3.4 | 3.6 | 0.26 | 0 | 88 | 50 |
| asyncfiles-io_uring | 4614.4 | 4614.4 | 3.3 | 3.8 | 4.5 | 0.21 | 0 | 83 | 50 |
| anyio | 4350.0 | 4350.0 | 3.1 | 4.4 | 5.3 | 0.32 | 0 | 90 | 50 |
| aiofile | 3347.2 | 3347.2 | 3.6 | 6.3 | 7.5 | 0.40 | 0 | 88 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 6066.2 MB/s (6066.2 ops/s)
- **p95 Latency**: 2.6 ms
- **CPU Time**: 0.26 s
- **Peak Memory**: 74 MB

## Performance Comparison

- **aiofiles**: 1.14x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.31x slower than asyncfiles-libuv
- **anyio**: 1.39x slower than asyncfiles-libuv
- **aiofile**: 1.81x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 5846.8 | 5846.8 | 3.2 | 5.3 | 5.7 | 0.54 | 0 | 122 | 50 |
| aiofiles | 4219.3 | 4219.3 | 6.9 | 8.3 | 8.7 | 0.67 | 0 | 123 | 50 |
| asyncfiles-io_uring | 3720.0 | 3720.0 | 8.4 | 9.0 | 9.3 | 0.51 | 0 | 122 | 50 |
| anyio | 2981.7 | 2981.7 | 9.3 | 13.6 | 17.2 | 0.89 | 0 | 134 | 50 |
| aiofile | 2577.5 | 2577.5 | 11.2 | 14.6 | 15.8 | 1.01 | 0 | 123 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 5846.8 MB/s (5846.8 ops/s)
- **p95 Latency**: 5.3 ms
- **CPU Time**: 0.54 s
- **Peak Memory**: 122 MB

## Performance Comparison

- **aiofiles**: 1.39x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.57x slower than asyncfiles-libuv
- **anyio**: 1.96x slower than asyncfiles-libuv
- **aiofile**: 2.27x slower than asyncfiles-libuv
