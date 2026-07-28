# Wave-3 specs — ship + reflect layer

> **What this file is.** Per-skill designs for wave 3, written at wave
> start per PLAN.md's process, at the same fidelity as waves 1–2. Build
> follows approval, one increment at a time, in the build order at the
> end. **Drafted:** 2026-07-27. ~~**Status:** awaiting approval — nothing
> below is built yet.~~
> **Status (2026-07-29):** all seven built, independently reviewed, and
> shakedown-passed; wave 3 ticked in PLAN.md. This document is now the
> as-built record. **Divergences from the spec as written, recorded rather
> than edited:** the shakedown used a local scratch directory, not the
> `acstack-w3-shakedown` GitHub repo named in the verification section
> below — nothing in wave 3 needed tickets mode — and the tickets-mode
> `Fixes #N` spot check was therefore NOT run, since the wave-2 shakedown
> had already proven that path end to end.
> **Standing verdicts applied:** 3.7 ships as **/health**, not /doctor
> (2026-07-27 shadowing decision); the /qa browser probe is **deferred**
> to first real need (2026-07-27 decision — http now, seam designed for
> both); /retro ships **without** the usage-stats section (arrives with
> wave-4 telemetry, 4.3).

## Cross-cutting

- Seven new skill directories (`qa`, `secure`, `ship`, `retro`, `learn`,
  `design-audit`, `health`). Pack total after the wave: 19 skills — the
  full roster. `check.sh` globs `skills/*/SKILL.md` and `setup` globs
  `skills/*/`, so guard and installer need zero changes; adopters re-run
  `./setup`.
- Every new SKILL.md carries the canonical principles block verbatim
  (README canonical), stays under 500 lines, plain markdown, no bash
  preambles (wave 4), no new dependencies. `gh` is required only for
  tickets-mode surfaces, which degrade honestly exactly as in wave 2
  (name the failed precondition, offer document mode, never guess).
- Invocation split: **all seven are model-invocable**, each description
  scoped to explicit intent — the pack's first zero-user-only wave. The
  report-shaped five (/qa, /secure, /design-audit, /health, /retro)
  mis-fire at worst into an overly thorough answer; /learn follows
  /ticket's capture-must-be-frictionless precedent; /ship follows /do's
  precedent — it acts, but only on explicit ship intent, every failing
  gate stops the release, and conduct rules 2 and 5 gate the act (the
  wave-2 invocation-split rationale, unchanged).
- Every new SKILL.md carries the `Adjacent skills:` routing line; the
  wave-2 disambiguation rule binds all seven.
- Report-shaped skills share the pack stance: verdict as the report's
  FIRST line, findings with evidence (file:line or exact repro command),
  exact commands under `**Safety checks:**` where commands were run,
  scope stated, proposed fixes listed — never silently applied.
- **Probe safety rule** (binds /qa and any future probe consumer):
  mutating probes (non-GET, form submits) run only against targets that
  are clearly local/dev; if the target is not clearly local, name the
  risk and get explicit confirmation first. Adversarial probing of a
  production URL never starts uninvited.
- Config additions (both optional, unknown-ignored per the extension
  hook): a `## qa` per-skill section with `base-url:` (the http probe
  target; an argument URL overrides), and a `## design-audit` section
  with `palette:` (allowed hex values) and `product-names:` (exact
  casings). README's config table gains both rows as the skills land.
- New repo-owned artifact: `LEARNINGS.md` — created by /learn on first
  capture if missing; /investigate already reads it; wave-4 recall will
  load it. Repo-owned memory, per the pack identity.

## 3.1 /qa — flows, adversarial inputs, and the probe seam

Frontmatter: `name: qa`, `argument-hint: "[flow | url | notes]"`,
model-invocable. Description scoped to intent: use when the user asks to
QA, exercise, or probe the running app's flows and inputs.
`Adjacent skills:` /secure (hunts vulnerabilities; /qa exercises
functionality), /audit code (reads the code; /qa hits the running
system), /design-audit (how it looks; /qa is how it behaves).

