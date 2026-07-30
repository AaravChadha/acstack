# PLAN.md — acstack

> **Purpose of this document.** The operative roadmap for the pack itself:
> what ships in each wave and how we know a wave is done. Waves 1–3 are
> built (19 skills); detailed per-skill specs for later waves get written
> at wave start, at the same fidelity as waves 1–3's (`docs/wave-2-specs.md`,
> `docs/wave-3-specs.md`). The founding design discussion — wave-1 specs,
> skill-roster rationale, infra tradeoffs, telemetry stance, and the
> numbered locked decisions — predates this file, lives under
> `~/.claude/plans/` outside this repo, and is summarized in README.md
> and CONDUCT.md.
>
> **Cross-cutting constraints (apply to every wave):**
> - Plain markdown skills; zero runtime dependencies beyond git + bash 3.2+
>   (the version macOS ships). Stated as POSIX until 2026-07-29; both `setup`
>   and `check.sh` use `BASH_SOURCE` and process substitution, so the claim
>   was false — corrected rather than the scripts rewritten, since bash 3.2
>   is present everywhere the pack targets.
> - All pack memory is repo-owned; machine-local state is limited to an
>   update-check stamp (4.2, wave 4) and, once telemetry ships, a usage log
>   (4.3, wave 4.5).
> - No client/company/collaborator names in pack content (guard-enforced).
> - `scripts/check.sh` clean before every commit.
> - Public launch only after the wave-4 checklist passes.
> - **Every check-shaped skill ships a positive control (NEW 2026-07-29).**
>   A fixture containing a known instance of what the skill is supposed to
>   catch, plus a check that fails if the skill does not catch it.
>   Rationale: wave 3's shakedown planted an `sk-live-…` key and
>   `/secure`'s secrets sweep reported *clean* — its pattern
>   `sk-[A-Za-z0-9]{20,}` stopped at the first hyphen after the prefix.
>   A broken check returning a pass is worse than no check, because it
>   converts an unknown into a false certainty. Without positive controls
>   we have evidence our checks RUN, not that they WORK. Three false passes
>   are now documented: this one, check.sh's description guard on
>   2026-07-29, and /design-audit's palette check, whose `\b` matched
>   nothing at all in POSIX ERE. (/ship's gate 1 was a false FAIL — loud,
>   not silent, and so a different class.)
>   Applies retroactively to /qa, /secure, /design-audit, /health, /audit,
>   and /migrate-check, and to every wave-6 lens — carrier task **4.15**.
> - **Resolve one document set, and say which (NEW 2026-07-29).** Every
>   document-reading skill (/plan, /do, /resume, /journal, /retro, /ship,
>   /audit docs, /health, /ticket, /triage, /learn, /plan-review, /challenge,
>   and /why (4.11))
>   resolves exactly ONE BRIEF/PLAN/JOURNAL set and names its path in the
>   scope line. If more than one candidate set exists, list the candidates
>   and STOP — never pick one silently. Ambiguity is a reason to stop, not
>   to guess (CONDUCT rule 8). This does not add monorepo *support*; it
>   converts a silent wrong-product answer into an honest halt, which is
>   the whole cost of the limitation below.
> - **Reports state what they did NOT check (NEW 2026-07-29).** Already
>   practiced via the `Scope` element; recorded here as binding because it
>   is the primary defense against false confidence. A verdict is an input
>   to the user's judgment, never a permission slip.
>
> **Known limitations (recorded 2026-07-29, not defects):**
> - **One repo = one BRIEF/PLAN/JOURNAL.** Every skill assumes a single
>   product per repository. Monorepos and multi-product repos break this
>   silently — `/resume` and `/retro` would confidently report on the
>   wrong product. Multi-product *support* stays out of scope at launch;
>   detection and an honest halt do not — see the resolve-one-document-set
>   rule above and task **4.14**.
> - **Correlated blind spots are structural.** Wave 6's lenses decorrelate
>   by having different checklists, not by being independent reviewers —
>   they share one model's priors. `/board` cannot manufacture genuine
>   independence, and the open slot is answered by the same prior that
>   created the gap. Mitigation is honest scope statements, not more
>   reviewers.
> - **Absence is nearly invisible to diff-scoped review.** A missing auth
>   check in an untouched file produces no diff lines. Whole-surface runs
>   of /secure and /qa are the counterweight to review-time-only checking.
> - **Process prerequisites in prose are invisible to `/resume`.** Its
>   "unblocked" is defined by checkboxes and `## Open items` only, so a
>   prerequisite recorded in prose — like this header's
>   specs-at-wave-start rule — never blocks a task. Found by the 4.7
>   item 10 cold start (2026-07-29), which named 4.1 as next when the
>   true next unit was `docs/wave-4-specs.md`. **Deliberately declined,
>   not carried:** the fix would mean parsing prose for constraints,
>   which is out of proportion; the mitigation is keeping such rules in
>   this header, which the skill's PLAN read does surface.

## Index of waves

| Wave | Goal | Exit criterion |
|---|---|---|
| [x] 1 — Core + foundation | The five core skills installable and honest | `./setup` round-trips; `scripts/check.sh` clean; skills load in a fresh session |
| [x] 2 — Gate, eval, tickets | Planning gets teeth; tickets mode lands | All wave-2 skills load; tickets mode drives a real GitHub repo end-to-end |
| [x] 3 — Ship + reflect | Full sprint coverage | /qa (http), /secure, /ship, /retro, /learn, /design-audit, /health load and pass their shakedowns |
| [ ] 4 — Distribution + launch | A stranger can install, trust, and update it | Fresh-machine install test passes; launch checklist all green |
| [ ] 4.5 — Post-launch hardening | More rigorous and more capable, once real adopters exist | Each item's acceptance passes; journal records what adopter feedback reordered |
| [ ] 5 — Gates: pre-flight + verification | Nothing destructive or unverified lands quietly | Each gate returns a written verdict on a seeded repo; none of them can write |
| [ ] 6 — The review board | Multi-perspective review without personas | Each lens returns a verdict on a seeded project; /board consolidates with dissents preserved |
| [ ] 7 — Operate | Coverage past the merge | Deploy → verify → rollback path proven; incident path exercised once |
| [ ] B — Browser layer | *Unscheduled, demand-triggered* — unblocks rendered QA, a11y, design, perf | Browser probe implements the existing reach/act/observe contract; every dependent skill still degrades cleanly without it |

> **Roadmap note (2026-07-29):** waves 5–7 were designed after a survey of
> gstack (53 skills, inspected from a clone), obra/superpowers (14),
> GitHub spec-kit (10 commands), and BMAD-METHOD. Every skill below was
> checked against all four; the ones that survived are either absent
> everywhere or an existing acstack shape pointed at a new target.

