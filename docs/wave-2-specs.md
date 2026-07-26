# Wave-2 specs — gate, eval, and tickets layer

> **What this file is.** Per-skill designs for wave 2, written at wave start
> per PLAN.md's process, at the same fidelity as wave 1's specs. Build
> follows approval, one increment at a time, in the build order at the end.
> **Drafted:** 2026-07-27. ~~**Status:** awaiting approval — nothing below
> is built yet.~~ **Status (2026-07-27, end of day):** all eight items
> built, independently reviewed (6 findings fixed), and shakedown-passed in
> a scratch repo; wave 2 ticked in PLAN.md. This document is now the
> as-built record.
> **Revised 2026-07-27:** invocation split changed after review — /challenge,
> /plan-review, and /triage flipped to model-invocable (was: user-only), and
> the disambiguation rule below was added. /eval-spec remains user-only.
> **Revised 2026-07-27 (post-build review):** /challenge's verdict moved to
> the report's first line and a scope element added — the original 2.1 shape
> (verdict last) conflicted with the cross-cutting verdict-up-front stance.

## Cross-cutting

- Seven new skill directories (`challenge`, `plan-review`, `eval-spec`,
  `investigate`, `resume`, `ticket`, `triage`) plus tickets-mode edits to
  /plan, /do, and README (item 2.6). Pack total after the wave: 12 skills.
- Every new SKILL.md carries the canonical principles block verbatim.
  `check.sh` globs `skills/*/SKILL.md` and `setup` globs `skills/*/`, so new
  skills are guarded and installable with zero guard/installer changes —
  adopters just re-run `./setup`.
- Plain markdown, under 500 lines each, no bash preambles (wave 4), no new
  dependencies. `gh` is required only when `tracking: tickets` is set, and
  every tickets-mode surface degrades honestly: if `gh` is missing,
  unauthenticated, or there is no GitHub remote, say exactly which
  precondition failed and offer document mode — never guess.
- One new config key: `stale-days` (read from a `## triage` per-skill
  section, default `30`). README's config table drops "(coming)" from
  `tracking: tickets` when 2.6 lands.
- Report-shaped skills (/challenge, /plan-review, /triage) share /audit's
  stance: verdict up front, findings with evidence, scope stated, proposed
  edits listed — never silently applied.
- Invocation split: /investigate, /resume, /ticket, /challenge,
  /plan-review, and /triage are model-invocable, each description scoped to
  explicit intent ("use when the user asks to …"). What prevents uninvited
  gate-firing is the conduct contract (rules 2 and 5), not a frontmatter
  flag — and because these skills are report-shaped, a mis-fire costs an
  overly thorough answer, never mutated state. /eval-spec is the wave's one
  user-only skill: like /plan, it creates committed artifacts and sets
  score targets, so it stays a typed, deliberate act.
- Disambiguation rule (binds every model-invocable skill in the pack): when
  a request plausibly matches more than one skill — "review the plan" could
  mean /plan-review's engineering lock or /audit docs' drift check — never
  silently pick. Present the candidates, one line each, and let the user
  choose. To make routing legible, every new SKILL.md carries an
  `Adjacent skills:` line near the top naming its nearest neighbors with a
  one-phrase contrast — read by the model when routing and by humans when
  browsing.

## 2.1 /challenge — product interrogation of the BRIEF

Frontmatter: `name: challenge`, `argument-hint: "[notes]"`, model-invocable.
Description scoped to intent: use when the user asks to challenge,
stress-test, or poke holes in a brief or an idea. `Adjacent skills:`
/plan-review (reviews the plan, not the brief — engineering, not product).

Reads BRIEF.md (legacy PLANNING_PROMPT.md). No brief → say so, point at
`/plan seed`, stop. Anchored to the document, not persona theater: one
written interrogation, every attack citing the BRIEF line it attacks.

Report shape, in order:

- **Premise attacks.** For each load-bearing premise in Context: steelman it
  in one sentence, then attack it — who exactly has this problem, what do
  they do about it today, why does now matter. A premise with no evidence
  named in the BRIEF is called out as such.
