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
| asyncfiles | 0.0017 | 0.0004 | 0.0028 | 0.57 | 0.0 | 0.0 | 89.6 | 96.5 | 100 |
| aiofiles | 0.0051 | 0.0016 | 0.0082 | 0.19 | 0.0 | 0.0 | 62.0 | 62.2 | 100 |
| anyio | 0.0058 | 0.0019 | 0.0090 | 0.17 | 0.0 | 0.0 | 62.3 | 62.3 | 100 |
| aiofile | 0.0077 | 0.0025 | 0.0163 | 0.13 | 0.0 | 0.0 | 70.0 | 78.4 | 100 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0017s
- **Throughput**: 0.57 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 89.6 MB

## Performance Comparison

- **aiofiles**: 2.99x slower than asyncfiles
- **anyio**: 3.41x slower than asyncfiles
- **aiofile**: 4.51x slower than asyncfiles


---

# Benchmark Results: medium_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| asyncfiles | 0.0058 | 0.0017 | 0.0147 | 171.68 | 0.0 | 0.0 | 94.6 | 99.4 | 100 |
| aiofiles | 0.0058 | 0.0028 | 0.0155 | 171.42 | 0.0 | 0.0 | 77.2 | 91.7 | 100 |
| anyio | 0.0070 | 0.0032 | 0.0152 | 142.47 | 0.0 | 0.0 | 75.5 | 75.5 | 100 |
| aiofile | 0.0100 | 0.0041 | 0.0217 | 100.11 | 0.0 | 0.0 | 110.9 | 115.5 | 100 |

## 🏆 Winner: **asyncfiles**

- **Average Time**: 0.0058s
- **Throughput**: 171.68 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 94.6 MB

## Performance Comparison

- **aiofiles**: 1.00x slower than asyncfiles
- **anyio**: 1.21x slower than asyncfiles
- **aiofile**: 1.72x slower than asyncfiles


---

# Benchmark Results: large_file_read

| Implementation | Avg Time (s) | Min Time (s) | Max Time (s) | MB/s | Avg CPU (%) | Max CPU (%) | Avg Memory (MB) | Max Memory (MB) | Iterations |
|----------------|--------------|--------------|--------------|------|-------------|-------------|-----------------|-----------------|------------|
| aiofile | 0.0135 | 0.0115 | 0.0254 | 371.04 | 0.0 | 0.0 | 177.9 | 181.7 | 100 |
| aiofiles | 0.0136 | 0.0103 | 0.0433 | 367.90 | 0.0 | 0.0 | 144.5 | 181.6 | 100 |
| asyncfiles | 0.0144 | 0.0063 | 0.0298 | 346.11 | 0.0 | 0.0 | 161.9 | 182.3 | 100 |
| anyio | 0.0206 | 0.0099 | 0.0394 | 242.31 | 0.0 | 0.0 | 87.6 | 107.2 | 100 |

## 🏆 Winner: **aiofile**

- **Average Time**: 0.0135s
- **Throughput**: 371.04 MB/s
- **Average CPU Usage**: 0.0%
- **Average Memory Usage**: 177.9 MB

## Performance Comparison

- **aiofiles**: 1.01x slower than aiofile
- **asyncfiles**: 1.07x slower than aiofile
- **anyio**: 1.53x slower than aiofile