> **Second survey (2026-07-30) — eight repos, cloned and counted, three
> context-free readers.** Source record, counted facts, and the exact
> file paths each carrier cites: `docs/survey-2026-07-30.md`. obra/superpowers (still exactly 14 skills; its
> ★264k growth is seven harness packagings + test suites),
> thedotmack/claude-mem (66k-line TS memory daemon — the opposite memory
> bet), anthropics/skills + the claude-code code-review and
> security-guidance plugins (acstack passes every counted axis of the
> official authoring standard; their own repos break it — claude-api at
> 546 lines vs their <500 norm, code-review's README documenting a 0-100
> scorer and a git-blame agent its command file doesn't contain), and
> four design/taste skills (emilkowalski/skills, pbakaus/impeccable,
> Leonxlnx/taste-skill, ui-ux-pro-max — ~★250k combined) which converge
> independently on one mechanical slop signature and craft floor.
> Carriers from it: **4.27–4.30** below, plus dated notes on 4.4, 4.6,
> 6.2, 6.7, and Wave B. **Declined, with reasons:** multi-harness
> packaging (Claude-Code-only at launch is locked; superpowers'
> porting doc is the recipe if demand appears); /standup and
> /timeline-report as skills (folded — `/retro week` already covers the
> shape); a search index derived from committed markdown (deferred until
> JOURNAL-reading pain is real; 4.29 is the cheap first step); numeric
> scoring models — impeccable's 0–4 dimensions and code-review's
> documented-but-unimplemented 0–100 filter (score theater vs
> verdict-first findings; their own README drift proves the hazard);
> per-step model choreography, Python/Node hook engines, font/CSV
> payloads, machine-local stores, and prose-pressure enforcement
> (`<EXTREMELY_IMPORTANT>` tags — prose decay is why check.sh exists);
> frontend-design's generative persona (4.30 takes its process, not its
> persona).
>
> **Completeness ledger (2026-07-30).** Every steal-list item from the
> three reader reports, enumerated rather than asserted — the set rule
> applied to the survey itself. *superpowers:* skill RED-GREEN → 6.7;
> test harness → 6.7; session-start hook → 4.4; porting doc → declined;
> claim/requires/not-sufficient table → 4.28. *claude-mem:*
> search→filter→fetch → 4.29; Stop-hook reminder → 4.4; standup +
> timeline → declined (folded into `/retro week`); `what-the` →
> **already covered, no carrier** — `/investigate` reads LEARNINGS.md
> and known-bug-classes before hypotheses (`skills/investigate/SKILL.md`
> lines 61–62). *Anthropic:* false-positive blocklist, triage gate,
> inline-justification demotion, one-comment-per-issue → 4.28; config
> truncation priority → 4.6; with/baseline eval runs → 6.7; per-finding
> validation → 6.6; doc-coauthoring → 7.3; webapp-testing → B.1.
> *Design four:* impeccable's 47 rule IDs, craft floor, taste-skill §9 +
> banned hex, emil motion bounds, ui-ux-pro-max severity columns → 4.27;
> emil's Before/After/Why + review-vs-improve split, taste dials,
> frontend-design two-pass → 4.30; a11y statics → 6.2; one-rule-list
> across static and rendered → Wave B; scoring models → declined.
> **Audit of the survey itself (2026-07-30, third pass).** After the
> emil miss, every multi-member set in all three reader reports was
> re-enumerated against the clones. **The failure was systematic: 5 of
> 8 repos had unenumerated sets** — a reader counts the set correctly,
> details the interesting subset, and the count reads as coverage.
> Clean: obra/superpowers (all 14 skills named), and the two
> single-skill targets. Incomplete: emilkowalski 8 skills / 3 detailed
> (fixed, second pass); **thedotmack/claude-mem 18 / 8** — unnamed:
> babysit, cloud-sync, design-is, how-it-works, knowledge-agent,
> oh-my-issues, pathfinder, smart-explore, version-bump, wowerpoint;
> **nextlevelbuilder/ui-ux-pro-max 7 / 2** — unnamed: banner-design,
> brand, design, design-system, slides; **Leonxlnx/taste-skill 13 / 2**
> — the rest are style variants (brutalist, soft, minimalist, stitch,
> brandkit, output, gpt-tasteskill…), which is itself the evidence that
> its "dials" are the generalization; **pbakaus/impeccable 22
> sub-commands / ~6** — unnamed included `harden.md` (336 lines),
> `delight.md`, `critique.md` (788), and a whole `reference/degraded/`
> tree. **anthropics/skills 17 / 3 detailed** (+5 checked by hand);
> unexamined remainder is the document-format family (docx, pdf, pptx,
> xlsx, slack-gif-creator, algorithmic-art, canvas-design, mcp-builder,
> internal-comms) — reviewed by name and declined: artifact-generation
> for end users, orthogonal to an engineering-discipline pack.
> **Recovered and carried:** harden/delight/design-system → 4.30;
> degraded/ → 4.18; oh-my-issues → NEW **4.32**; smart-explore → 4.29
> (noted, dependency declined); critique.md's two-independent-
> assessments → 6.6 below. **Also declined by name:** babysit (PR
> watching — real gap, but wave 7 operate territory and /ship
> deliberately stops at the PR), version-bump (4.1 already ships
> VERSION/CHANGELOG with a guard), cloud-sync + knowledge-agent +
> pathfinder + wowerpoint + design-is + how-it-works (memory-daemon
> surface or presentation generation), and ui-ux's banner/brand/slides
> (marketing asset generation).
> **Process finding, recorded because it recurred:** a subagent report
> that states a count and details a subset is an unenumerated set claim,
> and the reviewer accepting the count without listing members is how it
> ships. AGENTS.md's set rule already binds this — it was applied to the
> pack's own claims and not to inbound reports. The fix that worked was
> mechanical: `ls` every member directory, diff against names appearing
> in the report.
>
> **Ledger correction (2026-07-30, second pass).** The first ledger was
> incomplete for one repo: emilkowalski/skills has **eight** skills and
> the reader detailed three, summarizing the rest by their motion rules.
> Unsurfaced and now carried: **`apple-design`** (282 lines — response,
> interruptibility, springs, velocity handoff, momentum projection,
> materials/translucency, multimodal, reduced-*) → 4.27's
> interaction-feel block and 4.30's `interaction-feel.md`;
> **`animation-vocabulary`** (173 — a reverse-lookup glossary turning
> "the bouncy thing when a popover opens" into *Pop in*) → 4.30, as the
> naming layer for design conversations, which is the problem a user
> hits when they reach for a material name to describe a behavior;
> **`find-animation-opportunities`** (132) → 4.30's method, where
> motion is proposed rather than sprinkled; **`prototype`** + PICKER
> (197 + 90) and **`pick-ui-library`** (77) → declined, both are
> stack-selection advice that dates fast and duplicates judgment the
> adopter's own repo already encodes. **Process note:** this is the
> summarize-instead-of-enumerate failure the set rule exists to catch,
> committed by a subagent this time — a report that says "eight skills"
> and details three is an unenumerated set claim, and the reviewer
> (me) accepted the count without listing the members.
> **Measured, no action:** SKILL.md average is 108.7 lines across 19
> (range 84–176) against 93 at the wave-3 close — the delta is the
> 4.2 runtime block (~12 lines × 19), not scope creep, and every file
> remains far inside the 500 budget. Journal entries keep their
> as-written numbers. The
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
push; /triage groomed seeded rot (dupe closed with reason,
`needs-acceptance` labeled); /eval-spec landed 25 golden cases before any code
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
and found the auth gap on the scratch app — but **initially MISSED the
seeded key**, reporting clean; see the fix below. /design-audit flagged
the off-palette color, the unlabeled mock chart, and slop copy.
/ship's five gates ran on a scratch feature branch (fix verified:
`limit=abc → 400`). /learn captured a lesson, bumped `seen` on the
repeat, and its promotion path added a real class to known-bug-classes.
/health and /retro ran on acstack. **Shakedown earned a real fix:** the
secret-scan regex missed every prefixed key format — `sk-live-…` (the
one actually seeded), `sk-proj-…`, `sk_live_…` — because
`sk-[A-Za-z0-9]{20,}` stops at the first hyphen after the prefix. Widened
to `sk[-_][A-Za-z0-9_-]{20,}` and promoted to known-bug-classes (commit
d709d70). Found by the **shakedown**, not by the independent review — the
review read files, the shakedown ran the check against a planted defect,
which is the whole argument for positive controls.

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

- [x] **4.1** VERSION + CHANGELOG.md; issue template requiring VERSION.
  *(Done 2026-07-30: VERSION `0.4.0`; CHANGELOG with 0.1–0.3 distilled
  retroactively and `0.4.0 — unreleased` on top; `.github/ISSUE_TEMPLATE/
  bug.yml` with `required: true` version field; check.sh section 6
  enforces agreement, demonstrated by three guard-matrix full-tree cases
  that reported BAD before the guard existed and ok after — matrix
  15 → 19 cases, 19 passing.)*
  **Acceptance (added 2026-07-30, from docs/wave-4-specs.md):** VERSION
  parses semver and equals CHANGELOG.md's first versioned heading; the
  issue template's version field is `required: true`; the
  VERSION/CHANGELOG mismatch guard demonstrated firing on a seed.
- [x] **4.2** *(Done 2026-07-30: 11-line marker-fenced `acstack:runtime`
  block, canonical in README, byte-identical across all 19 skills,
  enforced by check.sh section 12 with `PREAMBLE_BUDGET=12`; three
  matrix cases — drift, missing, over-budget — shown failing first
  (matrix 40 → 43). `bin/acstack-config` (4-level precedence with
  sources), `bin/acstack-update-check` (stamp-first daily throttle,
  offline exits 0 silently, prints the pull command when behind, never
  pulls), `bin/acstack-recall` (6KB cap with honest truncation marker,
  empty degradation) — all demonstrated against scratch fixtures, all
  shellcheck'd. `runtime` config key added to README + template.
  Machine-local state: exactly `~/.acstack/update-stamp`.)*
  Slim per-invocation preamble (≤12 lines, hand-maintained,
  budget enforced by check.sh) + `bin/` helpers (config resolve,
  update-check, recall) — bash 3.2+, matching `setup` and `check.sh`;
  `runtime: off` degrades cleanly.
  **Acceptance (added 2026-07-30, from docs/wave-4-specs.md):** with
  `runtime: off`, a skill invocation runs no pack command and creates
  nothing under `~/.acstack/`; with defaults, the first run creates the
  update stamp and a second same-day run does not fetch; a no-network
  run exits 0 silently; recall output is capped at ~6KB and degrades to
  empty; check.sh fails on a seeded one-skill preamble drift and on a
  13-line preamble (both matrix-demonstrated).
- [ ] **4.5** CI: GitHub Action running check.sh + shellcheck on every PR.
  *(Built 2026-07-30: `.github/workflows/check.yml` — check.sh, the
  guard matrix, and shellcheck on push-to-main and every PR; the
  banned-names SKIP gap stated in the workflow's own comment. Box stays
  OPEN deliberately: the acceptance below needs a live run — a clean
  push showing the SKIP line, and a seeded-violation PR failing — which
  cannot be demonstrated locally. Evidence lands with the next push.)*
  **Acceptance (added 2026-07-30, from docs/wave-4-specs.md):** a PR
  carrying a seeded guard violation fails CI; a clean PR passes with
  the banned-names SKIP line visible in the log (CI has no
  `.acstack-banned` by design; local pre-commit stays the enforcement
  point for names).
