#!/usr/bin/env bash
# Conditional-branch ratio per skill (PLAN 4.61).
#
# Why this is a script and not a measurement. 4.49 shortlisted split
# candidates by SIZE, corrected its own criterion mid-task to
# per-section conditionality, and never regenerated the list — so
# `/audit` at 66% conditional was never looked at, while two skills with
# ZERO conditional content were measured and declined. A one-off number
# cannot catch that; a re-runnable one can.
#
# What counts as conditional: a `## Mode:` / `## Target:` /
# `## Tickets mode` / `## Document mode` section. These are
# MUTUALLY EXCLUSIVE by construction — one invocation reads one of them —
# so every line in the others is loaded and discarded.
#
# `wasted` is the honest cost: total conditional lines minus the average
# branch, i.e. what a single invocation pays for branches it will not read.
# A pointer left behind still costs a few lines; that is counted, not
# excused.
#
# THE THRESHOLD IS ON `wasted`, NOT ON PERCENT — learned by running this.
# A correctly-split skill still scores high by percentage, because the
# pointers it is left with ARE conditional content: /audit came out of its
# split at 31% while its real cost had dropped 81 lines -> 18. Percent is
# scale-dependent; wasted lines are the thing an invocation actually pays.
#
# Default 40 lines (~450 tokens/invocation), derived: splitting a skill with
# B branches leaves ~5 pointer lines each, so the post-split floor is
# ~5*(B-1) — 15 lines at B=4. Below ~40 wasted, the net saving after paying
# that overhead is under ~25 lines, which does not earn a new file and a new
# indirection.
#
# Usage: scripts/conditional-ratio.sh [threshold-wasted-lines]   (default 40)
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

THRESHOLD="${1:-40}"

printf '%-16s %6s %12s %6s %9s  %s\n' skill body conditional pct wasted status
printf '%-16s %6s %12s %6s %9s  %s\n' ---------------- ------ ------------ ------ --------- ------

over=0
for f in skills/*/SKILL.md; do
  name="$(basename "$(dirname "$f")")"
  read -r body cond branches <<EOF
$(awk '
  BEGIN{ fm=0; body=0; cond=0; branches=0; incond=0 }
  /^---[[:space:]]*$/{ fm++; next }
  fm<2 { next }                      # skip frontmatter
  /^## /{
    incond = ($0 ~ /^## (Mode:|Target:|Tickets mode|Document mode)/) ? 1 : 0
    if (incond) branches++
  }
  { body++; if (incond) cond++ }
  END{ printf "%d %d %d", body, cond, branches }
' "$f")
EOF
  pct=0; wasted=0
  [ "$body" -gt 0 ] && pct=$(( cond * 100 / body ))
  [ "$branches" -gt 0 ] && wasted=$(( cond - cond / branches ))
  status="-"
  if [ "$wasted" -ge "$THRESHOLD" ]; then status="OVER (>=${THRESHOLD} wasted)"; over=$((over+1)); fi
  printf '%-16s %6s %12s %5s%% %9s  %s\n' "$name" "$body" "$cond" "$pct" "$wasted" "$status"
done | sort -k5 -r -n

echo
echo "Threshold: ${THRESHOLD} wasted lines. At or above it, a skill must be split"
echo "or carry a written reason in PLAN.md. Ranked by WASTED, not by size and not"
echo "by percent: sorting by size is the mistake 4.61 exists to correct, and"
echo "sorting by percent flags skills that were already split correctly."
