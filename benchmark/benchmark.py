from typing import Callable, Dict, List, Any
import asyncio
import time
from tabulate import tabulate
import psutil
import threading



class Benchmark:

    def __init__(self, name:str) -> None:
        self.name = name
        self._implementations:Dict[str, Dict[str, Any]] = {}
        self._monitoring = False
        self._cpu_usage = []
        self._memory_usage = []

    def add_implementation(self,  name_framework: str, prepared_callable: Callable) -> None:
        self._implementations[name_framework] = {
            'func': prepared_callable,
            'args': (),
            'kwargs': {}
        }

    def _monitor_resources(self):
        """Monitor CPU and memory usage in a separate thread"""
        process = psutil.Process()
        while self._monitoring:
            cpu_percent = process.cpu_percent()
            memory_mb = process.memory_info().rss / 1024 / 1024  # Convert to MB
            self._cpu_usage.append(cpu_percent)
            self._memory_usage.append(memory_mb)
            time.sleep(0.1)  # Sample every 100ms

    async def run_gather(self, max_concurrency:int, impl_data: Dict[str, Any]) -> Dict[str, Any]:
        func = impl_data['func']
        args = impl_data['args']
        kwargs = impl_data['kwargs']

        # Reset monitoring data
        self._cpu_usage = []
        self._memory_usage = []

        # Start monitoring
        self._monitoring = True
        monitor_thread = threading.Thread(target=self._monitor_resources)
        monitor_thread.start()

        start_time = time.time()
        await asyncio.gather(*[func(*args, **kwargs) for _ in range(max_concurrency)])
        end_time = time.time()

        # Stop monitoring
        self._monitoring = False
        monitor_thread.join()

        # Calculate metrics
        elapsed_time = end_time - start_time
        avg_cpu = sum(self._cpu_usage) / len(self._cpu_usage) if self._cpu_usage else 0
        max_cpu = max(self._cpu_usage) if self._cpu_usage else 0
        avg_memory = sum(self._memory_usage) / len(self._memory_usage) if self._memory_usage else 0
        max_memory = max(self._memory_usage) if self._memory_usage else 0

        return {
            'time': elapsed_time,
            'avg_cpu': avg_cpu,
            'max_cpu': max_cpu,
            'avg_memory': avg_memory,
            'max_memory': max_memory
        }
    def run(self, iterations:int, max_concurrency:int):
        asyncio.run(self._run(iterations, max_concurrency))

    async def _run(self, iterations:int, max_concurrency:int) -> Dict[str, Dict[str, List[float]]]:
        results = {}

        for name, impl_data in self._implementations.items():
            print(f"Running benchmark for {name}...")
            times = []
            avg_cpus = []
            max_cpus = []
            avg_memories = []
            max_memories = []

            for iteration in range(iterations):
                metrics = await self.run_gather(max_concurrency, impl_data)
                times.append(metrics['time'])
                avg_cpus.append(metrics['avg_cpu'])
                max_cpus.append(metrics['max_cpu'])
                avg_memories.append(metrics['avg_memory'])
                max_memories.append(metrics['max_memory'])

                print(f"  Iteration {iteration + 1}/{iterations}: {metrics['time']:.4f}s | "
                      f"CPU: {metrics['avg_cpu']:.1f}% | Memory: {metrics['avg_memory']:.1f}MB")

            results[name] = {
                'times': times,
                'avg_cpus': avg_cpus,
                'max_cpus': max_cpus,
                'avg_memories': avg_memories,
                'max_memories': max_memories
            }

            print()

        return results

    def print_summary(self, results: Dict[str, Dict[str, List[float]]]) -> None:
        print(f"=== Benchmark Summary: {self.name} ===")

        # Prepare data for tabulate
        table_data = []
        headers = ["Implementation", "Avg Time (s)", "Min Time (s)", "Max Time (s)",
                  "Avg CPU (%)", "Max CPU (%)", "Avg Memory (MB)", "Max Memory (MB)", "Iterations"]

        for name, metrics in results.items():
            times = metrics['times']
            avg_cpus = metrics['avg_cpus']
            max_cpus = metrics['max_cpus']
            avg_memories = metrics['avg_memories']
            max_memories = metrics['max_memories']

            avg_time = sum(times) / len(times)
            min_time = min(times)
            max_time = max(times)
            avg_cpu = sum(avg_cpus) / len(avg_cpus)
            max_cpu = max(max_cpus)
            avg_memory = sum(avg_memories) / len(avg_memories)
            max_memory = max(max_memories)
            iterations = len(times)

            table_data.append([
                name,
                f"{avg_time:.4f}",
                f"{min_time:.4f}",
                f"{max_time:.4f}",
                f"{avg_cpu:.1f}",
                f"{max_cpu:.1f}",
                f"{avg_memory:.1f}",
                f"{max_memory:.1f}",
                iterations
            ])

        #sort by avg_time
        table_data.sort(key=lambda x: x[1])

        print(tabulate(table_data, headers=headers, tablefmt="github"))
        print()