- [ ] **4.6** PRINCIPLES.md, docs/ARCHITECTURE.md (every preamble line
  documented), CONTRIBUTING.md; README v2 with a see-it-work walkthrough
  and the built-in shadowing disclosure (/plan, /resume — per the
  2026-07-27 decision; also why user-only skills miss the VS Code
  autocomplete).
  **Acceptance (added 2026-07-30, from docs/wave-4-specs.md):**
  ARCHITECTURE.md documents exactly as many preamble lines as the
  preamble block contains; README v2 carries the walkthrough and both
  shadowing disclosures; the 4.17 cross-reference and
  config-reachability guards pass over all four documents.
  *Note (2026-07-30, survey):* ARCHITECTURE also documents the config
  truncation priority for layered config (user-wide kept, project next,
  local dropped first — security-guidance's model); CONTRIBUTING states
  the skill RED-GREEN rule carried on 6.7.
- [ ] **4.7** Launch checklist — every line must be *demonstrated*, not
  asserted. Nothing here is checkable by re-reading a file (AGENTS.md's
  verify-the-consumed-form rule); each item names the artifact that
  proves it.

  **Mechanical**
  1. `scripts/check.sh` green, and every guard in it shown firing against
     a seeded defect — a guard with no demonstrated failure mode does not
     count as coverage.
  2. Every skill's frontmatter **parses**, and each description survives
     intact into the live skill listing (the `/ship` truncation class).
  3. Cross-references resolve: every skill named by another skill exists,
     every referenced file path exists, every config key in README is
     reachable from `templates/acstack.md` and read by the skill claimed.
  4. `./setup` round-trips on a **fresh machine**: install → idempotent
     re-run → uninstall removes exactly what it created → reinstall.

  **Independent review — both kinds, because they catch different classes**
  5. A multi-agent audit of PLAN.md and all skills, run as subagents with
     no prior conversation context. Every finding resolved or explicitly
     accepted in writing with a reason.
  6. A main-thread pass over the same ground. The 2026-07-29 audits proved
     neither substitutes for the other: the subagents found a shipped
     truncated description and a misclassified read-only skill that the
     author had re-read without noticing, while the main thread found a
     positive control that passed misleadingly and a provenance
     contradiction — each needing context the other lacked.

  **Content**
  7. Demo transcript recorded against a real project, deliberately
     curated — never a promoted shakedown leftover.
  8. Credits line verified; no personal, client, or collaborator data
     ~~anywhere in the history (not just the working tree)~~ in the
     working tree. *(History scope removed 2026-07-30: the 4.24 purge
     was declined by verdict — the historical roster is accepted as
     public. The working-tree sweep stands.)*
  9. Every wave-4 acceptance line actually run, with its output pasted
     into the wave's journal entry.
  10. **The two skills that have never faced their real case.** `/resume`
     has never been run as a genuine cold start (a session with no prior
     context reading only the three documents), and `/investigate` has
     never chased a real failure — flagged as their "true shakedown" in
     the wave-2 journal entry, 2026-07-27, and carried nowhere until now.
     Both are launch-facing: `/resume` is the first skill a returning
     adopter runs, and a five-minute catch-up that doesn't catch up is a
     visible failure. **Acceptance:** a context-free session runs
     `/resume` and correctly states the current wave, the divergence
     flags, and three genuinely unblocked tasks; `/investigate` roots a
     real failure to a `file:line` cause. Note the cold start cannot be
     faked from inside a session that already knows the answer.

  Only then flip public. **Acceptance:** the launch commit's journal entry
  carries evidence for all nine — a command and its output, or a named
  artifact — with no line resting on "looks right".
- [x] **4.8** *(Done 2026-07-30: all five declare tool sets derived from
  the commands their own text documents — /secure git grep/log/ls-files/
  status, /design-audit git grep only, /audit +check-ignore/ls, /resume
  +gh issue list, /health +cat/command -v/gh auth status/label list. No
  entry is bare `Bash`. check.sh section 13 asserts the six read-only
  skills (the five + /migrate-check, their template) declare
  allowed-tools with no Write/Edit/NotebookEdit and no unscoped Bash;
  three matrix cases — declaration removed, Write granted, bare Bash
  granted — were shown failing first (matrix 43 → 46). Consumed form
  verified: all five re-registered in the live skill listing with
  descriptions intact after the frontmatter change.
  **Honest scope, unchanged:** the guard proves the DECLARATION;
  enforcement is Claude Code's permission layer, so the seeded
  write-attempt probe stays 4.7 evidence, not a check.sh line.)*
  `allowed-tools` on the **five** structurally read-only
  skills — /secure, /health, /design-audit, /audit, /resume. Their
  never-writes promise is prose today; this makes it mechanical. README
  v2 claims "audit what you're trusting in five minutes" — this is what
  backs that claim. **Acceptance:** each of the five declares a read-only
  tool set; check.sh asserts none of them can Write/Edit; the assertion
  is proved by a positive control (a seeded write attempt must fail).

  > **Correction (2026-07-29):** this item originally said "six" and
  > included /retro. /retro is NOT read-only — it appends a dated entry
  > to JOURNAL.md and commits it (`skills/retro/SKILL.md:67`). The
  > acceptance criterion as first written would have failed against a
  > correctly-built /retro. **/migrate-check** is excluded because it
  > already declares `allowed-tools` — it is the template the other five
  > copy. **/qa** is excluded because it makes network requests: its tool
  > set is narrower-than-write but not the same shape, and 4.15 groups it
  > with the check-shaped skills for positive controls, which is a
  > different question from whether it can write.
- [x] **4.9** *(Done 2026-07-30: marker-fenced `acstack-referrals` roster
  in AGENTS.md listing exactly /plan and /eval-spec, /plan's suggest-when
  carrying the approved build-without-a-plan trigger verbatim (bright
  line, work-first timing, concrete options, once-per-session, no state
  file); the rule 9 clause added to CONDUCT.md and AGENTS.md, blocks
  verified byte-identical; `/plan seed` installs the block by the same
  pack-root readlink rules as the conduct block, never from memory;
  `/health` gains check 3b plus its SKILL.md row. check.sh section 14
  diffs the roster against the `disable-model-invocation: true` set —
  two matrix cases (a dropped row, a model-invocable skill added) shown
  failing first; matrix 46 → 48.)*
  Referral block — discoverability for typed-only skills, per
  the 2026-07-29 verdict in Open items. Marker-fenced `acstack-referrals`
  roster in AGENTS.md (skill → one-line definition → suggest-when); a
  clause on CONDUCT rule 9 carrying the behavior (name it once, never
  repeat, silence is not consent); `/plan seed` installs it beside the
  conduct block; `/health` gains a row verifying it is present and
  current. **Acceptance:** check.sh fails when the table's skill set
  differs from the set carrying `disable-model-invocation: true`.

  > **Sharpened (2026-07-30, user-approved).** `/plan`'s `suggest-when`
  > gains the build-without-a-plan trigger, and the offer's shape is
  > specified so it cannot become nagging.
  > **Trigger (bright line, deliberately narrow):** a *build* request in
  > a repo with no PLAN.md (or legacy equivalent) AND the work is not a
  > bounded single-file change — new files, new surface, or multi-file
  > work. A one-line fix NEVER triggers it. A trigger that fires on typo
  > fixes gets disabled within a day, which costs more than it saves.
  > **Timing:** the work happens first, and the offer rides the
  > end-of-increment status statement (rule 2's boundary, rule 9's slot).
  > Never a precondition — that is superpowers' hard gate, which this
  > repo rejected 2026-07-30 for violating rules 1 and 5 (it converts
  > "build" into plan mode regardless of the user's word, asks
  > permission for already-requested work, and commits a design doc
  > nobody asked for).
  > **Shape:** name concrete options with a recommendation — "spec first
  > in docs/ / a short design sketch / keep building as-is; I'd suggest
  > X because Y" — never a bare "want to plan?". One clause of reason,
  > borrowed from superpowers' genuinely correct anti-pattern note:
  > simple-looking work is where unexamined assumptions cost most.
  > **Bound:** once per session per repo. **No state file** — a recorded
  > decline would be exactly the hidden machine-local state the pack
  > rejects, so a later session may ask once more; PLAN.md appearing is
  > itself the signal to stop asking. Silence or a pivot is not consent
  > (rule 9, unchanged).
  > **Acceptance addition:** on a seeded repo with no PLAN.md, a
  > multi-file build request produces the work plus exactly ONE offer
  > naming concrete options; a single-line fix in the same repo produces
  > no offer at all; a second build request in the same session produces
  > no second offer.
  > **Edits:** `AGENTS.md` (referral table + conduct block clause),
  > `CONDUCT.md` (rule 9 clause — both blocks, byte-identical),
  > `skills/plan/SKILL.md` (seed installs the block),
  > `skills/health/references/health-checks.md` + SKILL.md (the row),
  > `scripts/check.sh` (roster-vs-flag guard).
- [x] **4.12** *(Done 2026-07-30: `skills/eval-run/` — 20th skill,
  model-invocable, cost disclosed before the run rather than asked as
  permission. Prefers an existing runner, scaffolds only when none
  exists, stops rather than guessing a stack. Denominator discipline is
  explicit: needs-data skipped and reported as skipped, superseded
  excluded, `acceptable_failure` only with a written reason. The
  headline is recomputed FROM the results file — the template's Python
  is executable and was run, not just written.
  **Positive control proven both directions:** `fixtures/eval-run/`
  seeds a failing case and a needs-data case; a correct runner reports
  **4/5 (80.0%)**, and a runner seeded to swallow errors and count
  skips as passes reports 100% and is caught by controls.sh. No network,
  no API key, no dependencies. Guard fix earned en route: the crossref
  extractor read `#!/usr/bin/env` as a skill reference — a skill ref is
  never followed by `/` — and the fix's own `grep -v` reintroduced the
  pipefail early-death class, caught by the matrix and fixed with a
  load-bearing `|| true`. Matrix 48 → 49; setup links 20.)*
  /eval-run — close the loop on the flagship methodology.
  Today `/eval-spec` writes the spec and golden set, `/ship`'s eval gate
  *runs the eval per its run command*, and `/audit eval` reviews a
  report — all three assume a runner that no skill produces. Wave 2's own
  shakedown caught this: `/plan-review` flagged that M2's exit criterion
  invoked `eval/run.py` that no issue created. Launching "the eval is the
  spec" while the pack can specify and audit an eval but not execute one
  is a credibility gap in the single strongest differentiator — the
  adopter runs `/eval-spec`, gets 25 golden cases, and hits a cliff.
  **Scope:** scaffold the runner for the project's stack (a generic
  runner is impossible at zero dependencies — executing an eval means
  calling a model API), execute it, compute the headline from the raw
  results file and never by hand, and write results in the shape
  `/audit eval` already expects. **Acceptance:** on a scratch project
  with a golden set, produces a results file and a headline that
  `/audit eval` can read and `/ship`'s eval gate can compare to target.
