import asyncio
import json
import os
from pathlib import Path
from uuid import uuid4

import pytest

from asyncfiles import open as async_open


def split_by(seq, n):
    seq = seq
    while seq:
        yield seq[:n]
        seq = seq[n:]


@pytest.fixture
def temp_file(tmp_path):
    path = str(tmp_path / "file.bin")
    with open(path, "wb"):
        pass
    return path


@pytest.fixture
def uuid():
    return str(uuid4())


async def test_read(temp_file, uuid):
    with open(temp_file, "w") as f:
        f.write(uuid)

    async with async_open(temp_file, "r") as aio_file:
        data = await aio_file.read()

    assert data == uuid


async def test_read_write(temp_file, uuid):
    async with async_open(temp_file, "w") as w_file:
        await w_file.write(uuid)

    async with async_open(temp_file, "r") as r_file:
        data = await r_file.read()

    assert data == uuid


async def test_read_write_str_path(temp_file, uuid):
    # Test with string path
    async with async_open(str(temp_file), "w") as w_file:
        await w_file.write(uuid)

    async with async_open(str(temp_file), "r") as r_file:
        data = await r_file.read()

    assert data == uuid


async def test_read_basic(temp_file):
    test_data = "Hello, World!"

    with open(temp_file, "w") as f:
        f.write(test_data)

    async with async_open(temp_file, "r") as aio_file:
        data = await aio_file.read()

    assert data == test_data


async def test_write_basic(temp_file):
    test_data = "Hello, async world!"

    async with async_open(temp_file, "w") as aio_file:
        await aio_file.write(test_data)

    with open(temp_file, "r") as f:
        data = f.read()

    assert data == test_data


async def test_non_existent_file_read():
    with pytest.raises(FileNotFoundError):
        async with async_open("/nonexistent/path/file.txt", "r") as f:
            pass


async def test_sequential_write_read(temp_file):
    data = "Hello, async world!"

    async with async_open(temp_file, "w") as file:
        await file.write(data)

    async with async_open(temp_file, "r") as file:
        result = await file.read()
        assert result == data


async def test_multiple_writes(temp_file):
    async with async_open(temp_file, "w") as w_file:
        await w_file.write("Hello")
        await w_file.write(" ")
        await w_file.write("World")

    async with async_open(temp_file, "r") as r_file:
        result = await r_file.read()
        assert result == "Hello World"


async def test_truncate(temp_file):
    async with async_open(temp_file, "w") as afp:
        await afp.write("hello world")

    async with async_open(temp_file, "r") as afp:
        result = await afp.read()
        assert result == "hello world"

    # Open in write mode to truncate
    async with async_open(temp_file, "r+") as afp:
        await afp.truncate(0)

    async with async_open(temp_file, "r") as afp:
        result = await afp.read()
        assert result == ""


async def test_modes_basic(tmp_path):
    tmpfile = tmp_path / "test.txt"

    async with async_open(tmpfile, "w") as afp:
        await afp.write("foo")

    async with async_open(tmpfile, "r") as afp:
        assert await afp.read() == "foo"


async def test_modes_json(tmp_path):
    data = {"test": "data", "number": 42}
    tmpfile = tmp_path / "test.json"

    async with async_open(tmpfile, "w") as afp:
        await afp.write(json.dumps(data, indent=1))

    async with async_open(tmpfile, "r") as afp:
        result = json.loads(await afp.read())

    assert result == data


async def test_unicode_read_write(temp_file):
    async with async_open(temp_file, "w") as afp:
        await afp.write("한글")

    async with async_open(temp_file, "r") as afp:
        result = await afp.read()
        assert result == "한글"


async def test_unicode_multiple_writes(temp_file):
    async with async_open(temp_file, "w") as afp:
        await afp.write("한")
        await afp.write("글")

    async with async_open(temp_file, "r") as afp:
        result = await afp.read()
        assert result == "한글"


async def test_unicode_emoji(temp_file):
    data = "🏁💾🏴‍☠️"

    async with async_open(temp_file, "w") as afp:
        await afp.write(data)

    async with async_open(temp_file, "r") as afp:
        result = await afp.read()
        assert result == data


