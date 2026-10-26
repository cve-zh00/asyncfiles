## Summary

<!-- What does this PR change and why? -->

## Type of change

<!-- The PR title must follow Conventional Commits: feat:, fix:, perf:, refactor:, docs:, test:, build:, ci:, chore: -->

- [ ] `feat` — new functionality (minor release)
- [ ] `fix` / `perf` / `refactor` — patch release
- [ ] `docs` / `test` / `build` / `ci` / `chore` — no release
- [ ] Breaking change (`!` in the title or `BREAKING CHANGE:` footer)

## Checklist

- [ ] `make compile && make test` passes (both libuv and io_uring backends)
- [ ] Tests added/updated for text **and** binary modes when touching file I/O
- [ ] Benchmarked if this touches a performance-critical path
- [ ] Docs (README / type stubs) updated if the public API changed
