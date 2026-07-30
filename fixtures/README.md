# Positive-control fixtures (PLAN 4.15)

Every directory here carries a KNOWN, DELIBERATE instance of what a
check-shaped skill must catch. `scripts/controls.sh` (check.sh section
11) re-runs each skill's documented detection command against these
seeds and fails when a command misses its plant — evidence the checks
WORK, not merely that they run. The motivating case: a planted
`sk-live-…` key that /secure's old regex reported clean.

Consequences of living in the tree, all intended:

- /secure and /health run on this repo WILL hit these seeds — a sweep
  of the pack itself names them and moves on; excluding `fixtures/` is
  the honest scope line for self-runs.
- The banned-name guard sweeps `fixtures/` like everything else; all
  content stays generic.
- /qa's fixture needs a live process, so its control is NOT in
  controls.sh — `fixtures/qa/README.md` documents the shakedown
  procedure. Its stale-server guard was itself broken until 2026-07-31
  (the `pkill` pattern could never match), found by /investigate.


- Controls EXTRACT non-trivial patterns from the reference files at
  run time, so editing a documented command edits what the control
  tests. **Six** trivial checks are restated inline instead, having no
  drift surface worth extracting: the `^!` negation grep, the CLAUDE.md
  pointer comparison, the `.env` presence test, the multi-product
  `find`, the workspace-marker `ls`, and /audit's raw-compare pattern.
  (Counted 2026-07-31 — this said "two" while naming two of six, the
  set rule broken inside the fixture index itself.)

## What each directory plants

The eight fixture directories: `secure/` (planted keys, `!.env`
negation, unauth route, and the surface-4 classes — deserialization,
crypto, TLS, XXE, sinks, SRI, Actions injection), `design-audit/`
(off-palette hex, unlabeled mockData, hedge copy), `health/`
(non-pointer CLAUDE.md, tracked `.env`), `audit/` (Unicode lookalikes
with verified bytes), `migrate-check/` (DROP TABLE, RENAME COLUMN),
`qa/` (live server, auth gap, uncaught crash), `multi-product/` (two
document sets plus a workspace marker), `eval-run/` (a golden set whose
seeded failure must produce 5/6, not 100%).
