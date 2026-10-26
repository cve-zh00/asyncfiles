# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.17.0-1022-azure (x86_64)
- **Iterations**: 100
- **Concurrency**: 1, 8, 16, 32, 64
- **File sizes**: 512KB, 4MB, 16MB
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32, 16MB x64
- **Generated**: 2026-10-26 19:51 UTC

## Summary

Scenarios won (highest throughput) out of 13:

| Implementation | Wins |
|----------------|------|
| asyncfiles-io_uring | 5 |
| anyio | 4 |
| aiofiles | 2 |
| asyncfiles-libuv | 2 |


---

# Benchmark Results: 512KB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 1367.3 | 2734.6 | 0.3 | 0.4 | 3.0 | 0.02 | 0 | 24 | 100 |
| aiofiles | 1148.5 | 2297.1 | 0.4 | 0.6 | 2.9 | 0.03 | 0 | 24 | 100 |
| anyio | 1135.3 | 2270.7 | 0.4 | 0.5 | 0.7 | 0.13 | 0 | 23 | 100 |
| asyncfiles-libuv | 1007.6 | 2015.2 | 0.3 | 1.4 | 5.2 | 0.03 | 0 | 23 | 100 |
| aiofile | 263.1 | 526.2 | 0.8 | 5.1 | 5.2 | 0.23 | 0 | 24 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 1367.3 MB/s (2734.6 ops/s)
- **p95 Latency**: 0.4 ms
- **CPU Time**: 0.02 s
- **Peak Memory**: 24 MB

## Performance Comparison

- **aiofiles**: 1.19x slower than asyncfiles-io_uring
- **anyio**: 1.20x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.36x slower than asyncfiles-io_uring
- **aiofile**: 5.20x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 1268.7 | 2537.4 | 2.1 | 4.7 | 7.7 | 0.52 | 0 | 37 | 100 |
| asyncfiles-libuv | 994.7 | 1989.4 | 0.7 | 3.7 | 18.7 | 0.25 | 0 | 39 | 100 |
| asyncfiles-io_uring | 940.4 | 1880.9 | 0.7 | 3.8 | 16.7 | 0.21 | 0 | 39 | 100 |
| aiofiles | 861.8 | 1723.7 | 1.6 | 2.2 | 16.4 | 0.39 | 0 | 39 | 100 |
| aiofile | 231.1 | 462.2 | 11.5 | 20.4 | 148.2 | 2.09 | 0 | 39 | 100 |

## 🏆 Winner: **anyio**

- **Throughput**: 1268.7 MB/s (2537.4 ops/s)
- **p95 Latency**: 4.7 ms
- **CPU Time**: 0.52 s
- **Peak Memory**: 37 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.28x slower than anyio
- **asyncfiles-io_uring**: 1.35x slower than anyio
- **aiofiles**: 1.47x slower than anyio
- **aiofile**: 5.49x slower than anyio


---

# Benchmark Results: 512KB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 2689.4 | 5378.8 | 1.5 | 2.1 | 5.5 | 0.41 | 0 | 47 | 100 |
| asyncfiles-libuv | 2142.4 | 4284.7 | 1.1 | 9.4 | 24.6 | 0.45 | 0 | 47 | 100 |
| anyio | 1838.8 | 3677.7 | 3.7 | 5.0 | 8.2 | 0.90 | 0 | 40 | 100 |
| aiofiles | 1571.8 | 3143.5 | 3.1 | 4.0 | 9.7 | 0.76 | 0 | 47 | 100 |
| aiofile | 265.4 | 530.8 | 29.1 | 30.7 | 38.9 | 3.79 | 0 | 48 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 2689.4 MB/s (5378.8 ops/s)
- **p95 Latency**: 2.1 ms
- **CPU Time**: 0.41 s
- **Peak Memory**: 47 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.26x slower than asyncfiles-io_uring
- **anyio**: 1.46x slower than asyncfiles-io_uring
- **aiofiles**: 1.71x slower than asyncfiles-io_uring
- **aiofile**: 10.13x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 3134.0 | 6268.0 | 3.1 | 15.9 | 43.2 | 0.76 | 0 | 40 | 100 |
| aiofiles | 2262.1 | 4524.2 | 5.9 | 6.9 | 7.8 | 1.50 | 0 | 40 | 100 |
| asyncfiles-libuv | 2210.0 | 4420.1 | 2.0 | 17.8 | 45.8 | 0.90 | 0 | 56 | 100 |
| anyio | 2047.1 | 4094.2 | 6.7 | 9.3 | 14.5 | 1.74 | 0 | 41 | 100 |
| aiofile | 238.3 | 476.6 | 48.0 | 78.2 | 181.3 | 8.13 | 0 | 57 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 3134.0 MB/s (6268.0 ops/s)
- **p95 Latency**: 15.9 ms
- **CPU Time**: 0.76 s
- **Peak Memory**: 40 MB

