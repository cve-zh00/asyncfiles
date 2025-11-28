# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of asyncfiles
- High-performance async file I/O built on libuv
- Support for text and binary file modes
- Context manager interface (`async with open(...)`)
- Offset-based read/write operations
- Multiple buffer size configurations
- Full Python 3.8+ support
- Type hints and py.typed support
- Comprehensive test suite with pytest
- Support for multiple file modes: r, w, a, x, r+, w+, a+
- Binary mode support (rb, wb, ab, etc.)
- pathlib.Path compatibility
- Concurrent file operations support
- Zero-copy buffer operations (via Cython)
- fsync and truncate operations

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [0.1.0] - 2024-01-XX

### Added
- Initial alpha release
- Basic async file operations
- libuv integration via Cython
- Core functionality for read/write operations
- Support for POSIX systems (Linux, macOS, BSD)

[Unreleased]: https://github.com/yourusername/asyncfiles/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/asyncfiles/releases/tag/v0.1.0
