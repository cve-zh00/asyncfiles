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


async def test_large_binary_roundtrip_chunked(temp_file):
    """Archivos > umbral paralelo se leen/escriben troceados y en orden"""
    data = os.urandom(9 * 1024 * 1024 + 123)

    async with async_open(temp_file, "wb") as f:
        await f.write(data)
    assert Path(temp_file).read_bytes() == data

    async with async_open(temp_file, "rb") as f:
        assert await f.read() == data


async def test_read_past_eof_is_empty_and_short_read(temp_file):
    Path(temp_file).write_bytes(b"abcdef")
    async with async_open(temp_file, "rb") as f:
        assert await f.read(100) == b"abcdef"
        assert await f.read(10) == b""


async def test_cancelled_read_does_not_corrupt(temp_file):
    """Cancelar lecturas en vuelo no debe provocar use-after-free"""
    data = os.urandom(8 * 1024 * 1024)
    Path(temp_file).write_bytes(data)

    for _ in range(20):
        async with async_open(temp_file, "rb") as f:
            task = asyncio.ensure_future(f.read())
            await asyncio.sleep(0)
            task.cancel()
            with pytest.raises(asyncio.CancelledError):
                await task

    async with async_open(temp_file, "rb") as f:
        assert await f.read() == data


async def test_missing_file_raises(tmp_path):
    with pytest.raises(OSError):
        async with async_open(str(tmp_path / "nope.bin"), "rb"):
            pass


async def test_text_write_returns_utf8_byte_count(temp_file):
    data = "añ한🏁"

    async with async_open(temp_file, "w") as afp:
        written = await afp.write(data)

    assert written == len(data.encode("utf-8"))
    assert Path(temp_file).read_bytes() == data.encode("utf-8")


async def test_text_write_large_non_ascii_temporary(temp_file):
    # Above the io_uring parallel threshold; the str is a temporary that must
    # stay alive while the write is in flight.
    size = 3 * 1024 * 1024

    async with async_open(temp_file, "w") as afp:
        await afp.write("é한" * size)

    async with async_open(temp_file, "r") as afp:
        result = await afp.read()

    assert result == "é한" * size


async def test_text_write_at_offset_after_seek(temp_file):
    async with async_open(temp_file, "w+") as afp:
        await afp.write("hello world")
        afp.seek(6)
        await afp.write("한글!")

    assert Path(temp_file).read_text(encoding="utf-8") == "hello 한글!"


async def test_open_without_async_with_is_context_manager(temp_file):
    cm = async_open(temp_file, "wb")
    async with cm as afp:
        await afp.write(b"abc")

    assert Path(temp_file).read_bytes() == b"abc"


async def test_open_does_not_leak_futures(temp_file):
    import gc

    def count():
        gc.collect()
        return sum(1 for o in gc.get_objects() if isinstance(o, asyncio.Future))

    async with async_open(temp_file, "wb") as afp:
        await afp.write(b"x" * 4096)

    before = count()
    for _ in range(200):
        async with async_open(temp_file, "rb") as afp:
            await afp.read()
        async with async_open(temp_file, "ab") as afp:
            await afp.write(b"y")

    assert count() - before < 10


async def test_unicode_path_roundtrip(tmp_path):
    path = tmp_path / "ñandú_日本語.txt"

    async with async_open(path, "w") as f:
        await f.write("héllo")

    async with async_open(path, "r") as f:
        assert await f.read() == "héllo"


async def test_open_error_does_not_leak_pump_or_fd(tmp_path):
    import gc
    from asyncfiles.event_loop import EventLoopPump

    with pytest.raises(FileNotFoundError):
        async with async_open(tmp_path / "does_not_exist.bin", "rb"):
            pass

    gc.collect()
    assert not any(isinstance(o, EventLoopPump) for o in gc.get_objects())

    existing = tmp_path / "exists.bin"
    existing.write_bytes(b"123")
    with pytest.raises(FileExistsError):
        async with async_open(existing, "xb"):
            pass

    gc.collect()
    assert not any(isinstance(o, EventLoopPump) for o in gc.get_objects())


async def test_open_directory_raises_is_a_directory(tmp_path):
    import gc
    from asyncfiles.event_loop import EventLoopPump

    for mode in ("r", "rb", "w", "wb"):
        with pytest.raises(IsADirectoryError):
            async with async_open(tmp_path, mode):
                pass

    gc.collect()
    assert not any(isinstance(o, EventLoopPump) for o in gc.get_objects())


