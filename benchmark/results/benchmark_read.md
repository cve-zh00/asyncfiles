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
- **Generated**: 2026-11-07 02:14 UTC

## Summary

Scenarios won (highest throughput) out of 12:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 6 |
| asyncfiles-io_uring | 4 |
| anyio | 2 |


---

# Benchmark Results: 256KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 490.9 | 1963.5 | 0.5 | 0.5 | 0.6 | 0.01 | 0 | 20 | 50 |
| asyncfiles-libuv | 417.0 | 1668.2 | 0.6 | 0.6 | 0.8 | 0.01 | 0 | 20 | 50 |
| aiofiles | 397.8 | 1591.2 | 0.6 | 0.7 | 0.9 | 0.02 | 0 | 21 | 50 |
| anyio | 333.8 | 1335.1 | 0.7 | 0.8 | 0.9 | 0.06 | 0 | 22 | 50 |
| aiofile | 246.1 | 984.5 | 0.7 | 0.8 | 9.5 | 0.09 | 0 | 21 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 490.9 MB/s (1963.5 ops/s)
- **p95 Latency**: 0.5 ms
- **CPU Time**: 0.01 s
- **Peak Memory**: 20 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.18x slower than asyncfiles-io_uring
- **aiofiles**: 1.23x slower than asyncfiles-io_uring
- **anyio**: 1.47x slower than asyncfiles-io_uring
- **aiofile**: 1.99x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 465.8 | 1863.1 | 2.7 | 5.8 | 16.8 | 0.33 | 0 | 30 | 50 |
| asyncfiles-libuv | 465.0 | 1859.8 | 1.4 | 5.7 | 6.8 | 0.15 | 0 | 25 | 50 |
| aiofile | 429.1 | 1716.5 | 2.5 | 3.4 | 12.6 | 0.50 | 0 | 29 | 50 |
| asyncfiles-io_uring | 405.6 | 1622.5 | 1.5 | 6.2 | 11.3 | 0.10 | 0 | 26 | 50 |
| aiofiles | 399.4 | 1597.7 | 2.2 | 4.5 | 6.4 | 0.23 | 0 | 28 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 465.8 MB/s (1863.1 ops/s)
- **p95 Latency**: 5.8 ms
- **CPU Time**: 0.33 s
- **Peak Memory**: 30 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as anyio
- **aiofile**: 1.09x slower than anyio
- **asyncfiles-io_uring**: 1.15x slower than anyio
- **aiofiles**: 1.17x slower than anyio


---

# Benchmark Results: 256KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 525.4 | 2101.4 | 3.1 | 8.7 | 20.9 | 0.22 | 0 | 36 | 50 |
| asyncfiles-libuv | 523.5 | 2094.0 | 2.8 | 8.4 | 25.9 | 0.31 | 0 | 35 | 50 |
| aiofiles | 520.3 | 2081.2 | 4.5 | 8.9 | 10.7 | 0.44 | 0 | 34 | 50 |
| aiofile | 499.5 | 1998.1 | 4.5 | 15.2 | 36.9 | 0.84 | 1 | 34 | 50 |
| anyio | 402.5 | 1609.9 | 4.7 | 19.4 | 31.3 | 0.59 | 0 | 36 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 525.4 MB/s (2101.4 ops/s)
- **p95 Latency**: 8.7 ms
- **CPU Time**: 0.22 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as asyncfiles-io_uring
- **aiofiles**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.05x slower than asyncfiles-io_uring
- **anyio**: 1.31x slower than asyncfiles-io_uring


---

