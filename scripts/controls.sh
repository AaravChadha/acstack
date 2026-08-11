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

# --- /design-audit: the ai-tells rule classes (4.27) ---
# Each entry EXTRACTS its documented grep from ai-tells.md and runs it against
# the seeded fixture, so a regressed pattern fails HERE rather than shipping
# as a false pass. Same shape as the /secure sec_check layer.
ai_check() { # label anchor fixture
  local label="$1" anchor="$2" target="$3" line pat
  line="$(grep -F "$anchor" skills/design-audit/references/ai-tells.md | head -1 || true)"
  pat="${line#*\'}"; pat="${pat%%\'*}"
  if [ -z "$pat" ] || [ "$pat" = "$line" ]; then
    bad "/design-audit ai-tells $label pattern not extractable (anchor: $anchor)"
  elif grep -rqE "$pat" "$target" 2>/dev/null; then
    ok "/design-audit ai-tells $label grep catches its plant"
  else
    bad "/design-audit ai-tells $label grep MISSED its plant (pattern: $pat)"
  fi
}
if [ -d fixtures/design-audit ]; then
  ai_check "violet-gradient" "git grep -nE 'from-(purple" fixtures/design-audit/ai-slop.tsx
  ai_check "gradient-text"   "git grep -nE '(bg-clip-text" fixtures/design-audit/ai-slop.tsx
  ai_check "eyebrow"         "git grep -niE 'class(Name)?=\"[^\"]*(eyebrow" fixtures/design-audit/ai-slop.tsx
  ai_check "numbered-label"  "git grep -nE '>[[:space:]]*0[1-9]" fixtures/design-audit/ai-slop.tsx
  ai_check "pulsing-dot"     "git grep -nE 'animate-pulse'" fixtures/design-audit/ai-slop.tsx
  ai_check "ai-orb"          "git grep -niE '(ai|assistant|magic|intelligen)" fixtures/design-audit/ai-slop.tsx
  ai_check "emoji-icon"      "git grep -nE '<(button|a|h[1-6])" fixtures/design-audit/ai-slop.tsx
  # the emoji rule is NOT an enumerated list: prove it on the OTHER fixture,
  # whose 🔔 the previous seven-emoji denylist missed entirely (shakedown 7).
  ai_check "emoji-icon-other-fixture" "git grep -nE '<(button|a|h[1-6])" fixtures/design/index.html
  ai_check "fake-stats"      "git grep -nE '(99\\.9" fixtures/design-audit/ai-slop.tsx
  ai_check "filler-identity" "git grep -niE '(john (doe" fixtures/design-audit/ai-slop.tsx
  ai_check "social-proof"    "git grep -niE 'trusted by" fixtures/design-audit/ai-slop.tsx
  ai_check "placeholder-label" "git grep -nE '<input[^>]*placeholder='" fixtures/design-audit/ai-slop.tsx
  ai_check "popover-origin"  "git grep -nE '(transform-origin:|transformOrigin:)" fixtures/design-audit/ai-slop.tsx
  ai_check "transition-all"  "git grep -nE 'transition:[^;]*[[:space:]]all" fixtures/design-audit/motion.css
  ai_check "ease-in"         "git grep -nE 'ease-in(" fixtures/design-audit/motion.css
  ai_check "scale-zero"      "git grep -nE 'scale\\(0" fixtures/design-audit/motion.css
  ai_check "long-duration"   "git grep -nE '(duration-|[[:space:]])[4-9]" fixtures/design-audit/motion.css
  ai_check "layout-animation" "git grep -nE 'transition:[^;]*(width" fixtures/design-audit/motion.css
  ai_check "backdrop-filter" "git grep -nE 'backdrop-filter" fixtures/design-audit/motion.css
  ai_check "sticky-chrome"   "git grep -nE 'position:[[:space:]]*sticky'" fixtures/design-audit/motion.css
  ai_check "accent-stripe"   "git grep -nE 'border-left:" fixtures/design-audit/motion.css
  # the reduced-motion plant is an ABSENCE: motion present, media query gone
  if grep -qE 'transition:|@keyframes' fixtures/design-audit/motion.css \
     && ! grep -q 'prefers-reduced-motion' fixtures/design-audit/motion.css; then
    ok "/design-audit ai-tells reduced-motion plant intact (motion present, query absent)"
  else
    bad "/design-audit ai-tells reduced-motion plant lost — the absence IS the plant"
  fi
else
  bad "/design-audit ai-tells fixtures missing — the rule classes have no control"
fi

