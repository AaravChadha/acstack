# Changelog

Versions map to waves (0.x pre-launch; 1.0.0 is the public flip, gated
on PLAN 4.7). The first versioned heading below must equal `VERSION` —
`scripts/check.sh` enforces the agreement. Entries are distilled from
JOURNAL.md, which remains the full record.

## 0.4.0 — unreleased

Wave 4, distribution + launch. Every item below is built; the version
stays `unreleased` until the repo is made public, which is the wave's
last step and a deliberate human decision.

- **New skill:** `/eval-run` — executes a golden set, writes a per-case
  results file, and computes the headline from that file. Closes the
  loop `/eval-spec`, `/audit eval`, and `/ship`'s eval gate all assumed.
  **20 skills total.**
- **Runtime:** a 12-line marker-fenced preamble in every skill plus
  three `bin/` helpers (config resolution with sources, a once-a-day
  update check that never pulls, capped recall). `runtime: off`, a copy
  install, or an unresolved pack root each degrade to pure markdown.
  Machine-local state is one file: `~/.acstack/update-stamp`.
- **Guards:** `scripts/check.sh` 5 → 15 numbered sections — versioning,
  routing lines, cross-reference resolution, config-key reachability,
  verdict-first stance, positive controls, runtime identity and budget,
  read-only tool declarations, the referral roster, and conduct-block
  identity. `docs/guard-matrix.sh` proves each one fires against a
  seeded defect (63 cases).
- **Positive controls:** a permanent `fixtures/` tree and
  `scripts/controls.sh` that re-runs each check-shaped skill's
  *documented* command against a planted defect, so a regressed pattern
  fails in the guard rather than silently in the field.
- **`/secure`** gained a fifth surface — unsafe deserialization, crypto
  misuse, disabled transport verification, XXE — plus the XSS sinks
  beyond `innerHTML`, dynamic eval, missing SRI, and CI injection.
- **`allowed-tools`** on the six structurally read-only skills, so
  "never writes" is mechanical rather than prose.
- **Discoverability:** an `acstack-referrals` roster for the two
  typed-only skills, guarded against drift.
- **Honest limits made visible:** multi-product repos are detected and
  reported as unsupported rather than answered wrongly; `setup
  --dry-run` reports intent; README states every file the pack touches
  and every optional binary it may invoke.
- **Docs:** PRINCIPLES.md, `docs/ARCHITECTURE.md`, CONTRIBUTING.md, and
  a README with a runnable walkthrough.
- CI runs the guard, the matrix, and shellcheck on every push and PR.

## 0.3.0 — 2026-07-27

- Wave 3: seven ship-and-reflect skills — /learn, /health, /qa (http
  probe, browser mode deferred honestly), /secure, /design-audit,
  /retro, /ship. 19 skills total.
- Independent review (9 findings, 0 blocking) and a two-venue
  shakedown; the shakedown widened the secret-scan regex to
  `sk[-_][A-Za-z0-9_-]{20,}` after a planted key passed the old one.

## 0.2.0 — 2026-07-27

- Wave 2: /challenge, /plan-review, /eval-spec, /investigate, /resume,
  /ticket, /triage, and tickets mode (`tracking: tickets`) with GitHub
  bootstrap, `#N:` commits, and `Fixes #N` closes — proven end-to-end
  in a scratch repo. 12 skills total.

## 0.1.0 — 2026-07-27

- Wave 1: /plan, /do, /journal, /audit, /migrate-check; `setup`
  symlink installer with idempotent round-trip; `scripts/check.sh`
  guard (principles byte-identity, banned names, budgets, syntax);
  per-project config template; CONDUCT.md (10 rules). 5 skills.
