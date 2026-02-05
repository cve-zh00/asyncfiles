import asyncio
import hashlib
import os

import aiofiles
import uvloop
from aiofile import async_open

from asyncfiles import open as open_asyncfiles
from benchmark import Benchmark

# asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

MB = 1048576
TEST_FILES = {
    "small": ("small_test.txt", int(MB / 1024)),  # 1KB
    "medium": ("medium_test.txt", 5 * MB),  # 1MB
    "large": ("large_test.txt", 10 * MB),  # 10MB
}


def create_test_files():
    """Crear archivos de prueba con diferentes tamaños"""
    print("Creando archivos de prueba...")
    for name, (filename, size) in TEST_FILES.items():
        content = "x" * size
        with open(filename, "w") as f:
            f.write(content)
        print(f"  {filename}: {size} bytes ({size / 1024:.1f} KB)")
    print("Archivos creados.\n")


def calculate_hash(data):
    """Calcular hash MD5 de los datos para comparación"""
    if isinstance(data, str):
        data = data.encode("utf-8")
    return hashlib.md5(data).hexdigest()


async def verify_content_match(filename):
    """Verificar que todas las implementaciones devuelvan el mismo contenido"""
    try:
        # Leer con aiofile
        async with async_open(filename, mode="r") as f:
            aiofile_content = await f.read()

        async with open_asyncfiles(filename, mode="r") as f:
            asyncfiles_content = await f.read()

        # Leer con aiofiles
        async with aiofiles.open(filename, mode="r") as f:
            aiofiles_content = await f.read()

        # Comparar contenido
        content_match = aiofile_content == asyncfiles_content == aiofiles_content
        hash_aio = calculate_hash(aiofile_content)
        hash_async = calculate_hash(asyncfiles_content)
        hash_aiofiles = calculate_hash(aiofiles_content)
        hash_match = hash_aio == hash_async == hash_aiofiles
        print(len(asyncfiles_content))
        return {
            "content_match": content_match,
            "hash_match": hash_match,
            "aiofile_length": len(aiofile_content),
            "asyncfiles_length": len(asyncfiles_content),
            "aiofiles_length": len(aiofiles_content),
        }
    except Exception as e:
        return {"error": str(e), "content_match": False, "hash_match": False}


async def benchmark_aiofile(filename):
    """Benchmark usando aiofile"""
    async with async_open(filename, mode="r") as f:
        contents = await f.read()
    return len(contents)


async def benchmark_asyncfiles(filename):
    """Benchmark usando asyncfiles"""
    async with open_asyncfiles(filename) as f:
        data = await f.read()

    return len(data)


async def benchmark_aiofiles(filename):
    """Benchmark usando aiofiles"""
    async with aiofiles.open(filename, mode="r") as f:
        contents = await f.read()
    return len(contents)


async def benchmark_stdlib_async(filename):
    """Benchmark usando stdlib con asyncio.to_thread"""

    def stdlib_read():
        with open(filename, "r") as fp:
            return fp.read()

    result = await asyncio.to_thread(stdlib_read)
    return len(result)


async def main():
    """Función principal del benchmark"""
    print("=== Benchmark: asyncfiles vs aiofile vs aiofiles vs stdlib_async ===\n")

    # Crear archivos de prueba
    create_test_files()

    # Verificar contenido
    print("\n=== VERIFICACIÓN DE CONTENIDO ===")
    content_issues = False
    for file_type, (filename, size) in TEST_FILES.items():
        print(f"Verificando contenido de {filename}...")
        verification = await verify_content_match(filename)

        if verification.get("content_match", False):
            print("  ✓ Contenido idéntico")
        else:
            print("  ✗ Contenido difiere!")
            content_issues = True
            if "error" in verification:
                print(f"    Error: {verification['error']}")

    if content_issues:
        print("\n⚠️  ADVERTENCIA: Las implementaciones devuelven contenido diferente!")
        return
    else:
        print("\n✓ Todas las implementaciones devuelven contenido idéntico.\n")

    # Benchmark para cada tamaño de archivo
    for file_type, (filename, size) in TEST_FILES.items():
        print(f"\n{'=' * 60}")
        print(f"BENCHMARK: {file_type.upper()} ({filename})")
        print(f"{'=' * 60}\n")

        bench = Benchmark(f"{file_type}_file_benchmark")

        # Agregar implementaciones
        bench.add_implementation(
            "asyncfiles", lambda f=filename: benchmark_asyncfiles(f)
        )

        bench.add_implementation("aiofile", lambda f=filename: benchmark_aiofile(f))

        bench.add_implementation("aiofiles", lambda f=filename: benchmark_aiofiles(f))

        bench.add_implementation(
            "stdlib_async", lambda f=filename: benchmark_stdlib_async(f)
        )

        # Ejecutar benchmark
        results = await bench._run(iterations=10, max_concurrency=500)
        bench.print_summary(results)

    # Limpiar archivos de prueba
    print("\nLimpiando archivos de prueba...")
    for _, (filename, _) in TEST_FILES.items():
        if os.path.exists(filename):
            os.remove(filename)
    print("✓ Limpieza completada")


if __name__ == "__main__":
    asyncio.run(main())
