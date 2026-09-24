#!/usr/bin/env bash
# Test matrix for check.sh's frontmatter guard, written BEFORE the fix.
# Each case: name | expected (PASS/FAIL) | frontmatter body
# Run: bash guard-matrix.sh /path/to/repo [case-filter-regex]
#
# THE FILTER AND ITS OWN FAILURE MODE (5.11, 2026-09-10). A full run is all
# 150 cases or nothing, ~19 minutes at ~7.6 s/case on a frozen tree, so a
# two-line edit paid the same price as a rewrite and the standing options
# were both bad: pay 19 minutes, or skip the matrix and push on check.sh
# alone. The second is what turned CI red on 2026-08-31, since the two are
# separate surfaces.
#
# The trap this exists to avoid is the FIX's failure mode, not the bug's. A
# filter matching nothing runs zero cases and would report
# `passed=0 failed=0` — indistinguishable from a clean run and greener than
# a real one, the 4.55a phantom-pass shape where the absence of a signal
# reads as a good signal. So the filter is not done when it selects
# correctly. It is done when it CANNOT report success without saying how
# many cases it ran. Hence: RAN is in every summary line, an empty match is
# a loud exit 2 and never a pass, and an unfiltered run asserts RAN against
# the case count derived from this file — the equality count-check.sh has
# assumed since 2026-08-06 on the strength of one hand-check.
set -uo pipefail
# ABSOLUTE, resolved before anything cds (2026-09-10). This was
# `${BASH_SOURCE[0]}` for four minutes and that is a defect: the run cds
# into the copied tree at line 67, so the unfiltered RAN assertion below
# re-read `docs/guard-matrix.sh` from the COPY of whatever repo was passed
# in, not from the script actually executing. Against this repo it is
# invisible, because the copy is byte-identical — the failure needs two
# trees whose case counts differ, e.g. running this script against an older
# clone, which then reports `MATRIX INCOMPLETE` for a complete run.
# Demonstrated before the fix against a 3-case stub: `3 cases declared but
# RAN=150`, exit 2. The relative-path-from-the-wrong-root class, inside the
# guard whose job is refusing to vouch for a run it cannot verify.
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
# 5.26: --shard i/N runs one partition of the case set; --list names a
# shard's cases and runs none of them, which is what makes the partition
# cheap to ASSERT (check.sh §39) rather than trusted.
REPO=""; ONLY=""; SHARD_I=""; SHARD_N=""; LIST=0; _pos=0
_usage() { echo "usage: guard-matrix.sh <repo> [case-filter-regex] [--shard i/N] [--list]" >&2; exit 2; }
_shard_set() {
  case "$1" in
    [1-9]*/[1-9]*) SHARD_I="${1%%/*}"; SHARD_N="${1##*/}" ;;
    *) echo "guard-matrix: --shard needs i/N with both >= 1 (e.g. --shard 2/4)" >&2; exit 2 ;;
  esac
  case "$SHARD_I$SHARD_N" in *[!0-9]*) echo "guard-matrix: --shard i/N must be integers, got $1" >&2; exit 2 ;; esac
  [ "$SHARD_I" -le "$SHARD_N" ] || { echo "guard-matrix: shard $SHARD_I of $SHARD_N does not exist" >&2; exit 2; }
}
while [ "$#" -gt 0 ]; do
  case "$1" in
    --shard)   shift; [ "$#" -gt 0 ] || _usage; _shard_set "$1" ;;
    --shard=*) _shard_set "${1#--shard=}" ;;
    --list)    LIST=1 ;;
    -*)        echo "guard-matrix: unknown option $1" >&2; _usage ;;
    *)         _pos=$((_pos + 1))
               case "$_pos" in 1) REPO="$1" ;; 2) ONLY="$1" ;; *) _usage ;; esac ;;
  esac
  shift
done
[ -n "$REPO" ] || _usage
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

# Every case function must gate on the filter, and a new one that forgets
# would run unfiltered and silently — a case class quietly ignoring the
# selection, which is the same silent-scope class as a hardcoded roster
# under-counting the day a name is added (4.82, 5.8). DERIVED from this
# file rather than listed: definitions counted against gates.
_defs="$(grep -cE '^(check|[a-z]+case)\(\) *\{' "$SELF")"
_gates="$(grep -cE '^  _case_start "\$n" \|\| return 0$' "$SELF")"
if [ "$_defs" -ne "$_gates" ]; then
  echo "guard-matrix: $_defs case function(s) but $_gates filter gate(s)."
  echo "  A case function without the gate ignores the filter and runs"
  echo "  unfiltered, silently. Add the gate as the first line of its body."
  exit 2
fi

# --- SNAPSHOT ONCE (4.55a) -----------------------------------------------
# Every case used to `cp -R "$REPO"` afresh, so a long run re-sampled the
# LIVE working tree per case and later cases saw a different tree than
# earlier ones. Editing anything mid-run — a PLAN.md checkbox is enough,
# since it moves a count-check-derived number — produced phantom failures:
# two wasted runs and three bogus case failures on 2026-08-07, none a
# defect. A matrix that cries wolf is one you stop reading.
#
# .git and .acstack-banned are dropped HERE, once, because every case
# deleted them anyway — and .git was 16M of every 18M copied, measured
# 2026-08-08 against a 31.3 s/case, ~55-minute run.
SRC="$WORK/src"
# --list executes no case, so it needs neither the snapshot nor the hash;
# skipping both is what keeps §39's partition assertion cheap enough to run
# on every commit (8 walks in well under a second, versus ~8 x 0.4 s).
if [ "$LIST" -eq 0 ]; then
cp -R "$REPO" "$SRC" 2>/dev/null
rm -rf "$SRC/.git" "$SRC/.acstack-banned"
fi

# The run still records what the live tree looked like at start, so a
# mid-run edit is NAMED rather than silently ignored. It is a NOTE, not a
# failure: the results are valid for the snapshot they were taken from, and
# aborting a ~15-minute run over an unrelated edit is the cure being worse
# than the disease.
tree_hash() { find "$1" -name .git -prune -o -type f -exec shasum {} + 2>/dev/null | sort | shasum | awk '{print $1}'; }
H0=""
if [ "$LIST" -eq 0 ]; then
H0="$(tree_hash "$REPO")"

cp -R "$SRC" "$WORK/pack" 2>/dev/null
cd "$WORK/pack" || exit 1
rm -rf skills/*/ 2>/dev/null
# keep one known-good skill so principles/budget checks have something valid
mkdir -p skills/good
fi
pass=0; failed=0; RAN=0

# --- 5.8: a seed that changed nothing tested nothing -----------------------
# THE DEFECT. A `sed` whose pattern stops matching writes the file back
# byte-identical and exits 0, so the case runs check.sh against an unmutated
# tree. For a must-FAIL case that surfaces as `got=PASS want=FAIL`, which is
# loud. For a must-PASS case it surfaces as nothing at all — a green case
# that verified an untouched tree. Three no-op seeds were found by hand in a
# single day (2026-08-17); one reached a full run as `passed=148 failed=1`.
#
# WHY THIS IS STRUCTURAL RATHER THAN 49 REWRITES. The task that carried this
# asked to convert 49 `sed` seeds to python3 so each could assert. But `sed`
# is only 49 of ~107 mutating seeds: 21 printf, 12 grep -v, 9 awk, 8 rm and 7
# others rot exactly the same way, and every future seed would depend on its
# author remembering. Hashing the copy either side of the mutation asserts it
# for ALL of them, cannot be forgotten, and costs ~30 ms per case (~9 s on a
# full run, measured 2026-09-10 on 212 files).
#
# The content hash is not negotiable: a metadata hash would see `mv t file`
# as a change even when the bytes are identical, which is precisely the
# no-op being hunted.
seed_hash() { find "$1" -type f -exec shasum {} + 2>/dev/null | sort | shasum | awk '{print $1}'; }

# Cases that legitimately change nothing, each with its reason. The size is
# asserted so a second exemption has to be a deliberate, visible edit — the
# §33 idiom, because an exemption list that grows quietly is how a guard
# stops guarding.
NOMUT_CASES='clean tree stays clean'   # the baseline: an UNmutated tree is the whole point
_nomut() {
  local c oldifs="$IFS"
  IFS='|'
  for c in $NOMUT_CASES; do
    [ "$c" = "$1" ] && { IFS="$oldifs"; return 0; }
  done
  IFS="$oldifs"; return 1
}
_nomut_n="$(printf '%s' "$NOMUT_CASES" | awk -F'|' '{print NF}')"
if [ "$_nomut_n" -ne 1 ]; then
  echo "guard-matrix: NOMUT_CASES lists $_nomut_n entries, expected 1."
  echo "  A new no-op exemption must be deliberate: state the case's reason"
  echo "  above and update this assertion in the same edit."
  exit 2
fi

# The one filter gate. Returns 1 when the case is filtered out, so every
# case function opens by calling it and returning early. RAN counts only
# what actually ran, which is what makes a zero-match run detectable.
# THE ORDINAL IS ASSIGNED BEFORE EVERY TEST, and that order is load-bearing
# (5.26). Assign it after the name filter and the same case lands in
# different shards depending on whether a filter was passed — the partition
# stops being a function of the case set alone, which is the one property
# every assertion below rests on. RAN still counts only what actually ran,
# because the zero-match guard reads it as "cases executed".
_ORD=0
_case_start() { # case-name
  _ORD=$((_ORD + 1))
  if [ -n "$SHARD_N" ]; then
    [ "$(( (_ORD - 1) % SHARD_N ))" -eq "$((SHARD_I - 1))" ] || return 1
  fi
  [ -z "$ONLY" ] || printf '%s' "$1" | grep -qE "$ONLY" || return 1
  if [ "$LIST" -eq 1 ]; then printf '%s\n' "$1"; RAN=$((RAN + 1)); return 1; fi
  RAN=$((RAN + 1))
  return 0
}

check() { # name expected body
  local n="$1" exp="$2" body="$3"
  _case_start "$n" || return 0
  rm -rf skills/tc; mkdir -p skills/tc
  printf '%s' "$body" > skills/tc/SKILL.md
  out="$(ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh 2>&1)"
  if printf '%s' "$out" | grep -qE 'FAIL (description|frontmatter)'; then got=FAIL; else got=PASS; fi
  if [ "$got" = "$exp" ]; then printf '  ok   %-42s %s\n' "$n" "$got"; pass=$((pass+1))
  else printf '  BAD  %-42s got=%s want=%s\n' "$n" "$got" "$exp"; failed=$((failed+1)); fi
}

[ "$LIST" -eq 1 ] || echo "=== frontmatter guard matrix ==="
# --- must PASS: valid frontmatter ---
check "plain valid"            PASS $'---\nname: tc\ndescription: Does a thing. Use when asked.\n---\n'
check "double-quoted"          PASS $'---\nname: tc\ndescription: "Does a thing: really. Use when asked."\n---\n'
check "single-quoted"          PASS $'---\nname: tc\ndescription: \'Does a thing. Use when asked.\'\n---\n'
check "quoted + trailing cmt"  PASS $'---\nname: tc\ndescription: "Does a thing." # note\n---\n'
check "name trailing space"    PASS $'---\nname: tc \ndescription: Does a thing. Use when asked.\n---\n'
check "extra frontmatter keys" PASS $'---\nname: tc\ndescription: Does a thing.\nargument-hint: "[x]"\n---\n'

# --- must FAIL: genuine hazards ---
check "leading hash"           FAIL $'---\nname: tc\ndescription: #1 thing. Use when asked.\n---\n'
check "space-hash truncates"   FAIL $'---\nname: tc\ndescription: wiring Fixes #N here. Use when.\n---\n'
check "colon-space ambiguous"  FAIL $'---\nname: tc\ndescription: sweeps surfaces: auth, secrets.\n---\n'
check "name != dir"            FAIL $'---\nname: other\ndescription: Does a thing. Use when asked.\n---\n'
check "no description"         FAIL $'---\nname: tc\n---\n'
check "no frontmatter at all"  FAIL $'# just a heading\n\nsome text\n'
check "unclosed quote"         FAIL $'---\nname: tc\ndescription: "Does a thing. Use when asked.\n---\n'
# A repeated key: the parser takes the LAST, this guard read the FIRST, so
# the value checked was not the value served (external review, 2026-09-16).
check "duplicate name key"     FAIL $'---\nname: tc\ndescription: Does a thing. Use when asked.\nname: wrong\n---\n'
check "duplicate tools key"    FAIL $'---\nname: tc\ndescription: Does a thing. Use when asked.\nallowed-tools: Read\nallowed-tools: Bash\n---\n'
check "hazard on 2nd desc line" FAIL $'---\nname: tc\ndescription: fine here.\ndescription: wiring Fixes #N here.\n---\n'
check "CRLF line endings"      PASS "$(printf -- '---\r\nname: tc\r\ndescription: Does a thing. Use when asked.\r\n---\r\n')"
check "unknown frontmatter key" FAIL $'---\nname: tc\ndescription: Does a thing. Use when asked.\nbanana: yes\n---\n'

echo
[ "$LIST" -eq 1 ] || echo "=== full-tree seeded-defect matrix ==="
# Cases here copy the REAL tree (minus .git), seed exactly one defect via a
# mutation command, and expect check.sh to emit "FAIL <class>". This tests
# each guard against the tree shape it actually polices; the section above
# tests frontmatter parsing in isolation.
FULL="$WORK/full"

# 5.20.2: which of check.sh's slow sections this case may skip. Derived per
# case from the case's OWN copy of check.sh (some cases mutate check.sh), in
# three steps, each failing safe:
#   1. the skippable sections are the ones wrapped in `if ! _skip N; then`,
#      and a wrapper outside section N stops the whole run, since the
#      section numbers would no longer mean what the wrapper says;
#   2. a section's classes are the literal labels of its FAIL lines; a FAIL
#      whose label is computed (`FAIL $x`) makes the section never skipped;
#   3. a section is skipped only if NONE of its labels matches this case's
#      class, tested with the same `grep -E` the case's assertion uses.
# A skipped section cannot change the outcome: the assertion only greps for
# "FAIL (<class>)", which that section cannot print, and no later section
# reads its variables (checked 2026-09-24: shell_sources and XREF_EXCEPTIONS
# are read nowhere else; its loop variables are set again before use).
_skip_set() { # check.sh-path class-regex -> space-separated sections to skip
  local f="$1" cls="$2" rows sec lab keep out=""
  [ -f "$f" ] || return 0
  rows="$(awk '
    /^# [0-9]+[a-z]?\. / { sec = $2; sub(/\.$/, "", sec) }
    /^if ! _skip [0-9]+[a-z]?; then$/ { n = $4; sub(/;$/, "", n)
      if (n != sec) { print "MISPLACED " n " " sec; next }
      skippable[n] = 1 }
    { line = $0
      while ((i = index(line, "FAIL ")) > 0) {
        rest = substr(line, i + 5)
        if (match(rest, /^[a-z][a-z-]*/)) labels[sec] = labels[sec] " " substr(rest, 1, RLENGTH)
        else dynamic[sec] = 1
        line = rest
      } }
    END { for (n in skippable) print "SECTION " n " " (dynamic[n] ? "DYNAMIC" : "LABELS") labels[n] }
  ' "$f")"
  if printf '%s\n' "$rows" | grep -q '^MISPLACED '; then
    echo "MATRIX: an \`if ! _skip N\` wrapper sits outside section N in $f:" >&2
    printf '%s\n' "$rows" | grep '^MISPLACED ' >&2
    exit 2
  fi
  while read -r _ sec kind labs; do
    [ -n "$sec" ] || continue
    [ "$kind" = LABELS ] || continue
    keep=0
    for lab in $labs; do
      printf 'FAIL %s' "$lab" | grep -qE "FAIL ($cls)" && { keep=1; break; }
    done
    [ "$keep" -eq 1 ] || out="$out $sec"
  done <<EOF_SKIP