- [x] **4.14** *(Done 2026-07-30: /health check 3c detects the shape by
  the three signal classes and reports it as INFO — unsupported, not
  broken — naming every set found; the resolve-one-document-set rule
  added to all **13** built document-reading skills (enumerated: plan,
  do, resume, journal, retro, ship, audit, health, ticket, triage,
  learn, plan-review, challenge — the 14th, /why, is unbuilt task 4.11),
  each standalone-readable rather than pointing at a README the adopter
  does not have; README states the constraint before install;
  `fixtures/multi-product/` seeds two document sets under `apps/*` plus
  a pnpm workspace marker, with a controls.sh check demonstrated both
  directions — clean on the seeded fixture, FAIL when a set is removed.
  The behavioral half — /health and /resume actually halting on this
  fixture — is 4.7 shakedown evidence, not a mechanical check.)*
  Multi-product detection — make the one-repo assumption
  visible instead of silent. Three parts:
  1. **`/health` row.** Flags a repo that violates the assumption.
     Signals, strongest first: more than one BRIEF.md / PLAN.md /
     JOURNAL.md below the root; workspace markers
     (`pnpm-workspace.yaml`, `lerna.json`, `turbo.json`, a `workspaces`
     key in package.json, `[workspace]` in Cargo.toml, `go.work`); and
     `apps/` `packages/` `services/` directories each carrying their own
     manifest. Reported as **info, not a failure** — a monorepo is not
     broken, it is unsupported, and the two deserve different words.
  2. **The resolve-one-document-set rule** applied to every
     document-reading skill's scope line (cross-cutting rule above).
     Ambiguity → name the candidate paths, stop.
  3. **README statement** of the constraint, so an adopter with a
     monorepo learns it before installing rather than after a `/retro`
     confidently reports on the wrong product.

  **Acceptance:** on a seeded two-product repo, `/health` names both
  document sets and `/resume` halts with the candidates listed instead of
  picking one. That seeded repo is also this task's positive control.
- [x] **4.15** *(Done 2026-07-30: `fixtures/` seeded for secure,
  design-audit, health, audit, migrate-check + a live-server qa fixture
  whose control runs at shakedown; `scripts/controls.sh` re-runs each
  documented detection command — extracted from the reference file at
  run time, so a pattern edit is what gets tested — wired in as check.sh
  section 11. Demonstrated both directions: all plants caught on the
  clean tree, and three matrix cases regress a pattern or delete a plant
  and watch the control fail; the control also caught a real defect on
  its first run — the audit fixture's NBSP plant was a plain space.
  Matrix 28 → 31.)*
  Positive controls for the shipped check-shaped skills —
  the carrier for the cross-cutting rule above, which was binding with
  nobody owning it. Each of /qa, /secure, /design-audit, /health,
  /audit, and /migrate-check gets a fixture containing a known instance
  of what it must catch, plus an assertion that fails when the skill
  misses it. **Acceptance:** seeding each fixture makes its check fail;
  removing the seed makes it pass. Evidence this is not theoretical: the
  `sk-live-` key (a check that ran and did not work) and check.sh's own
  description guard on 2026-07-29, whose first control passed
  misleadingly and would have shipped unverified.
