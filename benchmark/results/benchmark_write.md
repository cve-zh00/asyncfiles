# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 7.0.0-1019-azure (x86_64)
- **Iterations**: 50
- **Concurrency**: 1, 8, 16, 32
- **File sizes**: 256KB, 512KB, 1MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Generated**: 2026-11-11 03:26 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 8 |
| asyncfiles-libuv | 2 |
| anyio | 2 |


---

# Benchmark Results: 256KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 611.4 | 2445.5 | 0.3 | 0.6 | 1.1 | 0.02 | 0 | 23 | 50 |
| asyncfiles-libuv | 598.7 | 2394.8 | 0.4 | 0.5 | 0.6 | 0.04 | 0 | 23 | 50 |
| anyio | 520.0 | 2080.0 | 0.4 | 0.6 | 0.9 | 0.07 | 0 | 23 | 50 |
| aiofiles | 459.3 | 1837.2 | 0.5 | 0.5 | 1.7 | 0.02 | 0 | 22 | 50 |
| aiofile | 251.6 | 1006.4 | 0.8 | 2.1 | 2.4 | 0.07 | 0 | 23 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 611.4 MB/s (2445.5 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 23 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **anyio**: 1.18x slower than asyncfiles-io_uring
- **aiofiles**: 1.33x slower than asyncfiles-io_uring
- **aiofile**: 2.43x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1529.0 | 6116.1 | 0.8 | 1.0 | 11.1 | 0.08 | 0 | 32 | 50 |
| asyncfiles-libuv | 1464.2 | 5856.7 | 0.7 | 0.9 | 10.3 | 0.10 | 0 | 31 | 50 |
| aiofiles | 765.5 | 3062.1 | 2.2 | 2.6 | 3.5 | 0.21 | 0 | 31 | 50 |
| anyio | 613.6 | 2454.5 | 2.8 | 3.9 | 4.9 | 0.34 | 0 | 32 | 50 |
| aiofile | 226.9 | 907.8 | 6.9 | 9.7 | 31.2 | 0.64 | 0 | 32 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1529.0 MB/s (6116.1 ops/s)
- **p95 Latency**: 1.0 ms
- **CPU Time**: 0.08 s
- **Peak Memory**: 32 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.04x slower than asyncfiles-io_uring
- **aiofiles**: 2.00x slower than asyncfiles-io_uring
- **anyio**: 2.49x slower than asyncfiles-io_uring
- **aiofile**: 6.74x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1956.8 | 7827.1 | 1.6 | 1.9 | 2.0 | 0.16 | 0 | 32 | 50 |
| asyncfiles-libuv | 1497.2 | 5988.6 | 1.3 | 2.5 | 40.9 | 0.20 | 0 | 34 | 50 |
| aiofiles | 935.0 | 3740.2 | 3.7 | 4.1 | 4.4 | 0.38 | 0 | 36 | 50 |
| anyio | 480.4 | 1921.5 | 4.8 | 5.6 | 92.9 | 0.53 | 0 | 37 | 50 |
| aiofile | 108.4 | 433.4 | 9.9 | 117.8 | 222.7 | 1.96 | 0 | 37 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1956.8 MB/s (7827.1 ops/s)
- **p95 Latency**: 1.9 ms
- **CPU Time**: 0.16 s
- **Peak Memory**: 32 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.31x slower than asyncfiles-io_uring
- **aiofiles**: 2.09x slower than asyncfiles-io_uring
- **anyio**: 4.07x slower than asyncfiles-io_uring
- **aiofile**: 18.06x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2314.7 | 9258.8 | 2.8 | 3.5 | 3.8 | 0.35 | 0 | 36 | 50 |
| asyncfiles-io_uring | 1932.4 | 7729.4 | 3.4 | 3.9 | 4.3 | 0.32 | 0 | 37 | 50 |
| aiofiles | 946.6 | 3786.6 | 6.9 | 7.5 | 7.8 | 0.74 | 0 | 44 | 50 |
| anyio | 839.3 | 3357.1 | 8.4 | 9.3 | 9.6 | 0.93 | 0 | 44 | 50 |
| aiofile | 207.6 | 830.6 | 20.8 | 50.3 | 81.9 | 2.70 | 0 | 45 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2314.7 MB/s (9258.8 ops/s)
- **p95 Latency**: 3.5 ms
- **CPU Time**: 0.35 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.20x slower than asyncfiles-libuv
- **aiofiles**: 2.45x slower than asyncfiles-libuv
- **anyio**: 2.76x slower than asyncfiles-libuv
- **aiofile**: 11.15x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 907.9 | 1815.7 | 0.5 | 0.6 | 0.9 | 0.12 | 0 | 40 | 50 |
| asyncfiles-io_uring | 882.7 | 1765.5 | 0.5 | 0.6 | 0.9 | 0.02 | 0 | 40 | 50 |
| asyncfiles-libuv | 824.1 | 1648.2 | 0.6 | 0.7 | 0.7 | 0.02 | 0 | 40 | 50 |
| aiofiles | 759.9 | 1519.7 | 0.6 | 0.8 | 0.8 | 0.03 | 0 | 40 | 50 |
| aiofile | 268.1 | 536.1 | 0.9 | 5.2 | 5.2 | 0.12 | 0 | 40 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 907.9 MB/s (1815.7 ops/s)
- **p95 Latency**: 0.6 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.03x slower than anyio
- **asyncfiles-libuv**: 1.10x slower than anyio
- **aiofiles**: 1.19x slower than anyio
- **aiofile**: 3.39x slower than anyio


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2784.7 | 5569.5 | 1.1 | 1.3 | 1.5 | 0.13 | 0 | 42 | 50 |
| asyncfiles-libuv | 1576.9 | 3153.7 | 1.0 | 9.2 | 9.6 | 0.15 | 0 | 43 | 50 |
| aiofiles | 1470.7 | 2941.3 | 2.3 | 2.7 | 2.8 | 0.24 | 0 | 43 | 50 |
| anyio | 819.3 | 1638.5 | 3.0 | 3.7 | 76.9 | 0.36 | 0 | 45 | 50 |
| aiofile | 226.1 | 452.1 | 10.0 | 19.7 | 65.8 | 1.14 | 0 | 45 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2784.7 MB/s (5569.5 ops/s)
- **p95 Latency**: 1.3 ms
- **CPU Time**: 0.13 s
- **Peak Memory**: 42 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.77x slower than asyncfiles-io_uring
- **aiofiles**: 1.89x slower than asyncfiles-io_uring
- **anyio**: 3.40x slower than asyncfiles-io_uring
- **aiofile**: 12.32x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2486.4 | 4972.8 | 1.9 | 2.4 | 38.9 | 0.25 | 0 | 49 | 50 |
| asyncfiles-libuv | 1789.6 | 3579.3 | 1.4 | 11.3 | 19.4 | 0.26 | 0 | 49 | 50 |
| aiofiles | 1706.4 | 3412.9 | 4.0 | 4.6 | 4.9 | 0.46 | 0 | 41 | 50 |
| anyio | 1162.3 | 2324.7 | 5.2 | 5.8 | 58.7 | 0.58 | 0 | 40 | 50 |
| aiofile | 189.3 | 378.7 | 27.8 | 73.3 | 251.2 | 2.55 | 0 | 49 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2486.4 MB/s (4972.8 ops/s)
- **p95 Latency**: 2.4 ms
- **CPU Time**: 0.25 s
- **Peak Memory**: 49 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.39x slower than asyncfiles-io_uring
- **aiofiles**: 1.46x slower than asyncfiles-io_uring
- **anyio**: 2.14x slower than asyncfiles-io_uring
- **aiofile**: 13.13x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 2609.3 | 5218.5 | 2.7 | 3.4 | 43.6 | 0.49 | 0 | 61 | 50 |
| asyncfiles-io_uring | 1812.1 | 3624.3 | 3.7 | 5.1 | 207.7 | 0.48 | 0 | 45 | 50 |
| aiofiles | 1697.8 | 3395.5 | 7.4 | 8.3 | 54.1 | 0.88 | 0 | 59 | 50 |
| anyio | 1565.5 | 3131.1 | 9.1 | 9.9 | 13.6 | 1.07 | 0 | 44 | 50 |
| aiofile | 197.8 | 395.7 | 45.4 | 112.2 | 200.4 | 4.93 | 0 | 61 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 2609.3 MB/s (5218.5 ops/s)
- **p95 Latency**: 3.4 ms
- **CPU Time**: 0.49 s
- **Peak Memory**: 61 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.44x slower than asyncfiles-libuv
- **aiofiles**: 1.54x slower than asyncfiles-libuv
- **anyio**: 1.67x slower than asyncfiles-libuv
- **aiofile**: 13.19x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 1422.2 | 1422.2 | 0.6 | 0.9 | 1.0 | 0.12 | 0 | 52 | 50 |
| aiofiles | 993.4 | 993.4 | 0.7 | 2.3 | 4.0 | 0.05 | 0 | 52 | 50 |
| asyncfiles-io_uring | 753.9 | 753.9 | 0.4 | 0.6 | 41.9 | 0.02 | 0 | 52 | 50 |
| aiofile | 268.5 | 268.5 | 1.1 | 8.7 | 8.8 | 0.22 | 0 | 52 | 50 |
| asyncfiles-libuv | 175.3 | 175.3 | 0.5 | 64.5 | 128.0 | 0.03 | 0 | 52 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 1422.2 MB/s (1422.2 ops/s)
- **p95 Latency**: 0.9 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 52 MB

## Performance Comparison

- **aiofiles**: 1.43x slower than anyio
- **asyncfiles-io_uring**: 1.89x slower than anyio
- **aiofile**: 5.30x slower than anyio
- **asyncfiles-libuv**: 8.11x slower than anyio


---

# Benchmark Results: 1MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 4587.1 | 4587.1 | 1.3 | 1.6 | 1.8 | 0.20 | 0 | 51 | 50 |
| aiofiles | 2600.3 | 2600.3 | 2.6 | 3.0 | 3.2 | 0.32 | 0 | 51 | 50 |
| anyio | 2167.0 | 2167.0 | 3.3 | 3.9 | 4.6 | 0.42 | 0 | 50 | 50 |
| asyncfiles-libuv | 1374.0 | 1374.0 | 1.2 | 19.3 | 80.3 | 0.23 | 0 | 59 | 50 |
| aiofile | 268.2 | 268.2 | 29.3 | 29.9 | 36.0 | 1.82 | 0 | 60 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 4587.1 MB/s (4587.1 ops/s)
- **p95 Latency**: 1.6 ms
- **CPU Time**: 0.20 s
- **Peak Memory**: 51 MB

## Performance Comparison

- **aiofiles**: 1.76x slower than asyncfiles-io_uring
- **anyio**: 2.12x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 3.34x slower than asyncfiles-io_uring
- **aiofile**: 17.11x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3041.1 | 3041.1 | 2.7 | 3.4 | 50.4 | 0.41 | 0 | 76 | 50 |
| aiofiles | 2563.4 | 2563.4 | 4.7 | 5.4 | 43.8 | 0.61 | 0 | 57 | 50 |
| anyio | 2322.6 | 2322.6 | 6.1 | 6.8 | 7.9 | 0.75 | 0 | 54 | 50 |
| asyncfiles-libuv | 1082.2 | 1082.2 | 1.9 | 49.0 | 233.7 | 0.43 | 0 | 76 | 50 |
| aiofile | 265.6 | 265.6 | 58.6 | 67.6 | 68.9 | 3.66 | 0 | 70 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3041.1 MB/s (3041.1 ops/s)
- **p95 Latency**: 3.4 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 76 MB

## Performance Comparison

- **aiofiles**: 1.19x slower than asyncfiles-io_uring
- **anyio**: 1.31x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 2.81x slower than asyncfiles-io_uring
- **aiofile**: 11.45x slower than asyncfiles-io_uring


---

# Benchmark Results: 1MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 346.9 | 346.9 | 88.3 | 96.7 | 97.2 | 0.84 | 0 | 90 | 50 |
| asyncfiles-libuv | 328.4 | 328.4 | 3.8 | 100.2 | 120.7 | 0.87 | 0 | 90 | 50 |
| aiofiles | 324.5 | 324.5 | 9.2 | 98.3 | 107.6 | 1.26 | 0 | 90 | 50 |
| anyio | 317.2 | 317.2 | 10.9 | 100.1 | 108.4 | 1.46 | 0 | 87 | 50 |
| aiofile | 253.8 | 253.8 | 88.1 | 130.4 | 207.8 | 7.64 | 0 | 88 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 346.9 MB/s (346.9 ops/s)
- **p95 Latency**: 96.7 ms
- **CPU Time**: 0.84 s
- **Peak Memory**: 90 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.06x slower than asyncfiles-io_uring
- **aiofiles**: 1.07x slower than asyncfiles-io_uring
- **anyio**: 1.09x slower than asyncfiles-io_uring
- **aiofile**: 1.37x slower than asyncfiles-io_uring
