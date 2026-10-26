# distutils: language = c
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False

import os
import sys
from libc.stdint cimport uint32_t

# Cached detection result: None = not checked, True/False = result
cdef object _io_uring_available = None

cdef tuple _parse_kernel_version(str release):
    """Parse major.minor from kernel release string like '5.15.0-generic'."""
    cdef str part
    cdef list parts
    try:
        parts = release.split(".")
        return (int(parts[0]), int(parts[1]))
    except (IndexError, ValueError):
        return (0, 0)

cdef bint _detect_io_uring_support():
    """Check if io_uring is available on this system."""
    global _io_uring_available

    if _io_uring_available is not None:
        return _io_uring_available

    if sys.platform != "linux":
        _io_uring_available = False
        return False

    cdef tuple kver = _parse_kernel_version(os.uname().release)
    if kver[0] < 5 or (kver[0] == 5 and kver[1] < 6):
        _io_uring_available = False
        return False

    # Attempt a probe: try io_uring_queue_init and immediately exit
    try:
        from .io_uring_pump import _probe_io_uring
        _io_uring_available = _probe_io_uring()
    except Exception:
        _io_uring_available = False

    return _io_uring_available

cpdef str resolve_backend(str backend):
    """Resolve the backend string to 'io_uring' or 'libuv'.

    Raises ValueError for invalid backend values.
    Raises OSError if 'io_uring' is explicitly requested but unavailable.
    """
    if backend not in ("auto", "io_uring", "libuv"):
        raise ValueError(
            f"Invalid backend '{backend}'. Must be one of: 'auto', 'io_uring', 'libuv'"
        )

    if backend == "libuv":
        return "libuv"

    if backend == "io_uring":
        if not _detect_io_uring_support():
            raise OSError(
                "io_uring backend is unavailable: requires Linux kernel 5.6+ "
                "with io_uring support"
            )
        return "io_uring"

    # backend == "auto"
    if _detect_io_uring_support():
        return "io_uring"
    return "libuv"
