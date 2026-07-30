#!/usr/bin/env bash
# Test matrix for check.sh's frontmatter guard, written BEFORE the fix.
# Each case: name | expected (PASS/FAIL) | frontmatter body
# Run: bash guard-matrix.sh /path/to/repo
set -uo pipefail
REPO="${1:?usage: guard-matrix.sh <repo>}"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
cp -R "$REPO" "$WORK/pack" 2>/dev/null
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
  rm -rf "$FULL"; cp -R "$REPO" "$FULL"; rm -rf "$FULL/.git"
  rm -f "$FULL/.acstack-banned"   # never carry the private roster into /tmp copies
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
  rm -rf "$FULL"; cp -R "$REPO" "$FULL"; rm -rf "$FULL/.git" "$FULL/.acstack-banned"
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
fullcase "headingless changelog fails, not dies" FAIL 'version' bash -c "printf '# Changelog\nno versioned headings here\n' > CHANGELOG.md"

echo
echo "passed=$pass failed=$failed"
[ "$failed" -eq 0 ]