$(printf '%s\n' "$rows" | grep '^SECTION ')
EOF_SKIP
  printf '%s' "${out# }"
}

fullcase() { # name expected(PASS|FAIL) class-regex mutation-command...
  local n="$1" exp="$2" cls="$3"; shift 3
  _case_start "$n" || return 0
  rm -rf "$FULL"; cp -R "$SRC" "$FULL"   # $SRC: frozen at start, no .git/.acstack-banned
  local _pre _post
  _pre="$(seed_hash "$FULL")"
  ( cd "$FULL" && "$@" ) >/dev/null 2>&1
  _post="$(seed_hash "$FULL")"
  if [ "$_pre" = "$_post" ] && ! _nomut "$n"; then
    printf '  BAD  %-42s SEED NO-OP — tree unchanged, the case tested nothing\n' "$n"
    failed=$((failed+1)); return 0
  fi
  local skip; skip="$(_skip_set "$FULL/scripts/check.sh" "$cls")" || exit 2
  out="$(cd "$FULL" && ACSTACK_SKIP_SECTIONS="$skip" ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh 2>&1)"
  if printf '%s' "$out" | grep -qE "FAIL ($cls)"; then got=FAIL; else got=PASS; fi
  if [ "$got" = "$exp" ]; then printf '  ok   %-42s %s\n' "$n" "$got"; pass=$((pass+1))
  else printf '  BAD  %-42s got=%s want=%s\n' "$n" "$got" "$exp"; failed=$((failed+1)); fi
}

# bespoke: assert on the FILESYSTEM after check.sh, not on its output. The
# defect this exists for was invisible in stdout — controls.sh ran the eval
# fixture in place and then `rm -rf`d a whole gitignored directory, so the
# guard every commit must pass deleted files it never wrote and said nothing
# (external review, 2026-09-16). A text check cannot catch this: it cannot
# tell `rm -rf skills/*/` inside a temp copy from the same line in the tree,
# and the first attempt at one flagged three legitimate copy-local deletions.
# The property is "my files are still here afterwards", so that is what is
# asserted.
treecase() { # name relative-path-to-plant
  local n="$1" rel="$2"
  _case_start "$n" || return 0
  rm -rf "$FULL"; cp -R "$SRC" "$FULL"
  mkdir -p "$FULL/$(dirname "$rel")"
  printf 'sentinel — a guard must not delete what it did not write\n' > "$FULL/$rel"
  ( cd "$FULL" && ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh ) >/dev/null 2>&1
  if [ -f "$FULL/$rel" ]; then
    printf '  ok   %-42s survived\n' "$n"; pass=$((pass+1))
  else
    printf '  BAD  %-42s DELETED by check.sh — a guard wrote nothing here and removed it anyway\n' "$n"
    failed=$((failed+1))
  fi
}

# bespoke: run check.sh on a clean full copy with a crafted banned list; assert
# on the OUTPUT TEXT (these cases are about the sweep's own error handling).
bannedcase() { # name listfile-content required-regex [second-required-regex]
  local n="$1" content="$2" want="$3" want2="${4:-}"
  _case_start "$n" || return 0
  rm -rf "$FULL"; cp -R "$SRC" "$FULL"   # $SRC: frozen at start, no .git/.acstack-banned
  # 5.8: this shape mutates NO tree by design — the seed is the banned list
  # handed to check.sh, and the copy is deliberately pristine so the sweep's
  # own error handling is what gets tested. So the seed asserted here is the
  # list file, not the tree.
  printf '%s\n' "$content" > "$WORK/blist"
  if [ ! -s "$WORK/blist" ]; then
    printf '  BAD  %-42s SEED NO-OP — banned list is empty, nothing was seeded\n' "$n"
    failed=$((failed+1)); return 0
  fi
  out="$(cd "$FULL" && ACSTACK_BANNED_FILE="$WORK/blist" bash scripts/check.sh 2>&1)" || true
  if printf '%s' "$out" | grep -qE "$want" && { [ -z "$want2" ] || printf '%s' "$out" | grep -qE "$want2"; }; then
    printf '  ok   %-42s matched\n' "$n"; pass=$((pass+1))
  else printf '  BAD  %-42s output lacked /%s/%s\n' "$n" "$want" "${want2:+ or /$want2/}"; failed=$((failed+1)); fi
}

