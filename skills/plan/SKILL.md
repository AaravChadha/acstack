---
name: plan
description: Create or evolve project planning docs. Modes - seed (write BRIEF.md, the frozen problem statement, and gate on written architecture pushback), build (write PLAN.md, the living phase plan with runnable exit criteria), replan (supersede decisions with dated verdicts, insert decimal phases). Hackathon shape via config or the hackathon argument.
argument-hint: "[seed|build|replan] [hackathon] [notes]"
disable-model-invocation: true
---

# /plan — the seed, the gate, and the living plan

Planning docs are deliberate artifacts. This skill is user-invoked only and
never regenerates a plan spontaneously.

`Adjacent skills:` /challenge (interrogates the BRIEF this creates) ·
/plan-review (locks the PLAN this creates before code) · /eval-spec (sets
the score targets a phase exit criterion cites) · /do (executes the tasks).

<!-- acstack:principles -->
## Operating principles

- Be direct. Push back in writing when the plan or the user is wrong. No sycophancy.
- Never delete a decision. Supersede it: `~~old~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- Never fix, tune, or delete a test or eval case to raise a score. Log the miss honestly and leave the case unchanged.
- Name exact things: regex patterns, function signatures, model names, before → after numbers. Never "fixed bugs".
- Attribution: follow the project's `attribution` setting (default `none`) — no AI-tool mentions in generated docs, no attribution trailers in commits or PRs. Commit with explicit `-m`/`-F` messages only.
- Config: read `.claude/acstack.md` at the project root (fall back to `~/.claude/acstack.md`) before acting. `## Settings` keys override pack defaults; a `## <skill-name>` section overrides both. Unknown keys and sections are ignored.
- Docs: BRIEF.md (frozen seed) / PLAN.md (living plan) / JOURNAL.md (rolling journal). If the repo uses legacy names (PLANNING_PROMPT.md / PLANNING.md / STATUS.md), use those instead — never create both.
- Recall: if `LEARNINGS.md` exists at the project root, read it before starting.
- Conduct: follow the `acstack-conduct` block in this repo's AGENTS.md — the word is the mode; the user sets the pace.
<!-- /acstack:principles -->

## Mode dispatch

Parse the arguments. No mode given: if no BRIEF.md exists → `seed`; if
BRIEF.md exists but no PLAN.md → `build`; otherwise ask which mode is wanted.
`hackathon` as an argument (or `mode: hackathon` in config) switches the
templates to the hackathon shape.

## Mode: seed — write the frozen BRIEF

Interview the user (or take their brain-dump) and write `BRIEF.md` following
`references/brief-template.md`. Required sections — if the user hasn't
supplied one, ask; never silently skip:

- **Context** — who this is for, why now, what stage, solo or team.
- **Source data / domain landmines** — the gotchas an implementer must know
  (formats, quirks, do-NOT rules). Prompt for these explicitly; every domain
  has them.
- **Architecture Decision: <choice>, NOT <rejected>** — with the reasoning.
- **What I want help with FIRST** — numbered validation items, ending with
  "Don't write code yet."
- **Constraints** — including explicit non-negotiables.
- **What's intentionally out of scope.**
- **Open questions I haven't resolved** — unknowns admitted in writing.
- The closing gate line: validate the architecture with written pushback
  BEFORE any code — be direct, push back, don't be sycophantic.

**BRIEF.md is frozen once committed.** Later corrections are recorded in
PLAN.md as dated decisions with an `(Originally X, changed YYYY-MM-DD)`
breadcrumb. The brief stays an honest record of what was believed at the
start — that is its entire value.

Seed housekeeping (same invocation):
- Ensure `CLAUDE.md` is exactly `@AGENTS.md`. If it has real content, flag it
  and propose moving the content to AGENTS.md — never silently rewrite.
- Ensure AGENTS.md contains the pack's `acstack-conduct` block (copy the
  marker-fenced block from the pack's CONDUCT.md). Refresh only between the
  markers; never touch content outside them.
- Create an empty `LEARNINGS.md` if none exists (a place for /learn later).
- Offer to copy `templates/acstack.md` to `.claude/acstack.md` if absent.

