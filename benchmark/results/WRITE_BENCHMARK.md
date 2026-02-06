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
| asyncfiles | 0.0041 | 0.0010 | 0.0336 | 0.24 | 0.0 | 0.0 | 69.1 | 69.4 | 20 |
| anyio | 0.0047 | 0.0024 | 0.0089 | 0.21 | 0.0 | 0.0 | 71.3 | 71.4 | 20 |
| aiofile | 0.0056 | 0.0020 | 0.0089 | 0.17 | 0.0 | 0.0 | 70.3 | 70.4 | 20 |
| aiofiles | 0.0056 | 0.0026 | 0.0082 | 0.17 | 0.0 | 0.0 | 70.5 | 70.5 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0041s
- **Throughput**: 0.24 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 69.1 MB

## Performance Comparison

- **anyio**: 1.15x slower than asyncfiles
- **aiofile**: 1.38x slower than asyncfiles
- **aiofiles**: 1.38x slower than asyncfiles


---

# Benchmark Results: medium_file_write

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| aiofiles | 0.0080 | 0.0025 | 0.0151 | 125.43 | 0.0 | 0.0 | 164.7 | 164.8 | 20 |
| anyio | 0.0082 | 0.0025 | 0.0168 | 121.48 | 0.0 | 0.0 | 164.8 | 164.8 | 20 |
| asyncfiles | 0.0100 | 0.0023 | 0.0166 | 99.68 | 0.0 | 0.0 | 114.2 | 133.8 | 20 |
| aiofile | 0.0125 | 0.0036 | 0.0310 | 80.26 | 0.0 | 0.0 | 152.7 | 164.6 | 20 |

## 🏆 Winner: **aiofiles**

- **Average Time**: 0.0080s
- **Throughput**: 125.43 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 164.7 MB

## Performance Comparison

- **anyio**: 1.03x slower than aiofiles
- **asyncfiles**: 1.26x slower than aiofiles
- **aiofile**: 1.56x slower than aiofiles


---

# Benchmark Results: large_file_write

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0215 | 0.0141 | 0.0299 | 464.09 | 0.0 | 0.0 | 270.1 | 275.3 | 20 |
| aiofile | 0.0230 | 0.0162 | 0.0305 | 435.12 | 0.0 | 0.0 | 275.4 | 275.4 | 20 |
| aiofiles | 0.0250 | 0.0166 | 0.0381 | 400.44 | 0.0 | 0.0 | 275.4 | 275.4 | 20 |
| anyio | 0.0253 | 0.0171 | 0.0316 | 394.86 | 0.0 | 0.0 | 275.4 | 275.4 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0215s
- **Throughput**: 464.09 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 270.1 MB

## Performance Comparison

- **aiofile**: 1.07x slower than asyncfiles
- **aiofiles**: 1.16x slower than asyncfiles
- **anyio**: 1.18x slower than asyncfiles

