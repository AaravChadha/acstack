#!/usr/bin/env bash
# Derive-and-compare for MARKED count claims (PLAN 4.48).
#
# Why this exists at all: a count duplicated outside its single enumeration
# goes stale. This repo produced six instances in three days (JOURNAL's
# "Twenty skills" vs 23, its 21/23 table row, its "35 open tasks" vs 21,
# PLAN's risk note saying "3 remain" then "Those four", ARCHITECTURE's
# enumeration, and PRINCIPLES' "fifteen numbered sections" — the last
# inside the principle *about* replacing prose with checks). /audit docs
# has carried "stale counts vs greppable reality" since it shipped and
# never once ran, because nobody types it without already suspecting
# drift. This does the mechanical half from check.sh, which runs before
# every commit.
#
# Usage: scripts/count-check.sh FILE...
#
# A claim is marked as:  <!-- count:skills -->23<!-- /count -->
#
# HONEST SCOPE. Only MARKED claims are checked. An unmarked count in prose
# is invisible here, so a clean run means "every marked count agrees with
# its derivation" and NEVER "this document has no stale numbers". A regex
# sweep for count-like prose would be a denylist and cannot be finished
# (the section 13 ruling, 2026-08-02); it is deliberately not attempted.
# An unknown count NAME is a failure, not a skip — a typo'd marker that
# silently verified nothing is the same false-pass class the guard exists
# to prevent.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

fail=0
verified=""

w45() { awk '/^## \[[ x]\] Wave 4\.5/,/^## \[[ x]\] Wave 5/' PLAN.md; }

# The enumerated set of derivable counts. Adding a marker with a name not
# listed here fails loudly rather than passing silently.
derive() {
  local n
  case "$1" in
    skills)         n=$(ls -1 skills 2>/dev/null | wc -l) ;;
    checks)         n=$(grep -cE '^# [0-9]+[a-z]?\. ' scripts/check.sh) ;;
    # Static count of case invocations. Verified 2026-08-06 to equal the
    # runtime `passed=` total (94); running the matrix here would cost
    # minutes on every commit, which is why this counts the source instead.
    matrix-cases)   n=$(grep -cE '^(fullcase|check|bannedcase) ' docs/guard-matrix.sh) ;;
    wave45-done)    n=$(w45 | grep -c '^- \[x\]') ;;
    wave45-open)    n=$(w45 | grep -c '^- \[ \]') ;;
    wave45-total)   n=$(w45 | grep -cE '^- \[[ x]\]') ;;
    open-scheduled) n=$(awk '/^## \[[ x]\] Wave 4\.5/,/^## \[[ x]\] Wave B/' PLAN.md \
                        | grep -c '^- \[ \]') ;;
    *)              return 1 ;;
  esac
  printf '%s' "$n" | tr -d '[:space:]'
}

for f in "$@"; do
  if [ ! -f "$f" ]; then
    echo "FAIL count: $f does not exist — a marked-count file was moved or deleted"
    fail=1; continue
  fi
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    ln="${hit%%:*}"
    rest="${hit#*:}"
    name="${rest#*count:}"; name="${name%% *}"
    val="${rest#*-->}";     val="${val%%<*}"
    if ! want="$(derive "$name")"; then
      echo "FAIL count: $f:$ln marks unknown count '$name' — no derivation exists, so this claim was never checked"
      fail=1; continue
    fi
    if [ "$val" != "$want" ]; then
      echo "FAIL count: $f:$ln  doc says $val / reality is $want  (count:$name)"
      fail=1
    else
      verified="$verified $name"
    fi
  done < <(grep -noE '<!-- count:[a-z0-9-]+ -->[0-9]+<!-- /count -->' "$f" || true)
done

if [ "$fail" -eq 0 ]; then
  if [ -n "$verified" ]; then
    names="$(printf '%s' "$verified" | tr ' ' '\n' | grep -v '^$' | sort -u | tr '\n' ' ')"
    echo "count-check: verified ${names%% } — unmarked counts are NOT checked"
  else
    echo "FAIL count: no marked counts found in the files given — the guard verified nothing"
    exit 1
  fi
else
  exit 1
fi
