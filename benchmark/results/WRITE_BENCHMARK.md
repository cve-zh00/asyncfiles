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
| asyncfiles | 0.0045 | 0.0031 | 0.0054 | 0.22 | 0.0 | 0.0 | 69.6 | 70.3 | 20 |
| aiofiles | 0.0157 | 0.0109 | 0.0372 | 0.06 | 0.0 | 0.0 | 72.1 | 72.1 | 20 |
| anyio | 0.0157 | 0.0101 | 0.0200 | 0.06 | 0.0 | 0.0 | 74.2 | 74.4 | 20 |
| aiofile | 0.0227 | 0.0114 | 0.0766 | 0.04 | 0.0 | 0.0 | 71.7 | 71.9 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0045s
- **Throughput**: 0.22 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 69.6 MB

## Performance Comparison

- **aiofiles**: 3.51x slower than asyncfiles
- **anyio**: 3.51x slower than asyncfiles
- **aiofile**: 5.07x slower than asyncfiles


---

# Benchmark Results: large_file_write

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0188 | 0.0145 | 0.0288 | 53.26 | 0.0 | 0.0 | 474.2 | 651.2 | 20 |
| aiofiles | 0.0262 | 0.0175 | 0.1043 | 38.15 | 0.8 | 32.1 | 620.7 | 627.6 | 20 |
| aiofile | 0.0422 | 0.0225 | 0.2094 | 23.67 | 1.1 | 61.7 | 650.6 | 663.6 | 20 |
| anyio | 0.0532 | 0.0236 | 0.1847 | 18.80 | 2.6 | 58.8 | 616.0 | 620.7 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0188s
- **Throughput**: 53.26 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 474.2 MB

## Performance Comparison

- **aiofiles**: 1.40x slower than asyncfiles
- **aiofile**: 2.25x slower than asyncfiles
- **anyio**: 2.83x slower than asyncfiles

