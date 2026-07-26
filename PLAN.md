# PLAN.md — acstack

> **Purpose of this document.** The operative roadmap for the pack itself:
> what ships in each wave and how we know a wave is done. Wave 1 is built;
> detailed per-skill specs for later waves get written at wave start, at the
> same fidelity as wave 1's. The founding design discussion (skill roster
> rationale, infra tradeoffs, telemetry stance) predates this file and is
> summarized in README.md and CONDUCT.md.
>
> **Cross-cutting constraints (apply to every wave):**
> - Plain markdown skills; zero runtime dependencies beyond git + POSIX shell.
> - All pack memory is repo-owned; machine-local state is limited to a usage
>   log and an update-check stamp (wave 4).
> - No client/company/collaborator names in pack content (guard-enforced).
> - `scripts/check.sh` clean before every commit.
> - Public launch only after the wave-4 checklist passes.

## Index of waves

| Wave | Goal | Exit criterion |
|---|---|---|
| [x] 1 — Core + foundation | The five core skills installable and honest | `./setup` round-trips; `scripts/check.sh` clean; skills load in a fresh session |
| [x] 2 — Gate, eval, tickets | Planning gets teeth; tickets mode lands | All wave-2 skills load; tickets mode drives a real GitHub repo end-to-end |
| [ ] 3 — Ship + reflect | Full sprint coverage | /qa (http), /secure, /ship, /retro, /learn, /design-audit, /doctor load and pass their shakedowns |
| [ ] 4 — Distribution + launch | A stranger can install, trust, and update it | Fresh-machine install test passes; launch checklist all green |

---

## [x] Wave 1 — Core + foundation

**Goal:** The discipline's five core skills — plan, do, journal, audit,
migrate-check — plus installer, config, conduct contract, and guard.

**Exit criterion:** `./setup` links 5 skills idempotently and uninstalls
cleanly; `scripts/check.sh` reports all clean; a fresh session lists all
five skills. **Status (2026-07-27):** all three verified; 13 commits.

## [x] Wave 2 — Gate, eval, and tickets layer

**Goal:** Planning gains its adversarial gate and eval-first spine; tracking
gains tickets mode for teams and tracker-native users.

**Exit criterion:** In a scratch GitHub repo, `/plan seed` + tickets mode
bootstraps labels/milestones/issue-template; `/ticket` files a well-formed
issue; `/do <issue>` lands a `Fixes #N` branch; `/triage` grooms a seeded
messy backlog; `/eval-spec` produces a golden-question spec before any code.

**Specs (2026-07-27):** per-skill designs at wave-1 fidelity in
`docs/wave-2-specs.md`; build starts on approval, in the order given there.

