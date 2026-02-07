import asyncio
import hashlib
import os

import aiofiles
import anyio
from aiofile import async_open

from asyncfiles import open as open_asyncfiles
from benchmark import Benchmark

MB = 1048576
TEST_CONFIGS = {
    "small": ("write_small_test.txt", int(MB / 1024)),  # 1KB
    "large": ("write_large_test.txt", MB),  # 10MB
}


def generate_test_content(size):
    """Generar contenido de prueba"""
    return "x" * size


def calculate_hash(data):
    """Calcular hash MD5 de los datos para comparación"""
    if isinstance(data, str):
        data = data.encode("utf-8")
    return hashlib.md5(data).hexdigest()


async def verify_written_content(filename, expected_content):
    """Verificar que el contenido escrito sea correcto"""
    try:
        with open(filename, "r") as f:
            written_content = f.read()

        content_match = written_content == expected_content
        hash_expected = calculate_hash(expected_content)
        hash_written = calculate_hash(written_content)
        hash_match = hash_expected == hash_written

        return {
            "content_match": content_match,
            "hash_match": hash_match,
            "expected_length": len(expected_content),
            "written_length": len(written_content),
        }
    except Exception as e:
        return {"error": str(e), "content_match": False, "hash_match": False}


async def benchmark_aiofile_write(filename, content):
    """Benchmark escritura usando aiofile"""
    async with async_open(filename, mode="w") as f:
        await f.write(content)
    return len(content)


async def benchmark_asyncfiles_write(filename, content):
    """Benchmark escritura usando asyncfiles"""
    async with open_asyncfiles(filename, "w") as f:
        await f.write(content)
    return len(content)


async def benchmark_aiofiles_write(filename, content):
    """Benchmark escritura usando aiofiles"""
    async with aiofiles.open(filename, mode="w") as f:
        await f.write(content)
    return len(content)


async def benchmark_anyio_write(filename, content):
    """Benchmark escritura usando anyio"""
    async with await anyio.open_file(filename, mode="w") as f:
        await f.write(content)
    return len(content)


async def main():
    """Función principal del benchmark de escritura"""
    print("=== Benchmark ESCRITURA: asyncfiles vs aiofile vs aiofiles vs anyio ===\n")

    # Crear carpeta de resultados
    results_dir = "benchmark/results"
    os.makedirs(results_dir, exist_ok=True)

    # Variable para almacenar el README completo
    full_markdown = "# Write Benchmark Results\n\n"
    full_markdown += "This document contains the benchmark results for write operations using different async file I/O libraries.\n\n"
    full_markdown += "## Test Configuration\n\n"
    full_markdown += "- **Iterations**: 20\n"
    full_markdown += "- **Concurrency**: 10\n"
    full_markdown += "- **Libraries Tested**: asyncfiles, aiofile, aiofiles, anyio\n\n"

    # Benchmark para cada tamaño de archivo
    for file_type, (filename, size) in TEST_CONFIGS.items():
        print(f"\n{'=' * 60}")
        print(f"BENCHMARK ESCRITURA: {file_type.upper()} ({size / 1024:.1f} KB)")
        print(f"{'=' * 60}\n")

        content = generate_test_content(size)

        bench = Benchmark(f"{file_type}_file_write")

        # Agregar implementaciones
        bench.add_implementation(
            "asyncfiles", lambda f=filename, c=content: benchmark_asyncfiles_write(f, c)
        )

        bench.add_implementation(
            "aiofile", lambda f=filename, c=content: benchmark_aiofile_write(f, c)
        )

        bench.add_implementation(
            "aiofiles", lambda f=filename, c=content: benchmark_aiofiles_write(f, c)
        )

        bench.add_implementation(
            "anyio",
            lambda f=filename, c=content: benchmark_anyio_write(f, c),
        )

        # Ejecutar benchmark
        results = await bench._run(iterations=20, max_concurrency=100)
        bench.print_summary(results)

        # Agregar resultados al markdown
        file_size_mb = size / (1024 * 1024)
        section_md = bench.generate_markdown_summary(results, file_size_mb)
        full_markdown += f"\n---\n\n{section_md}\n"

        # Verificar contenido escrito (usar la última versión)
        print(f"\nVerificando contenido escrito en {filename}...")
        verification = await verify_written_content(filename, content)

        if verification.get("content_match", False):
            print(f"  ✓ Contenido escrito correctamente")
        else:
            print(f"  ✗ Contenido incorrecto!")
            if "error" in verification:
                print(f"    Error: {verification['error']}")
            else:
                print(f"    Esperado: {verification['expected_length']} chars")
                print(f"    Escrito: {verification['written_length']} chars")

    # Guardar README.md
    readme_path = os.path.join(results_dir, "WRITE_BENCHMARK.md")
    with open(readme_path, "w") as f:
        f.write(full_markdown)

    print(f"\n✓ Resultados guardados en: {readme_path}")

    # Limpiar archivos de prueba
    print("\n\nLimpiando archivos de prueba...")
    for _, (filename, _) in TEST_CONFIGS.items():
        if os.path.exists(filename):
            os.remove(filename)
            print(f"  ✓ {filename} eliminado")
    print("\n✓ Limpieza completada")


if __name__ == "__main__":
    asyncio.run(main())
