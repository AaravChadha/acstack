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
  ( cd "$FULL" && "$@" ) >/dev/null 2>&1
  out="$(cd "$FULL" && ACSTACK_BANNED_FILE=/dev/null bash scripts/check.sh 2>&1)"
  if printf '%s' "$out" | grep -qE "FAIL ($cls)"; then got=FAIL; else got=PASS; fi
  if [ "$got" = "$exp" ]; then printf '  ok   %-42s %s\n' "$n" "$got"; pass=$((pass+1))
  else printf '  BAD  %-42s got=%s want=%s\n' "$n" "$got" "$exp"; failed=$((failed+1)); fi
}

# clean copy of the real tree must not fail ANY class
fullcase "clean tree stays clean"     PASS '.*' true
# 4.1 version/changelog agreement
fullcase "version mismatch"           FAIL 'version' bash -c 'echo 9.9.9 > VERSION'
fullcase "version malformed"          FAIL 'version' bash -c 'echo banana > VERSION'
fullcase "changelog missing"          FAIL 'version' rm CHANGELOG.md

echo
echo "passed=$pass failed=$failed"
[ "$failed" -eq 0 ]
