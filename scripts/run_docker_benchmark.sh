#!/usr/bin/env bash
# Run the read/write benchmark in a single resource-limited container
# (2 CPUs / 1 GB RAM) and write benchmark/results/benchmark_{read,write}.md.
#
# Usage:
#   scripts/run_docker_benchmark.sh [-- <benchmark args>]
#
# Optional env vars:
#   IO_DEVICE      block device inside the Docker VM to throttle (e.g. /dev/vda)
#   IO_READ_BPS    read limit  (e.g. 50mb)   requires IO_DEVICE
#   IO_WRITE_BPS   write limit (e.g. 30mb)   requires IO_DEVICE
#   SECCOMP        "unconfined" (default, needed for io_uring) or "default"
set -euo pipefail

cd "$(dirname "$0")/.."

IMAGE=asyncfiles-bench
CPUS=2
MEM=1g
SECCOMP=${SECCOMP:-unconfined}
RESULTS_DIR="$PWD/benchmark/results"
mkdir -p "$RESULTS_DIR"

[[ "${1:-}" == "--" ]] && shift

docker build -f Dockerfile.benchmark -t "$IMAGE" .

vol="asyncfiles-bench-$$"
cname="asyncfiles-bench-$$"
docker volume create "$vol" >/dev/null
trap 'docker rm -f "$cname" >/dev/null 2>&1 || true; docker volume rm "$vol" >/dev/null 2>&1 || true' EXIT

io_flags=()
if [[ -n "${IO_DEVICE:-}" ]]; then
  [[ -n "${IO_READ_BPS:-}" ]] && io_flags+=(--device-read-bps "$IO_DEVICE:$IO_READ_BPS")
  [[ -n "${IO_WRITE_BPS:-}" ]] && io_flags+=(--device-write-bps "$IO_DEVICE:$IO_WRITE_BPS")
fi

echo ">>> cpus=$CPUS memory=$MEM seccomp=$SECCOMP ${io_flags[*]:-}"
docker run --name "$cname" \
  --cpus "$CPUS" \
  --memory "$MEM" --memory-swap "$MEM" \
  --pids-limit 256 \
  --ulimit nofile=4096:4096 \
  --security-opt "seccomp=$SECCOMP" \
  ${io_flags[@]+"${io_flags[@]}"} \
  -v "$vol:/bench" \
  "$IMAGE" --dir /bench --output /results "$@"

docker cp "$cname:/results/benchmark_read.md" "$RESULTS_DIR/benchmark_read.md"
docker cp "$cname:/results/benchmark_write.md" "$RESULTS_DIR/benchmark_write.md"

echo "Results in $RESULTS_DIR/benchmark_read.md and benchmark_write.md"
