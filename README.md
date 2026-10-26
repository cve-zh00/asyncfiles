# asyncfiles

[![Python Versions](https://img.shields.io/badge/python-3.9%2B-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Tests](https://github.com/cve-zh00/asyncfiles/actions/workflows/tests.yml/badge.svg)](https://github.com/cve-zh00/asyncfiles/actions/workflows/tests.yml)
[![Release](https://github.com/cve-zh00/asyncfiles/actions/workflows/release.yml/badge.svg)](https://github.com/cve-zh00/asyncfiles/actions/workflows/release.yml)
[![PyPI](https://img.shields.io/pypi/v/py-asyncfiles.svg)](https://pypi.org/project/py-asyncfiles/)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-fe5196.svg)](https://www.conventionalcommits.org/)

**asyncfiles** is a high-performance async file I/O library for Python, built using Cython on two backends: native **io_uring** (Linux 5.6+) and [libuv](https://libuv.org/) (Linux, macOS, BSD). It provides non-blocking file operations with efficient event-loop integration and improved performance compared to typical Python thread-pool wrappers.

## 🚀 Features

- **Two backends**: native `io_uring` on Linux (auto-selected when available) and `libuv` everywhere else
- **True Async I/O**: Built directly on io_uring / libuv async filesystem operations
- **High Performance**: Cython-optimized with zero-copy buffer operations, batched submissions and parallel chunked I/O for large files
- **Cancellation-safe**: cancelling an in-flight read/write never frees a buffer the kernel is still using
- **Simple API**: Familiar async context manager interface
- **Type Hints**: Full typing support for better IDE integration
- **Memory Efficient**: Configurable buffer sizes for optimal memory usage

## 📦 Installation

### From PyPI

```bash
pip3 install py-asyncfiles
```

### Requirements

- Python 3.9 or higher
- Cython ~3.0
- A C compiler (gcc, clang, or MSVC)
- libuv and liburing (included as submodules)
- POSIX only (Linux, macOS, BSD). Windows is not supported


## 🔥 Quick Start

```python
import asyncio
from asyncfiles import open

async def main():
    # Read a file
    async with open('example.txt', 'r') as f:
        content = await f.read()
        print(content)

    # Write to a file
    async with open('output.txt', 'w') as f:
        await f.write('Hello, async world!')

asyncio.run(main())
```

## 📖 Usage Examples

### Reading Files

```python
import asyncio
from asyncfiles import open

async def read_file():
    # Read entire file
    async with open('data.txt', 'r') as f:
        content = await f.read()
        return content

asyncio.run(read_file())
```

### Writing Files

```python
import asyncio
from asyncfiles import open

async def write_file():
    async with open('output.txt', 'w') as f:
        await f.write('Line 1\n')
        await f.write('Line 2\n')
        await f.write('Line 3\n')

asyncio.run(write_file())
```

### Custom Buffer Size

```python
import asyncio
from asyncfiles import open

async def large_file():
    # Use 1MB buffer for large files
    async with open('large_file.bin', 'r', buffer_size=1024*1024) as f:
        data = await f.read()
        return data

asyncio.run(large_file())
```

### Choosing a Backend

```python
import asyncio
from asyncfiles import open

async def main():
    # "auto" (default): io_uring on Linux when the kernel allows it, else libuv
    async with open('data.bin', 'rb', backend='io_uring') as f:
        data = await f.read()

    async with open('data.bin', 'rb', backend='libuv') as f:
        data = await f.read()

asyncio.run(main())
```

`io_uring` requires Linux 5.6+. Inside Docker it also needs
`--security-opt seccomp=unconfined`, since the default seccomp profile blocks it.
Operations not supported by the running kernel (e.g. `ftruncate` on kernels < 6.9)
transparently fall back to a thread.

### Multiple Concurrent Operations

```python
import asyncio
from asyncfiles import open

async def process_files():
    # Read multiple files concurrently
    async def read_file(path):
        async with open(path, 'r') as f:
            return await f.read()

    results = await asyncio.gather(
        read_file('file1.txt'),
        read_file('file2.txt'),
        read_file('file3.txt'),
    )

    return results

asyncio.run(process_files())
```

## 🎯 Supported File Modes

| Mode | Description |
|------|-------------|
| `'r'` | Read text (default) |
| `'w'` | Write text (truncate) |
| `'a'` | Append text |
| `'x'` | Exclusive creation |
| `'r+'` | Read and write |
| `'w+'` | Write and read (truncate) |
| `'a+'` | Append and read |

Additional modifiers:
- `'b'`: Binary mode
- `'t'`: Text mode (default)

## ⚡ Performance

Throughput (MB/s) in a Docker container with 2 CPUs / 1GB RAM, binary mode, cold
page cache. Best result per row in **bold**; `af-*` is asyncfiles with that backend.

| Op | Size | Conc | aiofile | aiofiles | anyio | af-io_uring | af-libuv |
|---|---|---|---|---|---|---|---|
| read | 4KB | 1 | 12 | 12 | 27 | **29** | 19 |
| write | 4KB | 1 | 6 | 13 | **27** | 24 | 22 |
| read | 4KB | 8 | 38 | 23 | 15 | **152** | 65 |
| write | 4KB | 8 | 18 | 24 | 53 | **133** | 116 |
| read | 4KB | 32 | 32 | 36 | 27 | **251** | 140 |
| write | 4KB | 32 | 39 | 37 | 54 | **209** | 167 |
| read | 1MB | 1 | 1486 | 1672 | 3099 | **3416** | 1761 |
| write | 1MB | 1 | 907 | 2082 | **3602** | 2833 | 2796 |
| read | 1MB | 8 | 2762 | 5172 | 4360 | 3926 | **5402** |
| write | 1MB | 8 | 1858 | 5208 | 4018 | **7227** | 5060 |
| read | 1MB | 32 | 4163 | **5386** | 2853 | 2999 | 5069 |
| write | 1MB | 32 | 2566 | 4891 | 3455 | 6499 | **6758** |
| read | 16MB | 1 | 4514 | 4754 | **6169** | 4980 | 4835 |
| write | 16MB | 1 | 2264 | 3680 | 3750 | **3837** | 3629 |
| read | 16MB | 8 | 5453 | **9461** | 7445 | 3679 | 6633 |
| write | 16MB | 8 | 3574 | 6010 | 5931 | **7609** | 7528 |

asyncfiles is fastest in 11 of 16 cells in this profile (10 of 14 and 10 of 16 in
the 0.5 CPU / 256MB and 1 CPU / 512MB profiles). It is strongest on many small files
with concurrency (up to ~7x on 4KB reads) and on writes; `aiofiles` and `anyio`
still lead on some concurrent large reads. Numbers come from a single container run
and are partly served by the page cache, so treat them as relative, not absolute.
Full results for every profile (latency percentiles, CPU time, throttling, peak
memory) are in [`benchmark/results/docker/`](benchmark/results/docker/) and are
refreshed automatically on every release.

Older, non-containerised reports:

- [Read Benchmark Results](benchmark/results/READ_BENCHMARK.md)
- [Write Benchmark Results](benchmark/results/WRITE_BENCHMARK.md)

### Run the benchmarks yourself

```bash
python -m benchmark.benchmark_read
python -m benchmark.benchmark_write
```

Resource-limited Docker benchmark (reads and writes, binary, 4KB/1MB/16MB,
concurrency 1/8/32, cold page cache) against `aiofiles`, `aiofile` and `anyio`.
Profiles: `tiny` = 0.5 CPU/256MB, `small` = 1 CPU/512MB, `medium` = 2 CPU/1GB.

```bash
scripts/run_docker_benchmark.sh tiny small medium
# optional disk throttling: IO_DEVICE=/dev/vda IO_READ_BPS=50mb IO_WRITE_BPS=30mb
```

Cells whose working set exceeds 50% of the memory limit are skipped, and each
cell has a timeout (`--timeout`, default 120s) so a hung implementation cannot
stall the whole run.

## 🛠️ Development

### Building from Source

```bash
# Clean build
make clean

# Compile with optimizations
make compile

# Debug build with line tracing
make debug

# Run tests (the suite runs against both libuv and io_uring when available)
make test
```

### Running Tests

```bash
# Run all tests
make test

# Run with async debug mode
PYTHONASYNCIODEBUG=1 python -m pytest tests/ -v

# Test installed package
make testinstalled
```

### Releases

Releases are fully automated with [python-semantic-release](https://python-semantic-release.readthedocs.io/).
Merging Conventional Commits into `main` (`feat:` → minor, `fix:`/`perf:`/`refactor:` → patch,
`!` or `BREAKING CHANGE:` → major) runs the tests, bumps the version, updates `CHANGELOG.md`,
tags `vX.Y.Z`, builds wheels/sdist, publishes to PyPI and refreshes the Docker benchmark results.
See [CONTRIBUTING.md](CONTRIBUTING.md).

### Code Style

- Follow PEP 8 for Python code
- Use type hints where applicable
- Add docstrings for public APIs
- Keep Cython code clean and well-commented

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

This project is heavily inspired by [uvloop](https://github.com/MagicStack/uvloop), which pioneered the use of libuv in Python's async ecosystem. The build system, Cython integration patterns, and overall architecture follow uvloop's excellent design.

Special thanks to:
- **uvloop** team for showing how to properly integrate libuv with Python
- **libuv** project for the excellent async I/O library
- **Cython** team for making high-performance Python extensions possible

## 🔗 Related Projects

- [uvloop](https://github.com/MagicStack/uvloop) - Ultra fast asyncio event loop
- [aiofiles](https://github.com/Tinche/aiofiles) - Thread-based async file I/O
- [aiofile](https://github.com/mosquito/aiofile) - Another async file library
- [libuv](https://github.com/libuv/libuv) - Cross-platform async I/O

## 📊 Status

**Current Status**: Experimental / In Development

This project is currently in active development. The API may change. Production use is not recommended yet.

### Roadmap
- [x] Iteration support
- [X] Comprehensive test suite
- [] Complete documentation
- [x] Binary mode support
- [x] Seek/tell operations
- [x] File metadata operations
- [x] PyPI package release
- [x] CI/CD pipeline
- [x] Performance optimizations
- [x] More comprehensive benchmarks
- [x] Integration with io_uring

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/cve-zh00/asyncfiles/issues)
---

**Made with ❤️ and ⚡ by Zh00**