- **Narrower wedge.** At least one smaller version that still proves the
  core value: `Wedge: <scope> — drops <what>, still proves <what>`. If the
  full scope is genuinely the minimum, say so and defend it.
- **Constraint reality checks** (from `references/challenge-checklist.md`):
  cost/tier ceiling (does the plan fit the stated budget and free-tier
  limits, with numbers), hours reality (estimated build hours vs the hours
  the Context says exist), blast radius (what the first users experience if
  this breaks in week one, and whether the BRIEF accepts that).
- **Forcing questions.** Numbered, each answerable in one sentence. These are
  questions for the user, not rhetorical devices.
- **Verdict.** `proceed` / `narrow first` / `rethink` — one line of reason,
  stated as the report's FIRST line (shared stance: verdict up front, the
  sections as its evidence). No middle mush.
- **Scope.** What was not interrogated, so the verdict's coverage is
  honest. *(Both revised post-build; this shape originally put the verdict
  last and had no scope element.)*

Timing rule: /challenge is designed for the window between `/plan seed` and
the BRIEF's committing. If the BRIEF is already frozen, outcomes land in
PLAN.md as dated decisions with the `(Originally X, changed YYYY-MM-DD)`
breadcrumb — the BRIEF itself is never edited.

References: `references/challenge-checklist.md` — the three reality checks
with their exact question sets, plus a forcing-question bank by project type.

## 2.2 /plan-review — the engineering lock on PLAN.md

Frontmatter: `name: plan-review`, `argument-hint: "[phase N | notes]"`,
model-invocable. Description scoped to intent: use when the user asks to
review, lock, or sanity-check the plan before building. `Adjacent skills:`
/audit docs (does the doc match reality — drift, not soundness); /challenge
(interrogates the brief, not the plan).

Reads PLAN.md + BRIEF.md (legacy fallback). No plan → point at
`/plan build`, stop. Scope defaults to the whole plan; `phase N` narrows it.
Written pushback with teeth — the review /plan's gate promises, made
mechanical:

- **Data-flow trace.** Walk the primary flow end to end naming actual
  components, files, and stores at each hop; every hop names its producer
  and consumer. A hop the plan doesn't cover is a finding, not a footnote.
- **Failure modes.** Per phase: what breaks first under bad input, partial
  failure, and volume — each with how it would be detected and what the
  recovery is. "It won't" is not an acceptable detection story.
- **Test matrix.** The dimensions × cases table the plan implies but doesn't
  state. Flag every phase whose `**Exit criterion:**` is not literally
  runnable, and every task group missing `**Acceptance:**`.
- **Hidden assumptions.** Numbered list of things the plan treats as true
  without evidence: library capabilities, data shapes, rate limits, auth
  behavior, third-party uptime. Each with the cheapest probe that would
  confirm or kill it.
- **Verdict.** `LOCKED` or `CHANGES REQUIRED`. Changes are listed as exact
  supersede-style PLAN.md edits for the user to apply via `/plan replan` —
  /plan-review proposes, it does not rewrite.

On LOCKED, append one additive line under PLAN.md's Gate verdict block:
`**Plan review (YYYY-MM-DD): locked** — <one-line summary>`.

References: `references/review-dimensions.md` — the four dimensions with
per-dimension question sets and finding formats.

## 2.3 /eval-spec — the eval IS the spec (headline skill)

Frontmatter: `name: eval-spec`, `argument-hint: "[feature | notes]"`,
`disable-model-invocation: true` — the wave's one user-only skill: it
creates committed artifacts and sets score targets, so like /plan it stays
a typed, deliberate act.

Writes the eval before the system exists. For LLM-shaped features the eval
is the spec: if the golden set doesn't define success, the code has no
target. Sequence:

1. Read BRIEF.md + PLAN.md; interview for answer categories and domain
   landmines (the same landmines the BRIEF records — they become
   adversarial cases).
