# Hackathon PLAN.md template — 24–48h, 2–4 people or sessions

Same grammar as plan-template.md, compressed for a timed event. Differences:
clock windows instead of days, build-order arrows, owner tags, a file
ownership table, a demo script, and a submission checklist. Owners come from
the config's `## Collaborators`; an owner can be a person or one of several
sessions run by one person.

**Every task carries its own `**Acceptance:**` line.** `/do` will not tick a
box without one, so a plan that leaves them out makes every task stop and
wait for the user to approve a check. Measured 2026-09-23: four sessions ran
`/do` on this template's old shape, which had no acceptance lines, and
**0 of 4** tasks were ticked.

```markdown
# <Project name>
### <Event name> | <duration>

## Problem
<2-3 sentences. The judge-facing pain.>

## Solution
<Numbered 1-5 capability list — what it does, not how.>

## Tech Stack
| Layer | Choice | Reason |
|---|---|---|
| <layer> | <tool> | <why — free tier and setup speed count as reasons> |

## File ownership

| Track | Owner | Edits only | Reads from |
|---|---|---|---|
| A | <owner> | `<dir or files>` | — |
| B | <owner> | `<dir or files>` | Track A's function names, fixed in PLAN.md |

<Every file the plan will create is in exactly one "Edits only" cell. A
session that needs a change in another track's file asks that track; it does
not edit it. PLAN.md is shared, and only `/do` edits it, one box per task.>

## Phases

### [ ] Phase 0 — Setup `Friday 5–8pm` (~1 hr)
> Goal: <one sentence>

### [ ] Phase 1 — <core> `Friday 8pm → Saturday 12pm` (~3–4 hrs)
> Goal: <one sentence>
> **Build order:** 1.1 → 1.3 → 1.2 → 1.4 (share schemas after 1.3 to
> unblock teammates)

- [ ] **1.1 <task> (Track A — <owner>)** ← start here
  **Acceptance:** `<command>` prints `<expected>`.
- [ ] **1.3 <task> (Track A — <owner>)** ← do second, share with teammates
  immediately after
  **Acceptance:** `<command>` prints `<expected>`.
- [ ] **1.2 <task> (Track B — <owner>)** ← unblocks <owner 2>
  - [ ] 1.2.1 <leaf with exact file/endpoint/literal>
  **Acceptance:** `<command>` prints `<expected>`.

<Physically reorder subtasks to match the build order — the document order
IS the execution order.>

## Demo Script for Judges

**Scenario 1 — <name> (shows <the feature>):**
> <spoken setup, one sentence>
- <click-path, one line>

<Close with a meta-judgment: which scenario is the strongest talking point.>

## Future Extensions (mention to judges, don't build)
- <each on one line>

## Submission checklist `<final window>`
- [ ] Confirm `.env` never committed: `git log --all -- '*.env'` is empty.
- [ ] README has run instructions verified on a teammate's clone.
- [ ] Any event-required sections present and **user-authored** — the
  agent never writes them (see the pack's attribution setting).
- [ ] Demo rehearsed once end-to-end, timed.
```

## The fast-lane block for AGENTS.md

In hackathon mode `/plan` also writes this block into the project's
AGENTS.md, between its markers, filling in the event end. A project's own
AGENTS.md is what overrides a personal "merge only through a PR" rule for
this one repo, so the lane has to be written here, not assumed.

```markdown
<!-- acstack:hackathon-lane -->
## Hackathon fast lane (this repo only, until <event end>)

This project is a timed event. For this repo, these rules replace any
"merge only through a pull request" or "one integrator merges" rule in
personal instructions.

- One session per track, each in its own git worktree and branch. Nobody
  edits in the main checkout; keep it on a detached `main`
  (`git switch --detach main`) and use it only to run the demo.
- Edit only the files your track owns (PLAN.md, "File ownership"). For a
  change in another track's file, ask that track's session.
- `/do` merges its own finished task into `main` as soon as the task's
  acceptance passes. There is no pull request, no review and no integrator.
- Before starting a task that builds on another track, check that the other
  track's work is already on `main`.
- Pushing `main` to the remote is a backup. Nothing waits for it.

What this gives up on purpose, for the length of the event: review before
merge, CI before merge, and a protected `main`. Put them back afterwards.
<!-- /acstack:hackathon-lane -->
```

## Change rules under time pressure

Same as standard, faster notation:
- Dropped scope stays visible:
  `- [x] 3.1.2 ~~Implement external API~~ — using mock data (swap in if
  credits materialize)`
- Moved work leaves the one-line breadcrumb; decimal phases (`3.5`) for
  integrations discovered mid-event.
- Done-by attribution appended: `— done by <owner> in Phase 3`.
- A task added mid-event gets its `**Acceptance:**` line when it is added,
  not later. Without it `/do` cannot finish the task.
