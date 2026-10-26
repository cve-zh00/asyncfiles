# Contributing to asyncfiles

## Setup

```bash
git clone --recurse-submodules git@github.com:cve-zh00/asyncfiles.git
cd asyncfiles
python -m venv .venv && source .venv/bin/activate
pip install "Cython~=3.0" pytest pytest-asyncio typing_extensions
make compile
make test
```

Requirements: Python 3.9+, a C compiler and `autoconf automake libtool`. POSIX only (Linux, macOS, BSD). The generated `asyncfiles/*.c` files are not tracked in git.

The test suite runs against both backends (libuv and, on Linux, io_uring).

## Benchmarks

Resource-limited Docker benchmark (one container, 2 CPUs / 1GB; needs Docker; io_uring needs `--security-opt seccomp=unconfined`, which the script sets):

```bash
scripts/run_docker_benchmark.sh
```

Results land in `benchmark/results/benchmark_read.md` and `benchmark_write.md` and are refreshed automatically on every release.

## Commit messages

Releases are automated by [python-semantic-release](https://python-semantic-release.readthedocs.io/),
so commit messages (and PR titles, for squash merges) **must** follow
[Conventional Commits](https://www.conventionalcommits.org/):

| Type | Effect |
|------|--------|
| `feat:` | minor release |
| `fix:`, `perf:`, `refactor:` | patch release |
| `docs:`, `test:`, `build:`, `ci:`, `chore:`, `style:` | no release |
| `feat!:` / `BREAKING CHANGE:` footer | major release |

Do not edit the version or `CHANGELOG.md` by hand.

## Pull requests

1. Branch from `main`, keep the change focused.
2. `make compile && make test` must pass.
3. Add tests for new behaviour (text and binary modes when touching file I/O).
4. Open the PR against `main` with a Conventional Commits title.

## Release process

Pushing to `main` runs `.github/workflows/release.yml`: tests → semantic-release
(version bump, changelog, `vX.Y.Z` tag, GitHub release) → sdist and wheels →
PyPI (trusted publishing) → Docker benchmark refresh.
Maintainers can re-run it manually with *Run workflow* (`workflow_dispatch`).