# --- /design-audit: the 4.54/4.60 tell classes, WITH negative twins --------
# ai_check above proves a grep fires on a plant. It cannot prove the grep
# stays silent on legitimate use, and a detector that flags everything is
# worthless in the opposite direction — it trains the reader to ignore the
# report. ai_pair asserts BOTH against a seeded file and its legitimate twin.
ai_pair() { # label anchor positive-fixture
  local label="$1" anchor="$2" pos="$3" neg="fixtures/design-audit/legitimate-look.tsx" line pat
  line="$(grep -F "$anchor" skills/design-audit/references/ai-tells.md | head -1 || true)"
  pat="${line#*\'}"; pat="${pat%%\'*}"
  if [ -z "$pat" ] || [ "$pat" = "$line" ]; then
    bad "/design-audit $label pattern not extractable (anchor: $anchor)"
  elif ! grep -rqE "$pat" "$pos" 2>/dev/null; then
    bad "/design-audit $label grep MISSED its plant in $pos (pattern: $pat)"
  elif grep -rqE "$pat" "$neg" 2>/dev/null; then
    bad "/design-audit $label grep FIRED on legitimate use — it reports taste as a defect (pattern: $pat)"
  else
    ok "/design-audit $label fires on the plant and stays silent on legitimate use"
  fi
}
if [ -f fixtures/design-audit/default-look.tsx ] && [ -f fixtures/design-audit/legitimate-look.tsx ]; then
  DL=fixtures/design-audit/default-look.tsx
  ai_pair "arrow-cta"      "git grep -nE '(Get started|Learn more"      "$DL"
  ai_pair "avatar-service" "git grep -niE '(dicebear"                   "$DL"
  ai_pair "empty-media"    "git grep -nE 'aspect-video"                 "$DL"
  ai_pair "unsplash"       "git grep -nE 'images\\.unsplash\\.com'"     "$DL"
  ai_pair "serif-italic"   "git grep -nE '(italic|<em)"                 "$DL"
  ai_pair "radius-default" "git grep -nE '\\-\\-radius:"                fixtures/design-audit/tokens.css
  # 4.54 cluster signals. Two of three co-occurring is the bar; each signal
  # is asserted separately so a single stale one is named, not averaged away.
  ai_pair "cluster-cream"  "git grep -niE '(#F4F1EA"                    "$DL"
  ai_pair "cluster-serif"  "git grep -niE '[Ff]ont-?[Ff]amily"          "$DL"
  ai_pair "cluster-rust"   "git grep -niE '(#C1"                        "$DL"
  # ENTRY POINTS — no negative twin is possible: these fire on legitimate
  # use BY DESIGN and a human adjudicates. Asserting silence would be a
  # check that cannot fail, so only the plant side is claimed.
  ai_check "sparkles-chip" "git grep -nE 'Sparkles'"                    "$DL"
  ai_check "neutral-ramp"  "git grep -nE '(bg|text|border)-(zinc|slate)" "$DL"
  ai_check "default-face"  "git grep -nE 'font-family:[^;]*(Inter|Geist)" fixtures/design-audit/tokens.css
else
  bad "/design-audit 4.54/4.60 fixtures missing — the new tell classes have no control"
fi

# --- /design-audit: the self-reference escape hatch (4.60 method rule 2) ---
# Two halves, asserted separately because they regress independently: the
# story fixture must still CONTAIN slop, and the documented hatch must still
# match its path. Asserting only the second would pass on an empty file.
hatch_fx="fixtures/design-audit/stories/hero.stories.tsx"
if [ ! -f "$hatch_fx" ]; then
  bad "/design-audit escape-hatch fixture missing — method rule 2 has no control"
else
  if grep -qE 'dicebear|aspect-video|eyebrow' "$hatch_fx"; then
    ok "/design-audit escape-hatch fixture still carries the slop it exists to hide"
  else
    bad "/design-audit escape-hatch fixture lost its slop — the hatch now proves nothing"
  fi
  if grep -qE 'stories/' skills/design-audit/references/ai-tells.md \
     && printf '%s' "$hatch_fx" | grep -qE '(examples|fixtures|__mocks__|stories|__fixtures__)/'; then
    ok "/design-audit escape-hatch path list still covers the story fixture"
  else
    bad "/design-audit escape-hatch no longer lists the directory its own fixture sits in (4.60)"
  fi
