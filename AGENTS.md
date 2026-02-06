# AGENTS.md

**Agent guide for working in the asyncfiles codebase**

This document provides essential context for AI agents working in this repository. It covers commands, code organization, conventions, and gotchas.

---

## Project Overview

**asyncfiles** is a high-performance async file I/O library for Python, built on libuv using Cython. It provides true asynchronous file operations without blocking the event loop.

- **Language**: Python 3.8+ with Cython 3.0 extensions
- **Architecture**: Cython-compiled C extensions wrapping libuv's async filesystem operations
- **Current Status**: Alpha/experimental (v1.1.3) - API may change
- **Platform Support**: POSIX only (Linux, macOS, BSD) - **NO Windows support**

---

## Essential Commands

### Building and Compilation

```bash
# Clean all build artifacts and compiled files
make clean

# Full compile (clean + build extensions in place)
make compile

# Debug build with line tracing and annotations
make debug

# Clean libuv vendor files
make clean-libuv

# Nuclear option - clean everything including libuv build
make distclean

# Direct build (used by make compile)
python setup.py build_ext --inplace --cython-always
```

**Build requirements:**
- Cython ~3.0
- C compiler (gcc/clang)
- autoconf, automake, libtool (for libuv)
- libuv (included as git submodule in `vendor/libuv/`)

**Important**: The build system automatically:
1. Checks out libuv submodule if missing
2. Runs libuv's `autogen.sh` and `configure`
3. Compiles libuv from source (unless `--use-system-libuv` is passed)
4. Links the static libuv into each Cython extension

### Testing

```bash
# Run full test suite (runs twice: with and without PYTHONASYNCIODEBUG)
make test

# Run tests manually with async debug mode
PYTHONASYNCIODEBUG=1 python -m unittest discover -v tests

# Run tests without debug mode
python -m unittest discover -v tests

# Test installed package (from outside project dir)
make testinstalled

# Run pytest directly (recommended for development)
pytest tests/ -v

# Run specific test file
pytest tests/test_files.py -v

# Run with coverage
pytest --cov=asyncfiles --cov-report=term-missing tests/
```

### Benchmarks

```bash
# Run read benchmarks
python -m benchmark.benchmark_read

# Run write benchmarks
python -m benchmark.benchmark_write

# Run readlines benchmarks
python -m benchmark.benchmark_readlines

# Initial benchmarks
python -m benchmark.benchmark_initial
```

### Code Quality (from pyproject.toml)

```bash
# Format code
black asyncfiles/ tests/
isort asyncfiles/ tests/

# Check formatting without changes
black --check asyncfiles/ tests/
isort --check-only asyncfiles/ tests/

# Type checking (mypy configured but errors ignored for asyncfiles module)
mypy asyncfiles/ tests/ --ignore-missing-imports

# Linting
flake8 asyncfiles/ tests/
```

### Using Tox (multi-environment testing)

```bash
# Run tests on all Python versions
tox

# Run specific environment
tox -e py311
tox -e lint
tox -e coverage
tox -e type

# Format code
tox -e format

# Build package
tox -e build

# Clean build artifacts
tox -e clean
```

---

## Code Organization

### Directory Structure

