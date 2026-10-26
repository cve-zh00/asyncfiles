#!/usr/bin/env bash
# Run the read/write benchmark inside resource-limited containers.
#
# Usage:
#   scripts/run_docker_benchmark.sh [profile ...] [-- <benchmark args>]
#
# Profiles (cpus / memory): tiny=0.5/256m  small=1/512m  medium=2/1g
# Optional env vars:
#   IO_DEVICE      block device inside the Docker VM to throttle (e.g. /dev/vda)
#   IO_READ_BPS    read limit  (e.g. 50mb)   requires IO_DEVICE
#   IO_WRITE_BPS   write limit (e.g. 30mb)   requires IO_DEVICE
#   SECCOMP        "unconfined" (default, needed for io_uring) or "default"
set -euo pipefail

cd "$(dirname "$0")/.."

IMAGE=asyncfiles-bench
SECCOMP=${SECCOMP:-unconfined}
RESULTS_DIR="$PWD/benchmark/results/docker"
mkdir -p "$RESULTS_DIR"

profiles=()
while [[ $# -gt 0 && "$1" != "--" ]]; do profiles+=("$1"); shift; done
[[ "${1:-}" == "--" ]] && shift
[[ ${#profiles[@]} -eq 0 ]] && profiles=(tiny small medium)

declare_profile() {
  case "$1" in
    tiny)   CPUS=0.5; MEM=256m ;;
    small)  CPUS=1;   MEM=512m ;;
    medium) CPUS=2;   MEM=1g ;;
    *) echo "unknown profile: $1" >&2; exit 1 ;;
  esac
}

docker build -f Dockerfile.benchmark -t "$IMAGE" .

for profile in "${profiles[@]}"; do
  declare_profile "$profile"
  vol="asyncfiles-bench-$profile"
  cname="asyncfiles-bench-$profile-$$"
  docker volume create "$vol" >/dev/null

  io_flags=()
  if [[ -n "${IO_DEVICE:-}" ]]; then
    [[ -n "${IO_READ_BPS:-}" ]] && io_flags+=(--device-read-bps "$IO_DEVICE:$IO_READ_BPS")
    [[ -n "${IO_WRITE_BPS:-}" ]] && io_flags+=(--device-write-bps "$IO_DEVICE:$IO_WRITE_BPS")
  fi

  echo ">>> profile=$profile cpus=$CPUS memory=$MEM seccomp=$SECCOMP ${io_flags[*]:-}"
  docker run --name "$cname" \
    --cpus "$CPUS" \
    --memory "$MEM" --memory-swap "$MEM" \
    --pids-limit 256 \
    --ulimit nofile=4096:4096 \
    --security-opt "seccomp=$SECCOMP" \
    ${io_flags[@]+"${io_flags[@]}"} \
    -e BENCH_LABEL="$profile" \
    -v "$vol:/bench" \
    "$IMAGE" --dir /bench --output /results "$@"

  docker cp "$cname:/results/." "$RESULTS_DIR/" || true
  docker rm "$cname" >/dev/null
  docker volume rm "$vol" >/dev/null
done

echo "Results in $RESULTS_DIR"