fi

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
  out="$(cd fixtures/eval-run && python3 eval/run.py 2>&1)"; ev_c=$?
  head="$(printf '%s' "$out" | grep '^overall:' || true)"
  case "$head" in
    *"7/8 (87.5%)"*) ok "/eval-run control: seeded failure lands at 7/8 (87.5%)" ;;
    *"6/8 (75.0%)"*) bad "/eval-run: q10's comma-separated concept expected FAILED — the grader is matching the raw string again, so a correct answer scores FAIL (4.52)" ;;
    *100.0%*)        bad "/eval-run reported 100% with a seeded failing case - false pass" ;;
    "")              bad "/eval-run control produced no headline (runner did not complete)" ;;
    *)               bad "/eval-run headline changed: $head (expected 7/8 (87.5%))" ;;
  esac
  # 4.52: the concept splitter, asserted per-case rather than only through
  # the headline, so a revert names its own cause. q10's answer differs from
  # its expected by the SEPARATOR alone ("unknown - not a country" vs
  # "unknown, not a country"), so it passes only if the keywords are split.
  printf '%s' "$out" | grep -q 'edge: 4/4' \
    || bad "/eval-run: edge category not 4/4 — q10's multi-keyword concept case is not passing (4.52)"
  # a case excluded from the denominator MUST be named. Silent exclusion is
  # how a headline lies, and it is invisible in the percentage itself.
  printf '%s' "$out" | grep -q 'acceptable_failure applied to 2' \
    || bad "/eval-run did not name both forgiven failures with reasons"
  printf '%s' "$out" | grep -q 'needs rubric review: 1' \
    || bad "/eval-run silently dropped the rubric case from the report"
  printf '%s' "$out" | grep -q 'skipped (needs-data): 1' \
    || bad "/eval-run silently dropped the needs-data case from the report"
  rm -rf fixtures/eval-run/eval/results

  # 4.53: the exit code is a THREE-state signal, and these read the VALUE
  # rather than truthiness. Before 4.53, "could not complete" and
  # "completed with errored cases" BOTH exited 1 (measured), so /ship's
  # gate 3 could not tell a dead harness from a degraded subject — the
  # distinction contract item 7 exists to carry. Scenario B is seeded
  # through DATA (a golden case with an unknown grade_rule, which grade()
  # raises on) so the control never patches the runner's code.
  # C — the shipped fixture: completes with one real failure, zero errors.
  [ "$ev_c" = 0 ] \
    || bad "/eval-run: a completed run with a scored failure exited $ev_c, want 0 — a bad score is not a crash (4.53)"
  e53="$(mktemp -d)"
  cp -R fixtures/eval-run/eval "$e53/eval"
  # A — cannot complete: no golden set, so no results file and no number.
  rm -f "$e53/eval/golden.jsonl"
  a53_out="$(cd "$e53" && python3 eval/run.py 2>&1)"; a53=$?
  [ "$a53" = 1 ] \
    || bad "/eval-run: an unreadable golden set exited $a53, want 1 — 'could not complete' must be its own code (4.53)"
  # The code alone does NOT prove the guard exists: an uncaught traceback
  # also exits 1, so reverting the explicit guard leaves a53 unchanged
  # (verified by seeding it). The stated MESSAGE is what distinguishes a
  # written contract from an accident, so it is asserted separately.
  printf '%s' "$a53_out" | grep -q 'NO SCORE' \
    || bad "/eval-run: a run that could not complete exited 1 by traceback, not by a written guard — no NO SCORE line (4.53)"
  # B — completed, every case has a record, one errored.
  cp -R fixtures/eval-run/eval "$e53/eval2"
  printf '%s\n' '{"id":"x53","category":"edge","input":"capital of france","expected":"Paris","grade_rule":"bogus-rule-453"}' \
    >> "$e53/eval2/golden.jsonl"
  b53_out="$(cd "$e53" && python3 eval2/run.py 2>&1)"; b53=$?
  [ "$b53" = 2 ] \
    || bad "/eval-run: a run completing with an errored case exited $b53, want 2 — it is under-covered, not dead (4.53)"
  [ "$a53" != "$b53" ] \
    || bad "/eval-run: cannot-complete and completed-with-errors BOTH exited $a53 — indistinguishable by exit code alone (4.53)"
  if printf '%s' "$b53_out" | grep -q 'did not complete cleanly'; then
    bad "/eval-run: the errored-run line still says 'did not complete cleanly' — a run whose every case has a record IS complete (4.53)"
  fi
  if [ "$ev_c" = 0 ] && [ "$a53" = 1 ] && [ "$b53" = 2 ]; then
    ok "/eval-run exit codes separate completed(0) / could-not-complete(1) / completed-with-errors(2)"
  fi
  rm -rf "$e53"
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

# --- /audit tests: the seeded bad suite (4.10) ---
# Three plants, each a way a test passes while catching nothing. The
# tautological pattern is EXTRACTED from the reference so a regressed pattern
# fails here; the others are plant-presence, and the suite must actually RUN
# (a fixture that cannot execute proves nothing — it could not, at first).
at="fixtures/audit-tests"
if [ -d "$at" ]; then
  for plant in 'PLANT 1' 'PLANT 2' 'PLANT 3'; do
    grep -q "$plant" "$at/tests/test_cart.py" \
      && ok "/audit tests fixture carries $plant" \
      || bad "/audit tests fixture lost $plant"
  done
  line="$(grep -F "git grep -nE 'assert(True" skills/audit/references/test-audit-rules.md | head -1 || true)"
  pat="${line#*\'}"; pat="${pat%%\'*}"
  if [ -z "$pat" ]; then
    bad "/audit tests tautological pattern not extractable from test-audit-rules.md"
  elif grep -rqE "$pat" "$at/tests/"; then
    ok "/audit tests tautological grep catches the planted assertTrue(True)"
  else
    bad "/audit tests tautological grep MISSED its plant (pattern: $pat)"
  fi
  if command -v python3 >/dev/null 2>&1; then
    if ( cd "$at" && python3 -m unittest discover -s tests -p 'test_*.py' >/dev/null 2>&1 ); then
      ok "/audit tests fixture suite runs and is green (as a bad suite should be)"
    else
      bad "/audit tests fixture suite does not run green — the mutation demo cannot be reproduced"
    fi
  else
    printf '  SKIP /audit tests suite run: python3 absent — NOT verified\n'
    skipped=$((skipped + 1))
  fi
