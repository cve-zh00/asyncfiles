# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-07 02:44 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 10 |
| asyncfiles-libuv | 2 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 674.3 | 2697.0 | 0.3 | 0.3 | 0.4 | 0.02 | 0 | 22 | 50 |
| asyncfiles-libuv | 577.8 | 2311.0 | 0.4 | 0.4 | 0.5 | 0.02 | 0 | 22 | 50 |
| aiofiles | 368.6 | 1474.3 | 0.6 | 0.7 | 1.9 | 0.04 | 0 | 22 | 50 |
| anyio | 362.1 | 1448.6 | 0.6 | 0.7 | 1.4 | 0.08 | 0 | 23 | 50 |
| aiofile | 246.0 | 984.0 | 0.9 | 1.1 | 1.9 | 0.08 | 0 | 22 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 674.3 MB/s (2697.0 ops/s)
- **p95 Latency**: 0.3 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.17x slower than asyncfiles-io_uring
- **aiofiles**: 1.83x slower than asyncfiles-io_uring
- **anyio**: 1.86x slower than asyncfiles-io_uring
- **aiofile**: 2.74x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2110.5 | 8441.8 | 0.7 | 0.8 | 1.2 | 0.13 | 0 | 30 | 50 |
| asyncfiles-io_uring | 1546.2 | 6184.9 | 0.8 | 1.0 | 1.9 | 0.12 | 0 | 32 | 50 |
| aiofiles | 610.8 | 2443.1 | 2.8 | 3.3 | 3.5 | 0.29 | 0 | 30 | 50 |
| anyio | 487.8 | 1951.2 | 3.5 | 4.2 | 4.5 | 0.41 | 0 | 32 | 50 |
| aiofile | 441.2 | 1764.8 | 3.0 | 10.8 | 20.7 | 0.49 | 2 | 32 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2110.5 MB/s (8441.8 ops/s)
- **p95 Latency**: 0.8 ms
- **CPU Time**: 0.13 s
- **Peak Memory**: 30 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.36x slower than asyncfiles-libuv
- **aiofiles**: 3.46x slower than asyncfiles-libuv
- **anyio**: 4.33x slower than asyncfiles-libuv
- **aiofile**: 4.78x slower than asyncfiles-libuv


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2116.4 | 8465.5 | 1.4 | 1.7 | 2.0 | 0.22 | 0 | 37 | 50 |
| asyncfiles-libuv | 1285.0 | 5140.1 | 1.2 | 1.8 | 35.4 | 0.25 | 0 | 37 | 50 |
| aiofiles | 704.7 | 2818.7 | 4.9 | 5.5 | 5.8 | 0.52 | 0 | 37 | 50 |
| anyio | 534.2 | 2136.9 | 6.2 | 7.2 | 7.5 | 0.69 | 1 | 37 | 50 |
| aiofile | 410.1 | 1640.4 | 5.0 | 22.6 | 40.7 | 1.00 | 1 | 37 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2116.4 MB/s (8465.5 ops/s)
- **p95 Latency**: 1.7 ms
- **CPU Time**: 0.22 s
- **Peak Memory**: 37 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.65x slower than asyncfiles-io_uring
- **aiofiles**: 3.00x slower than asyncfiles-io_uring
- **anyio**: 3.96x slower than asyncfiles-io_uring
- **aiofile**: 5.16x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2412.2 | 9649.0 | 2.5 | 3.2 | 3.6 | 0.42 | 0 | 44 | 50 |
| asyncfiles-libuv | 1601.0 | 6403.9 | 2.1 | 3.3 | 20.6 | 0.45 | 0 | 44 | 50 |
| aiofiles | 752.3 | 3009.2 | 9.4 | 10.4 | 10.7 | 1.00 | 0 | 44 | 50 |
| anyio | 614.6 | 2458.5 | 11.7 | 13.0 | 13.5 | 1.20 | 0 | 45 | 50 |
| aiofile | 378.0 | 1511.8 | 9.4 | 34.3 | 43.9 | 2.06 | 3 | 45 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2412.2 MB/s (9649.0 ops/s)
- **p95 Latency**: 3.2 ms
- **CPU Time**: 0.42 s
- **Peak Memory**: 44 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.51x slower than asyncfiles-io_uring
- **aiofiles**: 3.21x slower than asyncfiles-io_uring
- **anyio**: 3.92x slower than asyncfiles-io_uring
- **aiofile**: 6.38x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1172.2 | 2344.5 | 0.4 | 0.4 | 0.4 | 0.02 | 0 | 40 | 50 |
| asyncfiles-libuv | 956.9 | 1913.9 | 0.5 | 0.5 | 0.6 | 0.03 | 0 | 40 | 50 |
| aiofiles | 701.3 | 1402.5 | 0.7 | 0.7 | 1.0 | 0.04 | 0 | 40 | 50 |
| anyio | 631.5 | 1263.0 | 0.7 | 0.9 | 1.8 | 0.10 | 0 | 40 | 50 |
| aiofile | 434.4 | 868.8 | 1.1 | 1.2 | 1.3 | 0.10 | 0 | 40 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1172.2 MB/s (2344.5 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.22x slower than asyncfiles-io_uring
- **aiofiles**: 1.67x slower than asyncfiles-io_uring
- **anyio**: 1.86x slower than asyncfiles-io_uring
- **aiofile**: 2.70x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2905.0 | 5810.0 | 1.0 | 1.4 | 1.5 | 0.19 | 0 | 48 | 50 |
| asyncfiles-io_uring | 2876.4 | 5752.8 | 1.0 | 1.4 | 1.6 | 0.17 | 0 | 48 | 50 |
| aiofiles | 1165.0 | 2330.0 | 2.9 | 3.5 | 3.8 | 0.33 | 0 | 48 | 50 |
| anyio | 911.2 | 1822.4 | 3.8 | 4.6 | 4.7 | 0.43 | 0 | 48 | 50 |
| aiofile | 403.8 | 807.6 | 3.6 | 34.1 | 45.8 | 0.82 | 0 | 48 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2905.0 MB/s (5810.0 ops/s)
- **p95 Latency**: 1.4 ms
- **CPU Time**: 0.19 s
- **Peak Memory**: 48 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.01x slower than asyncfiles-libuv
- **aiofiles**: 2.49x slower than asyncfiles-libuv
- **anyio**: 3.19x slower than asyncfiles-libuv
- **aiofile**: 7.19x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3385.9 | 6771.8 | 1.8 | 2.2 | 2.3 | 0.32 | 0 | 51 | 50 |
| asyncfiles-libuv | 2608.2 | 5216.5 | 1.6 | 2.2 | 2.9 | 0.35 | 0 | 51 | 50 |
| aiofiles | 1244.7 | 2489.4 | 5.4 | 6.8 | 11.3 | 0.62 | 0 | 51 | 50 |
| anyio | 1041.9 | 2083.8 | 6.7 | 7.7 | 8.0 | 0.77 | 0 | 50 | 50 |
| aiofile | 414.8 | 829.5 | 6.2 | 47.7 | 54.5 | 1.58 | 0 | 51 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3385.9 MB/s (6771.8 ops/s)
- **p95 Latency**: 2.2 ms
- **CPU Time**: 0.32 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.30x slower than asyncfiles-io_uring
- **aiofiles**: 2.72x slower than asyncfiles-io_uring
- **anyio**: 3.25x slower than asyncfiles-io_uring
- **aiofile**: 8.16x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3562.8 | 7125.6 | 3.2 | 4.0 | 9.0 | 0.67 | 0 | 62 | 50 |
| asyncfiles-libuv | 2742.0 | 5483.9 | 3.0 | 4.0 | 39.0 | 0.68 | 0 | 62 | 50 |
| aiofiles | 1328.7 | 2657.3 | 10.6 | 12.0 | 15.3 | 1.22 | 0 | 62 | 50 |
| anyio | 1131.6 | 2263.2 | 12.7 | 14.0 | 19.1 | 1.45 | 0 | 62 | 50 |
| aiofile | 395.8 | 791.5 | 34.3 | 53.7 | 59.0 | 3.24 | 0 | 63 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3562.8 MB/s (7125.6 ops/s)
- **p95 Latency**: 4.0 ms
- **CPU Time**: 0.67 s
- **Peak Memory**: 62 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.30x slower than asyncfiles-io_uring
- **aiofiles**: 2.68x slower than asyncfiles-io_uring
- **anyio**: 3.15x slower than asyncfiles-io_uring
- **aiofile**: 9.00x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1655.9 | 1655.9 | 0.5 | 0.6 | 0.8 | 0.03 | 0 | 53 | 50 |
| asyncfiles-libuv | 1468.0 | 1468.0 | 0.6 | 0.7 | 0.9 | 0.04 | 0 | 54 | 50 |
| aiofiles | 1182.0 | 1182.0 | 0.8 | 0.9 | 1.0 | 0.05 | 0 | 53 | 50 |
| anyio | 1074.5 | 1074.5 | 0.9 | 1.1 | 1.2 | 0.13 | 0 | 53 | 50 |
| aiofile | 650.7 | 650.7 | 1.4 | 1.6 | 4.5 | 0.13 | 0 | 54 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1655.9 MB/s (1655.9 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 53 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.13x slower than asyncfiles-io_uring
- **aiofiles**: 1.40x slower than asyncfiles-io_uring
- **anyio**: 1.54x slower than asyncfiles-io_uring
- **aiofile**: 2.54x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4067.1 | 4067.1 | 1.4 | 1.9 | 2.3 | 0.27 | 0 | 65 | 50 |
| asyncfiles-libuv | 4060.9 | 4060.9 | 1.5 | 1.9 | 2.4 | 0.29 | 0 | 65 | 50 |
| aiofiles | 2037.0 | 2037.0 | 3.4 | 4.1 | 4.5 | 0.43 | 0 | 65 | 50 |
| anyio | 1659.7 | 1659.7 | 4.3 | 5.0 | 5.2 | 0.54 | 0 | 65 | 50 |
| aiofile | 395.0 | 395.0 | 5.2 | 50.5 | 56.7 | 1.43 | 0 | 66 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4067.1 MB/s (4067.1 ops/s)
- **p95 Latency**: 1.9 ms
- **CPU Time**: 0.27 s
- **Peak Memory**: 65 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as asyncfiles-io_uring
- **aiofiles**: 2.00x slower than asyncfiles-io_uring
- **anyio**: 2.45x slower than asyncfiles-io_uring
- **aiofile**: 10.30x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4402.9 | 4402.9 | 2.5 | 3.5 | 4.3 | 0.56 | 0 | 72 | 50 |
| asyncfiles-libuv | 3794.9 | 3794.9 | 2.7 | 3.2 | 3.9 | 0.56 | 0 | 72 | 50 |
| aiofiles | 2167.7 | 2167.7 | 6.5 | 7.3 | 8.1 | 0.84 | 0 | 72 | 50 |
| anyio | 1763.3 | 1763.3 | 8.1 | 9.2 | 9.6 | 1.02 | 0 | 73 | 50 |
| aiofile | 398.1 | 398.1 | 42.0 | 60.9 | 62.2 | 2.86 | 0 | 72 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4402.9 MB/s (4402.9 ops/s)
- **p95 Latency**: 3.5 ms
- **CPU Time**: 0.56 s
- **Peak Memory**: 72 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.16x slower than asyncfiles-io_uring
- **aiofiles**: 2.03x slower than asyncfiles-io_uring
- **anyio**: 2.50x slower than asyncfiles-io_uring
- **aiofile**: 11.06x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4609.9 | 4609.9 | 4.9 | 7.2 | 7.5 | 1.17 | 0 | 96 | 50 |
| asyncfiles-libuv | 3223.0 | 3223.0 | 5.1 | 6.2 | 39.4 | 1.17 | 0 | 96 | 50 |
| aiofiles | 2286.0 | 2286.0 | 12.5 | 13.8 | 14.1 | 1.64 | 0 | 96 | 50 |
| anyio | 1891.0 | 1891.0 | 15.1 | 19.7 | 21.7 | 1.93 | 0 | 71 | 50 |
| aiofile | 398.1 | 398.1 | 47.3 | 103.1 | 107.8 | 5.67 | 0 | 96 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4609.9 MB/s (4609.9 ops/s)
- **p95 Latency**: 7.2 ms
- **CPU Time**: 1.17 s
- **Peak Memory**: 96 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.43x slower than asyncfiles-io_uring
- **aiofiles**: 2.02x slower than asyncfiles-io_uring
- **anyio**: 2.44x slower than asyncfiles-io_uring
- **aiofile**: 11.58x slower than asyncfiles-io_uring
