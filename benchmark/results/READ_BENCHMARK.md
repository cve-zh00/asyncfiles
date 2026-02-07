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
| asyncfiles | 0.0014 | 0.0006 | 0.0023 | 0.72 | 0.0 | 0.0 | 133.3 | 133.4 | 20 |
| aiofiles | 0.0027 | 0.0019 | 0.0034 | 0.36 | 0.0 | 0.0 | 134.0 | 134.0 | 20 |
| anyio | 0.0034 | 0.0018 | 0.0046 | 0.29 | 0.0 | 0.0 | 134.4 | 134.4 | 20 |
| aiofile | 0.0038 | 0.0019 | 0.0067 | 0.26 | 0.0 | 0.0 | 134.0 | 134.0 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0014s
- **Throughput**: 0.72 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 133.3 MB

## Performance Comparison

- **aiofiles**: 2.00x slower than asyncfiles
- **anyio**: 2.47x slower than asyncfiles
- **aiofile**: 2.78x slower than asyncfiles


---

# Benchmark Results: medium_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0054 | 0.0036 | 0.0079 | 184.20 | 0.0 | 0.0 | 180.8 | 201.6 | 20 |
| aiofiles | 0.0060 | 0.0038 | 0.0070 | 167.02 | 0.0 | 0.0 | 207.9 | 207.9 | 20 |
| anyio | 0.0068 | 0.0040 | 0.0085 | 147.15 | 0.0 | 0.0 | 208.9 | 208.9 | 20 |
| aiofile | 0.0084 | 0.0063 | 0.0106 | 118.93 | 0.0 | 0.0 | 204.3 | 207.9 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0054s
- **Throughput**: 184.20 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 180.8 MB

## Performance Comparison

- **aiofiles**: 1.10x slower than asyncfiles
- **anyio**: 1.25x slower than asyncfiles
- **aiofile**: 1.55x slower than asyncfiles


---

# Benchmark Results: large_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0210 | 0.0180 | 0.0235 | 238.10 | 0.0 | 0.0 | 406.1 | 475.0 | 20 |
| aiofiles | 0.0210 | 0.0175 | 0.0240 | 237.82 | 0.0 | 0.0 | 568.1 | 575.3 | 20 |
| anyio | 0.0215 | 0.0188 | 0.0259 | 232.35 | 0.0 | 0.0 | 575.3 | 575.3 | 20 |
| aiofile | 0.0326 | 0.0286 | 0.0364 | 153.52 | 0.0 | 0.0 | 525.4 | 560.3 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0210s
- **Throughput**: 238.10 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 406.1 MB

## Performance Comparison

- **aiofiles**: 1.00x slower than asyncfiles
- **anyio**: 1.02x slower than asyncfiles
- **aiofile**: 1.55x slower than asyncfiles