## Performance Comparison

- **aiofiles**: 1.39x slower than asyncfiles-io_uring
- **asyncfiles-libuv**: 1.42x slower than asyncfiles-io_uring
- **anyio**: 1.53x slower than asyncfiles-io_uring
- **aiofile**: 13.15x slower than asyncfiles-io_uring


---

# Benchmark Results: 512KB_x64_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 341.8 | 683.6 | 89.2 | 100.5 | 119.3 | 1.59 | 0 | 95 | 100 |
| asyncfiles-libuv | 334.9 | 669.8 | 3.7 | 99.0 | 100.1 | 1.64 | 0 | 95 | 100 |
| aiofiles | 293.5 | 586.9 | 11.7 | 109.2 | 118.2 | 3.01 | 0 | 95 | 100 |
| anyio | 271.9 | 543.7 | 13.5 | 118.0 | 119.6 | 3.60 | 0 | 96 | 100 |
| aiofile | 255.8 | 511.7 | 79.0 | 126.5 | 139.8 | 15.52 | 0 | 96 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 341.8 MB/s (683.6 ops/s)
- **p95 Latency**: 100.5 ms
- **CPU Time**: 1.59 s
- **Peak Memory**: 95 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.02x slower than asyncfiles-io_uring
- **aiofiles**: 1.16x slower than asyncfiles-io_uring
- **anyio**: 1.26x slower than asyncfiles-io_uring
- **aiofile**: 1.34x slower than asyncfiles-io_uring


---

# Benchmark Results: 4MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 2567.1 | 641.8 | 1.4 | 3.1 | 5.5 | 0.16 | 0 | 97 | 100 |
| anyio | 2382.2 | 595.5 | 1.3 | 1.5 | 30.5 | 0.19 | 0 | 95 | 100 |
| asyncfiles-io_uring | 2208.7 | 552.2 | 1.3 | 2.0 | 28.0 | 0.15 | 0 | 97 | 100 |
| asyncfiles-libuv | 1847.2 | 461.8 | 1.4 | 9.8 | 15.5 | 0.16 | 0 | 97 | 100 |
| aiofile | 263.1 | 65.8 | 16.8 | 19.7 | 39.9 | 1.69 | 0 | 97 | 100 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 2567.1 MB/s (641.8 ops/s)
- **p95 Latency**: 3.1 ms
- **CPU Time**: 0.16 s
- **Peak Memory**: 97 MB

## Performance Comparison

- **anyio**: 1.08x slower than aiofiles
- **asyncfiles-io_uring**: 1.16x slower than aiofiles
- **asyncfiles-libuv**: 1.39x slower than aiofiles
- **aiofile**: 9.76x slower than aiofiles


---

