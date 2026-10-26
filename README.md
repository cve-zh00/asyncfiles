# asyncfiles

[![Python Versions](https://img.shields.io/badge/python-3.9%2B-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Tests](https://github.com/cve-zh00/asyncfiles/actions/workflows/tests.yml/badge.svg)](https://github.com/cve-zh00/asyncfiles/actions/workflows/tests.yml)
[![Release](https://github.com/cve-zh00/asyncfiles/actions/workflows/release.yml/badge.svg)](https://github.com/cve-zh00/asyncfiles/actions/workflows/release.yml)
[![PyPI](https://img.shields.io/pypi/v/py-asyncfiles.svg)](https://pypi.org/project/py-asyncfiles/)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-fe5196.svg)](https://www.conventionalcommits.org/)

**asyncfiles** is a high-performance async file I/O library for Python, built using Cython on two backends: native **io_uring** (Linux 5.6+) and [libuv](https://libuv.org/) (Linux, macOS, BSD). File operations never block the asyncio event loop. On Linux the `io_uring` backend submits I/O to the kernel without any thread pool; the `libuv` backend runs operations on libuv's own C thread pool (see [How it works](#-how-it-works)), which avoids the Python-level `run_in_executor` overhead of typical thread-pool wrappers.

## 🚀 Features

- **Two backends**: native `io_uring` on Linux (auto-selected when available) and `libuv` everywhere else
- **Non-blocking I/O**: `io_uring` is kernel-level async I/O with no thread pool; `libuv` offloads to its internal C thread pool (POSIX has no portable async file API)
- **High Performance**: Cython-optimized with zero-copy buffer operations, batched submissions and parallel chunked I/O for large files
- **Cancellation-safe**: cancelling an in-flight read/write never frees a buffer the kernel is still using
- **Simple API**: Familiar async context manager interface
- **Type Hints**: Full typing support for better IDE integration
- **Memory Efficient**: Configurable buffer sizes for optimal memory usage

## 🧠 How it works

| Backend | Platform | Mechanism | Threads |
|---------|----------|-----------|---------|
| `io_uring` | Linux 5.6+ | Submission/completion rings shared with the kernel | None for reads/writes (only `ftruncate` falls back to a thread on kernels < 6.9) |
| `libuv` | Linux, macOS, BSD | `uv_fs_*` requests | libuv's thread pool (4 threads by default, tune with `UV_THREADPOOL_SIZE`) |

Regular files do not support readiness-based polling (`epoll` always reports them ready), so
on most platforms "async file I/O" means offloading blocking syscalls to threads. asyncfiles
does that in C/Cython and completes the `asyncio` futures directly (the `libuv` backend polls
its loop once per asyncio iteration; `io_uring` is woken through an `eventfd`) instead of going
through Python's `run_in_executor`. `io_uring` is the only path that avoids threads entirely.

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

Benchmarks run in a single Docker container limited to 2 CPUs / 1GB RAM (binary
mode, cold page cache for reads) against `aiofiles`, `aiofile` and `anyio`. Every
scenario (file size × concurrency) is reported with throughput, latency
percentiles, CPU time and peak memory, plus a winner and a "Nx slower" comparison:

- [Read benchmark results](benchmark/results/benchmark_read.md)
- [Write benchmark results](benchmark/results/benchmark_write.md)

Scenarios won (highest throughput, 8 per operation, latest run):

| Implementation | Read | Write |
|---|---|---|
| asyncfiles (io_uring) | 3 | 4 |
| asyncfiles (libuv) | 1 | 2 |
| aiofiles | 3 | 0 |
| anyio | 1 | 2 |
| aiofile | 0 | 0 |

asyncfiles is strongest on many small files with concurrency and on writes;
`aiofiles` and `anyio` still lead some large concurrent reads. Numbers come from a
single container run and are partly served by the page cache, so treat them as
relative, not absolute. The reports are refreshed automatically on every release.

### Run the benchmark yourself

```bash
scripts/run_docker_benchmark.sh
# optional disk throttling: IO_DEVICE=/dev/vda IO_READ_BPS=50mb IO_WRITE_BPS=30mb
```

Sizes are 4KB/1MB/16MB with concurrency 1/8/32. Scenarios whose working set
exceeds 50% of the memory limit are skipped, and each cell has a timeout
(`--timeout`, default 120s) so a hung implementation cannot stall the whole run.

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