2. Write `eval/spec.md`: the category table (name, definition, **minimum
   case count**, target score), the grader definition, the run command, and
   the `acceptable_failure` policy.
3. Write the golden dataset skeleton `eval/golden.jsonl` — one JSON object
   per line: `id`, `category`, `input`, `expected`, `grade_rule`
   (`exact` | `concept` | `numeric-tolerance:<x>` | `rubric:<name>`),
   `acceptable_failure` (absent by default; when present, MUST carry a
   `reason` string).
4. Propose the PLAN.md edit wiring the eval run command into the relevant
   phase's `**Exit criterion:**` — the score target is set now, before code.

Category minimums are floors the spec states and the dataset must meet:
happy-path, edge, adversarial (garbage strings, oversized input,
regex-special chars, out-of-range values), and **refusal** — inputs where
the correct behavior is declining to answer (out-of-domain, no-data,
unsafe). A system that answers a refusal case fails that case.

Grader rules (in `references/grader-rules.md`, aligned with /audit eval):
assert the concept, not the literal wording; normalize Unicode before
substring compares; numeric answers get explicit tolerances; every rubric
names its dimensions. Grader-brittleness fixes are legitimate and logged;
editing a case or its expected value to raise a score never is.

Hard rules: the dataset is committed to the repo (repo-owned memory). A
golden case, once committed, is never edited to pass — a genuinely wrong
case is superseded (`superseded_by: <new-id>`, reason recorded) and a
corrected case added. The headline number is always computed from the raw
results file, never transcribed by hand.

References: `references/eval-spec-template.md` (the `eval/spec.md`
skeleton), `references/grader-rules.md`.

## 2.4 /investigate — no fixes without investigation

Frontmatter: `name: investigate`, `argument-hint: "<symptom | issue#>"`,
model-invocable (debugging mid-task is exactly when it should trigger).

The Iron Law: no fix is written until the investigation names a root cause
backed by discriminating evidence. Structure of an investigation:

1. **Symptom statement.** Exact observed behavior: error text verbatim,
   failing input, expected vs actual. "It's broken" is not a symptom.
2. **Reproduce first.** A minimal command that shows the failure. Can't
   reproduce → the investigation continues; a fix is not attempted.
3. **Known classes first.** Check the pack's
   `skills/audit/references/known-bug-classes.md` and the project's
   LEARNINGS.md before inventing hypotheses.
4. **Hypotheses vs evidence.** A table: hypothesis | evidence that would
   confirm or kill it | test run | result. A hypothesis with no
   discriminating test doesn't belong in the table.
5. **Root cause.** `file:line`, the mechanism, and why it produces exactly
   this symptom — the last one is the test that separates a root cause from
   a correlation.
6. **Proposed fix + verification.** The fix, the command that proves it, and
   the regression risk. The fix is *applied* only if the user asked for a
   fix; a bare `/investigate` ends with the report (assessment first).

**Three-strikes rule:** after 3 failed fix attempts, STOP. Write the state
up — dead hypotheses with the evidence that killed each, what remains
untested — into JOURNAL.md (document mode) or an issue comment (tickets
mode), and hand it to the user. There is never a silent fourth attempt.

Tickets-mode delta: `issue#` argument reads the issue for symptom context;
findings are offered as a `gh issue comment` so the investigation travels
with the ticket.

References: `references/investigation-method.md` — the hypothesis-evidence
discipline, repro-first rule, and three-strikes write-up format.

## 2.5 /resume — resume in five minutes

Frontmatter: `name: resume`, `argument-hint: "[notes]"`, model-invocable.
Read-only: writes no files, changes no state.

Read config, BRIEF.md, PLAN.md, JOURNAL.md (legacy fallback), `git status`,
and `git log` since the last `Journal` commit. Output, in chat:

- **Brief** (≤10 lines): what this project is, current phase and its exit
  criterion, what the last session actually did (from JOURNAL, with its
  numbers), what state the tree is in.
