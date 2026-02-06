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
| asyncfiles | 0.0010 | 0.0006 | 0.0020 | 1.00 | 0.0 | 0.0 | 114.0 | 114.1 | 20 |
| aiofiles | 0.0030 | 0.0013 | 0.0055 | 0.33 | 0.0 | 0.0 | 114.7 | 114.7 | 20 |
| aiofile | 0.0044 | 0.0019 | 0.0070 | 0.22 | 0.0 | 0.0 | 114.7 | 114.7 | 20 |
| anyio | 0.0046 | 0.0026 | 0.0076 | 0.21 | 0.0 | 0.0 | 115.0 | 115.1 | 20 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0010s
- **Throughput**: 1.00 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 114.0 MB

## Performance Comparison

- **aiofiles**: 3.09x slower than asyncfiles
- **aiofile**: 4.57x slower than asyncfiles
- **anyio**: 4.71x slower than asyncfiles


---

# Benchmark Results: medium_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| aiofiles | 0.0043 | 0.0032 | 0.0051 | 233.67 | 0.0 | 0.0 | 226.9 | 226.9 | 20 |
| anyio | 0.0046 | 0.0039 | 0.0052 | 219.68 | 0.0 | 0.0 | 226.9 | 226.9 | 20 |
| aiofile | 0.0062 | 0.0054 | 0.0076 | 160.77 | 0.0 | 0.0 | 221.5 | 226.9 | 20 |
| asyncfiles | 0.0067 | 0.0032 | 0.0091 | 148.64 | 0.0 | 0.0 | 176.5 | 204.4 | 20 |

## 🏆 Winner: **aiofiles**

- **Average Time**: 0.0043s
- **Throughput**: 233.67 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 226.9 MB

## Performance Comparison

- **anyio**: 1.06x slower than aiofiles
- **aiofile**: 1.45x slower than aiofiles
- **asyncfiles**: 1.57x slower than aiofiles


---

# Benchmark Results: large_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| aiofiles | 0.0201 | 0.0167 | 0.0236 | 248.29 | 0.0 | 0.0 | 580.0 | 583.2 | 20 |
| anyio | 0.0225 | 0.0185 | 0.0265 | 222.17 | 0.0 | 0.0 | 583.2 | 583.2 | 20 |
| asyncfiles | 0.0231 | 0.0171 | 0.0352 | 216.04 | 0.0 | 0.0 | 440.2 | 518.1 | 20 |
| aiofile | 0.0305 | 0.0262 | 0.0383 | 163.90 | 0.0 | 0.0 | 536.2 | 548.2 | 20 |

## 🏆 Winner: **aiofiles**

- **Average Time**: 0.0201s
- **Throughput**: 248.29 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 580.0 MB

## Performance Comparison

- **anyio**: 1.12x slower than aiofiles
- **asyncfiles**: 1.15x slower than aiofiles
- **aiofile**: 1.51x slower than aiofiles

