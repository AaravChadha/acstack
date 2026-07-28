#!/usr/bin/env bash
# acstack pack guard — run before committing pack changes (CI runs it too).
# Checks: principles-block byte-identity, banned personal/client names,
# frontmatter safety (description YAML hazards, name vs directory),
# SKILL.md line budgets, shell syntax.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"
fail=0
skipped=0

extract_principles() {
  awk '/<!-- acstack:principles -->/{f=1} f{print} /<!-- \/acstack:principles -->/{f=0}' "$1"
}

# 1. Principles block: canonical copy lives in README.md; every SKILL.md
#    must match it byte-for-byte.
canon="$(extract_principles README.md)"
if [ -z "$canon" ]; then
  echo "FAIL principles: README.md has no acstack:principles block (canonical copy required)"
  fail=1
else
  for f in skills/*/SKILL.md; do
    if ! diff <(printf '%s\n' "$canon") <(extract_principles "$f") >/dev/null; then
      echo "FAIL principles: $f drifts from README canonical block"
      fail=1
    fi
  done
fi

# 2. Banned names: client/collaborator/project-specific terms must never
#    appear in pack content. Word-boundary, case-insensitive.
#    The list itself lives OUTSIDE the tracked tree: it names the clients and
#    collaborators being protected, so committing it publishes exactly what it
#    guards. Until 2026-07-29 this script hardcoded a real roster AND excluded
#    scripts/ from its own sweep, so it could never catch itself.
BANNED_FILE="${ACSTACK_BANNED_FILE:-.acstack-banned}"
[ -f "$BANNED_FILE" ] || BANNED_FILE="$HOME/.claude/acstack-banned"
if [ ! -f "$BANNED_FILE" ]; then
  echo "SKIP banned names: no list found (.acstack-banned or ~/.claude/acstack-banned)."
  echo "     Copy .acstack-banned.example and edit it. A missing list is NOT a pass —"
  echo "     nothing was checked."
  skipped=$((skipped + 1))
else
  BANNED="$(grep -vE '^\s*(#|$)' "$BANNED_FILE" | paste -sd'|' -)"
  if [ -z "$BANNED" ]; then
    echo "SKIP banned names: $BANNED_FILE has no entries — nothing was checked."
    skipped=$((skipped + 1))
  elif hits="$(grep -riEnw "$BANNED" \
        skills/ templates/ docs/ scripts/ setup \
        CONDUCT.md README.md AGENTS.md PLAN.md JOURNAL.md 2>/dev/null)"; then
    echo "FAIL banned names:"
    printf '%s\n' "$hits"
    fail=1
  fi
fi

# 3. Frontmatter description safety. An unquoted YAML scalar ends at " #"
#    (comment) and is ambiguous at ": ". /ship shipped truncated at
#    "wiring Fixes #N" — losing its whole trigger sentence — so this is
#    guarded, not trusted to review.
for f in skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$f")")"
  name="$(sed -n 's/^name: *//p' "$f" | head -1)"
  desc="$(sed -n 's/^description: //p' "$f" | head -1)"

  # name must match its directory — a mismatch installs under one name and
  # advertises another.
  if [ "$name" != "$dir" ]; then
    echo "FAIL frontmatter: $f declares name '$name' but lives in skills/$dir/"
    fail=1
  fi
  if [ -z "$desc" ]; then
    echo "FAIL frontmatter: $f has no description"
    fail=1
    continue
  fi

  case "$desc" in
    '"'*'"'|"'"*"'") continue ;;              # properly quoted, both ends
    '"'*|"'"*)
      echo "FAIL description: $f opens a quote it never closes on the same line"
      fail=1; continue ;;
    '#'*)                                     # leading # = whole value is a comment
      echo "FAIL description: $f starts with '#' — YAML reads the value as null"
      fail=1; continue ;;
  esac
  if printf '%s' "$desc" | grep -q ' #'; then
    echo "FAIL description: $f has an unquoted ' #' — YAML truncates it into a comment"
    fail=1
  fi
  if printf '%s' "$desc" | grep -q ': '; then
    echo "FAIL description: $f has an unquoted ': ' — quote the description"
    fail=1
  fi
done

# 4. SKILL.md line budget (< 500 per Claude Code guidance).
for f in skills/*/SKILL.md; do
  lines="$(wc -l < "$f" | tr -d ' ')"
  if [ "$lines" -ge 500 ]; then
    echo "FAIL budget: $f is $lines lines (limit 500)"
    fail=1
  fi
done

# 5. Shell syntax (+ shellcheck when available).
for s in setup scripts/check.sh; do
  bash -n "$s" || { echo "FAIL syntax: $s"; fail=1; }
done
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning setup scripts/check.sh || fail=1
fi

if [ "$fail" -eq 0 ]; then
  if [ "$skipped" -gt 0 ]; then
    echo "check.sh: no failures, but $skipped check(s) SKIPPED — coverage is incomplete"
  else
    echo "check.sh: all clean"
  fi
else
  exit 1
fi
