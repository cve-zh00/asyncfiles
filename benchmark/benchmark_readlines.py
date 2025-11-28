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
    "small": ("small_lines_test.txt", 100),  # 100 lines
    "medium": ("medium_lines_test.txt", 1000),  # 1000 lines
    "large": ("large_lines_test.txt", 10000),  # 10000 lines
}


def create_test_files():
    """Crear archivos de prueba con diferentes cantidades de líneas"""
    print("Creando archivos de prueba...")
    for name, (filename, num_lines) in TEST_FILES.items():
        with open(filename, "w") as f:
            for i in range(num_lines):
                f.write(
                    f"This is line number {i} with some content to make it longer\n"
                )
        size = os.path.getsize(filename)
        print(f"  {filename}: {num_lines} líneas ({size / 1024:.1f} KB)")
    print("Archivos creados.\n")


def calculate_hash(lines):
    """Calcular hash MD5 de las líneas para comparación"""
    content = "".join(lines)
    if isinstance(content, str):
        content = content.encode("utf-8")
    return hashlib.md5(content).hexdigest()


async def verify_content_match(filename):
    """Verificar que todas las implementaciones devuelvan el mismo contenido"""
    try:
        # Leer con asyncfiles (iterador)
        asyncfiles_lines = []
        async with open_asyncfiles(filename, "r") as f:
            async for line in f:
                asyncfiles_lines.append(line)

        # Leer con aiofiles (readlines)
        async with aiofiles.open(filename, mode="r") as f:
            aiofiles_lines = await f.readlines()

        # Leer con stdlib
        def stdlib_readlines():
            with open(filename, "r") as fp:
                return fp.readlines()

        stdlib_lines = await asyncio.to_thread(stdlib_readlines)

        # Comparar contenido
        content_match = asyncfiles_lines == aiofiles_lines == stdlib_lines
        hash_asyncfiles = calculate_hash(asyncfiles_lines)
        hash_aiofiles = calculate_hash(aiofiles_lines)
        hash_stdlib = calculate_hash(stdlib_lines)
        hash_match = hash_asyncfiles == hash_aiofiles == hash_stdlib

        return {
            "content_match": content_match,
            "hash_match": hash_match,
            "asyncfiles_lines": len(asyncfiles_lines),
            "aiofiles_lines": len(aiofiles_lines),
            "stdlib_lines": len(stdlib_lines),
        }
    except Exception as e:
        return {"error": str(e), "content_match": False, "hash_match": False}


async def benchmark_asyncfiles_iterator(filename):
    """Benchmark usando asyncfiles con iterador"""
    lines = []
    async with open_asyncfiles(filename, "r") as f:
        async for line in f:
            lines.append(line)
    return len(lines)


async def benchmark_aiofiles_readlines(filename):
    """Benchmark usando aiofiles readlines"""
    async with aiofiles.open(filename, mode="r") as f:
        lines = await f.readlines()
    return len(lines)


async def benchmark_aiofiles_iterator(filename):
    """Benchmark usando aiofiles con iterador"""
    lines = []
    async with aiofiles.open(filename, mode="r") as f:
        async for line in f:
            lines.append(line)
    return len(lines)


async def benchmark_stdlib_async(filename):
    """Benchmark usando stdlib con asyncio.to_thread"""

    def stdlib_readlines():
        with open(filename, "r") as fp:
            return fp.readlines()

    result = await asyncio.to_thread(stdlib_readlines)
    return len(result)


async def main():
    """Función principal del benchmark"""
    print("=== Benchmark: Lectura de líneas (readlines/iterators) ===\n")

    # Crear archivos de prueba
    create_test_files()

    # Verificar contenido
    print("\n=== VERIFICACIÓN DE CONTENIDO ===")
    content_issues = False
    for file_type, (filename, num_lines) in TEST_FILES.items():
        print(f"Verificando contenido de {filename}...")
        verification = await verify_content_match(filename)

        if verification.get("content_match", False):
            print("  ✓ Contenido idéntico")
        else:
            print("  ✗ Contenido difiere!")
            content_issues = True
            if "error" in verification:
                print(f"    Error: {verification['error']}")
            else:
                print(
                    f"    asyncfiles: {verification.get('asyncfiles_lines', 0)} líneas"
                )
                print(f"    aiofiles: {verification.get('aiofiles_lines', 0)} líneas")
                print(f"    stdlib: {verification.get('stdlib_lines', 0)} líneas")

    if content_issues:
        print("\n⚠️  ADVERTENCIA: Las implementaciones devuelven contenido diferente!")
        return
    else:
        print("\n✓ Todas las implementaciones devuelven contenido idéntico.\n")

    # Benchmark para cada tamaño de archivo
    for file_type, (filename, num_lines) in TEST_FILES.items():
        print(f"\n{'=' * 60}")
        print(f"BENCHMARK: {file_type.upper()} ({filename} - {num_lines} líneas)")
        print(f"{'=' * 60}\n")

        bench = Benchmark(f"{file_type}_readlines_benchmark")

        # Agregar implementaciones
        bench.add_implementation(
            "asyncfiles_iterator", lambda f=filename: benchmark_asyncfiles_iterator(f)
        )

        bench.add_implementation(
            "aiofiles_readlines", lambda f=filename: benchmark_aiofiles_readlines(f)
        )

        bench.add_implementation(
            "aiofiles_iterator", lambda f=filename: benchmark_aiofiles_iterator(f)
        )

        bench.add_implementation(
            "stdlib_async", lambda f=filename: benchmark_stdlib_async(f)
        )

        # Ejecutar benchmark
        results = await bench._run(iterations=5, max_concurrency=10)
        bench.print_summary(results)

    # Limpiar archivos de prueba
    print("\nLimpiando archivos de prueba...")
    for _, (filename, _) in TEST_FILES.items():
        if os.path.exists(filename):
            os.remove(filename)
    print("✓ Limpieza completada")


if __name__ == "__main__":
    asyncio.run(main())