# Benchmark Results: 256KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 522.9 | 2091.5 | 7.3 | 16.2 | 28.2 | 0.61 | 0 | 47 | 50 |
| aiofile | 443.5 | 1774.1 | 9.0 | 27.8 | 36.8 | 1.75 | 0 | 47 | 50 |
| asyncfiles-io_uring | 430.8 | 1723.4 | 8.6 | 28.8 | 47.4 | 0.43 | 0 | 47 | 50 |
| aiofiles | 412.0 | 1647.9 | 11.2 | 37.0 | 41.5 | 0.85 | 0 | 42 | 50 |
| anyio | 400.8 | 1603.0 | 8.8 | 30.0 | 49.3 | 1.03 | 0 | 44 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 522.9 MB/s (2091.5 ops/s)
- **p95 Latency**: 16.2 ms
- **CPU Time**: 0.61 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **aiofile**: 1.18x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.21x slower than asyncfiles-libuv
- **aiofiles**: 1.27x slower than asyncfiles-libuv
- **anyio**: 1.30x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 454.4 | 908.8 | 1.0 | 1.4 | 2.2 | 0.02 | 0 | 36 | 50 |
| anyio | 407.2 | 814.5 | 1.2 | 1.3 | 1.5 | 0.09 | 0 | 39 | 50 |
| aiofiles | 382.0 | 764.0 | 1.1 | 1.4 | 6.4 | 0.03 | 0 | 39 | 50 |
| asyncfiles-io_uring | 370.6 | 741.1 | 0.9 | 1.7 | 17.1 | 0.02 | 0 | 36 | 50 |
| aiofile | 323.4 | 646.7 | 1.2 | 3.0 | 10.7 | 0.10 | 0 | 39 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 454.4 MB/s (908.8 ops/s)
- **p95 Latency**: 1.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 36 MB

## Performance Comparison

- **anyio**: 1.12x slower than asyncfiles-libuv
- **aiofiles**: 1.19x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.23x slower than asyncfiles-libuv
- **aiofile**: 1.41x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 513.8 | 1027.6 | 7.2 | 8.9 | 28.2 | 0.18 | 0 | 46 | 50 |
| asyncfiles-libuv | 511.5 | 1023.0 | 2.4 | 8.8 | 19.3 | 0.25 | 0 | 46 | 50 |
| aiofiles | 472.5 | 944.9 | 4.5 | 10.7 | 30.5 | 0.27 | 0 | 42 | 50 |
| anyio | 427.7 | 855.4 | 5.3 | 22.0 | 32.2 | 0.38 | 0 | 45 | 50 |
| aiofile | 388.4 | 776.9 | 4.2 | 21.3 | 25.1 | 0.82 | 0 | 46 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 513.8 MB/s (1027.6 ops/s)
- **p95 Latency**: 8.9 ms
- **CPU Time**: 0.18 s
- **Peak Memory**: 46 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as asyncfiles-io_uring
- **aiofiles**: 1.09x slower than asyncfiles-io_uring
- **anyio**: 1.20x slower than asyncfiles-io_uring
- **aiofile**: 1.32x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 516.2 | 1032.5 | 9.9 | 22.7 | 29.8 | 0.36 | 0 | 56 | 50 |
| aiofile | 419.1 | 838.1 | 8.8 | 33.3 | 38.6 | 1.52 | 0 | 57 | 50 |
| anyio | 402.3 | 804.6 | 9.7 | 35.5 | 54.1 | 0.67 | 0 | 52 | 50 |
| aiofiles | 384.7 | 769.4 | 9.8 | 30.7 | 48.9 | 0.55 | 0 | 52 | 50 |
| asyncfiles-libuv | 290.6 | 581.3 | 7.6 | 27.3 | 141.5 | 0.48 | 0 | 55 | 50 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 516.2 MB/s (1032.5 ops/s)
- **p95 Latency**: 22.7 ms
- **CPU Time**: 0.36 s
- **Peak Memory**: 56 MB

## Performance Comparison

- **aiofile**: 1.23x slower than asyncfiles-io_uring
- **anyio**: 1.28x slower than asyncfiles-io_uring
- **aiofiles**: 1.34x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.78x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 479.1 | 958.1 | 15.3 | 30.3 | 60.5 | 0.93 | 0 | 74 | 50 |
| anyio | 445.2 | 890.4 | 20.3 | 39.6 | 59.8 | 1.23 | 0 | 60 | 50 |
| aiofiles | 420.8 | 841.6 | 26.6 | 28.5 | 29.9 | 1.04 | 0 | 62 | 50 |
| aiofile | 387.3 | 774.6 | 20.0 | 39.1 | 84.7 | 3.07 | 0 | 71 | 50 |
| asyncfiles-io_uring | 306.1 | 612.1 | 19.7 | 48.0 | 157.5 | 0.71 | 0 | 75 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 479.1 MB/s (958.1 ops/s)
- **p95 Latency**: 30.3 ms
- **CPU Time**: 0.93 s
- **Peak Memory**: 74 MB

## Performance Comparison