# clean copy of the real tree must not fail ANY class
treecase "results dir survives the guard" "fixtures/eval-run/eval/results/SENTINEL.txt"
fullcase "clean tree stays clean"     PASS '.*' true
# 4.1 version/changelog agreement
fullcase "version mismatch"           FAIL 'version' bash -c 'echo 9.9.9 > VERSION'
fullcase "version malformed"          FAIL 'version' bash -c 'echo banana > VERSION'
fullcase "changelog missing"          FAIL 'version' rm CHANGELOG.md
# 4.17 guard coverage
fullcase "routing line missing"       FAIL 'routing'  bash -c "grep -v 'Adjacent skills:' skills/do/SKILL.md > t && mv t skills/do/SKILL.md"
fullcase "dangling skill reference"   FAIL 'crossref' bash -c "printf 'Pair with /nonexistent-skill for depth.\n' >> skills/do/SKILL.md"
fullcase "missing reference file"     FAIL 'crossref' bash -c "printf 'See references/ghost.md for detail.\n' >> skills/do/SKILL.md"
fullcase "dangling cross-skill citation" FAIL 'crossref' bash -c "printf 'See ../ghost/references/gone.md too.\n' >> skills/do/SKILL.md"
fullcase "root-relative citation"     FAIL 'crossref' bash -c "printf 'Also skills/audit/references/known-bug-classes.md here.\n' >> skills/do/SKILL.md"
fullcase "config key not in template" FAIL 'config'  bash -c "grep -v 'base-url' templates/acstack.md > t && mv t templates/acstack.md"
fullcase "config consumer silent on key" FAIL 'config' bash -c "awk '{print} /journal-commit-format/ && !d {print \"| \`phantom-key\` | \`x\` | /do |\"; d=1}' README.md > t && mv t README.md; printf -- '- phantom-key: x\n' >> templates/acstack.md"
fullcase "verdict stance removed"     FAIL 'verdict' bash -c "grep -iv 'verdict' skills/qa/SKILL.md > t && mv t skills/qa/SKILL.md"
# 4.15 positive controls — regress a documented command; the control must fail
fullcase "regressed secret pattern caught"  FAIL 'controls' bash -c "sed -e 's/sk\[-_\]\[A-Za-z0-9_-\]/sk-[A-Za-z0-9]/' skills/secure/references/security-surfaces.md > t && mv t skills/secure/references/security-surfaces.md"
fullcase "gutted mock-data pattern caught"  FAIL 'controls' bash -c "sed -e 's/mockData|//' skills/design-audit/references/design-conventions.md > t && mv t skills/design-audit/references/design-conventions.md"
fullcase "lost fixture plant caught"        FAIL 'controls' rm fixtures/secure/config.js
fullcase "lost instruction-quality plant"   FAIL 'controls' rm fixtures/health/AGENTS.md
# 4.39 inverted control: the no-DB fixture's value is the ABSENCE of signals
fullcase "no-DB fixture gains a db signal"  FAIL 'controls' bash -c "printf 'DATABASE_URL=postgres://x\n' > fixtures/migrate-check-no-db/.env"
# 17: the ladder without its never-cut floor is "write less code", unbounded
fullcase "simplicity ladder loses its floor" FAIL 'ladder' bash -c "grep -v 'NEVER about validation, error handling, security, or' skills/do/SKILL.md > t && mv t skills/do/SKILL.md"
# recheck A.1 — silent-disable and evasion classes found 2026-07-30
bannedcase "invalid banned entry fails loudly"  'acstack
broken(' 'FAIL banned'
bannedcase "comments-only list SKIPs, runs on"  '# just a comment' 'SKIP banned' 'no failures, but'
fullcase "fixtures dir removed"             FAIL 'controls' rm -rf fixtures
fullcase "colon-suffixed dangling ref"      FAIL 'crossref' bash -c "printf 'Run /ghost-first: it cleans up.\n' >> skills/do/SKILL.md"
fullcase "backtick-quoted dangling ref"     FAIL 'crossref' bash -c "printf 'Pair with \`/ghost-second\` next.\n' >> skills/do/SKILL.md"
fullcase "template key line gone, prose left" FAIL 'config' bash -c "sed -e '/^- push:/d' templates/acstack.md > t && mv t templates/acstack.md"
fullcase "audit plant reduced to prose"     FAIL 'controls' bash -c "printf 'the en dash \xe2\x80\x93 and nbsp \xc2\xa0 sit in prose\n' > fixtures/audit/compare.py"
fullcase "dollar-prefixed git grep hazard"  FAIL 'regex'   bash -c "printf '%s\n' '\$ git grep -E '\''\\bfoo'\''' >> skills/qa/references/probe-layer.md"
# 3b extension: a backreference is an INVALID ESCAPE in ERE — the grep errors
# out and matches nothing. Shipped once in test-audit-rules.md (2026-08-03).
fullcase "backreference in a documented grep" FAIL 'regex' bash -c "printf '%s\n' \"git grep -nE 'Equal\\(([A-Za-z]+), \\\\1\\)'\" >> skills/qa/references/probe-layer.md"
# 4.10: the seeded bad-suite fixture for /audit tests
fullcase "lost /audit tests plant"          FAIL 'controls' rm fixtures/audit-tests/tests/test_cart.py
# 4.27: the ai-tells rule classes lose their seeded fixture
fullcase "lost ai-tells plant"              FAIL 'controls' rm fixtures/design-audit/motion.css
# 4.30: the /design before-page loses a seeded gap and stops being a valid before
fullcase "design before-page fixed up"      FAIL 'controls' bash -c "sed -e 's/width: 680px/max-width: 680px/' fixtures/design/index.html > t && mv t fixtures/design/index.html"
# 21: the 4.28 hygiene rule set is five rules across five skills; dropping one
# is invisible in a green run — nothing fails, the reports just get noisier.
fullcase "hygiene rule set loses a rule"    FAIL 'hygiene' bash -c "grep -vi 'Do NOT flag these' skills/audit/references/code-report-template.md > t && mv t skills/audit/references/code-report-template.md"
# 4.32: both clustering fixtures. The negative one matters most — without it
# a clustering pass that always finds clusters would look correct.
fullcase "clustering fixture loses a task"  FAIL 'controls' bash -c "grep -v '1.8' fixtures/triage/clustered-PLAN.md > t && mv t fixtures/triage/clustered-PLAN.md"
fullcase "independent fixture goes missing" FAIL 'controls' rm fixtures/triage/independent-PLAN.md
# 5.5: the /deps upgrade fixture's discriminator is the positional call site.
# Rewriting every site to the options-object form — the realistic rot, someone
# "fixing" the fixture — leaves the BREAKING entry with nothing to break, and
# the control must say so. python3 so the seed asserts it mutated (5.8).
fullcase "deps upgrade fixture loses its call sites" FAIL 'controls' bash -c "python3 - <<'EOF'
import pathlib
n = 0
for p in sorted(pathlib.Path('fixtures/deps/upgrade/src').glob('*.js')):
    s = p.read_text()
    t = s.replace('createClient(\"https://', 'createClient({ url: \"https://')
    if t != s:
        p.write_text(t); n += 1
assert n > 0, 'seed no-op: no positional call site found'
EOF"
# 20: /design without all eight items is the mockup generator 4.30 exists not to be.
# The mutation deletes the BODY item only — the frontmatter description still
# says "real content", which is exactly how a looser guard stayed green.
fullcase "design loses a readiness item"    FAIL 'design' bash -c "grep -v '[*][*]Real content[.][*][*]' skills/design/SKILL.md > t && mv t skills/design/SKILL.md"
fullcase "design loses its floor rule"      FAIL 'design' bash -c "grep -vi 'never lower the floor' skills/design/SKILL.md > t && mv t skills/design/SKILL.md"
# 19: /refactor without its same-count proof is "refactor and hope"
fullcase "refactor loses its count proof"   FAIL 'refactor' bash -c "grep -viE 'same (test )?count' skills/refactor/SKILL.md > t && mv t skills/refactor/SKILL.md"
fullcase "headingless changelog fails, not dies" FAIL 'version' bash -c "printf '# Changelog\nno versioned headings here\n' > CHANGELOG.md"
# 4.2 runtime preamble — identity, presence, and the hard budget
fullcase "runtime block drifts in one skill"  FAIL 'runtime' bash -c "sed -e 's/proceeding without recall/proceeding sans recall/' skills/do/SKILL.md > t && mv t skills/do/SKILL.md"
fullcase "runtime block missing from a skill" FAIL 'runtime' bash -c "awk '/<!-- acstack:runtime -->/{f=1} !f{print} /<!-- \\/acstack:runtime -->/{f=0}' skills/do/SKILL.md > t && mv t skills/do/SKILL.md"
fullcase "preamble grown past its budget"     FAIL 'runtime' bash -c "awk '{print} /<!-- acstack:runtime -->/{print \"pad line one\"; print \"pad line two\"}' README.md > t && mv t README.md"
# 4.8 read-only tool declarations
fullcase "read-only skill loses allowed-tools" FAIL 'readonly' bash -c "grep -v '^allowed-tools:' skills/resume/SKILL.md > t && mv t skills/resume/SKILL.md"
fullcase "read-only skill granted Write"       FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Write, Read/' skills/secure/SKILL.md > t && mv t skills/secure/SKILL.md"
fullcase "read-only skill granted bare Bash"   FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash, Read/' skills/audit/SKILL.md > t && mv t skills/audit/SKILL.md"
# 4.9 referral roster must match the typed-only skill set exactly
fullcase "filesystem path is not a skill ref" PASS 'crossref' bash -c "printf '%s\n' '#!/usr/bin/env python3' 'read /etc/hosts and /var/log' >> skills/do/SKILL.md"
fullcase "referral roster missing a skill"    FAIL 'referral' bash -c "grep -v '^| \`/eval-spec\`' AGENTS.md > t && mv t AGENTS.md"
fullcase "referral roster names a model-invocable skill" FAIL 'referral' bash -c "awk '/END:acstack-referrals/{print \"| \`/ship\` | releases a branch | never |\"} {print}' AGENTS.md > t && mv t AGENTS.md"
# recheck A.2 — silent-death and evasion classes found 2026-07-30 (round 3)
fullcase "empty referral roster fails loudly"  FAIL 'referral' bash -c "grep -v '^| .\/' AGENTS.md > t && mv t AGENTS.md"
fullcase "config table header renamed"        FAIL 'config'   bash -c "sed -e 's/^| Key | Values.*/| Key | Allowed | Consumed by |/' README.md > t && mv t README.md"
fullcase "read-only granted Bash(rm)"         FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(rm:*), Read/' skills/audit/SKILL.md > t && mv t skills/audit/SKILL.md"
fullcase "read-only granted Bash(*)"          FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(*), Read/' skills/health/SKILL.md > t && mv t skills/health/SKILL.md"
fullcase "read-only granted Bash(find)"     FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(find:*), Read/' skills/secure/SKILL.md > t && mv t skills/secure/SKILL.md"
fullcase "read-only granted Bash(awk)"      FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(awk:*), Read/' skills/resume/SKILL.md > t && mv t skills/resume/SKILL.md"
fullcase "read-only granted Bash(sed -n)"   FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(sed -n:*), Read/' skills/audit/SKILL.md > t && mv t skills/audit/SKILL.md"
fullcase "read-only granted Bash(git remote)" FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(git remote:*), Read/' skills/resume/SKILL.md > t && mv t skills/resume/SKILL.md"
fullcase "read-only granted Bash(curl)"     FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(curl:*), Read/' skills/secure/SKILL.md > t && mv t skills/secure/SKILL.md"
fullcase "read-only skill file missing"       FAIL 'readonly' rm skills/resume/SKILL.md
# 2026-08-03 recheck round 3 — the allowlist audit that framed agents to DISPROVE.
# Each of these passed §13 clean before the fix in the same commit; all four are
# demonstrated FAILING first (run the matrix against the pre-fix check.sh).
#   - a write tool appended LAST slipped through: `printf '%s'` left the final
#     comma-field unterminated, so `read` dropped it and never validated it.
#   - `sort -o`, `git symbolic-ref <ref>` write/mutate under free args yet sat on
#     the allowlist unused — the allowlist was a plausible-looking set, not the
#     audited union of what the six skills actually grant.
#   - a second `allowed-tools:` line hid a write grant from `head -1`.
fullcase "read-only Write as last token"       FAIL 'readonly' bash -c "sed -e 's/^\\(allowed-tools:.*\\)/\\1, Write/' skills/resume/SKILL.md > t && mv t skills/resume/SKILL.md"
fullcase "read-only granted Bash(sort)"        FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(sort:*), Read/' skills/audit/SKILL.md > t && mv t skills/audit/SKILL.md"
fullcase "read-only granted Bash(git symbolic-ref)" FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(git symbolic-ref:*), Read/' skills/health/SKILL.md > t && mv t skills/health/SKILL.md"
fullcase "read-only duplicate allowed-tools line"   FAIL 'readonly' bash -c "awk '/^allowed-tools:/ && !d {print; print \"allowed-tools: Write\"; d=1; next} {print}' skills/secure/SKILL.md > t && mv t skills/secure/SKILL.md"
# git grep left the allowlist entirely (its -O<pager> runs an arbitrary program;
# the four skills apply patterns via the read-only Grep tool now). Granting it
# back must be rejected — this passed clean while git grep was allowlisted.
fullcase "read-only granted Bash(git grep)"    FAIL 'readonly' bash -c "sed -e 's/^allowed-tools: Read/allowed-tools: Bash(git grep:*), Read/' skills/secure/SKILL.md > t && mv t skills/secure/SKILL.md"
# 13a forcing function: a no-write allowed-tools set on a skill NOT in
# READONLY_SKILLS is a structural read-only claim that escapes §13's allowlist
# check. ticket is a writer with no allowed-tools; giving it one must fail.
fullcase "no-write allowed-tools escapes READONLY_SKILLS" FAIL 'readonly' bash -c "awk '/^name: ticket/{print; print \"allowed-tools: Read, Grep, Glob\"; next} {print}' skills/ticket/SKILL.md > t && mv t skills/ticket/SKILL.md"
# 16 commit-format: the retired `completed task <number>` default must not return
# (task 4.16 switched it to `task <n>: <desc>`); shown failing first.
fullcase "retired commit-format default returns" FAIL 'commit-format' bash -c "sed -e 's/task <number>: <description>/completed task <number> (<description>)/' README.md > t && mv t README.md"
# 3c: a skill that forbids shell git grep must keep its grep -rnE fallback
# (else a harness with no Grep tool degrades to the removed git grep form).
fullcase "git-grep drop loses its grep fallback" FAIL 'grep-fallback' bash -c "sed '/Use .grep -rnE., never/d' skills/secure/SKILL.md > t && mv t skills/secure/SKILL.md"
fullcase "guard-matrix syntax error caught"   FAIL 'syntax'   bash -c "printf 'if [ ; then\n' >> docs/guard-matrix.sh"
fullcase "conduct block drifts from canon" FAIL 'conduct' bash -c "sed -e 's/^4\. Be direct\./4. Be direct and blunt./' AGENTS.md > t && mv t AGENTS.md"
fullcase "conduct block missing entirely"  FAIL 'conduct' bash -c "awk '/BEGIN:acstack-conduct/{f=1} !f{print} /END:acstack-conduct/{f=0}' CONDUCT.md > t && mv t CONDUCT.md"
# guards that had NO matrix case until 2026-07-31 — found by an audit that
# checked 4.7's bar ("every guard shown firing") against the matrix itself
fullcase "principles block drifts"        FAIL 'principles' bash -c "sed -e 's/^- Be direct\./- Be direct and terse./' skills/do/SKILL.md > t && mv t skills/do/SKILL.md"
fullcase "SKILL.md over line budget"      FAIL 'budget'  bash -c "for i in \$(seq 1 500); do echo 'pad line'; done >> skills/do/SKILL.md"
# 5.12: §28's TOTAL branch. The case above is §4's SKILL.md LINE budget — a
# different branch of a different check — so the constant 5.7 moved from
# 12000 to 13500 had no matrix coverage at all until now.
#
# THE CLASS REGEX IS THE POINT. All four of §28's failures print
# `FAIL budget:`, so matching the bare class would be satisfied by whichever
# branch happened to fire. That is exactly the contamination 5.7 hit by hand:
# its first control padded ONE description to 3920 chars, tripped the
# PER-DESCRIPTION cap, and proved nothing about the total while appearing to.
# Matching `budget: skill descriptions total` is what makes only the total
# branch able to satisfy these cases.
#
# Both seeds DERIVE both caps from check.sh rather than naming 13500 or 600,
# so the next ruling that moves either number cannot turn them into no-ops —
# the rot that hit three seeds in one day (5.8).
fullcase "budget: description total over cap" FAIL 'budget: skill descriptions total' bash -c "python3 - <<'EOF'
import pathlib, re
s = pathlib.Path('scripts/check.sh').read_text()
TOT = int(re.search(r'^BUDGET_TOTAL=(\d+)', s, re.M).group(1))
ONE = int(re.search(r'^BUDGET_ONE=(\d+)', s, re.M).group(1))
def rows():
    r = []
    for f in sorted(pathlib.Path('skills').glob('*/SKILL.md')):
        t = f.read_text().splitlines(keepends=True)
        for i, l in enumerate(t):
            if re.match(r'^description:\s', l):
                r.append((f, i, t, len(re.sub(r'^description:\s*', '', l.rstrip(chr(10)))))); break
    return r
def pad(line, target):
    v = re.sub(r'^description:\s*', '', line); n = target - len(v)
    if n <= 0: return line
    p = 'x' * n
    v = v[:-1] + p + v[-1] if len(v) > 1 and v[0] == v[-1] and v[0] in '\"' + chr(39) else v + p
    return 'description: ' + v
r = rows(); assert r, 'seed no-op: no descriptions found'
for f, i, t, vlen in r:
    if vlen < ONE:
        t[i] = pad(t[i].rstrip(chr(10)), ONE) + chr(10); f.write_text(''.join(t))
a = rows(); tot = sum(v for *_, v in a)
assert max(v for *_, v in a) <= ONE, 'seed invalid: a single description exceeds BUDGET_ONE — this would fire the WRONG branch'
assert tot > TOT, 'seed cannot fire: total ' + str(tot) + ' <= cap ' + str(TOT)
EOF"
# The must-not-fire arm sits at EXACTLY the cap, not one under it. 5.12's text
# asked for one-under; the boundary value is strictly stronger, because §28
# tests `-gt` and an off-by-one to `-ge` fires at the cap and is invisible one
# char below it. Proven both ways before this was trusted.
fullcase "budget: total exactly at the cap"   PASS 'budget: skill descriptions total' bash -c "python3 - <<'EOF'
import pathlib, re
s = pathlib.Path('scripts/check.sh').read_text()
TOT = int(re.search(r'^BUDGET_TOTAL=(\d+)', s, re.M).group(1))
ONE = int(re.search(r'^BUDGET_ONE=(\d+)', s, re.M).group(1))
def rows():
    r = []
    for f in sorted(pathlib.Path('skills').glob('*/SKILL.md')):
        t = f.read_text().splitlines(keepends=True)
        for i, l in enumerate(t):
            if re.match(r'^description:\s', l):
                r.append((f, i, t, len(re.sub(r'^description:\s*', '', l.rstrip(chr(10)))))); break
    return r
def pad(line, target):
    v = re.sub(r'^description:\s*', '', line); n = target - len(v)
    if n <= 0: return line
    p = 'x' * n
    v = v[:-1] + p + v[-1] if len(v) > 1 and v[0] == v[-1] and v[0] in '\"' + chr(39) else v + p
    return 'description: ' + v
r = rows(); assert r, 'seed no-op: no descriptions found'
need = TOT - sum(v for *_, v in r)
assert need > 0, 'seed no-op: baseline is already at or over the cap'
assert sum(ONE - v for *_, v in r) >= need, 'not enough headroom to reach the cap without breaching BUDGET_ONE'
for f, i, t, vlen in r:
    if need <= 0: break
    add = min(ONE - vlen, need)
    if add <= 0: continue
    t[i] = pad(t[i].rstrip(chr(10)), vlen + add) + chr(10); f.write_text(''.join(t)); need -= add
assert need == 0, 'seed missed the cap by ' + str(need)
a = rows(); tot = sum(v for *_, v in a)
assert tot == TOT, 'seed landed at ' + str(tot) + ', not exactly ' + str(TOT)
assert max(v for *_, v in a) <= ONE, 'seed invalid: a single description exceeds BUDGET_ONE'
EOF"
fullcase "shell syntax error in setup"    FAIL 'syntax'  bash -c "printf 'if [ ; then\n' >> setup"
bannedcase "a planted banned token is caught" 'zzqqplanted' 'FAIL banned names'
# the budget case must trip the BUDGET, not byte-identity: grow the block
# in README *and* every skill so the diff still matches
fullcase "preamble over budget, identity intact" FAIL 'runtime' bash -c "for f in README.md skills/*/SKILL.md; do awk '/<!-- \\/acstack:runtime -->/{print \"pad1\"; print \"pad2\"} {print}' \$f > t && mv t \$f; done"
fullcase "preamble fails open on unresolved pack" FAIL 'runtime' bash -c "sed -e 's|if \[ \"\${link#/}\" != \"\$link\" \] && |if |' README.md > t && mv t README.md"
# 22: the four grader sites must agree on the case rule. Shakedown 10 found the
# runner template folding case unconditionally against the flag the spec
# template documents — a verbatim scaffold silently ignored the spec.
fullcase "grader site drops the case flag" FAIL 'grader-case' bash -c "sed -e 's/case_sensitive/caseflaggone/g' skills/eval-run/references/runner-template.md > t && mv t skills/eval-run/references/runner-template.md"
# 4.48 marked-count drift. Four ways this guard can rot: a value going stale,
# the implementation vanishing, a marker being renamed to a name with no
# derivation, and the comparison being neutered into a blanket accept.
# DERIVED (2026-08-17). This hardcoded `-->23<!--`; enrolling a 24th skill made
# the sed match nothing, and the case reported got=PASS want=FAIL — a no-op seed,
# the third of its kind found today. sed cannot assert it changed anything.
# ~~which is why AGENTS.md says python3~~ **Corrected 2026-09-10 (5.8):**
# AGENTS.md says no such thing and never did — its six repo-binding rules were
# enumerated and none concerns sed or python3. Three places cited that rule
# (this comment, PLAN 5.8, a JOURNAL line); nothing could catch it, because
# §8's crossref guard resolves skill and reference citations, not prose claims
# about what another document says. The rule's PURPOSE is now met mechanically
# by the seed_hash check above, for every seed shape rather than for python3
# ones — so no such rule is being added to AGENTS.md.
fullcase "marked count goes stale"        FAIL 'count' bash -c "python3 - <<'EOF'
import re, pathlib
p = pathlib.Path('JOURNAL.md'); s = p.read_text()
m = re.search(r'<!-- count:skills -->(\\d+)<!-- /count -->', s)
assert m, 'seed no-op: count:skills marker not found'
n = s.replace(m.group(0), '<!-- count:skills -->' + str(int(m.group(1)) + 77) + '<!-- /count -->', 1)
assert n != s, 'seed no-op'
p.write_text(n)
EOF"
fullcase "count-check implementation gone" FAIL 'count' bash -c "rm -f scripts/count-check.sh"
fullcase "marker renamed to unknown count" FAIL 'count' bash -c "sed -e 's/count:skills/count:skillz/g' JOURNAL.md > t && mv t JOURNAL.md"
fullcase "comparison neutered to accept-all" FAIL 'control' bash -c "sed -e 's/if \[ \"\$val\" != \"\$want\" \]; then/if false; then/' scripts/count-check.sh > t && mv t scripts/count-check.sh"
# 5.x repo-rules: the enumeration of AGENTS.md's repo-binding rules. NEW
# COVERAGE AXIS, stated because it is the reason this case exists: every count
# case above mutates the MARKER and leaves the counted reality alone. None
# mutates the thing being counted, so a rule added to or dropped from the
# enumeration while both markers stay put was invisible to the matrix. That is
# the direction this drifted by hand until 2026-09-11, and it fires on
# AGENTS.md and JOURNAL.md together because both restate the number.
# DERIVED, not hardcoded (5.8): the seed finds the LAST rule bullet in the
# block rather than naming rule 7's text, so rewording a rule cannot turn this
# into a no-op seed.
fullcase "repo-rule dropped from enumeration" FAIL 'count: AGENTS\.md' bash -c "python3 - <<'EOF'
import pathlib
p = pathlib.Path('AGENTS.md'); s = p.read_text()
lines = s.split('\n')
start = next(i for i, l in enumerate(lines) if l.startswith('Verification rules (added'))
end = next(i for i, l in enumerate(lines) if i > start and l.startswith('These '))
idx = [i for i in range(start, end) if lines[i].startswith('- **')]
assert idx, 'seed no-op: no repo-binding rule bullets found'
lines[idx[-1]] = '  ' + lines[idx[-1]][2:]
n = '\n'.join(lines)
assert n != s, 'seed no-op'
p.write_text(n)
EOF"
# 5.17.3 /learn's sighting trail. TWO cases because the guard has two halves
# and either failing alone is a real defect: the template regressing to a
# stored total (the measured multi-session loss), and the list losing its
# dated line so the "count IS the lines" property quietly stops holding.
# Seeds are DERIVED: they rewrite whatever the template currently says rather
# than naming its exact text, so rewording the skill cannot no-op them.
fullcase "seen-count regresses to a total"  FAIL 'seen-shape' bash -c "python3 - <<'EOF'
import pathlib, re
p = pathlib.Path('skills/learn/SKILL.md'); s = p.read_text()
n = re.sub(r'- \*\*Seen:\*\*\n(  - [^\n]*\n)+', '- **Seen:** 1\n', s, count=1)
assert n != s, 'seed no-op: the Seen list shape was not found'
p.write_text(n)
EOF"
fullcase "seen list loses its dated line"   FAIL 'seen-shape' bash -c "python3 - <<'EOF'
import pathlib, re
p = pathlib.Path('skills/learn/SKILL.md'); s = p.read_text()
n = re.sub(r'(- \*\*Seen:\*\*\n)(  - [^\n]*\n)+', r'\1', s, count=1)
assert n != s, 'seed no-op: the Seen list shape was not found'
p.write_text(n)
EOF"
# 37: duplicate identifiers in PLAN.md are the trace of two concurrent filings
# (5.17.1). Both seeds derive the ID they duplicate from the file itself, so a
# renumbered plan cannot no-op them; python3 so each asserts it mutated (5.8).
fullcase "duplicate task ID in PLAN"      FAIL 'identifier' bash -c "python3 - <<'EOF'
import io, re
s = io.open('PLAN.md', encoding='utf-8').read()
m = re.search(r'^ *- \[[ x]\] \*\*([0-9]+(?:\.[0-9]+)*)\*\*', s, re.M)
assert m, 'seed no-op: no task ID line found'
s = s.rstrip('\n') + '\n- [ ] **' + m.group(1) + '** duplicate filing (seeded).\n  **Acceptance:** seeded.\n'
io.open('PLAN.md', 'w', encoding='utf-8').write(s)
EOF"
fullcase "duplicate wave heading in PLAN" FAIL 'identifier' bash -c "python3 - <<'EOF'
import io, re
s = io.open('PLAN.md', encoding='utf-8').read()
m = re.search(r'^## \[[ x]\] Wave ([0-9A-Z]+(?:\.[0-9]+)?)', s, re.M)
assert m, 'seed no-op: no wave heading found'
s = s.rstrip('\n') + '\n\n## [ ] Wave ' + m.group(1) + ' — duplicate phase (seeded)\n'
io.open('PLAN.md', 'w', encoding='utf-8').write(s)
EOF"
# 5.27: §11's negative control must catch a count-check that rejects what
# matches it, and must NOT fire on real marker drift — that is §23's finding,
# and until 2026-09-16 every post-merge tree failed both. Seeds derive their
# targets from the files; python3 so each asserts it mutated (5.8).
fullcase "count-check rejecting everything is caught" FAIL 'controls' bash -c "python3 - <<'EOF'
import io
p = 'scripts/count-check.sh'
s = io.open(p, encoding='utf-8').read()
old = '    if [ \"\$val\" != \"\$want\" ]; then'
assert s.count(old) == 1, 'seed no-op: comparison line not found'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '    if true; then'))
EOF"
fullcase "marker drift is not a controls failure" PASS 'controls' bash -c "python3 - <<'EOF'
import io, re
p = 'JOURNAL.md'
s = io.open(p, encoding='utf-8').read()
new, n = re.subn(r'(<!-- count:[a-z0-9-]+ -->)([0-9]+)(<!-- /count -->)', lambda m: m.group(1) + str(int(m.group(2)) + 1) + m.group(3), s, count=1)
assert n == 1, 'seed no-op: no marker found in JOURNAL.md'
io.open(p, 'w', encoding='utf-8').write(new)
EOF"
# 38: the class-D scope line is one source line per skill; losing it in any
# of the three, or the roster's size drifting, must fail (5.17.4/.5/.6).
fullcase "health loses its scope line"  FAIL 'scope' bash -c "python3 - <<'EOF'
import io
p = 'skills/health/SKILL.md'
L = io.open(p, encoding='utf-8').read().split('\n')
k = [l for l in L if '**Scope:** branch' in l]
assert k, 'seed no-op: no scope line in health'
io.open(p, 'w', encoding='utf-8').write('\n'.join(l for l in L if l not in k))
EOF"
fullcase "resume loses its scope line"  FAIL 'scope' bash -c "python3 - <<'EOF'
import io
p = 'skills/resume/SKILL.md'
L = io.open(p, encoding='utf-8').read().split('\n')
k = [l for l in L if '**Scope:** branch' in l]
assert k, 'seed no-op: no scope line in resume'
io.open(p, 'w', encoding='utf-8').write('\n'.join(l for l in L if l not in k))
EOF"
fullcase "ship loses its scope line"    FAIL 'scope' bash -c "python3 - <<'EOF'
import io
p = 'skills/ship/SKILL.md'
L = io.open(p, encoding='utf-8').read().split('\n')
k = [l for l in L if '**Scope:** branch' in l]
assert k, 'seed no-op: no scope line in ship'
io.open(p, 'w', encoding='utf-8').write('\n'.join(l for l in L if l not in k))
EOF"
fullcase "scope roster size drifts"       FAIL 'scope' bash -c "python3 - <<'EOF'
import io
p = 'scripts/check.sh'
s = io.open(p, encoding='utf-8').read()
old = 'SCOPE_SKILLS=\"health resume ship\"'
assert s.count(old) == 1, 'seed no-op: roster line not found'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'SCOPE_SKILLS=\"health resume ship audit\"'))
EOF"
# 39: the shard partition is the one invariant a sharded run cannot show you
# — a case in zero shards leaves every shard green and the aggregate clean
# (5.26). All four seeds derive their target from the file, so a reworded
# gate or a renumbered shard list cannot quietly no-op them.
fullcase "matrix case in zero shards"     FAIL 'shard' bash -c "python3 - <<'EOF'
import io
p = 'docs/guard-matrix.sh'
s = io.open(p, encoding='utf-8').read()
old = '    [ \"\$(( (_ORD - 1) % SHARD_N ))\" -eq \"\$((SHARD_I - 1))\" ] || return 1'
assert s.count(old) == 1, 'seed no-op: shard gate not found'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, old + chr(10) + '    [ \"\$_ORD\" -ne 7 ] || return 1'))
EOF"
fullcase "matrix case in two shards"      FAIL 'shard' bash -c "python3 - <<'EOF'
import io
p = 'docs/guard-matrix.sh'
s = io.open(p, encoding='utf-8').read()
old = '    [ \"\$(( (_ORD - 1) % SHARD_N ))\" -eq \"\$((SHARD_I - 1))\" ] || return 1'
assert s.count(old) == 1, 'seed no-op: shard gate not found'
new = '    if [ \"\$_ORD\" -ne 7 ]; then' + chr(10) + '  ' + old + chr(10) + '    fi'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, new))
EOF"
fullcase "shard list and divisor disagree" FAIL 'shard' bash -c "python3 - <<'EOF'
import io, re
p = '.github/workflows/check.yml'
s = io.open(p, encoding='utf-8').read()
m = re.search(r'^( *shard: \[)(.+)(\])\$', s, re.M)
assert m, 'seed no-op: no shard list found'
items = [x.strip() for x in m.group(2).split(',')]
assert len(items) > 1, 'seed no-op: shard list too short to shorten'
io.open(p, 'w', encoding='utf-8').write(s[:m.start()] + m.group(1) + ', '.join(items[:-1]) + m.group(3) + s[m.end():])
EOF"
fullcase "fan-in stops reading shard result" FAIL 'shard' bash -c "python3 - <<'EOF'
import io
p = '.github/workflows/check.yml'
s = io.open(p, encoding='utf-8').read()
assert 'needs.matrix.result' in s, 'seed no-op: fan-in never read the shard result'
io.open(p, 'w', encoding='utf-8').write(s.replace('needs.matrix.result', 'needs.matrix.conclusion'))
EOF"
# 39: the gate's needs list is DERIVED from the workflow's own job set, so a
# job added without wiring it into the gate is caught (5.20.2 is filed to add
# exactly that). Both halves: every job needed, every needed job's result read.
fullcase "new CI job the gate ignores"    FAIL 'shard' bash -c "python3 - <<'EOF'
import io
p = '.github/workflows/check.yml'
s = io.open(p, encoding='utf-8').read()
old = chr(10) + '  check:' + chr(10)
assert s.count(old) == 1, 'seed no-op: fan-in job not found'
job = chr(10) + '  seeded-tier:' + chr(10) + '    runs-on: ubuntu-latest' + chr(10) + '    steps:' + chr(10) + '      - run: echo seeded' + chr(10)
io.open(p, 'w', encoding='utf-8').write(s.replace(old, job + old))
EOF"
fullcase "gate needs a job but ignores it" FAIL 'shard' bash -c "python3 - <<'EOF'
import io, re
p = '.github/workflows/check.yml'
s = io.open(p, encoding='utf-8').read()
m = re.search(r'^    needs: \[(.+)\]\$', s, re.M)
assert m, 'seed no-op: no needs list found'
first = [x.strip() for x in m.group(1).split(',')][0]
old = 'needs.' + first + '.result'
assert old in s, 'seed no-op: ' + old + ' never read'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'needs.NOTAJOB.result'))
EOF"
# The eval layer can report a number that is not true (codex review,
# 2026-09-16). Both seeds restore a defect in the RUNNABLE fixture, so the
# control catches them by running the code rather than reading it.
fullcase "eval forgives a null reason"    FAIL 'controls' bash -c "python3 - <<'EOF'
import io
p = 'fixtures/eval-run/eval/run.py'
s = io.open(p, encoding='utf-8').read()
a = '        return _written_reason(case.get(\"reason\"))'
b = '        return _written_reason(af.get(\"reason\"))'
assert a in s and b in s, 'seed no-op: accepted() is not in its fixed form'
s = s.replace(a, '        return bool(str(case.get(\"reason\", \"\")).strip())')
s = s.replace(b, '        return bool(str(af.get(\"reason\", \"\")).strip())')
io.open(p, 'w', encoding='utf-8').write(s)
EOF"
fullcase "eval grading nothing exits ok"  FAIL 'controls' bash -c "python3 - <<'EOF'
import io
p = 'fixtures/eval-run/eval/run.py'
s = io.open(p, encoding='utf-8').read()
i = s.find('    if not scored:')
assert i != -1, 'seed no-op: the zero-graded guard is already absent'
j = s.index('    return 2 if errors else 0', i)
io.open(p, 'w', encoding='utf-8').write(s[:i] + s[j:])
EOF"
# 5.31: three rules grader-rules.md states and no runner honored — curly
# quotes, case_sensitive, and `parse: label:total`. Each seed restores the
# defect in the RUNNABLE fixture, so the control catches it by running the
# code rather than reading it. Each was measured to flip exactly one case:
# q12 and q14 from pass to fail, q13 from fail to PASS — q13 is the sharp
# one, because folding case unconditionally scores a wrong-SHAPE answer as
# correct, which is a false pass rather than a missed catch.
fullcase "grader stops folding curly quotes" FAIL 'controls' bash -c "python3 - <<'EOF'
import io
p = 'fixtures/eval-run/eval/run.py'
s = io.open(p, encoding='utf-8').read()
a = 'for bad, good in LOOKALIKES.items():'
assert a in s, 'seed no-op: the lookalike fold is not in its fixed form'
b = 'for bad, good in [(chr(0x2013), chr(0x2d))]:'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, b))
EOF"
fullcase "grader folds case unconditionally"  FAIL 'controls' bash -c "python3 - <<'EOF'
import io
p = 'fixtures/eval-run/eval/run.py'
s = io.open(p, encoding='utf-8').read()
a = '    return s.lower() if fold_case else s'
assert a in s, 'seed no-op: norm() is not in its fixed form'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, '    return s.lower()'))
EOF"
fullcase "grader ignores the parse label"     FAIL 'controls' bash -c "python3 - <<'EOF'
import io
p = 'fixtures/eval-run/eval/run.py'
s = io.open(p, encoding='utf-8').read()
a = '        av = _pick_number(actual, case)'
c = '        ev = _pick_number(expected, case, authored=True)'
assert a in s and c in s, 'seed no-op: the numeric branch is not in its fixed form'
s = s.replace(a, '        av = (_numbers(actual) or [None])[0]')
s = s.replace(c, '        ev = (_numbers(expected) or [None])[0]')
io.open(p, 'w', encoding='utf-8').write(s)
EOF"

