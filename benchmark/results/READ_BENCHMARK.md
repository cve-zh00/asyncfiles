# Read Benchmark Results

This document contains the benchmark results for read operations using different async file I/O libraries.

## Test Configuration

- **Iterations**: 20
- **Concurrency**: 10
- **Libraries Tested**: asyncfiles, aiofile, aiofiles, anyio


---

# Benchmark Results: small_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0015 | 0.0005 | 0.0032 | 0.63 | 0.0 | 0.0 | 86.1 | 106.5 | 100 |
| aiofiles | 0.0047 | 0.0017 | 0.0081 | 0.21 | 0.0 | 0.0 | 74.9 | 82.5 | 100 |
| anyio | 0.0064 | 0.0020 | 0.0130 | 0.15 | 0.0 | 0.0 | 62.0 | 63.2 | 100 |
| aiofile | 0.0075 | 0.0023 | 0.0134 | 0.13 | 0.0 | 0.0 | 82.4 | 82.5 | 100 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0015s
- **Throughput**: 0.63 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 86.1 MB

## Performance Comparison

- **aiofiles**: 3.01x slower than asyncfiles
- **anyio**: 4.17x slower than asyncfiles
- **aiofile**: 4.87x slower than asyncfiles


---

# Benchmark Results: medium_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0046 | 0.0016 | 0.0073 | 215.54 | 0.0 | 0.0 | 85.7 | 87.5 | 100 |
| aiofiles | 0.0069 | 0.0030 | 0.0113 | 145.23 | 0.0 | 0.0 | 101.4 | 109.3 | 100 |
| aiofile | 0.0080 | 0.0039 | 0.0159 | 124.27 | 0.0 | 0.0 | 106.8 | 109.3 | 100 |
| anyio | 0.0089 | 0.0032 | 0.0296 | 112.50 | 0.0 | 0.0 | 60.9 | 90.9 | 100 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0046s
- **Throughput**: 215.54 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 85.7 MB

## Performance Comparison

- **aiofiles**: 1.48x slower than asyncfiles
- **aiofile**: 1.73x slower than asyncfiles
- **anyio**: 1.92x slower than asyncfiles


---

# Benchmark Results: large_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| anyio | 0.0111 | 0.0090 | 0.0223 | 452.18 | 0.0 | 0.0 | 98.2 | 100.6 | 100 |
| asyncfiles | 0.0126 | 0.0065 | 0.0183 | 395.70 | 0.0 | 0.0 | 117.1 | 118.0 | 100 |
| aiofiles | 0.0129 | 0.0088 | 0.0209 | 387.62 | 0.0 | 0.0 | 110.9 | 135.5 | 100 |
| aiofile | 0.0146 | 0.0101 | 0.0350 | 342.71 | 0.0 | 0.0 | 155.2 | 160.4 | 100 |

## 🏆 Winner: **anyio**

- **Average Time**: 0.0111s
- **Throughput**: 452.18 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 98.2 MB

## Performance Comparison

- **asyncfiles**: 1.14x slower than anyio
- **aiofiles**: 1.17x slower than anyio
- **aiofile**: 1.32x slower than anyio

