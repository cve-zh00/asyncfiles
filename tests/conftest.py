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

    ``asyncfiles.open`` resolves ``backend="auto"`` at call time, so forcing
    the default resolution exercises each implementation while still allowing
    tests to pass an explicit ``backend=...`` value.
    """
    import asyncfiles.backend as backend_module

    real_resolve_backend = backend_module.resolve_backend

    monkeypatch.setattr(
        backend_module,
        "resolve_backend",
        lambda requested: (
            request.param if requested == "auto" else real_resolve_backend(requested)
        ),
    )
    return request.param


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