- **Divergence flags:** uncommitted changes, commits made since the last
  journal entry (candidates for `/journal`), and any checked box whose
  Acceptance command cheaply and visibly fails now.
- **Next 3 unblocked subtasks**, in plan order, each with its ID, text, and
  acceptance line. Unblocked = every prerequisite box checked.

Ends with a status statement. Starts nothing — naming the next tasks is
information, not an offer accepted (CONDUCT rules 2 and 9).

Tickets-mode delta: the checkbox scan becomes a tracker query — open issues
in the current milestone via `gh issue list`, next-3 = top unblocked open
issues (no `blocked` label), milestone burn stated as open/closed counts.

No references directory; the skill is small enough to be self-contained.

## 2.6 Tickets mode — `tracking: tickets` deltas in /plan and /do

Opt-in per project. Preconditions checked on every tickets-mode invocation:
`gh` present, authenticated, GitHub remote exists. Any failure → name the
missing precondition, offer document mode.

**/plan seed:** unchanged — BRIEF.md is identical in both modes.

**/plan build:** PLAN.md slims to: purpose blockquote, Gate verdict,
milestone index table (Milestone | Goal | Exit criterion), the decision log
(dated `> **Decision:**` blocks — **kept in-doc in both modes**; trackers
bury close-reasons in comments, the doc keeps them visible), cross-cutting
risks, and open items. Tasks live as issues, not checkboxes.

One-time bootstrap (idempotent — existing objects are left untouched, never
overwritten):

- Labels: `blocked`, `needs-acceptance`, `bug`, `feature`, `chore` —
  created only if absent.
- Milestones: one per phase; the phase's exit criterion becomes the
  milestone description (the definition of done).
- `.github/ISSUE_TEMPLATE/task.md`: scaffold with `## Acceptance criteria`,
  `## Files touched`, `## Out of scope` — so hand-filed issues arrive
  well-formed too.

Task → issue mapping (the quality bar every wave-1 plan task already meets):
title = task title; body = acceptance criteria (runnable where possible) +
file paths + out-of-scope; subtasks → a checklist in the issue body;
milestone = the task's phase.

**/do deltas:** `/do 42` (or `#42`) picks up that issue; bare `/do` proposes
the top unblocked issue in the current milestone and confirms before
starting. Branch `<branch-prefix><n>-<slug>` (e.g. `feature/42-fix-parser`).
Commit subjects use the rule-10 tickets shape: `#42: <subject>`. Work that
completes the issue carries `Fixes #42` (PR body under `push: branch-pr`,
commit body under `push: direct`); partial work references `#42` without
`Fixes`. Issue-body checklist items are ticked via `gh issue edit` as they
complete. The issue's acceptance section is run before anything closes; a
failing acceptance becomes an issue comment with the output — the issue
stays open.

README edit: config table's `tracking` row drops "(coming)".

## 2.7 /ticket — mode-agnostic capture

Frontmatter: `name: ticket`, `argument-hint: "<brain-dump>"`,
model-invocable (capture must be frictionless — it's what keeps ideas from
routing around the system).

Shape the brain-dump into a well-formed work item: verb-first title,
acceptance criteria (runnable where possible), file paths when known, an
out-of-scope line. What can't be determined from the dump is marked
explicitly — `Acceptance: TBD — needs <what>` — never invented. At most one
round of clarifying questions, and only when the item would otherwise be
unfileable.

- **Tickets mode:** `gh issue create` using the task template body, best-fit
  label, current milestone (ask only if genuinely ambiguous). Items with TBD
  acceptance get the `needs-acceptance` label.
- **Document mode:** append a numbered task (next free number under the
  current open phase — never renumber existing tasks) with its acceptance
  line. No obvious phase → a dated checkbox under `## Open items`.

Report what was filed (issue URL or PLAN.md line). Capture never starts the
work (CONDUCT rule 5).

## 2.8 /triage — backlog hygiene on demand

