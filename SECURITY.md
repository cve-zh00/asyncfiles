# Security Policy

## Supported Versions

Only the latest `1.x` release line of `py-asyncfiles` receives security updates.

| Version | Supported |
| ------- | --------- |
| 1.10.x  | :white_check_mark: |
| < 1.10  | :x: |

## Reporting a Vulnerability

Please **do not** report security vulnerabilities through public GitHub issues, discussions, or pull requests.

Instead, report them privately using one of the following channels:

1. **GitHub Private Vulnerability Reporting (preferred)**:
   Open a private advisory at [https://github.com/cve-zh00/asyncfiles/security/advisories/new](https://github.com/cve-zh00/asyncfiles/security/advisories/new).
2. **Email**:
   Send a report to `bastiang@uc.cl` with `[SECURITY] asyncfiles` in the subject line.

### What to Include

Because `asyncfiles` includes Cython/C extensions (`libuv` and `io_uring`), please include:

- The affected version of `py-asyncfiles` and Python (`python -VV`)
- Operating system, architecture, and kernel version (`uname -a`)
- Active backend (`io_uring` or `libuv`)
- A minimal reproduction script or proof-of-concept demonstrating the issue (e.g., memory corruption, use-after-free, descriptor leak, or path handling bug)

### Response Timeline

- **Initial acknowledgment**: within 72 hours
- **Triage & status update**: within 7 days
- **Coordinated disclosure**: once a fix is released on PyPI, we will publish a GitHub Security Advisory crediting the reporter (unless anonymity is requested)
