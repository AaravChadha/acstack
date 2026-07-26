# Hackathon PLAN.md template — 24–48h, 2–4 people

Same grammar as plan-template.md, compressed for a timed event. Differences:
clock windows instead of days, build-order arrows, owner tags, a demo script,
and a submission checklist. Owners come from the config's `## Collaborators`.

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

## Phases

### [ ] Phase 0 — Setup `Friday 5–8pm` (~1 hr)
> Goal: <one sentence>

### [ ] Phase 1 — <core> `Friday 8pm → Saturday 12pm` (~3–4 hrs)
> Goal: <one sentence>
> **Build order:** 1.1 → 1.3 → 1.2 → 1.4 (share schemas after 1.3 to
> unblock teammates)

- [ ] **1.1 <task> (Track A — <owner>)** ← start here
- [ ] **1.3 <task> (Track A — <owner>)** ← do second, share with teammates
  immediately after
- [ ] **1.2 <task> (Track B — <owner>)** ← unblocks <owner 2>
  - [ ] 1.2.1 <leaf with exact file/endpoint/literal>

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

## Change rules under time pressure

Same as standard, faster notation:
- Dropped scope stays visible:
  `- [x] 3.1.2 ~~Implement external API~~ — using mock data (swap in if
  credits materialize)`
- Moved work leaves the one-line breadcrumb; decimal phases (`3.5`) for
  integrations discovered mid-event.
- Done-by attribution appended: `— done by <owner> in Phase 3`.