# Three guards that reported clean on the defect they exist to catch
# (external review, 2026-09-16): a marker the checker could not parse, a
# workflow that stopped invoking a guard, and a deleted plugin manifest.
fullcase "unparseable count marker"       FAIL 'count' bash -c "python3 - <<'EOF'
import io, re
p = 'README.md'
s = io.open(p, encoding='utf-8').read()
new, n = re.subn(r'<!-- count:([a-z0-9-]+) -->[0-9]+<!-- /count -->', r'<!-- count:\1 -->wrong<!-- /count -->', s, count=1)
assert n == 1, 'seed no-op: no numeric marker found in README'
io.open(p, 'w', encoding='utf-8').write(new)
EOF"
fullcase "workflow drops a guard step"    FAIL 'shard' bash -c "python3 - <<'EOF'
import io
p = '.github/workflows/check.yml'
s = io.open(p, encoding='utf-8').read()
old = 'bash scripts/check.sh'
assert s.count(old) >= 1, 'seed no-op: the workflow never invoked check.sh'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'echo seeded-skip'))
EOF"
fullcase "plugin manifest deleted"        FAIL 'plugin' rm -f .claude-plugin/plugin.json
# The real defect: an unclosed code span promotes prose to a live heading,
# which §35 then reads as the end of a wave's scope (5.31).
fullcase "unclosed span makes a heading"  FAIL 'planhead' bash -c "python3 - <<'EOF'
import io
p = 'PLAN.md'
s = io.open(p, encoding='utf-8').read()
old = '\`## Open items\` only'
assert s.count(old) == 1, 'seed no-op: the fixed code span is not present'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, '## Open items\` only', 1))
EOF"
# 41: /audit's target roster is stated in three places and drifted once
# already — "described with four targets when it declares five" (5.9).
fullcase "audit hint drops a target"      FAIL 'audittargets' bash -c "python3 - <<'EOF'
import io, re
p = 'skills/audit/SKILL.md'
s = io.open(p, encoding='utf-8').read()
m = re.search(r'^argument-hint: *\"([a-z|]+)', s, re.M)
assert m and '|' in m.group(1), 'seed no-op: no multi-target argument-hint'
kept = '|'.join(m.group(1).split('|')[:-1])
io.open(p, 'w', encoding='utf-8').write(s[:m.start(1)] + kept + s[m.end(1):])
EOF"
fullcase "roster row hides a target"      FAIL 'audittargets' bash -c "python3 - <<'EOF'
import io, re, pathlib
names = re.findall(r'^## Target: ([a-z-]+)', io.open('skills/audit/SKILL.md', encoding='utf-8').read(), re.M)
assert names, 'seed no-op: no target sections'
last = sorted(names)[-1]
# find the advertising row wherever it lives, exactly as check.sh 41 does
hit = None
for f in pathlib.Path('.').rglob('*.md'):
    if '.git' in f.parts:
        continue
    for line in f.read_text(encoding='utf-8').split(chr(10)):
        if line.startswith('| \`/audit\` |') and last in line:
            hit = (f, line)
            break
    if hit:
        break
