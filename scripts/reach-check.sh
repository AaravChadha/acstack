#!/usr/bin/env bash
# Reachability for work named as owed (PLAN 4.47).
#
# Why this exists: AGENTS.md's third verification rule — "anything named as
# needed work gets a carrier task in the same edit" — has been broken three
# times, and a human-driven audit caught it every time. Three cross-cutting
# rules bound with nobody owning them; two proposed skills named in analysis
# and never scheduled; then `b566654`'s regression debt, written as owed in
# both JOURNAL.md and inside 4.42's CLOSED task text, with no open task
# carrying it and four tool calls to establish by hand. A rule enforced only
# by remembering to look is not enforced.
#
# Usage: scripts/reach-check.sh FILE...
#
# The convention this enforces: when you write that something is owed, tag
# it with its carrier.
#
#     [owed: 4.50]                     -> task 4.50 must EXIST and be OPEN
#     [owed: declined — <reason>]      -> deliberately not carried, reason required
#
# Both failure modes the rule has actually produced are covered: a carrier
# that does not exist (a dangling reference) and a carrier that is already
# closed (the work is owed to a task that can no longer do it).
#
# HONEST SCOPE — measured, not assumed. An unmarked "this owes X" sentence
# in prose is invisible here. Checking prose was tried first and rejected on
# evidence: matching bare `N.NN` references across PLAN.md and JOURNAL.md
# produced six unresolved values on a clean tree (2026-08-06), every one an
# incidental numeric — `1.3% of a 200k window`, VERSION `0.4.0`, a `1:1`
# ratio. Widening the pattern to catch real references means chasing those,
# which is a denylist and cannot be finished (the section 13 ruling). So a
# clean run means "every MARKED obligation has a live carrier", never "no
# work is owed without one". That limit is printed on every run.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

fail=0
checked=0

open_tasks="$(grep -oE '^- \[ \] \*\*[0-9]+\.[0-9]+\*\*' PLAN.md | grep -oE '[0-9]+\.[0-9]+' | sort -u)"
all_tasks="$(grep -oE '^- \[[ x]\] \*\*[0-9]+\.[0-9]+\*\*' PLAN.md | grep -oE '[0-9]+\.[0-9]+' | sort -u)"

for f in "$@"; do
  if [ ! -f "$f" ]; then
    echo "FAIL reach: $f does not exist — a file carrying owed-markers was moved or deleted"
    fail=1; continue
  fi
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    ln="${hit%%:*}"
    rest="${hit#*:}"
    body="${rest#*owed:}"; body="${body%%]*}"
    # strip surrounding whitespace
    body="${body#"${body%%[![:space:]]*}"}"; body="${body%"${body##*[![:space:]]}"}"
    checked=$((checked+1))
    case "$body" in
      declined*)
        reason="${body#declined}"
        # require an actual reason after the marker word, not a bare "declined"
        if [ -z "$(printf '%s' "$reason" | tr -d '[:space:]:—-')" ]; then
          echo "FAIL reach: $f:$ln  [owed: declined] carries no reason — a decline without one is an orphan wearing a label"
          fail=1
        fi
        ;;
      [0-9]*)
        if ! printf '%s\n' "$all_tasks" | grep -qx "$body"; then
          echo "FAIL reach: $f:$ln  [owed: $body] names a task that does not exist in PLAN.md"
          fail=1
        elif ! printf '%s\n' "$open_tasks" | grep -qx "$body"; then
          echo "FAIL reach: $f:$ln  [owed: $body] names task $body, which is CLOSED — the work is owed to a task that can no longer do it"
          fail=1
        fi
        ;;
      *)
        echo "FAIL reach: $f:$ln  [owed: $body] is neither a task number nor a decline — the carrier is unreadable"
        fail=1
        ;;
    esac
  done < <(grep -noE '\[owed:[^]]*\]' "$f" || true)
done

if [ "$fail" -eq 0 ]; then
  echo "reach-check: $checked owed-marker(s) carried — UNMARKED owed-prose is NOT checked"
else
  exit 1
fi
