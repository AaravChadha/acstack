# Changelog

Versions map to waves (0.x pre-launch; 1.0.0 is the public flip, gated
on PLAN 4.7). The first versioned heading below must equal `VERSION` —
`scripts/check.sh` enforces the agreement. Entries are distilled from
JOURNAL.md, which remains the full record.

## 0.4.0 — unreleased

- Wave 4, distribution + launch, in progress: versioning, guard
  coverage, positive controls, runtime preamble + `bin/`, CI,
  `allowed-tools`, referral block, multi-product detection, /eval-run,
  docs v2, launch checklist. Roadmap: PLAN.md.

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
