# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries, run inside a resource-limited Docker container.

## Test Configuration

- **Container**: 2.0 CPUs, 1024 MB RAM
- **Kernel**: 6.17.0-1022-azure (x86_64)
- **Iterations**: 100
- **Concurrency**: 1, 8, 16, 32, 64
- **File sizes**: 512KB, 4MB, 16MB
- **Page cache**: cold (evicted)
- **Libraries Tested**: aiofile, aiofiles, anyio, asyncfiles-io_uring, asyncfiles-libuv
- **Skipped (exceeds memory limit)**: 16MB x32, 16MB x64
- **Generated**: 2026-10-26 19:51 UTC

## Summary

Scenarios won (highest throughput) out of 13:

| Implementation | Wins |
|----------------|------|
| asyncfiles-libuv | 8 |
| asyncfiles-io_uring | 4 |
| aiofiles | 1 |


---

# Benchmark Results: 512KB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| aiofiles | 503.1 | 1006.2 | 1.0 | 1.1 | 1.6 | 0.03 | 0 | 22 | 100 |
| asyncfiles-libuv | 502.2 | 1004.4 | 1.0 | 1.2 | 1.4 | 0.03 | 0 | 21 | 100 |
| aiofile | 489.8 | 979.7 | 1.0 | 1.1 | 1.2 | 0.13 | 0 | 22 | 100 |
| anyio | 479.7 | 959.3 | 1.0 | 1.2 | 1.3 | 0.08 | 0 | 24 | 100 |
| asyncfiles-io_uring | 445.1 | 890.1 | 0.9 | 1.9 | 2.1 | 0.03 | 0 | 21 | 100 |

## 🏆 Winner: **aiofiles**

- **Throughput**: 503.1 MB/s (1006.2 ops/s)
- **p95 Latency**: 1.1 ms
- **CPU Time**: 0.03 s
- **Peak Memory**: 22 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as aiofiles
- **aiofile**: 1.03x slower than aiofiles
- **anyio**: 1.05x slower than aiofiles
- **asyncfiles-io_uring**: 1.13x slower than aiofiles


---

# Benchmark Results: 512KB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 558.0 | 1116.0 | 2.5 | 8.7 | 9.0 | 0.38 | 0 | 31 | 100 |
| anyio | 417.5 | 835.0 | 6.1 | 22.8 | 38.5 | 0.55 | 0 | 39 | 100 |
| aiofile | 414.8 | 829.7 | 3.7 | 21.8 | 36.7 | 1.46 | 0 | 35 | 100 |
| asyncfiles-io_uring | 411.6 | 823.2 | 6.1 | 24.1 | 39.8 | 0.39 | 0 | 31 | 100 |
| aiofiles | 411.4 | 822.9 | 6.4 | 22.7 | 38.4 | 0.44 | 0 | 31 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 558.0 MB/s (1116.0 ops/s)
- **p95 Latency**: 8.7 ms
- **CPU Time**: 0.38 s
- **Peak Memory**: 31 MB

## Performance Comparison

- **anyio**: 1.34x slower than asyncfiles-libuv
- **aiofile**: 1.35x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.36x slower than asyncfiles-libuv
- **aiofiles**: 1.36x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 475.6 | 951.2 | 8.0 | 24.5 | 37.9 | 0.82 | 0 | 50 | 100 |
| aiofile | 417.9 | 835.8 | 8.7 | 34.6 | 48.8 | 2.83 | 0 | 49 | 100 |
| anyio | 414.3 | 828.6 | 9.8 | 36.2 | 41.8 | 0.97 | 0 | 47 | 100 |
| aiofiles | 411.4 | 822.8 | 10.1 | 32.8 | 42.5 | 0.86 | 0 | 46 | 100 |
| asyncfiles-io_uring | 409.9 | 819.9 | 9.7 | 39.0 | 45.3 | 0.60 | 0 | 50 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 475.6 MB/s (951.2 ops/s)
- **p95 Latency**: 24.5 ms
- **CPU Time**: 0.82 s
- **Peak Memory**: 50 MB

## Performance Comparison

