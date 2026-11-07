# CHANGELOG

<!-- version list -->

## v1.10.1 (2026-11-07)

### Performance Improvements

- Raise sendfile/sendpath default chunk_size from 64 KiB to 1 MiB
  ([`4cb560b`](https://github.com/cve-zh00/asyncfiles/commit/4cb560b59d64d449cbeb10714564b8bbbf1687d0))


## v1.10.0 (2026-11-07)

### Bug Fixes

- Prime shared libuv loop after submitting borrowed-fd read
  ([`312655d`](https://github.com/cve-zh00/asyncfiles/commit/312655d0db42efefbf220769a8d88d4243ccaa81))

### Features

- Add sendfile and sendpath protocol support
  ([`82eface`](https://github.com/cve-zh00/asyncfiles/commit/82efaceb4a86c6caa5b7664ec94fd0308b15f8bb))


## v1.9.0 (2026-11-07)

### Bug Fixes

- Map libuv error codes to errno so Windows raises FileNotFoundError/FileExistsError
  ([`bd7d8b4`](https://github.com/cve-zh00/asyncfiles/commit/bd7d8b43179b22de84cd8e44b42bc3c64b389ad0))

### Build System

- Add Windows build path for libuv via CMake
  ([`c3a4cef`](https://github.com/cve-zh00/asyncfiles/commit/c3a4cef144d57f14956addfaa474953401049925))

- Read text files as UTF-8 in setup.py
  ([`165cbb2`](https://github.com/cve-zh00/asyncfiles/commit/165cbb24fa414c4986c35c5b05707d57f321b106))

### Continuous Integration

- Add experimental Windows job
  ([`6a80228`](https://github.com/cve-zh00/asyncfiles/commit/6a802284fe645d76a76a655c93c99eb6cac714f0))

- Run Windows tests in tests.yml so PRs and releases cover them
  ([`31a1907`](https://github.com/cve-zh00/asyncfiles/commit/31a190749e65aa2b0b2991da93324d5263b2952d))

### Features

- Support Windows (wheels, CI matrix, docs)
  ([`e04b7e9`](https://github.com/cve-zh00/asyncfiles/commit/e04b7e965e8911632849dc9c5ceb7a8f6dc05d6f))


## v1.8.1 (2026-11-07)

### Bug Fixes

- Resolve sign-compare and const-qualifier compiler warnings
  ([`a222e3e`](https://github.com/cve-zh00/asyncfiles/commit/a222e3edebb19d73178f8c9eb1e1c96b27fdea49))

### Continuous Integration

- Add Python 3.14 and 3.15 to tests, wheels and classifiers
  ([`f372db1`](https://github.com/cve-zh00/asyncfiles/commit/f372db1f1c3c2d39028ea66be6f758acb3f595a7))

- Update tox envlist for Python 3.10-3.15
  ([`eb1fad4`](https://github.com/cve-zh00/asyncfiles/commit/eb1fad45516afe8c3b3921bd45640fb17a69255f))

### Documentation

- Update AGENTS.md for Python 3.10-3.15
  ([`71bfca6`](https://github.com/cve-zh00/asyncfiles/commit/71bfca6deb3364c050dd11edfb1f3045324d8d58))


## v1.8.0 (2026-11-06)

### Continuous Integration

- Modify benchmark sizes and default parameters
  ([`eef8973`](https://github.com/cve-zh00/asyncfiles/commit/eef89736354ed5b6906071b23c429c831e3f9828))

### Features

- Drop Python 3.9 support
  ([`4d1acde`](https://github.com/cve-zh00/asyncfiles/commit/4d1acdeb8a3fa90d5eee1bd4546f6924b438cc04))


## v1.7.0 (2026-10-26)

### Features

- Update benchmark sizes and parameters
  ([`ddc431b`](https://github.com/cve-zh00/asyncfiles/commit/ddc431b5e2fd0389c7c9a954116990449d622327))


## v1.6.1 (2026-10-26)

### Bug Fixes

- Stop leaking an asyncio Future reference on every libuv operation
  ([`b319a50`](https://github.com/cve-zh00/asyncfiles/commit/b319a50a25ae332c23852d2c046f827c41f525b2))

### Performance Improvements

- Zero-copy text writes, lighter open() and fstat on the open fd
  ([`28b7d72`](https://github.com/cve-zh00/asyncfiles/commit/28b7d72acf44874ddb00d7d24c333a76a9cac5e0))


## v1.6.0 (2026-10-26)

### Continuous Integration

- **benchmark**: Single medium container, publish benchmark_read.md and benchmark_write.md
  ([`a366217`](https://github.com/cve-zh00/asyncfiles/commit/a36621773268e782c2ee667aa1f043ee5abb72aa))

### Features

- Increase default iterations from 5 to 10
  ([`ea5e6bb`](https://github.com/cve-zh00/asyncfiles/commit/ea5e6bbe8f425979437e1c207cc1aedd49e59039))


## v1.5.1 (2026-10-26)

### Bug Fixes

- Clarify threading model and correct misleading async claims
  ([`5fdaaf7`](https://github.com/cve-zh00/asyncfiles/commit/5fdaaf79034fa19afc1449bbee576b6260265494))

- **build**: Build only liburing src and skip musllinux wheels
  ([`3bb91be`](https://github.com/cve-zh00/asyncfiles/commit/3bb91be8551562fdef0ea2178bf8deb19e7492dc))

### Continuous Integration

- Fix cibuildwheel Linux dependency install
  ([`a3dbb53`](https://github.com/cve-zh00/asyncfiles/commit/a3dbb53d61736ea234a7aede05693db8294ed685))


## v1.5.0 (2026-10-26)

### Bug Fixes

- Make libuv work on Linux and harden io_uring backend
  ([`9c03a8a`](https://github.com/cve-zh00/asyncfiles/commit/9c03a8a435c0e003aaa064e6734bf4f30761d8e2))

### Build System

- Use SPDX license expression and require Python >=3.9
  ([`b4d43fe`](https://github.com/cve-zh00/asyncfiles/commit/b4d43fe3b7f03a0360053964f5fbcff7f23fe7bb))

### Chores

- Add Python 3.9 compatibility and modernize type hints
  ([`cb61620`](https://github.com/cve-zh00/asyncfiles/commit/cb61620c2b51146e88ef2fe7612e816fa0539c18))

- **Makefile**: Migrate test runner from unittest to pytest
  ([`e3e0207`](https://github.com/cve-zh00/asyncfiles/commit/e3e02071c284abae7a452b00f73cafc1130aae74))

### Continuous Integration

- Bump the actions group across 1 directory with 2 updates
  ([`d1bccc5`](https://github.com/cve-zh00/asyncfiles/commit/d1bccc580c94a15e505015873affd0548f63ca94))

- Change branch of trigger deploy
  ([`4eebbe9`](https://github.com/cve-zh00/asyncfiles/commit/4eebbe9845b12c3d1ba5a7ac942f37c5a7718c84))

- Delete flags of coverage
  ([`a018e67`](https://github.com/cve-zh00/asyncfiles/commit/a018e673d99f9428bfe7818d2462d8961925fac0))

- Limit dependabot to github-actions
  ([`b174494`](https://github.com/cve-zh00/asyncfiles/commit/b174494d620589f717a251818e5e27e7d71bae9d))

- Refactor release workflow and add test automation
  ([`ea94b03`](https://github.com/cve-zh00/asyncfiles/commit/ea94b0339c02c662d3bf59b297b392ff92e6124f))

- Release pipeline with python-semantic-release
  ([`86fe5ff`](https://github.com/cve-zh00/asyncfiles/commit/86fe5ff5ccbbc87c191580cc1d72f27572b659d2))

- Run Docker benchmark on release and commit refreshed results
  ([`1015f15`](https://github.com/cve-zh00/asyncfiles/commit/1015f154eefcce24c47a1eab5490adc3b85f71e2))

### Documentation

- Add CONTRIBUTING, PR template, badges and release docs
  ([`60f4313`](https://github.com/cve-zh00/asyncfiles/commit/60f43132b5319b195a4ba3ba3187f93313ebbb34))

- Document io_uring backend and Docker benchmark results
  ([`7d66c3b`](https://github.com/cve-zh00/asyncfiles/commit/7d66c3b821845a760d987266721c76d1928dea97))

- **Readme.md**: Refine README description for async file operations
  ([`059beae`](https://github.com/cve-zh00/asyncfiles/commit/059beae726ece91576063fd6f102d43b8c1009c3))

- **Readme.md**: Update non-blocking feature description in README
  ([`c867659`](https://github.com/cve-zh00/asyncfiles/commit/c8676595d7bcc43af86f5003938a5c18d5457580))

### Features

- Add io_uring backend for Linux kernel 5.6+
  ([`af63823`](https://github.com/cve-zh00/asyncfiles/commit/af63823d02286cd4fd5846581dfd27b7a6455a32))

- Add resource-limited Docker benchmark and results
  ([`23b2cf8`](https://github.com/cve-zh00/asyncfiles/commit/23b2cf8fe7d67f867af9eda1707c8cf2ba600371))

- Delete .c files
  ([`9c5cd0a`](https://github.com/cve-zh00/asyncfiles/commit/9c5cd0a7b85b238bc91f34e6ee2f86bf7cd53f4d))

### Performance Improvements

- **io**: Implement zero-copy reads using direct buffer access
  ([`d1f2122`](https://github.com/cve-zh00/asyncfiles/commit/d1f2122d3d26962fedf38ca124fa1465b2258d6d))

### Refactoring

- **core**: Simplify event loop handling and improve memory management
  ([`e620715`](https://github.com/cve-zh00/asyncfiles/commit/e6207156e7f3e15ac3fd176c107555a6bcb0f28c))

- **event_loop**: Implement singleton pump with shared lifecycle management
  ([`e788d4f`](https://github.com/cve-zh00/asyncfiles/commit/e788d4f194066e69983af74d2a6bd8656b3695ba))


## v1.4.0

Last release published before the automated release pipeline. Subsequent
entries are generated by [python-semantic-release](https://python-semantic-release.readthedocs.io/)
from [Conventional Commits](https://www.conventionalcommits.org/).