**Status (2026-07-27):** exit criterion passed in scratch repo
`acstack-w2-shakedown` (private, throwaway): bootstrap idempotent with
GitHub's default `bug` label left untouched; /ticket filed a well-formed
issue; /do closed #1 via a `feature/1-…` branch + `Fixes #1` on direct
push; /triage groomed seeded rot (dupe closed with reason, `needs-
acceptance` labeled); /eval-spec landed 25 golden cases before any code
(closed #4); /plan-review caught a real gap (M2 exit ran `eval/run.py`
that no issue created → filed #8, then locked). ~~Residue: /eval-spec's
slash-menu visibility awaits a fresh session — user-only skills never
appear in the model-facing list; re-open with a verdict if it fails to
load.~~ **Verdict (2026-07-27):** closed — fresh session verified manual
invocation works (typed `/plan` engaged seed mode). User-only skills are
absent from the VS Code extension's autocomplete because the extension
lists only a subset of commands (documented; the CLI menu shows all) —
cosmetic, not a load failure.

- [x] **2.1** /challenge — product interrogation of a BRIEF (premise
  attacks, narrower-wedge proposal, constraint reality checks).
- [x] **2.2** /plan-review — engineering lock on PLAN.md: data-flow trace,
  failure modes, test matrix, hidden assumptions.
- [x] **2.3** /eval-spec — the eval is the spec: golden questions with
  category minimums, refusal cases, grader, `acceptable_failure` discipline.
- [x] **2.4** /investigate — no fixes without investigation; hypotheses vs
  evidence; stop after 3 failed fixes; reads known-bug-classes.
- [x] **2.5** /resume — resume-in-5-minutes brief + next 3 unblocked items.
- [x] **2.6** Tickets mode: `tracking: tickets` deltas in /plan and /do;
  label/milestone/issue-template bootstrap; decision log stays in PLAN.md.
- [x] **2.7** /ticket — mode-agnostic capture to issue or PLAN.md task.
- [x] **2.8** /triage — backlog hygiene: stale, dupes, missing acceptance,
  unblocked-but-unassigned, milestone burn.

## [ ] Wave 3 — Ship + reflect layer

**Goal:** Cover the rest of the sprint: test, secure, release, retrospect,
learn, and project hygiene.

**Exit criterion:** Each skill passes a shakedown on a real project; /qa
probe layer proves both modes' seam with http implemented.

- [ ] **3.1** /qa — flows + adversarial inputs; probe layer abstracted
  (http now, browser later).
- [ ] **3.2** /secure — confidence-gated findings with exploit scenarios;
  auth gates, secrets hygiene, injection surface, LLM tool-use trust
  boundaries.
- [ ] **3.3** /ship — branch-level release: tests + eval suite + docs drift
  + attribution sweep + PR in report shape.
- [ ] **3.4** /retro — weekly/phase-end trends: velocity vs plan, eval
  trend, failure-category trends, risk review, local usage stats.
- [ ] **3.5** /learn — capture lesson to LEARNINGS.md; promote recurring
  ones into the pack's known-bug-classes.
- [ ] **3.6** /design-audit — UI convention check: palette, honest data
  labels, slop detection.
- [ ] **3.7** /doctor — project hygiene: docs present/non-drifted, config
  valid, secrets clean, conduct block current.

## [ ] Wave 4 — Distribution + launch

**Goal:** A stranger can install in 30 seconds, audit what they're
trusting in 5 minutes, and never silently run a stale pack.

**Exit criterion:** Fresh-machine install test passes; launch checklist
below fully green; repo flipped public.

- [ ] **4.1** VERSION + CHANGELOG.md; issue template requiring VERSION.
- [ ] **4.2** Slim per-invocation preamble (≤12 lines, hand-maintained,
  budget enforced by check.sh) + `bin/` helpers (config resolve,
  update-check, recall) — POSIX sh only; `runtime: off` degrades cleanly.
- [ ] **4.3** Local-only telemetry (`~/.acstack/usage.jsonl`) + /retro
  usage section + human-approved aggregate share flow.
- [ ] **4.4** `setup --global` (conduct block into `~/.claude/CLAUDE.md`)
  and `--hook` (SessionStart recall).
- [ ] **4.5** CI: GitHub Action running check.sh + shellcheck on every PR.
- [ ] **4.6** PRINCIPLES.md, docs/ARCHITECTURE.md (every preamble line
  documented), CONTRIBUTING.md; README v2 with a see-it-work walkthrough.
- [ ] **4.7** Launch checklist: check.sh clean, fresh-machine test, demo
  transcript, credits line verified, no personal data in history, flip
  public.

## Open items (decide as we go)

- [ ] **Document-mode commit style (NEW 2026-07-27).** Keep
  `completed task 3.2.1 (…)` or switch to terse `3.2.1: <desc>` to match
  the tickets-mode shape. Owner: user.
- [ ] **Browser probe timing (NEW 2026-07-27).** Playwright mode for /qa —
  wave 3 with http, or deferred until first real need. Owner: user.
- [ ] **GitHub remote (NEW 2026-07-27).** Private `AaravChadha/acstack`
  creation awaits explicit user go. Owner: user.