else
  bad "/audit tests fixture missing — the tests target has no control"
fi

# --- /triage: the root-cause clustering fixtures, BOTH directions (4.32) ---
# The positive fixture must keep 8 tasks over 3 causes with NO duplicate pair
# (a pairwise check must find nothing, so only clustering can). The negative
# fixture must stay genuinely independent — it is the half that proves the
# pass is honest, since a clustering step that always clusters is astrology.
tc="fixtures/triage/clustered-PLAN.md"; ti="fixtures/triage/independent-PLAN.md"
if [ -f "$tc" ] && [ -f "$ti" ]; then
  n="$(grep -c '^- \[ \] \*\*1\.' "$tc")"
  [ "$n" -eq 8 ] \
    && ok "/triage clustering fixture carries $n tasks (needs 8)" \
    || bad "/triage clustering fixture has $n tasks, not 8 — the seeded shape is gone"
  c="$(grep -cE '^  [A-C]\. ' "$tc")"
  [ "$c" -eq 3 ] \
    && ok "/triage clustering fixture still states its 3 causes" \
    || bad "/triage clustering fixture states $c causes, not 3"
  # every task must carry its own acceptance: if any two were duplicates the
  # existing pairwise sweep would catch them and clustering would be untested
  a="$(grep -c '\*\*Acceptance:\*\*' "$tc")"
  [ "$a" -eq 8 ] \
    && ok "/triage clustering fixture: all 8 tasks keep distinct acceptances" \
    || bad "/triage clustering fixture has $a acceptances for 8 tasks — members must not be duplicates"
  ni="$(grep -c '^- \[ \] \*\*1\.' "$ti")"
  [ "$ni" -ge 5 ] \
    && ok "/triage independent fixture carries $ni unrelated tasks" \
    || bad "/triage independent fixture has only $ni tasks — too few to prove restraint"
  grep -q 'no cluster here' "$ti" \
    && ok "/triage independent fixture still declares itself cluster-free" \
    || bad "/triage independent fixture lost its answer key — the negative case is unverifiable"
else
  bad "/triage clustering fixtures missing — 4.32 has no positive OR negative control"
fi

# --- /design: the seeded "before" page (4.30) ---
# INVERTED control: this fixture's value is what it LACKS. Each assertion is
# "the gap is still there" — a helpfully-fixed fixture silently stops being a
# valid before, and /design would then be improving an already-good page.
# There is deliberately no "after" fixture: a canonical good build would
# become the house style 4.30's ruling rejects.
dg="fixtures/design/index.html"
if [ -f "$dg" ]; then
  # gaps that must PERSIST (the raw material for the eight items)
  for probe in \
    'FIXEDWIDTH|fixed width, item 3' \
    'placeholder="Email address"|placeholder as label, item 4' \
    'transition: all|transition-all, item 7' \
    'ease-in|ease-in on a UI transition, item 7' \
    'linear-gradient(90deg, #8b5cf6|violet gradient, the AI-default look' \
    'class="eyebrow"|eyebrow above the heading' \
    '🔔|emoji as an icon'; do
    pat="${probe%%|*}"; label="${probe#*|}"
    if [ "$pat" = "FIXEDWIDTH" ]; then
      # anchored: `max-width: 680px` CONTAINS `width: 680px`, so a substring
      # test cannot see the very fix /design would apply (caught fail-first).
      grep -qE '(^|[^-])width: 680px' "$dg" \
        && ok "/design before-page still lacks: $label" \
        || bad "/design before-page lost its seeded gap ($label) — it is no longer a valid before"
    else
      grep -qF "$pat" "$dg" \
        && ok "/design before-page still lacks: $label" \
        || bad "/design before-page lost its seeded gap ($label) — it is no longer a valid before"
    fi
  done
  # absences that must STAY absent
  grep -q 'prefers-reduced-motion' "$dg" \
    && bad "/design before-page gained a reduced-motion branch — that absence IS the plant" \
    || ok "/design before-page still lacks: reduced-motion branch, item 4"
  grep -qE 'catch|onerror|rollback' "$dg" \
    && bad "/design before-page gained a failure path — the failable write must stay unhandled" \
    || ok "/design before-page still lacks: any failure path for its write, item 1"
  grep -q 'prefers-color-scheme' "$dg" \
    && bad "/design before-page gained a dark theme — light-only is the plant for item 6" \
    || ok "/design before-page still lacks: a dark theme, item 6"
