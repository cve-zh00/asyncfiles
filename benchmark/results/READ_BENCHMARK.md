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
| asyncfiles | 0.0011 | 0.0006 | 0.0024 | 0.86 | 0.0 | 0.0 | 105.3 | 106.5 | 20 |
| aiofiles | 0.0044 | 0.0017 | 0.0065 | 0.22 | 0.0 | 0.0 | 71.7 | 71.9 | 20 |
| anyio | 0.0057 | 0.0023 | 0.0091 | 0.17 | 0.0 | 0.0 | 68.7 | 72.0 | 20 |
| aiofile | 0.0077 | 0.0026 | 0.0123 | 0.13 | 0.0 | 0.0 | 86.4 | 101.9 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0011s
- **Throughput**: 0.86 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 105.3 MB

## Performance Comparison

- **aiofiles**: 3.91x slower than asyncfiles
- **anyio**: 5.03x slower than asyncfiles
- **aiofile**: 6.77x slower than asyncfiles


---

# Benchmark Results: medium_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0050 | 0.0023 | 0.0077 | 200.42 | 0.0 | 0.0 | 86.9 | 92.0 | 20 |
| anyio | 0.0070 | 0.0037 | 0.0120 | 143.48 | 0.0 | 0.0 | 107.2 | 107.2 | 20 |
| aiofiles | 0.0090 | 0.0032 | 0.0162 | 111.14 | 0.0 | 0.0 | 107.2 | 107.2 | 20 |
| aiofile | 0.0108 | 0.0041 | 0.0180 | 92.94 | 0.0 | 0.0 | 102.5 | 107.2 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0050s
- **Throughput**: 200.42 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 86.9 MB

## Performance Comparison

- **anyio**: 1.40x slower than asyncfiles
- **aiofiles**: 1.80x slower than asyncfiles
- **aiofile**: 2.16x slower than asyncfiles


---

# Benchmark Results: large_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0138 | 0.0089 | 0.0381 | 362.18 | 0.0 | 0.0 | 197.5 | 204.3 | 20 |
| aiofile | 0.0193 | 0.0120 | 0.0276 | 259.48 | 0.0 | 0.0 | 196.6 | 208.4 | 20 |
| anyio | 0.0201 | 0.0117 | 0.0356 | 249.03 | 0.0 | 0.0 | 179.9 | 183.0 | 20 |
| aiofiles | 0.0219 | 0.0121 | 0.0283 | 228.59 | 0.0 | 0.0 | 188.2 | 193.0 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0138s
- **Throughput**: 362.18 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 197.5 MB

## Performance Comparison

- **aiofile**: 1.40x slower than asyncfiles
- **anyio**: 1.45x slower than asyncfiles
- **aiofiles**: 1.58x slower than asyncfiles