Frontmatter: `name: triage`, `argument-hint: "[notes]"`, model-invocable.
Description scoped to intent: use when the user asks to triage, groom, or
clean up the backlog or the plan's open tasks. `Adjacent skills:` /audit
docs (read-only drift report; /triage proposes tracker and plan actions).

Report-then-apply: the full findings report comes first; only user-approved
actions are executed. Nothing is ever silently deleted — every close carries
a written reason (supersede-don't-delete, applied to a backlog).

**Tickets-mode sweep:**

- **Stale:** open issues with no activity in `stale-days` (default 30) →
  propose close-with-reason (`superseded by #M` / `no longer planned —
  <reason>`) or re-prioritize.
- **Duplicates:** candidate pairs with the overlap evidence quoted; the
  newer closes as `duplicate of #N` only after the user confirms.
- **Missing acceptance:** issues without an acceptance section → listed,
  labeled `needs-acceptance`.
- **Unblocked-but-unassigned:** in current milestone, no `blocked` label,
  no assignee → surfaced as ready work.
- **Milestone burn:** per milestone — open/closed counts, the exit
  criterion restated, and an honest verdict on whether what remains can
  meet it.

**Document-mode sweep** (PLAN.md hygiene): checked boxes whose Acceptance
now fails (propose re-open with dated verdict), unchecked boxes whose
artifact plainly exists (verify acceptance before proposing the tick),
tasks with no acceptance line, open items dated older than `stale-days`,
and phase-heading state inconsistent with its children.

No references directory.

## Build order and commits

One commit per increment, wave-1 subject style:

1. `add resume skill (five-minute brief + next unblocked tasks)` — smallest,
   standalone, immediately useful on this repo itself.
2. `add investigate skill (iron law, hypotheses vs evidence, three strikes)`
3. `add challenge skill (premise attacks, narrower wedge, reality checks)`
4. `add plan-review skill (data-flow trace, failure modes, test matrix)`
5. `add eval-spec skill (golden categories, grader rules, refusal cases)`
6. `add tickets mode (plan/do deltas, label-milestone-template bootstrap)`
7. `add ticket skill (mode-agnostic capture to issue or plan task)`
8. `add triage skill (stale, dupes, missing acceptance, milestone burn)`

/ticket and /triage come after 2.6 because their tickets-mode behavior
depends on its label set and issue template.

## Wave verification (the PLAN.md exit criterion, expanded)

In a scratch GitHub repo (throwaway, private):

1. `/plan seed` + `tracking: tickets` → bootstrap verified via
   `gh label list`, `gh api repos/:owner/:repo/milestones`, and the template
   file's presence; re-run proves idempotency (no duplicates, no edits).
2. `/ticket` files an issue that meets the bar (acceptance + files +
   out-of-scope in the body).
3. `/do <issue>` lands a `feature/<n>-<slug>` branch whose merge closes the
   issue via `Fixes #N`.
4. `/triage` grooms a deliberately seeded messy backlog (a stale issue, a
   duplicate pair, an acceptance-less issue) — report first, approved
   actions only, every close reasoned.
5. `/eval-spec` on a toy feature produces `eval/spec.md` + `eval/golden.jsonl`
   with all category minimums met, before any implementation exists.
6. Document-mode spot checks on this repo: `/resume` (brief + next 3),
   `/challenge` and `/plan-review` against a scratch BRIEF/PLAN.
7. `scripts/check.sh` clean; `./setup` links 12 skills idempotently; a fresh
   session lists all 12.

## What wave 2 does NOT include (intentional)

- Wave-3 skills (/qa, /secure, /ship, /retro, /learn, /design-audit,
  /doctor) and the wave-4 runtime (preamble, bin/, telemetry, VERSION).
- Linear/Jira tracker support — GitHub Issues only at launch (locked
  decision; other trackers are post-launch roads).
- Auto-triage on a schedule, auto-close of stale issues, or any tracker
  mutation without a user-approved report first.
- A GitHub remote for THIS repo — the wave-2 exit test uses a scratch repo;
  acstack's own remote remains a parked open item.