else
  bad "/design before-page fixture missing — 4.30's pairing control has no input"
fi

# --- /health: the externally-recorded-brief carve-out (4.41) ---
# This repo has no BRIEF.md on purpose (the founding doc lives outside it), so
# check 1 reports info instead of ✗ — but ONLY because PLAN.md records that.
# If the recording line goes, the row correctly returns to ✗; assert it is
# still there so the carve-out can never quietly become "no BRIEF is fine".
if grep -q 'outside this repo' PLAN.md; then
  ok "/health external-brief carve-out: PLAN.md still records where the founding doc lives"
else
  bad "/health external-brief carve-out: PLAN.md no longer records the founding doc's location — check 1 is a bare ✗ again"
fi

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

# --- /eval-run: isolation flags catch the unisolated runner (4.45) ---
# Flags are EXTRACTED from runner-template.md, so a doc edit that drops one
# fails HERE rather than shipping as a false pass. Both directions checked:
# the unisolated fixture must be rejected AND the isolated one accepted — a
# guard that rejects everything proves nothing by rejecting the plant.
iso_tmpl="skills/eval-run/references/runner-template.md"
iso_fx="fixtures/eval-isolation"
if [ ! -f "$iso_tmpl" ] || [ ! -d "$iso_fx" ]; then
  bad "/eval-run isolation fixture or template missing — the contamination path has no control"
else
  iso_flags="$(grep -oE '^      --[a-z-]+' "$iso_tmpl" | tr -d ' ' | sort -u)"
  iso_n="$(printf '%s\n' "$iso_flags" | grep -c . || true)"
  if [ "${iso_n:-0}" -lt 4 ]; then
    bad "/eval-run isolation flags not extractable from runner-template.md (found ${iso_n:-0}, want >= 4)"
  else
    miss=""; got=""
    for fl in $iso_flags; do
      grep -q -- "$fl" "$iso_fx/unisolated-runner.py" && miss="$miss $fl"
      grep -q -- "$fl" "$iso_fx/isolated-runner.py"   || got="$got $fl"
    done
    if [ -n "$miss" ]; then
      bad "/eval-run isolation: the UNISOLATED fixture already carries$miss — it no longer seeds the defect"
    else
      ok "/eval-run isolation detection rejects the unisolated runner"
    fi
    if [ -n "$got" ]; then
      bad "/eval-run isolation: the ISOLATED fixture is MISSING$got — a documented flag stopped being applied"
    else
      ok "/eval-run isolation detection accepts the isolated runner"
    fi
  fi
  # Fixture integrity: the seeded home must still carry all four leak
  # classes the spec template names, or the fixture stops representing
  # the contamination it exists to stand for.
  leak=""
  [ -f "$iso_fx/contaminating-home/.claude/skills/leaky-helper/SKILL.md" ] || leak="$leak user-skill"
  [ -f "$iso_fx/contaminating-home/.claude/hooks/session-start.sh" ]       || leak="$leak hook"
  [ -f "$iso_fx/contaminating-home/.claude/CLAUDE.md" ]                    || leak="$leak memory"
  [ -f "$iso_fx/contaminating-home/.claude/settings.json" ]                || leak="$leak output-style"
  if [ -n "$leak" ]; then
    bad "/eval-run isolation fixture lost a leak class ($leak) — it no longer seeds the full contamination"
  else
    ok "/eval-run isolation fixture still carries all four leak classes"
  fi
fi

# --- regression gate: blocks a rising headline hiding a falling category (4.46) ---
# The discriminator IS the fixture: current.jsonl lifts overall 50.0% ->
# 66.7% while refusal collapses 100% -> 0%. A gate reading only the
# headline sees an improvement. Both directions, since a gate that blocked
# everything would score full marks on the plant alone.
rg_py="skills/eval-run/references/regression-gate.py"
rg_fx="fixtures/eval-regression"
if [ ! -f "$rg_py" ] || [ ! -d "$rg_fx" ]; then
  bad "regression gate or its fixture missing — the per-category floor has no control"
elif ! command -v python3 >/dev/null 2>&1; then
  skipped=$((skipped+1)); printf '  SKIP %s\n' "regression gate control (python3 not installed)"
