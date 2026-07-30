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
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
fail=0
skipped=0
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

# --- multi-product: the detection command must find BOTH document sets ---
sets="$(find fixtures/multi-product -name PLAN.md | wc -l | tr -d ' ')"
if [ "$sets" -ge 2 ]; then ok "/health multi-product fixture carries $sets document sets"
else bad "/health multi-product fixture lost a document set (found $sets, need 2+)"; fi
if ls fixtures/multi-product/pnpm-workspace.yaml >/dev/null 2>&1; then
  ok "/health workspace-marker signal present in the fixture"
else bad "/health multi-product fixture lost its workspace marker"; fi

# --- /eval-run: the false-pass control (a runner that reports 100% is broken) ---
# NOTE: this executes eval/run.py, a tracked file a pull request can edit.
# Reviewing a fork branch? Read the fixtures/ and scripts/ diff BEFORE
# running the guard — see CONTRIBUTING.md.
if [ -f fixtures/eval-run/eval/run.py ] && command -v python3 >/dev/null 2>&1; then
  out="$( (cd fixtures/eval-run && python3 eval/run.py 2>&1) || true)"
  head="$(printf '%s' "$out" | grep '^overall:' || true)"
  case "$head" in
    *"5/6 (83.3%)"*) ok "/eval-run control: seeded failure lands at 5/6 (83.3%)" ;;
    *100.0%*)        bad "/eval-run reported 100% with a seeded failing case - false pass" ;;
    "")              bad "/eval-run control produced no headline (runner did not complete)" ;;
    *)               bad "/eval-run headline changed: $head (expected 5/6 (83.3%))" ;;
  esac
  # a case excluded from the denominator MUST be named. Silent exclusion is
  # how a headline lies, and it is invisible in the percentage itself.
  printf '%s' "$out" | grep -q 'needs rubric review: 1' \
    || bad "/eval-run silently dropped the rubric case from the report"
  printf '%s' "$out" | grep -q 'skipped (needs-data): 1' \
    || bad "/eval-run silently dropped the needs-data case from the report"
  rm -rf fixtures/eval-run/eval/results
else
  # a skipped control is NOT a pass — check.sh section 2 already learned
  # this lesson about a missing banned list. Say so and count it.
  printf '  SKIP /eval-run control: python3 absent or fixture missing — NOT verified\n'
  skipped=$((skipped + 1))
fi

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
if [ "$fail" -eq 0 ] && [ "$skipped" -gt 0 ]; then
  echo "controls.sh: no failures, but $skipped control(s) SKIPPED — coverage is incomplete"
elif [ "$fail" -eq 0 ]; then echo "controls.sh: all plants caught"
else echo "controls.sh: a documented check MISSED its plant — a false-pass in the making"; exit 1; fi
