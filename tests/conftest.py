import asyncio
import os
import tempfile
from pathlib import Path

import pytest


def _available_backends():
    from asyncfiles.backend import resolve_backend

    backends = ["libuv"]
    try:
        resolve_backend("io_uring")
    except OSError:
        pass
    else:
        backends.append("io_uring")
    return backends


@pytest.fixture(autouse=True, params=_available_backends())
def backend(request, monkeypatch):
    """Run every test once per available backend.

    ``asyncfiles.open`` resolves the backend at call time, so forcing the
    resolver exercises each implementation without touching the tests.
    """
    import asyncfiles.backend as backend_module

    monkeypatch.setattr(
        backend_module, "resolve_backend", lambda _requested: request.param
    )
    return request.param


@pytest.fixture(scope="session")
def event_loop_policy():
    """Set the event loop policy for the test session."""
    return asyncio.DefaultEventLoopPolicy()


@pytest.fixture
def event_loop(event_loop_policy):
    """Create an event loop for each test."""
    loop = event_loop_policy.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def temp_file(tmp_path):
    """Create a temporary file for testing."""
    path = tmp_path / "test_file.bin"
    path.touch()
    return str(path)


@pytest.fixture
def uuid():
    """Generate a UUID string for testing."""
    from uuid import uuid4

    return str(uuid4())


@pytest.fixture
def temp_dir(tmp_path):
    """Provide a temporary directory for testing."""
    return tmp_path


# Configure pytest-asyncio
pytest_plugins = ("pytest_asyncio",)