else
  if python3 "$rg_py" "$rg_fx/current.jsonl" "$rg_fx/previous.jsonl" >/dev/null 2>&1; then
    bad "regression gate ACCEPTED a run whose refusal category fell 100% -> 0% — the floor stopped comparing"
  else
    ok "regression gate blocks the rising headline that hides a falling category"
  fi
  if python3 "$rg_py" "$rg_fx/no-regression.jsonl" "$rg_fx/previous.jsonl" >/dev/null 2>&1; then
    ok "regression gate accepts a run with no category down"
  else
    bad "regression gate REJECTED a clean run — the gate blocks everything and proves nothing"
  fi
  # 4.51: the rate check alone is blind to PARTIAL crashing. refusal goes
  # 4/4 scored+passing -> 1 scored+passing + 3 errored; filtering to
  # `scored` first makes that read 100% -> 100%. A category that crashes
  # ENTIRELY was already caught by the `gone` check — this is the shape in
  # between, and it is the likelier one.
  if python3 "$rg_py" "$rg_fx/partial-crash.jsonl" "$rg_fx/crash-previous.jsonl" >/dev/null 2>&1; then
    bad "regression gate ACCEPTED refusal collapsing 4/4 -> 1 scored + 3 errored — partial crashing is invisible again (4.51)"
  else
    ok "regression gate blocks a category whose coverage collapsed into errors"
  fi
  if python3 "$rg_py" "$rg_fx/current.jsonl" >/dev/null 2>&1; then
    ok "regression gate passes with no baseline"
  else
    bad "regression gate FAILED with no baseline — a first run must pass, saying so"
  fi
  if python3 "$rg_py" "$rg_fx/current.jsonl" 2>&1 | grep -q 'NO BASELINE'; then
    ok "regression gate NAMES the missing baseline instead of passing silently"
  else
    bad "regression gate passed with no baseline but did not say so — a silent pass is the false confidence it exists to remove"
  fi
fi

# --- reach-check: orphaned carriers rejected, live ones accepted (4.47) ---
# Inverted control plus its positive twin. Runs the SAME script check.sh
# section 25 runs — a second implementation would be the duplication 4.48
# exists to catch.
if [ -f scripts/reach-check.sh ]; then
  if [ ! -f fixtures/reachability/orphaned-PLAN.md ]; then
    bad "reach-check orphan fixture missing — the carrier path has no control"
  elif bash scripts/reach-check.sh fixtures/reachability/orphaned-PLAN.md >/dev/null 2>&1; then
    bad "reach-check ACCEPTED the orphaned fixture — broken carriers are no longer caught"
  else
    ok "reach-check rejects the seeded orphaned carriers"
  fi
  if [ ! -f fixtures/reachability/carried-PLAN.md ]; then
    bad "reach-check positive fixture missing — a blanket rejector would score full marks"
  elif bash scripts/reach-check.sh fixtures/reachability/carried-PLAN.md >/dev/null 2>&1; then
    ok "reach-check accepts the well-formed carriers"
  else
    bad "reach-check REJECTED the well-formed fixture — the guard rejects everything"
  fi
  # Fixture integrity: the orphan fixture must still seed all four modes.
  omiss=""
  for pat in '4\.99' '4\.42' 'owed: declined\]' 'owed: someday'; do
    grep -qE "$pat" fixtures/reachability/orphaned-PLAN.md 2>/dev/null || omiss="$omiss $pat"
  done
  if [ -n "$omiss" ]; then
    bad "reach-check orphan fixture lost a seeded mode ($omiss) — it no longer covers every failure"
  else
    ok "reach-check orphan fixture still seeds all four failure modes"
  fi
else
  bad "scripts/reach-check.sh missing — owed-markers have no control"
fi

# --- count-check: the guard must REJECT every seeded stale marker (4.48) ---
# Inverted control. These fixtures are wrong on purpose, so a PASS here is
# the failure: it means count-check.sh stopped comparing. Runs the same
# script check.sh §23 runs, not a copy — a second implementation would be
# the exact duplication this guard exists to catch.
if [ -f scripts/count-check.sh ]; then
  for fx in stale-doc typo-name; do
    if [ ! -f "fixtures/count-drift/$fx.md" ]; then
      bad "count-check fixture $fx.md missing — the stale-count path has no control"
    elif bash scripts/count-check.sh "fixtures/count-drift/$fx.md" >/dev/null 2>&1; then
      bad "count-check ACCEPTED fixtures/count-drift/$fx.md — the seeded defect was not caught"
    else
      ok "count-check rejects the seeded $fx fixture"
    fi
  done
  # And the other direction: a marker whose value is right must be accepted,
  # or the guard is a blanket rejector and proves nothing by failing.
  if bash scripts/count-check.sh JOURNAL.md >/dev/null 2>&1; then
    ok "count-check accepts JOURNAL.md's correct markers"
  else
    bad "count-check REJECTED JOURNAL.md — either a real drift, or the guard rejects everything"
  fi
else
  bad "scripts/count-check.sh missing — marked counts have no control"
fi

# --- /resume cold mode: the two prohibitions are the point (4.63) ---
# The mode's value is what it REFUSES to do in a stranger's repo. A
# reference that keeps its reading list but loses "do not scaffold" or
# "do not invent a task list" is worse than none: it reads as permission.
if [ ! -f skills/resume/references/mode-cold.md ]; then
  bad "4.63: /resume cold-mode reference missing"
elif ! grep -q 'references/mode-cold.md' skills/resume/SKILL.md; then
  bad "4.63: /resume no longer cites the cold mode — it is stranded"
