# Changelog

Versions map to waves (0.x pre-launch). The repo went public 2026-08-03;
`1.0.0` is reserved for the first *cut* release once the pack stabilizes
post-launch — public availability is not itself a version cut. The first
versioned heading below must equal `VERSION` — `scripts/check.sh` enforces
the agreement. Entries are distilled from JOURNAL.md, the full record.

## 0.4.0 — unreleased

Wave 4, distribution + launch. Every item below is built and the repo went
**public 2026-08-03**. The version stays `unreleased` because no `0.4.0`
has been cut as a tagged release — a deliberate step, deferred while the
pack stabilizes through post-launch shakedowns and wave-4.5 hardening.

### Post-launch hardening (wave 4.5, in progress — 2026-08-03)

Shipped to `main` after the public flip; pull to get it. **If you already
have the pack installed, re-run `./setup` after pulling** — a pull alone
leaves any newly added skill unlinked and invisible, which is exactly how
`/why` shipped and reached nobody until it was caught.

- **New skill:** `/why` — decision archaeology. Answers "why is this like
  this" from BRIEF constraints → dated PLAN verdicts → JOURNAL → git
  history, stops at the first answer that states a *reason*, and says
  `no recorded rationale` rather than inventing one.
- **New skill:** `/design` — production-grade UI rather than a mockup. DTCG
  token system first, wireframe before code, then eight production-readiness
  items every interactive surface must answer (all states including error
  and rollback, real content, responsive, accessibility, interaction feel,
  theming, performance, UX writing). An unanswered item is reported as a
  named gap, never silently skipped. Style is yours via `variance` /
  `motion` / `density` dials; the readiness floor is not negotiable.
  **23 skills total.**
- **`/design-audit` gained `references/ai-tells.md`** — twenty rule classes
  for the signature of generated UI, in a fixed severity order:
  accessibility, then honesty, then everything else. Violet gradients,
  eyebrows, fabricated statistics, motion bounds, materials/translucency
  and interaction-feel misses, each with a seeded plant proving its check
  fires. New `banned-palette` config key.
- **Quieter, sharper reviews.** `/audit` now checks a do-not-flag list
  before writing any finding (pre-existing issues outside the diff,
  correct-but-unusual code, pedantic nitpicks, anything a linter catches,
  explicitly silenced lines); `/audit` and `/qa` both ask whether the target
  needs the pass at all; `/secure` treats a written justification as
  demoting a finding to worth-hardening with the reason quoted, never
  deleting it; `/ship` writes one comment per issue and only offers a code
  suggestion that fully fixes; `/do` states what its evidence does and does
  not establish.
- **`/triage` clusters a backlog by root cause** — the global pass its
  local sweeps cannot do, since twelve items sharing one cause contain no
  duplicate pair. A cluster needs a stated cause and per-member evidence,
  and an independent backlog correctly returns nothing.
- **New skill:** `/refactor` — behavior-preserving cleanup with proof:
  green before, green after, **same test count**. Stops on a dirty tree, a
  red baseline, or a suite too thin to notice a behavior change.
- **New `/audit` target:** `tests` — finds tests that pass without
  catching (assertion-free, tautological, mocks stubbing the unit under
  test, unread snapshots, accumulating skips) plus a mutation spot-check
  that breaks the code deliberately to prove the suite can fail.
- **`/do` climbs a simplicity ladder before writing** — need it at all? →
  already in the codebase? → stdlib? → platform? → installed dependency? →
  one line? → minimal solution. Never at the cost of validation, error
  handling, security, or accessibility.
- **Read-only skills are genuinely narrower.** `git grep` was dropped from
  all four skills that had it (its `-O` flag runs an arbitrary program);
  they use the read-only Grep tool, with plain `grep -rnE` as the stated
  fallback. The `gh auth status` grant was narrowed so `--show-token`
  cannot be appended. Remaining residual is documented in `check.sh` §13.
- **Fewer false alarms:** `/health` and `/secure` now label a repo's own
  seeded test fixtures as `seeded control (fixture)` instead of reporting
  them as defects — labeled and still listed, never hidden. `/health` also
  stops flagging a deliberately external BRIEF when the plan records where
  it lives.
- **Honest declines:** `/migrate-check` opens with "no database in this
  project" when there is genuinely none, instead of reaching that answer
  through a failed stack lookup.
- Guards grew 16 → **24 checks** and the seeded-defect matrix 68 → **89
  cases**, including a new class for PCRE escapes in POSIX-ERE greps —
  `\b`, `\s`, and `\1` each make a check match *nothing* while reporting
  clean, and this pack shipped all three.

- **New skill:** `/eval-run` — executes a golden set, writes a per-case
  results file, and computes the headline from that file. Closes the
  loop `/eval-spec`, `/audit eval`, and `/ship`'s eval gate all assumed.
  **20 skills total.**
- **Runtime:** a 12-line marker-fenced preamble in every skill plus
  three `bin/` helpers (config resolution with sources, a once-a-day
  update check that never pulls, capped recall). `runtime: off`, a copy
  install, or an unresolved pack root each degrade to pure markdown.
  Machine-local state is one file: `~/.acstack/update-stamp`.
- **Guards:** `scripts/check.sh` 5 → 15 numbered sections (16 checks with 3b) — versioning,
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
