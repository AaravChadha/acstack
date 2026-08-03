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

# --- /secure surface 5 + sinks: every documented pattern vs its plant ---
# Each entry: a label, the grep -F anchor that locates the documented
# command, and the fixture that must match. Extracted at run time, so a
# regressed pattern fails HERE (PLAN 4.31).
sec_check() { # label anchor fixture-path expected-hits
  # expected-hits is the NUMBER of distinct lines the pattern must match.
  # HONEST SCOPE (corrected 2026-08-02): counting catches a pattern that
  # stops matching a whole class — it is how the `eval(`-at-column-1 gap
  # was found. It does NOT protect individual branches of an alternation:
  # deleting `|MODE_ECB` still passes, because other branches cover the
  # same fixture lines and the assertion is `-ge`. Per-branch coverage
  # would need one fixture line and one control per branch; that is not
  # what this does, and claiming otherwise would be the false-confidence
  # this file exists to prevent.
  local label="$1" anchor="$2" target="$3" want="$4" line pat got
  line="$(grep -F "$anchor" skills/secure/references/security-surfaces.md | head -1 || true)"
  pat="${line#*\'}"; pat="${pat%%\'*}"
  if [ -z "$pat" ] || [ "$pat" = "$line" ]; then
    bad "/secure $label pattern not extractable (anchor: $anchor)"
    return
  fi
  got="$(grep -rhE "$pat" "$target" 2>/dev/null | grep -vc '^[[:space:]]*[#/]' || true)"
  if [ "${got:-0}" -ge "$want" ]; then
    ok "/secure $label grep catches $got/$want planted line(s)"
  else
    bad "/secure $label grep caught only $got of $want planted lines (pattern: $pat)"
  fi
}
sec_check "deserialization" "git grep -nE '(pickle|cPickle" fixtures/secure/deserialization.py 4
sec_check "pickle-wrappers" "git grep -nE '(read_pickle\(" fixtures/secure/deserialization.py 2
sec_check "yaml-load"       "git grep -nE '(yaml\.(load|unsafe_load)" fixtures/secure/deserialization.py 1
sec_check "crypto-misuse"   "git grep -nE '(createCipher\(" fixtures/secure/crypto-tls.js 1
sec_check "tls-disabled"    "git grep -nE '(verify[[:space:]]*=[[:space:]]*False" fixtures/secure/ 3
sec_check "xxe"             "git grep -nE '(resolve_entities[[:space:]]*=[[:space:]]*True" fixtures/secure/xxe.py 2
sec_check "xss-sinks"       "git grep -nE '(document\.write\(" fixtures/secure/sinks.js 3
sec_check "dynamic-eval"    "git grep -nE '(new[[:space:]]+Function" fixtures/secure/sinks.js 2
sec_check "sri-missing"     "git grep -nE '<script[^>]+src=" fixtures/secure/sri.html 1
sec_check "actions-inject"  "git grep -nE 'run:" fixtures/secure/workflow-sample.yml 1

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
# check 9 (agent-instruction quality) — judgment check, so the control is
# plant-presence (like the pointer/.env checks above), not a detection rerun.
if grep -qi 'Co-Authored-By' fixtures/health/AGENTS.md 2>/dev/null; then
  ok "/health instruction-quality: attribution-contradiction plant present"
else bad "/health instruction-quality: AGENTS.md contradiction plant lost"; fi
if grep -q 'references/ghost.md' fixtures/health/AGENTS.md 2>/dev/null && [ ! -f fixtures/health/references/ghost.md ]; then
  ok "/health instruction-quality: dead-reference plant present and unresolved"
else bad "/health instruction-quality: dead-reference plant lost"; fi

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
    *"6/7 (85.7%)"*) ok "/eval-run control: seeded failure lands at 6/7 (85.7%)" ;;
    *100.0%*)        bad "/eval-run reported 100% with a seeded failing case - false pass" ;;
    "")              bad "/eval-run control produced no headline (runner did not complete)" ;;
    *)               bad "/eval-run headline changed: $head (expected 6/7 (85.7%))" ;;
  esac
  # a case excluded from the denominator MUST be named. Silent exclusion is
  # how a headline lies, and it is invisible in the percentage itself.
  printf '%s' "$out" | grep -q 'acceptable_failure applied to 2' \
    || bad "/eval-run did not name both forgiven failures with reasons"
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

# --- seeded-control labeling, BOTH directions (4.34) ---
# The rule: a secret hit is labeled `seeded control (fixture)` only when its
# path is under a fixtures/ root AND a controls script references that root.
# Tested both ways, because a labeling rule that never says "finding" is a
# suppression rule wearing a label's clothes.
label_verdict() { # path -> "label" | "finding"
  case "$1" in
    fixtures/*) [ -d fixtures ] && grep -q 'fixtures/' scripts/controls.sh \
                  && echo label || echo finding ;;
    *) echo finding ;;
  esac
}
if [ "$(label_verdict 'fixtures/secure/config.js')" = "label" ]; then
  ok "/secure seeded-control rule labels the planted key under fixtures/"
else
  bad "/secure seeded-control rule failed to label its own fixture plant"
fi
# direction two: an identical key shape OUTSIDE the fixtures root must stay a
# finding — proven on a path the repo does not ship, so nothing is planted.
if [ "$(label_verdict 'src/config.js')" = "finding" ]; then
  ok "/secure seeded-control rule still reports a key outside fixtures/ as a finding"
else
  bad "/secure seeded-control rule would suppress a real key outside fixtures/"
fi

# --- /migrate-check: the no-database fixture must stay signal-free (4.39) ---
# Inverted control: this fixture's VALUE is the ABSENCE of every database
# signal the autodetect keys on. If one creeps in, the fixture silently stops
# testing the no-DB path — so the assertion is "still nothing here".
nodb="fixtures/migrate-check-no-db"
if [ -d "$nodb" ]; then
  sig=""
  [ -d "$nodb/prisma" ] && sig="$sig prisma/"
  [ -d "$nodb/migrations" ] && sig="$sig migrations/"
  [ -f "$nodb/alembic.ini" ] && sig="$sig alembic.ini"
  [ -f "$nodb/Gemfile" ] && sig="$sig Gemfile"
  { find "$nodb" -name '*.sql' | grep -q . ; } && sig="$sig *.sql"
  { grep -rqE 'DATABASE_URL|"(prisma|pg|mysql2?|sequelize|typeorm|knex|mongoose|sqlite3?|drizzle-orm)"' "$nodb" 2>/dev/null; } \
    && sig="$sig db-dep-or-url"
  if [ -z "$sig" ]; then
    ok "/migrate-check no-DB fixture is still free of every database signal"
  else
    bad "/migrate-check no-DB fixture gained a database signal ($sig) — it no longer tests the no-DB path"
  fi
else
  bad "/migrate-check no-DB fixture missing — the autodetect path has no control"
fi

echo
if [ "$fail" -eq 0 ] && [ "$skipped" -gt 0 ]; then
  echo "controls.sh: no failures, but $skipped control(s) SKIPPED — coverage is incomplete"
elif [ "$fail" -eq 0 ]; then echo "controls.sh: all plants caught"
else echo "controls.sh: a documented check MISSED its plant — a false-pass in the making"; exit 1; fi
