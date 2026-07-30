#!/usr/bin/env bash
# Positive controls for the check-shaped skills (PLAN 4.15).
# Each control re-runs a skill's DOCUMENTED detection command against a
# fixture seeded with a known instance of what the skill must catch, and
# fails when the command misses the plant. Non-trivial patterns are
# EXTRACTED from the reference files at run time, so editing a documented
# command edits what gets tested — a regressed pattern fails HERE, not
# silently in the field (the sk-live false-pass class). Trivial patterns
# (^!, pointer equality) are restated inline; no drift surface worth
# extracting. /qa's control needs a live server and lives in
# fixtures/qa/README.md as a shakedown procedure instead.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
fail=0
ok()  { printf '  ok   %s\n' "$1"; }
bad() { printf '  FAIL control: %s\n' "$1"; fail=1; }

# --- /secure: planted key shapes (extracted) + negation trap (inline) ---
line="$(grep -F "git grep -nE '(sk[-_]" skills/secure/references/security-surfaces.md | head -1 || true)"
pat="${line#*\'}"; pat="${pat%%\'*}"
if [ -z "$pat" ]; then bad "/secure key-shape pattern not extractable from security-surfaces.md"
elif grep -rqE "$pat" fixtures/secure/; then ok "/secure key-shape grep catches the planted keys"
else bad "/secure key-shape grep MISSED the planted keys (pattern: $pat)"; fi
if grep -q '^!' fixtures/secure/.gitignore; then ok "/secure negation-trap grep catches !.env"
else bad "/secure negation-trap grep missed the !.env plant"; fi

# --- /design-audit: palette, mock-data, slop (all extracted) ---
line="$(grep -F "git grep -nE '#[0-9a-fA-F]" skills/design-audit/references/design-conventions.md | head -1 || true)"
pat="${line#*\'}"; pat="${pat%%\'*}"
if [ -z "$pat" ]; then bad "/design-audit palette pattern not extractable"
elif grep -rqE "$pat" fixtures/design-audit/; then ok "/design-audit palette grep catches #ff00aa"
else bad "/design-audit palette grep MISSED the off-palette hex (pattern: $pat)"; fi

line="$(grep -F "git grep -niE '(faker|mockData" skills/design-audit/references/design-conventions.md | head -1 || true)"
pat="${line#*\'}"; pat="${pat%%\'*}"
if [ -z "$pat" ]; then bad "/design-audit mock-data pattern not extractable"
elif grep -riqE "$pat" fixtures/design-audit/; then ok "/design-audit mock-data grep catches mockData"
else bad "/design-audit mock-data grep MISSED the mockData plant (pattern: $pat)"; fi

line="$(grep -F "git grep -niEw '(simply" skills/design-audit/references/design-conventions.md | head -1 || true)"
pat="${line#*\'}"; pat="${pat%%\'*}"
if [ -z "$pat" ]; then bad "/design-audit slop pattern not extractable"
elif grep -riqEw "$pat" fixtures/design-audit/; then ok "/design-audit slop grep catches the hedge copy"
else bad "/design-audit slop grep MISSED the hedge copy (pattern: $pat)"; fi

# --- /health: pointer test + tracked .env-class plant (inline) ---
if [ "$(tr -d '\n' < fixtures/health/CLAUDE.md | head -c 12)" != "@AGENTS.md" ]; then
  ok "/health pointer test flags the non-pointer CLAUDE.md"
else bad "/health fixture CLAUDE.md became a clean pointer — plant lost"; fi
if [ -f fixtures/health/.env ]; then ok "/health .env-class plant present"
else bad "/health .env plant missing"; fi

# --- /audit: unicode-lookalike class + raw-compare pattern ---
if grep -rq "$(printf '\xe2\x80\x93')" fixtures/audit/ && grep -rq "$(printf '\xc2\xa0')" fixtures/audit/; then
  ok "/audit fixture carries the lookalike bytes (en dash, NBSP)"
else bad "/audit fixture lost its Unicode-lookalike plant"; fi
if grep -rqE 'if .* in .*:|\.includes\(' fixtures/audit/; then
  ok "/audit raw-compare pattern (known-bug-classes) fires on the fixture"
else bad "/audit raw-compare pattern missed the fixture"; fi

# --- /migrate-check: destructive classification vs planted statements ---
tbl="$(awk '/## Destructive/,/## Not SQL/' skills/migrate-check/references/sql-classification.md)"
for stmt in "DROP TABLE" "RENAME COLUMN"; do
  if ! grep -rqiF "$stmt" fixtures/migrate-check/; then
    bad "/migrate-check fixture lost its '$stmt' plant"
  elif printf '%s' "$tbl" | grep -qF "$stmt"; then
    ok "/migrate-check classification lists '$stmt' as destructive"
  else bad "/migrate-check destructive table no longer lists '$stmt'"; fi
done

echo
if [ "$fail" -eq 0 ]; then echo "controls.sh: all plants caught"
else echo "controls.sh: a documented check MISSED its plant — a false-pass in the making"; exit 1; fi