**The probe seam — the wave's architectural deliverable.** A probe is
the only thing that touches the target; the skill's method and report
never name a transport. A probe provides three verbs: **reach** (is the
target up), **act** (deliver one input or step), **observe** (status,
body/output, error). Modes:

- `probe: http` — implemented now: curl against the resolved base URL,
  conventions in `references/probe-layer.md`.
- `probe: browser` — documented, not implemented: invoking it declines
  honestly ("browser probe deferred until first real need — decision
  2026-07-27") and offers http.

The report skeleton is identical for both modes — that identical shape
is the seam proof the wave exit criterion demands.

**Method.**

1. Resolve the target: argument URL beats config `base-url`; neither →
   say exactly what's missing, stop. Target not clearly local → the
   probe safety rule applies before any mutating probe.
2. Enumerate flows from BRIEF/PLAN (or the named flow) — a flow is a
   named sequence of steps with an expected outcome.
3. Happy path per flow first — a broken happy path makes adversarial
   results noise.
4. Adversarial pass per input surface, drawing from
   `references/adversarial-inputs.md`: garbage tokens (`hdcf`, `zzzz`),
   oversized input (500-char), regex-special characters, out-of-range
   numerics, empty/whitespace-only, wrong-type values.
5. Auth-gate probing: every gated endpoint hit unauthenticated must
   fail closed — 401/403 expected; a 200 is handed to /secure's pile,
   a 500 is an error-hygiene finding.

**Report shape.** Verdict first: `PASS` / `FAIL — <n> findings` /
`BLOCKED — <precondition>`. Per-flow table (step | input class |
expected | observed | verdict). Findings each carry the exact repro
command. Scope: flows and surfaces not exercised, probe mode used,
target probed.

References: `references/probe-layer.md` (seam contract, http probe
conventions, the browser deferral note), `references/adversarial-inputs.md`
(the input bank by surface type).

## 3.2 /secure — confidence-gated security findings

Frontmatter: `name: secure`, `argument-hint: "[path | surface | notes]"`,
model-invocable. Description scoped to intent: use when the user asks
for a security review or to check vulnerabilities/secrets/auth.
`Adjacent skills:` /qa (functional probing; /secure hunts
vulnerabilities), /audit code (general defects; /secure is
security-only), /migrate-check (DB change safety).

Structurally read-only like /migrate-check: it reports, it never fixes.

**The confidence gate — the skill's identity.** A finding exists only if
it carries (a) a concrete exploit scenario — who sends what request or
input, and what they obtain — and (b) a confidence rating: `high`
(demonstrated, or directly evidenced in code), `medium` (code path
present, preconditions unverified), `low` (pattern-level suspicion).
Suspicions with no scenario go to a separate `Worth hardening` list —
never inflated into findings. The never-inflate rule, applied to
security.

**The four surfaces** (each with a checklist + grep patterns in
`references/security-surfaces.md`):

1. **Auth gates** — the rival-user test: can authenticated user A reach
   user B's data by ID-swapping; unauthenticated reach of gated routes;
   server-side checks missing behind client-side hiding.
2. **Secrets hygiene** — .env tracked or recoverable in history, the
   gitignore-negation trap (`!.env` class), hardcoded keys/tokens,
   secrets leaking into error messages or logs.
3. **Injection surface** — string-built SQL and raw-query usage, shell
   interpolation of user input, path traversal in file operations,
   unsanitized HTML sinks.
4. **LLM tool-use trust boundaries** — untrusted content flowing into
   tool calls or system prompts, over-scoped tool permissions,
   prompt-injection paths from user-supplied documents, model output
   executed or rendered unchecked.

**Report shape.** Verdict first (`no high-confidence findings` or
`N findings (X high)`). Findings ordered by severity: surface,
file:line, exploit scenario, confidence, fix direction.
`**Safety checks:**` the exact grep/git commands run per surface.
`Worth hardening` list. Scope: surfaces and paths covered / not covered.

References: `references/security-surfaces.md`.

## 3.3 /ship — branch-level release with gates

Frontmatter: `name: ship`, `argument-hint: "[branch | notes]"`,
model-invocable, description tightly scoped: use when the user asks to
ship, release, or open the PR for a feature or branch.
`Adjacent skills:` /do (ships one subtask; /ship releases a branch),
/audit code (review only; /ship is the release act).

/do ships subtasks; /ship ships features. Five gates, then the act.
Every gate reports before the act, and any failing gate STOPS the
release with its output — the user rules; there is no force path.

1. **State gate.** Working tree clean; current branch is not the default
   (on default → offer to cut one per `branch-prefix`); branch is ahead
   of default by the commits being shipped.
2. **Test gate.** Run the project's test suite if one exists (detected,
   or named in config); record the summary numbers. No suite → stated
   honestly, never silently passed.