# Benchmark Results: 4MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 361.2 | 90.3 | 3.0 | 89.8 | 99.1 | 1.28 | 0 | 158 | 100 |
| aiofiles | 355.4 | 88.8 | 4.3 | 89.8 | 90.3 | 1.43 | 0 | 158 | 100 |
| anyio | 355.1 | 88.8 | 4.8 | 89.8 | 99.4 | 1.48 | 0 | 158 | 100 |
| asyncfiles-io_uring | 354.8 | 88.7 | 3.2 | 90.2 | 90.9 | 1.26 | 0 | 158 | 100 |
| aiofile | 267.2 | 66.8 | 118.6 | 119.6 | 123.4 | 12.87 | 0 | 158 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 361.2 MB/s (90.3 ops/s)
- **p95 Latency**: 89.8 ms
- **CPU Time**: 1.28 s
- **Peak Memory**: 158 MB

## Performance Comparison

- **aiofiles**: 1.02x slower than asyncfiles-libuv
- **anyio**: 1.02x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.02x slower than asyncfiles-libuv
- **aiofile**: 1.35x slower than asyncfiles-libuv


---

# Benchmark Results: 4MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 353.6 | 88.4 | 90.7 | 181.2 | 188.2 | 2.55 | 0 | 213 | 100 |
| asyncfiles-libuv | 322.1 | 80.5 | 88.8 | 217.4 | 302.7 | 2.71 | 0 | 213 | 100 |
| aiofiles | 321.5 | 80.4 | 101.0 | 208.3 | 227.6 | 3.00 | 0 | 213 | 100 |
| anyio | 313.9 | 78.5 | 118.5 | 214.4 | 233.4 | 3.07 | 0 | 213 | 100 |
| aiofile | 261.1 | 65.3 | 237.6 | 248.1 | 326.9 | 21.16 | 0 | 213 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 353.6 MB/s (88.4 ops/s)
- **p95 Latency**: 181.2 ms
- **CPU Time**: 2.55 s
- **Peak Memory**: 213 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.10x slower than asyncfiles-io_uring
- **aiofiles**: 1.10x slower than asyncfiles-io_uring
- **anyio**: 1.13x slower than asyncfiles-io_uring
- **aiofile**: 1.35x slower than asyncfiles-io_uring


---

# Benchmark Results: 4MB_x32_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 300.9 | 75.2 | 216.4 | 426.4 | 474.3 | 5.61 | 0 | 365 | 100 |
| asyncfiles-io_uring | 283.7 | 70.9 | 187.5 | 455.7 | 457.8 | 4.84 | 0 | 365 | 100 |
| anyio | 275.9 | 69.0 | 336.8 | 476.2 | 477.3 | 6.21 | 0 | 360 | 100 |
| asyncfiles-libuv | 270.7 | 67.7 | 193.0 | 455.4 | 493.7 | 5.11 | 0 | 365 | 100 |
| aiofile | 254.6 | 63.6 | 414.6 | 546.6 | 626.4 | 50.52 | 0 | 366 | 100 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 300.9 MB/s (75.2 ops/s)
- **p95 Latency**: 426.4 ms
- **CPU Time**: 5.61 s
- **Peak Memory**: 365 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.06x slower than aiofiles
- **anyio**: 1.09x slower than aiofiles
- **asyncfiles-libuv**: 1.11x slower than aiofiles
- **aiofile**: 1.18x slower than aiofiles


---

# Benchmark Results: 4MB_x64_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 272.4 | 68.1 | 761.7 | 973.2 | 1026.2 | 13.48 | 0 | 460 | 100 |
| asyncfiles-libuv | 271.6 | 67.9 | 452.1 | 907.8 | 1010.9 | 9.94 | 0 | 482 | 100 |
| aiofiles | 260.4 | 65.1 | 501.2 | 981.9 | 1062.8 | 11.17 | 0 | 477 | 100 |
| asyncfiles-io_uring | 252.2 | 63.1 | 522.3 | 1062.3 | 1083.6 | 9.35 | 0 | 483 | 100 |
| aiofile | 236.9 | 59.2 | 701.7 | 1142.3 | 1301.2 | 107.03 | 0 | 466 | 100 |

## 🏆 Winner: **anyio**

