#!/usr/bin/env bash
# The guard matrix as N parallel local shards (default 4): the pre-push slow
# tier (5.20.2). It exits non-zero when ANY shard fails. A bare `wait` with
# no job ids returns 0 however its jobs ended, which is how the one-line
# version first written into CONTRIBUTING.md could report a failing matrix
# as a pass (found by a Codex review, 2026-09-24); each shard is waited on by
# its own pid here. A script rather than a pasted line also keeps it out of
# the user's shell: zsh does not word-split an unquoted variable, so a
# one-liner that collects pids in a string behaves differently there.
# Each shard asserts its own case count, and check.sh §39 proves the
# partition covers every case.
#   usage: bash scripts/matrix.sh [shards]
set -uo pipefail
n="${1:-4}"
case "$n" in
  '' | *[!0-9]* | 0) echo "usage: bash scripts/matrix.sh [shards, default 4]" >&2; exit 2 ;;
esac
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
logs="$(mktemp -d)"
pids=()
for i in $(seq 1 "$n"); do
  bash "$repo/docs/guard-matrix.sh" "$repo" --shard "$i/$n" > "$logs/shard$i.log" 2>&1 &
  pids+=("$!")
done
rc=0
for i in $(seq 1 "$n"); do
  if ! wait "${pids[$((i - 1))]}"; then
    rc=1
    echo "shard $i/$n FAILED:"
    grep '  BAD ' "$logs/shard$i.log" || tail -n 5 "$logs/shard$i.log"
  fi
  tail -n 1 "$logs/shard$i.log"
done
if [ "$rc" -eq 0 ]; then
  echo "matrix: all $n shards passed (logs in $logs)"
else
  echo "matrix: FAILED (logs in $logs)"
fi
exit "$rc"
