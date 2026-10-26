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
| asyncfiles | 0.0205 | 0.0076 | 0.0427 | 0.05 | 0.0 | 0.0 | 74.1 | 74.6 | 20 |
| aiofiles | 0.0233 | 0.0138 | 0.0415 | 0.04 | 0.0 | 0.0 | 70.6 | 76.2 | 20 |
| anyio | 0.0242 | 0.0161 | 0.0448 | 0.04 | 0.0 | 0.0 | 68.1 | 72.8 | 20 |
| aiofile | 0.0268 | 0.0145 | 0.0532 | 0.04 | 0.0 | 0.0 | 76.1 | 76.2 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0205s
- **Throughput**: 0.05 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 74.1 MB

## Performance Comparison

- **aiofiles**: 1.14x slower than asyncfiles
- **anyio**: 1.18x slower than asyncfiles
- **aiofile**: 1.30x slower than asyncfiles


---

# Benchmark Results: large_file_write

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| aiofiles | 0.0214 | 0.0139 | 0.0287 | 46.68 | 0.0 | 0.0 | 197.6 | 197.6 | 20 |
| asyncfiles | 0.0271 | 0.0163 | 0.0654 | 36.91 | 0.0 | 0.0 | 187.5 | 197.2 | 20 |
| anyio | 0.0302 | 0.0195 | 0.0956 | 33.14 | 0.0 | 0.0 | 197.6 | 197.6 | 20 |
| aiofile | 0.0354 | 0.0235 | 0.0772 | 28.26 | 0.0 | 0.0 | 197.5 | 197.5 | 20 |

## 🏆 Winner: **aiofiles**

- **Average Time**: 0.0214s
- **Throughput**: 46.68 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 197.6 MB

## Performance Comparison

- **asyncfiles**: 1.26x slower than aiofiles
- **anyio**: 1.41x slower than aiofiles
- **aiofile**: 1.65x slower than aiofiles

