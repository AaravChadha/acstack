#!/usr/bin/env bash
# Derive-and-compare for MARKED count claims (PLAN 4.48).
#
# Why this exists at all: a count duplicated outside its single enumeration
# goes stale. This repo produced six instances in three days (JOURNAL's
# "Twenty skills" vs 23, its 21/23 table row, its "35 open tasks" vs 21,
# PLAN's risk note saying "3 remain" then "Those four", ARCHITECTURE's
# enumeration, and PRINCIPLES' "fifteen numbered sections" — the last
# inside the principle *about* replacing prose with checks). /audit docs
# has carried "stale counts vs greppable reality" since it shipped and
# never once ran, because nobody types it without already suspecting
# drift. This does the mechanical half from check.sh, which runs before
# every commit.
#
# Usage: scripts/count-check.sh FILE...
#
# A claim is marked as:  <!-- count:skills -->23<!-- /count -->
#
# HONEST SCOPE. Only MARKED claims are checked. An unmarked count in prose
# is invisible here, so a clean run means "every marked count agrees with
# its derivation" and NEVER "this document has no stale numbers". A regex
# sweep for count-like prose would be a denylist and cannot be finished
# (the section 13 ruling, 2026-08-02); it is deliberately not attempted.
# An unknown count NAME is a failure, not a skip — a typo'd marker that
# silently verified nothing is the same false-pass class the guard exists
# to prevent.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

fail=0
verified=""

# --- THE COVERAGE CONTRACT (4.55b) ---------------------------------------
# Until 2026-08-08 the covered set was check.sh's argument list and NOTHING
# SAID SO. A marked count in a file nobody passed was silently unverified,
# and the argument list could be edited with no signal. The roster below is
# now the contract, stated where the guard is read, with a reason per
# inclusion AND per exclusion — an exclusion with no reason is how a list
# rots into a denylist.
#
# Run with NO ARGUMENTS to check the contracted set and scan for strays;
# run with FILE... to check exactly those files (what controls.sh does when
# it points the guard at one seeded fixture).
#
# COVERED — documents that make marked count claims to a reader:
#   README.md            the front door; its numbers are the first ones read
#   PLAN.md              the roadmap; every wave/task count derives from it
#   JOURNAL.md           the status snapshot; carried a stale 25/90 once
#   CONTRIBUTING.md      tells contributors how many checks they must pass
#   PRINCIPLES.md        enumerates its own sections
#   docs/ARCHITECTURE.md enumerates guards and components
COVERED="README.md PLAN.md JOURNAL.md CONTRIBUTING.md PRINCIPLES.md docs/ARCHITECTURE.md"
#
# EXEMPT — files that contain the marker SYNTAX but make no claim. Each is
# listed with why, so adding one is a decision rather than a silent drop:
#   scripts/count-check.sh    documents the marker format in its own header
#   docs/guard-matrix.sh      seeds marker strings inside sed mutations
#   fixtures/count-drift/*    seeded fixtures; being stale IS their job
EXEMPT="scripts/count-check.sh docs/guard-matrix.sh fixtures/count-drift/stale-doc.md fixtures/count-drift/typo-name.md"
#
# HONEST SCOPE OF THE STRAY SCAN. It finds files carrying a MARKER that are
# on neither list. A new file making count claims in unmarked prose is still
# invisible — sweeping prose is the unfinishable denylist ruled out above,
# and `.github/workflows/check.yml`'s "15 checks" was exactly that shape.
# The roster's reasons are where an author learns to mark a claim instead.
contract=0
if [ "$#" -eq 0 ]; then contract=1; set -- $COVERED; fi

w45() { awk '/^## \[[ x]\] Wave 4\.5/,/^## \[[ x]\] Wave 5/' PLAN.md; }

# The enumerated set of derivable counts. Adding a marker with a name not
# listed here fails loudly rather than passing silently.
derive() {
  local n
  case "$1" in
    skills)         n=$(ls -1 skills 2>/dev/null | wc -l) ;;
    checks)         n=$(grep -cE '^# [0-9]+[a-z]?\. ' scripts/check.sh) ;;
    # Static count of case invocations. Verified 2026-08-06 to equal the
    # runtime `passed=` total (94); running the matrix here would cost
    # minutes on every commit, which is why this counts the source instead.
    # SHAPE-AGNOSTIC on purpose (4.80). This named the three shapes that
    # existed until 2026-08-14, when a fourth (`gitcase`) was added and the
    # derivation silently under-counted by 5 — reporting a smaller matrix than
    # the one that runs, which is the direction that hides work rather than
    # inventing it. `<name>case ` with a trailing space matches an invocation
    # and not the `<name>case() {` definition.
    matrix-cases)   n=$(grep -cE '^([a-z]+case|check) ' docs/guard-matrix.sh) ;;
    wave45-done)    n=$(w45 | grep -c '^- \[x\]') ;;
    wave45-open)    n=$(w45 | grep -c '^- \[ \]') ;;
    wave45-total)   n=$(w45 | grep -cE '^- \[[ x]\]') ;;
    open-scheduled) n=$(awk '/^## \[[ x]\] Wave 4\.5/,/^## \[[ x]\] Wave B/' PLAN.md \
                        | grep -c '^- \[ \]') ;;
    *)              return 1 ;;
  esac
  printf '%s' "$n" | tr -d '[:space:]'
}

for f in "$@"; do
  if [ ! -f "$f" ]; then
    echo "FAIL count: $f does not exist — a marked-count file was moved or deleted"
    fail=1; continue
  fi
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    ln="${hit%%:*}"
    rest="${hit#*:}"
    name="${rest#*count:}"; name="${name%% *}"
    val="${rest#*-->}";     val="${val%%<*}"
    if ! want="$(derive "$name")"; then
      echo "FAIL count: $f:$ln marks unknown count '$name' — no derivation exists, so this claim was never checked"
      fail=1; continue
    fi
    if [ "$val" != "$want" ]; then
      echo "FAIL count: $f:$ln  doc says $val / reality is $want  (count:$name)"
      fail=1
    else
      verified="$verified $name"
    fi
  done < <(grep -noE '<!-- count:[a-z0-9-]+ -->[0-9]+<!-- /count -->' "$f" || true)
done

# Stray scan: a marked count living outside the roster is a claim nobody
# checks. This is what makes the argument list self-enforcing rather than
# a convention — the defect it exists to catch is a NEW covered-looking
# file, added with a marker, that nobody remembered to pass.
if [ "$contract" -eq 1 ]; then
  known=" $COVERED $EXEMPT "
  while IFS= read -r m; do
    [ -n "$m" ] || continue
    case "$known" in *" $m "*) continue ;; esac
    echo "FAIL count: $m carries a marked count but is on neither count-check roster"
    echo "            — add it to COVERED (it makes a claim) or to EXEMPT (with a reason)"
    fail=1
  done < <(grep -rl --exclude-dir=.git --exclude-dir=results '<!-- count:' . 2>/dev/null \
             | sed 's|^\./||' | sort)
fi

if [ "$fail" -eq 0 ]; then
  if [ -n "$verified" ]; then
    names="$(printf '%s' "$verified" | tr ' ' '\n' | grep -v '^$' | sort -u | tr '\n' ' ')"
    echo "count-check: verified ${names%% } — unmarked counts are NOT checked"
  else
    echo "FAIL count: no marked counts found in the files given — the guard verified nothing"
    exit 1
  fi
else
  exit 1
fi
