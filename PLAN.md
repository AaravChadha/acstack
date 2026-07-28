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
| [x] 3 — Ship + reflect | Full sprint coverage | /qa (http), /secure, /ship, /retro, /learn, /design-audit, /health load and pass their shakedowns |
| [ ] 4 — Distribution + launch | A stranger can install, trust, and update it | Fresh-machine install test passes; launch checklist all green |
| [ ] 5 — Gates: pre-flight + verification | Nothing destructive or unverified lands quietly | Each gate returns a written verdict on a seeded repo; none of them can write |
| [ ] 6 — The review board | Multi-perspective review without personas | Each lens returns a verdict on a seeded project; /board consolidates with dissents preserved |
| [ ] 7 — Operate | Coverage past the merge | Deploy → verify → rollback path proven; incident path exercised once |

> **Roadmap note (2026-07-29):** waves 5–7 were designed after a survey of
> gstack (53 skills, inspected from a clone), obra/superpowers (14),
> GitHub spec-kit (10 commands), and BMAD-METHOD. Every skill below was
> checked against all four; the ones that survived are either absent
> everywhere or an existing acstack shape pointed at a new target. The
> team-of-perspectives goal is met by **lenses, not personas** — each
> reviewer reads a named artifact and returns a verdict; no roleplay, no
> first names. That keeps the "gstack simulates the team; acstack encodes
> the discipline" line intact while still convening a board.

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

## [x] Wave 3 — Ship + reflect layer

**Goal:** Cover the rest of the sprint: test, secure, release, retrospect,
learn, and project hygiene.

**Exit criterion:** Each skill passes a shakedown on a real project; /qa
probe layer proves both modes' seam with http implemented.

**Status (2026-07-27):** all seven built (19 skills total), independently
reviewed (9 findings, 0 blocking, all should-fix/nits addressed), and
shakedown-passed. /qa http probe found the seeded auth gap and a crash on
`limit=abc`; the browser probe declined honestly with the dated deferral
(seam proven — identical report skeleton). /secure ran clean on acstack
and found the seeded key + auth gap on the scratch app. /design-audit
flagged the off-palette color, the unlabeled mock chart, and slop copy.
/ship's five gates ran on a scratch feature branch (fix verified:
`limit=abc → 400`). /learn captured a lesson, bumped `seen` on the
repeat, and its promotion path added a real class to known-bug-classes.
/health and /retro ran on acstack. **Shakedown earned a real fix:** the
secret-scan regex missed prefixed key formats (`sk-proj-…`, `sk_live_…`)
— widened and promoted (commit d709d70).

**Specs (2026-07-27):** per-skill designs at waves-1/2 fidelity in
`docs/wave-3-specs.md`; build starts on approval, in the order given
there.

- [x] **3.1** /qa — flows + adversarial inputs; probe layer abstracted
  (http now, browser later).
- [x] **3.2** /secure — confidence-gated findings with exploit scenarios;
  auth gates, secrets hygiene, injection surface, LLM tool-use trust
  boundaries.
- [x] **3.3** /ship — branch-level release: tests + eval suite + docs drift
  + attribution sweep + PR in report shape.
- [x] **3.4** /retro — weekly/phase-end trends: velocity vs plan, eval
  trend, failure-category trends, risk review. Usage-stats section is NOT
  wave 3 — it arrives with local telemetry in 4.3; the wave-3 skill ships
  without it.
- [x] **3.5** /learn — capture lesson to LEARNINGS.md; promote recurring
  ones into the pack's known-bug-classes.
- [x] **3.6** /design-audit — UI convention check: palette, honest data
  labels, slop detection.
- [x] **3.7** ~~/doctor~~ → **Verdict (2026-07-27):** ships as **/health**
  — avoids shadowing Claude Code's bundled /doctor diagnostic (user skills
  always take precedence over built-ins, no escape syntax), and /health is
  the skill's lineage name anyway. Scope unchanged: project hygiene — docs
  present/non-drifted, config valid, secrets clean, conduct block current.