- **Throughput**: 272.4 MB/s (68.1 ops/s)
- **p95 Latency**: 973.2 ms
- **CPU Time**: 13.48 s
- **Peak Memory**: 460 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as anyio
- **aiofiles**: 1.05x slower than anyio
- **asyncfiles-io_uring**: 1.08x slower than anyio
- **aiofile**: 1.15x slower than anyio


---

# Benchmark Results: 16MB_x1_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 3469.9 | 216.9 | 4.5 | 4.8 | 5.0 | 0.55 | 0 | 289 | 100 |
| aiofiles | 3441.3 | 215.1 | 4.5 | 4.8 | 8.5 | 0.52 | 0 | 289 | 100 |
| asyncfiles-io_uring | 3383.9 | 211.5 | 4.4 | 6.1 | 8.5 | 0.54 | 0 | 289 | 100 |
| asyncfiles-libuv | 2531.1 | 158.2 | 4.4 | 7.3 | 59.1 | 0.52 | 0 | 305 | 100 |
| aiofile | 268.7 | 16.8 | 59.5 | 59.9 | 62.5 | 6.58 | 0 | 305 | 100 |

## 🏆 Winner: **anyio**

- **Throughput**: 3469.9 MB/s (216.9 ops/s)
- **p95 Latency**: 4.8 ms
- **CPU Time**: 0.55 s
- **Peak Memory**: 289 MB

## Performance Comparison

- **aiofiles**: 1.01x slower than anyio
- **asyncfiles-io_uring**: 1.03x slower than anyio
- **asyncfiles-libuv**: 1.37x slower than anyio
- **aiofile**: 12.91x slower than anyio


---

# Benchmark Results: 16MB_x8_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| anyio | 306.8 | 19.2 | 286.9 | 456.6 | 486.0 | 5.21 | 0 | 493 | 100 |
| aiofiles | 306.5 | 19.2 | 285.3 | 456.0 | 467.7 | 5.72 | 0 | 495 | 100 |
| asyncfiles-libuv | 294.4 | 18.4 | 274.9 | 455.9 | 487.8 | 5.64 | 0 | 497 | 100 |
| asyncfiles-io_uring | 273.2 | 17.1 | 269.4 | 459.3 | 596.6 | 5.26 | 0 | 495 | 100 |
| aiofile | 266.8 | 16.7 | 474.9 | 483.0 | 493.1 | 38.90 | 0 | 493 | 100 |

## 🏆 Winner: **anyio**

- **Throughput**: 306.8 MB/s (19.2 ops/s)
- **p95 Latency**: 456.6 ms
- **CPU Time**: 5.21 s
- **Peak Memory**: 493 MB

## Performance Comparison

- **aiofiles**: about the same as anyio
- **asyncfiles-libuv**: 1.04x slower than anyio
- **asyncfiles-io_uring**: 1.12x slower than anyio
- **aiofile**: 1.15x slower than anyio


---

# Benchmark Results: 16MB_x16_write

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 279.6 | 17.5 | 486.7 | 941.8 | 1007.8 | 10.06 | 0 | 694 | 100 |
| aiofiles | 277.3 | 17.3 | 641.6 | 955.3 | 1234.7 | 10.19 | 0 | 690 | 100 |
| asyncfiles-io_uring | 276.1 | 17.3 | 483.7 | 908.7 | 1084.7 | 9.82 | 0 | 694 | 100 |
| aiofile | 239.8 | 15.0 | 879.8 | 2113.2 | 2516.1 | 74.09 | 2 | 690 | 100 |
| anyio | 237.7 | 14.9 | 813.7 | 2006.2 | 2448.8 | 10.79 | 0 | 690 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 279.6 MB/s (17.5 ops/s)
- **p95 Latency**: 941.8 ms
- **CPU Time**: 10.06 s
- **Peak Memory**: 694 MB

## Performance Comparison

- **aiofiles**: 1.01x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.01x slower than asyncfiles-libuv
- **aiofile**: 1.17x slower than asyncfiles-libuv
- **anyio**: 1.18x slower than asyncfiles-libuv