- **aiofile**: 1.14x slower than asyncfiles-libuv
- **anyio**: 1.15x slower than asyncfiles-libuv
- **aiofiles**: 1.16x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.16x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 438.5 | 877.1 | 16.3 | 41.6 | 55.4 | 1.52 | 0 | 71 | 100 |
| aiofiles | 414.5 | 829.0 | 36.5 | 52.6 | 58.0 | 1.64 | 0 | 61 | 100 |
| anyio | 413.7 | 827.4 | 28.3 | 49.1 | 59.3 | 2.00 | 0 | 62 | 100 |
| aiofile | 411.1 | 822.1 | 23.6 | 47.3 | 58.2 | 5.66 | 0 | 70 | 100 |
| asyncfiles-io_uring | 407.6 | 815.3 | 28.5 | 49.2 | 58.6 | 1.20 | 0 | 71 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 438.5 MB/s (877.1 ops/s)
- **p95 Latency**: 41.6 ms
- **CPU Time**: 1.52 s
- **Peak Memory**: 71 MB

## Performance Comparison

- **aiofiles**: 1.06x slower than asyncfiles-libuv
- **anyio**: 1.06x slower than asyncfiles-libuv
- **aiofile**: 1.07x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.08x slower than asyncfiles-libuv


---

# Benchmark Results: 512KB_x64_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 423.4 | 846.8 | 35.6 | 74.8 | 92.2 | 3.09 | 0 | 103 | 100 |
| aiofile | 412.2 | 824.3 | 55.0 | 86.6 | 95.8 | 10.59 | 0 | 106 | 100 |
| aiofiles | 411.2 | 822.4 | 68.1 | 93.9 | 97.1 | 3.10 | 0 | 78 | 100 |
| anyio | 410.1 | 820.3 | 50.5 | 86.9 | 96.8 | 3.94 | 0 | 105 | 100 |
| asyncfiles-io_uring | 409.5 | 819.0 | 55.2 | 87.4 | 95.4 | 2.42 | 0 | 103 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 423.4 MB/s (846.8 ops/s)
- **p95 Latency**: 74.8 ms
- **CPU Time**: 3.09 s
- **Peak Memory**: 103 MB

## Performance Comparison

- **aiofile**: 1.03x slower than asyncfiles-libuv
- **aiofiles**: 1.03x slower than asyncfiles-libuv
- **anyio**: 1.03x slower than asyncfiles-libuv
- **asyncfiles-io_uring**: 1.03x slower than asyncfiles-libuv


---

# Benchmark Results: 4MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 536.5 | 134.1 | 8.6 | 9.1 | 13.3 | 0.07 | 0 | 62 | 100 |
| asyncfiles-io_uring | 407.0 | 101.7 | 8.6 | 24.4 | 36.5 | 0.10 | 0 | 63 | 100 |
| aiofile | 402.9 | 100.7 | 8.5 | 24.7 | 38.6 | 1.06 | 0 | 93 | 100 |
| anyio | 402.7 | 100.7 | 8.5 | 23.6 | 37.9 | 0.16 | 0 | 97 | 100 |
| aiofiles | 399.7 | 99.9 | 8.5 | 25.5 | 36.1 | 0.09 | 0 | 93 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 536.5 MB/s (134.1 ops/s)
- **p95 Latency**: 9.1 ms
- **CPU Time**: 0.07 s
- **Peak Memory**: 62 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.32x slower than asyncfiles-libuv
- **aiofile**: 1.33x slower than asyncfiles-libuv
- **anyio**: 1.33x slower than asyncfiles-libuv
- **aiofiles**: 1.34x slower than asyncfiles-libuv


---