```
asyncfiles/
├── asyncfiles/          # Main package (Cython extensions)
│   ├── __init__.py      # Public API: open() function
│   ├── __init__.pyi     # Type stubs
│   ├── types.py         # Python type definitions
│   ├── py.typed         # PEP 561 marker for type hints
│   │
│   ├── *.pyx            # Cython implementation files
│   ├── *.pxd            # Cython header/declaration files
│   ├── *.c              # Generated C code (git-tracked)
│   │
│   ├── uv.pxd           # libuv C API declarations
│   ├── cpython.pxd      # CPython API declarations
│   ├── context.pxd      # Context-related declarations
│   │
│   ├── utils.pyx        # FileMode, utility functions
│   ├── callbacks.pyx    # libuv callback handlers
│   ├── memory_utils.pyx # Memory management utilities
│   ├── buffer_manager.pyx  # Buffer allocation/management
│   ├── event_loop.pyx   # Event loop integration (EventLoopPump)
│   ├── io_operations.pyx   # Core I/O operations (IOOperation)
│   ├── file_io.pyx      # FileReader/FileWriter classes
│   ├── iterators.pyx    # Async iteration support
│   ├── base_file.pyx    # BaseFile class (core file abstraction)
│   ├── binary_file.pyx  # BinaryFile subclass
│   ├── text_file.pyx    # TextFile subclass
│   └── files.pyx        # Public exports
│
├── tests/               # Test suite (pytest + unittest)
│   ├── conftest.py      # Pytest fixtures
│   └── test_files.py    # Main test file
│
├── benchmark/           # Performance benchmarks
│   ├── __init__.py
│   ├── benchmark.py     # Base benchmark class
│   ├── benchmark_read.py
│   ├── benchmark_write.py
│   ├── benchmark_readlines.py
│   └── benchmark_initial.py
│
├── vendor/              # Third-party dependencies
│   └── libuv/           # Git submodule
│
├── scripts/             # Utility scripts
├── .github/workflows/   # CI/CD
│   └── publish.yml      # Semantic release workflow
│
├── setup.py             # Build configuration (custom build_ext)
├── pyproject.toml       # Project metadata and tool configs
├── Makefile             # Development commands
├── tox.ini              # Multi-environment testing
├── requirements.txt     # Runtime dependencies (empty - no deps!)
└── MANIFEST.in          # Package data inclusion rules
```

### Module Architecture

**Layered design** from low-level to high-level:

1. **libuv bindings** (`uv.pxd`) - C API declarations
2. **Utilities** (`utils.pyx`, `memory_utils.pyx`, `callbacks.pyx`) - Helper functions
3. **Buffer management** (`buffer_manager.pyx`) - Dynamic buffer allocation
4. **Event loop integration** (`event_loop.pyx`) - EventLoopPump bridges libuv and asyncio
5. **I/O operations** (`io_operations.pyx`) - IOOperation wraps libuv file operations
6. **File I/O** (`file_io.pyx`) - FileReader/FileWriter orchestrate reads/writes
7. **File abstractions** (`base_file.pyx`, `binary_file.pyx`, `text_file.pyx`) - User-facing classes
8. **Public API** (`__init__.py`) - `open()` context manager

**Key classes:**

- `FileMode` - Parsed file mode (readable, writable, binary, flags, etc.)
- `EventLoopPump` - Runs libuv loop to pump async events
- `IOOperation` - Wraps a single file descriptor with libuv operations
- `BufferManager` - Allocates/frees uv_buf_t buffers efficiently
- `FileReader` / `FileWriter` - Orchestrate chunked reads/writes
- `BaseFile` - Base class with common file operations (seek, tell, truncate)
- `TextFile` / `BinaryFile` - Mode-specific implementations (UTF-8 vs bytes)

---

## Cython Patterns and Conventions

### File Headers

Every `.pyx` file starts with:
```cython
# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
```

### Import Conventions

```cython
from . cimport uv                  # libuv bindings
from . cimport cpython as py       # CPython API
from .utils cimport FileMode       # Internal Cython imports
from cpython.ref cimport Py_INCREF, Py_DECREF
from libc.stdlib cimport malloc, free
from libc.stdint cimport int64_t
```

### Memory Management

**Critical**: Manual memory management is required for C allocations.

```cython
# Always pair malloc with free
cdef uv.uv_buf_t* bufs = <uv.uv_buf_t*>malloc(count * sizeof(uv.uv_buf_t))
if bufs == NULL:
    return NULL
# ... use bufs ...
free(bufs)

# Use nogil for performance-critical sections
cdef inline uv.uv_buf_t* _make_uv_bufs(...) noexcept nogil:
    # No Python objects allowed here
    pass

# Manage Python refcounts when storing in C structures
Py_INCREF(future)  # Keep Python object alive
# ... later ...
Py_DECREF(future)  # Release reference
```