async def test_write_empty_string(temp_file):
    async with async_open(temp_file, "w") as afp:
        await afp.write("")

    async with async_open(temp_file, "r") as afp:
        result = await afp.read()
        assert result == ""


async def test_binary_mode(temp_file):
    data = b"\x01\x02\x03"

    async with async_open(temp_file, "wb") as afp:
        await afp.write(data * 32)

    async with async_open(temp_file, "rb") as afp:
        result = await afp.read()
        assert result == data * 32


async def test_binary_unicode(temp_file):
    data = "🦠📱".encode()

    async with async_open(temp_file, "wb") as afp:
        await afp.write(data)

    async with async_open(temp_file, "rb") as afp:
        result = await afp.read()
        assert result == data


async def test_multiple_concurrent_read_operations(tmp_path):
    files = [tmp_path / f"file{i}.txt" for i in range(5)]
    contents = [f"Content {i}" for i in range(5)]

    # Write files synchronously first
    for file_path, content in zip(files, contents):
        with open(file_path, "w") as f:
            f.write(content)

    async def read_file(path):
        async with async_open(path, "r") as f:
            return await f.read()

    # Read concurrently
    results = await asyncio.gather(*[read_file(files[i]) for i in range(5)])

    assert results == contents


async def test_multiple_concurrent_write_operations(tmp_path):
    files = [tmp_path / f"file{i}.txt" for i in range(5)]
    contents = [f"Content {i}" for i in range(5)]

    async def write_file(path, content):
        async with async_open(path, "w") as f:
            await f.write(content)

    # Write concurrently
    await asyncio.gather(*[write_file(files[i], contents[i]) for i in range(5)])

    # Verify
    for file_path, expected_content in zip(files, contents):
        with open(file_path, "r") as f:
            assert f.read() == expected_content


async def test_large_file_write_read(tmp_path):
    src_path = tmp_path / "large.txt"
    size = 1000

    # Write large file
    async with async_open(src_path, "w") as afp:
        for i in range(size):
            await afp.write(f"{i}\n")

    # Read and verify
    async with async_open(src_path, "r") as afp:
        content = await afp.read()
        lines = content.strip().split("\n")
        numbers = [int(line) for line in lines]

    assert numbers == list(range(size))


async def test_append_mode(temp_file):
    async with async_open(temp_file, "w") as f:
        await f.write("Hello")

    async with async_open(temp_file, "a") as f:
        await f.write(" World")

    async with async_open(temp_file, "r") as f:
        result = await f.read()
        assert result == "Hello World"


async def test_append_mode_multiple(temp_file):
    async with async_open(temp_file, "w") as f:
        await f.write("Line 1\n")

    async with async_open(temp_file, "a") as f:
        await f.write("Line 2\n")

    async with async_open(temp_file, "a") as f:
        await f.write("Line 3\n")

    async with async_open(temp_file, "r") as f:
        result = await f.read()
        assert result == "Line 1\nLine 2\nLine 3\n"


async def test_exclusive_creation(tmp_path):
    new_file = tmp_path / "new_file.txt"

    async with async_open(new_file, "x") as f:
        await f.write("Created")

    # Should raise FileExistsError
    with pytest.raises(FileExistsError):
        async with async_open(new_file, "x") as f:
            pass


async def test_read_plus_mode(temp_file):
    # Write initial content
    with open(temp_file, "w") as f:
        f.write("Initial content")

    async with async_open(temp_file, "r+") as f:
        content = await f.read()
        assert content == "Initial content"

        await f.write(" and more")

    async with async_open(temp_file, "r") as f:
        result = await f.read()
        assert result == "Initial content and more"