async def test_plus_modes_write_seek_read_same_handle(tmp_path):
    # w+b: write, seek(0), read within the same handle
    p_wb = tmp_path / "wplus.bin"
    async with async_open(p_wb, "w+b") as f:
        assert await f.write(b"hello world") == 11
        assert f.tell() == 11
        f.seek(0)
        assert await f.read() == b"hello world"
        f.seek(6)
        await f.write(b"asyncfiles")
        f.seek(0)
        assert await f.read() == b"hello asyncfiles"

    # w+ text: write, seek(0), read within the same handle
    p_wt = tmp_path / "wplus.txt"
    async with async_open(p_wt, "w+") as f:
        await f.write("hola mundo")
        f.seek(0)
        assert await f.read() == "hola mundo"

    # a+b: initial offset at EOF, seek(0) reads from start, write still appends at EOF
    p_ab = tmp_path / "aplus.bin"
    p_ab.write_bytes(b"first-")
    async with async_open(p_ab, "a+b") as f:
        assert f.tell() == 6
        f.seek(0)
        assert await f.read() == b"first-"
        f.seek(0)
        await f.write(b"second")
        assert f.tell() == 12
        f.seek(0)
        assert await f.read() == b"first-second"

    # x+b: exclusive create + write + seek + read
    p_xb = tmp_path / "xplus.bin"
    async with async_open(p_xb, "x+b") as f:
        await f.write(b"exclusive")
        f.seek(0)
        assert await f.read() == b"exclusive"


async def test_read_none_and_large_length_clamp(temp_file):
    async with async_open(temp_file, "wb") as f:
        await f.write(b"short data")

    async with async_open(temp_file, "rb") as f:
        assert await f.read(0) == b""
        assert await f.read(10_000_000) == b"short data"
        assert await f.read(65536) == b""
        f.seek(0)
        assert await f.read(None) == b"short data"

    async with async_open(temp_file, "r") as f:
        assert await f.read(0) == ""
        assert await f.read(10_000_000) == "short data"
        assert await f.read(65536) == ""
        f.seek(0)
        assert await f.read(None) == "short data"


async def test_utf8_multibyte_cut_after_first_byte(temp_file):
    # "한" is 3 bytes (\xed\x95\x9c), followed by "a" (1 byte)
    async with async_open(temp_file, "w") as f:
        await f.write("한a🏁b")

    async with async_open(temp_file, "r") as f:
        assert await f.read(1) == "한"
        assert await f.read(1) == "a"
        assert await f.read(1) == "🏁"
        assert await f.read(1) == "b"
        assert await f.read(1) == ""


async def test_binary_write_bytearray_and_memoryview(temp_file):
    async with async_open(temp_file, "wb") as f:
        assert await f.write(bytearray(b"hello ")) == 6
        mv = memoryview(b"world!")[0:5]
        assert await f.write(mv) == 5

    async with async_open(temp_file, "rb") as f:
        assert await f.read() == b"hello world"


async def test_pathlike_and_bytes_paths(tmp_path):
    class CustomPath(os.PathLike):
        def __init__(self, p):
            self._p = str(p)

        def __fspath__(self):
            return self._p

    target = tmp_path / "custom_path.bin"
    async with async_open(CustomPath(target), "wb") as f:
        await f.write(b"from-pathlike")

    async with async_open(os.fsencode(target), "rb") as f:
        assert await f.read() == b"from-pathlike"


async def test_close_flush_closed_name_fileno(temp_file):
    async with async_open(temp_file, "w+b") as f:
        assert f.name == temp_file
        assert f.path == temp_file
        assert f.buffer_size == 65536
        assert not f.closed
        assert f.fileno() >= 0
        await f.write(b"abc")
        await f.flush()
        await f.close()
        assert f.closed
        with pytest.raises(ValueError, match="closed file"):
            await f.read()
        with pytest.raises(ValueError, match="closed file"):
            await f.write(b"x")
        with pytest.raises(ValueError, match="closed file"):
            f.seek(0)
        with pytest.raises(ValueError, match="closed file"):
            f.tell()
        with pytest.raises(ValueError, match="closed file"):
            f.fileno()


async def test_readline_readlines_writelines(temp_file):
    lines_txt = ["first line\n", "second line 🚀\n", "third line"]
    async with async_open(temp_file, "w") as f:
        await f.writelines(lines_txt)

    async with async_open(temp_file, "r") as f:
        assert await f.readline() == "first line\n"
        assert await f.readline(6) == "second"
        assert await f.readline() == " line 🚀\n"
        assert await f.readline() == "third line"
        assert await f.readline() == ""
        f.seek(0)
        assert await f.readlines() == lines_txt

    lines_bin = [b"alpha\n", b"beta\n", b"gamma"]
    async with async_open(temp_file, "wb") as f:
        await f.writelines(lines_bin)

    async with async_open(temp_file, "rb") as f:
        assert await f.readline() == b"alpha\n"
        assert await f.readline(2) == b"be"
        assert await f.readline() == b"ta\n"
        assert await f.readline() == b"gamma"
        assert await f.readline() == b""
        f.seek(0)
        assert await f.readlines() == lines_bin