3. **Eval gate.** If `eval/spec.md` exists: run the eval per its run
   command, compare headline vs target — below-target blocks the ship.
   No eval → one honest line.
4. **Docs gate.** Cheap drift pass: README quickstart still true; the
   shipped work's PLAN exit criterion run if runnable; JOURNAL mentions
   the work (else propose /journal first). Deep drift stays /audit
   docs' job.
5. **Attribution gate.** Sweep the branch's commit messages and the PR
   body per `attribution` config (default `none`: no AI trailers or
   mentions).

**The act.** Push per config; `gh pr create` with a report-shaped body:
what-and-why lede, per-gate evidence table, test/eval numbers,
out-of-scope. Tickets mode: `Fixes #N` for each issue the branch
completes (from commit refs + milestone), PR tied to the milestone.
Document mode: the body names PLAN task IDs; a phase exit criterion that
passed in gate 4 is ticked per /do convention. Report ends with the PR
URL + one line per gate.

References: `references/ship-gates.md` (gate definitions, exact
commands, PR body template).

## 3.4 /retro — trends across sessions

Frontmatter: `name: retro`, `argument-hint: "[week | phase N | notes]"`,
model-invocable. Description scoped to intent: use when the user asks
for a retro, a weekly review, or a phase wrap-up.
`Adjacent skills:` /journal (one session's worklog; /retro trends across
many), /audit eval (one report's honesty; /retro the trend across runs).

Reads: JOURNAL.md entries since the last retro, PLAN.md (dates, phases,
risks), eval artifacts when present (spec targets + result files over
time), git log (commit/box velocity). The argument narrows scope to a
week or a phase.

Sections, with a verdict-shaped lede first (`on plan` / `slipping —
<where>` / `off plan`):

1. **Velocity vs plan.** Planned phase dates vs actual; boxes or issues
   closed per period vs the plan's implied rate; slippage named in days
   with causes pulled from journal entries, not vibes.
2. **Eval trend.** Headline score per run over the window, per-category
   direction, distance to target. No eval history → one honest line,
   section ends.
3. **Failure-category trends.** Counts by class from the journal's eval
   triage sections and /investigate write-ups; recurring classes named
   as /learn promotion candidates.
4. **Risk review.** Each open PLAN risk: still real / materialized /
   retired, with evidence; new risks proposed as dated PLAN edits
   (proposed, never applied by /retro).

No usage-stats section in wave 3 — no placeholder either; 4.3 adds the
section together with the telemetry it reads (per the 2026-07-27
scope ruling recorded in PLAN 3.4).

Output: appended to JOURNAL.md as a dated `### Retro (YYYY-MM-DD —
<window>)` entry under Key decisions and journey; committed per the
journal convention: `Journal YYYY-MM-DD: retro — <summary>`.

Tickets-mode delta: velocity becomes closed issues + milestone burn via
`gh`; failure classes additionally mined from issue labels and comments.

References: `references/retro-sections.md` (per-section question sets +
the honest-degradation lines).

## 3.5 /learn — capture a lesson, grow the pack

Frontmatter: `name: learn`, `argument-hint: "<lesson | notes>"`,
model-invocable — capture must be frictionless (/ticket precedent).
`Adjacent skills:` /journal (whole-session record; /learn one durable
lesson), /investigate (its write-ups are /learn's best input), /ticket
(captures work to do; /learn captures knowledge learned).

**Capture.** Shape the lesson into a LEARNINGS.md entry:
`### <one-line lesson> (YYYY-MM-DD)`, a `symptom → cause → fix` triple,
a context line (project area, tech, file when known), and `seen: 1`.
Create LEARNINGS.md with a two-line header if missing. Before
appending, scan for an existing entry with the same cause — propose
bumping its `seen:` count and last-seen date instead of duplicating.
What can't be determined is marked TBD, never invented (/ticket's rule).

**Promotion.** When an entry's `seen:` reaches 2+, or the lesson is
plainly project-independent, propose promotion into the pack's
`skills/audit/references/known-bug-classes.md`, outputting the exact
entry text in that file's format. In the acstack repo itself the edit
is applied on approval; in adopter projects the text is output for the
user to carry over — the pack is never edited silently from a project.

The entry rides the project's next commit by default; a standalone
`add learning (<slug>)` commit only on request. Report: the entry as
written, the dedup/promotion outcome.

No references directory — the entry format and promotion rule are
compact enough to live in SKILL.md.

## 3.6 /design-audit — UI conventions and honest surfaces

Frontmatter: `name: design-audit`, `argument-hint: "[path | notes]"`,
model-invocable. Description scoped to intent: use when the user asks
to design-audit, or to check UI conventions, polish, or copy.
`Adjacent skills:` /qa (behavior; /design-audit is look and language),
/audit code (correctness; /design-audit is convention), /secure
(exploitability; /design-audit flags leaked internals as language).

Static pass over UI code, styles, templates, and user-facing strings —
nothing is rendered; a rendered mode arrives with the browser probe
(same deferral verdict, stated in the SKILL.md). Conventions come from
project config (`## design-audit`: `palette:`, `product-names:`)
layered over pack defaults in `references/design-conventions.md`;
config always wins.

Checks:

1. **Palette + branding.** Hardcoded colors outside the configured
   palette; product names in the wrong casing; spacing/font constants
   diverging from the project's own tokens where tokens exist.
2. **Honest data labels.** AI-generated, illustrative, or mock data
   shown without saying so; charts of fabricated numbers presented as
   real — the honest-measurement principle applied to pixels.
3. **Slop detection.** Placeholder/lorem remnants, emoji-decorated
   headings in product UI, uniform gradient-card grids, hedge copy
   ("simply", "seamlessly", "powerful"), user-visible debug strings.
4. **Client-facing language.** Internal jargon or codenames in UI
   strings, error messages leaking internals, inconsistent terminology
   for the same object across screens.

**Report shape.** Verdict first; findings with file:line, the
convention violated, and the suggested fix; `**Safety checks:**` the
greps run; scope (paths covered; static-only stated).

References: `references/design-conventions.md` (brand-neutral default
conventions, the slop list, label rules, the config schema).

## 3.7 /health — the project checkup (ships as /health)

Frontmatter: `name: health`, `argument-hint: "[notes]"`,
model-invocable. Description scoped to intent: use when the user asks
for a health check, a project checkup, or whether the setup is sane.
Named /health per the 2026-07-27 verdict — /doctor would shadow Claude
Code's built-in diagnostic; /health is the lineage name anyway.
`Adjacent skills:` /audit docs (deep drift triples; /health is the
quick checkup), /resume (where-we-are; /health is is-anything-broken).

Read-only. Every ✗ comes with the exact fix command — applied never.

Checks (exact commands live in `references/health-checks.md`):

1. **Docs.** BRIEF/PLAN/JOURNAL present (legacy names accepted and
   named); JOURNAL's last update vs the last non-journal commit (stale →
   flag); PLAN has an open phase with a runnable exit criterion.