### Error Handling

```cython
# Check libuv return codes
cdef int err = uv.uv_fs_open(...)
if err < 0:
    raise OSError(err, uv.uv_strerror(err))

# Check C allocations
if ptr == NULL:
    raise MemoryError("Allocation failed")
```

### Async Integration

```cython
# Create asyncio Future from C code
from asyncio import Future

cdef object new_future(object loop):
    cdef object future = Future(loop=loop)
    Py_INCREF(future)  # Keep alive until callback
    return future
```

---

## Coding Conventions

### Python Code

- **PEP 8 compliant** (enforced by black/isort)
- **Line length**: 88 characters (black default)
- **Type hints**: Required for public APIs (`__init__.pyi` provides stubs)
- **Docstrings**: Required for public functions/classes
- **Import order**: stdlib → third-party → local (enforced by isort with black profile)

### Cython Code

- **Use `cdef` for performance-critical functions**
- **Use `cpdef` for functions called from both Python and Cython**
- **Use `@cython.cdivision(True)` for faster integer division**
- **Avoid Python object overhead** in tight loops (use C types)
- **Release GIL** with `nogil` in pure C sections
- **Mark exception-less functions** with `noexcept` (Cython 3.0)

### Naming Conventions

- **Python**: `snake_case` for functions, `PascalCase` for classes
- **Cython internal**: Prefix with `_` (e.g., `_make_uv_bufs`, `_read_internal`)
- **C variables**: `snake_case` with type prefixes where helpful (e.g., `data_ptr`, `chunk_len`)

---

## File Mode System

The library uses a custom `FileMode` class to parse Python file mode strings into POSIX flags.

**Supported modes:**
- Base: `r` (read), `w` (write+truncate), `a` (append), `x` (exclusive create)
- Modifiers: `+` (read+write), `b` (binary), `t` (text, default)
- Examples: `r`, `w`, `rb`, `w+`, `a+b`, etc.

**Mode parsing** (`utils.pyx::mode_to_posix`):
```python
from asyncfiles.utils import mode_to_posix
mode = mode_to_posix(b"w+b")  # Returns FileMode instance
# mode.readable == True
# mode.writable == True
# mode.binary == True
# mode.flags == O_CREAT | O_TRUNC | O_RDWR
```

**Mode selection** (`__init__.py::open`):
```python
FileClass = BinaryFile if file_mode.binary else TextFile
```

---

## Testing Patterns

### Test Structure

Tests use **pytest** with `pytest-asyncio` for async support.

```python
import pytest
from asyncfiles import open as async_open

@pytest.fixture
def temp_file(tmp_path):
    path = str(tmp_path / "file.bin")
    with open(path, "wb"):
        pass
    return path

async def test_read(temp_file):
    async with async_open(temp_file, "r") as f:
        data = await f.read()
    assert data == expected
```

### Async Test Configuration

**pyproject.toml** sets `asyncio_mode = "auto"` - tests are automatically detected as async.

### Coverage

Tests are configured to measure coverage with:
- Source: `asyncfiles/` package
- Omit: `tests/`, `vendor/`, `build/`
- Target: See `pyproject.toml` or `tox.ini` for exclusions

---

## Common Gotchas

### 1. **Windows is NOT supported**

The codebase explicitly raises `RuntimeError` on Windows in `setup.py`:
```python
if sys.platform in ("win32", "cygwin", "cli"):
    raise RuntimeError("asyncfiles does not support Windows at the moment")
```

**Why**: The build system assumes POSIX APIs and relies on autoconf/libuv POSIX features.

### 2. **Generated C files are tracked in git**

Unlike typical Cython projects, the `.c` files in `asyncfiles/` are committed. This allows installation without Cython.