assert hit, 'seed no-op: no skill-table row names ' + last
f, line = hit
s = f.read_text(encoding='utf-8')
f.write_text(s.replace(line, line.replace(', ' + last, '', 1), 1), encoding='utf-8')
EOF"
# The name-in-the-path mode. The row lives in docs/SKILLS.md, whose PATH
# contains "docs", so `grep -q docs` against a `grep -n` line matched the
# filename prefix and the guard passed on a row that omitted the target.
# The case above cannot reach this: it removes the alphabetically-last name,
# which appears in no path. Derived, not hardcoded, so a rename survives.
fullcase "roster hides a path-named target" FAIL 'audittargets' bash -c "python3 - <<'EOF'
import io, re, pathlib
names = re.findall(r'^## Target: ([a-z-]+)', io.open('skills/audit/SKILL.md', encoding='utf-8').read(), re.M)
assert names, 'seed no-op: no target sections'
hit = None
for f in pathlib.Path('.').rglob('*.md'):
    if '.git' in f.parts:
        continue
    for line in f.read_text(encoding='utf-8').split(chr(10)):
        if not line.startswith('| \`/audit\` |'):
            continue
        # a target whose name also occurs in this file's own path
        for n in names:
            if n in str(f) and n in line:
                hit = (f, line, n)
                break
    if hit:
        break
