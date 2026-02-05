import asyncio
import cProfile
import pstats

from asyncfiles import open


async def main():
    async with open("example.txt", "r") as f:
        await f.read()


def run():
    for i in range(10):
        asyncio.run(main())



if __name__ == "__main__":
    profiler = cProfile.Profile()
    profiler.enable()

    run()

    profiler.disable()

    stats = pstats.Stats(profiler)
    stats.sort_stats("cumtime").print_stats(30)