## The gate — before build

`build` runs only after the gate: deliver written architecture pushback on
the BRIEF — what won't work, where the user is being naive, risks, the
rejected alternatives reconsidered — and get the user's explicit
acknowledgment. Record the verdict in a short **Gate verdict** block at the
top of PLAN.md (date, what was challenged, what changed, what was accepted
as-is). No pushback delivered → no plan, no code.

## Mode: build — write the living PLAN

Generate `PLAN.md` following `references/plan-template.md`. The grammar:

- Top: purpose blockquote (what this doc is, pointer to BRIEF.md) +
  cross-cutting constraints blockquote + the Gate verdict block.
- `## Index of phases` — table: Phase | Goal | Exit criterion (add Days when
  timeboxed).
- Phase headings carry state: `## [ ] Phase N — Title`.
- Each phase: `**Goal:**` one-liner, then `**Exit criterion:**` as a
  RUNNABLE command with expected output — never prose like "works well".
- Tasks: numbered bold-ID checkboxes 3–5 levels deep
  (`- [ ] **1.2.3** …`), leaf text naming exact files, functions, and
  literal values. Task groups close with `**Acceptance:**` — also runnable.
- Decisions: `> **Decision (YYYY-MM-DD):** <call>. Tradeoff: <cost>;
  mitigated by <mitigation>. Revisit when <trigger>.`
- `## Cross-cutting risks` — each risk owned: `**Owner: Phase N.M**`.
- `## Open items` — dated checkboxes.
- Optional `## Glossary` for invented terms.

## Mode: replan — change the plan honestly

- Nothing is deleted or silently edited. Changed decisions:
  `~~old text~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- New scope discovered mid-project becomes a decimal phase (`Phase 3.5`)
  inserted in place, with a Goal explaining why it exists mid-stream.
- Deferred work leaves a breadcrumb at both ends: the origin notes
  `1.4.2 moved to Phase 3.5 (<reason>)`; the destination names the origin.
- Reality diverging from plan gets `**Status (YYYY-MM-DD):**` lines under
  the phase, keeping the original target visible.

## Tickets mode (`tracking: tickets`)

Opt-in per project. Preconditions checked on every tickets-mode invocation:
`gh` present and authenticated, GitHub remote exists. Any failure → name
the exact missing precondition and offer document mode; never guess.

- **seed** is unchanged — BRIEF.md is identical in both modes.
- **build** slims PLAN.md to: purpose blockquote, Gate verdict, milestone
  index table (Milestone | Goal | Exit criterion), the decision log
  (dated `> **Decision:**` blocks — kept IN-DOC in both modes: trackers
  bury close-reasons in comments, the doc keeps them visible),
  cross-cutting risks, and open items. Tasks live as issues, not
  checkboxes.
- **One-time bootstrap**, idempotent — existing objects are left
  untouched, never overwritten:
  - Labels, created only if absent: `blocked`, `needs-acceptance`, `bug`,
    `feature`, `chore`.
  - Milestones: one per phase; the phase's exit criterion becomes the
    milestone description (its definition of done).
  - `.github/ISSUE_TEMPLATE/task.md`: scaffold with `## Acceptance
    criteria`, `## Files touched`, `## Out of scope` — so hand-filed
    issues arrive well-formed too.
- **Task → issue mapping:** title = task title; body = acceptance criteria
  (runnable where possible) + file paths + out-of-scope; subtasks → a
  checklist in the issue body; milestone = the task's phase.
- **replan** in tickets mode: decision-log supersessions work exactly as in
  document mode; scope moves between milestones are recorded as a dated
  decision in PLAN.md plus a milestone change on the issue.

## Hackathon mode

Use `references/hackathon-template.md` instead: clock-window phase headings
with hour estimates, a `> **Build order:**` blockquote with arrows and
unblock rationale, owner tags from the config's `## Collaborators`,
`← unblocks <owner>` annotations, a `## Demo Script` section, a
`## Future Extensions (mention, don't build)` section, and a submission
checklist that includes verifying `.env` was never committed
(`git log --all -- '*.env'`) and that any event-required sections are
present and user-authored.