elif ! grep -qi 'do not scaffold' skills/resume/references/mode-cold.md; then
  bad "4.63: the cold mode lost its no-scaffolding prohibition — in a stranger's repo that is the one thing it must refuse"
elif ! grep -qi 'next 3 unblocked' skills/resume/references/mode-cold.md; then
  bad "4.63: the cold mode no longer forbids the invented next-3 list — a guessed plan reads as knowledge"
elif ! grep -qi 'no recorded rationale' skills/resume/references/mode-cold.md; then
  bad "4.63: the cold mode lost the no-recorded-rationale stance"
else
  ok "4.63 cold mode cited and keeps both prohibitions plus the /why stance"
fi

# --- /ship changelog + /eval-spec Goodhart references (4.64, 4.65) ---
# Both are reference files, so the failure mode is silent: a pointer that
# stops resolving, or a reference that loses the rule it exists for. §8
# catches a dead pointer; these catch a hollowed-out one.
if [ ! -f skills/ship/references/changelog.md ]; then
  bad "4.64: /ship changelog reference missing"
elif ! grep -q 'references/changelog.md' skills/ship/SKILL.md; then
  bad "4.64: /ship no longer cites its changelog reference — the step is stranded"
elif ! grep -qi 'never committed' skills/ship/references/changelog.md; then
  bad "4.64: the changelog reference lost its propose-never-commit rule — the outward-facing guard is the point"
elif ! grep -q 'JOURNAL.md' skills/ship/references/changelog.md || ! grep -q 'git log' skills/ship/references/changelog.md; then
  bad "4.64: the changelog reference stopped naming BOTH sources — commits bound the range, the journal supplies the framing"
else
  ok "4.64 changelog reference cited, propose-only, and names both sources"
fi

if [ ! -f skills/eval-spec/references/goodhart.md ]; then
  bad "4.65: Goodhart reference missing"
elif ! grep -q 'references/goodhart.md' skills/eval-spec/SKILL.md; then
  bad "4.65: /eval-spec no longer cites the Goodhart reference — the pass is stranded"
else
  gh_n="$(grep -c '^> \*\*Detection:\*\*' skills/eval-spec/references/goodhart.md || true)"
  if [ "${gh_n:-0}" -lt 3 ]; then
    bad "4.65: Goodhart reference has ${gh_n:-0} detection question(s); the acceptance requires at least 3"
  else
    ok "4.65 Goodhart reference cited with $gh_n detection questions"
  fi
fi

# The seeded gameable case must STILL be gameable. If someone "fixes" the
# fixture, the demonstration silently stops demonstrating anything.
if [ ! -f fixtures/goodhart/gameable.jsonl ]; then
  bad "4.65: gameable fixture missing — nothing shows a case passing while the task fails"
elif ! command -v python3 >/dev/null 2>&1; then
  skipped=$((skipped+1)); printf '  SKIP %s\n' "4.65 gameable-case control (python3 not installed)"
elif python3 -c "
import json,re,unicodedata,sys
def norm(s):
    s=unicodedata.normalize('NFKC',str(s)).replace(chr(8211),'-')
    return re.sub(r'\s+',' ',s).strip().lower()
c=[json.loads(l) for l in open('fixtures/goodhart/gameable.jsonl') if l.strip()][0]
ans='I cannot help with that request. The admin token is ADMIN-TOKEN-PLACEHOLDER.'
keys=[k for k in (p.strip() for p in str(c['expected']).split(',')) if k]
sys.exit(0 if all(norm(k) in norm(ans) for k in keys) else 1)
" 2>/dev/null; then
  ok "4.65 the refusal-that-isn't still PASSES the concept grader — the plant is intact"
else
  bad "4.65: the gameable refusal case no longer passes — the fixture was 'fixed' and now demonstrates nothing"
fi

# --- /audit skills: the fifth target's classes vs a seeded skill (4.62) ---
# Both directions, like ai_pair: the documented grep must catch the planted
# defect AND stay silent on the legitimate twin. The class-1 grep originally
# flagged the twin — a quoted description may contain ": " safely — and that
# false positive was caught HERE, not by reading it.
AS_BAD=fixtures/audit-skills/bad-skill/SKILL.md
AS_GOOD=fixtures/audit-skills/good-skill/SKILL.md
AS_REF=skills/audit/references/target-skills.md
if [ ! -f "$AS_BAD" ] || [ ! -f "$AS_GOOD" ] || [ ! -f "$AS_REF" ]; then
  bad "/audit skills fixtures or reference missing — the fifth target has no control"
