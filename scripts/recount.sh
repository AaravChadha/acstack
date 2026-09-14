#!/usr/bin/env bash
# recount.sh — re-derive every marked count and rewrite the ones that drifted.
#
# Usage: scripts/recount.sh [--dry-run]
#
# WHY THIS EXISTS (5.17.2). Every task closure moves `count:open-scheduled`,
# so two sessions closing tasks concurrently both hand-edit the same marker to
# the same value. Git sees identical edits, auto-merges them without conflict,
# and the marker sits one too high. AGENTS.md rule 7 already tells the
# integrator to re-derive after every merge — but a control that depends on
# someone remembering is not a control, so this makes it mechanical.
#
# SINGLE SOURCE OF TRUTH, BY CONSTRUCTION. This script contains NO derivation
# of its own. It runs `count-check.sh` and repairs what that reports, so the
# two can never disagree about what a count should be. Duplicating `derive()`
# here would create exactly the drift this script exists to remove — and the
# copy would be the one nobody runs in CI.
#
# HONEST SCOPE — three things it deliberately does NOT do:
#   1. NON-DERIVABLE counts. Every count here has ground truth in the tree
#      (count the dirs, count the boxes). An accumulator like /learn's
#      seen-count has none — you cannot re-derive how many times a lesson was
#      seen — so it is NOT repairable here and needs a derivable shape first
#      (store the occurrences, derive the count). See 5.17.2.
#   2. UNMARKED prose. Same limit count-check has: marked claims only.
#      "These 7" in running text stays invisible to both. (The marker syntax
#      is deliberately not spelled out anywhere in this file: count-check's
#      stray scan reads any file containing it as making a claim, and flagged
#      this script when an earlier draft quoted it in a comment.)
#   3. Failures that are not drift. An unknown count name, a missing roster
#      file or a stray marker are reported and exit 1 — rewriting cannot fix
#      a claim nobody can derive, and pretending otherwise is worse than
#      failing.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

DRY=0
case "${1:-}" in
  --dry-run) DRY=1 ;;
  "") ;;
  *) echo "usage: scripts/recount.sh [--dry-run]" >&2; exit 2 ;;
esac

out="$(bash scripts/count-check.sh 2>&1)"
rc=$?

if [ "$rc" -eq 0 ]; then
  echo "recount: nothing to do — every marked count already matches its derivation"
  exit 0
fi

# Drift lines look exactly like:
#   FAIL count: PLAN.md:4196  doc says 25 / reality is 26  (count:open-scheduled)
drift="$(printf '%s\n' "$out" | grep -E '^FAIL count: .*doc says [0-9]+ / reality is [0-9]+' || true)"
other="$(printf '%s\n' "$out" | grep -E '^FAIL count: ' | grep -vE 'doc says [0-9]+ / reality is [0-9]+' || true)"

if [ -z "$drift" ]; then
  echo "recount: count-check failed, but nothing it reported is repairable drift:" >&2
  printf '%s\n' "$out" >&2
  exit 1
fi

fixed=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  file="$(printf '%s' "$line" | sed -E 's/^FAIL count: ([^:]+):[0-9]+.*/\1/')"
  ln="$(printf '%s' "$line"   | sed -E 's/^FAIL count: [^:]+:([0-9]+).*/\1/')"
  want="$(printf '%s' "$line" | sed -E 's/.*reality is ([0-9]+).*/\1/')"
  name="$(printf '%s' "$line" | sed -E 's/.*\(count:([a-z0-9-]+)\).*/\1/')"

  if [ "$DRY" -eq 1 ]; then
    printf '  would fix %s:%s  count:%s -> %s\n' "$file" "$ln" "$name" "$want"
    fixed=$((fixed+1))
    continue
  fi

  # Rewrite by (line, name) so a line carrying two markers repairs only the
  # drifted one. Python, not sed -i: portable, and it fails loudly rather
  # than silently matching nothing.
  python3 - "$file" "$ln" "$name" "$want" <<'PY' || exit 1
import re, sys
path, ln, name, want = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
lines = open(path, encoding="utf-8").read().split("\n")
i = ln - 1
pat = re.compile(r'(<!-- count:%s -->)(\d+)(<!-- /count -->)' % re.escape(name))
new, n = pat.subn(lambda m: m.group(1) + want + m.group(3), lines[i])
if n != 1:
    sys.exit("recount: %s:%d expected exactly 1 'count:%s' marker, found %d" % (path, ln, name, n))
lines[i] = new
open(path, "w", encoding="utf-8").write("\n".join(lines))
PY
  printf '  fixed %s:%s  count:%s -> %s\n' "$file" "$ln" "$name" "$want"
  fixed=$((fixed+1))
done <<EOF
$drift
EOF

if [ -n "$other" ]; then
  echo "recount: $fixed drifted marker(s) handled, but count-check also reported" >&2
  echo "         problems that rewriting cannot fix:" >&2
  printf '%s\n' "$other" >&2
  exit 1
fi

if [ "$DRY" -eq 1 ]; then
  echo "recount: $fixed marker(s) would be rewritten. Nothing was changed."
  exit 0
fi

# VERIFY, never assume. A parse that silently matched nothing would otherwise
# look identical to a successful repair.
if bash scripts/count-check.sh >/dev/null 2>&1; then
  echo "recount: $fixed marker(s) rewritten; count-check now clean"
  exit 0
fi
echo "recount: rewrote $fixed marker(s) but count-check is STILL failing:" >&2
bash scripts/count-check.sh >&2
exit 1
