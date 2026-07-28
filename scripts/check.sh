#!/usr/bin/env bash
# acstack pack guard — run before committing pack changes (CI runs it too).
# Checks: principles-block byte-identity, banned personal/client names,
# SKILL.md line budgets, shell syntax.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"
fail=0

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
BANNED='bajaj|finalyca|satyajit|neil|nuv|rm_assist|rm-assist|rm-research|canara|robeco|nutriscan|triage_ai'
if hits="$(grep -riEnw "$BANNED" skills/ templates/ docs/ CONDUCT.md README.md AGENTS.md PLAN.md JOURNAL.md 2>/dev/null)"; then
  echo "FAIL banned names:"
  printf '%s\n' "$hits"
  fail=1
fi

# 3. Frontmatter description safety. An unquoted YAML scalar ends at " #"
#    (comment) and is ambiguous at ": ". /ship shipped truncated at
#    "wiring Fixes #N" — losing its whole trigger sentence — so this is
#    guarded, not trusted to review.
for f in skills/*/SKILL.md; do
  desc="$(sed -n 's/^description: //p' "$f")"
  case "$desc" in
    '"'*|"'"*) continue ;;   # quoted: safe
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
  echo "check.sh: all clean"
else
  exit 1
fi
