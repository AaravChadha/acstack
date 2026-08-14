#!/usr/bin/env bash
# Test matrix for check.sh's frontmatter guard, written BEFORE the fix.
# Each case: name | expected (PASS/FAIL) | frontmatter body
# Run: bash guard-matrix.sh /path/to/repo
set -uo pipefail
REPO="${1:?usage: guard-matrix.sh <repo>}"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

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
cp -R "$REPO" "$SRC" 2>/dev/null
rm -rf "$SRC/.git" "$SRC/.acstack-banned"

# The run still records what the live tree looked like at start, so a
# mid-run edit is NAMED rather than silently ignored. It is a NOTE, not a
# failure: the results are valid for the snapshot they were taken from, and
# aborting a ~15-minute run over an unrelated edit is the cure being worse
# than the disease.
tree_hash() { find "$1" -name .git -prune -o -type f -exec shasum {} + 2>/dev/null | sort | shasum | awk '{print $1}'; }
H0="$(tree_hash "$REPO")"

cp -R "$SRC" "$WORK/pack" 2>/dev/null
cd "$WORK/pack" || exit 1
rm -rf skills/*/ 2>/dev/null
# keep one known-good skill so principles/budget checks have something valid
mkdir -p skills/good
pass=0; failed=0

check() { # name expected body
  local n="$1" exp="$2" body="$3"
  rm -rf skills/tc; mkdir -p skills/tc
  printf '%s' "$body" > skills/tc/SKILL.md
  out="$(ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh 2>&1)"
  if printf '%s' "$out" | grep -qE 'FAIL (description|frontmatter)'; then got=FAIL; else got=PASS; fi
  if [ "$got" = "$exp" ]; then printf '  ok   %-42s %s\n' "$n" "$got"; pass=$((pass+1))
  else printf '  BAD  %-42s got=%s want=%s\n' "$n" "$got" "$exp"; failed=$((failed+1)); fi
}

echo "=== frontmatter guard matrix ==="
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
check "hazard on 2nd desc line" FAIL $'---\nname: tc\ndescription: fine here.\ndescription: wiring Fixes #N here.\n---\n'
check "CRLF line endings"      PASS "$(printf -- '---\r\nname: tc\r\ndescription: Does a thing. Use when asked.\r\n---\r\n')"
check "unknown frontmatter key" FAIL $'---\nname: tc\ndescription: Does a thing. Use when asked.\nbanana: yes\n---\n'

echo
echo "=== full-tree seeded-defect matrix ==="
# Cases here copy the REAL tree (minus .git), seed exactly one defect via a
# mutation command, and expect check.sh to emit "FAIL <class>". This tests
# each guard against the tree shape it actually polices; the section above
# tests frontmatter parsing in isolation.
FULL="$WORK/full"

fullcase() { # name expected(PASS|FAIL) class-regex mutation-command...
  local n="$1" exp="$2" cls="$3"; shift 3
  rm -rf "$FULL"; cp -R "$SRC" "$FULL"   # $SRC: frozen at start, no .git/.acstack-banned
  ( cd "$FULL" && "$@" ) >/dev/null 2>&1
  out="$(cd "$FULL" && ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh 2>&1)"
  if printf '%s' "$out" | grep -qE "FAIL ($cls)"; then got=FAIL; else got=PASS; fi
  if [ "$got" = "$exp" ]; then printf '  ok   %-42s %s\n' "$n" "$got"; pass=$((pass+1))
  else printf '  BAD  %-42s got=%s want=%s\n' "$n" "$got" "$exp"; failed=$((failed+1)); fi
}

# bespoke: run check.sh on a clean full copy with a crafted banned list; assert
# on the OUTPUT TEXT (these cases are about the sweep's own error handling).
bannedcase() { # name listfile-content required-regex [second-required-regex]
  local n="$1" content="$2" want="$3" want2="${4:-}"
  rm -rf "$FULL"; cp -R "$SRC" "$FULL"   # $SRC: frozen at start, no .git/.acstack-banned
  printf '%s\n' "$content" > "$WORK/blist"
  out="$(cd "$FULL" && ACSTACK_BANNED_FILE="$WORK/blist" bash scripts/check.sh 2>&1)" || true
  if printf '%s' "$out" | grep -qE "$want" && { [ -z "$want2" ] || printf '%s' "$out" | grep -qE "$want2"; }; then
    printf '  ok   %-42s matched\n' "$n"; pass=$((pass+1))
  else printf '  BAD  %-42s output lacked /%s/%s\n' "$n" "$want" "${want2:+ or /$want2/}"; failed=$((failed+1)); fi
}

# clean copy of the real tree must not fail ANY class
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
fullcase "marked count goes stale"        FAIL 'count' bash -c "sed -e 's/<!-- count:skills -->23<!-- \\/count -->/<!-- count:skills -->99<!-- \\/count -->/' JOURNAL.md > t && mv t JOURNAL.md"
fullcase "count-check implementation gone" FAIL 'count' bash -c "rm -f scripts/count-check.sh"
fullcase "marker renamed to unknown count" FAIL 'count' bash -c "sed -e 's/count:skills/count:skillz/g' JOURNAL.md > t && mv t JOURNAL.md"
fullcase "comparison neutered to accept-all" FAIL 'control' bash -c "sed -e 's/if \[ \"\$val\" != \"\$want\" \]; then/if false; then/' scripts/count-check.sh > t && mv t scripts/count-check.sh"
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
fullcase "owed-marker carrier gets closed"  FAIL 'reach'   bash -c "sed -e 's/^- \[ \] \*\*4\.50\*\*/- [x] **4.50**/' PLAN.md > t && mv t PLAN.md"
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
fullcase "readonly-count: eighth skill enrolled" FAIL 'readonly-count' bash -c "python3 - <<'EOF'
p='scripts/check.sh'; s=open(p).read()
n=s.replace('resume migrate-check why','resume migrate-check why ship',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
fullcase "readonly-count: comment restates old" FAIL 'readonly-count' bash -c "python3 - <<'EOF'
p='scripts/check.sh'; s=open(p).read()
n=s.replace('the 7 read-only skills actually grant','the 6 read-only skills actually grant',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"
fullcase "readonly-count: a claim is dropped"   FAIL 'readonly-count' bash -c "python3 - <<'EOF'
p='scripts/check.sh'; s=open(p).read()
n=s.replace('across the 7 read-only skills above','across the read-only skills above',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
EOF"

# 4.80: §34 commit subjects. A NEW CASE SHAPE, and it exists because this file
# strips .git at line 22 — so a git-dependent guard is unreachable through
# fullcase: it hits the shallow-repository fallback and SKIPs, forever. This
# builds a one-commit repo inside the copy, which makes the subject under test
# the only one in the guard's window. A fresh `git init` repo reports
# is-shallow=false, which is what lets §34 run at all here.
gitcase() { # name expected(PASS|FAIL) subject
  local n="$1" exp="$2" subj="$3"
  rm -rf "$FULL"; cp -R "$SRC" "$FULL"
  ( cd "$FULL" && git init -q . && git add -A \
    && git -c user.email=m@m -c user.name=m commit -q -m "$subj" ) >/dev/null 2>&1
  out="$(cd "$FULL" && ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh 2>&1)"
  if printf '%s' "$out" | grep -qE 'FAIL commit-style'; then got=FAIL; else got=PASS; fi
  if [ "$got" = "$exp" ]; then printf '  ok   %-42s %s\n' "$n" "$got"; pass=$((pass+1))
  else printf '  BAD  %-42s got=%s want=%s\n' "$n" "$got" "$exp"; failed=$((failed+1)); fi
}
gitcase "commit-style: capitalised subject"   FAIL "Fix the thing"
gitcase "commit-style: task without colon"    FAIL "task 4.80 missing its colon"
gitcase "commit-style: capitalised Task"      FAIL "Task 4.80: capitalised"
gitcase "commit-style: Journal without date"  FAIL "Journal without a date"
gitcase "commit-style: ordinary verb-first"   PASS "run an ordinary verb-first commit"

# 4.81: §35 near-term tasks state a done-condition. The third case is the one
# the design rests on — the scope is DERIVED (topmost open wave + the next), so
# closing waves must PULL the following ones in. A guard that is permanently
# blind to distant waves would pass forever and check nothing.
fullcase "acceptance: in-scope task loses it" FAIL 'acceptance' bash -c "python3 - <<'EOF'
p='PLAN.md'; s=open(p).read()
n=s.replace('  **Acceptance:** on a scratch project whose manifest carries four planted','  Not an acceptance: on a scratch project whose manifest carries four planted',1)
assert n!=s, 'seed no-op'
open(p,'w').write(n)
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
fullcase "acceptance: closed task is exempt"  PASS 'acceptance' bash -c "python3 - <<'EOF'
p='PLAN.md'; s=open(p).read()
n=s.replace('- [ ] **5.2** /contract-check','- [x] **5.2** /contract-check',1)
assert n!=s, 'seed no-op (checkbox)'
m=n.replace('  **Acceptance:** against a diff that renames a public export','  Not an acceptance: against a diff that renames a public export',1)
assert m!=n, 'seed no-op (acceptance)'
open(p,'w').write(m)
EOF"

echo
# 4.55a: name a mid-run tree change. Not a failure — every case above read
# the SAME frozen snapshot, so the results stand; this tells the operator
# the live tree has moved on, which is the fact that used to arrive
# disguised as a phantom case failure.
if [ "$(tree_hash "$REPO")" != "$H0" ]; then
  echo "NOTE: the tree changed during this run. Every case above read the"
  echo "      snapshot taken at start, so these results are internally"
  echo "      consistent — but they describe the tree as it was, not as it is."
fi
echo "passed=$pass failed=$failed"
[ "$failed" -eq 0 ]