- **anyio**: 1.08x slower than asyncfiles-libuv
- **aiofiles**: 1.14x slower than asyncfiles-libuv
- **aiofile**: 1.24x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.57x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 571.2 | 571.2 | 1.5 | 2.6 | 3.0 | 0.12 | 0 | 48 | 50 |
| aiofiles | 560.3 | 560.3 | 1.6 | 3.0 | 3.3 | 0.03 | 0 | 48 | 50 |
| asyncfiles-io_uring | 555.7 | 555.7 | 1.3 | 3.7 | 4.2 | 0.02 | 0 | 41 | 50 |
| asyncfiles-libuv | 554.6 | 554.6 | 1.5 | 3.4 | 3.5 | 0.02 | 0 | 41 | 50 |
| aiofile | 547.4 | 547.4 | 1.6 | 2.7 | 5.0 | 0.12 | 0 | 48 | 50 |

## 🏆 Winner: **anyio**

- **Throughput**: 571.2 MB/s (571.2 ops/s)
- **p95 Latency**: 2.6 ms
- **CPU Time**: 0.12 s
- **Peak Memory**: 48 MB

## Performance Comparison

- **aiofiles**: 1.02x slower than anyio
- **asyncfiles-io_uring**: 1.03x slower than anyio
- **asyncfiles-libuv**: 1.03x slower than anyio
- **aiofile**: 1.04x slower than anyio


---

# Benchmark Results: 1MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 548.8 | 548.8 | 9.1 | 18.1 | 18.7 | 0.38 | 0 | 59 | 50 |
| asyncfiles-io_uring | 407.7 | 407.7 | 11.2 | 35.6 | 76.3 | 0.30 | 0 | 61 | 50 |
| aiofiles | 407.4 | 407.4 | 10.3 | 35.9 | 45.1 | 0.31 | 0 | 54 | 50 |
| aiofile | 406.4 | 406.4 | 9.5 | 38.0 | 44.6 | 1.38 | 0 | 62 | 50 |
| anyio | 364.4 | 364.4 | 9.9 | 32.3 | 113.9 | 0.42 | 0 | 57 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 548.8 MB/s (548.8 ops/s)
- **p95 Latency**: 18.1 ms
- **CPU Time**: 0.38 s
- **Peak Memory**: 59 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.35x slower than asyncfiles-libuv
- **aiofiles**: 1.35x slower than asyncfiles-libuv
- **aiofile**: 1.35x slower than asyncfiles-libuv
- **anyio**: 1.51x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 467.6 | 467.6 | 17.7 | 39.7 | 107.6 | 0.73 | 0 | 80 | 50 |
| aiofile | 415.2 | 415.2 | 23.3 | 48.8 | 59.1 | 2.70 | 0 | 84 | 50 |
| aiofiles | 410.4 | 410.4 | 29.4 | 49.4 | 59.4 | 0.63 | 0 | 72 | 50 |
| asyncfiles-io_uring | 404.7 | 404.7 | 38.0 | 56.1 | 58.1 | 0.57 | 0 | 80 | 50 |
| anyio | 402.7 | 402.7 | 28.7 | 50.0 | 76.9 | 0.75 | 0 | 75 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 467.6 MB/s (467.6 ops/s)
- **p95 Latency**: 39.7 ms
- **CPU Time**: 0.73 s
- **Peak Memory**: 80 MB

## Performance Comparison

- **aiofile**: 1.13x slower than asyncfiles-libuv
- **aiofiles**: 1.14x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.16x slower than asyncfiles-libuv
- **anyio**: 1.16x slower than asyncfiles-libuv


---

# Benchmark Results: 1MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 431.5 | 431.5 | 36.6 | 75.8 | 95.8 | 1.49 | 0 | 115 | 50 |
| anyio | 408.7 | 408.7 | 60.8 | 94.1 | 99.5 | 1.52 | 0 | 96 | 50 |
| aiofiles | 407.3 | 407.3 | 58.9 | 89.2 | 184.9 | 1.33 | 0 | 95 | 50 |
| asyncfiles-io_uring | 405.5 | 405.5 | 59.9 | 92.5 | 98.0 | 1.19 | 0 | 115 | 50 |
| aiofile | 402.2 | 402.2 | 54.4 | 92.7 | 126.1 | 5.46 | 0 | 116 | 50 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 431.5 MB/s (431.5 ops/s)
- **p95 Latency**: 75.8 ms
- **CPU Time**: 1.49 s
- **Peak Memory**: 115 MB

## Performance Comparison

- **anyio**: 1.06x slower than asyncfiles-libuv
- **aiofiles**: 1.06x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.06x slower than asyncfiles-libuv
- **aiofile**: 1.07x slower than asyncfiles-libuv