> **Decision (2026-07-27):** skill-name shadowing. /plan and /resume keep
> their names and deliberately shadow the built-in plan-mode command and
> session-resume command — the shadow is global (`~/.claude/skills`), but
> both built-ins keep alternate entry paths (Shift+Tab for plan mode,
> `claude -r` for session resume). Tradeoff: adopters lose the typed
> forms; mitigated by documenting both shadows in README v2 (4.6).
> Revisit when adopter feedback shows the /resume shadow hurts in
> practice.

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
  documented), CONTRIBUTING.md; README v2 with a see-it-work walkthrough
  and the built-in shadowing disclosure (/plan, /resume — per the
  2026-07-27 decision; also why user-only skills miss the VS Code
  autocomplete).
- [ ] **4.7** Launch checklist: check.sh clean, fresh-machine test, demo
  transcript, credits line verified, no personal data in history, flip
  public.
- [ ] **4.8** `allowed-tools` on the six structurally read-only skills
  (/secure, /health, /design-audit, /audit, /resume, /retro). Their
  never-writes promise is prose today; this makes it mechanical. README
  v2 claims "audit what you're trusting in five minutes" — this is what
  backs that claim. **Acceptance:** each of the six declares a read-only
  tool set; check.sh asserts none of them can Write/Edit.
- [ ] **4.9** Referral block — discoverability for typed-only skills, per
  the 2026-07-29 verdict in Open items. Marker-fenced `acstack-referrals`
  roster in AGENTS.md (skill → one-line definition → suggest-when); a
  clause on CONDUCT rule 9 carrying the behavior (name it once, never
  repeat, silence is not consent); `/plan seed` installs it beside the
  conduct block; `/health` gains a row verifying it is present and
  current. **Acceptance:** check.sh fails when the table's skill set
  differs from the set carrying `disable-model-invocation: true`.
- [ ] **4.10** /audit tests — fourth target on the existing skill
  (*pulled forward from wave 5, 2026-07-29*). Sweeps an existing suite
  for tests that pass without catching: assertion-free and tautological
  tests, mocks stubbing the unit under test, unread snapshots,
  accumulating skips, plus a mutation spot-check — break the production
  code deliberately, confirm something fails. The never-inflate rule
  applied to tests instead of eval scores. Confirmed absent from gstack,
  spec-kit, and BMAD; superpowers has the material only as guidance for
  someone *writing* a test, never as a sweep over a suite that exists.
- [ ] **4.11** /why — decision archaeology (*pulled forward from wave 5,
  2026-07-29*). Answers "why is this code like this" from BRIEF
  constraints → dated PLAN decision blocks → JOURNAL entries → git blame,
  in that order, stopping at the first real answer and stating "no
  recorded rationale" when there is none. The payoff for three waves of
  document discipline, and the answer to onboarding a human onto an
  agent-built codebase. Confirmed absent everywhere — BMAD is the proof
  it is non-obvious: it keeps an append-only session memlog and per-epic
  retros and still ships no way to ask them anything.

> **Decision (2026-07-29):** 4.10 and 4.11 pulled into the launch wave.
> Both are unusually cheap — one is a new target on a skill that already
> exists, the other a reader for a corpus already three waves deep — and
> both are demonstrably unclaimed by every major pack surveyed. Launching
> with 21 skills rather than 19 gives README v2 a differentiator argument
> that does not rest on roadmap promises. Tradeoff: wave 4 grows by two
> skills before a launch already carrying seven infrastructure items.
> Revisit if 4.1–4.7 slip.

## [ ] Wave 5 — Gates: pre-flight + verification

**Goal:** Generalize `/migrate-check`'s shape — read-only, classify every
change additive vs destructive, end in a written GO/NO-GO — into the lane
no surveyed pack occupies at all. Plus the one verification skill worth
building.