assert hit, 'seed no-op: no roster row whose path contains one of its own target names'
f, line, n = hit
s = f.read_text(encoding='utf-8')
f.write_text(s.replace(line, line.replace(', ' + n, '', 1).replace(n + ', ', '', 1), 1), encoding='utf-8')
EOF"
# 42: /verify's contract is that every input lands on exactly one verdict.
# Dropping one recreates /migrate-check's Flagged gap, which is invisible
# because each remaining verdict still reads fine — only the SET is wrong.
fullcase "verify loses a verdict"         FAIL 'verdicts' bash -c "python3 - <<'EOF'
import io, re
p = 'skills/verify/SKILL.md'
s = io.open(p, encoding='utf-8').read()
m = re.findall(r'\*\*(CONFIRMED|OVERSTATED|FALSE|UNVERIFIABLE)\*\*', s)
assert m, 'seed no-op: no bolded verdicts found'
target = 'UNVERIFIABLE' if 'UNVERIFIABLE' in m else m[-1]
io.open(p, 'w', encoding='utf-8').write(s.replace('**' + target + '**', '**INCONCLUSIVE**'))
EOF"
fullcase "verify drops the exhaustive claim" FAIL 'verdicts' bash -c "python3 - <<'EOF'
import io
p = 'skills/verify/SKILL.md'
s = io.open(p, encoding='utf-8').read()
old = 'Every input lands on exactly one'
assert s.count(old) == 1, 'seed no-op: the exhaustiveness claim is not present'
io.open(p, 'w', encoding='utf-8').write(s.replace(old, 'These are the verdicts'))
EOF"
# 5.17.2 recount repairs what it claims to. Every prior count case asserts the
# GUARD fires; this one asserts the REPAIR works, which nothing covered — a
# broken rewriter would leave check.sh red and look identical to drift nobody
# fixed. The seed moves the counted REALITY (ticks the last open scheduled
# task) and leaves the marker stale, so it is not self-reversing and cannot be
# a SEED NO-OP; recount then has to find and rewrite it. DERIVED, not
# hardcoded: it locates the last open task inside count-check's own awk range
# rather than naming a task ID, so renumbering cannot no-op it.
fullcase "recount repairs marker drift"    PASS '.*' bash -c "python3 - <<'EOF'
import pathlib, re
p = pathlib.Path('PLAN.md'); s = p.read_text()
lines = s.split('\n')
start = next(i for i, l in enumerate(lines) if re.match(r'^## \[[ x]\] Wave 4\.5', l))
end = next(i for i, l in enumerate(lines) if i > start and re.match(r'^## \[[ x]\] Wave B', l))
idx = [i for i in range(start, end) if lines[i].startswith('- [ ] ')]
assert idx, 'seed no-op: no open scheduled task found in the counted range'
lines[idx[-1]] = lines[idx[-1]].replace('- [ ] ', '- [x] ', 1)
n = '\n'.join(lines)
assert n != s, 'seed no-op'
p.write_text(n)
EOF
bash scripts/recount.sh"
# 4.45 eval-runner isolation. Three ways this rots: a site drops the rule,
# a site drops the model pin, and the seeded unisolated runner quietly
# acquires the flags it exists to lack (that last one surfaces as a control
# failure, which is the layer that owns fixture integrity).
fullcase "eval site drops isolation rule"  FAIL 'eval-isolation' bash -c "sed -e 's/[Ii]solat/redact/g' skills/eval-run/SKILL.md > t && mv t skills/eval-run/SKILL.md"
fullcase "eval site drops the model pin"   FAIL 'eval-isolation' bash -c "sed -e 's/[Pp]in/anchor/g' skills/eval-spec/references/eval-spec-template.md > t && mv t skills/eval-spec/references/eval-spec-template.md"
fullcase "unisolated fixture stops seeding" FAIL 'control' bash -c "sed -e 's|\"claude\", \"-p\", case\[\"input\"\]|\"claude\", \"-p\", case[\"input\"], \"--bare\"|' fixtures/eval-isolation/unisolated-runner.py > t && mv t fixtures/eval-isolation/unisolated-runner.py"
# 4.47 owed-marker reachability. Three ways this rots: a live carrier gets
# closed under a marker still pointing at it, the implementation vanishes,
# and the comparison is neutered into a blanket accept (caught by the
# control layer, not by section 25 itself).
# SELF-CONTAINED AND DERIVED (2026-08-16). This case used to seed
# `- [ ] **4.50**` -> `[x]` and rely on 4.50 already being named by live
# markers. Closing 4.50 made the sed match nothing AND emptied the marker
# set, so the seed became a no-op that would have read as a passing case.
# It now plants its own marker against whichever task is open first, so it
# cannot rot on any future tick.
fullcase "owed-marker carrier gets closed"  FAIL 'reach'   bash -c "python3 - <<'EOF'
import re, pathlib
p = pathlib.Path('PLAN.md'); s = p.read_text()
m = re.search(r'^- \[ \] \*\*(\d+\.\d+)\*\*', s, re.M)
assert m, 'seed no-op: PLAN.md has no open task to close'
tid = m.group(1)
s2 = s.replace(m.group(0), m.group(0).replace('[ ]', '[x]'), 1)
assert s2 != s, 'seed no-op: could not close the task'
s2 += chr(10) + 'Seeded: this behavioural half owes a round [owed: ' + tid + '].' + chr(10)
p.write_text(s2)
EOF"
fullcase "reach-check implementation gone"  FAIL 'reach'   bash -c "rm -f scripts/reach-check.sh"
# NOTE: anchor-free on purpose. The first version of this case anchored on
# '^  fail=1$', which matches nothing — every fail=1 in reach-check.sh sits
# indented inside a case branch — so the case reported got=PASS want=FAIL
# and never demonstrated the guard firing. Same weak-mutation class the
# matrix caught on 4.19.
fullcase "reach comparison neutered"        FAIL 'control' bash -c "sed -e 's/fail=1/fail=0/g' scripts/reach-check.sh > t && mv t scripts/reach-check.sh"
# 4.49 progressive disclosure. The pointer-cites-a-missing-file shape is
# already section 8's (crossref) and is NOT re-tested here. These cover the
# shape section 8 cannot see: a mode heading stranded with no pointer at
# all, and the reference body deleted out from under a live pointer.
fullcase "mode section stranded, no pointer" FAIL 'modesection' bash -c "awk '/^Full procedure: .references\/mode-seed/{skip=3} skip>0{skip--; next} {print}' skills/plan/SKILL.md > t && mv t skills/plan/SKILL.md"
fullcase "split reference body deleted"      FAIL 'crossref'    bash -c "rm -f skills/plan/references/mode-seed.md"
# 4.46 per-category non-regression floor.
fullcase "ship drops the regression floor"  FAIL 'eval-isolation' bash -c "sed -e 's/non-regression/aggregate/g' skills/ship/SKILL.md > t && mv t skills/ship/SKILL.md"
fullcase "regression gate accepts-all"      FAIL 'control'        bash -c "sed -e 's/if rate < prate:/if False:/' skills/eval-run/references/regression-gate.py > t && mv t skills/eval-run/references/regression-gate.py"
fullcase "regression gate rejects-all"      FAIL 'control'        bash -c "sed -e 's/if rate < prate:/if True:/' skills/eval-run/references/regression-gate.py > t && mv t skills/eval-run/references/regression-gate.py"
# 4.51 partial-crash blindness. Neutering the coverage check must be caught:
# the rate check still passes it, because 1-of-1 surviving reads as 100%.
fullcase "regression gate coverage-blind"   FAIL 'control'        bash -c "sed -e 's/if n < pn:/if False:/' skills/eval-run/references/regression-gate.py > t && mv t skills/eval-run/references/regression-gate.py"
# 4.53 exit-code merge. Reverting the runner to a two-valued code makes
# "could not complete" and "completed with errored cases" both exit 1 —
# the collision measured before the fix, and the one /ship's gate 3 reads.
fullcase "eval-run exit codes merged"       FAIL 'control'        bash -c "sed -e 's/return 2 if errors else 0/return 1 if errors else 0/' fixtures/eval-run/eval/run.py > t && mv t fixtures/eval-run/eval/run.py"
# 4.55b a marked count in a file on neither roster is a claim nobody checks.
# The planted VALUE is correct; only its location is wrong, so this case
# fails for coverage and not for staleness.
fullcase "marked count off the roster"      FAIL 'count' bash -c "printf 'skills: <!-- count:skills -->23<!-- /count -->\n' > docs/off-roster.md"
# 4.55c a dead .py citation. Identical to the .md case one line of regex
# away, and invisible for as long as the extension list was named.
fullcase "dead .py reference citation"      FAIL 'crossref' bash -c "printf '\nSee references/no-such-gate.py for details.\n' >> skills/ship/SKILL.md"
# 4.60 the negative twin. A tell leaking into the legitimate fixture means
# the detector now reports taste as a defect — the failure direction that
# ai_check alone could never see, since it only ever asserts a hit.
fullcase "tell fires on legitimate use"     FAIL 'control' bash -c "printf '// <a>Get started →</a>\n' >> fixtures/design-audit/legitimate-look.tsx"
# 4.61 conditional-branch waste. Inlining a split target's body back into
# SKILL.md is the regression: the skill still works, it just costs every
# invocation the branches it will not read.
fullcase "conditional waste over budget"    FAIL 'ratio' bash -c "for i in 1 2 3 4 5 6 7 8 9 10; do printf '\n## Target: bloat%s\n\n' \"\$i\" >> skills/audit/SKILL.md; for j in 1 2 3 4 5 6 7 8 9 10; do printf 'padding line %s\n' \"\$j\" >> skills/audit/SKILL.md; done; done"
# 4.68 unsupplied-section rule, one home. Three ways this rots, and the
# first is the defect as it actually shipped: the template grew its own
# half of the rule, the halves disagreed, and shakedown 15 watched a live
# run follow the template over the procedure.
fullcase "template restates the seed rule"  FAIL 'seed-rule' bash -c "printf '\n- If the user cannot fill Domain landmines, record \"none known yet\".\n' >> skills/plan/references/brief-template.md"
fullcase "canonical site drops a state"     FAIL 'seed-rule' bash -c "sed -e 's/none known yet/nothing recorded/g' skills/plan/references/mode-seed.md > t && mv t skills/plan/references/mode-seed.md"
fullcase "template stops pointing"          FAIL 'seed-rule' bash -c "sed -e 's/mode-seed\.md/the seed procedure/g' skills/plan/references/brief-template.md > t && mv t skills/plan/references/brief-template.md"
# 4.67 never-guess stays unconditional. Three ways this rots, and the first
# is how it shipped: the rule nested inside the unsupplied-sections branch,
# so a run that decided the branch did not apply took the rule with it.
# Position is the contract, so re-nesting is the regression to catch.
fullcase "never-guess re-nested in branch"  FAIL 'never-guess' bash -c "python3 - <<'EOF'
p='skills/plan/references/mode-seed.md'; t=open(p,encoding='utf-8').read()
i=t.index('**Before anything else: never guess.**'); j=t.index('Interview the user')
b=t[i:j]; t=t[:i]+t[j:]
open(p,'w',encoding='utf-8').write(t.replace('A BRIEF with honest gaps', b+'A BRIEF with honest gaps',1))
EOF"
fullcase "every-path clause dropped"        FAIL 'never-guess' bash -c "sed -e 's/every path through this mode/REDACTED/' skills/plan/references/mode-seed.md > t && mv t skills/plan/references/mode-seed.md"
fullcase "deriving carve-out dropped"       FAIL 'never-guess' bash -c "sed -e 's/Deriving is not guessing/REDACTED/' skills/plan/references/mode-seed.md > t && mv t skills/plan/references/mode-seed.md"
# 4.72 config resolver. Two ways this rots, and the first is how it shipped:
# the leading `- ` becomes mandatory again, so a bare `key: value` resolves to
# the DEFAULT; or the warning is silenced, restoring the silent-fallback that
# made an unreadable config indistinguishable from no config at all.
fullcase "config resolver needs the dash again" FAIL 'control' bash -c "sed -e 's|s/\\^\\[\\[:space:\\]\\]\\*-\\\\{0,1\\\\}\\[\\[:space:\\]\\]\\*|s/^-[[:space:]]*|' bin/acstack-config > t && mv t bin/acstack-config && chmod +x bin/acstack-config"
# 4.70 /design set claims. Two directions: the derive-don't-assert rule goes,
# and item 7 loses the design-choice-vs-false-claim distinction (which would
# turn an honesty fix into a ban on animating anything else).
fullcase "design set-claim rule dropped"     FAIL 'control' bash -c "sed -e 's/names a SET is derived from the artifact/asserts what it did/' skills/design/SKILL.md > t && mv t skills/design/SKILL.md"
fullcase "design item7 loses the distinction" FAIL 'control' bash -c "sed -e 's/has not broken this/violates this/' skills/design/SKILL.md > t && mv t skills/design/SKILL.md"
# 4.71 fabricated-domain grep. Two directions: narrowed back to the shipped
# sample (misses reserved TLDs), and widened past its boundary guard (flags
# sub.test.com, which is a plausible real domain).
fullcase "fabricated-domain grep re-narrowed" FAIL 'control' bash -c "python3 - <<'EOF'
p='skills/design-audit/references/ai-tells.md'; t=open(p).read()
open(p,'w').write(t.replace('@example\\\\.(com|net|org)','@example\\\\.(com|org)'))
EOF"
fullcase "fabricated-domain loses its boundary" FAIL 'control' bash -c "python3 - <<'EOF'
p='skills/design-audit/references/ai-tells.md'; t=open(p).read()
open(p,'w').write(t.replace('(example|invalid|test|localhost)([^A-Za-z0-9.-]|\$)','(example|invalid|test|localhost)'))
EOF"
# 4.75 next-3 is a cap, not a quota. Tickets mode lacked document mode's
# fewer-than-three clause, so a live run padded to three by listing a
# `blocked` issue under an "unblocked" heading. Both rot directions.
fullcase "next-3 padding prohibition dropped" FAIL 'control' bash -c "sed -e 's/\*\*Never pad the list to three\.\*\*/Keep it short./' skills/resume/SKILL.md > t && mv t skills/resume/SKILL.md"
fullcase "tickets next-3 stops pointing"      FAIL 'control' bash -c "sed -e 's/governs here/applies/' skills/resume/SKILL.md > t && mv t skills/resume/SKILL.md"
# 4.74 issue template: on disk is not in effect. GitHub serves templates from
# the default branch, so the bootstrap's local task.md governs nobody until
# pushed. Both rot directions: the bootstrap stops saying so, and /health goes
# back to `ls` alone (which reported present on a template the API 404s for).
fullcase "bootstrap drops the commit caveat" FAIL 'control' bash -c "sed -e 's/until it is committed and/once written, and/' -e 's/not yet in effect/written/' skills/plan/references/tickets-mode.md > t && mv t skills/plan/references/tickets-mode.md"
fullcase "health template check back to ls" FAIL 'control' bash -c "grep -v 'contents/.github/ISSUE_TEMPLATE/task.md' skills/health/references/health-checks.md > t && mv t skills/health/references/health-checks.md"
# 4.73 bootstrap ownership. The bullet shipped with no owning mode and
# /health's fix line named none either, so a live session guessed `/plan
# seed`. Both directions: the definition loses its mode, and the consumer
# points at the wrong one.
fullcase "bootstrap loses its owning mode" FAIL 'control' bash -c "sed -e 's/One-time bootstrap — performed by \`build\`, never by \`seed\`/One-time bootstrap/' skills/plan/references/tickets-mode.md > t && mv t skills/plan/references/tickets-mode.md"
fullcase "health fix points at plan seed" FAIL 'control' bash -c "sed -e 's|the fix \*\*\`/plan build\`\*\* (idempotent)|the fix \`/plan seed\` (idempotent)|' skills/health/references/health-checks.md > t && mv t skills/health/references/health-checks.md"
fullcase "config unreadable-key warning muted" FAIL 'control' bash -c "sed -e 's|\\[ -n \"\\\$bad\" \\] \&\&|[ -n \"\" ] \&\&|' bin/acstack-config > t && mv t bin/acstack-config && chmod +x bin/acstack-config"

