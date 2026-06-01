# Write Benchmark Results

This document contains the benchmark results for write operations using different async file I/O libraries.

## Test Configuration

- **Iterations**: 20
- **Concurrency**: 10
- **Libraries Tested**: asyncfiles, aiofile, aiofiles, anyio


---

# Benchmark Results: small_file_write

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0063 | 0.0029 | 0.0113 | 0.16 | 0.0 | 0.0 | 68.2 | 69.3 | 20 |
| aiofiles | 0.0233 | 0.0106 | 0.0999 | 0.04 | 0.0 | 0.0 | 70.9 | 71.0 | 20 |
| aiofile | 0.0263 | 0.0183 | 0.0417 | 0.04 | 0.0 | 0.0 | 70.5 | 70.7 | 20 |
| anyio | 0.0490 | 0.0179 | 0.3148 | 0.02 | 1.8 | 34.3 | 72.7 | 72.9 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0063s
- **Throughput**: 0.16 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 68.2 MB

## Performance Comparison

- **aiofiles**: 3.71x slower than asyncfiles
- **aiofile**: 4.19x slower than asyncfiles
- **anyio**: 7.80x slower than asyncfiles


---

# Benchmark Results: large_file_write

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0242 | 0.0164 | 0.0383 | 41.40 | 0.0 | 0.0 | 469.7 | 679.7 | 20 |
| aiofiles | 0.0255 | 0.0176 | 0.0401 | 39.26 | 0.0 | 0.0 | 706.7 | 706.7 | 20 |
| aiofile | 0.0303 | 0.0228 | 0.0510 | 32.97 | 0.0 | 0.0 | 706.5 | 706.6 | 20 |
| anyio | 0.0325 | 0.0286 | 0.0576 | 30.76 | 0.0 | 0.0 | 706.7 | 706.9 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0242s
- **Throughput**: 41.40 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 469.7 MB

## Performance Comparison

- **aiofiles**: 1.05x slower than asyncfiles
- **aiofile**: 1.26x slower than asyncfiles
- **anyio**: 1.35x slower than asyncfiles