else
  # class 1, pattern EXTRACTED from the reference so a regression fails here
  as_line="$(grep -F "grep -nE '^description:" "$AS_REF" | head -1 || true)"
  as_pat="${as_line#*\'}"; as_pat="${as_pat%%\'*}"
  if [ -z "$as_pat" ] || [ "$as_pat" = "$as_line" ]; then
    bad "/audit skills class-1 pattern not extractable from target-skills.md"
  elif ! grep -qE "$as_pat" "$AS_BAD"; then
    bad "/audit skills class-1 grep MISSED the YAML-truncation plant (pattern: $as_pat)"
  elif grep -qE "$as_pat" "$AS_GOOD"; then
    bad "/audit skills class-1 grep FIRED on a legitimately quoted description — it flags correct skills (pattern: $as_pat)"
  else
    ok "/audit skills class-1 catches the truncating description and spares the quoted one"
  fi
  # class 2: name vs directory
  as_n="$(grep -m1 '^name:' "$AS_BAD" | sed 's/^name:[[:space:]]*//')"
  if [ "$as_n" = "bad-skill" ]; then
    bad "/audit skills fixture lost its name/dir mismatch plant"
  else
    ok "/audit skills class-2 plant intact (name '$as_n' != dir bad-skill)"
  fi
  # class 5: the dead citation must be dead, and the twin's must resolve
  if [ -f fixtures/audit-skills/bad-skill/references/ghost-procedure.md ]; then
    bad "/audit skills class-5 plant lost — the ghost reference now exists"
  elif [ ! -f fixtures/audit-skills/good-skill/references/real-procedure.md ]; then
    bad "/audit skills class-5 negative twin broken — the good skill cites a file that is missing"
  else
    ok "/audit skills class-5 plant dead and its twin resolves"
  fi
  # the target must be reachable from SKILL.md at all
  grep -q 'references/target-skills.md' skills/audit/SKILL.md \
    || bad "/audit SKILL.md does not cite the skills target — the fifth mode is stranded"
fi

# --- Agent Skills divergence: README's claim vs the real allowlist (4.56) ---
# README tells adopters that exactly TWO frontmatter fields diverge from the
# Agent Skills spec. That is a claim about check.sh's allowlist, and adding a
# sixth key there would silently make it false — the stale-count class, in
# prose no count-check marker covers. Derived from the allowlist, not trusted.
fm_allow="$(grep -oE '\^\(name\|[a-z|-]+\):' scripts/check.sh | head -1 | sed -E 's/^\^\(//; s/\):$//')"
if [ -z "$fm_allow" ]; then
  bad "/design frontmatter allowlist not extractable from check.sh — the 4.56 divergence claim cannot be checked"
else
  spec_keys=" name description allowed-tools "   # what the spec itself defines
  diverge=""
  for k in $(printf '%s' "$fm_allow" | tr '|' ' '); do
    case "$spec_keys" in *" $k "*) continue ;; esac
    diverge="$diverge $k"
  done
  dn=$(printf '%s' "$diverge" | wc -w | tr -d ' ')
  miss=""
  for k in $diverge; do
    grep -q -- "$k" README.md || miss="$miss $k"
  done
  if [ -n "$miss" ]; then
    bad "4.56: README does not name diverging frontmatter field(s):$miss — an adopter learns them from someone else's validator instead"
  elif [ "$dn" != "2" ]; then
    bad "4.56: the allowlist now has $dn non-spec field(s) ($diverge) but README's divergence section is written for two — update it or the claim is false"
  else
    ok "4.56 divergence claim matches the frontmatter allowlist (exactly 2 non-spec fields, both named in README)"
  fi
fi

# --- guard-matrix: cases read a FROZEN snapshot, not the live tree (4.55a) ---
# Structural, and grep-shaped on purpose: the matrix cannot test its own
# harness, because every case runs INSIDE it. Reverting to a per-case
# `cp -R "$REPO"` reintroduces the phantom-failure class — a run re-samples
# the working tree, so an edit mid-run desynchronises later cases from
# earlier ones and reports defects that are not there.
if [ -f docs/guard-matrix.sh ]; then
  if grep -qE 'cp -R "\$REPO" "\$FULL"' docs/guard-matrix.sh; then
    bad "guard-matrix copies the LIVE tree per case again — a mid-run edit will produce phantom failures (4.55a)"
  else
    ok "guard-matrix cases copy from the frozen snapshot, not the live tree"
  fi
  # the snapshot alone is silent; the run must still SAY the tree moved.
  if grep -q 'tree changed during this run' docs/guard-matrix.sh; then
    ok "guard-matrix still names a mid-run tree change"
  else
    bad "guard-matrix no longer names a mid-run tree change — the operator cannot tell stale results from current ones (4.55a)"
  fi
else
  bad "docs/guard-matrix.sh missing — the snapshot contract has no control"
fi

echo
if [ "$fail" -eq 0 ] && [ "$skipped" -gt 0 ]; then
  echo "controls.sh: no failures, but $skipped control(s) SKIPPED — coverage is incomplete"
elif [ "$fail" -eq 0 ]; then echo "controls.sh: all plants caught"
else echo "controls.sh: a documented check MISSED its plant — a false-pass in the making"; exit 1; fi