# 4.80: §32 deny-set. Four drift modes plus one that must NOT fire. The last is
# the standing control on a bug this guard shipped with — its first form grepped
# a phrase that wraps in the source, so it reported a missing declaration that
# was present. A re-wrap must stay silent.
fullcase "deny-set: README canonical block gone" FAIL 'deny-set' bash -c "python3 - <<'EOF'
import re
p='README.md'; s=open(p).read()
n=re.sub(r'<!-- acstack:deny-set -->.*?<!-- /acstack:deny-set -->','',s,flags=re.S)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
fullcase "deny-set: /health copy gone"        FAIL 'deny-set' bash -c "python3 - <<'EOF'
import re
p='skills/health/SKILL.md'; s=open(p).read()
n=re.sub(r'<!-- acstack:deny-set -->.*?<!-- /acstack:deny-set -->','',s,flags=re.S)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
fullcase "deny-set: /health entry diverges"   FAIL 'deny-set' bash -c "python3 - <<'EOF'
p='skills/health/SKILL.md'; s=open(p).read()
n=s.replace('Bash(rm -rf:*)','Bash(rm -rf:*)-DRIFT',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
fullcase "deny-set: row claims a verdict"     FAIL 'deny-set' bash -c "python3 - <<'EOF'
p='skills/health/SKILL.md'; s=open(p).read()
n=s.replace('never counts toward the issue total','counts toward the issue total',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
fullcase "deny-set: declaration re-wrapped"   PASS 'deny-set' bash -c "python3 - <<'EOF'
p='skills/health/SKILL.md'; s=open(p).read()
n=s.replace('never counts toward the issue total','never counts\n   toward the issue total',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"

# 4.80: §33 READONLY_SKILLS states its own size. The first case IS the original
# defect — /why was enrolled and both comments kept saying six.
# SEEDS DERIVE THE CURRENT NUMBER (2026-08-17). They hardcoded 7; enrolling
# /contract-check as the eighth made two of the three match nothing, and a
# no-op seed reports got=PASS want=FAIL only if you are lucky enough to notice.
# Same rot as the owed-marker case above: a seed naming a live value expires.
fullcase "readonly-count: another skill enrolled" FAIL 'readonly-count' bash -c "python3 - <<'EOF'
import re, pathlib
p = pathlib.Path('scripts/check.sh'); s = p.read_text()
m = re.search(r'^READONLY_SKILLS=\"([^\"]+)\"', s, re.M)
assert m, 'seed no-op: READONLY_SKILLS not found'
n = s.replace(m.group(0), 'READONLY_SKILLS=\"' + m.group(1) + ' ship\"', 1)
assert n != s, 'seed no-op'
p.write_text(n)
EOF"
fullcase "readonly-count: comment restates old" FAIL 'readonly-count' bash -c "python3 - <<'EOF'
import re, pathlib
p = pathlib.Path('scripts/check.sh'); s = p.read_text()
m = re.search(r'the (\d+) read-only skills actually grant', s)
assert m, 'seed no-op: first stated-size claim not found'
n = s.replace(m.group(0), 'the ' + str(int(m.group(1)) - 1) + ' read-only skills actually grant', 1)
assert n != s, 'seed no-op'
p.write_text(n)
EOF"
fullcase "readonly-count: a claim is dropped"   FAIL 'readonly-count' bash -c "python3 - <<'EOF'
import re, pathlib
p = pathlib.Path('scripts/check.sh'); s = p.read_text()
m = re.search(r'across the (\d+) read-only skills above', s)
assert m, 'seed no-op: second stated-size claim not found'
n = s.replace(m.group(0), 'across the read-only skills above', 1)
assert n != s, 'seed no-op'
p.write_text(n)
EOF"

# 4.80: §34 commit subjects. A NEW CASE SHAPE, and it exists because this file
# strips .git at line 22 — so a git-dependent guard is unreachable through
# fullcase: it hits the shallow-repository fallback and SKIPs, forever. This
# builds a one-commit repo inside the copy, which makes the subject under test
# the only one in the guard's window. A fresh `git init` repo reports
# is-shallow=false, which is what lets §34 run at all here.
gitcase() { # name expected(PASS|FAIL) subject
  local n="$1" exp="$2" subj="$3"
  _case_start "$n" || return 0
  rm -rf "$FULL"; cp -R "$SRC" "$FULL"
  ( cd "$FULL" && git init -q . && git add -A \
    && git -c user.email=m@m -c user.name=m commit -q -m "$subj" ) >/dev/null 2>&1
  # 5.8: fullcase's tree-hash check would be satisfied here by `git init`
  # alone, which proves nothing about the subject under test. The subject IS
  # this case's seed, so it is asserted directly.
  local _got
  _got="$(cd "$FULL" && git log -1 --format=%s 2>/dev/null)"
  if [ "$_got" != "$subj" ]; then
    printf '  BAD  %-42s SEED NO-OP — subject is %s, expected %s\n' "$n" "${_got:-<no commit>}" "$subj"
    failed=$((failed+1)); return 0
  fi
  out="$(cd "$FULL" && ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh 2>&1)"
  if printf '%s' "$out" | grep -qE 'FAIL commit-style'; then got=FAIL; else got=PASS; fi
  if [ "$got" = "$exp" ]; then printf '  ok   %-42s %s\n' "$n" "$got"; pass=$((pass+1))
  else printf '  BAD  %-42s got=%s want=%s\n' "$n" "$got" "$exp"; failed=$((failed+1)); fi
}
gitcase "commit-style: capitalised subject"   FAIL "Fix the thing"
gitcase "commit-style: task without colon"    FAIL "task 4.80 missing its colon"
gitcase "commit-style: capitalised Task"      FAIL "Task 4.80: capitalised"
gitcase "commit-style: Journal without date"  FAIL "Journal without a date"
# The glob these replaced validated only the FIRST character after the
# keyword, so both of these passed §34 (external review, 2026-09-16).
gitcase "commit-style: non-numeric task id"   FAIL "task 1x: malformed"
gitcase "commit-style: journal without a real date" FAIL "Journal 2 garbage"
gitcase "commit-style: dotted task id"        PASS "task 3.2.1: a real subtask"
gitcase "commit-style: two-task subject"      PASS "task 4.68 + 4.67: one commit closes two"
gitcase "commit-style: same-day journal"      PASS "Journal 2026-09-16 (3rd): a second entry that day"
gitcase "commit-style: ordinary verb-first"   PASS "run an ordinary verb-first commit"

# 4.81: §35 near-term tasks state a done-condition. The third case is the one
# the design rests on — the scope is DERIVED (topmost open wave + the next), so
# closing waves must PULL the following ones in. A guard that is permanently
# blind to distant waves would pass forever and check nothing.
# DERIVED (2026-08-31). This named 5.1's acceptance text verbatim; ticking 5.1
# made the seed neuter a CLOSED task's line, which section 35 does not police,
# so the case went got=PASS want=FAIL. It passed locally only because the tree
# was edited mid-run and the matrix scores the snapshot it took at start —
# 4.55a's NOTE exists for exactly that and was not read. Now it finds whichever
# open task carries the first acceptance line and breaks that one.
fullcase "acceptance: in-scope task loses it" FAIL 'acceptance' bash -c "python3 - <<'EOF'
import re, pathlib
p = pathlib.Path('PLAN.md'); lines = p.read_text().split(chr(10))
is_open = False; hit = -1
for i, l in enumerate(lines):
    if re.match(r'^- \\[[ x]\\] \\*\\*[0-9]', l):
        is_open = l.startswith('- [ ]')
    if is_open and '**Acceptance:**' in l:
        hit = i; break
assert hit >= 0, 'seed no-op: no open task carries an acceptance line'
lines[hit] = lines[hit].replace('**Acceptance:**', 'Not an acceptance:', 1)
p.write_text(chr(10).join(lines))
EOF"
fullcase "acceptance: new task has none"      FAIL 'acceptance' bash -c "python3 - <<'EOF'
p='PLAN.md'; s=open(p).read()
a='## [ ] Wave 5 — Gates: pre-flight + verification'
n=s.replace(a,'- [ ] **4.99** A brand-new task with no done-condition at all.\n\n'+a,1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
fullcase "acceptance: scope advances on close" FAIL 'acceptance' bash -c "python3 - <<'EOF'
p='PLAN.md'; s=open(p).read()
n=s.replace('## [ ] Wave 4.5 —','## [x] Wave 4.5 —',1).replace('## [ ] Wave 5 —','## [x] Wave 5 —',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
# DERIVED (2026-09-10, 5.8) — and this one was found by the seed-hash check on
# its first full run, not by reading. It hardcoded `- [ ] **5.2** /contract-check`;
# 5.2 closed 2026-08-17, so the string stopped existing and the seed mutated
# NOTHING from that day on. The case is must-PASS, so it reported `ok` while
# testing an untouched tree — silent, unlike its must-FAIL sibling above.
# NOTE THE SHAPE: this seed was ALREADY python3 and ALREADY carried
# `assert n!=s`. The assertion fired correctly every time and nobody heard it,
# because fullcase discarded the mutation's exit status. Converting seeds to
# python3 — which is what 5.8 was written to do — would not have caught this.
# Only the harness-level check does.
fullcase "acceptance: closed task is exempt"  PASS 'acceptance' bash -c "python3 - <<'EOF'
import re, pathlib
p = pathlib.Path('PLAN.md'); lines = p.read_text().split(chr(10))
task = -1; acc = -1
for i, l in enumerate(lines):
    if re.match(r'^- \\[[ x]\\] \\*\\*[0-9]', l):
        task = i if l.startswith('- [ ]') else -1
        continue
    if task >= 0 and '**Acceptance:**' in l:
        acc = i; break
assert task >= 0 and acc >= 0, 'seed no-op: no open task carries an acceptance line'
lines[task] = lines[task].replace('- [ ]', '- [x]', 1)
lines[acc] = lines[acc].replace('**Acceptance:**', 'Not an acceptance:', 1)
p.write_text(chr(10).join(lines))
EOF"

echo
# 4.82: §5's shell set is DERIVED, not listed. Three rosters used to live in
# check.sh and check.yml and no two agreed, so four scripts were linted by
# nothing. Case 1 is the original defect reproduced — a script added after the
# roster was written. Case 2 is the must-not-fire, and it CANNOT be satisfied
# by the baseline: the fixture it plants does not exist until the seed runs,
# so a guard that swept fixtures/ would fail it. Case 3 guards the derivation
# itself, since an empty list would silently lint nothing and still pass.
# 5.31 acstack-config's key roster. The helper's KEYS list is hardcoded and
# under-counted by four; §43 derives the expected set from README's config
# table instead. Two arms, because a derived guard has two ways to go quiet:
# the roster loses a key, and the ORACLE it derives from disappears.
fullcase "config: KEYS drops a documented key" FAIL 'config-keys' bash -c "python3 - <<'EOF'
import io
p = 'bin/acstack-config'
s = io.open(p, encoding='utf-8').read()
a = ' banned-palette variance'
assert a in s, 'seed no-op: KEYS is not in its fixed form'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, ' variance', 1))
EOF"
fullcase "config: README's key table moves"    FAIL 'config-keys' bash -c "python3 - <<'EOF'
import io
p = 'README.md'
s = io.open(p, encoding='utf-8').read()
a = '| Key | Values (default first) | Consumed by |'
assert a in s, 'seed no-op: the config table header is already absent'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, '| Setting | Values (default first) | Consumed by |', 1))
EOF"

# 5.31 (iii): the tickets commit subject. A decision recorded in one file
# and applied in another is invisible to every check that reads one file.
fullcase "ticket: bare '#42:' subject returns"  FAIL 'ticket-subject' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/tickets-mode.md'
s = io.open(p, encoding='utf-8').read()
# chr(96) is a backtick. A literal one here is COMMAND SUBSTITUTION: the
# seed body sits inside a double-quoted bash -c argument, which the shell
# parses before python ever runs, so the backticked subject was executed
# as a command and the replacement never matched. The tree went unchanged
# and the case tested nothing, while the guard it exists for reported
# clean. Caught by the matrix SEED NO-OP detector, not by reading it.
q = chr(96)
a = q + 'ticket #42: <subject>' + q
assert a in s, 'seed no-op: the corrected shape is not present'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, q + '#42: <subject>' + q, 1))
EOF"
fullcase "ticket: CONDUCT loses the canon form" FAIL 'ticket-subject' bash -c "python3 - <<'EOF'
import io
p = 'CONDUCT.md'
s = io.open(p, encoding='utf-8').read()
a = 'ticket #42: '
assert a in s, 'seed no-op: CONDUCT never stated the canonical form'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, 'ticket #42-'))
EOF"