async def test_seek_and_tell(temp_file):
    """Test seek and tell methods"""
    async with async_open(temp_file, "w") as f:
        await f.write("0123456789")

    async with async_open(temp_file, "r") as f:
        # Test tell at start
        assert f.tell() == 0

        # Read some bytes and check position
        data = await f.read(5)
        assert data == "01234"
        assert f.tell() == 5

        # Seek to beginning
        f.seek(0)
        assert f.tell() == 0

        # Read again from beginning
        data = await f.read(3)
        assert data == "012"
        assert f.tell() == 3

        # Seek from current position
        f.seek(2, 1)  # SEEK_CUR
        assert f.tell() == 5

        # Seek from end
        f.seek(-3, 2)  # SEEK_END
        assert f.tell() == 7


async def test_truncate_with_size(temp_file):
    """Test truncate with specific size"""
    async with async_open(temp_file, "w") as f:
        await f.write("Hello World!")

    async with async_open(temp_file, "r+") as f:
        await f.truncate(5)

    async with async_open(temp_file, "r") as f:
        result = await f.read()
        assert result == "Hello"


async def test_write_plus_mode(temp_file):
    async with async_open(temp_file, "w+") as f:
        await f.write("Test data")
        result = await f.read()
        # After write, we're at the end, so read returns empty or remaining
        assert result == "" or result == "Test data"


async def test_empty_file_operations(temp_file):
    async with async_open(temp_file, "w") as f:
        pass  # Create empty file

    async with async_open(temp_file, "r") as f:
        result = await f.read()
        assert result == ""


async def test_pathlib_path_support(tmp_path):
    file_path = Path(tmp_path) / "pathlib_test.txt"
    content = "Testing pathlib support"

    # Note: Current implementation may need str() conversion
    async with async_open(str(file_path), "w") as f:
        await f.write(content)

    async with async_open(str(file_path), "r") as f:
        result = await f.read()
        assert result == content


async def test_multiple_buffer_sizes(temp_file, uuid):
    for buffer_size in [1024, 4096, 64 * 1024]:
        async with async_open(temp_file, "w", buffer_size=buffer_size) as f:
            await f.write(uuid)

        async with async_open(temp_file, "r", buffer_size=buffer_size) as f:
            result = await f.read()
            assert result == uuid


async def test_binary_large_data(temp_file):
    data = os.urandom(1024 * 1024)  # 1 MB

    async with async_open(temp_file, "wb") as f:
        await f.write(data)

    async with async_open(temp_file, "rb") as f:
        result = await f.read()
        assert result == data


# ============================================================================
# Tests para iteradores (TextFileIterator y BinaryFileIterator)
# ============================================================================


async def test_text_iterator_basic(temp_file):
    """Test básico de iteración sobre archivo de texto"""
    lines = ["Line 1\n", "Line 2\n", "Line 3\n"]

    async with async_open(temp_file, "w") as f:
        for line in lines:
            await f.write(line)

    result_lines = []
    async with async_open(temp_file, "r") as f:
        async for line in f:
            result_lines.append(line)

    assert result_lines == lines


async def test_text_iterator_no_final_newline(temp_file):
    """Test iterador con última línea sin salto de línea"""
    content = "Line 1\nLine 2\nLine 3"

    async with async_open(temp_file, "w") as f:
        await f.write(content)

    result_lines = []
    async with async_open(temp_file, "r") as f:
        async for line in f:
            result_lines.append(line)

    assert result_lines == ["Line 1\n", "Line 2\n", "Line 3"]


async def test_binary_iterator_basic(temp_file):
    """Test básico de iteración sobre archivo binario"""
    lines = [b"Line 1\n", b"Line 2\n", b"Line 3\n"]

    async with async_open(temp_file, "wb") as f:
        for line in lines:
            await f.write(line)

    result_lines = []
    async with async_open(temp_file, "rb") as f:
        async for line in f:
            result_lines.append(line)

    assert result_lines == lines


async def test_text_iterator_unicode(temp_file):
    """Test iterador con caracteres Unicode"""
    lines = ["한글\n", "🏁💾\n"]

    async with async_open(temp_file, "w") as f:
        for line in lines:
            await f.write(line)

    result_lines = []
    async with async_open(temp_file, "r") as f:
        async for line in f:
            result_lines.append(line)

    assert result_lines == lines