**Exit criterion:** Each gate returns a written verdict against a seeded
scratch project; none of them can write (enforced by `allowed-tools`, per
4.8's precedent).

- [ ] **5.1** /deps — dependency hygiene: what packages were added and
  why, maintenance status, license posture, whether stdlib or an existing
  dependency would have done it, whether it is even imported. Agents add
  packages reflexively; nothing in any surveyed pack looks at this.
- [ ] **5.2** /contract-check — breaking-change pre-flight for the surface
  callers depend on: function signatures, API response shapes, public
  exports, config keys. Same additive-vs-destructive classification and
  safe-alternative column as `/migrate-check` (add-new-then-deprecate
  rather than rename). The cheapest build in these three waves — the
  template already exists and is shakedown-proven.
- [ ] **5.3** /careful — GO/NO-GO for destructive operations generally:
  history rewrites on shared branches, bulk deletes, production config
  edits, secret rotation. `/migrate-check` covers the database slice and
  nothing else today; gstack splits this across three skills, acstack
  does it as one verdict.
- [ ] **5.4** /verify — audits a completion *claim* rather than the code:
  re-derives what acceptance demands, runs it against the running system,
  reports CONFIRMED / OVERSTATED / FALSE. **Build last and only with that
  angle** — this is the crowded lane. superpowers gates the agent on
  itself before it may claim done, spec-kit's `/speckit.converge` diffs
  code against spec and emits more tasks, and BMAD's Acceptance Auditor
  reviews the diff via a context-free subagent. acstack already covers
  much of this distributed across `/do` (runs acceptance before ticking),
  `/ship` (five gates), and `/triage` (checked boxes that now fail). The
  genuine gap is auditing a claim made by *someone else* — another
  session, another agent, a teammate — against a running system.

> **Decision (2026-07-29):** /verify folded into this wave rather than
> keeping a one-item wave 5. Its two companions (/audit tests, /why) moved
> to wave 4, and "honest measurement" as a theme moved with them; what
> remains is a gate, which is what this wave is. Tradeoff: the wave now
> mixes pre-change gates with a post-change one. Revisit if /verify grows
> enough to stand alone.

## [ ] Wave 6 — The review board

**Goal:** Multi-perspective review — the team — expressed as lenses, not
personas. Each reads a named artifact, applies a checklist, and returns a
verdict. No first names, no roleplay, no "as your architect I would say".

**Exit criterion:** Each lens returns a verdict on a seeded project
carrying its specific defect class; `/board` convenes the relevant ones
and consolidates without averaging dissent away.

- [ ] **6.1** /architect — the system's shape as built: module
  boundaries, coupling, which direction dependencies point, abstractions
  that do not earn their keep, logic that leaked into the wrong layer.
  `/plan-review` covers structure *before* code and BRIEF carries the
  `## Architecture Decision: X, NOT Y` line; nothing revisits it after,
  which is exactly where drift accumulates when agents write fast.
- [ ] **6.2** /a11y — keyboard navigation, focus order, labels and roles,
  contrast, motion and reduced-motion, form-error association.
  `/design-audit` covers palette, honest labels, slop, and client-facing
  language — all a different axis. Absent from all four surveyed packs.
- [ ] **6.3** /devex — the cold-start experience: clone → install → run on
  a clean machine, whether errors are actionable, how much undocumented
  tribal knowledge the setup assumes. Today only one line of this exists
  (`/audit docs` runs the README quickstart "where cheap").
- [ ] **6.4** /ops — operability: does it fail loudly or silently, is
  anything observable, what happens on partial failure, is there a
  runbook for the obvious break.
- [ ] **6.5** /data — data model review: schema shape, integrity
  constraints, nullability honesty, index posture against real query
  patterns. Neighbor to `/migrate-check`, not the same job — that one is
  migration *safety*, this is schema *design*.
- [ ] **6.6** /board — convenes the lenses relevant to a change, each as a
  **subagent with no prior conversation context**, and returns one
  consolidated report with dissents preserved rather than averaged. The
  context-free part is load-bearing: it stops a reviewer inheriting the
  builder's rationalizations. Proven in practice — wave 3's independent
  review ran this way and found the `sk-live-` secret-regex gap that a
  self-review demonstrably missed. Prior art: gstack `/autoplan`, BMAD's
  parallel review subagents.

## [ ] Wave 7 — Operate

**Goal:** Coverage past the merge. `/ship` deliberately stops at the PR;
everything after it is currently uncovered.

**Exit criterion:** A deploy → verify → rollback path proven on a scratch
project; the incident path exercised once against a seeded outage.

- [ ] **7.1** /deploy — deploy, verify it took, and state the rollback
  path before it is needed.
- [ ] **7.2** /incident — production is broken now: what changed, blast
  radius, mitigate first and diagnose second, then hand to `/investigate`
  and `/learn`. Must name its own tension explicitly — `/investigate`'s
  iron law is no fixes without investigation, and incident response
  deliberately inverts that ordering.
- [ ] **7.3** /document — authors documentation that does not exist yet
  (module purpose and invariants, API reference, runbook). `/audit docs`
  only *detects* drift; nothing in the pack writes.
- [ ] **7.4** /cost — what a feature cost in tokens and infrastructure.
  Depends on 4.3's telemetry pipe.

## Open items (decide as we go)

- [x] **Commit subject format (NEW 2026-07-27).** ~~Document mode: keep
  `completed task 3.2.1 (…)` or switch to terse `3.2.1: <desc>`.~~
  **Verdict (2026-07-29):** both modes take one symmetric shape — the
  mode changes the noun, nothing else:
  - document mode — `task 2.3.2: <description>` (was
    `completed task 2.3.2 (<description>)`)
  - tickets mode — `ticket #2: <description>` (was `#2: <description>`)

  The `#` is kept in tickets mode deliberately: GitHub auto-links `#2` in
  a commit subject, and dropping it would trade a working cross-reference
  for nothing. Issue closing is unaffected either way — that comes from
  `Fixes #N` in the body.

  **Not yet implemented.** Lands with an edit to CONDUCT rule 10, `/do`,
  `/ship`, and README's `subtask-commit-format` row. Until then the pack
  still emits the old shapes, and wave-2's JOURNAL entry keeps describing
  `#N:` as the format of its day (supersede-don't-delete: history stays
  as written). This repo's own commits are unaffected — acstack uses the
  lowercase `<verb> <object> (<detail>)` convention from AGENTS.md.
- [x] **Scratch-repo policy (NEW 2026-07-29).** **Verdict (2026-07-29):**
  never reuse a shakedown repo — create a fresh one per wave that needs
  one, throw it away after. Each wave seeds *conflicting* conditions
  (wave 2 needed a rotten backlog; wave 3 needed a vulnerable app; wave 6
  would need dependency sprawl), and reuse destroys the property these
  tests exist to prove: tickets-mode bootstrap idempotency is only
  testable once per repo, from cold. Wave 3 already drifted this way on
  its own — it used a local scratch directory and created no repo at all,
  because nothing in it needed tickets mode. The launch demo (4.7) is a
  separate, deliberately curated artifact, never a promoted leftover.
  Deletion of `acstack-w2-shakedown` is owner: user (needs
  `gh auth refresh -s delete_repo`); contents verified disposable
  2026-07-29 — the only non-generated artifacts were 25 golden cases
  hardcoded to a 4-row toy fixture, and an empty LEARNINGS.md.
- [x] **Referral block / discoverability (NEW 2026-07-29).** Typed-only
  skills (`disable-model-invocation: true`) are invisible to the agent,
  so it cannot recommend what it cannot see — a user who never discovers
  `/plan` has effectively installed nothing. **Verdict (2026-07-29):**
  a marker-fenced `acstack-referrals` roster in AGENTS.md (skill →
  one-line definition → suggest-when), guarded by check.sh asserting the
  table matches exactly the set of skills carrying
  `disable-model-invocation: true`, verified by a `/health` row, and
  installed by `/plan seed` alongside the conduct block.

  Behavior placement: ~~text local to the block~~ / ~~new CONDUCT rule
  11~~ → **a half-sentence clause on existing rule 9.** A referral IS an
  offer, and rule 9 already governs offers (permitted, expectation-free,
  never repeated, silence is not consent). Rule 11 was rejected as a
  category mismatch — rules 1–10 govern how an agent talks to a human and
  hold with zero skills installed, whereas referral is a property of the
  pack; it would also have needed the roster table anyway, buying no
  independence while making every existing install stale. The count stays
  at ten. Slated for wave 4 (distribution is where discoverability
  belongs). **Not yet implemented.**
- [x] **Browser probe timing (NEW 2026-07-27).** ~~Playwright mode for /qa —
  wave 3 with http, or deferred until first real need.~~ **Verdict
  (2026-07-27):** deferred to first real need (user call at wave-3 spec
  time). Wave 3 ships the http probe with the seam designed for both
  modes, so adding browser later stays additive — locked decision 8's
  no-architectural-penalty bet, restated in `docs/wave-3-specs.md`.
- [x] **GitHub remote (NEW 2026-07-27).** ~~Private `AaravChadha/acstack`
  creation awaits explicit user go.~~ **Verdict (2026-07-27):** created
  private and pushed — `main` tracks `origin/main`, all 31 commits up.
  Public flip stays gated on the wave-4 launch checklist (4.7).