fullcase "shell: new script enters the lint set" FAIL 'syntax' bash -c "printf '#!/usr/bin/env bash\ncd /tmp\necho hi\n' > scripts/newthing.sh"
fullcase "shell: planted fixture stays excluded" PASS '.*'      bash -c "mkdir -p fixtures/shell-scope && printf '#!/usr/bin/env bash\ncd /tmp\necho hi\n' > fixtures/shell-scope/planted.sh"
fullcase "shell: derivation returning nothing"   FAIL 'syntax' bash -c "printf '#!/usr/bin/env bash\ntrue\n' > scripts/shell-sources.sh"

# 5.21: the hackathon lane. Two acceptance-line arms, because the guard's
# awk reports a missing line from three places — the next task line, the
# next heading, and the end of the PLAN block — and a seed that always
# removes the first line proves only the first (the §41 lesson: direction
# coverage and input coverage are different axes). The first arm exercises
# "next task"; the last arm exercises "next heading", since the template's
# task list is followed by a heading. "End of block" is not exercised: the
# template has no task as the last line of its block. chr(96) is a
# backtick: a literal one inside this double-quoted bash -c would be run as
# command substitution by the shell before python ever saw it.
fullcase "hackathon: first task loses acceptance" FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/plan/references/hackathon-template.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
a = '  **Acceptance:** ' + q + '<command>' + q + ' prints ' + q + '<expected>' + q + '.\n'
assert s.count(a) >= 2, 'seed no-op: fewer than two acceptance lines to remove from'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, '', 1))
EOF"
fullcase "hackathon: last task loses acceptance"  FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/plan/references/hackathon-template.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
a = '  **Acceptance:** ' + q + '<command>' + q + ' prints ' + q + '<expected>' + q + '.\n'
i = s.rfind(a)
assert i >= 0, 'seed no-op: no acceptance line to remove'
io.open(p, 'w', encoding='utf-8').write(s[:i] + s[i + len(a):])
EOF"
fullcase "hackathon: merge loses its old value"   FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
a = 'git update-ref refs/heads/main HEAD <base>'
assert a in s, 'seed no-op: the compare-and-swap form is not present'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, 'git update-ref refs/heads/main HEAD', 1))
EOF"

# 5.21, second round: one arm per bypass class a disprove-agent planted
# against the first version of §46, each of which that version passed.
fullcase "hackathon: acceptance left as prose"      FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/plan/references/hackathon-template.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
a = '  **Acceptance:** ' + q + '<command>' + q + ' prints ' + q + '<expected>' + q + '.'
assert a in s, 'seed no-op: no acceptance line to blank'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, '  **Acceptance:** TBD', 1))
EOF"
fullcase "hackathon: task written without bold"     FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/plan/references/hackathon-template.md'
s = io.open(p, encoding='utf-8').read()
a = '\n<Physically reorder subtasks'
assert s.count(a) == 1, 'seed no-op: the build-order note moved'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, '- [ ] 1.9 Extra task (Track A)' + a, 1))
EOF"
fullcase "hackathon: swap in prose loses old value" FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
assert '## Report' in s, 'seed no-op: the Report heading moved'
io.open(p, 'w', encoding='utf-8').write(s.replace('## Report', 'Or run ' + q + 'git update-ref refs/heads/main HEAD' + q + ' to finish.\n\n## Report', 1))
EOF"
fullcase "hackathon: /do stops pointing at lane"    FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/SKILL.md'
s = io.open(p, encoding='utf-8').read()
a = 'references/hackathon-lane.md'
assert a in s, 'seed no-op: /do does not name the lane'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, 'references/fast-lane.md'))
EOF"

# 5.21, third round: the bypasses a sixth disprove-agent planted against
# §46 on 2026-09-24, each of which passed the pattern-based (b). (b) is now
# an allowlist; one arm per planted form, plus a control that the allowed
# prose form still passes (it fails if the allowlist stops accepting a
# closing backtick). chr(36) is a dollar sign, for the same reason as
# chr(96): the shell would expand it before python saw it.
fullcase "hackathon: option before the ref"         FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
assert '## Report' in s, 'seed no-op: the Report heading moved'
io.open(p, 'w', encoding='utf-8').write(s.replace('## Report', 'Or run ' + q + 'git update-ref -m land refs/heads/main HEAD <base>' + q + '.\n\n## Report', 1))
EOF"
fullcase "hackathon: swap wrapped across lines"     FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
assert '## Report' in s, 'seed no-op: the Report heading moved'
io.open(p, 'w', encoding='utf-8').write(s.replace('## Report', 'Or run ' + q + 'git update-ref\nrefs/heads/main HEAD' + q + ' to finish.\n\n## Report', 1))
EOF"
fullcase "hackathon: a name as the old value"       FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
a = 'git update-ref refs/heads/main HEAD <base>\n'
assert a in s, 'seed no-op: the swap line is not present'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, a + 'git update-ref refs/heads/main HEAD main\n', 1))
EOF"
fullcase "hackathon: swap line hidden in comment"   FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
a = 'git update-ref refs/heads/main HEAD <base>\n'
assert a in s, 'seed no-op: the swap line is not present'
r = 'git update-ref refs/heads/main HEAD ' + chr(36) + '(git rev-parse refs/heads/main)\n'
s = s.replace(a, r, 1)
io.open(p, 'w', encoding='utf-8').write(s.replace('## Report', '<!--\n' + a + '-->\n\n## Report', 1))
EOF"
fullcase "hackathon: subtask loses its acceptance"  FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/plan/references/hackathon-template.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
a = '    **Acceptance:** ' + q + '<command for this leaf>' + q + ' prints ' + q + '<expected>' + q + '.\n'
assert a in s, 'seed no-op: no leaf acceptance line to remove'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, '', 1))
EOF"
fullcase "hackathon: task with a plus marker"       FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/plan/references/hackathon-template.md'
s = io.open(p, encoding='utf-8').read()
a = '\n<Physically reorder subtasks'
assert s.count(a) == 1, 'seed no-op: the build-order note moved'
io.open(p, 'w', encoding='utf-8').write(s.replace(a, '+ [ ] **1.9 Extra task (Track A)**' + a, 1))
EOF"
fullcase "hackathon: checkout -B moves main"        FAIL 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
assert '## Report' in s, 'seed no-op: the Report heading moved'
io.open(p, 'w', encoding='utf-8').write(s.replace('## Report', 'Or run ' + q + 'git checkout -B main HEAD' + q + '.\n\n## Report', 1))
EOF"
fullcase "hackathon: swap quoted in prose passes"   PASS 'hackathon' bash -c "python3 - <<'EOF'
import io
p = 'skills/do/references/hackathon-lane.md'
s = io.open(p, encoding='utf-8').read()
q = chr(96)
assert '## Report' in s, 'seed no-op: the Report heading moved'
io.open(p, 'w', encoding='utf-8').write(s.replace('## Report', 'The swap is ' + q + 'git update-ref refs/heads/main HEAD <base>' + q + '.\n\n## Report', 1))
EOF"

echo
# --list produced names, not results; say so and stop before any summary
# that would read as a run. RAN here means "cases named".
if [ "$LIST" -eq 1 ]; then
  echo "LISTED=$RAN${SHARD_N:+ SHARD=$SHARD_I/$SHARD_N} — names only, no case executed"
  exit 0
fi

# 4.55a: name a mid-run tree change. Not a failure — every case above read
# the SAME frozen snapshot, so the results stand; this tells the operator
# the live tree has moved on, which is the fact that used to arrive
# disguised as a phantom case failure.
if [ "$(tree_hash "$REPO")" != "$H0" ]; then
  echo "NOTE: the tree changed during this run. Every case above read the"
  echo "      snapshot taken at start, so these results are internally"
  echo "      consistent — but they describe the tree as it was, not as it is."
fi

# 5.11: the summary can never say "clean" without saying how many ran.
if [ -n "$ONLY" ]; then
  echo "FILTER: /$ONLY/  — a filtered run covers ONLY the named cases;"
  echo "        it is not a substitute for a full run before a push."
fi
if [ "$RAN" -eq 0 ]; then
  echo "MATRIX FILTER MATCHED NOTHING: 0 cases ran."
  echo "  passed=$pass failed=$failed is not a clean run here, it is an empty"
  echo "  one — greener than the real thing and the reason this check exists."
  echo "  Check the regex against the case names in $SELF."
  exit 2
fi
if [ -z "$ONLY" ]; then
  # An unfiltered run must run every declared case. count-check.sh derives
  # matrix-cases from these same invocation lines and has assumed since
  # 2026-08-06 that the static count equals the runtime total, on one
  # hand-check. Asserted here instead of assumed.
  _declared="$(grep -cE '^([a-z]+case|check) ' "$SELF")"
  if [ -z "$SHARD_N" ]; then
    _expect="$_declared"
  else
    # Shard i of N holds ordinals i, i+N, i+2N, ... up to _declared. Each
    # shard asserts its OWN share, so a broken partition fails inside the
    # shard rather than waiting for fan-in — the aggregating step still
    # exists, because only it can notice a shard that never ran at all.
    if [ "$SHARD_I" -gt "$_declared" ]; then _expect=0
    else _expect=$(( (_declared - SHARD_I) / SHARD_N + 1 )); fi
  fi
  if [ "$RAN" -ne "$_expect" ]; then
    echo "MATRIX INCOMPLETE: expected $_expect of $_declared declared case(s)${SHARD_N:+ for shard $SHARD_I/$SHARD_N} but RAN=$RAN."
    echo "  An unfiltered run must execute every case it is responsible for;"
    echo "  a case that silently did not run is coverage the summary would"
    echo "  otherwise claim."
    echo "RAN=$RAN passed=$pass failed=$failed"
    exit 2
  fi
fi
echo "RAN=$RAN passed=$pass failed=$failed${SHARD_N:+ SHARD=$SHARD_I/$SHARD_N DECLARED=$(grep -cE '^([a-z]+case|check) ' "$SELF")}"
[ "$failed" -eq 0 ]