**Implication**: After modifying `.pyx` files, you must:
1. Run `make compile` to regenerate `.c` files
2. Commit both `.pyx` and `.c` changes

### 3. **libuv is a git submodule**

The `vendor/libuv/` directory is a submodule. After cloning:
```bash
git submodule init
git submodule update
```

CI/CD (`.github/workflows/publish.yml`) does this automatically.

### 4. **File offset tracking is manual**

`BaseFile` maintains `self.offset` manually - not via OS file descriptor position. This is intentional for async flexibility but requires careful tracking in read/write operations.

```cython
# In text_file.pyx
async def read(self, int length=-1):
    data = await self._read_internal(total_to_read)
    if self.offset >= 0:
        self.offset += len(data)  # Manual tracking!
    return data.decode("utf-8")
```

### 5. **EventLoopPump must be started and stopped**

The `EventLoopPump` runs libuv's event loop to process async operations. It's created in `BaseFile.__init__` and managed in `__aenter__`/`__aexit__`.

**Critical**: Always use context managers (`async with`) to ensure proper cleanup.

### 6. **Buffer size is configurable but has heuristics**

Default buffer size is 64KB. `BufferManager` dynamically adjusts:
- Small reads (< buffer_size): Single buffer
- Large reads (> 10MB): 2MB chunks, max 64 buffers
- Medium reads: Use buffer_size chunks, max 64 buffers

See `buffer_manager.pyx::create_read_buffers` for logic.

### 7. **Semantic versioning is automated**