# Benchmark Results: 4MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 410.4 | 102.6 | 49.8 | 91.0 | 101.3 | 1.10 | 0 | 139 | 100 |
| asyncfiles-io_uring | 403.1 | 100.8 | 73.9 | 97.9 | 101.2 | 1.15 | 0 | 139 | 100 |
| aiofile | 400.2 | 100.1 | 65.9 | 97.8 | 111.0 | 8.81 | 0 | 139 | 100 |
| aiofiles | 396.7 | 99.2 | 75.5 | 99.2 | 108.1 | 1.08 | 0 | 123 | 100 |
| anyio | 396.3 | 99.1 | 73.1 | 98.9 | 105.6 | 1.08 | 0 | 157 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 410.4 MB/s (102.6 ops/s)
- **p95 Latency**: 91.0 ms
- **CPU Time**: 1.10 s
- **Peak Memory**: 139 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.02x slower than asyncfiles-libuv
- **aiofile**: 1.03x slower than asyncfiles-libuv
- **aiofiles**: 1.03x slower than asyncfiles-libuv
- **anyio**: 1.04x slower than asyncfiles-libuv


---

# Benchmark Results: 4MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 403.1 | 100.8 | 95.0 | 165.8 | 178.4 | 2.53 | 0 | 236 | 100 |
| asyncfiles-io_uring | 401.5 | 100.4 | 146.4 | 165.6 | 179.5 | 2.62 | 0 | 237 | 100 |
| aiofile | 398.2 | 99.5 | 144.6 | 179.2 | 276.6 | 17.93 | 0 | 229 | 100 |
| anyio | 397.3 | 99.3 | 148.9 | 178.5 | 183.0 | 2.04 | 0 | 211 | 100 |
| aiofiles | 396.8 | 99.2 | 148.9 | 169.0 | 299.3 | 2.21 | 0 | 219 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 403.1 MB/s (100.8 ops/s)
- **p95 Latency**: 165.8 ms
- **CPU Time**: 2.53 s
- **Peak Memory**: 236 MB

## Performance Comparison

- **asyncfiles-io_uring**: about the same as asyncfiles-libuv
- **aiofile**: 1.01x slower than asyncfiles-libuv
- **anyio**: 1.01x slower than asyncfiles-libuv
- **aiofiles**: 1.02x slower than asyncfiles-libuv


---

# Benchmark Results: 4MB_x32_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 401.1 | 100.3 | 295.4 | 328.8 | 336.9 | 5.88 | 0 | 400 | 100 |
| asyncfiles-libuv | 400.2 | 100.1 | 172.6 | 313.6 | 333.7 | 5.49 | 0 | 393 | 100 |
| aiofiles | 397.3 | 99.3 | 297.8 | 327.6 | 341.3 | 4.14 | 0 | 345 | 100 |
| aiofile | 397.0 | 99.3 | 293.6 | 327.6 | 341.5 | 36.61 | 0 | 412 | 100 |
| anyio | 396.8 | 99.2 | 297.7 | 330.4 | 346.2 | 4.69 | 0 | 377 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 401.1 MB/s (100.3 ops/s)
- **p95 Latency**: 328.8 ms
- **CPU Time**: 5.88 s
- **Peak Memory**: 400 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as asyncfiles-io_uring
- **aiofiles**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.01x slower than asyncfiles-io_uring
- **anyio**: 1.01x slower than asyncfiles-io_uring


---

# Benchmark Results: 4MB_x64_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 400.9 | 100.2 | 584.5 | 639.4 | 688.6 | 11.78 | 0 | 701 | 100 |
| asyncfiles-libuv | 397.9 | 99.5 | 328.8 | 627.0 | 647.4 | 10.91 | 0 | 708 | 100 |
| aiofile | 397.0 | 99.3 | 591.4 | 639.7 | 649.9 | 73.60 | 0 | 699 | 100 |
| anyio | 396.9 | 99.2 | 425.5 | 651.2 | 656.3 | 9.69 | 0 | 549 | 100 |
| aiofiles | 396.8 | 99.2 | 615.9 | 644.6 | 647.7 | 8.93 | 0 | 521 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 400.9 MB/s (100.2 ops/s)
- **p95 Latency**: 639.4 ms
- **CPU Time**: 11.78 s
- **Peak Memory**: 701 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.01x slower than asyncfiles-io_uring
- **anyio**: 1.01x slower than asyncfiles-io_uring
- **aiofiles**: 1.01x slower than asyncfiles-io_uring


---

