import asyncio
import os
import tempfile
from pathlib import Path

import pytest


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
