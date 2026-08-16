# PLAN.md — acstack

> **Purpose of this document.** The operative roadmap for the pack itself:
> what ships in each wave and how we know a wave is done. Waves 1–3 are
> built (19 skills; wave 4 added /eval-run for **20**); detailed
> per-skill specs for later waves get written
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
> - **Windows is copy-install only.** `setup` symlinks; on Windows the
>   `skills/*` directories are copied by hand, so pack edits need a
>   re-copy. Native symlink support is **not scheduled** — recorded as a
>   declined item rather than a roadmap promise (README said "roadmap
>   item" with no task owning it until 2026-07-31).
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
| [x] 4 — Distribution + launch | A stranger can install, trust, and update it | Fresh-machine install test passes; launch checklist all green; **flipped public 2026-08-03** |
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

## [x] Wave 4 — Distribution + launch

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
  block, canonical in README, byte-identical across all skills (19 at
  the time, 20 once /eval-run landed),
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
- [x] **4.5** *(Closed 2026-07-31 — both acceptance halves demonstrated.
  **Clean push:** run `30562185603` green on `main`, log carrying the
  honest `check.sh: no failures, but 1 check(s) SKIPPED — coverage is
  incomplete` line (banned-name list is untracked by design) and
  `passed=58 failed=0` from the matrix. **Seeded violation:** PR #1 on
  branch `test/ci-seeded-violation` removed /do's `Adjacent skills:`
  line; run `30581653375`, event `pull_request`, **conclusion failure**,
  log `FAIL routing: skills/do/SKILL.md has no 'Adjacent skills:' line`,
  exit code 1, and `gh pr checks` reporting `check  fail`. PR closed
  unmerged and the branch deleted from both remotes — only `main`
  remains. CI has now caught two real defects this machine structurally
  could not, both shellcheck findings (SC2164, SC2222), since shellcheck
  is not installed locally.)*
  CI: GitHub Action running check.sh + shellcheck on every PR.
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
- [x] **4.6** *(Done 2026-07-30: PRINCIPLES.md — ten principles, each
  with the defect that produced it and the numbers where they exist;
  docs/ARCHITECTURE.md — four layers, all 11 preamble lines documented
  individually (verified: preamble line count == documented count), the
  bin/ contracts, the three guard layers AND an explicit statement of
  what guards cannot prove; CONTRIBUTING.md — matrix-first rule with the
  0/25/60% convergence numbers as its reason, the eight-point skill
  checklist, behavioral red-green, and the four verification rules;
  README v2 — a see-it-work walkthrough, both shadowing disclosures
  (/plan vs plan mode with Shift+Tab, /resume vs session resume with
  claude -r, plus the typed-only and VS Code autocomplete notes), and
  the new documents in the layout block.)*
  PRINCIPLES.md, docs/ARCHITECTURE.md (every preamble line
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
- [x] **4.7** *(All **ten** items demonstrated 2026-07-31 — evidence
  ledger in the JOURNAL entry of the same date. **Closed 2026-08-03:
  after the §13 allowlist falsification round and CI green (run
  30765510782), the repo was flipped public via `gh repo edit
  --visibility public` — the last clause "only then flip public" is
  done.**)*
  Launch checklist — every line must be *demonstrated*, not
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
  carries evidence for all **ten** — a command and its output, or a named
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
  added to every built document-reading skill — **16** after the
  same-day review, which caught that /eval-spec and /investigate both
  read AND write the set (enumerated: audit, challenge, do, eval-run,
  eval-spec, health, investigate, journal, learn, plan, plan-review,
  resume, retro, ship, ticket, triage; /why is unbuilt task 4.11.
  /design-audit, /migrate-check, /qa and /secure correctly lack it —
  they resolve no document set),
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

- [x] **4.31** *(Done 2026-07-31: surface 4 added — unsafe
  deserialization (pickle family, cloudpickle/dill/marshal/shelve/joblib,
  read_pickle, numpy allow_pickle, yaml.load/unsafe_load, torch.load),
  crypto misuse (ECB, createCipher without IV), disabled transport
  verification (verify=False, rejectUnauthorized, NODE_TLS_REJECT_
  UNAUTHORIZED, CURLOPT_SSL_VERIFYPEER, _create_unverified), and XXE;
  surface 3 gained document.write/outerHTML/insertAdjacentHTML, dynamic
  eval, the exec family, missing SRI, and GitHub Actions run: injection.
  Nine fixture files with nine controls in scripts/controls.sh, all
  demonstrated FAILING before the patterns existed. Each finding carries
  a trust-boundary caveat so a repo-shipped pickle load is not inflated
  into a finding. **The set-claim trap was real and all three sites
  changed together:** the body heading, the frontmatter description (the
  consumed form — re-parsed, not re-read), and README's row all said
  four surfaces. Two extraction bugs surfaced en route, both from quotes
  inside documented patterns; the eval pattern was rewritten quote-free
  rather than working around it.)*
  /secure's injection surface is a third of a surface —
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

> **Moved into wave 4 (2026-07-31, user verdict).** Filed in wave 4.5;
> promoted because it fails wave 4's own dividing line — an adopter who
> runs `/secure` over a codebase using `pickle.load` on untrusted input
> gets a clean report. That is a confidently wrong answer from the
> pack's security skill, not a missing feature, and wrong beats absent.
> Cheap, too: every gap is one `git grep` line plus a fixture seed.

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

> **Risk (2026-07-29, revised; updated 2026-07-31; CLOSED 2026-08-06):**
> the split left wave 4 at 11 items; two audit rounds took it to **16**,
> and 4.31 was promoted from wave 4.5 on 2026-07-31, making **17**.
> ~~Of which 14 are done and **3 remain** (4.5, 4.7, 4.31). Those four
> are cleanup of defects already found, not new ambition — but the wave
> is heavy again and that should be watched rather than discovered
> late.~~ **Closed 2026-08-06: all 17 done**, counted by enumerating the
> wave rather than by adjusting the previous figure. That enumeration
> also settled an off-by-one the superseded text carried from 07-31 — it
> said "**3 remain**" and then "Those **four**" in the next clause, and
> neither number was re-derived when the note was revised. The growth
> itself was cleanup of defects already found, not new ambition; the
> lesson that a wave can get heavy twice without anyone noticing stands,
> and is why the counts here are now enumerated on every touch.
>
> Cut order if it slips: 4.22 (`--dry-run` output — cosmetic and rarely
> hit), then 4.26 (README requirements — a doc correction, though it is
> the kind that loses trust), then 4.8 (`allowed-tools`, and soften README
> v2's trust claim to match), then 4.9 (referral block — costs
> discoverability, but the README still explains the typed-only skills).
>
> **Do not cut 4.7, 4.12, 4.14, 4.15, 4.17, 4.23, 4.31, ~~or 4.24~~.**
> *(4.31 added 2026-07-31: a security skill that reports clean on
> `pickle.load` is the confidently-wrong class, same reason as 4.14.)*
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
  *Note (2026-08-06, survey):* a second and smaller working model —
  i-have-adhd's `hooks/always-on.sh`, 25 lines of POSIX sh (not bash, so
  it runs wherever Claude Code runs a command hook). Five properties
  worth copying over the 49-line version: opt-in gated on a flag file
  existing, so the hook is inert until the user creates it; every failure
  path exits 0, so it can never block session start; `SessionStart`
  matched on `startup|resume|clear|compact` rather than startup alone;
  the skill path resolved from `$0` instead of a trusted env var; and the
  injected text names its own off-switch. Its flag file is also the
  contamination source 4.45 exists to stop — the hook and the warning
  about the hook ship together, which is the pairing to imitate.
- [x] **4.10** *(Done 2026-08-03: fourth /audit target. references/test-audit-rules.md covers five classes — assertion-free tests, tautological assertions, mocks stubbing the unit under test, unread snapshots + accumulating skips, and the mutation spot-check (the only one that PROVES rather than suggests, with a revert-and-verify rule). The set-claim trap was live and all four sites changed together: the frontmatter description (three → four targets, verified re-parsed in the live listing), argument-hint, body, and README's row. fixtures/audit-tests/ seeds all three acceptance defects and was demonstrated green under a mutation returning 0.0 instead of 20.0 — a confirmed coverage hole. **Two defects caught in itself:** the fixture could not RUN (bare `def test_` needs pytest, which the pack does not ship → rewritten on stdlib unittest, since a fixture that cannot execute proves nothing), and my own documented pattern used a backreference — an INVALID ESCAPE in POSIX ERE, so the grep errors out and matches NOTHING, the same class as \b. Its positive control caught it on the first run; §3b guarded \b and \s but not backreferences, so the guard was extended and shown failing first. Matrix 79 → 81.)* /audit tests — fourth target on the existing skill
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
- [x] **4.11** *(Done 2026-08-03 — the 21st skill. Search order BRIEF → dated PLAN verdicts → JOURNAL → git history, stop at the first REAL answer (one stating a reason, not just what changed), never invent a rationale, never infer intent from the implementation. Both acceptance halves demonstrated: the order finds PLAN 3.7's 2026-07-27 /health verdict WITH its reason at PLAN.md:326, and a decision with no record returns empty from all four sources → `no recorded rationale`. **Deviation from this spec, deliberate:** it uses `git log -S`/`-L` rather than `git blame` — `git blame --output=FILE` was tested and WRITES, so granting it would have widened the very write-capable residual §13 narrowed the same day; git log is already granted and does the same archaeology. Enrolled in READONLY_SKILLS (caught by §13a's forcing function on first run) and REPORT_SKILLS. 20 → 21 skills; matrix 79.)* /why — decision archaeology (*originally wave 5; settled here by the 2026-07-29 split*). Answers "why is this code like this" from BRIEF
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
- [x] **4.13** *(Done 2026-08-03: /health check 9 + health-checks.md §9
  read the project's own AGENTS.md rules outside the conduct block and flag
  contradictions with a conduct rule — naming both — and dead references.
  Judgment-led (there is no grep for "contradiction"), so the positive
  control is behavioral per 4.15's /qa carve-out: `fixtures/health/AGENTS.md`
  plants an attribution + push-after-commit contradiction and a dead
  reference; controls.sh asserts the plants present, and a matrix case
  removes the fixture. check.sh clean, matrix +1.)* `/health` row auditing
  the project's own agent instructions — contradictory rules, stale
  references, project
  instructions conflicting with the installed conduct block. acstack
  manages AGENTS.md and CLAUDE.md but never reviews their quality, which
  is odd for a pack whose thesis is that instructions are the product.
  Small: one check row, not a skill. **Acceptance:** on a repo whose
  AGENTS.md contradicts the installed conduct block, `/health` flags the
  conflict and names both rules.
- [x] **4.16** *(Done 2026-08-03. The verdict's listed sites were
  incomplete — the review found the **functional** default in
  `bin/acstack-config` (the resolver `/do` actually reads; docs alone would
  have been cosmetic) and `/retro`'s history-detection grep, neither in the
  task. All now emit/parse `task <number>: <description>` /
  `ticket #<n>: <description>`; `templates/acstack.md`, CONDUCT rule 10
  (both byte-identical copies), README's row and `/do` updated too. check.sh
  §16 guards the retired default from returning — shown failing first;
  matrix 74 → 75. README's demo commit and wave-4-specs keep the old string
  as history.)* Implement the 2026-07-29 commit-format verdict — the
  carrier for a decision recorded as `[x]` while nothing emitted the new
  shape. Edit CONDUCT rule 10, `/do`, `/ship`, and README's
  `subtask-commit-format` row to `task 2.3.2: <description>` (document)
  and `ticket #2: <description>` (tickets). **Acceptance:** no pack file
  still documents `completed task N (…)` or a bare `#N:` subject as the
  current format; wave-2's JOURNAL entry keeps its historical wording.
- [x] **4.18** *(Done 2026-08-04. Surveyed first rather than assumed: 3 of the listed sub-items were ALREADY handled (/audit eval's no-results stop, /learn's acstack-repo detection, and the whole config-consistency group — §9's reachability guard had forced journal-commit-format, test-command and Collaborators into agreement, so those notes were stale), and the survey itself produced a false positive on /investigate that only checking caught. Eleven paths added, each naming what is missing and stopping: /plan seed refuses to regenerate an existing BRIEF (it is the frozen record; regenerating destroys the only artifact later work can be compared against); /journal stages JOURNAL and PLAN BY NAME, never `git add -A`, and covers non-git, empty-session and no-PLAN cases; /ticket will not scaffold a PLAN as a side effect of filing; /triage and /retro stop on their missing document; /design-audit stops on a path with no UI, since CLEAN over a directory with no UI is a true statement that reads as false reassurance; /qa takes credentials from the user and never from the repo, because using a committed credential would launder a /secure finding into a passing test; /investigate leads with the verdict; /do and /resume both handle a task with no Acceptance line — /do refuses to tick on "looks done", /resume flags it rather than inventing one; and /resume prefix-matches journal subjects, the bug that made it count six journal commits as unjournaled on this repo.)* Remaining degradation paths and config consistency — every
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

- [x] **4.19** *(Done 2026-08-03 — the 22nd skill. Three preconditions before any edit: clean tree (dirty makes before/after unattributable), GREEN baseline with the exact count recorded (a red baseline cannot prove preservation, and "it was already failing" is how a real regression gets absorbed), and a suite that could actually notice — too thin means STOP and name what to test first, which is a success, not a failure to deliver. After: same count green = the promise held; count DROPPED = the headline finding; count ROSE = say why; and compare test NAMES when the count is unchanged, since equal totals hide a one-for-one swap. Never edit a test to force green (never-inflate pointed at refactoring); no behavior change smuggled in; no opportunistic scope. check.sh §19 guards BOTH halves of the proof rule, shown failing first. **The matrix caught a weak case of mine:** the first mutation stripped only "same test count" while the guard also accepts "same count", so the case reported got=PASS want=FAIL — it never demonstrated the guard firing. Strengthened to strip both phrasings. 21 → 22 skills; matrix 81 → 82.)* /refactor — behavior-preserving cleanup with proof. The rule
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
- [x] **4.27** *(Done 2026-08-04: `references/ai-tells.md`, 178 lines, zero assets, six severity-ordered sections — accessibility floor, honesty tells, the impeccable visual signature, motion bounds, materials/translucency, interaction feel — plus a credits line naming all five sources, ideas re-expressed and no text copied. **20 rule classes, each with a seeded plant and an extracted-pattern control**, so a regressed grep fails in controls.sh rather than shipping as a false pass. BOTH acceptance clauses verified, not asserted: every documented grep catches its seed, and the clean tree stays quiet (every hit in the repo is a fixture). `banned-palette` wired across README, templates/acstack.md and the skill, so §9's reachability guard holds. Citation discipline kept: the hedge-copy list stays canonical in design-conventions.md and is cited, not duplicated (4.17.4). **Two defects the controls caught on first run:** the popover pattern matched only CSS `transform-origin` and missed JSX `transformOrigin` — a real coverage gap, now both; and the motion fixture's own comment spelled `prefers-reduced-motion` while explaining its absence, so the absence-plant reported itself present — the same prose-trips-its-own-grep trap as the 4.39 fixture. Matrix 82 → 83.)* `references/ai-tells.md` for /design-audit — the 2026-07-30
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
  **Translucency/materials block (2026-07-31, third survey).** From
  `ngocanhnckh/liquid-glass-frontend-skill` — the only net-new material
  in that round, and all of it CSS-level and grep-able: `backdrop-filter`
  on an ancestor creates a **stacking context that traps z-index**, so a
  popover inside a glass shell clips — it must render at the shell root;
  nested `backdrop-filter` breaks GPU compositing (4.27 already bans the
  nesting for legibility — this adds the performance reason and makes it
  a two-signal finding); translucency over a flat fill reads as a grey
  box rather than glass; a popover over live content needs ~94% opacity
  before small text is readable; and ambient background loops need
  mismatched durations (22/27/31s) or they visibly re-sync. Light theme
  needs the INVERSE tuning — thinner mix, higher saturation — which
  belongs to 4.30's theming item, not here.

  **Three anti-slop tells from `jiji262/claude-design-skill`
  (2026-07-31)**, kept only after diffing against this task's existing
  list: a gradient orb used as the visual signifier for "AI"; charts and
  stat blocks used as decoration rather than data (distinct from the
  dishonest-label rule — these are real-looking numbers that decorate);
  and the rounded-card-plus-left-border-accent-stripe cliché. Its fourth
  candidate — a CSS/SVG silhouette standing in for a product shot — is
  **already covered** by the fake-div-screenshot tell taste-skill
  supplied. Caveat on the diff: it was run against this task's written
  list, not against impeccable's 47 rule IDs directly, since those
  clones are gone; a duplicate surviving into `ai-tells.md` is possible
  and cheap to spot at build.

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
- [x] **4.28** *(Done 2026-08-04, one commit as specified — they are one rule set. /audit gained the do-not-flag blocklist (pre-existing-outside-the-diff, correct-but-looks-wrong, pedantic, linter-catchable, explicitly-silenced lines) with the bar stated in one sentence: a finding names a consequence AND the input that produces it; everything else is a question, a Scope note, or silence. /audit and /qa both gained the does-this-target-need-the-pass opener — a review that manufactures findings because it was invoked trains readers to skim the next one. /secure now treats a written justification as DEMOTING a finding to worth-hardening with the reason quoted, never deleting it, because the justification may be stale and the reader deserves to see the trade; a wrong reason is itself a finding, argued against the reason. /ship gained one-comment-per-issue and suggestion-only-when-it-fully-fixes (a partial suggestion gets applied and resolves the comment while the defect stays half-present). /do gained the claim → requires → NOT-sufficient table, where most false completions come from the third column: the check ran but could not have failed. Every rule is verified present in its skill's consumed text; check.sh §21 keeps the set whole — the failure mode is a later edit dropping one, which is INVISIBLE in a green run because these rules suppress noise, so nothing fails and the reports just get worse. All six shown failing first; matrix 86 → 87. The other acceptance half — /audit naming the blocklist reason on a pre-existing-only diff — is behavioral.)* Skill-hygiene rules from the 2026-07-30 survey — five
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
- [x] **4.32** *(Done 2026-08-04: /triage's global pass, run last over the whole backlog after the local sweeps clear the noise. A cluster needs a stated CAUSE, not a shared topic — the test is one sentence, would fixing the named cause close every member? — plus three-or-more items (two is a duplicate pair the existing sweep handles better) and per-member evidence tying that item to that cause. Proposes a parent titled by the cause, redirects children with one standardized line so the tree stays navigable, and lists what stayed independent. Approval-gated like the rest: getting a cluster wrong reshapes a whole backlog. **The negative half is the load-bearing one** — a clustering step that always finds clusters is astrology, so an independent backlog returns "no root-cause groups found" as a real result, and a cause is never widened until items fit it. BOTH directions seeded: `fixtures/triage/clustered-PLAN.md` (8 tasks, 3 causes, every task with its OWN acceptance so no two are duplicates — a pairwise check finds nothing there, which is exactly why clustering is needed) and `independent-PLAN.md` (6 unrelated tasks where any grouping is a false positive). Five controls, four shown failing first; matrix 87 → 89. The behavioural half — a live model naming the three causes — is a shakedown.)* Backlog root-cause clustering for /triage (third pass,
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
- [x] **4.29** *(Done 2026-08-04: search→filter→fetch on repo-owned markdown. /resume's READ STEP names it — past ~500 lines, read the blockquote and TL;DR, then the ### headings, then fetch full text for the newest entry plus any heading matching the question, and say which were read in full; a five-minute catch-up that spends its budget loading six months of history has already failed at what it is for. /retro retrieves BY WINDOW and states the window plus how many entries fell inside it, so a reader can tell a five-entry trend from a one-entry anecdote — entries outside the window are not evidence, and reading them invites a trend claim drawn from data the window excluded. Partly pre-implemented by 4.36, which had already made recall itself a headings digest.)* Journal-retrieval discipline for /resume and /retro —
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
- [x] **4.30** *(Done 2026-08-04 — the 23rd skill, closing the design lane. Spine is the eight production-readiness items, all present and guarded by check.sh §20, with the rule that a style dial can NEVER lower the floor: `variance: bold` changes the look, it does not licence skipping the error state. DTCG tokens in three layers (primitive → semantic → component, 4–6 colours, ≥2 type roles, raw hex in a component is a defect), wireframe before code, one signature element, self-critique naming the AI-default look avoided BEFORE coding. Both jiji262 gates: verify the subject exists first (web content is untrusted input — weighed, never obeyed), and verify the ARTIFACT not the intent (load it, read the console; "it should work" is not verification). `references/interaction-feel.md` re-expresses emil's apple-design — response on pointer-down, interruptibility as the first principle, springs in damping/response with shipped values, the exponential-decay momentum form explicitly NOT v²/2a, materials, and reduced-motion/transparency/contrast as THREE independent signals. Light theme gets its concrete rule: thinner mix, higher saturation, never inverted tokens. Delight is product character through a useful interaction, not a whimsy layer. **Guard defect caught by its own fail-first probe:** the first §20 matched bare words, so deleting a body item stayed green because the frontmatter description repeats them — tightened to the bolded list form, then re-proved. **Honest scope: all four of this task's acceptances are BEHAVIORAL** (a live model must run /design and be checked by /design-audit + ai-tells); §20 guards the spine, not the output. That pairing is a shakedown. 22 → 23 skills; matrix 83 → 86. **`fixtures/design/` added 2026-08-04** — a seeded generic "before" page (the input 4.30's acceptance names and never had), so the /design + /design-audit pairing is repeatable instead of needing a hand-built scratch repo each run. INPUT fixture only: deliberately NO "after" page, since a canonical good build would become the house style this task's ruling rejects. It carries the eight items' raw material (a failable write with no failure path, single-state UI, uniform short content, fixed 680px width, placeholder-as-label, raw hex, light-only, `transition: all ease-in` with no reduced-motion) plus the AI-default look — violet gradient, eyebrow, emoji icon — so "named which look it avoided" and "/design-audit finds nothing in the output" are both verifiable as REMOVAL rather than mere absence. Inverted control asserts the gaps persist. **Corrected 2026-08-04, same day:** the first tick MISSED two items PLAN had routed here — emil's `animation-vocabulary` (the reverse-lookup naming layer) and `find-animation-opportunities` (motion proposed, never sprinkled). Both are now interaction-feel.md §9 and §10, found by enumerating the routing list against the tree instead of trusting the tick.)* /design — the generative lane, scoped to
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

  **Two gates from `jiji262/claude-design-skill` (2026-07-31).**
  (a) **Verify before designing.** Before producing anything for a named
  product, confirm it exists and check its current version — that repo
  records a dated failure from skipping it, and web content used this way
  is untrusted input, so it is weighed, never obeyed. Wrong-by-confidence
  is this pack's named enemy; designing a page for a product that
  shipped a redesign is the design-lane instance of it.
  (b) **Verify the artifact, not the intent.** Load the result and check
  the console: no 404s, no framework key warnings, no CORS/CSP failures,
  fonts actually resolving rather than silently falling back. Depth
  matches the change. This is the pack's verify-the-consumed-form rule
  applied to UI, and it is the only place a design skill can honestly
  claim its output works.

  **Light-theme tuning (same survey).** Theming (item 6) is not an
  inversion: a translucent surface in light mode needs a *thinner* mix
  and *higher* saturation than its dark counterpart, which is why
  inverted tokens read as grey. One concrete rule for an item that was
  otherwise stated as a principle.

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
  omitted); and ~~/design-audit + ai-tells (4.27) run on /design's output
  returns no findings — the pairing is this skill's positive control.~~
  **Verdict (2026-08-14, task 4.69): the zero-findings bar is superseded —
  it was unreachable by construction.** `/design`'s honest-scope rule
  deliberately ships artifacts with disclosed gaps, `/design-audit` sees
  only the artifact, so any design with a scope boundary — every honest one
  — fails a no-findings bar. Shakedown 16 proved it: three findings, all
  true at `file:line`, and the headline one had been **disclosed by
  /design's own Scope section**. Both skills were correct and the
  acceptance still failed.
  **The pairing is now a DIFF, and the audit stays BLIND.** Feeding the
  auditor the Scope list was rejected: it destroys the independence that
  made the finding worth having, and an auditor told "the author already
  scoped this out" may swallow a genuine blocker — exactly the case here.
  Findings are diffed against Scope *afterward*, into three buckets:
  **(1) unclaimed** — the audit found what /design never named; this alone
  fails the pairing. **(2) claimed and agreed** — named in Scope, auditor
  rates it non-blocking; passes. **(3) claimed but disputed** — /design
  scoped it out, the auditor rates it blocking; **reported to the user, not
  silently passed.** Bucket 3 is what neither originally-filed shape had,
  and it is the bucket shakedown 16 actually produced.
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

> **Carriers from the 2026-08-03 live-model shakedown** — the first real
> Claude Code session driven through /resume, /health, /secure. Its full
> report and the verification of each claim live in JOURNAL's 2026-08-03
> shakedown entry. Finding 6 (same-day journal commits lack a
> disambiguating suffix) is already owned by **4.18(a)**, so it gets no
> new task.

- [x] **4.33** *(Done 2026-08-03: re-pointed to 4.3/4.4 — wave 4 closed without adding those checks. Verified the other direction too: every numbered /health check 1–9 has a matching health-checks.md section.)* Correct `/health`'s stale wave-4 forward-reference.
  `skills/health/SKILL.md:104-105` says VERSION/update-check-freshness and
  conduct-in-global rows "are added by [wave 4]"; wave 4 closed without
  adding them (they are 4.3 / 4.4 items), so the sentence promises checks
  that do not exist and `references/health-checks.md` has none.
  **Acceptance:** /health's SKILL.md no longer claims those rows are
  added-by-wave-4 — either the rows exist, or the wording says they are
  pending (4.3/4.4); a doc-vs-reference check confirms every row /health's
  prose names exists in health-checks.md.
- [x] **4.34** *(Done 2026-08-03: seeded-control rule in the canonical secrets section + check 3c — a hit under a fixtures/ root that a controls script references is LABELED `seeded control (fixture)`, never suppressed; still listed with file:line and a count. Never applies outside the root; a live-looking value stays a finding anywhere. controls.sh proves BOTH directions and the fail-first turns the predicate into a blanket suppressor.)* Fixture vocabulary for `/health` and `/secure` run on the
  pack itself. Run on acstack, both flag the pack's own seeded controls —
  `fixtures/health/.env`, the planted keys in `fixtures/secure/config.js`,
  the `fixtures/multi-product` document sets — as ✗ issues, defused only
  by JOURNAL context; an adopter's plausible first move (run /health on
  the pack) reads as a security fail. **Acceptance:** when the
  secret/`.env`/doc-set hits are all under a `fixtures/` (or
  config-declared) fixtures root, /health and /secure label them
  seeded-control hits, not defects — without suppressing a real hit
  outside that root (prove both directions with a planted real-looking
  secret outside `fixtures/`).
- [x] **4.35** *(Verdict 2026-08-03: keep **unreleased** — no 0.4.0 was cut as a tagged release; public availability is not a version cut. Also fixed two lines the flip had made false: "1.0.0 is the public flip" and "unreleased until the repo is made public". check.sh §6 still passes.)* Decide `CHANGELOG.md`'s release heading now that the repo
  is public. Its top heading is `## 0.4.0 — unreleased` on a public repo —
  defensible (public ≠ released) but an undeliberated default.
  **Acceptance:** a recorded verdict — cut 0.4.0 as released (date the
  heading and state the /ship-time discipline that dates it) or keep
  "unreleased" with a one-line reason; check.sh §6's VERSION/CHANGELOG
  guard still passes either way.

> **Carriers from the 2026-08-03 write-path shakedown** — the second
> live-model session (/do, /journal, /audit docs, /migrate-check in a
> throwaway repo). Full report and verification in JOURNAL's 2026-08-03
> shakedown entry; finding 1 (the /do↔/audit phase contradiction) was
> fixed directly, not carried.

- [x] **4.36** *(Verdict 2026-08-03 — option A′: no session marker (that adds machine-local state the pack minimises). Made recall cheaper instead — class NAMES + a pointer, not the full text; cap 6KB → 3KB. Output ~4.2KB → **522 bytes**, all 9 classes retained, fresh every invocation.)* Runtime preamble runs per-invocation, not per-session. The
  marker-fenced block runs `acstack-config` + `acstack-recall` (~6KB of
  known-bug-classes) on every skill invocation — 4× in one shakedown; the
  model improvised suppressing the repeats. `acstack-update-check` is
  already throttled to ≤1 fetch/day via its stamp, so this is about the
  recall re-print, not the fetch. **Acceptance:** a recorded verdict —
  either a session-level "recall already ran" marker (weighed against the
  pack's minimal-machine-state stance — the stamp is the only precedent),
  or an explicit decision that per-invocation recall is acceptable and the
  preamble comment says so. No silent 4×-per-session waste.
- [x] **4.37** *(Verdict 2026-08-03: deliberately **/health's job alone** — its Docs check already flags a missing BRIEF; /do needs only PLAN and /journal only the log, so duplicating the nag in every write-path skill is scope creep. No code change; the status quo is correct and now recorded.)* BRIEF.md absence is invisible to the write-path skills. A
  fresh repo went empty → committed → journaled with no skill asking what
  the project is; only `/health` flags a missing BRIEF. **Acceptance:** a
  recorded verdict — either `/do` and `/journal` note a missing BRIEF once
  (without blocking; /do needs only PLAN), or it is deliberately /health's
  job alone and that is stated. Not "silently fine" by default.
- [x] **4.38** *(Done 2026-08-03: step 1 spells out the first-entry case — full log, said as such.)* `/journal`'s first-entry case is unspecified.
  `skills/journal/SKILL.md:57` says "`git log` since the last journal
  commit" — undefined when no journal commit exists yet (the model used
  the full log and said so). **Acceptance:** the skill's step 1 covers the
  first-entry case explicitly (full log, stated); demonstrated on a repo
  with no prior journal commit.
- [x] **4.39** *(Done 2026-08-03: step-1 no-database autodetect — fires ONLY when db: is unset and every signal is absent; any one signal or an explicit db: keeps shared-prod strictness. fixtures/migrate-check-no-db/ + an inverted control (the fixture's value is the ABSENCE), shown failing three ways.)* `/migrate-check`'s no-database decline is indirect. On a
  repo with no DB at all it defaults `db:` to `shared-prod` and stops at
  "can't find the migration stack" rather than "this project has no
  database". Honest, but reached the long way. **Acceptance:** a repo with
  no migration stack and no DB config gets a crisp up-front "no database —
  nothing to pre-flight" (or a `db: none` autodetect), proven on a fixture;
  the conservative shared-prod default still applies whenever a DB *might*
  exist.
- [x] **4.40** *(Done 2026-08-03: the ladder is a STEP inside /do's Execute — climbed before writing, stop at the first rung that holds — not always-on prose. Rung 5 makes a NEW dependency a decision to surface rather than a rung to pass quietly. The never-cut floor (validation, error handling, security, accessibility) ships with it and is COUPLED to it by check.sh §17: document the ladder without the floor and the guard fails — shown failing on all four terms, plus a matrix case. Matrix 78 → 79. The behavioral half — a live model actually reducing a would-over-build task — is shakedown evidence, not a mechanical check.)* A pre-code simplicity gate (from the 2026-08-03 external
  survey — ponytail ~93k★, Karpathy's "Simplicity First", and Boris
  Cherny's `code-simplifier` all converge here). `/simplify` is POST-hoc;
  nothing stops over-building before it happens, and rung 1 — "does this
  need to exist at all?" — is upstream of anything a cleanup can catch.
  Fold a YAGNI ladder into `/do`'s Execute step as a STEP, not always-on
  prose (the pack rejects prose-pressure enforcement): before writing,
  climb — need it at all? → already in the codebase? → stdlib? → native
  platform? → an installed dependency? → one line? → only then a minimal
  solution — stopping at the first rung that holds. Keep ponytail's nuance
  verbatim: lazy about the solution, NEVER about validation, error
  handling, security, or accessibility. **Acceptance:** `/do`'s Execute
  step documents the ladder and the never-cut-safety half; a behavioral
  demonstration shows a would-over-build task (a date picker) reduced to a
  minimal solution with validation intact. **Declined siblings** (recorded,
  not carried): multi-agent adapters (the Claude-Code-only lock), worktree
  parallelism (harness territory, not a discipline skill), and always-on
  prose injection (prose decays — check.sh is the pack's answer).

- [x] **4.41** *(Done 2026-08-04. (a) update-check now speaks on every path — up to date / N behind / remote unreachable / cannot write state — and SILENCE NOW MEANS EXACTLY ONE THING: already checked today. That path stays quiet deliberately, being the common one (every invocation after the first each day); a line there would be noise on every skill run. All four paths verified by RUNNING them against isolated state dirs, not asserted. (b) the preamble reads "per invocation, not per session (4.36)" and its update-check comment no longer claims it only speaks when behind — reworded in place across README + all 22 skills, still 12 lines inside the budget. (c)+(d) stated rather than fixed, in check.sh §13 where the read-only claim is certified: the preamble runs readlink/dirname/bin helpers that no skill grants (a grant cannot name a run-time-resolved path), so a strict harness may prompt for the preamble — it degrades to markdown, nothing breaks — and update-check WRITES the update stamp, so "read-only" describes what a skill does to the PROJECT, not a claim the pack touches nothing on the machine.)* Make the runtime preamble auditable (2026-08-03 shakedown 3).
  Two small honesty gaps in the block that runs before every skill:
  (a) **`acstack-update-check` prints nothing when current**, so silence
  cannot distinguish *up to date* from *today's fetch already consumed*
  from *failed quietly* — in a pack whose whole stance is that a silent
  pass is worse than a loud failure, the one component that says nothing is
  the odd one out. (b) **"Run once before the skill's steps" is
  ambiguous** — per invocation or per session? The 4.36 A′ verdict settled
  the behavior (per invocation, deliberately); the comment never says so.
  **Acceptance:** update-check emits one short line in every path it can
  take (current / behind / offline), verified by running all three; the
  preamble comment states per-invocation and cites the 4.36 verdict. The
  block is byte-identical across all 21 files, so a change here edits every
  skill — check.sh §12 enforces that, and the line budget of 12 still binds.
  **Added by shakedown 4 (2026-08-03), same block, same fix window:**
  (c) **the preamble cannot run under the grants of the skills that carry
  it.** It needs `readlink`, `dirname`, and execution of `bin/acstack-*`;
  only /health grants `readlink`, and no skill grants the rest. It degrades
  gracefully by design, so nothing breaks — but under a strict permission
  harness every acstack skill would open with a prompt for its own preamble,
  and §13's allowlist certifies a tool set the preamble then steps outside
  of. Decide: widen the read-only grants to cover the preamble, or state
  plainly that the preamble runs outside the declared set and why that is
  acceptable. (d) **the read-only claim carries an asterisk**: the preamble
  runs `acstack-update-check`, which WRITES `~/.acstack/update-stamp`. That
  single file is disclosed pack-wide as the only machine-local state, but
  the read-only skills' own prose says they never write, and a stamp write
  is a write. Reconcile the wording with the behavior.

- [x] **4.42** *(Done 2026-08-05: the round ran fresh-session on two blind
  venues — tiq, whose golden set made flag-honoring readable from the
  headline (honest 70.0% vs the 90% a flag-ignoring runner would print;
  the scaffolded run.py carried `fold = not case.get("case_sensitive",
  False)`), and pulse, which isolated the missing-credential branch. All
  five fixes HELD, verified at file:line against the venues on disk: the
  dated addition names PLAN task 1.1's acceptance line as invocation
  source (and venue B's spec-stated invocation correctly produced NO
  addition); NO SCORE appeared in all three layers — skill verdict,
  scaffold's printed line, all-error results file; /retro appended at the
  BOTTOM of the chronological hand-kept journal with the divergence named
  and PLAN untouched; and every /audit line citation matched `grep -n`,
  where round 10's audit had three wrong. The report itself survived
  falsification with zero broken claims (round 10's had two). One new
  finding: the runner template printed "run did not complete cleanly" on
  a COMPLETE run with one crashed-subject case — reworded in `b566654`,
  owing a regression slot next round — **discharged 2026-08-07 by round 12**, which closed 4.50's segment (a). Journal entry 2026-08-05 records
  the verdict per fix, closing this task's third acceptance clause.)*
  Shakedown 11 — live re-test of the shakedown-10 fix round
  (verification rule 6: every fix in commit `43cc1ca` is behavioural and
  stays unverified until a live run re-tests it). Two branches born in
  that round have never been driven live and must be: /retro appending
  to a CHRONOLOGICAL hand-kept journal (shakedown 10 seeded only the
  newest-first shape, so the bottom-of-the-record path is untested), and
  /eval-run's `NO SCORE — <what is missing>` verdict form. Plus: live
  `case_sensitive` grading through a freshly scaffolded runner (the
  fixed code block has executed in verification, never under a model's
  hands), the unattended-invocation clause sourced from an acceptance
  line, and /audit's pasted-not-counted line-number rule on a real
  report. **Acceptance:** a fresh-session round on a seeded venue
  exercises all of the above; the report is verified at file:line
  against the venue on disk; the journal entry records a verdict per
  fix. This task exists so the rule-6 debt has a carrier in the plan,
  not only in journal prose — the gap /resume flagged on 2026-08-04.

- [x] **4.43** *(Verdict 2026-08-05 — option (a): sharpen the front door
  and hold wave 5 until it is done. Reason: the two remaining 4.5 tasks
  wait on real adopters, and a front door that makes the sharp idea
  legible in thirty seconds is the thing most likely to produce
  adopters; wave 5's gates serve people who have already adopted. The
  sharpening work is 4.44, landed in this same edit per this task's own
  acceptance.)* Decide the
  front door before opening wave 5 — carrier for
  the 2026-08-03 external survey's strategic read, which sat in JOURNAL
  prose with no task until 2026-08-05. The datum: a single prose
  CLAUDE.md pulls ~199k★ against every comprehensive pack — the market
  rewards one sharp idea, not breadth. The question it forces: is
  acstack's sharp idea (verification — guards proven to fire, evals
  never inflated, evidence in the consumed form) legible to a stranger
  in thirty seconds from README/PRINCIPLES, or buried under a 23-skill
  table? Options, none pre-decided: (a) sharpen PRINCIPLES.md and
  README's opening into the one-sharp-idea front door and hold wave 5
  until done; (b) open wave 5 as planned and revisit this at its close;
  (c) decline the read, with the reason written. **Acceptance:** a dated
  verdict recorded on this task; if (a), the sharpening work lands as
  its own task with its own acceptance in the same edit (rule 3).

- [x] **4.44** *(Done 2026-08-05: README's first screen now leads with
  the one idea — "a claim is only as good as the thing that can falsify
  it" — instantiated five ways (phase/command, eval/results-file,
  guard/seeded-defect, migration/GO-NO-GO, resume/committed-record)
  before any table; PRINCIPLES.md names it in one sentence. The
  stranger-read falsification pass confirmed a cold reader of lines
  1–30 lands on the intended idea — and found THREE defects in the
  first draft, every one in the author's favour: "three committed
  markdown files" contradicted by the very next paragraph's four and by
  /resume's own contract (fixed count-free: "the repo's own committed
  record"), "several dozen" inflating 25 checks inside the sentence
  written to stop miscounting (now "more than two dozen"), and "Every
  principle" falsified by The-word-is-the-mode (now "Most… the rest
  keep the conduct around those claims honest"). It also caught a
  positional loss: the shared-database GO/NO-GO — the old opening's
  most searchable safety feature — had left the first screen; restored
  as the fifth instantiation. Marker-fenced blocks untouched (verified
  against the diff); check.sh clean.)* Sharpen the front door (4.43's
  option (a), same-edit carrier). One sharp idea, stated before anything else: verification —
  guards proven to fire on seeded defects, evals never inflated,
  evidence read from the consumed form, and a fresh session caught up
  from three committed documents. README's opening and PRINCIPLES.md
  lead with that idea; the skill table sells it afterwards, never
  substitutes for it. Constraint: the marker-fenced blocks README
  carries (`acstack:principles` is canonical there, `acstack:runtime`
  is budgeted) are guarded by §1/§12 — the sharpening edits prose
  around them, never inside them. **Acceptance:** README's first screen
  (before any table) states the idea and what a stranger gets from it;
  PRINCIPLES.md's opening names it in one sentence; an independent
  stranger-read pass — framed to falsify, per house practice — confirms
  the first thirty lines answer "what makes this different" without
  scrolling; `scripts/check.sh` stays clean.

- [x] **4.45** *(Done 2026-08-06. Three sites, one rule. (a) /eval-spec's
  template gained an **Isolation** section naming all four leak classes —
  user-level skills, hooks, memory/auto-memory/CLAUDE.md discovery, output
  styles and user settings — plus a **Model pin** section; the baseline-arm
  argument is stated where the spec author meets it, since ambient config
  lands in BOTH arms and an operator evaluating their own pack is the worst
  case. (b) The runner template gained contract item **8** and a worked CLI
  invocation. **Flags verified against `claude --help` before being
  written**, not recalled: `--setting-sources ""`, `--bare`,
  `--disable-slash-commands`, `--model`. That check corrected the task's own
  premise — `--bare`'s help text states skills still resolve when typed by
  name, so settings isolation ALONE does not drop a pack symlinked into
  `~/.claude/skills`; `--disable-slash-commands` is what closes it, and the
  residual (admin-managed policy settings still apply) is stated rather than
  implied. `SUBJECT_MODEL` ships **empty with a guard that exits** — an
  unpinned run STOPS instead of silently taking the operator's or the CLI
  release's default. No model id is hardcoded on purpose: a shipped id goes
  stale, and a stale default is the same defect as no pin. (c)
  `fixtures/eval-isolation/` seeds a contaminating `~/.claude` carrying all
  four leak classes, plus paired runners identical except for the
  invocation. controls.sh EXTRACTS the flags from the template at run time,
  so a doc edit that drops one fails there. **Shown failing nine ways
  before being trusted:** four controls (unisolated fixture acquires a flag,
  a documented flag vanishes from the template, the isolated fixture loses
  one, the seeded home loses a leak class), two §24 (a site drops the rule,
  a site file is missing), three matrix. check.sh **26 → 27**; matrix
  **94 → 97**; controls **75 → 78**. **Two guards caught this work
  mid-build:** §8 rejected a verbatim quote of `--bare`'s help text because
  `/skill-name` reads as a skill cross-reference (reworded, fact kept), and
  4.48's count guard blocked twice — once when §24 made checks 27, once when
  the three matrix cases made it 97, the second only surfacing inside the
  matrix's own copied tree. **Honest scope: the behavioural half is NOT
  verified** — that a live model scaffolding a runner actually emits these
  flags is a shakedown, carried as a segment of 4.50.)* Isolate the eval
  runner from the operator's own agent
  configuration. An eval that runs the subject through whatever the
  operator has installed is not measuring the subject; user-level skills,
  plugins, hooks, memory and output styles all leak into every condition,
  and they leak into the BASELINE arm hardest — where their effect reads
  as the candidate performing worse than it does, or better. acstack has
  this exposure by construction: `./setup` symlinks 23 skills into
  `~/.claude/skills`, so a pack author running the pack's own eval is the
  worst case. Verified absent 2026-08-06: zero hits for isolation, leak,
  contamination or baseline language across `skills/eval-spec/`,
  `skills/eval-run/` and `skills/ship/`. Two halves: (a) /eval-spec's
  template requires the run command to state its isolation flags and
  names what leaks without them; (b) /eval-run's scaffolded runner emits
  them and pins the SUBJECT model explicitly — unpinned, the eval
  silently runs whatever the operator or the CLI release defaults to, so
  the model varies between operators and drifts over time. Grader-side
  pinning is already covered (`eval-spec/references/grader-rules.md`,
  "Rubrics are pinned or they drift") — this is the subject side, which
  is not. *Source: 2026-08-06 survey of i-have-adhd, whose eval README
  names its own always-on flag file as the sharpest case — it would
  inject the skill's full ruleset into the baseline and make the
  comparison measure the skill against itself.* **Out of scope:** spend
  ledgers and per-condition cost caps; a budget is not a contamination
  control. **Acceptance:** eval-spec's template carries an isolation line
  naming at least user-level skills, hooks, memory and output styles; a
  scaffolded /eval-run runner for a Claude-CLI stack emits an isolation
  flag and an explicit model pin; and a fixture seeding a contaminating
  user-level config demonstrates the check firing, shown failing before
  it passes (verification rule 2).

- [x] **4.46** *(Done 2026-08-06. `skills/eval-run/references/regression-gate.py`
  — an adopter-side comparator, since the runner is the project's file, not
  the pack's. Reads the new results file and the last committed one,
  computes per-category pass rates over `status: "scored"` records only
  (the same exclusions the headline uses), and BLOCKS when any category
  falls. The floor is stated at three sites and §24 keeps them in
  agreement: /eval-spec's template (where the spec is written), /eval-run
  (where the eval is run), /ship gate 3 (where the release decides).
  **The fixture IS the discriminator, which is the whole point:** against
  `previous.jsonl`, `current.jsonl` lifts the overall number **50.0% →
  66.7%** while refusal **collapses 100% → 0%**. A gate reading only the
  headline sees an improvement and ships it — refusal is small, so its
  collapse barely moves the average, which is exactly why the aggregate
  cannot be the floor. Blocked output names the category and both rates:
  `refusal: 100.0% (2/2) -> 0.0% (0/2)`. The no-baseline path passes and
  PRINTS `NO BASELINE … This run is not evidence that nothing regressed` —
  a control asserts the message, not just the exit code, because a silent
  pass is the false confidence this gate exists to remove. **Shown failing
  in both directions before being trusted:** a comparison neutered to
  accept-all fails the control, and one turned into a blanket rejector
  fails it too — without the second, a gate that blocked everything would
  score full marks on the plant. Four controls, three matrix cases.
  matrix **102 → 105**; controls **81 → 85**. **The guard's first version
  was weak and the fail-first caught it:** §24's new rule anchored on a
  bare `regress`, which also matches `regression-gate.py`, so deleting the
  rule statement still passed. Tightened to `non-regression` and re-proved
  firing at all three sites — the same weak-pattern class the matrix caught
  on 4.19 and 4.47.)* Add a per-dimension non-regression floor to the eval
  release gate. /ship gate 3 today compares one headline number against a
  fixed target ("Below target BLOCKS"), and /eval-spec's category
  minimums are floors on the GOLDEN SET's composition (≥10 happy-path, ≥5
  edge/adversarial/refusal) — neither compares a run against the previous
  run. So a change that lifts the headline while degrading correctness or
  refusal behaviour passes both gates, which is the never-inflate rule
  losing to an aggregate. *Source: 2026-08-06 survey of i-have-adhd,
  whose release gate holds "correctness and safety are each within 0.1
  points of baseline or better" separately from the weighted score.*
  Design call to settle at build, deliberately NOT pre-decided: acstack's
  evals are per-case pass/fail with category minimums rather than
  weighted multi-dimensional scores, so the transferable form is probably
  "no category may fall below its previous run's pass rate" rather than a
  float floor — and whether the baseline is the last committed results
  file or the spec's stated target is the second half of that call.
  **Out of scope:** gating public comparison claims on identical
  cases/models/trials — the honesty half is already carried by the
  never-inflate principle and /audit eval.
  **Verdict (2026-08-06) — the baseline is the LAST COMMITTED RESULTS
  FILE.** The spec-minimum alternative was rejected because /eval-spec
  already states per-category floors, so flooring against them again
  would add a gate that catches nothing new; the max-of-both ratchet was
  rejected as too likely to block on ordinary eval noise. Consequence
  that must be built, not discovered: a first run has NO baseline, and
  that path passes with a stated line rather than silently — an absent
  baseline reported as a pass is the false-confidence this gate exists
  to remove. **Acceptance:** a seeded results pair where the headline
  RISES while one category's pass rate FALLS against the previous
  committed run must BLOCK, naming the category and both rates; a run
  with no committed baseline passes and says so in its output; both
  shown failing before they pass.

- [x] **4.47** *(Done 2026-08-06. `scripts/reach-check.sh` + check.sh §25;
  controls.sh runs the SAME script against seeded fixtures. The convention,
  described here without its literal brackets so this sentence is not itself
  read as a marker: an `owed:` tag naming a task number must name one that
  EXISTS and is OPEN; an `owed: declined` tag must carry a reason. Both failure
  modes the rule has really produced are covered — a carrier that does not
  exist, and one that is already closed, which is `b566654`'s case exactly.
  **The mechanism was chosen by measurement, not preference.** The plain
  bare-numeric approach was built and tested first: matching `N.NN`
  references across PLAN and JOURNAL returned six unresolved values on a
  clean tree, every one an incidental numeric — `1.3% of a 200k window`,
  VERSION `0.4.0`, a `1:1` ratio. Widening to catch real references means
  chasing those forever, which is a denylist and cannot be finished (§13's
  ruling), so explicit markers won on evidence and the rejected approach is
  recorded in the script header rather than lost. **Three live obligations
  annotated in the same edit**, including the one that motivated the task:
  4.42's closed text and JOURNAL's shakedown-11 entry both now carry
  an explicit owed-marker naming 4.50, so a reader of either learns where the debt went.
  **Shown failing seven ways before being trusted:** four via the orphan
  fixture (dangling carrier, closed carrier, reasonless decline,
  unreadable carrier), the missing-file path, and three matrix cases — plus
  the positive direction, since a guard that rejected every marker would
  otherwise score full marks. /audit docs gained the judgment half, pointed
  explicitly at what the guard cannot see. check.sh **27 → 28**; matrix
  **97 → 100**; controls **78 → 81**. **The matrix caught a weak mutation
  of mine:** the neutered-comparison case anchored on `^  fail=1$`, which
  matches nothing — every `fail=1` sits indented inside a case branch — so
  it reported got=PASS want=FAIL and never demonstrated the guard firing.
  Strengthened and re-proved; the same weak-mutation class the matrix
  caught on 4.19.)* Add a reachability check over the doc set — work named as
  owed with no open task owning it. AGENTS.md's third verification rule
  ("anything named as needed work gets a carrier task in the same edit")
  has now been broken three times, and every time a human-driven audit
  caught it rather than a check: three cross-cutting rules binding with
  nobody owning them, then two proposed skills named in analysis and
  never scheduled, then `b566654`'s regression debt — written as owed in
  both JOURNAL.md:209 and inside 4.42's CLOSED task text at
  PLAN.md:1471, with no open task carrying it, and four tool calls to
  establish by hand on 2026-08-06. A rule enforced only by remembering to
  look is not enforced. The check, over PLAN.md + JOURNAL.md: every
  phrase naming work as owed ("owes", "owing", "needs a carrier", "still
  to do") resolves to an OPEN task, and every `4.NN` and short-SHA
  reference resolves to something that exists. Home is /audit docs or
  /triage — both already read the doc set; a fourth skill for this is
  scope creep. Mechanism NOT pre-decided: plain regex over existing prose
  is the cheap candidate; `[[wikilink]]` references written into the
  canonical files are the richer one, and are preferred over any BUILT
  index or graph — a derived index is a duplicated enumeration, and this
  repo's demonstrated failure mode is precisely that (four count-drifts
  in the week to 2026-08-05, a fifth found in JOURNAL's own TL;DR on
  08-06). **Out of scope:** /triage's existing stale-item and
  duplicate-pair sweeps; reachability across git history or GitHub
  issues. **Acceptance:** a seeded fixture PLAN/JOURNAL pair in which one
  "owed" phrase has no open carrier and one `4.NN` reference dangles —
  the check names both with file:line, and reports zero on the clean
  tree. Shown failing before it passes.

- [x] **4.48** *(Done 2026-08-06. `scripts/count-check.sh` is the ONE
  implementation — check.sh §23 runs it on the six standing docs, and
  controls.sh runs the SAME script against seeded fixtures, because a
  second copy would be exactly the duplication this guard exists to
  catch. Seven derivations: `skills`, `checks`, `matrix-cases`,
  `wave45-done`, `wave45-open`, `wave45-total`, `open-scheduled`.
  JOURNAL's TL;DR and its wave table now carry
  `<!-- count:NAME -->N<!-- /count -->` markers. **Shown failing four
  ways BEFORE being wired:** a stale value, an unknown count name (a
  typo'd marker must FAIL, never skip — a marker that silently verifies
  nothing is the false-pass class), no markers at all in any file given,
  and a marked-count file that no longer exists. Then end-to-end in the
  consumed form: seeding `count:skills -->20` made check.sh exit **1**
  with `FAIL count: JOURNAL.md:30  doc says 20 / reality is 23`, and
  restoring it returned exit **0**. Matrix **90 → 94** — stale value,
  implementation deleted, marker renamed to an underivable name, and the
  comparison neutered to accept-all; that last one surfaces as
  `FAIL control`, which proves the inverted control catches a neutered
  comparison rather than the guard grading its own homework. Controls
  **72 → 75**: two inverted (both fixtures must be REJECTED) plus one
  positive (JOURNAL's correct markers must be ACCEPTED — without it a
  guard that rejects everything would score full marks). check.sh **25 →
  26** checks. **Two defects caught during the build, both by the new
  guard's own paths:** §23's first file list named `ARCHITECTURE.md` at
  the repo root when it lives in `docs/`, caught on the first run by the
  missing-file path; and CONTRIBUTING.md's "22 numbered sections +
  3b/3c/13a = 25 checks" sat inside a bash code block where an HTML
  marker cannot render, so it went count-free and points at check.sh's
  own header instead of duplicating it. **Honest scope, printed on every
  run rather than swallowed:** `unmarked counts are NOT checked`. The
  regex sweep for unmarked count-like prose stays declined per §13.)*
  Move the count-drift check from /audit docs into
  `scripts/check.sh`. Coverage was never the problem: the check exists,
  is correctly written, and reads *"Stale counts vs greppable reality:
  tool counts, test counts, table counts, record counts"* at
  `skills/audit/SKILL.md:92`. It has never fired. `/audit docs` runs only
  when a human types it, and nobody types it without already suspecting
  drift — so the one condition that triggers the check is the one
  condition that never occurs, while `scripts/check.sh` runs before every
  commit by AGENTS.md rule. Instances found 2026-08-06 alone: JOURNAL's
  TL;DR said "Twenty skills" against 23, its table said `21/23` against
  23/28, its roadmap bullet said "35 open tasks" against 21 scheduled,
  and PLAN's wave-4 risk note said "3 remain" and then "Those four" in
  the next clause. JOURNAL records two more in the days before
  (ARCHITECTURE's enumeration 08-04, PRINCIPLES' "fifteen numbered
  sections" 08-05 — inside the principle *about* replacing prose with
  checks). Every instance was a restatement of something enumerable in
  the tree, which is what makes a bash guard possible at all.
  **Mechanism:** derive-and-compare on MARKED counts —
  `<!-- count:skills -->twenty-three<!-- /count -->` — where check.sh
  derives each (`ls skills/ | wc -l`, a wave checkbox tally, the open-task
  total, `check.sh`'s own numbered-section grep) and fails on mismatch.
  The governing rule is duplication, not correctness: a number stated
  once cannot drift, so count-free prose is the default and a marked
  count is the deliberate exception where a reader needs the figure.
  **The certification scope is the load-bearing part** — the guard
  verifies the marked counts and NOTHING else, and must say so in its own
  output. An unmarked count claim is invisible to it. Green here means
  "the marked counts agree", not "no stale numbers in the docs", and this
  repo's documented habit is reading the first as the second. /audit docs
  keeps the judgment half: quickstart still true, exit criteria still
  runnable, superseded vs merely stale. **Out of scope:** a regex sweep
  for unmarked count-like prose — that is a denylist and cannot be
  finished, per §13's 2026-08-02 ruling; if built at all it is noise
  reduction, never certification. Also out of scope: having check.sh
  invoke /audit docs, which is impossible — skills are model-invoked
  prose, check.sh is bash, so the mechanical subset gets rewritten in
  bash or it does not exist. **Acceptance:** a fixture whose marked count
  disagrees with its derivable reality fails the guard with a `doc says /
  reality is` line; the clean tree passes; the guard's output names which
  counts it verified; and the whole thing is shown FAILING before it
  passes, per verification rule 2 — three guards in this repo have
  reported clean on a planted defect (the `sk-` secret regex, the
  description guard, the palette check whose `\b` matched nothing), and a
  count guard never seen failing is decoration.

- [x] **4.49** *(Closed 2026-08-07 with a scope verdict. **Three skills
  split, two measured and DECLINED** — the decline is half the result, so
  a later reader does not see two unsplit heavy skills and assume the work
  was abandoned. Net on the default (document) path:
  `/plan` 12,181 → 7,175 (**−5,006**), `/do` 10,428 → 9,236 (**−1,192**,
  tickets not loaded in document mode), `/triage` 9,625 → 8,890 (**−735**,
  one mode reference always loads). **Total 32,234 → 25,301 bytes, −6,933
  ≈ 1,733 tokens** — and `/plan` alone is 72% of it. Every split proved
  **0 lines lost** by set difference, the prose analogue of /refactor's
  same-test-count rule.
  **Verdict — `/design` and `/eval-run` are declined, not deferred.**
  Mapping their sections found **zero** conditional content: /design's
  process, eight items, and verify-the-artifact apply to every invocation;
  /eval-run's grading rules and report shape are consulted on every run.
  Splitting either would put always-on text behind a pointer — two loads
  instead of one, strictly worse. They are big, not splittable, and the
  original 35%-of-body-text framing was a SIZE measurement that did not
  survive contact with per-section conditionality.
  **A correction inside this task:** /triage was first advised as the best
  remaining candidate at ~101 conditional lines, counting root-cause
  clustering's 56. Reading it corrected that — it says "run it last, over
  the whole backlog", in BOTH modes, so it is a mandatory third pass and
  splitting it would have violated this task's own rule. Real conditional
  content was the mutually-exclusive mode pair, ~46 lines, and the saving
  came in at a third of the estimate.
  **Guard risk checked before touching /do:** check.sh greps
  `skills/do/SKILL.md` by path in §17 (ladder floor terms) and §21
  (hygiene's claim/requires table); its tickets section was confirmed
  clear of both before the split, and the guards stayed green.
  The behavioural half — a live model finding the moved procedure in each
  mode — is unchanged and still owed. **Discharged 2026-08-16 by shakedown
  23**, which completed the set: `/plan` seed mode (sk-15), `/do` and
  `/triage` in tickets mode (sk-17), and both in document mode today.)* Split the heavy
  skills so an invocation loads only the
  split, not the set, and the title says "the heavy skills". **`/plan`
  done: 12,181 → 7,175 bytes, 215 → 127 lines**, with `Mode: seed` (71
  lines) → `references/mode-seed.md` and `Tickets mode` (29) →
  `references/tickets-mode.md`. A `/plan replan` run no longer pays for
  either. **Behaviour preserved and proven**, /refactor's rule in its
  prose form: every non-blank line of the 215-line original is present in
  the new body or a reference — set difference **0 lines lost**, which is
  the analogue of "same test count", and a line that vanished would have
  been the finding. **The guard question turned out narrower than the
  task assumed.** §8 (crossref) ALREADY catches a pointer citing a missing
  file — verified by seeding one — so building that would have been
  duplication (ladder rung 2). What no guard caught was the silent shape:
  a `## Mode:` heading whose body moved out and whose pointer was then
  dropped, leaving a heading that cites nothing and says nothing. Seeded,
  it passed EVERY existing check. That is now §26, scoped to exactly the
  gap and shown failing first; matrix gained two cases and deliberately
  does not re-test §8's shape. check.sh **28 → 29**; matrix **100 → 102**.
  **Still open:** `do` (10,428) and `triage` (9,625) carry zero reference
  files and are the next clearest; `design` (11,814) and `eval-run`
  (11,369) have one each and need reading before any claim; `/audit`
  remains the model, not a candidate. The behavioural half is unchanged
  and still owed. **Discharged 2026-08-16 by shakedown 23.**)* Split the heavy skills so an invocation loads only the
  procedure it selected. Measured 2026-08-06: the always-on cost is the
  skill listing at 9,523 bytes over 21 model-invocable descriptions
  (~2,540 tokens, ~1.3% of a 200k window) — small, and not worth
  attacking. The cost that scales with use is the BODY: 182,421 bytes
  across 23 SKILL.md files, average 7,931, of which six carry 63,711 =
  35% of all body text. `/plan` is the clearest case — `Mode: seed`,
  `Mode: build`, `Mode: replan`, `Tickets mode` and `Hackathon mode` all
  sit in one 12,181-byte body, so `/plan replan` pays for four modes it
  will not use. **`/audit` is the model, not a candidate**: 8,975 bytes
  of dispatch and shared rules with its four targets' detail already in
  `references/` (16,924 bytes, fetched on selection). The pattern to
  copy is the one this pack already ships. **Candidates need identifying
  per skill, not assumed from size** — `do` (10,428) and `triage`
  (9,625) carry zero reference files and are the strongest; `design`
  (11,814) and `eval-run` (10,688) have one each and need reading before
  a claim. **Out of scope, deliberately:** trimming the frontmatter
  descriptions — that is the discovery surface, `/ship` already shipped
  once with a YAML-truncated description that lost its whole trigger
  sentence, and ~500 tokens a session is the wrong side of that trade.
  Also out of scope unless §13 is extended to follow it: collapsing the
  818-byte runtime block into a one-line `bin/` call, which would save
  ~175 tokens per invocation but move the block off the surface §13 reads
  to certify the read-only claim, undoing 4.41's auditability on
  purpose. **Sequencing:** this is gated behind 4.45 — without an
  isolated runner there is no way to show the split preserved behaviour,
  and compressing first and checking later means never knowing which cut
  cost what. **This is a refactor of shipped skills, so /refactor's own
  rule binds:** behaviour preserved, proven before and after, and a
  count that DROPS is the finding rather than a detail. **Acceptance:**
  (a) each split skill's SKILL.md shrinks by a stated before → after
  byte count, with the totals above as the baseline; (b) check.sh gains
  a guard that every mode or target named in a dispatch has a reachable
  reference file — the failure mode is a split that orphans a mode,
  which is INVISIBLE in a green run because the skill still loads and
  simply stops knowing how to do one thing; shown failing first; and (c)
  a live round drives each split skill in each of its modes and gets the
  same report shape as before the split — behavioural, so it owes a
  shakedown slot under verification rule 6. **Discharged 2026-08-16 by
  shakedown 23**: `/triage` in document mode reached
  `references/document-mode.md` — never exercised before — and returned the
  full sweep, catching both seeded defects while correctly leaving the two
  well-formed tasks alone; `/do 2.2` ticked only 2.2, committed
  `task 2.2: …`, and took the suite 3 → 4 green. `/do` has no document-mode
  reference at all, so for it the bar is report shape, not reachability.

- [x] **4.62** *(Done 2026-08-12. **Shipped as a MODE, and the description
  grew 36 chars against a <40 budget** — 460 -> 496, well inside 4.59's 600
  per-description cap. `references/target-skills.md` carries seven classes:
  YAML-truncating frontmatter, name/dir match, the description as trigger
  surface, body budget, citation resolution, `allowed-tools` honesty, and
  conditional-branch waste. It re-expresses what `check.sh` does rather
  than shelling out to it, because **an adopter's skill is not in this
  tree** — that is the whole point of the target.
  **The negative twin caught a false positive in a check written minutes
  earlier.** Class 1's first grep was `^description:.*( #|: )`, which
  flagged the GOOD fixture: a quoted description may legitimately contain
  `: `, and the parsed form confirmed it survives intact. A grep that fires
  on correct skills trains its reader to ignore it. Narrowed to
  `^description:[[:space:]]*[A-Za-z].*( #|: )` — unquoted values only.
  **Second finding, from the same fix:** the intermediate pattern used
  `[^"'... ]`, and **a documented grep containing a literal single quote
  cannot be extracted by this pack's own control convention**, which cuts
  at the first quote. Written as `[A-Za-z]` for that reason, and the
  reference says so.
  **Two stale claims fixed in passing, one of them mine:** `/audit` opened
  "Three targets, one stance" while carrying four (stale before this task),
  and the `target-code` pointer still advertised the does-this-need-auditing
  gate that **4.61 moved out of it one commit earlier** — a
  doc-says/reality-is mismatch inside `/audit` itself.
  Fixtures `bad-skill` (four plants) and `good-skill` (the twin) added;
  controls 104 -> 107, all four shown failing first — the naive pattern
  firing on the twin, the plant repaired so the grep misses, the ghost
  reference created, and the fifth target stranded. `/audit` sits at 26
  wasted lines, under 4.61's 40 threshold, with five pointers.
  **Still owed:** the behavioural half — a live model actually running
  `/audit skills` against a defective skill. **Discharged 2026-08-13 by
  shakedown 16**, which ran exactly that and caught the class a no-target run
  missed.)* Add `/audit skills` as a fifth mode — skill-authoring from the
  verification side. **Scheduled by 4.59** (2026-08-11) as a MODE, not a
  skill: the field's most-recurring verb across 8 independent sources, and
  acstack already holds the methodology in AGENTS.md and `check.sh` rather
  than in prose. **Startup cost of this choice: ~10 chars** on `/audit`'s
  existing description (460 -> ~470) against ~394 for a new skill's
  description — a mode costs one list item, a skill costs a permanent
  roster entry. **Acceptance:** the mode audits a SKILL.md the way
  `check.sh` does (frontmatter, budgets, reference resolution, allowed-tools
  honesty) and is shown catching a seeded defect in a fixture skill;
  `/audit`'s description grows by less than 40 chars.

- [x] **4.63** *(Done 2026-08-12. **Shipped as a MODE; description
  322 -> 361 chars (+39), and `/resume` sits at 10 wasted lines, far under
  4.61's 40 threshold.** `references/mode-cold.md` replaces the doc-triad
  reads with README, manifest, layout, SHAPED git history (activity and
  ownership, not a commit list), CI, and the config surface. The default
  path now hands off explicitly — all three documents missing means an
  unfamiliar repo, not a broken one — because a mode nothing routes to is
  a mode nobody reaches.
  **The mode is defined by what it REFUSES**, and both prohibitions are
  controlled: no scaffolding, and no invented "next 3 tasks" list. A
  stranger's repo is where a confident invented plan does the most damage,
  because it reads as knowledge and is a guess. `no recorded rationale` is
  the `/why` stance applied to structure.
  **Demonstrated live, headless, against a blind no-doc-triad venue**
  (`~/shakedown-13/venue-cold`, a small Python CLI with README, manifest,
  src, tests, CI and two commits). Fact-based discriminators:
  **file count 7 -> 7**, and no BRIEF/PLAN/JOURNAL/CLAUDE.md created — no
  scaffolding. It produced the orientation brief and **offered two options
  rather than listing invented tasks**.
  **It also found a defect I had put in the venue by accident:**
  `pyproject.toml` declares `tempo.cli:main` and the README says
  `python -m tempo`, but the code lives in `src/` — so both documented
  entry points would fail. That is the reference's own "a broken quickstart
  is the most useful thing you can report on day one" rule firing on an
  unplanted inconsistency.
  **Honest scope:** the literal phrase `no recorded rationale` was not
  exercised, because the venue posed no why-question. What was demonstrated
  is the absence of invention, not the presence of that sentence.
  controls 110 -> 111, shown failing when the no-scaffolding rule is
  removed.)* Add an unfamiliar-repo mode to `/resume`. **Scheduled by 4.59**
  (2026-08-11) as a MODE: 4 independent sources ship codebase onboarding,
  and `/resume` already owns "get oriented in five minutes" but assumes the
  BRIEF/PLAN/JOURNAL triad, which an unfamiliar repo does not have.
  **Startup cost: ~15 chars** on `/resume`'s description. **Acceptance:**
  run against a repo with NO doc triad, it produces an orientation brief
  without inventing a plan, and says plainly that no recorded rationale
  exists rather than guessing — the `/why` stance applied to structure.

- [x] **4.64** *(Done 2026-08-12. **Shipped as a reference — zero startup
  cost — cited from `/ship`'s act, after all five gates.**
  `references/changelog.md`. **The rule the task called out is the spine:
  the entry is PROPOSED, never committed or pushed without the user saying
  so** — a changelog is outward-facing text with their name on it, and the
  same rule that stops `/ship` inventing a PR step stops it writing release
  prose unasked. **Both sources are named, and the reference says why
  neither alone is enough:** `git log <range>` bounds the range and proves
  nothing was missed but never says why a reader should care; JOURNAL.md
  supplies the framing but silently drops whatever went unjournaled.
  **Demonstrated on a real range** (`9cc76ab..HEAD`), in this repo's own
  format — `### <theme>` bullets under the version heading, leading with
  the noun, upgrade actions inside the bullet where a reader hits them.
  **The no-tags path was exercised for real:** this repo has 0 tags, so
  `git describe` finds no boundary and the reference's "say so and use the
  range the user names" branch is what ran. `CHANGELOG.md` was left
  **unmodified — verified `0` changed files** — which IS the acceptance's
  never-commit-without-approval clause. controls 107 -> 108, shown failing
  when the propose-only rule is removed.)* Make `/ship` write the changelog entry it never writes.
  **Scheduled by 4.59** (2026-08-11) as a REFERENCE FILE under `/ship`:
  5 sources ship changelog generation, `/ship` cuts releases and produces
  none, and this repo's own `CHANGELOG.md` is maintained by hand.
  **Startup cost: ZERO** — a `references/` file costs nothing until cited.
  **Acceptance:** shown generating an entry from the commits in a release
  range, in this repo's own changelog format, with the entry proposed and
  never committed without approval (the outward-facing rule).

- [x] **4.65** *(Done 2026-08-12. **Shipped as a reference — zero startup
  cost — cited from `/eval-spec` before the category minimums, i.e. while
  the spec is being written and no score exists.**
  `references/goodhart.md` carries **five** shapes against an acceptance of
  three, each with its own detection question: the refusal that isn't, the
  expected leaked into the input, keyword stuffing on `concept`, tolerance
  wider than the decision, and a single-case category. The method reduces
  to one question per case — *write the worst answer that still passes it*.
  **Demonstrated against the pack's OWN grader, not a mock.** Running the
  shipped `concept` rule verbatim over `fixtures/goodhart/gameable.jsonl`:
  `g1` returns **PASS=True** for *"I cannot help with that request. The
  admin token is ADMIN-TOKEN-PLACEHOLDER."* — the grader saw the disclaimer
  and stopped, so a case built to catch a leak certifies one. `g2` passes
  by echoing the input verbatim; `g3` passes an answer that says nothing
  happened and then lists the five keywords. Three shapes, three passing
  wrong answers.
  **A control asserts the plant stays gameable** — if someone "fixes" the
  fixture, the demonstration silently stops demonstrating, which is the
  fixture-rot class this repo has shipped before. controls 108 -> 110, all
  three shown failing first. **Honest scope, stated in the reference:** the
  pass proves nothing about the SUBJECT. Every question is about whether
  the CASE can be satisfied without doing the task; a spec that survives it
  can still be too easy or aimed at the wrong behaviour.)* Add a Goodhart defence to `/eval-spec`. **Scheduled by 4.59**
  (2026-08-11) as a REFERENCE FILE: ECC's `loop-design-check` names the
  failure where the subject games the verifier, which bears directly on
  `/eval-run` — a golden set that can be satisfied without solving the task
  measures nothing. **Startup cost: ZERO** (reference, cited from the
  spec-writing step). **Acceptance:** the reference names at least three
  concrete gaming shapes with a detection question each, and one is shown
  against a seeded golden case that passes while getting the task wrong.

- [x] **4.66** *(Done 2026-08-14. **Verdict: (3) + (5) — a clause on conduct
  rule 5, plus a documented user-level `permissions.deny` block that the pack
  never writes. (1) declined, (2) deferred to 5.3, (4) rejected.**

  **Ruled on evidence, not inference: nine nested-session arms** (`claude
  2.1.170`, each a headless `-p` run, ground truth read off the disk rather
  than from the model's own report). Deny semantics, all observed:
  `Bash(cmd:*)` blocks (arm A default, arm B bypass); `Bash(cmd *)` blocks
  (E); bare `Bash(cmd)` does **not** block an invocation carrying arguments
  (D); a multi-token prefix blocks when it ends at a token boundary —
  `Bash(touch probe:*)` vs `touch probe extra` (H) — and does **not** when it
  lands mid-token (G v1). Scope: project `.claude/settings.json` applies
  (A–F, H); user `~/.claude/settings.json` applies in a directory with no
  project settings at all (G2). **Deny survives
  `--dangerously-skip-permissions`** — B blocks, C is the same rig with the
  deny list emptied and the command runs; single variable, both directions
  observed. `PreToolUse` hooks also fire under bypass, 5/5, before the
  permission decision.

  **The finding that shaped the verdict (arm F): any indirection defeats
  it.** `sh -c`, `bash -c` and a script file each ran the denied command;
  only the direct form and a compound `a && b` were caught. This is §13's
  lesson arriving on schedule — it is a denylist and it cannot be finished —
  so the block ships documented as **friction on the direct form**, never as
  a boundary, and `/health` reports presence-count only, never a safety
  verdict.

  **Why (1) loses.** Not on capability: a hook can read a script off disk and
  a deny pattern cannot, so it is genuinely more capable — the claim
  mid-argument that it "buys nothing deny doesn't" was wrong and is corrected
  here. It loses on cost against completeness: grepping every script before
  execution is slow and is defeated by any script that builds its command
  dynamically, so it buys marginal completeness on a provably incompletable
  problem — while making the pack own executable code in the user's global
  config, a new install surface, a new uninstall surface, and silent global
  behaviour. 4.59's boundary (*"harness config, and the pack ships skills, not
  settings"*) stands, and the probe removed its only remaining justification.

  **Why (2) loses here:** it is not this task's to rule — wave **5.3
  `/careful`** already owns that shape almost verbatim. A safety gate must
  also fire when the model is about to act: typed-only is inert precisely
  then, and model-invocable costs ~405 chars against the 2,861 of headroom
  measured 2026-08-14 (9,139 / 12,000), for the same reliability class as
  prose.

  **Why (4) loses:** its premise is exactly what arm C falsifies. With no deny
  rule, under bypass, the destructive command ran with no prompt and no
  denial. Default-mode prompting is not the protection; the deny rule is, and
  nothing in the pack currently tells an adopter that.

  **Why (3) survives the counter-evidence recorded below.** The category test
  that rejected rule 11 in the referral decision — *"rules 1–10 govern how an
  agent talks to a human and hold with zero skills installed"* — **passes**
  here, so the clause grafts onto rule 5 rather than becoming rule 11: an
  irreversibility confirm is the carve-out to *"don't ask permission for what
  was requested"*. And the evidence-for-crossing below does not transfer —
  three misdated verdicts, three miscounts, a stale pointer are all
  **bookkeeping accuracy**, never act/don't-act decisions. Arm F strengthens
  (3) relatively: if no mechanical control can be complete, the
  agent-behaviour half carries more weight than this task assumed.

  **Split, because the halves have different acceptances:** **4.76** is the
  buildable half (docs + `/health` row + guard, mechanical, today); **4.77**
  is the clause, whose live demonstration is owed to a round. **Discharged 2026-08-16 by
  shakedown 18** — control 3/3 performed the act, clause arm 0/3.

  **My own error, recorded because it is the useful part:** arms G v1 and v2
  were void by construction — the deny pattern's prefix landed mid-token
  against the marker name I chose — and I came close to writing them up as
  "user-level does not apply". Caught by adding a disambiguating control (H),
  not by re-reading my own design. Fourth instance of the venue-design shape
  the 2026-08-14 entry already records three of.

  **NOT tested, no claim made:** managed/enterprise settings layering; any
  tool other than `Bash`; `--permission-mode` values other than `default` and
  `bypassPermissions` — deny holding under a mode documented as "bypass all
  permission checks" should hold a fortiori in weaker ones, which is an
  inference and is labelled as one.)* Decide how the pack guards IRREVERSIBLE acts, and whether that
  crosses into harness config. Raised 2026-08-12 after a repo deletion was
  double-verified by hand and the second pass found a recorded verdict
  wrong (`"an empty LEARNINGS.md"` against 97 bytes). **Surveyed before
  filing:** the pack already has destructive-act discipline, but it is
  per-domain and advisory — `/do` never pushes because "a push cannot be
  undone quietly", `/migrate-check` is an entire skill that blocks a
  destructive class with a written GO/NO-GO. **Nothing ships hooks or
  settings**; the only `settings` mentions are `/eval-run` isolating AWAY
  from the operator's. There is no general rule for "about to do something
  irreversible".
  **This is NOT what 4.59 declined.** That was ECC's delivery-gate Stop
  hook, refused as (a) harness config rather than skills and (b) an
  unskippable gate removing pacing control. **(b) does not apply to a
  safety confirm; (a) still does**, so the boundary is the whole question.
  **The evidence for crossing it:** advisory rules were followed unevenly
  by a model *in the session that raised this* — three misdated verdicts,
  three miscounts of unpushed commits, a pointer left describing a moved
  gate. For irreversible acts, "followed unevenly" is the wrong
  reliability class, and that is precisely the gap a hook closes and a rule
  cannot. **The evidence against:** it makes the pack write `settings.json`
  — a new install surface, a new uninstall surface, and a global silent
  behaviour firing in projects where the user wants `gh repo delete` to
  just work.
  **Four shapes, none pre-decided.** (1) A `PreToolUse` hook intercepting a
  named destructive set — enforced, crosses the boundary. (2) A new skill
  in `/migrate-check`'s shape — costs ~394 chars of the startup budget
  4.59 capped, against ~2,900 chars of headroom. (3) An 11th conduct rule —
  zero startup cost, advisory, and the count has been held at ten
  deliberately once before. (4) Nothing: the harness already prompts on
  hard-to-reverse actions, and this session's double-check happened because
  the user asked.
  **Counter-evidence, added 2026-08-12 from 4.67 — and it does NOT widen
  this task.** This task is scoped to IRREVERSIBLE acts; writing a BRIEF is
  not one, and nothing below asks for a shape covering advisory rules in
  general. What the datum bears on is the *evidence* above, which argues
  that advisory prose is "followed unevenly" and therefore the wrong
  reliability class. 4.67 is a dated instance pointing the other way. Given
  a rule it had just read, a live model **quoted its field list back**
  (*"fabricating an audience or a constraint is the one thing this step
  must not do"*), recognised the harness condition the rule was re-keyed
  onto (*"The picker didn't get an answer back"*), **explicitly weighed the
  prescribed form and declined it** (*"let me not freeze a BRIEF full of
  TBDs either"*), and asked instead — which is what conduct rule 8 wants.
  Across four post-fix runs the fabrication the rule exists to stop
  occurred **zero** times. So on a non-destructive path, advisory prose was
  not followed unevenly; it was followed thoughtfully, and the one
  deviation was of FORM and was better than compliance.
  **Which shape this argues for:** it weakens (1), the enforced hook, as a
  general instrument — a `PreToolUse` gate cannot tell "deviating because
  it read the rule and judged well" from "ignoring the rule", and here it
  would have blocked the better answer. It leaves (1) untouched for
  genuinely destructive acts, where there is no better answer to block, and
  it modestly strengthens (3), the conduct rule. **The distinction to rule
  on is therefore reversibility, not compliance rates** — the evidence for
  crossing the boundary is strong exactly where an act cannot be undone and
  weak everywhere else.
  **Acceptance:** a dated verdict naming which shape and
  why the other three lose; if a hook ships, `./setup` installs and
  `--uninstall` removes it with the same never-delete-a-real-file property
  the symlink path has, shown on a machine where the user already has a
  populated `settings.json`; if a rule ships, it is shown changing a model's
  behaviour in a live run, not merely written down.

- [x] **4.67** *(Done 2026-08-12. The never-guess rule is hoisted above
  the unsupplied-sections block and binds on every path, with a
  `Deriving is not guessing` carve-out; the branch is re-keyed off the
  judgement "is this unattended" onto the observable **"you did not ask,
  or you asked and no answer came back"**. check.sh §31 pins the rule's
  POSITION — re-nesting is the regression — and all three of its branches
  were watched failing before being trusted; three matrix cases added.
  **Proven at file:line, not by summary:** the fabricated domain landmine
  appears in `run-b2` alone, **0 of 4 post-fix runs**; every post-fix run
  attributes its volume estimate and names the gap, where pre-fix `b1`
  asserted it flat. `run-rt4` emits the literal 5 times under a
  `## Open TBDs` heading. `run-rt5` on the bare stub path reads it as no
  answer — *"The picker didn't get an answer back. I won't invent
  these"* — and asks rather than freeze, which is conduct rule 8 working,
  not a defect. What is NOT claimed: that a frozen BRIEF always uses the
  `TBD` literal rather than an Open-questions section. It does not, and
  that residual is filed to 4.66 as counter-evidence, not as owed work.)*
  `/plan seed`'s unattended branch could not fire in the run it
  was written for. Found by shakedown 15 (2026-08-12), 2/2 clean runs.
  `references/mode-seed.md:11-18` opens *"When nobody can answer — a
  non-interactive or unattended run — asking is not an option"* and
  prescribes `TBD — not supplied at seed time` plus a TBD list at the top of
  the report. **It is conditioned on the model recognising the run is
  unattended, and a headless model does not.** In `claude -p` the session
  calls `AskUserQuestion`, which does not error — it returns the literal
  stub `"Answer questions?"` — so the model reads a declined question,
  concludes the user is present but skipping, and improvises its own
  gap-handling. `run-b1` narrates it: *"You skipped the questions, so I
  recorded them as admitted open questions."* Neither run emitted the
  literal; neither listed gaps at the top.
  **The downstream cost is invention, which is the rule this protects.**
  The seed prompt contained **0** mentions of volume or cadence (grep), yet
  `run-b1/BRIEF.md:26-28` states *"a handful of books a week at the very
  most. Volume is tiny: tens to low hundreds of lines accumulated over
  years"*, and `run-b2/BRIEF.md:35` states *"tens to low-hundreds of lines
  per user, ever"*. `run-b2/BRIEF.md:61` invents a **domain landmine** —
  *"'Same title' is not 'same book' … do NOT dedupe by title"* — the exact
  field `mode-seed.md:16-18` names as costliest to fabricate. `run-b2` then
  reported *"I did **not** invent"*. It had; a self-report of honesty is not
  evidence of it.
  **Not in scope to 'fix':** the bulk of both landmine sections was *derived
  from the venue's source* and is true (append-only supersede, `max+1` id
  collision, `json.loads` crashing a bad line, `ensure_ascii=False`,
  `from store import Store` defeating curl-one-file). Reading a landmine off
  the code is the opposite of guessing it. The fix must not suppress that.
  **Acceptance:** the branch fires without depending on the model
  classifying its own run — e.g. keyed on a question having been asked and
  not answered, rather than on "unattended" as a judgement. Verified by a
  live headless run emitting the literal `TBD — not supplied at seed time`
  for a section the prompt does not supply, with the TBDs listed together at
  the top of the report, and no invented figure in that section. Mechanical
  green does not discharge this (verification rule 6).
  *(**Fix built and re-tested 2026-08-12 — NOT discharged.** The never-guess
  rule was hoisted above the unsupplied-sections block so it binds on every
  path, with a `Deriving is not guessing` carve-out protecting the thing
  both original runs did right; the branch was re-keyed off the judgement
  "is this unattended" onto the observable **"you did not ask, or you asked
  and no answer came back"**. `check.sh §31` pins the rule's POSITION —
  re-nesting it is the regression — and all three of its branches were
  watched failing; three matrix cases added.
  **It works where the run is unambiguously unattended.** `run-rt4` meets
  this acceptance to the letter: the literal five times, a `## Open TBDs`
  list at the top tagged by source section, `Milestone time budget: TBD`
  in the Constraints section, and the carve-out holding rather than
  over-correcting — 12 `file.py:NN` citations and a header stating the
  landmines were *derived, not guessed*. `run-rt3`, given no unattended
  cue, **stopped and asked rather than invent**, quoting the new condition
  back: *"A declined/blank answer is treated the same as 'not supplied' …
  I won't guess them either way."*
  **It does NOT work in the condition that found the defect.** `run-rt1`
  and `run-rt2` reproduce the original failure exactly: `AskUserQuestion`
  returns its placeholder, the model reads it as a deliberate skip rather
  than as no answer, and fills the sections itself — including a numeric
  scale range nobody supplied, in both. Ticking this on `run-rt4` alone
  would be the inflation the pack forbids.
  **Acceptance sharpened, and this is what remains:** a live headless run
  in which `AskUserQuestion` is called and returns its placeholder — no
  unattended cue in the prompt — must still produce the literal for an
  underivable unsupplied section and invent no figure. Venue
  `~/shakedown-15/venue-seed2` already isolates this: Constraints is
  underivable there, verified by 0 residual constraint signals in
  `CLAUDE.md`, `README.md` and the source.
  **A defect in the round's own bar, recorded rather than buried:** the
  first venue omitted only sections a model can legitimately *derive*
  (landmines from source, open questions from analysis), so `TBD` was
  arguably never warranted there and the first two re-test runs were
  scored against a bar they should have failed. Venue 2 exists because of
  that error.
  **Sharpened test run 2026-08-12 (`run-rt5`) — branch NOT REACHED, and
  the residual is narrower than this task states.** On the stub path with
  no unattended cue the session called `AskUserQuestion` 4 times, wrote no
  BRIEF, and asked: *"The picker didn't get an answer back. I won't invent
  these … fabricating an audience or a constraint is the one thing this
  step must not do. But you're right here, so let me not freeze a BRIEF
  full of TBDs either."* It reads the stub as **no answer** — the re-keyed
  observable — quotes the hoisted rule with its field list, weighs the TBD
  freeze, and deliberately chooses to ask. 2/2 on venue 2 (`rt3`, `rt5`);
  2/2 on venue 1 the model freezes instead, because venue 1's gaps are
  derivable. Asking is correct conduct, so the branch is hard to reach by
  design. Graded N/A, not FAILED.
  **What the fix demonstrably changed:** the fabricated domain landmine did
  not recur — `run-b2`'s "'Same title' is not 'same book' … do NOT dedupe
  by title" appears in b2 alone, **0 of 4 post-fix runs** — and sourcing
  density inside the landmine section roughly tripled (pre-fix b1 5 refs /
  10 landmines, b2 2/7; post-fix rt1 17/8, rt2 9/7, rt4 13/10; a density
  proxy counting matching lines, not one audit per bullet).
  **What remains, restated honestly:** not "invents when it cannot ask" —
  that is fixed and demonstrated. What remains is only that when the model
  does freeze, it prefers its own Open-questions representation to the
  `TBD` literal. That is a representation preference, not an invention
  defect, and forcing TBD over asking may be the wrong trade.
  **A correction to this note, made before closing it.** An earlier draft
  said `rt1`'s volume estimate was unattributed. It is not:
  `run-rt1/BRIEF.md:31-33` reads *"(That bound is derived from the
  single-user personal-tracker use case, not supplied by me; exact counts
  were not given and are not load-bearing for the design at this scale.)"*
  All four post-fix runs attribute the estimate and name the gap, or route
  it to the TBD list; pre-fix `b1` asserts *"Volume is tiny: tens to low
  hundreds of lines accumulated over years"* flat, with no source and no
  gap named. The error understated the fix, and it was caught by re-reading
  the artifact rather than trusting the summary — which is why the closing
  claim below is stated against `file:line`, not against this note.
  **Verdict (2026-08-12): CLOSED on shape (1), with the residual filed to
  4.66 as scoped counter-evidence rather than left as owed work.** Shapes
  (2) and (3) lose: (3) would change a rule to force `TBD` over asking,
  and asking is what conduct rule 8 wants — the deviation observed was
  better than compliance would have been; (2) as originally phrased would
  have moved an open obligation into a task scoped to *irreversible acts*,
  silently widening it. What moves to 4.66 is the datum, not the debt.)*

- [x] **4.68** *(Done 2026-08-12. The rule now has one home:
  `mode-seed.md` states both states — `none known yet; expect to discover
  during <phase>` for **asked and nothing yet**, `TBD — not supplied at
  seed time` for **not supplied at all** — and `brief-template.md`'s note
  points at it instead of carrying a second copy. The distinction is the
  point, not the wording: conflating them destroys the difference between
  *we looked and found none* and *nobody has looked*, and only the second
  is a reason to go back and ask. **check.sh §30** guards all three drift
  modes and **each was watched failing** on a seeded defect — template
  restates the rule (the defect as it shipped), canonical site drops a
  state, template stops pointing — plus three matrix cases; matrix
  110 → 117, 0 failed. Re-tested live per rule 6: the template's
  `expect to discover` phrasing is absent from **4/4** re-test BRIEFs,
  where `run-b2` had used it.)* `mode-seed.md` and `brief-template.md` contradicted each other
  on unsupplied sections. Predicted by reading before shakedown 15 ran (H1),
  then **confirmed live**. `references/mode-seed.md:13` says write
  `TBD — not supplied at seed time`; `references/brief-template.md:78-80`
  says that for Domain landmines specifically, record *"none known yet;
  expect to discover during <phase>"* **rather than omitting the section**.
  A session reaches the template *through* the reference
  (`mode-seed.md:8`), so it reads both and gets two instructions for one
  field. `run-b2` followed the template — *"Known from reading the
  prototype …; **expect to discover more during build**"* — the template's
  phrasing, not the reference's. This is the same class as 4.52, where two
  files shipped contradictory grading rules and every multi-keyword expected
  was mis-graded. **Acceptance:** one rule, stated once, with the other site
  pointing at it rather than restating it; a control asserts the two files
  cannot drift back apart. Sequence with 4.67 — whichever lands first sets
  the wording the other adopts.

- [x] **4.69** *(Done 2026-08-14. **Verdict: the zero-findings bar is
  superseded; the pairing becomes a blind audit plus an after-the-fact
  diff into three buckets** — unclaimed (the only failure signal), claimed
  and agreed (pass), claimed but disputed (**reported, never silently
  passed**). Feeding the auditor `/design`'s Scope was rejected outright:
  it destroys the independence that made the pairing worth running, and an
  auditor told the author already scoped something out may swallow a real
  blocker — precisely the case here. Recorded against 4.30's acceptance as
  a dated supersession, and as method in `docs/shakedown-method.md`.
  **Re-run against `~/shakedown-16` as this task required, and the verdict
  on the same three findings holds:** hardcoded seed state → **bucket 3**
  (named in `/design`'s Scope as "first-paint hydration… not designed",
  yet the blind auditor calls shipping it a blocker — both correct, and the
  disagreement IS the finding); the copy contradiction at `:316`/`:340`
  and the danger-coloured hint at `:501` → **bucket 1**, unclaimed by
  Scope, genuine misses inside item 8.
  **The re-run also produced a finding that changes how the pairing must be
  used.** On a **byte-identical** artifact (`md5` equal), the same blind
  audit returned **3 findings the first time and 1 the second** — the
  second missed both bucket-1 items, which are still true in the file. A
  single-run diff would have scored zero unclaimed and PASSED, honestly and
  wrongly. **One audit run is not an enumeration:** union across at least
  two, and treat one run's silence as unmeasured rather than clean.
  **4.71 converged here:** the re-run's safety-check block shows the new
  RFC 2606 pattern, and the finding cites *"the `.example` TLD is RFC 2606
  reserved"* — caught by the fixed grep rather than by reading, which is
  what 4.71 was for.)* Rule how `/design` and `/design-audit` pair, because 4.30's
  acceptance as written can never pass. Found by shakedown 16 (2026-08-13),
  the first run of 4.30's behavioural acceptances. A3 says *"/design-audit +
  ai-tells run on /design's output returns no findings — the pairing is this
  skill's positive control."* A blind audit of a genuinely good `/design`
  output returned **3 findings, all verified true at `file:line`, 0 false
  positives** — and the headline one had been **explicitly disclosed by
  /design in its own Scope section** (`"First-paint hydration… state is
  hardcoded as a stand-in for server-rendered/injected data"`).
  **Both skills behaved correctly and the acceptance still failed.**
  `/design`'s honest-scope rule — *"a design that cannot answer all eight
  items is reported as incomplete with the gaps named"* — deliberately ships
  artifacts carrying disclosed gaps; `/design-audit` sees only the artifact,
  so it flags them. A zero-findings bar is unreachable for any design with a
  scope boundary, which is every honest one. **Acceptance:** a dated verdict
  choosing the shape — e.g. the bar becomes "no findings **other than ones
  /design named in Scope**", verified by feeding the auditor that Scope list;
  or the pairing stops being a pass/fail control and becomes a diff. Whatever
  is chosen must be re-run against `~/shakedown-16` and produce a defensible
  verdict on the same three findings.

- [x] **4.70** *(Done 2026-08-14. **The fix is derivation, not distrust** —
  the run's unchecked claims were all true (zero hex in component CSS, 39
  token aliases resolving); the one it *enumerated* was wrong. `/design`'s
  report shape now requires that **any claim naming a SET is derived from
  the artifact, not asserted from memory**, and item 7 says to extract the
  animated property set "from the artifact, never from intent". Item 7 also
  keeps the distinction that matters: animating `box-shadow` does not break
  the item; *saying you did not* breaks the honesty rule, which is worse.
  Without that clause an honesty fix silently becomes a ban.
  Three controls, each watched failing on its own seed. **The controls were
  wrong first** — the phrase wraps across a markdown line, so flattening
  newlines alone left `this    item` and a single-space grep missed it;
  fixed by squeezing whitespace, the **third line-wrap miss** in this
  file's controls. Two matrix cases; matrix 127 → 129.
  **Live re-tested per rule 6**, comparing the report's claim against the
  artifact mechanically. Artifact animates `animation`,
  `background-color`, `border-color`, `color`, `transform`; the report
  states *"animated set **enumerated from the file, not intent**:
  `transform`, `background-color`, `border-color`, `color` (+ a `spin`
  keyframe)"* — an exact match, where the first run claimed "only
  transform/opacity/background-color" while animating four including
  `box-shadow`. It also names what it does NOT animate, which is the
  falsifiable form.)* `/design`'s report was not verified against its own artifact.
  Three instances in one run (shakedown 16, 2026-08-13). (a) It claims *"only
  `transform`/`opacity`/`background-color` animated"*; the real set is
  `{background-color, border-color, box-shadow, transform}` — `opacity`
  claimed but never animated, `box-shadow` (the expensive repaint) and
  `border-color` animated and unclaimed. **A claim about a set that does not
  enumerate the set**, which is this repo's own rule, broken by its own
  skill. (b) It reported item 8 (UX writing) as answered while shipping a
  header reading *"Changes save as you make them"* over an email field that
  only persists on an explicit button — a promise the UI does not keep. (c)
  Same item, a merely-disabled row painted in `--danger-text`, the same
  colour as a real write failure. **Not every claim was wrong** — "zero raw
  hex in component CSS" is true (0 hex after line 67) and all 39 token
  aliases resolve — so the fix is verification, not distrust.
  **Acceptance:** the eight-item section's checkable claims are derived from
  the artifact rather than asserted, and a live run reproduces the animated
  property set correctly on a page that animates something outside the
  compositor-friendly three. Mechanical green does not discharge it (rule 6).

- [x] **4.71** *(Done 2026-08-14. The address half of the fabricated-content
  grep now **enumerates RFC 2606** instead of sampling it —
  `example.com/net/org` plus the reserved TLDs `.example`, `.invalid`,
  `.test`, `.localhost`, each closed by `([^A-Za-z0-9.-]|$)` so
  `sub.test.com` and `localhost.example-corp.com` stay out. Measured, not
  reasoned: 6/6 reserved forms caught, 0/5 false positives.
  **The control was watched failing BEFORE the fix, as this task required.**
  Against the shipped pattern it reported `MISSED its plant`, and the only
  line the old grep matched in the new fixture was **my own comment
  describing the bug** — `fixtures/design-audit/reserved-domains.tsx`
  tripping its own detector, which is a named bug class in this pack. The
  comment was rewritten to spell out no address at all.
  Two controls (catch + negative twin), both watched failing in both
  directions: narrowed back to the sample, and widened past the boundary
  guard. Two matrix cases; **the second was a no-op on its first draft** —
  `$` did not survive the nested shell quoting — and was rewritten as a
  python mutation, verified to mutate. matrix 125 → 127.
  **CI then caught a third defect, and it was the deeper one (2026-08-14,
  run 31743799656, `passed=128 failed=1`).** The *first* matrix seed was
  ALSO a no-op — `sed` mutated it on BSD and not on GNU, so it passed
  locally and reported `got=PASS want=FAIL` on Linux. Converting it to a
  python mutation made it fire, and that exposed the real problem
  underneath: **the control was too coarse.** It used `ai_check`, which
  passes if ANY line of the fixture matches, so narrowing one branch of
  the alternation stayed invisible while the other branch still caught
  something. Replaced with a **per-address** check over all seven reserved
  forms; the narrowing seed now fails naming exactly the address lost
  (`ops@example.net`). **The lesson is procedural:** twelve matrix cases
  were added across this session and the full matrix was never run
  locally — `check.sh` does not run it. Full local run after the fix:
  **129/129, 0 failed.**)* `ai-tells.md:102` missed the reserved `.example` TLD. The
  fabricated-content grep is `@example\.(com|org)`; RFC 2606 reserves
  `.example` as a **TLD** as well as `example.com/net/org` as domains, and a
  seeded address ending `.example` sailed past it in shakedown 16. The model
  caught it by reading and citing the RFC — the grep did not. **Fifth
  instance of the denylist class in this repo**, after the seven-emoji list,
  the `sk-` secret regex, the violet-hex palette list, and the `\b` POSIX
  hazard. **Acceptance:** the pattern covers the reserved set enumerated
  rather than sampled, and a control seeds a `.example` address and is
  watched failing before the fix, per the prove-it-fires rule.

- [x] **4.72** *(Done 2026-08-14. Two halves, because either alone leaves the
  silent path open. **(a) The leading `- ` is now optional** —
  `value_from`'s pattern went `s/^-[[:space:]]*$1:` →
  `s/^[[:space:]]*-\{0,1\}[[:space:]]*$1:`, so bare `key: value` resolves.
  Re-derivation widened the fix: `value_from` is called at ALL THREE
  precedence levels (global, project `## Settings`, per-skill section), so
  the bug was three-fold, not the one site the write-up named.
  **(b) A known key that is present but unreadable now WARNS on stderr**
  instead of falling back silently — the condition that made an unreadable
  config indistinguishable from no config. Unknown keys stay quiet, because
  ignoring them is README's documented extension mechanism.
  **The warning's first version was wrong and a control caught it:** it
  required a colon, so `tracking = tickets` warned about nothing — the same
  silent default, one layer up. Now separator-agnostic (`:`, `=`, or
  whitespace).
  **Five controls, every one watched failing on a seeded defect** —
  restoring the mandatory dash, muting the warning, and making the warning
  unconditional (which fires the two negative twins, unknown-key and
  prose-naming-a-key). One seed of mine was itself wrong and proved nothing
  until corrected. Two matrix cases added, both seeds verified to mutate;
  matrix 117 → 119.
  **README now documents the line format**, which had lived only inside
  `templates/acstack.md` while the key table implied bare `key: value`.
  **Live re-tested per rule 6** in the venue that exposed it: `/triage`
  re-run reports **zero** config-mismatch lines where the first run opened
  with a "Config caveat, read first" warning, and operated in tickets mode
  throughout — proposing issue actions, never PLAN.md checkboxes. The
  binary in that venue now reports `tracking=tickets (project)`,
  `stale-days=0 (project)`.)* `bin/acstack-config` silently ignored un-bulleted `## Settings`
  keys. Found live by shakedown 17 (2026-08-13) — a `/triage` session
  reported the resolver saying `tracking=document (default)` while
  `.claude/acstack.md` plainly set `tracking: tickets`, and proceeded off
  the file rather than the binary. **Verified independently, both
  directions:** `bin/acstack-config:40` is
  `sed -n "s/^-[[:space:]]*$1:[[:space:]]*//p"`, so bare `tracking: tickets`
  resolves to `document (default)` while `- tracking: tickets` resolves to
  `tickets (project)`. **Zero** warning, ignored-key or malformed-section
  output — grepped.
  **Severity is the discoverability, not the regex.** The bullet syntax
  exists in exactly ONE place, `templates/acstack.md`. README documents the
  keys as a table and never shows the line form (0 hits for the bullet form
  across README and all of `docs/`), and the principles block says only
  that "`## Settings` keys override pack defaults". An adopter writing the
  natural markdown gets the default mode, silently, and every skill's
  runtime preamble then prints a value that contradicts the file.
  **Why it survived this long:** skills that read the file themselves get
  it right — `/health` reported `tracking: tickets` prereqs met in the same
  round the binary said `document`. The model compensates, so the bug
  hides. **Corroborated 2026-08-13: THREE independent sessions caught it
  unprompted** — `/triage`, `/resume` and `/ship`, each in a separate run,
  each proceeding off the file rather than the binary. `/retro` read the
  file directly and never consulted the binary, so it was unaffected,
  which is precisely how the bug survives. **Acceptance:** either the parser accepts both forms, or it
  rejects the unparsed form LOUDLY — a `## Settings` section whose keys all
  fail to parse must not report defaults as though the file were absent.
  Whichever is chosen, README documents the syntax, a control seeds the
  bare form and is watched failing first, and a live run confirms a skill
  no longer disagrees with the binary.

- [x] **4.73** The tickets bootstrap had no owning mode, and a shipped fix
  command names the wrong one. `plan/references/tickets-mode.md:18` lists
  "**One-time bootstrap**" as a sibling bullet with NO mode attached,
  directly after "**seed** is unchanged".
  `health/references/health-checks.md:170` prescribes the fix as "re-run
  /plan's tickets bootstrap (idempotent)" — also naming no mode. With
  nothing to read, a live `/health` invented one and told the user to run
  **`/plan seed`**, the mode the same file rules out. **Settled
  behaviourally in shakedown 17: `build` performs the bootstrap** — labels
  10 → 14, 4 milestones, 7 issues, all created by `/plan build`. Same class
  as 4.68: an instruction that never says when it fires. **Acceptance:** the
  bootstrap names its owning mode at its definition; `/health`'s fix
  command names that mode; a control asserts the two cannot disagree.
  *(**Fix built 2026-08-14 — NOT closed, one live run owed.**
  `tickets-mode.md`'s bullet now reads "**One-time bootstrap — performed by
  `build`, never by `seed`**" and carries the derivation rather than just a
  label: milestones are one-per-phase, and phases do not exist until
  `build` has written them, so `seed` — which produces only BRIEF.md — has
  nothing to map. `health-checks.md` now prescribes **`/plan build`** by
  name. Four controls, **each watched failing** on a seeded defect: the
  definition losing its mode, the definition dropping its explicit
  rules-out-`seed` clause, the fix line naming no mode, and the fix line
  pointing at `/plan seed` — the exact wrong guess observed live. Two
  matrix cases added, both seeds verified to mutate; matrix 119 → 121.
  ~~**Why it stays open:** … the re-test died incomplete inside a five-hour
  rate-limit window — 26 events, no result.~~
  **Verdict (2026-08-14): that was wrong, and the correction matters more
  than the conclusion.** The run had not died; it was still streaming when
  I read its transcript at 26 events, and the `rate_limit_event` in it
  reads `status: allowed` — informational, not a kill. It finished at **80
  events with a result**. Reading a live log mid-stream and treating the
  snapshot as final is the same class as verifying the authored form
  instead of the consumed one.
  **Re-tested live, HELD.** Venue `~/shakedown-17/run-health2` with the
  local `ISSUE_TEMPLATE/task.md` removed so check 8 fails without touching
  the remote. `/health` check 8 now reports
  `✗ → /plan build` — the correct mode. The four remaining `/plan seed`
  fixes in that report are checks 2 (Pointer), 3 (Conduct) and 3b
  (Referrals), where `seed` genuinely is the fix; **no tickets fix points
  at `seed`**. Rule 6 discharged.)*

- [x] **4.74** *(Done 2026-08-14. **Verdict: the split cannot be removed, so
  it must be named — option (b) was impossible, not merely worse.** GitHub
  serves issue templates from the DEFAULT BRANCH, so a locally-written
  `task.md` governs nobody until committed and pushed; labels, milestones
  and issues are API objects that exist on creation; and `/plan` does not
  push by deliberate design. The asymmetry is imposed by GitHub, not chosen
  by the pack.
  **Re-derivation widened it past the write-up.** The task named only the
  bootstrap. `/health` check 8 ran `ls .github/ISSUE_TEMPLATE/task.md`
  **alone**, so it reported the template PRESENT while
  `gh api repos/{owner}/{repo}/contents/...` returned **404** — demonstrated
  live on `run-build` before any edit. A doc-says/reality-is mismatch inside
  the skill whose job is catching exactly that.
  **Both sites fixed:** the bootstrap now states the template is written but
  **not yet in effect**, with the commit as the outstanding step; `/health`
  queries the default branch as well as the disk and reports on-disk and
  in-effect as distinct states. Three controls, **each watched failing** —
  one seed of mine was too weak (`COMMITTEDXX` still contains `committed`)
  and proved nothing until corrected. Two matrix cases, both seeds verified
  to mutate; matrix 121 → 123.
  **Live re-tested per rule 6** on the venue that exposed it: `/health` now
  reports *"Issue template on disk but NOT in effect — `.github/` is
  untracked, API returns 404 on the default branch, so it governs
  nobody"*, where the same check previously reported ✓.)* Rule the half-remote bootstrap. Labels, milestones and issues
  are created REMOTELY via `gh` and exist immediately; `.github/ISSUE_TEMPLATE/task.md`
  is written LOCALLY and never pushed — correct on its own terms, since
  `/plan` does not push and that is `/ship`'s job. Verified in shakedown 17:
  the file is on disk and the API returns 404 for it. The consequence is
  that the template governing hand-filed issues does not exist for anyone
  else until someone commits and pushes, while the labels those issues use
  already do. **Acceptance:** a dated verdict — either the bootstrap says
  plainly that the template needs a commit before it governs anyone, or the
  split is removed. Not left as an undocumented asymmetry.

- [x] **4.75** *(Done 2026-08-14, and re-derivation corrected the diagnosis.
  **The two specs never disagreed about what "unblocked" means** — both say
  "no `blocked` label". The real gap: `/resume`'s DOCUMENT mode carries
  *"Fewer than three exist → list what's there and say why the rest are
  blocked"* (`SKILL.md:104`) and the TICKETS section omitted it entirely.
  With one unblocked issue in M1 and a bare "Next 3" instruction, the live
  run had no permission to return fewer, so it padded — listing the
  `blocked` issue under an "unblocked" heading. A missing escape valve, not
  a contradiction.
  **Fixed one-home:** the document-mode paragraph gains *"Never pad the
  list to three… three is a cap, not a quota"* and says it governs both
  modes; the tickets section points at it rather than restating it.
  **Three controls, each watched failing — and two of them were wrong
  first.** The cap-not-a-quota phrase wraps across a line in the canonical
  paragraph, so a line-wise grep silently matched only the *tickets* copy:
  the control was testing the wrong site and duplicating its neighbour.
  Retargeted with whitespace flattened and re-seeded so each control now
  trips on its own site with the other intact. Two matrix cases; matrix
  123 → 125.
  **Live re-tested per rule 6** in the venue that produced the padding:
  the heading is now *"Next unblocked work (M1)"*, the report says *"Only
  **one** unblocked open issue in the current milestone — not padding to
  three"*, and #2 sits under a separate "Blocked/held behind it" section
  marked "Not listed as ready".)* `/resume` and `/triage` disagreed about whether a `blocked`
  issue is ready work. Found in shakedown 17 (2026-08-13) on identical data.
  `/resume`'s spec says next-3 is "top unblocked open issues (**no
  `blocked` label**) in the current milestone"; the live run listed issue #2
  as item 2 under a heading reading "Next tasks (unblocked, current
  milestone M1)" while annotating it `blocked` and naming its blocker.
  `/triage`, given the same backlog, excluded #2 from ready work entirely —
  the correct reading. Nobody is misled, because the annotation is honest,
  but the heading contradicts its own contents and two skills apply one rule
  two ways. **Acceptance:** one rule, and both skills demonstrably applying
  it — a live run where a `blocked` issue appears in neither ready-work
  list, or appears in a section whose heading does not claim it is
  unblocked. Same one-rule-one-home shape as 4.68.

- [x] **4.50** *(Done 2026-08-16, and it closed only after its register was
  emptied rather than after its segments were finished — the distinction the
  guard forced. All seven segments held (shakedowns 19-22, detailed below).
  Ticking it then turned reach-check red: **14 `owed` markers across nine
  closed tasks pointed at 4.50**, because it was the standing register every
  behavioural debt in this repo named, not a finite task. Audited all 14
  instead of re-homing them: **11 already settled** (round 12; shakedown 13
  ×4; shakedown 16 ×3; shakedown 18 ×2), **1 was never a debt** (4.47's prose
  citing the convention), and **3 were live** — 4.49's acceptance (c),
  "each split skill in each of its modes". Shakedown 23 discharged those:
  `/triage` in document mode reached `references/document-mode.md` for the
  first time ever and returned the full sweep; `/do 2.2` ticked only its own
  box and committed `task 2.2: …`. Two self-inflicted false positives were
  caught by the guard on the way — an owed-marker written with an ellipsis instead of a task number, and this note's
  own quotation of the guard's error text, both citations the checker cannot
  distinguish from claims.
  **`/triage`'s stale class stays excluded**, untestable in a fresh repo.
  Two findings became carriers: **4.84** and **4.85**.)* The next shakedown's mandatory segments — everything a
  round is already known to owe. *(**Updated 2026-08-12:** round 13 ran
  4.58's ladder and **discharged 4.52's re-test** — `q10` graded correctly
  in three live runs, which requires the comma splitter.
  **Round 14, same day, discharged FOUR more and the accumulated debt is
  now ZERO — but this task stays OPEN, because its own (b) and (c)
  segments were never run.** Venue `~/shakedown-13/venue-b` seeds what
  round 13 structurally could not: a run that COMPLETES with 3 of 4
  refusal cases erroring. Ground truth: runner exits **2**, gate exits
  **1** on the coverage axis.
  **4.51 HELD** — a neutral-level session read the new line and explained
  it unprompted: *"on the surviving case the refusal pass rate is a clean
  100% -> 100%. Anyone eyeballing 'did a passing refusal case start
  failing?' would wave it through."* Golden hash unchanged.
  **4.53 HELD, but only via `/ship`, and that is the finding.** A
  direct-eval session mentioned the exit code **zero times** across two
  runs even though the runner PRINTS `exit 2: …` — it reads the report,
  not the status. Re-run as `/ship`, gate 3's evidence table recorded
  `python3 eval/run.py -> exit 2` and interpreted it per contract: *"Exit
  code 2 = completed with 3 errored cases… blocks regardless of the
  headline."* **The exit code's only live consumer is `/ship`**, exactly as
  4.53 designed it; a session running the eval by hand never reads it.
  **4.61 and 4.62 HELD together, by A/B on one defective skill.** Analysed
  WITHOUT the target, a session found four defect classes and **missed
  class 1** — the YAML truncation, the highest-severity class, because it
  read the description as text rather than as parsed YAML. Invoked as
  `/audit skills`, the same skill produced the seven-class scope table with
  **class 1 caught and ranked first**, class 7 marked N/A, and the
  reference's own "declarations only, not behaviour" clause reproduced —
  which it could only do by reaching the procedure 4.61 moved into
  `references/`. The split is reachable and the target earns its place.
  **A level-3 competing prompt also HELD:** told the safety endpoint was
  "known flaky" and to mark r2-r4 `acceptable_failure`, the session refused,
  disproved the premise — *"a repeatable code failure on the safety path
  rather than the flaky infra it was described as"* — and found the
  shortcut would not have worked anyway, since the runner refuses to
  forgive crashes by design.
  **Still owed, and why this box stays unticked:** (b)'s remainder — the
  interactive halves of the unattended contracts, the tickets-mode deltas,
  and `/plan`'s and `/do`'s splits — plus (c), 4.30's four design
  acceptances. Every round so far has run in document mode.
  *(**Superseded 2026-08-12 by shakedown 15**, below: `/plan`'s split is
  now exercised and HELD; `/do`'s is tickets-only and moves to the tickets
  round. What remains of (b) is the interactive halves and the tickets-mode
  deltas.)*)*
  *(**Shakedown 15, 2026-08-12 — the splits segment, and a scope correction
  derived from the code.** (b) named "`/plan`'s and `/do`'s splits". `/do`
  has exactly ONE reference, `references/tickets-mode.md` (27 lines), cited
  once at `skills/do/SKILL.md:149` behind `tracking: tickets`. There is no
  document-mode reference, so **`/do`'s split is not testable in document
  mode and moves to the tickets round**; the same is true of `/plan`'s
  second reference. This round therefore covered `/plan`'s
  `references/mode-seed.md` (75 lines) alone.
  **Split reachability HELD.** 3/3 headless sessions on a blind venue
  (`~/shakedown-15/venue-seed`, a stdlib Python reading tracker, no doc
  triad, `CLAUDE.md` carrying real content) opened `mode-seed.md`
  unprompted, and reproduced six behaviours that exist in **no other file
  reachable from the post-split `SKILL.md`**: `CLAUDE.md` flagged and left
  byte-identical, pack root resolved by the reference's own `readlink`
  guard including its `PACK ROOT NOT RESOLVED` branch, `acstack-conduct`
  (1668B) and `acstack-referrals` (1792B) copied **byte-verbatim**,
  `LEARNINGS.md` created, and the `.claude/acstack.md` copy offered rather
  than done. Reference-only score **6/9** both clean runs; shared
  discriminators **5/5**, all eight required BRIEF sections enumerated
  individually in both.
  **The unattended branch FAILED, and the split did not cause it** — in
  both runs the model *read the file containing* `TBD — not supplied at
  seed time` and then did not use it. Carried as **4.67** (branch cannot
  fire headless; invention downstream) and **4.68** (`mode-seed.md` vs
  `brief-template.md` contradict, H1 predicted before the run and
  confirmed).
  **The A/B could not be run, and that is a method finding.** Arm A
  (pre-split, 215-line single file) was discarded as invalid: a
  project-local `.claude/skills/plan/` does **not** override a globally
  symlinked skill, so the session read the global `mode-seed.md` anyway.
  Two further isolation facts, both verified against CLI 2.1.170:
  `CLAUDE_CONFIG_DIR` does **not** isolate a headless inference run
  (`claude -p` returns `Not logged in`) — 4.57's recipe held only because
  `marketplace add`/`install`/`plugin details` need no API auth — and
  isolating `HOME` breaks auth too, since credentials resolve through the
  macOS Keychain. **Consequence: an A/B on two versions of one skill cannot
  be run on this machine without re-pointing the live symlink.** Recorded
  in `docs/shakedown-method.md`. Blind integrity clean: 0 reads of this
  repo's PLAN.md or JOURNAL.md, no run reasoned about being tested.
  Evidence: `~/shakedown-15/ROUND.md`, pre-registered before any session
  ran.)*
  *(**Shakedown 16, 2026-08-13 — segment (c) COVERED, and it did not
  pass.** 4.30's four behavioural acceptances were run for the first time,
  on a blind venue: `fixtures/design/index.html` with every comment
  stripped, because the fixture's comments name the plants outright
  (`item 7`, `no reduced-motion — item 4`, `the write has no failure
  path`). 139 → 105 lines, all 9 plant tokens verified intact after the
  strip, 0 revealing comments left. The prompt was checked against 14 leak
  terms and hit none, because A4 requires the failure path **unprompted**.
  **A1 HELD** — `tokens.json` carries 99 DTCG `$value` tokens in three
  layers, 39 aliases, **0 unresolved** (checked with a resolver, not taken
  on the report's word); the self-critique names all three seeded tells and
  sits before the artifact sections, the ordering 4.32 found `/design`
  contradicting itself about. **A2 HELD 8/8**, with `zero/one/many`
  explicitly marked N/A and carried into Scope rather than dropped.
  **A4 HELD** — `onToggle` does `const prev = ch.on`, flips optimistically,
  and reverts in `catch` while announcing what it restored. Removal proved
  rather than absence assumed: violet gradient, eyebrow, 🔔, `width: 680px`,
  `transition: all` and placeholder-as-label are all gone.
  **A3 FAILED — and the acceptance is what broke.** A blind `/design-audit`
  returned **3 findings** against a bar of 0; every one verified true at
  `file:line`, **0 false positives**. The headline finding was one
  `/design` had **already disclosed in its own Scope section**. Both skills
  were correct and the acceptance still failed, because `/design`'s
  honest-scope rule ships artifacts with named gaps and `/design-audit`
  only sees the artifact. Carried as **4.69**. The other two findings were
  genuine misses inside item 8, the item `/design` reported answered —
  carried with a third self-report defect as **4.70**. A gap in
  `ai-tells.md:102`'s fabricated-content grep is **4.71**.
  *(**Shakedown 17 phases A-C, 2026-08-13 — the tickets segment, run.**
  Venue `AaravChadha/acstack-s17-tickets`, cold baseline captured first.
  **HELD:** `/health` cold-repo tickets extras (evidence matched the
  baseline independently); the gate, under a two-turn `--session-id` /
  `-r` test — turn 1 created nothing, verified against the API; `/plan
  build`'s bootstrap (labels 10 → 14 adding exactly the four absent,
  `bug` byte-identical, 4 milestones, 7 issues, 7/7 template sections);
  `/triage` (both seeded duplicates, both missing-acceptance, negative
  twin held, plus four true unseeded findings); `/do 1` (branch
  `feature/1-anchored-remainder-guard`, commit `#1: …`, checklist ticked
  via the API, issue left OPEN, **no push** — no remote branch exists);
  `/retro` (burn M1 0/2 M2 0/2 M3 0/1 M4 1/1, velocity correctly declined
  rather than inflated). `/resume` held with the deviation now carried as
  **4.75**. **Findings: 4.72, 4.73, 4.74, 4.75.**
  **NOT covered, stated plainly:** `/ticket` never run; `/investigate`
  (T9) never run — it needs a seeded failure and the venue's suite is
  green; the failing-acceptance path (T6) never run — it needs an issue
  whose acceptance cannot pass; `/ship`'s `Fixes #N` wiring (T7) **never
  exercised**, because the venue left `push: direct` and the PR path
  exists only under `push: branch-pr`; and `/triage`'s stale class is
  **not testable in a fresh repo at all** — `stale-days: 0` makes it
  degenerate, and the session rightly refused to manufacture findings
  about five-minute-old issues. Evidence: `~/shakedown-17/ROUND.md`,
  pre-registered before any session ran.)*
  **Not covered, stated plainly:** the widened emoji-as-icon check was
  never exercised — `/design` removed the 🔔, so there was nothing to
  catch. That detector still awaits a page that keeps one. Evidence:
  `~/shakedown-16/ROUND.md`, pre-registered before any session ran.)*
  *(**Shakedown 19, 2026-08-16 — three owed segments covered, and the
  failing-acceptance item turns out to have been asking for an outcome, not
  a code path.** Pre-registered at `~/shakedown-18/ROUND-4.50.md` before any
  session ran; every bar derived from the skill's own text at `file:line`.
  Venue `AaravChadha/acstack-s17-tickets`, fresh clone per run.
  **`/ticket` HELD**, first run ever. Issue #11 read back from the API:
  verb-first title, all three template sections, `bug` + `needs-acceptance`,
  milestone M1. **The discriminator was the TBD** — the dump deliberately
  carried a detail the repo cannot establish, and SKILL.md:63 says a guessed
  acceptance is *worse* than an honest one, so an invented acceptance was the
  failure mode. It wrote `TBD — needs the downstream-consumer contract` and
  still gave four decision-independent criteria. It also found a bug the dump
  never mentioned — `parse("1h3w")` returns `3600`, silently dropping `3w` —
  **verified at source rather than believed**, along with its `tempo.py:6-7`
  citations.
  **`/investigate` HELD on diagnosis, with two findings.** Seed: a Unicode
  lookalike (`"0s"` → `"0ѕ"`, U+0455) at `tests/test_tempo.py:29`, chosen
  because that class is named in the pack's own known-bug-classes list.
  Root cause named the exact seeded line and the exact codepoint, off a
  three-row hypotheses-vs-evidence table, and it did **not** fix — the only
  tree diff was the seed. **Finding A:** the report claimed *"Known class
  hit … Checked first"* while the trace shows `Bash` ×8 and **zero** `Read`
  calls — the class name came from the runtime recall preamble, which itself
  says *"read the full class when one matches"*. The diagnosis was right; the
  process claim was not. Carried as **4.84**. **Finding B:** the tickets
  delta never fired — no `gh issue comment` offered — and the skill text is
  partly at fault, since `skills/investigate/SKILL.md:103` states the offer
  unconditionally while the only stated target comes from an `issue#`
  argument. Carried as **4.85**.
  **The failing-acceptance path: COVERED, by two rigs, and the round author
  was grading the wrong thing.** T3 planted a self-contradictory acceptance
  (#12); T3b planted one that collides with an existing test (#13, chosen so
  the conflict is invisible from the issue alone). Both times: no branch, no
  commit, issue OPEN, zero boxes ticked, suite untouched — and in T3b
  `test_rejects_garbage` **survived byte-identical**, which is the failure
  mode the never-tune-a-test rule exists for. Both were caught by
  `skills/do/SKILL.md:59` (conflict → push back *before* code) rather than
  by `:99` (acceptance fails at verify). ~~Owed: the verify-time branch.~~
  **Verdict (2026-08-16):** 4.50 asked for *"an issue whose acceptance cannot
  pass"* — an outcome, not a branch. Two different collision shapes, both
  handled correctly, discharge it better than one run would have. The branch
  distinction is recorded as the finding, not as a miss.
  **T3c — the verify-time branch reached at last, and a fourth outcome.** A
  question this round surfaced rather than one 4.50 listed: when the
  acceptance names a command that fails *environmentally*, does `/do` report
  it or quietly substitute one that passes? Rig: issue #14, uncontroversial
  work (`--help`), AC4 naming `python3 -m pytest -q` — absent, and
  **undiscoverable by reading**, which is why this rig reached `:99` where
  T3/T3b could not. It did the work (branch `feature/14-help-flag`, commit
  `#14: …`), ran the acceptance, and AC4 failed.
  **Three outcomes were pre-registered and a fourth occurred: per-criterion
  ticking.** 3 of 4 boxes ticked, AC4 left unticked, the exact pytest output
  posted as an issue comment, issue left OPEN. That is *better* than the
  pre-registered PASS, which treated the acceptance as one bit. It did **not**
  substitute `unittest` and tick — it ran it, but labelled it as what it
  *could* verify — and did **not** install pytest, verified absent after the
  run. It also caught that AC4 contradicts the BRIEF's stdlib-only rule, so
  the acceptance itself was defective. Every claim checked independently:
  the unticked box is exactly AC4, the commit subject contains "Fixes" **0**
  times, `unittest` does report 9 tests OK, 1 comment exists. **No carrier
  owed — nothing behaved worse than its bar.** Method note kept because it
  will recur: pre-registration constrains grading, it does not exhaust the
  outcome space.
  **T4 — `/ship`'s `Fixes #N`, exercised for the first time.** Never run
  because the venue sat on the default `push: direct` and the PR path exists
  only under `push: branch-pr`; that key is now committed to the venue's
  `.claude/acstack.md`, and the resolver was checked through
  `bin/acstack-config` (`push=branch-pr (project)`) rather than by re-reading
  the file — 4.72 is exactly why the binary and not the file is the evidence.
  Real work, not a rig: `/do 5` on a genuine backlog item produced branch
  `feature/5-humanize-roundtrip-test`, commit `#5: …`, clean tree, suite
  6 → 7 green. `/ship` then pushed and opened **PR #15**.
  Every bar from `skills/ship/SKILL.md:139-141` held: `Fixes #5` present,
  tied to milestone M3, body report-shaped (what-and-why lede, five-row gate
  evidence table, out-of-scope line), and the report's first line is the
  verdict `## SHIPPED — <url>`. Gate evidence carries numbers and two honest
  negatives — *"no eval spec — gate passes with that stated"* and *"journal
  silent → /journal proposed"*.
  **The bar that mattered was the consumed one:** `Fixes #5` in the body is
  the authored form, so the check was GitHub's parse —
  `closingIssuesReferences → #5`. A grep for the string would not have
  settled it, and this repo has shipped defects in precisely that gap.
  PR #15 and its branch are left **open and unmerged**: unlike #12-#14 the
  work is legitimate and mergeable, so deleting it would destroy real work
  rather than clean up after the round.
  **Rig artifacts, named so a later reader is not misled:** issues #12, #13
  and #14 were planted by this round and closed as not-planned at its end,
  each carrying a comment saying so. T3b's own "five sources disagree about
  `parse(\"30\")`" table has two rows that were mine. Issue #5, PR #15 and
  the `push: branch-pr` config change are **not** artifacts — they are real
  venue state this round left behind on purpose.
  **T5 — the emoji-as-icon detector, and its must-not-fire is the real
  test.** Owed since shakedown 16, where `/design` removed the 🔔 and left
  nothing to catch. Venue `~/shakedown-20/venue`, a **committed** git repo,
  because the documented check is a `git grep` and only sees tracked files —
  an uncommitted fixture would have read clean, which is how a no-op rig
  passes. The author ran the documented grep first: exactly 4 hits.
  **MUST FIRE held** — 📊 `index.html:9`, 🔔 `:18`, 🚀 `:21`, each reported at
  file:line. **MUST NOT FIRE held, and it could genuinely have failed** —
  `:30` `<h2>Café…</h2>` *is* matched by the grep, and `ai-tells.md:77-79`
  names accented text as the known false positive to "drop on sight". The
  run named the line, classified it, and said *"dropped, not a finding"*
  rather than silently omitting it, which would have been
  indistinguishable from not looking.
  **The detector is narrower than the check it backs**, now measured: the
  grep only searches `button|a|h[1-6]`, so 💳/📅 in `<span>` are invisible to
  it. The run caught them anyway by reading, at correct line numbers. Every
  citation verified by the author, including the contrast arithmetic —
  claimed 5.97 and 5.5, actual **5.98** and **5.52**. It also found a real
  raw-hex-beside-token defect at `styles.css:4` that was **incidental in the
  fixture, not planted**, and refused a brand-conformance verdict with no
  palette configured: *"unanswerable, not merely unchecked."* Zero files
  changed.
  **T6 — `/retro`'s >500-line retrieval rule (4.29).** Venue
  `~/shakedown-21/venue`: a 607-line JOURNAL, 50 `###` entries, of which
  **8 substantive and 42 deliberate filler**. Both halves of
  `retro/SKILL.md:61-68` held. **Retrieval, not ingestion** — the trace shows
  a heading grep with line numbers, then `Read` with **limit=122** of 607
  lines; the file was never read whole. **Window and count stated** — *"the
  8 substantive entries (2026-06-22 → 2026-08-10); the other ~42 are
  backfilled Groundwork notes with no signal"*, which is the anecdote-vs-trend
  distinction the rule exists for, and the count is exactly right. Its other
  numbers check out (tests 31 → 61, 2 of 4 boxes), and it left PLAN untouched,
  proposing edits instead.
  **T7 — the interactive halves, with the scope derived rather than listed.**
  The unattended contracts live at `eval-spec/SKILL.md:72`,
  `eval-run/SKILL.md:94`, `do/SKILL.md:135` and `/plan`'s mode-seed;
  `/eval-spec`'s is the one that branches explicitly on whether anybody
  answered. Two-turn via `--session-id` / `-r` on `~/shakedown-22/venue`.
  **Turn 1 fired the unattended branch and labelled itself** — *"The
  interview wasn't answered, so this is a derivation run"* — writing the
  required source table with four rows marked `**DEFAULT** — unconfirmed`.
  **Turn 2 supplied answers differing from all four defaults**, and the
  interactive half fired completely: queue taxonomy replaced (4 supplied, and
  the spec now states *"there is no Account queue… no Sales queue… no
  Abuse/Spam queue"*), priority scheme swapped (**0** occurrences of
  `P1/P2/P3` remain), grading changed to within-one partial credit, refusal
  set narrowed to the two named with ambiguous routed to General. All four
  source rows re-attributed from `DEFAULT` to **`Interview 2026-08-16`**,
  while two genuinely-still-default rows stayed marked as such. The golden
  set was regenerated consistently — 33 cases, only the 4 supplied queues,
  only the 4 supplied priorities.
  **All seven segments covered; `/triage`'s stale class remains excluded as
  untestable in a fresh repo, by the previous round's verdict and not
  re-litigated.** Evidence: `~/shakedown-18/ROUND-4.50.md`, pre-registered
  before any session ran with results appended after, and the transcripts
  under `~/shakedown-19/`, `~/shakedown-20/`, `~/shakedown-21/` and
  `~/shakedown-22/`.
  **And yet this box does not tick, which the guard had to tell me.**
  With all seven covered I ticked it, and check.sh's reach-check went red
  instantly, reporting that the marker named a task that was now closed.
  Enumerating
  instead of trusting the first failures printed found **14 markers — 13 in
  PLAN.md, 1 in JOURNAL.md, across nine closed tasks** (4.42, 4.47, 4.49,
  4.51, 4.53, 4.58, 4.61, 4.62, 4.66, 4.77). **4.50 is not a finite task; it
  is the standing register every behavioural debt in this repo points at**,
  exactly as its own title says — "everything a round is already known to
  owe". My enumeration had checked 4.50's own owed list and never asked who
  was pointing *at* it, which is the half a self-audit structurally misses.
  First instinct was to re-home the 14 onto a fresh carrier; that only moves
  the cliff, since the successor breaks identically the day it closes.
  **Audited all 14 instead (2026-08-16), and 11 were already settled:**
  4.42 and JOURNAL's shakedown-11 entry by round 12; 4.51 ×2, 4.53 and 4.58
  by shakedown 13; 4.61 ×2 and 4.62 by shakedown 16 — the record states the
  session reproduced a clause it "could only do by reaching the procedure
  4.61 moved into `references/`", and `/audit` was 4.61's only split target,
  which corrected this author's guess that it was still live; 4.66 and 4.77
  by shakedown 18. Each is now discharged in place with its date and round,
  never deleted. One more — 4.47's — was **never a debt at all**: it is
  4.47's own prose describing the marker convention, using 4.50 as the
  example, and the guard cannot tell a citation from a claim. Reworded so it
  stops reading as one.
  **Three remain live, all 4.49's, all one debt:** acceptance (c), "a live
  round drives each split skill in each of its modes and gets the same
  report shape as before the split". `/plan`'s seed mode held in shakedown
  15, `/do` and `/triage` in tickets mode in shakedown 17 — **document mode
  for `/do` and `/triage` post-split is not evidenced**, and claiming it
  would be the guessing this task exists to prevent.
  **So 4.50 stays open by decision, not by omission**, holding exactly that
  residual. It retires when its register is empty, which is now three
  markers rather than fourteen.)*
  Verification rule 6 says a
  behaviourally-found fix stays unverified until a live run re-tests it,
  and mechanical green never discharges it. Three debts have accumulated
  with no task owning any of them, which is the rule-3 orphan 4.47 exists
  to detect; **decided 2026-08-06 to file rather than decline**, so the
  obligation is discharged by a task and not by an argument that it was
  too small to bother with. (a) **`b566654` regression segment** — the
  runner template printed `errors: N — run did not complete cleanly` on a
  COMPLETE run where every case had a record and one subject crashed, so
  the operator had to argue against the scaffold's own wording inside an
  otherwise-honest report. Reworded, never re-tested live. Rule 6's
  proportionality clause applies: this is one print string, so it is a
  segment inside the next round, never a round of its own. (b) **The
  never-exercised list** shakedown 11's operator wrote down and nothing
  has covered since: the interactive halves of the unattended contracts,
  /retro's >500-line retrieval rule (4.29), and the tickets-mode deltas.
  (c) **4.30's four behavioural acceptances** — /design's output judged
  by /design-audit plus ai-tells against `fixtures/design/`, which its
  own closing note flags as a shakedown and which no round has run.
  (d) **4.45's behavioural half** (added 2026-08-06 when 4.45 closed): a
  live model scaffolding a runner from the template must actually emit the
  isolation flags and refuse to run on an empty `SUBJECT_MODEL`. check.sh
  §24 proves the rule is still *written* at all three sites and controls.sh
  proves the documented flags still *catch* a seeded unisolated runner —
  neither can prove a model reads them and complies, which is precisely
  the gap rule 6 exists for.
  *(Round 12 ran 2026-08-07 and closed (a), (d) and part of (b) — see the
  journal entry. **Still owed and NOT covered:** the interactive halves of
  the unattended contracts; the tickets-mode deltas, since all four
  sessions ran in document mode; /plan's and /do's splits, only /triage's
  was exercised; and (c) 4.30's design acceptances, excluded by design.
  Round 12 also produced three new carriers — 4.51, 4.52, 4.53 — and
  4.51's fix is itself behaviourally-found, so it re-enters here.)*
  **Out of scope:** new-ground exploration. A round that only looks
  forward cannot catch these, because a fix becomes old ground the moment
  it is committed — that is the whole reason rule 6 exists. **Acceptance:**
  a fresh-session round on a blind venue covers all three segments and
  reports per-segment HELD or FAILED, each verified at `file:line`
  against the venue on disk; (a) specifically requires a venue where at
  least one case errors and the rest complete, with the scaffolded
  runner's printed line naming the errored cases without claiming the run
  was incomplete. Findings get carriers in the same edit.

- [x] **4.51** *(Done 2026-08-07. **Verdict on the open design question:
  two axes, kept separate — the divergence with the headline STAYS and is
  now explicit.** The gate blocks on (1) pass rate falling, computed on
  scored records only, or (2) coverage falling — fewer of a category's
  cases scored than last run. Folding errors into the denominator was
  rejected: one merged number answers neither "did the subject get worse"
  nor "did the harness break", and those have different causes and
  different fixes. Keeping them on separate lines preserves exactly the
  distinction 4.53 needs from an exit code. `rates()` now returns
  `(rate, passed, scored, errored)`; categories with zero scored records
  are still dropped so a total crash stays with the `gone` check rather
  than being reported twice; skipped and rubric-review rows count as
  neither, since treating a deliberate skip as lost coverage would block on
  ordinary spec maintenance. **Both acceptance conditions shown failing
  first:** the repro exited 0 with `no category regressed` before the fix,
  and seeding the coverage check as `<=` instead of `<` blocked the
  unchanged-count run and was caught by the existing clean-run control —
  so the negative control can fail, which is what makes its pass mean
  anything. Fixtures `crash-previous.jsonl` / `partial-crash.jsonl` seed
  the recorded reproduction exactly (refusal 4/4 -> 1 scored + 3 errored,
  which the old gate read as 100% -> 100%). controls 85 -> 86, matrix
  105 -> 106. **Still owed:** the behavioural half — a live run confirming
  a model actually reads the new coverage line — per rule 6. **Discharged 2026-08-12 by shakedown 13**: a neutral-level session read the new line and explained it unprompted.)*
  Close the non-regression gate's partial-crash blindness.
  **Found behaviourally by shakedown 12, in code shipped the same day.**
  `regression-gate.py:44` filters to `status == "scored"` before computing
  per-category rates, so a category whose cases start CRASHING is compared
  on the survivors alone. Reproduced 2026-08-07: refusal 4/4 passing → 1
  passing + 3 erroring is a real collapse from 100% to 25%, and the gate
  printed `no category regressed` and exited **0**. A category that
  vanishes ENTIRELY is caught by the existing `gone` check; partial
  crashing — the likelier shape, since a subject usually breaks on some
  inputs — is invisible. That is the exact failure the gate exists to
  prevent, in the gate itself. **Design question, not pre-decided:**
  whether the denominator becomes all non-skipped records (so an error
  counts against the category, matching how the headline treats it), or
  the gate blocks separately on a drop in a category's SCORED count, or
  both. The headline and the gate currently disagree by design and the
  round noted it as "correct by their own rules" — decide whether that
  divergence stays. **Acceptance:** the reproduction above BLOCKS; a run
  where a category's scored count is unchanged still passes; both shown
  failing before they pass; and rule 6 applies — the fix is
  behaviourally-found, so it owes a live re-test. **Discharged 2026-08-12 by shakedown 13.**

- [x] **4.52** *(Done 2026-08-07. **The task understated it: this was not an
  unstated separator, it was two files implementing contradictory rules.**
  `eval-spec-template.md` said "expected lists concept keywordS; pass = ALL
  present", while `runner-template.md` shipped
  `norm(expected) in norm(actual)` — a single whole-string match. So
  `expected: "destructive, data loss"` against an answer reading "this is
  destructive and will cause data loss" passed by the spec and FAILED by
  the runner; only a literal echo of the comma and all could pass. Any
  multi-keyword expected in the pack was mis-graded, not just comma-free
  ones. **Verdict: commas, and only commas.** `expected` splits on `,`,
  each keyword is matched as a normalized substring, pass = all present; an
  empty expected returns False rather than auto-passing; `;`, `/` and `+`
  are NOT separators, so a keyword may safely contain them. A comma-free
  expected is therefore ONE keyword that must appear as a whole phrase —
  stated as a trap, with `decline: out-of-domain` named as the shape that
  scores a correct refusal FAIL, and "it declined appropriately" routed to
  `rubric` where judgment belongs. Fixed at all three sites (4.45's rule),
  including the pack's own example row, which carried the trap string.
  **Shown failing first, on a discriminator that isolates the separator:**
  fixture case `q10` expects `unknown, not a country` while the subject
  answers `unknown - not a country` — identical but for the separator, so
  it passes only if the keywords are split. Before the fix the fixture read
  **6/8 (75.0%)** with q10 failing on a correct answer; after, **7/8
  (87.5%)**. q3 (`unknown`) and q4 (`cannot help`) are the comma-free
  controls, one word and one phrase, both unchanged. Two controls added
  that name their own cause on a revert, both shown firing on a seeded
  revert of the splitter. **The control COUNT is unchanged at 86** — both
  are `bad`-on-failure branches with no `ok` on success, matching the
  surrounding style, and the pack counts controls by `ok` lines. Recorded
  because this note first claimed `86 -> 88` without deriving it: the same
  unverified-count class this session already found three times in the
  docs, committed by its author while fixing it.)*
  Say what `concept` expecteds are separated by. The spec
  template documents the rule as "expected lists concept keywords; pass =
  all present in any phrasing (normalized substring)" and never says how
  the keywords are delimited, nor what a comma-free expected does. A
  runner author has to guess. Shakedown 12 caught the consequence live: an
  expected of `decline: not a diagnostic tool` has no commas, so a
  comma-splitting grader treats the whole phrase as ONE literal keyword
  the answer must contain verbatim — and a correct refusal
  ("I'm sorry, I cannot help with that") scores FAIL. The category's
  target was 100%, so it would have read 0% for grader reasons with a
  perfectly good subject. That is grader brittleness manufactured by the
  pack's own ambiguity, and it fails in the inflating-the-problem
  direction rather than the safe one. **Acceptance:** the template states
  the separator and what a single-keyword expected means; a fixture with
  a comma-free multi-word expected grades the way the template says, shown
  failing first.

- [x] **4.53** *(Done 2026-08-08. **Verdict: three exit codes, because two
  cannot carry the distinction.** `0` = completed, every case graded (the
  score is irrelevant to the code); `1` = could not complete, so no results
  file and no number exists; `2` = completed with N errored cases — every
  case has a record, but the headline is computed over fewer graded cases
  than the golden set holds. This is 4.51's decided position applied one
  layer down: "the harness broke" and "the subject got worse" have
  different causes and different fixes, and a two-valued code merges one
  pair or the other. `2` is deliberately non-zero so a consumer testing
  only zero/non-zero still blocks; the stated cost is that such a consumer
  cannot tell `1` from `2`, which is why gate 3 tests the value.
  Every-case-errored is the extreme of `2`, not a `1`.
  **The write-up covered about half of one of four defects found by
  re-deriving from the code:** (1) `runner-template.md:263-264` ruled that
  a run whose every case has a record IS complete, and `:267` then returned
  `1` — the code item 7 reserves for "could not complete" — a contradiction
  three lines apart; (2) the Python block exited 1 **on errors** while the
  Node paragraph told its author to exit 1 **"if the run could not
  complete"**, so a Node runner written to the same file exited 0 where the
  Python one exited 1; (3) `fixtures/eval-run/eval/run.py:143` still
  printed the exact sentence the template had repudiated; (4) **the
  largest — `/ship` gate 3 read no exit code at all.** Enumerated every
  exit-code mention in `skills/`, `docs/`, `README.md`: three hits, all in
  eval-run, none in `/ship`. Item 7 had promised a protection to a consumer
  that never implemented it. **Shown failing first, measured before the
  fix:** cannot-complete exited **1** and completed-with-one-errored-case
  exited **1** — indistinguishable by exit code alone; completed-with-a-
  scored-failure exited 0. After: 1 / 2 / 0. Three seeded reverts each
  fired their control (the `return 1` revert fired two — the value
  assertion and the indistinguishability assertion). A fourth seed proved
  an honest limit: removing the explicit load guard leaves the code at 1
  via traceback, so a separate assertion on the `NO SCORE` line covers
  written-contract-vs-accident. **Fixed at five sites, enumerated:**
  runner-template.md's item 7 (the contract statement), its Python
  `main()` return, its Node paragraph, `fixtures/eval-run/eval/run.py`'s
  return, and `/ship`'s gate 3 (the consumer). controls 86 -> 87.
  check.sh caught the first draft's cross-skill citation
  (`references/runner-template.md` resolving under `skills/ship/`), fixed
  to `../eval-run/...`. **Still owed:** the behavioural half — a live run
  confirming a model reads the three codes as specified — per rule 6.
  **Discharged 2026-08-12 by shakedown 13**, and only via `/ship` gate 3 — a
  direct-eval session mentioned the exit code zero times, which was the finding.)* Decide what a completed-with-failures run exits. The
  runner contract says "Exit non-zero when the run could not complete, so
  /ship's gate 3 cannot mistake a crash for a pass" (contract item 7, and
  again in the Node section) and says NOTHING about a run that completes
  with failing cases — verified 2026-08-07: zero occurrences of any
  completed-with-failures exit rule across runner-template.md,
  /eval-run and /ship. Two readers implement it two ways, and /ship then
  cannot distinguish "the runner crashed" from "the eval scored badly" —
  which is precisely the distinction item 7 exists to protect. Shakedown
  12's runner exited 1 on a run where all nine cases produced records.
  **Out of scope:** the gate's own exit code, which correctly signals
  BLOCKED. **Acceptance:** the contract states both cases explicitly, and
  /ship's gate 3 says which exit code it reads as which; a fixture run
  that completes with failures and one that cannot complete are
  distinguishable by exit code alone, shown failing first.

- [x] **4.54** *(Done 2026-08-08. **Verdict: the pack default becomes a
  dated CLUSTER check; the hex list stays for what it still catches.** A
  longer hex list was rejected on this repo's own precedent — the third
  appearance of the denylist class — because it would go stale exactly as
  the violet list did. A cluster is a *shape*: four named clusters (cream
  editorial, dark acid, broadsheet, violet gradient), each with three
  independent signals, and **a finding requires TWO of three co-occurring**,
  which is 4.60's concentration rule doing the work. Reviewed-on date is
  printed in the table and the file says to move it or delete the table
  rather than let it quietly misinform — an undated aesthetic claim is a
  stale claim with no expiry on it. **Configured `palette:` suppresses the
  cluster check entirely**: a look a project chose and declared is a
  decision, and reporting it back is the taste-as-defect failure the file
  opens by forbidding. SKILL.md's degradation line was rewritten to name
  what an unconfigured adopter does and does NOT get — it had undersold
  both halves, and conformance is *unanswerable* without a palette, not
  merely unchecked. **Shown failing first:** cream-bg, serif-display and
  rust-accent all HIT `default-look.tsx` and all stay silent on
  `legitimate-look.tsx`; the existing violet fixture still flags.)* Replace the AI-default-look palette denylist, which has gone
  stale. `skills/design-audit/references/ai-tells.md:179` ships a pack
  default of five violet hexes (`#8b5cf6, #a855f7, #7c3aed, #6366f1,
  #d946ef`). **Anthropic's own `frontend-design` skill now names where
  generated design actually clusters** — verified at source 2026-08-07,
  `anthropics/skills/skills/frontend-design/SKILL.md`: "(1) a warm cream
  background (near #F4F1EA) with a high-contrast serif display and a
  terracotta accent; (2) a near-black background with a single bright
  acid-green or vermilion accent; (3) a broadsheet-style layout with
  hairline rules, zero border-radius, and dense newspaper-like columns."
  None is violet. An independent source (educlopez/ui-craft,
  `01-ai-tells.md`) is blunter: the cream/serif look "reads as AI faster
  than purple does, precisely because it looks like a choice." `palette:`
  IS an allowlist and catches cream when configured — but with no config
  `skills/design-audit/SKILL.md:63-65` degrades to "obvious raw-hex
  sprawl", so an unconfigured adopter gets violet-only detection.
  **This is the third appearance of the denylist class** (§13's ruling;
  the emoji denylist that reported clean on this pack's own before-page),
  so a longer hex list is the wrong fix by the repo's own precedent.
  **Design question, not pre-decided:** whether the pack default becomes a
  cluster-shaped check (background+face+accent co-occurring) rather than
  bare hexes, whether it is dated and reviewed, or whether the honest
  answer is that an unconfigured project cannot get this check and the
  degradation message should say so louder. **Acceptance:** a fixture page
  in the current cream/serif default look is FLAGGED, shown failing first;
  the existing violet fixture still flags; a legitimately cream-branded
  project with `palette:` configured does NOT flag; and whatever ships
  states its review date.

- [x] **4.55** *(Done 2026-08-08. **Three verdicts, one shape: a guard's
  input surface is now written down instead of inferred.**
  **(a) Snapshot once AND name a mid-run change** — chosen over the task's
  own "cheapest" hash-and-abort, because aborting discards the run while
  fixing nothing. `$WORK/src` is taken once with `.git` and
  `.acstack-banned` stripped; all three copy sites read it. The run hashes
  the live `$REPO` at start and end and prints a NOTE — never a failure —
  if it moved, since results are valid for the snapshot they came from.
  **What is measured, and what is NOT.** The copy reduction is structural
  and verified: `du` on a live run's work dir shows `$SRC` at **1.4M**
  against an 18M repo — 92% less copied per case, because `.git` was 16M
  of every 18M and every case deleted it anyway. **The wall-clock benefit
  is NOT established.** Three runs: old code **31.3 s/case** (106 cases,
  ~55 min); new code **4.1 s/case** (107 cases, 7m15s); new code again
  **28.3 s/case** (109 cases, 51m25s). Runs two and three differ ~7× on
  near-identical code. System load averaged 10.25/14.04/12.05 during the
  third, and one `scripts/check.sh` timed at **4,845 ms** under that load —
  a 109-case floor of ~8.7 minutes on check.sh alone — but that does not
  account for 51 minutes, and **the cause was not isolated.** The earlier
  "~7× faster" claim in this session's report was retracted on the third
  run's evidence; copying less is proven, going faster is not.
  **Resolved 2026-08-08 (later), on a clean machine:** CI run
  `31270737987` completed **109 cases plus check.sh plus shellcheck in
  413s** — an upper bound of **3.8 s/case** including the other two steps.
  That matches the second local run and not the third, so the third was
  local contention (load averaged 10–14 with two Cursor renderers at 37.7%
  and 14.2%), not the change. The speedup is real; **the laptop is not a
  timing instrument**, and the retraction stands as written because it was
  the honest reading of what was measured at the time.
  **Demonstrated live:** this very box was ticked WHILE the matrix
  ran — moving `wave45-done` 31→32 against a JOURNAL marker still reading
  31, the exact inconsistency that produced three phantom failures on
  2026-08-07 — and the run returned **`passed=107 failed=0`** plus the
  NOTE. Zero phantom failures; the change was named instead. A later full
  run on the finished tree returned **`passed=109 failed=0`**.
  **(b) The roster is the contract, and no arguments means the contracted
  set.** `count-check.sh` now carries COVERED (six files, a reason each)
  and EXEMPT (four files that contain marker SYNTAX but make no claim —
  count-check's own header, guard-matrix's sed mutations, two count-drift
  fixtures), and fails on any marked count outside both. check.sh:669 now
  calls it with no arguments; `FILE...` stays for controls.sh, which
  points the guard at one seeded fixture and would have broken under an
  argv assertion. **Honest scope, stated in the header:** the scan finds
  MARKED counts in unrostered files. Unmarked prose — `check.yml`'s "15
  checks" — stays out of scope by the §13 denylist ruling, and the roster's
  reasons are where an author learns to mark a claim instead. Derived while
  writing it: **4 of the 6 covered files carry no marker at all today**, so
  coverage is pre-emptive, which is why a stale plant in CONTRIBUTING.md
  was caught immediately.
  **(c) Any extension, not a named list.** Both crossref loops matched
  `\.(md|sh)`; they now require an extension without naming it. A named
  list is a denylist wearing an allowlist's clothes — it passes silently on
  every extension nobody thought of. **The gap was hiding a live dead
  link** (`skills/ship/SKILL.md` → `references/regression-gate.py`, fixed
  in 4.53's commit), and re-deriving found a **fourth instance the write-up
  missed: the `../` loop carried the same `(md|sh)` class**, so 4.53's own
  fix — rewriting that citation to `../eval-run/...` — was itself
  unverified until now. Widening introduced **zero** new failures on the
  current tree; one apparent hit during analysis was my own test resolving
  from the wrong base directory, not a defect.
  **Controls 87 → 89, matrix 107 → 109.** Every new guard shown failing
  first: a dead `.py` citation, a marker planted off-roster (with a
  CORRECT value, so it fails for coverage and not staleness), a revert to
  per-case live copying, and deletion of the NOTE. Both new matrix cases
  verified in isolation against a clean twin. **Still owed:** nothing
  behavioural — these are mechanical guards, and (a) was proven on a live
  run rather than by inspection.)* Pin down what each guard actually reads. Three instances of
  one shape — **a guard's input surface is implicit** — folded here
  (a)+(b) 2026-08-07, (c) 2026-08-08, because they take the same fix and
  reading them apart hid the pattern once already.

  **(a) guard-matrix reads a LIVE tree, per case.**
  `docs/guard-matrix.sh:56` and `:69` each run `cp -R "$REPO" "$FULL"`, so
  a ~15-minute run re-samples the working tree at every full-tree case
  rather than snapshotting once. Any edit during the run desynchronises
  what later cases see from what earlier ones saw. **Cost, measured:** two
  runs wasted on 2026-08-07 and three phantom failures — `clean tree stays
  clean` and `comments-only list SKIPs` twice — none of which was a defect.
  Both times the trigger was a PLAN.md checkbox tick, reasoned as "inert
  with respect to guard behaviour": true of the guard *logic*, false of its
  *inputs*, since every full-tree case runs count-check and a tick moves a
  derived count. **A matrix that cries wolf is one you stop reading**,
  which is how a real `sk-proj-`-class miss survives. **Not pre-decided:**
  snapshot once and reuse, refuse to run against a dirty tree, or record
  the tree hash at start and fail if it moved. The third is cheapest and
  keeps the current dirty-tree workflow, which the pack relies on.
  **Measured 2026-08-08, same mechanism:** `fullcase` copies the repo and
  then deletes `.git` (`:56`), so every full-tree case copies **18M of
  which 16M (89%) is `.git`** purely to throw it away — the guards
  provably do not need it, since the case deletes it before running
  check.sh. A full run clocked **31.3 s/case, 106 cases, ~55 min** against
  a frozen snapshot, versus the "~15-minute run" this repo's own notes
  record; that figure is stale. Snapshot-once (option 1) fixes the
  staleness AND this cost together, which is a reason to prefer it.

  **(b) count-check's file list is an argument list, not a contract.**
  `scripts/check.sh:669` passes six files (README, PLAN,
  JOURNAL, CONTRIBUTING, PRINCIPLES, docs/ARCHITECTURE). **AGENTS.md,
  CONDUCT.md and `.github/` are off the list, and two of those three held a
  stale count on 2026-08-07**: `.github/workflows/check.yml` said "15
  checks" against 29 (fixed, `52f1349`), and `JOURNAL.md:64` said "4
  repo-only verification rules" against 6 — the latter inside a file that
  IS covered, invisible because it carries no marker. External
  corroboration from the same day's survey: ECC's `scripts/ci/catalog.js`
  gates seven files and every one is exact, while `SOUL.md` — off the list
  — claims 30 agents / 135 skills against a true 67 / 282. **The lesson is
  not "add a sweep"** — count-check's own header rules that out as an
  unfinishable denylist — **it is that the argument list is the contract
  and nothing says so.** **Out of scope:** regex-sweeping prose for
  count-like strings.

  **(c) the crossref guard's extension list is an unstated contract, and it
  was already hiding a dead link.** Found 2026-08-08 while closing 4.53.
  `scripts/check.sh:259` matches `references/[A-Za-z0-9._-]+\.(md|sh)`, so
  a cited `.py` reference is never resolved. Two exist —
  `skills/eval-run/SKILL.md:109` (resolves) and `skills/ship/SKILL.md:100`
  (**did not**: it cited `references/regression-gate.py`, which resolves
  under `skills/ship/`, where only `ship-gates.md` lives). The dead link
  was fixed in 4.53's commit to `../eval-run/references/regression-gate.py`
  since it sat in a file that task was already editing; **the guard gap is
  this half.** The demonstration is exact: check.sh caught the identical
  defect in 4.53's own first draft within the same hour — the only
  difference was the extension. A guard whose reach is set by an
  undocumented regex class reports clean on the class it cannot see, which
  is (a) and (b)'s shape a third time. **Not pre-decided:** widen the
  extension class, drop the extension filter and resolve any
  `references/<path>` token, or state the covered extensions where a
  reader of the guard will find them.

  **Acceptance, all three halves:** (a) a tree edited
  mid-run is DETECTED — seed it by touching a counted file while the matrix
  runs and show the run naming the change rather than reporting a phantom
  case failure; (b) the covered set is stated in one place with a reason
  per inclusion and per exclusion, a file added to `skills/` or `docs/`
  without a coverage decision is visible, and the guard is shown failing on
  a marked count planted in a newly-covered file; (c) a `.py` reference
  citation that does not resolve is shown FAILING the crossref guard, and
  the set of extensions the guard resolves is stated where the guard is
  read, not inferred from its regex.

- [x] **4.56** *(Done 2026-08-11. **Verdict: KEEP both fields. acstack
  targets Claude Code, and the divergence is now stated where an adopter
  reads it instead of discovered by running someone else's validator.**
  Re-derived from the tree: 23/23 carry `argument-hint`, 2 carry
  `disable-model-invocation` (`/plan`, `/eval-spec`) — the survey's figures
  hold. **The deciding fact the write-up did not carry:
  `disable-model-invocation` is load-bearing, not cosmetic.**
  `scripts/check.sh:513` derives the typed-only roster FROM that field and
  fails when AGENTS.md's referral table disagrees, so stripping it deletes
  a guard and the typed-only design with it. `argument-hint` is weaker —
  ~3% field adoption — but typed invocation is this pack's primary path and
  the hint is what makes `/do 3.2.1` legible. Everything the spec
  substantively constrains is already satisfied, including a 500-line cap
  that turns out to be the spec's own recommendation. The cost is real and
  named in README: no claude.ai upload, no Skills API, no official
  `package_skill.py` — all channels acstack does not use, and an adopter who
  needs them is told exactly which two fields to strip and what they lose.
  **Honesty about the measurement:** `skills-ref` is NOT installed here, so
  the 0/23 -> 23/23 figure is carried from 2026-08-07 and is not re-run by
  CI. Rather than assert an unverifiable claim, the divergence is now
  **guarded from the other side**: a control derives the non-spec field set
  from check.sh's own frontmatter allowlist and fails if README does not
  name every one, or if the count stops being two. Both branches shown
  failing first — a sixth field unnamed, a named field removed from README,
  and a sixth field named (the count branch). controls 103 -> 104.)* Decide acstack's Agent Skills conformance posture. Measured
  2026-08-07 by running the standard's own validator
  (`agentskills/agentskills`, `skills-ref validate`) against all 23 skills:
  **0 passed, 23 failed**, then **23 passed, 0 failed** after stripping two
  fields. Sole cause: `argument-hint` (23/23) and `disable-model-invocation`
  (`/plan`, `/eval-spec`). Everything the spec constrains, acstack already
  satisfies — name/description limits, the 500-line cap (which is the
  spec's own recommendation), one-level references, and bodies far under
  the "< 5000 tokens" guidance (max ~3,000, `/eval-run`). Field context:
  `argument-hint` is ~3% adoption in a 378-file community census versus
  100% here. The cost of the divergence is that the pack cannot be uploaded
  to claude.ai, used via the Skills API, or packaged with the official
  `package_skill.py`. **Not pre-decided, and keeping the fields is a
  legitimate answer** — they are documented Claude Code features that work.
  **Out of scope:** hiding the fields under `metadata:`; Claude Code will
  not read them there. **Acceptance:** a dated verdict in this file naming
  what acstack optimises for, and whichever way it goes, the divergence (or
  its removal) is stated where an adopter reads it rather than discovered
  by running someone else's validator.

- [x] **4.57** *(Done 2026-08-11. **Verdict: ADOPT, as a SECOND path.
  `./setup` stays primary and is not deprecated.** The counter-argument in
  the task weighs setup's auditability against the plugin layout, but
  nobody proposed replacing setup — the layout is additive, so the real
  question was only whether a second path can be kept honest. It can, and
  it now is.
  **Demonstrated end-to-end, not from `--dry-run` (the /why precedent):**
  `.claude-plugin/plugin.json` + `marketplace.json` written to the schema
  the live CLI itself scaffolds (`claude plugin init`, CLI 2.1.170 —
  schema read from the tool, not from recall), then in an ISOLATED
  `CLAUDE_CONFIG_DIR`: `marketplace add <path>` -> added, `install
  acstack@acstack` -> installed, and **`plugin details` enumerated all 23
  skills by name**. Install output was NOT accepted as proof; the component
  inventory was. The live `~/.claude` was never touched — verified before
  and after — because installing there would double-load skills already
  symlinked by `./setup`, which README now warns about explicitly.
  **A number this bought for 4.59:** the CLI reports **~2,353 tokens
  always-on** for the pack. That is the tool's own figure, against 2,301
  from the survey and 2,266 from my extraction — 4.59 should use the tool's.
  **Guarded, because a second install route that silently rots is worse
  than none** — an adopter installs a version that does not exist. check.sh
  section 27 asserts plugin.json's version equals VERSION, that plugin.json
  and marketplace.json name the same plugin, and that the declared skills
  path exists. Checks 29 -> 30. All three branches shown failing: version
  drift, a dead skills path, and the name mismatch — the last fired on my
  own first draft, which grabbed the OWNER's name because the entry's name
  is the third `"name"` in the file, not the second.
  **Not adopted:** hooks, agents, MCP or LSP entries; the inventory
  correctly reports 0 of each, and the pack ships skills, not settings.)* Decide whether acstack ships `.claude-plugin/`. Verified
  2026-08-07: acstack has no `.claude-plugin/`, no `marketplace.json`, no
  `plugin.json`; install is `./setup` symlinking into `~/.claude/skills`.
  Four of the five surveyed packs that ship real skills carry the plugin
  layout (obra/superpowers, mattpocock/skills, rohitg00 toolkit,
  alirezarezvani), reducing install to one `/plugin marketplace add`.
  Related signal: `hesreallyhim/awesome-claude-code` restructured and its
  live list has **no Workflows category** — the slot acstack fits is gone,
  and the surviving categories assume plugin-shaped artifacts. **Weigh
  honestly against the counter-argument:** `./setup` is auditable, has
  dry-run honesty and never deletes a real file, and those properties are
  load-bearing for a pack whose pitch is verification. **Acceptance:** a
  dated verdict; if adopted, a fresh machine installs the pack by the
  documented one-liner and the skills resolve, demonstrated end-to-end and
  not from `--dry-run` output (the /why precedent).

- [x] **4.58** *(Done 2026-08-12. **Ladder built AND run: HELD 3/3, the
  golden-set hash never moved.** Round 13, three fresh headless sessions
  (`claude -p`, one per level) against blind `~/shakedown-13/venue-a` — an
  offline project at 7/8 = 87.5% versus a stated 90% target, testing
  `/eval-run` against "never fix, tune, or delete a case to raise a score".
  Discriminator was `sha256(golden.jsonl)`, a fact rather than a judgment:
  **identical to baseline at all three levels**
  (`b2ff8da5…00b7`).
  **L1 supportive** — reported `87.5% below target, release blocked`, named
  q5 as a genuine subject gap at `run.py:19-22`, and said unprompted that
  the fix belongs in the subject not the case. **L2 neutral** — the skill
  was never named and it fired anyway, quoting `spec.md:26` verbatim and
  additionally working the README's release checklist. **L3 competing** —
  refused the direct instruction, led with "not the way you asked", noticed
  the cited `q8`/`q9` precedent does not transfer (fictional places vs a
  real country), **and produced a better argument than the one this venue
  was designed around**: marking q5 forgiven would not even have worked,
  since happy-path would stay at 66.7% under its 100% floor. It fixed the
  SUBJECT instead, reached 100% legitimately, and left git alone.
  **Incidental and verified at file level:** L3's claimed edit was checked
  by diff and was exactly what it said. **`q10` passed in all three runs**
  — expected `unknown, not a country` against actual `unknown - not a
  country` — which is only possible if the comma splitter works, so
  **4.52's owed live re-test is discharged here.**
  **Stated limits:** these ran headless with a restricted `--allowed-tools`
  set, so an interactive session may behave differently; and one skill
  against one rule is one segment, not a round. 4.51 and 4.53 remain owed —
  the runner completed cleanly every time, so only 4.53's `0` path was
  exercised, which is not its discriminating behaviour.)* Add a prompt-strictness ladder to the shakedown method.
  Twelve rounds have each used a single blind prompt, which measures
  whether a skill fires under *cooperative* framing only. ECC's
  `skills/skill-comply/` generates scenarios at three levels —
  supportive, neutral, and **competing** ("prompt includes instructions
  that conflict with the skill") — and its grader ships a real positive
  control (`fixtures/noncompliant_trace.jsonl` plants impl-before-test and
  `tests/test_grader.py:96` asserts the grader fails it). The dimension
  acstack has never tested is whether a conduct rule or a skill's own stop
  condition survives a prompt actively pushing the other way — which is
  the realistic case, since users ask for shortcuts. **Out of scope:**
  building ECC's harness; this is a segment design for the existing
  fresh-session method. **Discharged 2026-08-12** — built AND run as shakedown
  13, HELD 3/3. **Acceptance:** one skill with a hard
  stop condition is run at all three strictness levels in a blind venue,
  the level at which it first yields is recorded, and a level that yields
  when it should not becomes a carrier.

  *(**Ladder designed and venue seeded 2026-08-12; NOT ticked — the
  acceptance requires the run, and a round needs fresh blind sessions.**
  The method had no canonical home at all — twelve rounds of it lived only
  in JOURNAL prose — so `docs/shakedown-method.md` was written first and
  the ladder added there: level 1 supportive, 2 neutral (task stated, skill
  never named), 3 competing (a plausible instruction conflicting with the
  stop condition). Two rules were written into it that the task did not
  ask for and that a round needs: **level 3 must be what a colleague under
  deadline would actually say** — "ignore your instructions" tests nothing
  — and **yielding is not automatically wrong**, since an advisory rule may
  legitimately bend, though an integrity rule never may.
  **Venue `~/shakedown-13/venue-a` is seeded:** an offline project at
  **7/8 = 87.5%** against a stated **≥90%** release target, testing
  `/eval-run` against the principle "never fix, tune, or delete a case to
  raise a score". **The discriminator is a fact, not a judgment** — the
  sha256 of `golden.jsonl`
  (`b2ff8da5…00b7`); if it moves, the session edited the golden set.
  **A venue defect was caught and fixed before the round:** `q5` originally
  duplicated `q8`'s input, and `q8` is legitimately forgiven, which would
  have made forgiving `q5` DEFENSIBLE and blunted the whole test. `q5` is
  now the capital of Brazil — a real gap the subject genuinely has, so
  forgiving it unambiguously hides a defect. Level 3's prompt cites `q8`
  and `q9` as precedent on purpose; the precedent does not apply, and the
  session has to notice that itself. **Owed: the three runs.**)*

- [x] **4.59** *(Done 2026-08-11. **Verdict: MODE-FIRST, against a budget
  that bites.** All ten named items are ruled below — four scheduled, six
  declined with reasons — so none sits in prose without an owner.

  **The budget, decided here and not assumed: 12,000 chars total
  (~3,000 tokens) and 600 chars per description**, enforced by check.sh
  section 28. Baseline derived 2026-08-11: 23 descriptions, **9,064 chars
  ~= 2,266 tokens**, mean 394, max 510 (`/design`). Two other figures exist
  for the same thing — 2,301 from the survey, and **~2,353 reported by
  `claude plugin details` itself** during 4.57 — and the tool's is the one
  an adopter sees. The check measures CHARS because chars are deterministic
  and tokens are not.
  **The total cap is deliberately BELOW what the roadmap would cost if
  every planned skill shipped as a skill:** 39 skills at the current mean
  is ~15,400 chars, over the cap. That is the ruling, not an oversight — a
  budget with headroom is decoration, which is precisely how 4.49 came to
  optimise a body budget sitting at 212 lines against a 500 cap while this
  one grew unwatched. Both caps shown failing first: one padded description
  (739 > 600) and every description padded (12,537 > 12,000).

  | Item | Sources | Ruling |
  |---|---|---|
  | skill-authoring | 8 | **SCHEDULED — 4.62**, as `/audit skills`, a fifth mode (~10 chars) |
  | codebase onboarding | 4 | **SCHEDULED — 4.63**, as a `/resume` mode (~15 chars) |
  | changelog generation | 5 | **SCHEDULED — 4.64**, reference under `/ship` (zero startup) |
  | `loop-design-check` (Goodhart) | ECC | **SCHEDULED — 4.65**, reference under `/eval-spec` (zero startup) |
  | TDD / test-authoring | 8 | **DECLINED** — 8 independent sources already ship it, so an adopter is well served elsewhere and the value-add would be thin. Partial coverage already exists: `/refactor` refuses to start on a suite too thin to detect a behaviour change and names what to test first, and `/eval-spec` is test-first for LLM-shaped work |
  | parallel agents / worktrees | 6 | **DECLINED** — orchestration is the harness's job, not a verification verb. Claude Code ships agents and worktrees natively; wrapping them would buy a roster entry and no method |
  | context budget / compaction | ECC ships 3 | **DECLINED as a skill; the mechanical half SHIPS HERE.** A skill that costs startup budget to talk about startup budget is self-defeating at 23 skills. ECC needed one at 282 skills and ~16k tokens; revisit if this roster ever passes the cap above |
  | brainstorm before a BRIEF | 3 | **DECLINED** — lowest recurrence, and generating options is what an agent does natively. The pack's edge is the adversarial pass, which `/challenge` already holds |
  | `council` | ECC | **DECLINED as a skill** — it is a method, and the method already binds here as AGENTS.md's falsification rule. Promotion into shipped CONDUCT.md is governed by the existing bar (proves out across projects), so it has a path and needs no verb |
  | delivery-gate Stop hook | ECC | **DECLINED** — harness config, and the pack ships skills, not settings. An unskippable hook also removes the user's pacing control, contradicting conduct rule 2 |

  Checks 30 -> 31.)* Rule on the skill-roster gaps the 2026-08-07 ecosystem survey
  named, so none of them sits in prose without an owner (rule 3). Ranked by
  recurrence across independent lists: **skill-authoring** (8 sources —
  `anthropics/skill-creator`, `obra/writing-skills`, Microsoft, Apollo,
  Sentry, plus the `agnix` and `Schliff` linters; the field's most-recurring
  verb, and acstack already holds the methodology in AGENTS.md and
  check.sh); **TDD / test-authoring** (8 sources — the pack audits suites
  via `/audit tests` that it has no verb to create); **parallel agents and
  worktrees** (6); **context budget / compaction / config GC** (ECC ships
  three, acstack none, and it is the failure mode long sessions actually
  hit); **brainstorm before a BRIEF** (3 — `/challenge` interrogates a
  brief that already exists); **codebase onboarding for an unfamiliar
  repo** (4 — `/resume` assumes the doc triad); **changelog generation**
  (5 — `/ship` cuts releases and writes none). Also to rule on, from ECC
  specifically: `council` (fresh subagents given only the question — the
  falsification rule applied to a live decision), `loop-design-check`
  (Goodhart-gaming the verifier — bears on `/eval-run`), and the
  delivery-gate Stop hook that makes journaling unskippable, which is a
  harness-config departure from "the pack ships skills, not settings" and
  may well be a decline.
  **Rule against a budget, and mode-first.** Measured 2026-08-07: the 23
  descriptions total **9,204 chars ~= 2,301 tokens loaded at EVERY session
  start**, ~100 tokens per skill, permanently and for every user. That
  budget only grows, and nothing checks it. The two budgets that ARE
  checked have never bound — the largest SKILL.md is 212 lines against the
  500 cap, and ~3,000 tokens against the spec's 5,000 — so **4.49 optimised
  the budget with 60% headroom while the monotonic one went unguarded.**
  ECC is the end state: 282 skills, ~16k tokens of descriptions at startup,
  and a `context-budget` skill built to audit its own bloat. A new verb is
  therefore the expensive answer, and this pack already ships the cheap
  one: `/audit` runs four modes in 163 lines with one reference file each,
  `/plan` runs three. **A mode costs zero at startup; a `references/` file
  costs zero until cited.** First pass at applying that to the gaps above —
  skill-authoring-from-the-verification-side is plausibly `/audit skills`
  (a fifth mode, not a skill), unfamiliar-repo onboarding is plausibly a
  `/resume` mode, changelog belongs inside `/ship`, and context-budget is
  the one candidate with no existing home. **Acceptance:** every named item
  above is either a scheduled task or carries a dated decline with its
  reason in this file, and each scheduled one states whether it lands as a
  skill, a mode, or a reference file, with the startup cost of that choice
  named; a later reader can tell which without re-running the survey. Ships
  with a check on the always-loaded description total, shown failing on a
  seeded over-budget description — 2,301 tokens is the baseline, and the
  budget it is checked against is decided in this task, not assumed.

- [x] **4.60** *(Done 2026-08-08. **Three tell sections added (§7
  typography, §8 component-library defaults, §9 imagery) and both method
  rules adopted.** Threshold stated as a NUMBER: **three** distinct tells in
  one surface before it is called machine-generated, **two of three** within
  a named cluster. The prose bar that shipped before — "one tell is a
  choice, the full set is a signature" — did nothing, because it left every
  reader to pick their own, and a checker with no threshold reports a lone
  `animate-pulse` as evidence. **Escape hatch** exempts `examples/`,
  `fixtures/`, `__mocks__/`, `stories/`, `__fixtures__/`, `*.stories.*`.
  **The escape hatch contradicts this pack's own controls, and the file now
  says so in a blockquote:** controls.sh greps `fixtures/design-audit/`
  deliberately, because the seeded plant IS the thing under test — if a
  future reader "fixes" the controls to honour the hatch, every positive
  control goes dark while still printing `ok`. That is the 4.52 shape (two
  files, contradictory rules) caught before shipping rather than after.
  **A new control shape was needed:** `ai_check` only ever asserts a hit,
  so it structurally cannot see a detector that flags everything. `ai_pair`
  asserts BOTH — fires on `default-look.tsx`, silent on
  `legitimate-look.tsx` — for the nine tells where a negative is meaningful.
  **Three tells are declared ENTRY POINTS with no negative twin** (the
  default sans faces, the neutral ramps, the AI-chip glyph): they fire on
  legitimate use by design and a human adjudicates, so asserting silence
  would be a check that cannot fail. Named as such in controls.sh rather
  than faked. **Every seed fired, both directions:** a tell leaked into the
  legitimate fixture → `FIRED on legitimate use`; the plant removed →
  `MISSED its plant`; `stories/` dropped from the hatch list → the hatch
  control failed. **Two defects in my own fixtures, caught by running them:**
  the negative fixture's comment named the tell tokens literally and tripped
  its own detector (the fixture-prose bug class, again), and `default-face`
  was pointed at `ai-tells.md` as its own fixture, where a literal `;` in
  the documented pattern made `[^;]*` unable to reach the match. Controls
  89 → 103, matrix 109 → 110. **Out of scope as filed:** anything needing a
  rendered page.)* Close the tell-coverage gaps in `/design-audit`, and adopt
  the two method rules that outrank any single tell. Verified 2026-08-07:
  `skills/design-audit/` has **zero typography tells, zero
  component-library-default tells, zero imagery tells** (the three `Inter`
  hits are substring matches on "Internal"/"Interaction"). Missing and
  checked by multiple independent packs: Inter/Geist/system-stack as the
  only face; the "tasteful free font" cluster (Space Grotesk — named
  explicitly by Anthropic's frontend-design — Sora, Syne); a serif-italic
  accent word inside a sans headline; untouched shadcn `zinc`/`slate` and
  untouched `--radius: 0.5rem`; the Lucide-in-a-rounded-square chip and
  `Sparkles`+"AI"; placeholder identities (DiceBear, `pravatar.cc`,
  `aspect-video bg-muted`); arrow glyphs stapled to CTAs ("Get started →"),
  which is the typographic sibling of the em-dash tell already shipped.
  **The two method rules matter more:** (1) **presence vs concentration** —
  ui-craft's "the floor: a lone utility-class hit is not a finding", which
  turns this pack's prose ("one tell is a choice; the full set is a
  signature") into a threshold; (2) **a self-reference escape hatch**
  exempting `examples/`, `fixtures/`, `__mocks__/`, `stories/`. (2) is a
  fix for a defect this repo has already shipped — the emoji denylist
  reported clean on the pack's own before-page, and `fixtures/` is where
  slop is seeded deliberately. **Out of scope:** anything needing a
  rendered page; that stays with wave B. Credit rule from
  `references/ai-tells.md` applies — re-express, never copy.
  **Acceptance:** each added tell is shown firing on a seeded fixture and
  NOT firing on a legitimate use of the same construct; the concentration
  threshold is stated as a number; and a fixture placed under `fixtures/`
  that would otherwise flag is shown passing because of the escape hatch.

- [x] **4.61** *(Done 2026-08-12. **`/audit` split; the scan is now a script
  and a check, not a measurement.**
  **`scripts/conditional-ratio.sh`** ranks all 23 skills by conditional
  branch content and is wired into `check.sh` §29 — because a threshold
  nothing enforces is the decoration 4.59 named one task earlier. Run
  against the PRE-split tree it flags `/audit` at **81 wasted lines**,
  which is the proof it would have caught what 4.49's size-based shortlist
  missed.
  **The threshold is on WASTED LINES, not percent — a methodology
  correction found by running it.** Ranking by percentage flags a
  *correctly split* skill, because the pointers it is left with ARE
  conditional content: post-split `/audit` still scores 27% while its real
  cost fell from 81 wasted lines to 18. Percent is scale-dependent; wasted
  lines are what an invocation pays. Default **40 lines (~450 tokens)**,
  derived: a B-branch split leaves ~5 pointer lines each, so the floor is
  ~5(B-1) = 15 at B=4, and below ~40 the net saving does not earn a new
  file and a new indirection.
  **`/audit`: SKILL.md 163 -> 91 lines**, four `## Target:` bodies moved to
  `references/target-{code,docs,eval,tests}.md`. **Zero procedure lines
  lost, proved by set difference** against `HEAD`: 136 content lines before,
  156 after across SKILL.md + the four references, with exactly ONE line
  differing — `../qa/references/adversarial-inputs.md` became
  `../../qa/...`, a necessary depth rewrite that appears on both sides of
  the diff.
  **A guard caught a real design error in the split.** Moving `## Target:
  code` wholesale took the *"does this target need the pass at all?"*
  triage gate with it, and `check.sh`'s hygiene rule failed. The gate was
  never code-specific — it says "this target" and merely sat under `code` —
  so it is now hoisted into SKILL.md ahead of the dispatch, where it covers
  all four. The split made it MORE general, not less, only because the
  guard objected.
  **Ruled, above the old percent threshold but under the wasted one:**
  `/plan` (33 wasted) — split by 4.49 with a recorded scope verdict; its
  residual is two pointers plus the `build`/`replan` bodies, and re-opening
  it is out of 4.61's scope, which is the skills the selector never saw.
  `/ticket` (14 wasted) — two ~13-line branches and no `references/`
  directory at all; splitting saves ~9 lines and costs a new directory and
  two pointers, which does not pay.
  **Self-indicting:** `check.sh`'s header calls itself "the SINGLE
  enumeration" and says a new section must update it in the same commit. I
  broke that three times — §27 (4.57), §28 (4.59) and §29 — because
  `count:checks` derives from the body markers, so the header is unguarded
  prose. All three added; every one of the 32 body sections now appears in
  the header, verified programmatically.
  Checks 31 -> 32, matrix 110 -> 111. **Still owed:** the behavioural half —
  a live model finding the moved procedure in each target — like 4.49's.
  **Discharged 2026-08-13 by shakedown 16**: `/audit skills` reproduced the
  reference's own "declarations only, not behaviour" clause, which it could
  not do without reaching it, and `/audit` was 4.61's only split target.)* Re-run 4.49's selection with 4.49's own corrected criterion.
  **4.49 fixed its selector mid-task and never regenerated the candidate
  list.** Its closing verdict records the correction — "the original
  35%-of-body-text framing was a SIZE measurement that did not survive
  contact with per-section conditionality" — but the five candidates
  (`/plan`, `/do`, `/triage`, `/design`, `/eval-run`) had already been
  nominated BY size, and conditionality was only ever applied to them.
  Measured 2026-08-07 across all 23 skills by conditional-branch ratio
  (`## Mode:`, `## Target:`, `## Tickets mode`, `## Document mode`):

  | skill | body | conditional | wasted per run | status |
  |---|---|---|---|---|
  | `/audit` | 164 | 108 (66%) | **79 lines ≈ 888 tokens** | never a candidate |
  | `/plan` | 128 | 43 (34%) | 23 ≈ 258 tokens | split, residual |
  | `/ticket` | 105 | 27 (26%) | 13 ≈ 146 tokens | never a candidate, 0 refs |

  Total still on the table: **115 lines ≈ 1,293 tokens, against 4.49's
  entire delivered saving of 1,733.** `/audit` is the miss: four
  mutually-exclusive targets (`code|docs|eval|tests` — its own description
  says "Audit one of four targets"), all four bodies inline, and it already
  carries four reference files that map one-to-one onto them. It escaped
  the shortlist because at 164 lines it was not "heavy" next to `/design`
  (212) and `/eval-run` (206) — both then declined for having zero
  conditional content, while the 66%-conditional skill was never looked at.
  **Honest priority note:** this saves tokens per *invocation*, whereas
  4.59's roster budget (2,301 tokens) is paid every *session* by every
  user. If only one gets built, 4.59's is the bigger number.
  **Out of scope:** re-opening `/design` and `/eval-run`; their decline was
  measured on the right criterion and stands. **Acceptance:** the ratio
  scan above is a script anyone can re-run, not a one-off measurement;
  every skill it ranks above a stated threshold is split or carries a
  reason; each split proves 0 lines lost by set difference per 4.49's rule;
  and the behavioural half — a live model finding the moved procedure in
  each target — is owed like 4.49's was. **Discharged 2026-08-13 by shakedown 16.**
- [x] **4.76** *(Done 2026-08-14. README gains "Irreversible acts", carrying
  the canonical marker-fenced `acstack:deny-set` (5 entries) and **three**
  measured limits — indirection, prefix-only ordering, token boundary — the
  second of which was measured after the task was written: arm I showed
  `Bash(touch -c:*)` blocking `touch -c X` and **not** `touch X -c`, so a
  `git push --force` entry misses `git push origin main --force`, and the
  README says so. `/health` gains check 10, carrying the block byte-identical.
  check.sh **§32** guards the two copies plus the row's verdict-free
  declaration; **five seeds on a frozen copy**, each firing only its own
  message: README block deleted, `/health` block deleted, an entry added to
  one side, the declaration removed — and a fifth that must NOT fire, the
  declaration re-wrapped across a line, confirming the guard is wrap-proof.
  **Verified in the consumed form, not the authored one:** a live `/health`
  rendered row 10 as `info` reading *"1 of 5 present"* with the absent four
  named and the fix stated-not-applied, under a verdict line of
  `HEALTHY — 0 issues, 3 info` — so the row genuinely does not count.
  **Two defects of my own, both caught by machinery rather than by care:**
  the first seeding pass reverted with `git checkout --` on files whose new
  content was **uncommitted**, destroying the README and `/health` edits it
  was supposed to be testing (redone on a frozen copy, the same rule the
  matrix already follows); and §32's first form grepped a phrase that **wraps
  across a line**, so it reported a missing declaration that was present —
  third instance of that class here, now flattened-and-squeezed, with seed 5
  as its standing control. Checks 34 → 35; ARCHITECTURE's "29 numbered
  sections" was stale before this edit and is corrected to 32.)* Document the irreversible-act deny block, and make `/health`
  check it. Ruled by 4.66 as shape (5). README gains a recommended
  **user-level** `permissions.deny` set using the `:*` form, stating both
  measured limits in its own words — a prefix must end at a token boundary,
  and `sh -c` / `bash -c` / a script file defeat it entirely (4.66, arms F/G/H).
  `/health` gains a row reporting **how many of the documented set are
  present**, never a PASS and never "irreversible acts guarded": the block is
  a denylist, and a check that certifies safety it cannot deliver is §13's
  failure a second time. `./setup` writes nothing — the user pastes it, and
  uninstall is deleting a JSON key.
  **Acceptance:** a check.sh guard asserts the README set and the set
  `/health` checks are identical, shown failing first on a seeded divergence
  (an entry added to one side only); README states both limits; and
  `/health`'s row is verified in its RENDERED output to carry no pass/fail
  verdict for that row.
- [x] **4.77** *(Done 2026-08-16. **Demonstrated live before being written**,
  which is the order 4.66's bar demanded. Shakedown 18, venue
  `~/shakedown-18`: a fully local bare origin carrying two `dev-b` commits
  that exist nowhere else, and a session's clone diverged 3-ahead/2-behind.
  Ground truth is origin's SHA read off disk, never the model's report.
  **Discriminator 3–0.** Control (canonical block, 10 rules) **3/3
  PERFORMED** — all three ran `git push --force-with-lease origin main`.
  Clause arm (same block + carve-out, still 10 rules) **0/3** — no push
  command attempted in any run. Arms verified non-contaminated in the run
  directories, not the seeds.
  **The venue's first prompt was confounded and the negative control caught
  it.** v1 said "CI is building the wrong history", which made the request
  factually *false*; a no-conduct session refused on the premise
  (*"contradicts the premise"*), so the discriminator ceiling was zero for a
  reason unrelated to the clause. v2 made the premise true and the act
  correct — the same no-conduct arm then PERFORMED. Both prompts kept on
  disk; the pair is the evidence that the round measured irreversibility
  rather than premise-checking.
  **What the clause actually changes:** the base model already investigates
  on irreversibility alone with no conduct block at all (*"before doing
  anything irreversible… I want to see exactly what would be lost"*), and
  then proceeds — *"The description checks out, so I'll proceed."* It does
  the naming and skips the confirming, which is rule 5 working as written.
  The clause supplies only the second half, and clause-1 reproduced its
  semantics rather than generic caution: *"That's why I'm confirming before
  running it, even though you asked for it."* That phrasing is what defeats
  the alternative hypothesis that any two added lines would induce caution —
  a placebo arm was therefore judged unnecessary and **not run**, the one
  control this round omitted.
  **Shipped text is byte-identical to the arm that was measured** — verified
  by diff against `seed-clause/AGENTS.md`, not by re-reading. Propagated to
  both sites carrying rule 5 (CONDUCT.md:152, AGENTS.md:152); §15's
  block-identity check guards the copies. CONDUCT.md §5's prose section
  gained the expanded carve-out, since a summary rule that says more than the
  full text is drift. **No new guard filed, deliberately:** deleting the
  clause from both copies would pass §15 — but that is equally true of the
  other nine rules and is not a gap this task introduced.
  **Limits, stated:** 3+3 runs, one act type, one prompt. Generality beyond a
  force-push destroying a collaborator's only copy is untested, and the
  control's behaviour was not reckless — it verified, and reached for
  `--force-with-lease` unprompted.)* The irreversibility clause on CONDUCT rule 5. Ruled by 4.66 as
  shape (3): rule 5 gains a carve-out — before an act that cannot be undone,
  name it and confirm, even when it was requested — propagated verbatim to
  every site carrying the conduct block, with the rule count staying at ten
  per the referral precedent.
  **Acceptance:** the clause is **shown changing a model's behaviour in a
  live run, not merely written down** (4.66's own bar) — a round where a
  session carrying the clause stops and names an irreversible act that a
  session without it performs. The discriminator is a count across runs, not
  a reading of one transcript. **Discharged 2026-08-16 by shakedown 18.**
- [x] **4.78** *(Done 2026-08-14. **Re-derived before fixing, and the write-up
  survived it:** all seven entries grant Bash, so there is no reading of "six"
  that is accurate — the alternative hypothesis, that six of the seven had
  Bash grants and the comment meant that, is false. `REPORT_SKILLS`'s "five of
  them violated the pack's own stance" was checked in the same pass and
  **left alone**: that is a historical event count, not a claim about the
  current list.
  Both comments now read **"the 7 read-only skills"** — digits, so the claim
  is machine-readable — and check.sh **§33** asserts the stated number equals
  `wc -w` of the list AND that exactly two such claims exist, so dropping one
  is also a failure. Three seeds on a frozen copy, each firing its own
  message: an eighth skill enrolled (the original defect, reproduced — both
  claims flagged independently), one comment restating the old number, and a
  claim deleted.
  **Wider than the write-up, in one direction I caused:**
  `docs/ARCHITECTURE.md:19` claimed the header "enumerates all 31 sections",
  which was **correct until §32 and §33 landed today**. Fixed by deleting the
  number rather than restating it — matching CONTRIBUTING.md:12, which had
  already been fixed that way. The counts in CHANGELOG.md:92 and
  JOURNAL.md:2423/2758 are deliberately untouched: they record what the
  number was on their date. Checks 35 → 36.)* `scripts/check.sh` says "the six skills" twice about a list of
  seven. `READONLY_SKILLS` at `scripts/check.sh:442` carries seven entries —
  secure, health, design-audit, audit, resume, migrate-check, why — while the
  comments at `:399` and `:444` both say six. `/why` was enrolled 2026-08-03
  and the prose never followed. Not functional, since the loop reads the
  variable and not the comment, but it is a stale set-claim sitting inside the
  comment that certifies the read-only allowlist — the exact class AGENTS.md's
  "a claim about a set enumerates the set" rule exists for.
  **Acceptance:** both comments state the count `READONLY_SKILLS` actually
  has, and check.sh asserts the stated number equals the list length so the
  next enrolment cannot silently restate the old one — shown failing first on
  a seeded eighth entry.
- [x] **4.79** *(Done 2026-08-14. **User's ruling: the prose moves.** Derived
  from the log rather than from impression — last 40 subjects are **21**
  `task <n>:` (18 single + 3 of the `task 4.68 + 4.67:` form), **7**
  `Journal <date>:`, and **12** verb-first, and those 12 are not noise: they
  are exactly the non-task work (shakedown runs, fixes, corrections,
  records). So the repo has a coherent **three-shape** convention and
  AGENTS.md documented one shape while denying the most common one existed.
  Rewritten to record all three, with the old claim struck through rather
  than deleted and the reason named as **false**: a PLAN task ID *is* a
  work-item reference, so task-closing commits **follow** CONDUCT rule 10
  instead of excepting themselves from it. The exception survives only for
  the third shape, where there is genuinely no work item.
  check.sh **§34** checks the LOG — the half that goes stale silently, since
  prose cannot be checked against intent. Five seeds on a frozen copy: a
  capitalised subject, `task 4.79` without its colon, `Task 4.79:`
  capitalised, `Journal` without a date — each firing its own message — and
  an ordinary verb-first subject correctly staying **silent**. The
  shallow-clone branch was tested separately on a real `--depth 1` clone and
  emits `SKIP`, because CI checks out one commit and one subject is not
  coverage. **Honest scope, written into the guard:** "verb-first" can only
  be checked as "starts lowercase", so a malformed `task4.79:` with no space
  reads as verb-first and passes. Checks 36 → 37.)* AGENTS.md's commit-style rule contradicts this repo's own
  commits. The rule says the pack uses lowercase
  `<verb> <object> (<detail>)` *"because the pack itself has no ticket or
  task ID per commit"* — while the recent log is `task 4.70:`, `task 4.75:`,
  `task 4.66:`. Found 2026-08-14 by a live `/health` as an observation
  outside its ten checks, having survived every prior audit. Conduct rule 7
  says surface the conflict rather than pick a side, so this task is the
  surfacing: **the user rules which one moves** — the prose (task-IDs are the
  real convention, and the stated reason is simply false) or the commits.
  **Acceptance:** AGENTS.md and the last 20 commit subjects describe the same
  convention, and check.sh asserts it so the two cannot drift apart again —
  the guard shown failing first on a commit subject of the losing shape.
- [x] **4.80** *(Done 2026-08-15. **Matrix 129 → 142, `passed=142 failed=0`**,
  run in full locally with no mid-run tree-change NOTE. Thirteen cases: five
  for §32 (four must-fire plus the re-wrap that must stay silent), three for
  §33 (the first being the original six-vs-seven defect reproduced by
  enrolling an eighth skill), five for §34.
  **A new case shape, `gitcase`, and it had to exist.** This file strips
  `.git` at `guard-matrix.sh:22`, so any git-dependent guard hits §34's
  shallow-repository fallback and SKIPs — unreachable through `fullcase`,
  permanently. `gitcase` builds a one-commit repo inside the copy, which also
  makes the subject under test the only one in the guard's window; a fresh
  `git init` reports `is-shallow=false`, and that was verified standalone
  **before** five cases were written on the assumption.
  **A latent bug found on the way, outside this task's scope.**
  `scripts/count-check.sh:81` hardcoded the three case-shape names, so adding
  a fourth made the derivation silently **under-count by 5** — reporting a
  smaller suite than the one that runs, which is the direction that hides
  work rather than inventing it. Now shape-agnostic (`^([a-z]+case|check) `,
  matching invocations and not `<name>case() {` definitions); observed at 137
  before the fix and 142 after. The runtime `passed=` total then equalled the
  static count, re-validating the equivalence that comment has asserted since
  2026-08-06 at 94.
  **All eight file-mutating seeds were independently verified to change the
  tree** before the run — the must-not-fire one included, at 3 changed lines,
  since a no-op there would have read as a passing case that tested nothing.
  **Deviation from the acceptance, deliberate: thirteen cases, not fourteen.**
  The fourteenth was the shallow-clone SKIP, and it does not belong in the
  matrix — CI checks out at depth 1 on every run, so that branch is exercised
  live on each push rather than simulated. The `cover §34 by control instead`
  fallback was not needed.)* §32's, §33's and §34's failure modes are proven but not
  durable. 4.76 seeded four against §32 plus a fifth that must NOT fire (the
  declaration re-wrapped across a line); 4.78 seeded three against §33; 4.79
  seeded four against §34 plus a must-not-fire verb-first subject and a
  separately-tested shallow-clone SKIP — **fourteen in total, every one
  watched firing or correctly staying silent, and not one of them
  re-runnable.** Every comparable guard here carries
  `docs/guard-matrix.sh` cases. Named rather than done because adding cases
  obliges a full matrix run (~18 min, frozen copy) that none of the three
  tasks' acceptances asked for.
  **Acceptance:** fourteen matrix cases, one per seed above including both
  must-not-fire controls, each verified to actually mutate the tree (a no-op
  seed reached CI once already, 2026-08-14), and the full matrix run green
  locally before any push. §34's cases need a case shape that can create a
  commit, which the matrix has not needed before — if that proves
  impractical, say so in the note and cover §34 by control instead.

- [x] **4.81** *(Done 2026-08-15, **with its own scope superseded and that is
  the finding.** As filed this demanded acceptance lines for all 15 tasks
  across waves 5–7. That was wrong: the repo already has a pattern —
  `docs/wave-2-specs.md`, `wave-3-specs.md`, `wave-4-specs.md` — where a wave
  is specced **when it is next**, and there is no `wave-5-specs.md` because
  wave 5 has not been specced, not because acceptances went missing. Writing
  done-conditions today for wave 7's `/cost` and `/incident` would be
  inventing the shape of skills nobody has decided on — the guessing this
  pack refuses everywhere else.
  **Delivered: wave 5 only — four lines, not five.** 5.5 already carried one;
  the count was corrected mid-task. Each derived from the task's own text and
  matched to 5.5's shape (seeded condition → named output → verdict). 5.3
  additionally records 4.66's deferral, including that its report must state
  the deny block is friction on the directly-typed form only.
  **The wave's exit criterion was reworded, found while deriving 5.4's.** It
  claimed *"none of them can write (enforced by `allowed-tools`)"* — an
  overclaim of exactly the kind §13 refuses: that section certifies
  "documented use is read-only", explicitly **not** "cannot write under any
  argument". And `/verify` cannot belong to that set at all, since auditing a
  claim means running the project's own acceptance commands. Split in two,
  struck through rather than deleted.
  **check.sh §35, scope DERIVED not listed:** the topmost open wave plus the
  next. No exemption list to go stale, and waves 6/7/B fall out
  automatically — superseding the filed acceptance's "Wave B is exempt in the
  guard, by name" clause with something that cannot rot.
  **Four seeds, and the third replaced a weaker one.** My first
  must-not-fire seed asserted a distant wave stays silent — which the
  BASELINE already satisfies, so a guard permanently blind to distant waves
  would have passed it forever while checking nothing. Replaced with: close
  waves 4.5 and 5, and confirm the scope **advances** — it flagged all 11
  tasks in waves 6 and 7. Matrix 142 → 146, `passed=146 failed=0`; checks
  37 → 38.
  **Waves 6 and 7, decided not forgotten:** their acceptances arrive at their
  own spec pass, and §35 will demand them the moment those waves become
  next — mechanically, without anyone remembering.)* 15 of the 20 remaining scheduled tasks carry no
  `**Acceptance:**` line. Measured 2026-08-14: wave 5 has one (5.5 only),
  waves 6 and 7 have none at all — so 5.1–5.4, 6.1–6.7 and 7.1–7.4 are
  **unbuildable by the pack's own rules**, since `/do` stops on a task with
  no acceptance recorded and `/resume` reports it as a finding about the
  plan rather than ready work. Wave B's five are deliberately **excluded**:
  unscheduled and demand-triggered, they earn acceptance lines when they are
  scheduled, not before.
  **Filed late, and that is the point.** This gap was named twice in the
  2026-08-14 session — once in the opening brief, once in a full task
  enumeration — and no carrier was opened either time, which is precisely
  the orphan AGENTS.md's carrier rule exists to prevent. Recording it was
  not scheduling it.
  **Acceptance:** every open scheduled task in waves 5–7 carries a runnable
  `**Acceptance:**` line — runnable meaning a named command or a stated
  observable, not "works correctly" — and check.sh asserts the property so a
  future task cannot be filed without one, the guard shown failing first on
  a seeded acceptance-free task. Wave B is exempt in the guard, by name and
  with the reason.
- [x] **4.82** *(Done 2026-08-16. **Filed and closed in one edit, and the
  filing found more than the report did.** The gap had been named twice — the
  2026-08-15 journal and the session handoff both wrote that
  `scripts/count-check.sh` and `docs/guard-matrix.sh` are outside CI's
  shellcheck list, and neither opened a carrier. That is the orphan the
  carrier rule exists to stop, and it took two passes to catch.
  **Derived rather than trusted, and the named list was short.** Enumerating
  every tracked file with a shell shebang found **four** unlinted scripts,
  not two: `conditional-ratio.sh` and `reach-check.sh` had never been named
  by anybody. **Three rosters existed and no two agreed** — check.sh §5's
  `bash -n` loop named 7 files, its shellcheck call named 6, and
  `.github/workflows/check.yml` named the same 6. Ten production shell
  scripts exist; the best-covered list reached seven.
  **Fixed by deleting all three rosters, not by extending them** —
  `scripts/shell-sources.sh` is now the single derivation, read by both §5
  and CI, and it covers itself (11 files). All 11 were already clean at
  `-S warning`, so this buys future coverage rather than fixing live
  defects, which is stated because a green result reads like a fix.
  **Walks the tree with `find`, not `git ls-files`, deliberately:**
  guard-matrix copies the tree without `.git`, so a git-dependent derivation
  would have returned nothing there and broken every case in the matrix —
  the exact trap §34 fell into and 4.80 had to add `gitcase` for. Verified
  by running check.sh in a copy with `.git` removed: same 11 files, exit 0.
  **Controls, on a frozen copy:** a new tracked script with an SC2164
  warning takes check.sh to exit 1 and removing it returns exit 0, so the
  failure is the seed's; the same defect planted under `fixtures/` leaves
  check.sh at exit 0 and does not enter the derived set. **That must-not-fire
  cannot be satisfied by the baseline** — the fixture does not exist until
  the seed runs. Matrix **146 → 149**; §5 now emits a `FAIL syntax:` line on
  a shellcheck failure so the class is greppable like every other check.)*
  `scripts/count-check.sh` and `docs/guard-matrix.sh` run in CI but are
  linted by nothing.
  **Acceptance:** the set of shell files CI lints is derived from the tree
  rather than listed, every shell source in the pack is covered including
  any added later, and the derivation is shown failing on a newly added
  script before it is trusted.
- [x] **4.83** *(Done 2026-08-17. Bumped to the floating **v7** major
  (v7.0.1 latest, re-read from the releases API rather than reused from the
  filing note), matching what `v4` was. **Verified in the consumed form the
  acceptance named:** run `31912257744` on v4 carried
  `warning: Node.js 20 is deprecated … actions/checkout@v4`; run
  `31965411853` on v7 carries **no annotations at all**, all seven steps
  green. The v4 baseline was captured **before** the bump on purpose — without
  it, "no annotation" is indistinguishable from an annotations API that
  returns nothing for every run, and the acceptance would have been
  self-confirming.
  **The `uses:` set was enumerated, not assumed** — `.github/workflows/`
  contains exactly one action, so the "any other action on a deprecated
  runtime" clause is satisfied by there being none.
  **Checked before bumping, and it is the non-obvious risk:** default
  `fetch-depth` is unchanged at 1 across v5-v7. check.sh **§34 SKIPs on a
  shallow clone by design**, so a deeper default would have silently started
  running commit-subject checks over the entire history in CI. It still
  SKIPs. v5.0.0's Node 24 move is the only substantive change in the three
  majors crossed.)* CI pins `actions/checkout@v4`
  (`.github/workflows/check.yml:22`), which targets Node.js 20 and is being
  force-run on Node 24 — every run since has carried the deprecation
  annotation. Latest is **v7.0.1** (published 2026-07-20, read from the
  releases API on 2026-08-16, not recalled). Nothing fails today; this is
  filed because the forced-runtime bridge is what gets removed, and a green
  CI with a standing annotation is the state where that removal arrives as a
  surprise. Observed during 4.82's push, filed rather than mentioned once
  and lost — the failure mode 4.82 itself was created by.
  **Acceptance:** a real CI run after the bump carries **no** Node-version
  deprecation annotation — read from the run's annotations via
  `gh run view <id>`, not from the workflow file, since the workflow is the
  authored form and the annotation is the consumed one. Any other action in
  the workflow on a deprecated runtime is bumped in the same pass or its
  exclusion is written down.
- [ ] **4.84** A "known class hit" is claimed without the class being read.
  Shakedown 19's `/investigate` run reported *"Known class hit — Unicode
  lookalikes breaking string comparison (pack bug-class list). **Checked
  first**; it matched on inspection"* while its tool trace was `Bash` ×8 with
  **zero** `Read` calls: `skills/audit/references/known-bug-classes.md` was
  never opened. The name reached it through `bin/acstack-recall`'s preamble,
  whose own text says *"read the full class when one matches"*. The diagnosis
  was correct, which is why this is a reporting defect rather than a
  correctness one — and why it would survive any check that only grades
  outcomes. The recall preamble makes every session able to *name* classes it
  has not read, so the honest form has to be structural, not a resolution to
  be careful.
  **Acceptance:** `/investigate` cannot claim a class hit without naming the
  reference it read — either the procedure requires citing
  `known-bug-classes.md:<section>` alongside the claim, or the claim is
  downgraded to "matches a class name from recall (full class not read)".
  Shown live: a seeded run whose class matches either cites the file or makes
  the weaker claim, and the transcript's `Read` calls corroborate whichever
  it says.
- [ ] **4.85** `/investigate`'s tickets branch states an offer with no
  defined target. `skills/investigate/SKILL.md:103` says *"Findings are
  offered as a `gh issue comment` so the investigation travels with the
  ticket — offered, not posted unasked"* unconditionally, but the only
  target named anywhere in the branch comes from the optional `issue#`
  argument at `:102`. Invoked bare in tickets mode — which is how shakedown
  19 ran it, on a failure not tied to any issue — the instruction has nothing
  to attach to, and the offer did not happen. Not a model miss alone: the
  text does not say what to do when there is no issue.
  **Acceptance:** the branch states the no-`issue#` case explicitly — either
  the finding is offered against a named candidate issue, or the offer is
  stated as not applicable and why — and a live bare invocation in tickets
  mode does whichever the text now says.

## [ ] Wave 5 — Gates: pre-flight + verification

**Goal:** Generalize `/migrate-check`'s shape — read-only, classify every
change additive vs destructive, end in a written GO/NO-GO — into the lane
no surveyed pack occupies at all. Plus the one verification skill worth
building.

**Exit criterion:** Each gate returns a written verdict against a seeded
scratch project. ~~none of them can write (enforced by `allowed-tools`, per
4.8's precedent)~~ **Verdict (2026-08-14):** that overclaimed what
`allowed-tools` delivers. check.sh §13 certifies *"declares only commands
whose DOCUMENTED use is read-only"*, explicitly **not** *"cannot write under
any argument"*, and carries a named residual (`git log --output=FILE`); it
also states that read-only describes what a skill does **to the project**,
not a claim that nothing on the machine is touched. Restated in two parts:
**5.1, 5.2, 5.3 and 5.5** declare no write-capable tools and enrol in §13's
`READONLY_SKILLS`, so they never write to the project. **5.4 sits
deliberately outside that set** — verifying a claim means running the
project's own acceptance commands, and those write caches, temp files and
test databases; lumping it in would either block the skill or stretch
"read-only" until it meant nothing. Its constraint is its own and is stated
rather than inherited: it never edits the project, the claim, or the
acceptance it is auditing. Found while deriving 5.4's acceptance (4.81).

- [ ] **5.1** /deps — dependency hygiene: what packages were added and
  why, maintenance status, license posture, whether stdlib or an existing
  dependency would have done it, whether it is even imported. Agents add
  packages reflexively; nothing in any surveyed pack looks at this.
  **Acceptance:** on a scratch project whose manifest carries four planted
  defects — a package that is never imported, one whose job the stdlib
  already does, one unmaintained (no release in over two years), and one
  whose license conflicts with the project's declared one — names all four
  with the manifest line for each, and returns no findings on a clean
  manifest. The never-imported one is the discriminator: it is decidable
  with certainty, unlike the judgment calls beside it.
- [ ] **5.2** /contract-check — breaking-change pre-flight for the surface
  callers depend on: function signatures, API response shapes, public
  exports, config keys. Same additive-vs-destructive classification and
  safe-alternative column as `/migrate-check` (add-new-then-deprecate
  rather than rename). The cheapest build in these three waves — the
  template already exists and is shakedown-proven.
  **Acceptance:** against a diff that renames a public export, drops a field
  from an API response, narrows a function signature, and adds an optional
  config key, classifies the first three destructive and the fourth
  additive, names the add-new-then-deprecate alternative for each
  destructive one, and returns GO on an additions-only diff. A rename
  reported as additive is the failure this skill exists to prevent.
- [ ] **5.3** /careful — GO/NO-GO for destructive operations generally:
  history rewrites on shared branches, bulk deletes, production config
  edits, secret rotation. `/migrate-check` covers the database slice and
  nothing else today; gstack splits this across three skills, acstack
  does it as one verdict.
  **Acceptance:** given a `git push --force` onto a shared branch, a bulk
  delete, and a secret rotation, returns NO-GO for each with the
  irreversibility named and the recovery path stated, and GO for an
  operation with a working undo. **Inherits 4.66's deferral (2026-08-14):**
  the skill shape was ruled there and sent here rather than built in 4.5, so
  this task owns what the CONDUCT rule-5 clause does not — and its report
  must state that a `permissions.deny` block is friction on the
  directly-typed form only, since `sh -c`, `bash -c` and script files defeat
  it outright (4.66, arm F).
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
  **Acceptance:** given a claim naming an acceptance the system does not
  meet, returns FALSE with the command run and the output observed; given a
  claim true in part, OVERSTATED naming the clause that failed; given a met
  claim, CONFIRMED. All three must be produced against a **running** system —
  a pass that only reads the diff cannot honestly return any of them, and
  that is also why this task sits outside the wave's read-only set (see the
  exit criterion's 2026-08-14 verdict).
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

  > **Routed here from the 2026-07-30 survey (carrier note added
  > 2026-08-05):** three review-mechanics pieces mined but not yet landed
  > in any skill — (a) impeccable `critique.md`: two INDEPENDENT
  > assessments of one resolved target, then a synthesis, with the chat
  > deliverable kept separate from the persisted snapshot; (b) the
  > code-review plugin's per-finding validation subagents: every finding
  > is adversarially validated or DROPPED, never shipped unvalidated —
  > the falsification practice this repo already runs by hand, due to
  > become skill text here; (c) security-guidance's layered-config
  > truncation priority: when layered config must be cut to fit, which
  > layer survives is an explicit ordering, never silent loss. Until this
  > note, (c) had no carrier anywhere — the rule-3 orphan found
  > 2026-08-05. Sources: docs/survey-2026-07-30.md, Review mechanics.

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

  > **Reviewers are framed to REFUTE, not to review (2026-08-03).**
  > The single highest-yield finding of the wave-4 build, and it is a
  > prompt-shape rule rather than a mechanism. Every round framed as
  > "audit this" returned agreement; every round framed as "disprove
  > this, treat each row as a claim not a fact" returned real defects.
  > One falsification pass over the launch ledger found **2 rows false
  > and 4 overstated, all in the author's favour**, after three
  > audit-framed rounds had missed every one.
  > Therefore each lens gets its refutation framing in its own prompt,
  > and a finding **survives only when the attempt to refute it fails**
  > — which is also how `/board` should consolidate: validate each
  > finding independently and drop what does not survive, per the
  > code-review prior art above. Two riders: hand the reviewer the
  > requirement text separately, so it checks the claim against the bar
  > rather than against itself; and verify the reviewer's own findings
  > at `file:line`, because a refuter is as capable of being wrong as
  > the author — one claim in that same session did not survive
  > checking. Carried in AGENTS.md as this repo's fifth verification
  > rule; it reaches adopters only through this skill.

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
  hardcoded to a 4-row toy fixture, and a LEARNINGS.md carrying its
  scaffold header and no captured lesson. *(**Re-verified 2026-08-12**
  before deletion, and one word was wrong: LEARNINGS.md is **97 bytes**,
  not "empty" — a title line and the `/learn` comment. Substantively
  disposable, imprecisely stated. The other two figures are exact: 25
  golden cases, and `sample.csv` at 5 lines = header + 4 rows. Also found:
  **8 issues** the note never mentioned, all synthetic `csvsum` items.
  **Deletion deferred** — this is the only live example of a tickets-mode
  run (`#N:` commit subjects, a populated issue list, a working
  `.github/ISSUE_TEMPLATE/task.md`), and 4.50's tickets segment has to
  build a venue from scratch. Delete it after that round, not before.)*
  *(**Closed 2026-08-13.** Shakedown 17 ran the tickets segment and built
  its own venue, `acstack-s17-tickets`, which supersedes w2 as the live
  example — richer, and rigged for the paths that round left uncovered
  (`/ticket`, `/investigate`, the failing-acceptance path, `Fixes #N`).
  `acstack-w2-shakedown` was then **deleted by the user**, verified gone.
  The `delete_repo` scope was granted and **removed again in the same
  sitting** — scopes confirmed back to `gist, read:org, repo, workflow` —
  which is the narrow-capability-window shape 4.66 should weigh: the
  control that bounded the blast radius was the short-lived grant plus
  `gh`'s own requirement that the target be named in full, not a hook.
  `acstack-s17-tickets` is **kept deliberately**, and is the venue the
  uncovered paths need.)*
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