# Benchmark Results: 16MB_x1_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-libuv | 424.2 | 26.5 | 38.7 | 60.1 | 70.9 | 0.28 | 0 | 198 | 100 |
| asyncfiles-io_uring | 402.3 | 25.1 | 39.8 | 61.9 | 88.3 | 0.38 | 0 | 198 | 100 |
| anyio | 398.8 | 24.9 | 40.2 | 57.2 | 59.7 | 0.38 | 0 | 305 | 100 |
| aiofile | 397.0 | 24.8 | 39.8 | 59.7 | 61.1 | 4.19 | 0 | 307 | 100 |
| aiofiles | 396.7 | 24.8 | 40.7 | 58.9 | 61.1 | 0.31 | 0 | 307 | 100 |

## 🏆 Winner: **asyncfiles-libuv**

- **Throughput**: 424.2 MB/s (26.5 ops/s)
- **p95 Latency**: 60.1 ms
- **CPU Time**: 0.28 s
- **Peak Memory**: 198 MB

## Performance Comparison

- **asyncfiles-io_uring**: 1.05x slower than asyncfiles-libuv
- **anyio**: 1.06x slower than asyncfiles-libuv
- **aiofile**: 1.07x slower than asyncfiles-libuv
- **aiofiles**: 1.07x slower than asyncfiles-libuv


---

# Benchmark Results: 16MB_x8_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 399.3 | 25.0 | 310.1 | 339.2 | 344.1 | 4.12 | 0 | 529 | 100 |
| asyncfiles-libuv | 398.8 | 24.9 | 223.8 | 334.0 | 345.1 | 3.67 | 0 | 528 | 100 |
| aiofiles | 395.7 | 24.7 | 313.0 | 340.9 | 348.7 | 3.31 | 0 | 400 | 100 |
| anyio | 395.7 | 24.7 | 311.4 | 342.0 | 348.2 | 3.14 | 0 | 493 | 100 |
| aiofile | 395.6 | 24.7 | 307.7 | 342.0 | 347.2 | 34.59 | 0 | 529 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 399.3 MB/s (25.0 ops/s)
- **p95 Latency**: 339.2 ms
- **CPU Time**: 4.12 s
- **Peak Memory**: 529 MB

## Performance Comparison

- **asyncfiles-libuv**: about the same as asyncfiles-io_uring
- **aiofiles**: 1.01x slower than asyncfiles-io_uring
- **anyio**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.01x slower than asyncfiles-io_uring


---

# Benchmark Results: 16MB_x16_read

| Implementation | MB/s | ops/s | p50 (ms) | p95 (ms) | p99 (ms) | CPU (s) | CPU throttled | Peak Memory (MB) | Iterations |
|----------------|------|-------|----------|----------|----------|---------|---------------|------------------|------------|
| asyncfiles-io_uring | 398.8 | 24.9 | 613.7 | 650.4 | 654.0 | 7.97 | 0 | 874 | 100 |
| asyncfiles-libuv | 396.5 | 24.8 | 345.1 | 649.4 | 658.7 | 7.19 | 0 | 873 | 100 |
| aiofile | 395.5 | 24.7 | 613.2 | 655.8 | 658.7 | 68.88 | 0 | 891 | 100 |
| anyio | 395.4 | 24.7 | 620.5 | 656.5 | 658.5 | 5.87 | 0 | 687 | 100 |
| aiofiles | 394.4 | 24.6 | 616.1 | 656.7 | 770.5 | 6.15 | 0 | 760 | 100 |

## 🏆 Winner: **asyncfiles-io_uring**

- **Throughput**: 398.8 MB/s (24.9 ops/s)
- **p95 Latency**: 650.4 ms
- **CPU Time**: 7.97 s
- **Peak Memory**: 874 MB

## Performance Comparison

- **asyncfiles-libuv**: 1.01x slower than asyncfiles-io_uring
- **aiofile**: 1.01x slower than asyncfiles-io_uring
- **anyio**: 1.01x slower than asyncfiles-io_uring
- **aiofiles**: 1.01x slower than asyncfiles-io_uring