Commits use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` → minor version bump
- `fix:` / `perf:` / `refactor:` → patch version bump
- `BREAKING CHANGE:` → major version bump

The GitHub Action (`.github/workflows/publish.yml`) runs `python-semantic-release` on pushes to `main`.

### 8. **Type checking ignores asyncfiles module**

`pyproject.toml` has:
```toml
[[tool.mypy.overrides]]
module = "asyncfiles.*"
ignore_errors = true
```

**Reason**: Cython-generated code confuses mypy. Type hints are provided via `__init__.pyi` stub files instead.

### 9. **No runtime dependencies**

The package has **zero runtime dependencies** (`install_requires=[]`). It's fully self-contained once compiled.

### 10. **Branch strategy**

Current branch: `use-buffer` (feature branch)
Main branches: `main`, `feat/improve_performance`, `optimize-from-working`

**Workflow**: Develop in feature branches, PR to `main`, semantic-release handles versioning/publishing.

---

## Development Workflow

### Making Changes

1. **Create/switch to feature branch**:
   ```bash
   git checkout -b feat/my-feature
   ```

2. **Edit Cython files** (`.pyx`, `.pxd`):
   ```bash
   # Make changes to asyncfiles/*.pyx
   ```

3. **Rebuild and test**:
   ```bash
   make compile
   pytest tests/ -v
   ```

4. **Format and lint**:
   ```bash
   black asyncfiles/ tests/
   isort asyncfiles/ tests/
   flake8 asyncfiles/ tests/
   ```

5. **Commit with conventional commit message**:
   ```bash
   git commit -m "feat: add new buffer allocation strategy"
   # or
   git commit -m "fix: handle edge case in FileReader"
   ```

6. **Push and create PR** to `main`.

### Adding New Features

1. **Identify layer**: Determine if the feature belongs in:
   - Low-level (buffer management, I/O operations)
   - Mid-level (file I/O orchestration)
   - High-level (file classes, public API)

2. **Create/modify Cython modules**:
   - Add `.pxd` declarations for public Cython APIs
   - Implement in `.pyx` files
   - Update `__init__.py` if adding public API

3. **Add tests**:
   - Create test functions in `tests/test_files.py`
   - Test both success and error cases
   - Test both text and binary modes if applicable

4. **Update documentation**:
   - Update `README.md` with usage examples
   - Update this file (`AGENTS.md`) if adding new patterns
   - Update `CHANGELOG.md` (or let semantic-release handle it)

5. **Benchmark if performance-critical**:
   - Add benchmark in `benchmark/` if adding I/O-related features
   - Compare against aiofiles/aiofile

---

## Debugging Tips

### Enable Cython Line Tracing

```bash
make debug
pytest tests/ -v
```

This builds with `linetrace=True` and generates `.html` annotation files showing C/Python boundary.

### Enable Asyncio Debug Mode

```bash
PYTHONASYNCIODEBUG=1 pytest tests/ -v
```

Shows warnings for:
- Futures that were never awaited
- Tasks destroyed but pending
- Event loop running in wrong thread

### Check libuv Errors

libuv errors are negative integers. Convert to string:
```python
import asyncfiles.uv as uv
print(uv.uv_strerror(err))
```

### Inspect Generated C Code

After `make compile`, check `asyncfiles/*.c` files to see what Cython generated. Useful for understanding performance issues.

### Use gdb with Cython

```bash
make debug  # Build with debug symbols
gdb --args python -m pytest tests/test_files.py::test_read
```

Cython line tracing helps gdb show Python line numbers.

---

## Performance Considerations

### Key Optimization Strategies

1. **Zero-copy buffers**: `BufferManager` allocates buffers directly for libuv, avoiding memcpy
2. **Chunked I/O**: Large files use multiple buffers to avoid huge allocations
3. **Manual offset tracking**: Avoids lseek() syscalls
4. **Cython `nogil` sections**: Release GIL during C operations
5. **Static libuv linking**: Avoids dynamic library overhead

### Benchmarking

Always benchmark changes against `aiofiles` and `aiofile`:
```bash
python -m benchmark.benchmark_read
python -m benchmark.benchmark_write
```

Current performance (from README):
```
Benchmark Results (10MB file):
├── asyncfiles:    45.2 ms  ← Fastest
├── aiofile:       78.4 ms
├── aiofiles:      112.6 ms
└── stdlib+thread: 156.3 ms
```

---

## CI/CD

### Semantic Release Workflow

File: `.github/workflows/publish.yml`

**Triggers**: Push to `main` or `master`

**Steps**:
1. Checkout with full history (`fetch-depth: 0`)
2. Initialize libuv submodule
3. Install build dependencies (autoconf, automake, libtool, Cython)
4. Build extensions and run tests
5. Run `python-semantic-release` (bumps version, updates CHANGELOG, creates tag)
6. Publish to PyPI (if released)
7. Create GitHub release (if released)

**Semantic release config** in `pyproject.toml`:
- Reads version from `pyproject.toml:project.version` and `asyncfiles/__init__.py:__version__`
- Uses conventional commits to determine version bump
- Uploads sdist (not wheel - Cython extensions must compile on target platform)

---

## Resources

### External Documentation

- **libuv docs**: https://docs.libuv.org/
- **Cython docs**: https://cython.readthedocs.io/
- **uvloop** (inspiration): https://github.com/MagicStack/uvloop
- **Python asyncio**: https://docs.python.org/3/library/asyncio.html

### Related Projects

- **uvloop**: Fast asyncio event loop using libuv
- **aiofiles**: Thread-based async file I/O
- **aiofile**: Another async file library

---

## Summary Checklist

When working in this codebase:

- [ ] Check platform (POSIX only, no Windows)
- [ ] Initialize libuv submodule if needed (`git submodule update --init`)
- [ ] Build with `make compile` after changing `.pyx` files
- [ ] Run `make test` before committing
- [ ] Format with `black` and `isort`
- [ ] Use conventional commit messages (`feat:`, `fix:`, etc.)
- [ ] Always use `async with open(...)` (never bare open/close)
- [ ] Test both text and binary modes if touching file I/O
- [ ] Benchmark if changing performance-critical paths
- [ ] Update AGENTS.md if introducing new patterns or gotchas

---

**Last Updated**: 2025-02-05 (based on v1.1.3, branch use-buffer)