2. **Pointer.** CLAUDE.md is exactly the `@AGENTS.md` pointer (flag,
   never silently rewrite — /plan's rule).
3. **Conduct.** Marker-fenced conduct block present in AGENTS.md and
   current vs the pack's CONDUCT.md (stale → show the exact refresh).
4. **Config.** `.claude/acstack.md` parses; unknown keys listed as info
   (extension hook, not an error); mode prerequisites consistent
   (`tracking: tickets` with no gh/remote → ✗).
5. **Secrets.** .env-class files tracked; the gitignore-negation trap
   (`!.env`); quick grep for obvious key patterns in tracked files.
6. **Attribution.** Recent commit messages vs the `attribution` config
   (default `none` → any AI trailer is a ✗).
7. **Learnings.** LEARNINGS.md missing or untouched for `stale-days` →
   info line pointing at /learn.
8. **Tickets extras** (`tracking: tickets` only): gh present + authed,
   pack labels present, issue template present, stale-issue count vs
   `stale-days`.

Deferred checks, added by the wave that builds their artifacts: hook
installed (4.4), VERSION/update-check freshness (4.1/4.2),
conduct-in-global (4.4).

**Report shape.** One-line verdict (`HEALTHY` / `N issues, M info`),
the checklist table (check | ✓/✗/info | fix command), scope.

References: `references/health-checks.md`.

## Build order and commits

One commit per increment, wave-1 subject style. Each skill's commit
also carries its own README rows (skills table + any config rows) so no
doc-drift window exists between commits.

1. `add learn skill (symptom-cause-fix capture, seen-count promotion)`
   — smallest, standalone; LEARNINGS.md exists for later skills.
2. `add health skill (project checkup, ships as health per verdict)`
   — standalone, immediately useful on this repo.
3. `add qa skill (probe seam, http implemented, adversarial input bank)`
4. `add secure skill (confidence gate, four surfaces, exploit scenarios)`
5. `add design-audit skill (palette, honest labels, slop detection)`
   — the probing trio lands together, sharing the report stance.
6. `add retro skill (velocity, eval trend, failure classes, risks)`
   — reads journal history and /learn promotion candidates.
7. `add ship skill (five gates, report-shaped pr, mode-aware links)`
   — last: the release act touches every earlier surface.

## Wave verification (the PLAN.md exit criterion, expanded)

Two venues: **this repo** (document mode, real history) and a throwaway
scratch project **`acstack-w3-shakedown`** (private) carrying a
deliberately seeded minimal web app: one public endpoint, one
auth-gated, one input-validated; a seeded hardcoded key; an off-palette
hardcoded color and an unlabeled mock-data chart; a trivial test file.

1. **/qa — the seam proof.** http mode against the scratch app:
   happy-path flow + adversarial pass + auth-gate probe produce the
   report; a `probe: browser` invocation declines honestly with the
   dated deferral and offers http; both paths emit the same report
   skeleton.
2. **/secure.** Finds the seeded key and the auth gap, each with an
   exploit scenario and confidence; run on acstack itself expecting
   `no high-confidence findings`.
3. **/design-audit.** Flags the off-palette color, the unlabeled mock
   chart, and seeded slop copy, with the config palette honored.
4. **/ship.** A scratch feature branch through all five gates (trivial
   suite passes; eval honestly absent) to a report-shaped PR;
   tickets-mode spot check: a seeded issue closes via `Fixes #N`.
5. **/retro.** On acstack itself — real velocity vs PLAN, honest
   no-eval-history degradation, failure classes from the journal, risk
   review of PLAN's open items.
6. **/learn.** Captures a real lesson from this shakedown into the
   scratch LEARNINGS.md; a second capture of the same cause bumps
   `seen:` and triggers the promotion proposal (proposed, not applied).
7. **/health.** acstack expects `HEALTHY`; the scratch repo, seeded
   with a non-pointer CLAUDE.md and a tracked .env, must flag both
   with exact fix commands.
8. **Pack checks.** `scripts/check.sh` clean; `./setup` links 19
   idempotently; a fresh session lists 17 model-invocable skills
   (/plan and /eval-spec correctly absent from the model-facing list).

## What wave 3 does NOT include (intentional)

- The Playwright/browser probe (deferred 2026-07-27 to first real
  need; the seam ships ready for it) — and therefore no rendered mode
  for /design-audit either.
- /retro's usage-stats section (arrives with local telemetry, 4.3).
- The wave-4 runtime: preamble, bin/, VERSION/CHANGELOG, telemetry,
  CI, `setup --global`; /health's dependent checks are listed above as
  deferred.
- Any auto-fixing: /secure, /health, /design-audit, and /qa are
  read-only reporters; /ship stops on a failing gate rather than
  forcing past it.
- Linear/Jira tracker support (locked: GitHub Issues only at launch).
