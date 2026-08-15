#!/usr/bin/env bash
# Print every shell source in the pack, one per line — the SINGLE derivation
# of "what gets syntax-checked and linted". check.sh §5 and CI's shellcheck
# step both read this; neither carries a roster of its own.
#
# Why derived and not listed (4.82): three hardcoded lists existed here and
# no two agreed — check.sh's `bash -n` loop named 7 files, its shellcheck
# call named 6, and .github/workflows/check.yml named the same 6. Four
# scripts were linted by nothing at all, and two of those four
# (conditional-ratio.sh, reach-check.sh) had never been named by anyone as
# missing. A roster under-counts silently the day a script is added, which
# is the same defect 4.80 fixed in count-check.sh's case-shape list.
#
# fixtures/ is excluded ON PURPOSE: those files are planted defects for the
# positive-control layer, so linting them clean would defeat what they exist
# to prove. .git/ is excluded as machinery, not source.
#
# Walks the tree with find rather than `git ls-files` DELIBERATELY:
# docs/guard-matrix.sh runs check.sh inside a copy that has no .git at all, so
# a git-dependent derivation would return nothing there and break every case
# in the matrix — the trap §34 fell into and 4.80 had to add `gitcase` for.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

find . -path ./.git -prune -o -path ./fixtures -prune -o -type f -print \
| LC_ALL=C sort \
| while IFS= read -r f; do
  # Shebang must be a shell: /bin/sh, /bin/bash, /usr/bin/env bash, …
  head -n 1 -- "$f" 2>/dev/null | grep -qE '^#!.*/(env[[:space:]]+)?(ba)?sh([[:space:]]|$)' || continue
  printf '%s\n' "${f#./}"
done