- [x] **4.17** *(Done 2026-07-30: check.sh sections 7–10 — routing
  lines, cross-references/citations in four shapes, config-key
  reachability against README's table, verdict-first presence — plus a
  strict frontmatter parse in section 3. Snippet drift resolved by
  citation: canonical homes are /secure §2 (secret patterns), /audit
  eval-review-rules (six buckets), /qa adversarial-inputs (the bank,
  which absorbed prompt-injection-shaped); the three root-relative
  `skills/…` citations were caught by the new guard itself and converted
  to portable `../` forms. check.sh's header is now the single guard
  enumeration and README points at it. Matrix 19 → 28 cases, every new
  guard shown failing before it existed.)*
  Guard coverage for the mechanically-detectable classes —
  the carrier for "grow check.sh, not the prose", and the higher-value
  half of the 2026-07-29 process review (the four AGENTS.md verification
  rules are the lesser half). Six of that day's ten defects were
  mechanically detectable and only one (frontmatter safety) was guarded by
  day's end. Add to `scripts/check.sh`:
  1. **Routing line present** — every `skills/*/SKILL.md` carries
     `Adjacent skills:` (five wave-1 skills lacked it for two waves).
  2. **Cross-references resolve** — every `/skill-name` referenced in a
     SKILL.md names a real directory; every referenced file path exists.
  3. **Config-key reachability** — every key in README's table appears in
     `templates/acstack.md` AND is read by the skill the table names.
  4. **Shared-snippet drift** — pick one canonical home per snippet and
     make the others cite it, then guard the citations. Note the guard can
     only be byte-identity while duplicates EXIST; once they become
     citations, the check becomes "the cited section exists". The
     adversarial-input bank has already diverged three ways (audit has
     "empty query", eval-spec has "prompt-injection-shaped", neither
     carries the bank's HTML or Unicode cases). Covers: the secret-scan
     regex, the six
     eval failure buckets, and the adversarial input list are each
     duplicated across 2–4 files with no guard; the regex had *already*
     drifted (`ghp_` in one copy, absent in the other). Either mark one
     copy canonical and diff the rest, as done for the principles block,
     or collapse the duplicates.
  5. **Verdict-first present** — every report-shaped skill states its
     verdict-first stance (five violated it while the pack claimed it).
  6. **Frontmatter parses** — extend the description guard to assert the
     whole block parses and each description survives intact.

  **Acceptance:** each of the six fires against a seeded defect and is
  silent on the clean tree — demonstrated, per 4.15.

- [x] **4.22** *(Done 2026-07-30: an `act()` helper phrases every
  reported action as intent under `--dry-run` — `would link` /
  `would relink` / `would remove` against `linked` / `relink` /
  `removed` — summaries became "N would be linked, M would be skipped.
  Nothing was changed." and the start-a-new-session hint is suppressed.
  Verified against a scratch `CLAUDE_SKILLS_DIR`: dry install left the
  directory at 1 entry, dry uninstall left 20 before and 20 after, and
  the real paths still print past tense with 19 linked / 19 removed.)*
  Fix `setup --dry-run` reporting work it did not do. It
  prints per-item "linked <skill>" and a "19 linked, 0 skipped" summary
  while creating nothing; `--uninstall --dry-run` prints "removed <skill>"
  with the symlink still present. A dry run's output is exactly what a
  user trusts before running it for real. **Acceptance:** every dry-run
  line reads "would link"/"would remove" and the summary counts intended
  actions, verified against a scratch `CLAUDE_SKILLS_DIR`.
- [x] **4.23** *(Done 2026-07-30: `T4:` removed from rule 10's body,
  Good example, and both condensed blocks; verified by
  `git grep -nw 'T4:'` clean outside JOURNAL/PLAN/docs history and a
  byte-diff of the CONDUCT.md and AGENTS.md blocks.)*
  Resolve CONDUCT rule 10's self-contradiction before 4.16
  implements it. The rule's body says `T4: …` / `#42: …` are both tickets
  mode with document mode keeping `completed task 3.2.1 (…)`; the
  condensed block four lines later says "`T4: …` / `#42: …` **per tracking
  mode**", making T4 the document form — and `T4:` is emitted by no skill
  and appears in no config default. AGENTS.md carries the same condensed
  wording, so this repo's binding instruction is currently wrong. 4.16's
  acceptance never names `T4:`, so implementing it as written would leave
  the contradiction standing. **Acceptance:** `T4:` appears nowhere as a
  live format, and the body and condensed block agree.

- [x] **4.24** ~~Purge the banned-name roster from git history before the
  public flip.~~ **Verdict (2026-07-30):** purge **declined** — user call,
  made after reviewing the exact roster in history (`92e9779` added it
  inside check.sh, `883d729` removed it). The twelve tokens are company
  names whose association is not sensitive, bare first names, and project
  names that are already public repos. History exposure accepted; no
  rewrite, no repo recreation. **This no longer blocks 4.7's flip.**
  The working-tree ban and the `.acstack-banned` guard stay unchanged —
  their rationale is keeping pack content generic for adopters, not
  secrecy, and that holds regardless of history.
- [x] **4.25** ~~Decide and document `/do`'s push default.~~ **Verdict
  (2026-07-29):** `/do` no longer pushes at all. It completes the subtask,
  verifies acceptance, ticks the box, commits **locally**, and reports
  `committed locally — not pushed` with the exact command the user would
  run. The `push` key now governs `/ship` only.

  **Why removal rather than switching the default to `branch-pr`:** a
  commit is local and reversible; a push is outward-facing and is not, so
  bundling them into one unconfirmed step was the actual defect — not
  which push mode was selected. `branch-pr` as the default would also have
  put `gh` on the critical path of the pack's most-used skill, breaking
  the install promise for anyone on GitLab or a local-only repo, and
  PR-per-subtask is self-review for a solo user: you author and merge it
  yourself, which catches nothing. The real recheck already exists one
  level up in `/ship`'s five gates, at feature granularity where it
  belongs.

  **The decisive fact:** `/do` is model-invocable, so an agent can reach
  it without the user typing anything. An unattended `git push` is the one
  step in that sequence that cannot be undone quietly. Tradeoff: the user
  now runs one extra command to publish. Revisit if that friction turns
  out to bite in practice.
- [x] **4.26** *(Done 2026-07-30: requirements split into install-core
  (git + bash 3.2+) and a per-capability optional table naming gh for
  the nine tickets-aware skills, curl for /qa, pg_dump for
  /migrate-check under shared-prod, the project's own stack plus its own
  model API for /eval-run, and shellcheck for contributors — each with
  its honest degradation. A "What the pack writes" table lists every
  path the pack touches, who writes it, and when, including the
  CLAUDE.md rewrite, the AGENTS.md marker blocks, the OFFERED config
  file, and the single machine-local stamp. Closes with what leaves the
  machine: git fetch, gh calls the user initiates, and nothing else.)*
  Correct README's requirements and footprint claims.
  "git and bash 3.2+. Nothing else" is true of install only: tickets mode
  needs `gh` (nine skills), `/qa` needs `curl`, `/migrate-check` defaults
  to `pg_dump` under `db: shared-prod`, and 4.12's eval runner needs a
  model API. Separately, "The three documents" undersells the footprint —
  `/plan seed` also creates LEARNINGS.md, rewrites CLAUDE.md to a pointer,
  edits AGENTS.md, and offers `.claude/acstack.md`. **Acceptance:** a
  reader can predict every file the pack will touch and every binary it
  may invoke, before installing.

> **Process note (2026-07-29):** 4.14, 4.15, 4.17, 4.22–4.26 (this wave)
> and 4.16, 4.18 (wave 4.5) all exist because cross-cutting rules were written as decisions with no task
> owning the work — the multi-product rule, the positive-control rule, the
> commit-format verdict, and the audit findings left loose. Recording a
> decision is not scheduling it. Any future cross-cutting rule added to
> this document must name its carrier task in the same edit (now also
> binding via AGENTS.md).

> **Split decision (2026-07-29).** ~~Wave 4 carries 18 items.~~ Split into
> wave 4 (11 items, launch-blocking) and wave 4.5 (7 items, post-launch).
> *(Counts as of the split. 4.19–4.23 were added afterwards by the second
> audit round; current totals are in the Risk note below.)*
> **The dividing line: wave 4 is "nothing an adopter touches is broken,
> missing, or lying"; wave 4.5 is "the pack is more rigorous and more
> capable."** An item stays in wave 4 only if its absence would mislead a
> stranger on day one — a broken install, a doc that lies, an undiscoverable
> skill, a flagship that dead-ends, a wrong answer delivered confidently, or
> a trust claim the code does not back.
>
> Why each borderline call went the way it did:
> - **4.12 /eval-run stays.** Eval-first is the headline claim; an adopter
>   who runs /eval-spec and finds no way to execute the result has hit a
>   cliff inside the differentiator.
> - **4.14 multi-product stays.** Its absence produces confidently wrong
>   answers rather than a missing feature. Wrong beats absent, badly.
> - **4.15 and 4.17 stay** because 4.7 literally depends on them: the launch
>   checklist requires every guard demonstrated firing and cross-references
>   resolving. Moving them would have forced 4.7 to be weakened to "every
>   guard that happens to exist", which is the asserted-not-demonstrated
>   pattern this wave exists to kill. They are also cheap — six shell greps.
> - **4.10 and 4.11 move**, superseding the 2026-07-29 pull-forward below.
>   New information: wave 4 grew 7 → 18 items after that call. Two extra
>   differentiator skills are worth less than shipping eleven other items on
>   time, and neither is broken-without — they are additive.
> - **4.3 telemetry moves.** "Nothing phones home" is *more* true with no
>   telemetry at all, so its absence weakens no claim.
> - **4.4 `setup --global`/`--hook` moves.** The hook writes to
>   `~/.claude/CLAUDE.md` — the riskiest surface in the pack, and the one
>   most improved by real adopter feedback before it ships.
> - **4.18 moves.** Each gap is a genuine edge case, not a day-one break.
>
> **Task IDs are NOT renumbered.** Wave 4.5 holds 4.3, 4.4, 4.10, 4.11,
> 4.13, 4.16, 4.18 under their original numbers, per the pack's own rule
> that existing tasks are never renumbered (/ticket). Non-contiguous IDs
> within a wave cost less than breaking every cross-reference in this
> document and every reference in the journal.

> ~~**Decision (2026-07-29):** 4.10 and 4.11 pulled into the launch wave.~~
> **Superseded (2026-07-29, same day):** both moved to wave 4.5 by the
> split above. The original reasoning — that both are cheap and
> demonstrably unclaimed by every surveyed pack — still holds and is why
> they sit at the top of wave 4.5 rather than later. What changed is the
> denominator: wave 4 was 7 items when they were pulled in and 18 when the
> split was made.

> **Risk (2026-07-29, revised same day):** the split left wave 4 at 11
> items; two further audit rounds added carriers, taking it to **16**. Those four are cleanup of defects already found, not new
> ambition — but the wave is heavy again and that should be watched rather
> than discovered late.
>
> Cut order if it slips: 4.22 (`--dry-run` output — cosmetic and rarely
> hit), then 4.26 (README requirements — a doc correction, though it is
> the kind that loses trust), then 4.8 (`allowed-tools`, and soften README
> v2's trust claim to match), then 4.9 (referral block — costs
> discoverability, but the README still explains the typed-only skills).
>
> **Do not cut 4.7, 4.12, 4.14, 4.15, 4.17, 4.23, ~~or 4.24~~.**
> *(4.24 declined 2026-07-30 — see its verdict; the clause below about it
> being unfixable after the flip was true but is moot now that the purge
> is declined rather than deferred.)* 4.7 is the
> gate itself; 4.12 protects the headline claim; 4.14 stops confidently
> wrong answers; 4.15 and 4.17 are what make every other check
> trustworthy — this repo has produced **three false passes** (the
> `sk-live` secret regex, check.sh's description guard on its own first
> control, and /design-audit's palette check, whose `\b` matched nothing
> in POSIX ERE) plus one false FAIL (/ship's gate 1 blocking every
> release, which is loud rather than silent and so a different class);
> 4.23 must land before 4.16, or implementing the commit format would
> cement a `T4:` shape nothing emits; and **4.24 is absolute** — the only
> launch item that cannot be fixed after the flip, since history is public
> the moment the repo is. (4.25 is closed: /do no longer pushes.)

## [ ] Wave 4.5 — Post-launch hardening and capability

**Goal:** Everything that makes the pack more rigorous and more capable
without being required for a stranger's first week. Ships as a normal
release after launch, informed by whatever real adopters hit first.

**Exit criterion:** Each item's own acceptance passes; `scripts/check.sh`
clean; the wave's journal entry records which items real adopter feedback
reordered, if any.

> **Why post-launch:** none of these produces a broken install, a doc that
> lies, an undiscoverable skill, or a confidently wrong answer — the four
> failure modes wave 4 exists to prevent. Several are *better* for waiting:
> 4.4 touches the user's global config, and 4.18's degradation paths are
> best specified against edge cases adopters actually report rather than
> ones guessed at.

- [ ] **4.3** Local-only telemetry (`~/.acstack/usage.jsonl`) + /retro
  usage section + human-approved aggregate share flow.
  **Acceptance:** with `telemetry: off` nothing is written under
  `~/.acstack/`; with it on, exactly one JSON line per invocation and no
  network call anywhere in the path — verified by running the full flow
  offline. Nothing transmits without the user's own hand.
- [ ] **4.4** `setup --global` (conduct block into `~/.claude/CLAUDE.md`)
  and `--hook` (SessionStart recall).
  **Acceptance:** `--global` is idempotent and never clobbers hand-written
  content in `~/.claude/CLAUDE.md`; `--hook` is a no-op outside acstack
  projects; both are reversible by `--uninstall`.
  *Note (2026-07-30, survey):* superpowers' `hooks/session-start` — 49
  lines of zero-dependency bash injecting one gateway skill — is the
  working model for `--hook`. Scope question to settle at build: also a
  Stop-hook reminder when the session ends with unjournaled commits
  (claude-mem's Stop concept as a one-line reminder, never a daemon).
- [ ] **4.10** /audit tests — fourth target on the existing skill
  (*originally wave 5; pulled into wave 4 then settled in 4.5 by the split, all 2026-07-29*). Sweeps an existing suite
  for tests that pass without catching: assertion-free and tautological
  tests, mocks stubbing the unit under test, unread snapshots,
  accumulating skips, plus a mutation spot-check — break the production
  code deliberately, confirm something fails. The never-inflate rule
  applied to tests instead of eval scores. Confirmed absent from gstack,
  spec-kit, and BMAD; superpowers has the material only as guidance for
  someone *writing* a test, never as a sweep over a suite that exists.
  **Acceptance:** on a suite seeded with an assertion-free test, a
  tautological assert, and a test that passes against deliberately broken
  code, `/audit tests` names all three; on a clean suite it returns no
  findings. (That seeded suite is this target's positive control, 4.15.)
- [ ] **4.11** /why — decision archaeology (*originally wave 5; settled here by the 2026-07-29 split*). Answers "why is this code like this" from BRIEF
  constraints → dated PLAN decision blocks → JOURNAL entries → git blame,
  in that order, stopping at the first real answer and stating "no
  recorded rationale" when there is none. The payoff for three waves of
  document discipline, and the answer to onboarding a human onto an
  agent-built codebase. Confirmed absent everywhere — BMAD is the proof
  it is non-obvious: it keeps an append-only session memlog and per-epic
  retros and still ships no way to ask them anything.
  **Acceptance:** asked why this repo's hygiene skill is named /health,
  it returns the 2026-07-27 shadowing verdict from PLAN 3.7 with its
  reason; asked about a decision with no record, it says so rather than
  inventing one.
- [ ] **4.13** `/health` row auditing the project's own agent
  instructions — contradictory rules, stale references, project
  instructions conflicting with the installed conduct block. acstack
  manages AGENTS.md and CLAUDE.md but never reviews their quality, which
  is odd for a pack whose thesis is that instructions are the product.
  Small: one check row, not a skill. **Acceptance:** on a repo whose
  AGENTS.md contradicts the installed conduct block, `/health` flags the
  conflict and names both rules.
- [ ] **4.16** Implement the 2026-07-29 commit-format verdict — the
  carrier for a decision recorded as `[x]` while nothing emitted the new
  shape. Edit CONDUCT rule 10, `/do`, `/ship`, and README's
  `subtask-commit-format` row to `task 2.3.2: <description>` (document)
  and `ticket #2: <description>` (tickets). **Acceptance:** no pack file
  still documents `completed task N (…)` or a bare `#N:` subject as the
  current format; wave-2's JOURNAL entry keeps its historical wording.
- [ ] **4.18** Remaining degradation paths and config consistency — every
  place a skill would guess instead of stopping. (Absorbed the former **~~4.21~~**, filed
  2026-07-29 as a near-duplicate of this task in the *other* wave — the
  split line cannot adjudicate one task sitting on both sides of it. That
  ID is retired, not reused.)
  Also from that filing: `/do` step 2 has no path for a task group with no
  `**Acceptance:**` line — it would declare done unverified, the exact rot
  `/triage` and `/plan-review` exist to flag. Every one is a place a
  skill would guess instead of stopping:
  - `/audit eval` — no results file present.
  - `/plan seed` — BRIEF.md already exists (it is a *frozen* document;
    regenerating it is the same defect class as /eval-spec's step 0).
  - `/journal` — which files the commit stages (today it could sweep in
    unrelated work), an empty session, a non-git repo.
  - `/ticket` — document mode assumes PLAN.md exists.
  - `/qa` — where auth credentials come from for gated flows.
  - `/learn` — how it detects it is running inside the acstack repo,
    which currently gates whether promotion is applied or only printed.
  - `/triage`, `/retro`, `/design-audit` — missing PLAN.md, missing
    JOURNAL.md, and a path containing no UI files.
  - `/investigate` — state the verdict up front; root cause currently
    lands at step 5 with no lede.
  - *Prior art (2026-07-30, third pass):* impeccable ships a
    `reference/degraded/` directory — separate documented paths for
    asset-producer, documenter, finish-reviewer, and manual-edit-applier
    — i.e. degradation treated as its own first-class surface rather
    than a clause inside each skill. Worth reading before writing this
    item's paths; the shape may be better than what this task assumes.
  - `/resume` — two gaps from its first real cold start (2026-07-29, the
    4.7 item 10 test, run on this repo). (a) The unjournaled-range step
    matches the literal `Journal <date>: <summary>` subject, so a
    multi-entry day (`Journal 2026-07-29 (3rd): …`) makes it count
    journal commits as unjournaled — six instead of the true one on this
    repo; prefix-match the subject or document the suffix convention.
    (b) A next-task with no `**Acceptance:**` line has no stated path —
    the sibling of `/do`'s gap above, and true of 4.1, 4.2, and 4.5
    today, so it is the first thing a wave-4 `/resume` hits.
  - Config: README lists `journal-commit-format` for /journal and /retro,
    but /resume also reads it and /retro hardcodes the format instead;
    `test-command` is listed for /ship, which never names it (only
    `references/ship-gates.md` does); `## Collaborators` is used by /plan
    and documented nowhere.

  **Acceptance:** for each, the precondition is removed and the skill
  names what is missing and stops, rather than proceeding on a guess.

- [ ] **4.19** /refactor — behavior-preserving cleanup with proof. The rule
  is that the test suite is run and green BEFORE the refactor and green
  again after, with the same test count — a suite that shrinks during a
  refactor is the finding, not a detail. Scope stated up front, no
  behavior changes smuggled in, and a stop if the suite is too thin to
  detect a behavior change at all (in which case it names what to test
  first). Pairs with 4.10 `/audit tests`, which is what tells you whether
  the green is worth anything — both sit in this wave for that reason.
  **Placed here, not in wave 5:** that wave's exit criterion is "none of
  them can write", and a refactor skill writes code by definition. Caught
  on the same day as the /retro read-only misclassification, and the same
  error — asserting a property of a set without checking each member. **Acceptance:** on a repo with a passing
  suite, a refactor that silently drops a test or changes behavior is
  caught and reported rather than committed.
- [ ] **4.27** `references/ai-tells.md` for /design-audit — the 2026-07-30
  survey's biggest prize. One sub-500-line, zero-asset reference file
  phrased entirely as findable violations: impeccable's 47 detector rule
  IDs reduced to one-line grep signatures (purple/violet gradient
  palettes incl. Tailwind `from-purple-*`, gradient text,
  kicker/eyebrow-above-heading, numbered-section labels, nested cards,
  icon-tile grids, em-dash overuse, gray-on-color, pulsing dots, skipped
  headings); taste-skill §9's content tells (generic fake names,
  `99.99%`-shaped numbers, Acme/Nexus brand filler, Elevate/Seamless
  filler verbs, version-label eyebrows, scroll cues, fake
  div-screenshots); emil's motion bounds as a short appendix (`ease-in`
  on UI transitions, `transition: all`, `scale(0)` entrances, durations
  >300ms, animating width/height/top/left, missing
  `prefers-reduced-motion`); and the four-repo shared craft floor
  (contrast 4.5:1 body / 3:1 large, no emoji-as-icons, no
  placeholder-as-label). Findings severity-ordered, accessibility and
  honesty first. Config: a pack-default `banned-palette:` hex list
  (taste-skill's enumerated bans), overridable per project. Rule ideas
  re-expressed, never text copied; a credits line names the three
  sources. **Acceptance:** `fixtures/design-audit/` gains one seed per
  new rule class and every documented grep catches its seed
  (controls.sh, per 4.15); clean tree stays quiet.
  **Interaction-feel additions (2026-07-30, second pass — the first
  ledger MISSED emil's `apple-design` skill, 282 lines, because the
  reader summarized the repo by its motion rules and never opened it).**
  These are findable violations of *feel*, not looks: a click handler
  with no `:active`/pressed state (feedback owed on pointer-DOWN, not
  release); `transition:`/`@keyframes` driving a draggable or
  gesture-driven element (neither can be grabbed and reversed mid-flight
  — the interruptibility rule); animation starting from a target rather
  than the current presentation value (visible jump on interrupt);
  `backdrop-filter` with no `prefers-reduced-transparency` fallback;
  two nested `backdrop-filter` surfaces (stacked translucency destroys
  legibility); a hard 1px divider under sticky chrome where a scroll
  edge effect belongs; enter/exit paths that disagree (in-from-right,
  out-the-bottom); popovers with `transform-origin: center` instead of
  their trigger.
  **Edits:** NEW `skills/design-audit/references/ai-tells.md`;
  `skills/design-audit/SKILL.md` (cite it, severity ordering);
  `skills/design-audit/references/design-conventions.md` (point at it,
  no duplication — 4.17.4's citation rule); `templates/acstack.md` +
  README config table (`banned-palette`); `fixtures/design-audit/`.
- [ ] **4.28** Skill-hygiene rules from the 2026-07-30 survey — five
  small skill edits, one carrier: /audit gains an explicit do-NOT-flag
  blocklist (pre-existing issues, correct-but-looks-wrong, pedantic
  nitpicks, linter-catchable style, lint-silenced lines) and a
  does-this-target-even-need-the-pass triage opener; /qa gains the same
  triage opener; /secure treats an inline comment justifying a risk as
  demoting the finding to worth-hardening (never silently dropping it);
  /ship's PR body adopts one-comment-per-issue and
  suggestion-only-when-it-fully-fixes; /do's acceptance step gains the
  claim → requires → not-sufficient evidence table. **Acceptance:** each
  rule present in its skill's consumed text; /audit run on a diff whose
  only issues are pre-existing names the blocklist reason instead of
  reporting findings.
  **Edits:** `skills/audit/SKILL.md` (+ `references/code-report-template.md`
  for the blocklist), `skills/qa/SKILL.md`, `skills/secure/SKILL.md`,
  `skills/ship/references/ship-gates.md`, `skills/do/SKILL.md`. Five
  skills, one commit — they are one rule set, and splitting them makes
  the pack inconsistent between commits.
- [ ] **4.32** Backlog root-cause clustering for /triage (third pass,
  2026-07-30). claude-mem's `oh-my-issues` does something /triage does
  not and no surveyed pack does either: cluster an issue backlog **by
  root cause** into a small set of parent items, redirect the children
  with a standardized comment, and leave the tree navigable. /triage
  today finds stale items, duplicate PAIRS, and missing acceptance —
  all local comparisons. Clustering is the global one: twelve issues
  that are one cause is a finding no pairwise dupe check can see.
  Report-first and approval-gated like the rest of /triage; document
  mode clusters PLAN tasks under a parent instead of filing issues.
  **Acceptance:** on a seeded backlog carrying eight issues with three
  underlying causes, /triage names the three clusters with their
  evidence and proposes parents — and proposes nothing when every item
  is genuinely independent.
- [ ] **4.29** Journal-retrieval discipline for /resume and /retro —
  claude-mem's search→filter→fetch rule applied to repo-owned markdown:
  read headings and the TL;DR first, filter entries by the window or
  question, fetch full entry text only for matches; never a whole-file
  read once JOURNAL.md exceeds a stated size. **Acceptance:** both
  skills document the rule and /resume's read step names it.
  **Edits:** `skills/resume/SKILL.md`, `skills/retro/SKILL.md`
  (+ `references/retro-sections.md` if the window logic moves there).
  *Prior art (2026-07-30, third pass):* claude-mem's `smart-explore`
  applies the same principle to CODE — structural/AST search instead of
  reading whole files — which is the /investigate and /audit analogue of
  this rule. Noted, not carried: it needs tree-sitter, a dependency the
  pack declines; the portable half is "search structurally, read
  selectively", which those skills already imply and this task states.
- [ ] **4.31** /secure's injection surface is a third of a surface —
  measured 2026-07-30 against security-guidance's 25 frozen rule IDs
  (`plugins/security-guidance/hooks/patterns.py:264`). /secure's
  `references/security-surfaces.md` names `innerHTML`,
  `dangerouslySetInnerHTML`, and `subprocess`; it has **zero** patterns
  for: unsafe deserialization (`pickle`/`cPickle`/`cloudpickle`/`dill`/
  `marshal`/`shelve`/`joblib`/`pandas.read_pickle`/numpy
  `allow_pickle=True`), `yaml.load`/`unsafe_load`, `torch.load`
  (defaults to `weights_only=False`), crypto misuse (AES-ECB,
  `createCipher` without IV), disabled TLS verification
  (`verify=False`, `NODE_TLS_REJECT_UNAUTHORIZED=0`), unsafe XML parse
  (XXE), `document.write`/`outerHTML`/`insertAdjacentHTML` sinks,
  `<script src>` without SRI, `eval`/`new Function` injection,
  `child_process` exec, and GitHub Actions workflow injection via
  `${{ github.event.* }}` in `run:`. Every one is a `git grep` line,
  which is the point: this is the cheapest large increase in real
  coverage available to the pack, and a security skill that reports
  clean while missing `pickle.load` on untrusted input is the false-pass
  class in its most expensive form. Deserialization, TLS, and crypto
  become their own numbered surface (5); the missing sinks join surface
  3. **Acceptance:** `fixtures/secure/` gains a seed per class and
  controls.sh proves every new grep catches it (per 4.15) — and each
  pattern is written in POSIX ERE and checked by section 3b, since `\b`
  and `\s` are exactly how this file broke before.
  **Edits:** `skills/secure/references/security-surfaces.md` (surface 5
  + additions to 3), `fixtures/secure/`, and — **the set-claim trap,
  verified 2026-07-30** — `skills/secure/SKILL.md` says "four surfaces"
  in BOTH its body heading (`:68`) and its **frontmatter description**
  (`:3`), which is the form that ships into the live skill listing; plus
  README's /secure row enumerates the four without counting them. A
  fifth surface that updates only the reference file leaves the pack
  claiming four while sweeping five — the exact set-assertion class
  AGENTS.md names. All four sites change together, and the description
  is re-checked in its PARSED form, not re-read.
- [ ] **4.30** /design — the generative lane, scoped to
  **production-grade, not style-matching** (user ruling 2026-07-30: it
  must be able to produce any production-level UI, not a copy of one
  house style). The four surveyed design skills are almost entirely
  about *looks* — palette, type, anti-slop — and that is not where
  AI-generated UI actually fails. It fails on everything past the happy
  path, which is exactly acstack's territory. So the skill's spine is a
  **production-readiness set that every interactive surface must
  answer**, each item a thing a demo skips and a shipped product cannot:
  1. **States, all of them** — default, hover, focus-visible, active,
     disabled, loading, empty, error, success, and the optimistic/
     rollback path where a write can fail. An interface with only its
     happy state is a mockup.
  2. **Real content** — longest and shortest plausible values, missing
     avatars, unbounded strings, zero/one/many rows, RTL if claimed.
     Lorem hides every layout bug that matters.
  3. **Responsive behavior** — what reflows, what truncates, what
     scrolls; touch targets ≥44px; no horizontal body scroll.
  4. **Accessibility floor** — keyboard path through every flow, visible
     focus, contrast 4.5:1 body / 3:1 large, labels associated,
     reduced-motion honored.
  5. **Interaction feel** — `references/interaction-feel.md` below.
  6. **Theming** — light and dark both designed, not inverted; tokens,
     not raw hex.
  7. **Performance-shaped choices** — compositor-friendly properties,
     no layout thrash on interaction.
  8. **UX writing** — button verbs, error messages that say what to do
     next, empty states that teach (frontend-design's section).
  A design that cannot answer all eight is reported as incomplete with
  the gaps named — the honest-scope discipline applied to UI. Style
  (which look) stays the user's call via the dials; production-readiness
  is not optional.

  **Prior art recovered on the third pass (2026-07-30), all missed by
  the first reader:** impeccable's `reference/harden.md` (**336 lines**)
  is this item's spine already written — "designs that only work with
  perfect data aren't production-ready", worked against inputs, errors,
  languages, and network conditions; read it before drafting items 1–3
  rather than re-deriving them. `reference/delight.md` (70) draws the
  line this task needs on "magic": delight is product character revealed
  through a useful interaction, **not a layer of generic whimsy** —
  which is what keeps item 5 from becoming decoration. ui-ux-pro-max's
  `design-system` skill (244) supplies the token architecture for the
  token-first step: three layers, primitive → semantic → component.
  **Emit tokens in DTCG** (Design Tokens Community Group format) rather
  than inventing a shape — found 2026-07-30 via `uxKero/anydesign`,
  which uses it. The standard is the steal, not that skill (148 stars,
  and its Figma/image ingestion is a different job); DTCG costs nothing,
  is machine-readable by real tooling, and means /design's output can
  leave the pack without a translation step.
  Roster 38 → 39;
  NEW skill, the one place the 2026-07-30 survey showed demand acstack
  answers nowhere: four repos, ~★250k combined). Token-system-first
  two-pass process (4–6 named values, ≥2 type roles, wireframe before
  code, one signature element per Anthropic's frontend-design);
  self-critique against the named AI-default looks before coding;
  variance/motion/density dials under a `## design` config section
  (taste-skill's model, made config not prose); Before/After/Why output
  table (emil's shape); quality floor: responsive, focus-visible,
  reduced-motion. Complements /design-audit exactly as emil's
  review/improve pair splits detective from generative — /design-audit
  stays pure detective. **Acceptance:** on a seeded generic page,
  /design produces a token system and a critique naming which
  AI-default look it avoided; **every one of the eight
  production-readiness items above is answered or explicitly named as a
  gap** (a surface with no error state is reported, never silently
  omitted); and /design-audit + ai-tells (4.27) run on /design's output
  returns no findings — the pairing is this skill's positive control.
  Second control, the one that proves production-grade rather than
  pretty: a seeded flow whose write can fail must come back with its
  error and rollback states designed, unprompted.
  **`references/interaction-feel.md` (2026-07-30, second pass).** The
  generative half of the same miss, and the part with no acstack
  equivalent anywhere: *how an interface behaves under the hand*, which
  is what people mean by "feels like magic" and by naming a material
  ("liquid glass") to describe a behavior. Sourced from emil's
  `apple-design` (itself distilled from Apple's *Designing Fluid
  Interfaces*), re-expressed and credited:
  **response** (feedback on pointer-down, never on release; continuous
  during the gesture, not only at its end); **direct manipulation**
  (1:1 tracking, respect the grab offset, `setPointerCapture`);
  **interruptibility** — named there as the single most important
  principle (animate from the presentation value, never lock input,
  blend velocity on reversal, decompose 2D into independent X/Y
  springs); **springs over durations** for anything touchable, in
  damping/response terms with the shipped values (move 1.0/0.4,
  rotation 0.8/0.4, drawer 0.8/0.3) and bounce ONLY after a
  momentum-carrying gesture; **velocity handoff** at gesture end;
  **momentum projection** using the exponential-decay form Apple ships,
  explicitly NOT the textbook `v²/2a`; **spatial consistency**
  (symmetric enter/exit, `transform-origin` on the trigger);
  **rubber-banding** at boundaries; **materials** (translucency encodes
  hierarchy, never stack light on light, bigger surfaces read thicker,
  vibrancy for legibility, scroll edge effects over hard dividers,
  "materialize don't just fade" — animate blur radius and scale
  together); **multimodal** (visual/sound/haptic on the same frame);
  and **reduced-motion/transparency/contrast** as three independent
  signals. Framework-agnostic: CSS, Pointer Events, and
  `requestAnimationFrame` are the vocabulary; a spring library is named
  as an option, never a dependency. Its detective counterpart is 4.27's
  interaction-feel block — same rule list, both directions, per the
  Wave B one-source principle.
  **Edits:** NEW `skills/design/SKILL.md` (+ references); README skills
  table row and `templates/acstack.md` `## design` section (dials);
  `skills/design-audit/SKILL.md` adjacency line (they are a pair);
  `./setup` needs no change (it globs `skills/*/`). **Depends on 4.27**
  — its acceptance runs ai-tells against /design's output, so 4.27
  lands first.

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
- [ ] **5.5** /upgrade — dependency *upgrade* pre-flight, distinct from
  5.1's *addition* review. Upgrading is a breaking-change problem, not a
  justification problem: read the changelog between the pinned and target
  versions, classify each change additive vs breaking against the call
  sites this repo actually has, flag transitive bumps, and end in GO/NO-GO
  with the rollback pin named. Same shape as `/migrate-check`, applied to
  the supply chain. **Acceptance:** on a repo pinned to an older major of
  a dependency with a known breaking change, names that change and the
  call sites it affects, and returns NO-GO without a migration note.
> **Decision (2026-07-29):** /verify folded into this wave rather than
> leaving /verify alone under a theme that had departed. Its two companions
> (/audit tests, /why) moved out — first to wave 4, then to wave 4.5 in the
> split — and "honest measurement" went with them; what remains here is a
> gate, which is what this wave is. Tradeoff: the wave now
> mixes pre-change gates with a post-change one. Revisit if /verify grows
> enough to stand alone.

## [ ] Wave 6 — The review board

**Goal:** Multi-perspective review — the team — expressed as lenses, not
personas. Each reads a named artifact, applies a checklist, and returns a
verdict. No first names, no roleplay, no "as your architect I would say".

**Exit criterion:** Each **lens** (6.1–6.5) returns a verdict on a seeded
project carrying its specific defect class (its positive control, per the
cross-cutting rule); `/board` (6.6) convenes the relevant ones and
consolidates without averaging dissent away; `/skill` (6.7) produces a
SKILL.md that passes check.sh. 6.6 and 6.7 are deliberately NOT lenses —
6.7 writes files — so the per-lens criterion and the open-slot rule below
apply to 6.1–6.5 only. Stated explicitly because the same set-assertion
error already produced two bugs this wave-planning round.

> **Cross-cutting rule for every lens — the open slot (2026-07-29).**
> Each lens ends with one step that is explicitly NOT on its checklist:
> "what is wrong here that none of the above would catch?" Rationale: a
> checklist can only find what it enumerates, so lenses have a blind spot
> at the edge of their own list — the one place persona-style prompting
> genuinely outperforms them. The open slot recovers most of that
> exploratory value for one line per skill and zero runtime cost. It is
> NOT redundant with `/board`: `/board` decorrelates *across* checklists,
> but every finding still originates from some checklist, so five lenses
> still cannot see what none of them lists. Build it into 6.1 onward
> rather than retrofitting.

- [ ] **6.1** /architect — the system's shape as built: module
  boundaries, coupling, which direction dependencies point, abstractions
  that do not earn their keep, logic that leaked into the wrong layer.
  `/plan-review` covers structure *before* code and BRIEF carries the
  `## Architecture Decision: X, NOT Y` line; nothing revisits it after,
  which is exactly where drift accumulates when agents write fast.
- [ ] **6.2** /a11y — **static tier only** (see B.3). Reliably checkable
  without rendering: missing alt text, absent or unassociated form labels,
  ARIA misuse, heading-order breaks, positive tabindex, and
  reduced-motion handling declared in CSS. **Focus order, computed roles,
  and real contrast ratios require a rendered DOM and are OUT of scope
  here** — the skill's scope line must say so rather than implying full
  WCAG coverage. Shipping an accessibility check that overstates its
  reach is worse than shipping none.
  `/design-audit` covers palette, honest labels, slop, and client-facing
  language — all a different axis. Absent from all four surveyed packs.
  *Note (2026-07-30, survey):* spec inputs from ui-ux-pro-max's
  guideline data, all statically findable: placeholder-only labels,
  `user-scalable=no`, focus-ring removal without replacement, missing
  viewport meta, sub-44px touch targets, base font below 16px.
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
  builder's rationalizations. Proven in practice twice: wave 3's
  context-free review returned 9 findings the author's own re-read had
  not produced, and the 2026-07-29 audits found a *shipped* bug — /ship's
  YAML-truncated description — that the wave-3 review had missed by
  reading the file instead of the parsed result. Prior art: gstack
  `/autoplan`, BMAD's parallel review subagents. Build LAST — it is
  worthless until 6.1–6.5 exist.

  > **Attribution correction (2026-07-29):** this item previously
  > credited the independent review with finding the `sk-live-`
  > secret-regex gap. Git says otherwise — `d709d70` is titled
  > "(shakedown finding)" and `dfe291d` carries the review's findings.
  > The shakedown found it by running the check against a planted key;
  > the review never did. The argument for context-free subagents stands
  > on its own evidence above, but it does not stand on that example, and
  > a claim resting on the wrong provenance is the kind of thing /board
  > itself is supposed to catch.

  > **Design warnings (2026-07-29) — do not build this naively as "spawn
  > five agents."** The fan-out is trivial; these are the hard parts.
  > (a) **Consolidation** — merging N reports into one verdict without
  > losing the single sharp dissent. If it over-merges it drops findings;
  > if it does not merge, the user gets five reports and no verdict,
  > which is worse than one good review. (b) **Routing** — running all
  > lenses on a typo fix trains people to skip the skill; skipping /a11y
  > on a UI change makes it worse than useless. (c) **False confidence
  > is the failure mode** — "the board found no blockers" reads as far
  > more authoritative than one reviewer, while being only as good as the
  > union of its checklists. That is an eval score flattered by a narrow
  > golden set, in review clothing. The report MUST state which lenses
  > ran, which did not, and why. (d) **Volume defeats attention** — apply
  > /secure's confidence-gate discipline to the consolidated report.

  > **Prior art for warning (a) — consolidation (2026-07-30, survey).**
  > Anthropic's code-review plugin ships a working answer to the problem
  > this item calls hardest: after the review agents return, **each
  > finding gets its own validation subagent, and findings that fail
  > validation are dropped** rather than merged
  > (`plugins/code-review/commands/code-review.md`, steps 5–6). That
  > inverts the naive design — consolidation stops being "merge N
  > reports" (which loses the single sharp dissent) and becomes
  > "validate each finding independently, keep what survives". A lone
  > dissent that validates survives on its own merits; a
  > confidently-repeated finding that fails validation dies despite
  > repetition. Adopt the mechanism, NOT its per-step model
  > choreography (haiku/sonnet/opus by name couples the skill to a model
  > lineup). Their false-positive blocklist rides 4.28 into /audit and
  > applies here too. Fan-out stays inside the 2–4 agent budget.

  > **Second prior art (2026-07-30, third pass).** impeccable's
  > `reference/critique.md` (788 lines) runs **two independent
  > assessments of one resolved target, then synthesizes** — the board
  > pattern applied to design, and evidence the shape generalizes past
  > code review. Two useful specifics: it resolves ONE stable target
  > first (this wave's resolve-one-document-set rule, applied to a
  > review subject), and it separates the chat deliverable from a
  > persisted snapshot used as a backlog — worth considering for
  > /board's output, where a consolidated verdict and a durable
  > findings record are genuinely different artifacts.
- [ ] **6.7** /skill — turn a repeated workflow into a compliant
  SKILL.md: principles block verbatim, `Adjacent skills:` routing line,
  description scoped to explicit intent, under the line budget, passing
  check.sh, with its positive-control fixture. acstack's thesis is that
  discipline should be written down and version-controlled; giving
  adopters no way to encode *theirs* is the difference between extending
  the pack and forking it. Prior art: obra/superpowers `writing-skills`.
  *Note (2026-07-30, survey):* the spec adopts skill-behavior testing —
  RED-GREEN for skills (run the scenario and document the agent's exact
  rationalizations BEFORE the skill exists; superpowers
  `writing-skills`), paired with-skill/baseline eval runs (anthropics
  `skill-creator`), and an automated compliance harness modeled on
  superpowers' `tests/run-skill-tests.sh`. A /skill-produced SKILL.md
  ships with its behavioral control; CONTRIBUTING (4.6) states the rule
  for pack contributions. This is the prove-the-check-fails rule
  pointed at skills themselves.
  *Second note (2026-07-30, directory sweep):* `yusufkaraaslan/Skill_Seekers`
  (★14.6k) generates skills from documentation sites, repos, and PDFs.
  The **idea** is worth /skill's consideration — a skill scaffolded from
  a project's own docs beats one written from memory — but the
  implementation is declined: a Python package on PyPI with a 40-tool
  MCP server is the opposite of this pack's constitution. If /skill ever
  ingests docs, it does so by reading files that already exist.

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
  *Note (2026-07-30, survey):* anthropics/skills `doc-coauthoring`
  (375 lines) is the closest prior art found — its spine is
  context-transfer-first (interview before drafting), iterate on
  structure before prose, then **verify the doc works for a reader**
  rather than declaring it done. That last step is the acstack-shaped
  one: a doc's acceptance is a reader completing a task with it, which
  is what makes /document gate-able instead of vibes.
- [ ] **7.4** /cost — what a feature cost in tokens and infrastructure.
  Depends on 4.3's telemetry pipe.

## [ ] Wave B (Deferred) — browser layer (unscheduled, demand-triggered)

**Trigger, not a date.** The browser probe was deferred 2026-07-27 to
first real need (a UI whose flows cannot be exercised over http). This
section records what that decision *also* deferred, so the dependency
chain is not re-derived when the trigger fires. Nothing here is scheduled;
all of it unblocks together.

The probe seam already shipped ready for this: `/qa` defines reach / act /
observe transport-agnostically, and the report skeleton is identical
across modes, so the browser mode is a second implementation of an
existing contract — not a redesign.

- [ ] **B.1** /qa browser mode — Playwright behind the existing probe
  contract (reach = page load, act = one user action, observe = resulting
  DOM / visible text / console errors). Only `references/probe-layer.md`
  grows; SKILL.md gains a mode name and nothing else. **This is the item
  that carries the runtime dependency** — everything below is gated on it.
  *Note (2026-07-30, survey):* anthropics/skills `webapp-testing` (95
  lines) is a working reference implementation of exactly this contract
  on Playwright — page load, user action, screenshot, console logs — at
  a line count that fits acstack's budget. Read it at trigger time
  rather than designing the probe from scratch.
- [ ] **B.2** /design-audit rendered mode — deferred with the same verdict
  in `docs/wave-3-specs.md`. Static analysis cannot see computed layout,
  actual contrast against rendered backgrounds, or overflow.
- [ ] **B.3** /a11y rendered tier (6.2 ships static-only). Static catches
  missing alt text, absent labels, and some ARIA misuse; **focus order,
  computed roles, real contrast ratios, and keyboard traps require a
  rendered DOM.** Wave 6's /a11y must therefore state its static ceiling
  honestly in its scope line rather than implying full coverage.
- [ ] **B.4** /perf — recorded here as a **deliberate omission, not an
  oversight** (same treatment as the browser probe itself). Page-level
  performance needs the browser; backend performance needs load tooling
  neither the pack nor its zero-dependency constraint provides today.
  gstack covers this with `/benchmark` on a Bun runtime — a road acstack
  declines at launch.
- [ ] **B.5** Visual regression — screenshot capture and diffing across
  runs. Cheapest capability to add once B.1 exists, and the one that most
  needs a stated policy on where images live (repo-owned memory says the
  repo; image bloat says otherwise — decide at trigger time).

> **Evidence note (2026-07-30, survey):** pbakaus/impeccable runs ONE
> shared rule list through both a static analysis path and a rendered
> (bundled-browser) path — direct proof this wave's static-now/
> rendered-later split works with a single rule source. When B fires,
> 4.27's `ai-tells.md` is that source: the rendered tier re-checks the
> same rules against computed styles rather than growing a second list.
> Its PostToolUse run-the-detector-after-UI-edits hook is a candidate
> trigger mechanism for this layer.

> **Constraint check (2026-07-29):** the browser layer is the largest
> break with "zero runtime dependencies beyond git + bash" — though not the
> first: tickets mode already requires `gh` (shipped in wave 2), and 4.12's
> eval runner requires calling a model API. The pattern each time is that
> the dependency is OPTIONAL and the skill degrades honestly without it. When the trigger fires, that cross-cutting constraint needs an
> explicit amendment — most likely "the browser layer is optional and
> every skill degrades to its static/http tier without it," which is what
> `/qa`'s honest-decline path already models. Do not let it land by
> accident.

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
  modes, so adding browser later stays additive. That is the founding
  design doc's no-architectural-penalty bet (locked decision 8; the doc
  lives under `~/.claude/plans/`, outside this repo), restated in
  `docs/wave-3-specs.md`.
- [x] **GitHub remote (NEW 2026-07-27).** ~~Private `AaravChadha/acstack`
  creation awaits explicit user go.~~ **Verdict (2026-07-27):** created
  private and pushed — `main` tracks `origin/main`, all 31 commits up.
  Public flip stays gated on the wave-4 launch checklist (4.7).
