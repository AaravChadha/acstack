# BRIEF.md template — the frozen seed

Write in first person to the assistant. Every `<...>` is a slot; every
section is required. Once committed, this file is never edited — corrections
land in PLAN.md as dated decisions.

```markdown
# Project: <name> — <one-line qualifier, e.g. "Pilot Build">

## Context

<Who this is for and why now. What stage the project is at. Solo or team —
and if team, who does what. What "success" means for this phase, in one
sentence an outsider could verify.>

## Source Data

<Where the data/inputs come from, at what cadence, in what format, with what
access requirements. Concrete numbers: how many records, how large, verified
how.>

### Domain landmines

<The gotchas an implementer must know, as flat bullets. The things that look
like bugs but aren't, and the things that look fine but are bugs. Examples of
the expected texture:>
- "NA" appears throughout → must become NULL (not 0, not empty string).
- <Same entity appears twice legitimately> — these are genuinely different
  records, do NOT dedupe.
- Date formats differ between <place A> ("04 May 2026") and <place B>
  ("31 Mar 2026") → normalize on ingest.

## Architecture Decision: <choice>, NOT <rejected alternative>

<Why the chosen shape fits and the rejected one doesn't — argued from the
data and the questions being asked, not from fashion. Name the layers and
what each is responsible for.>

## <Schema / structure proposal>

<The concrete starting point: DDL, directory layout, API sketch. Detailed
enough to be criticized — the gate exists to attack this.>

## What I want you to help me with FIRST (planning stage, don't write code yet)

1. **Validate the architecture.** What would you change and why? Where am I
   overengineering? What will I regret in a month?
2. **Sanity-check the riskiest component** — <name it>. How would you build
   and test it?
3. **Suggest the build order.** My current plan: <ordered list with rough
   days>. Push back if the order is wrong.
4. **Don't write code yet.** I want the plan, the risks, and the open
   questions before implementation starts. Give me your honest assessment,
   including what you think won't work or where I'm being naive.

## Constraints

- <Time, money, people. e.g. "Solo developer, ~2 weeks to pilot.">
- <Hard technical constraints, each on its own line.>
- <Non-negotiables, stated as such: "… — this is non-negotiable, even at
  5 users.">

## What's intentionally out of scope

- <Each exclusion on its own line — the things a helpful assistant would
  otherwise suggest. This list is a fence, not a roadmap.>

## Open questions I haven't resolved

- <Real unknowns, admitted in writing, each with the tradeoff as currently
  understood and, where useful, "Want your take.">

Start with item (1) above — validate the architecture. Then (2), (3), (4) in
order. Be direct, push back where I'm wrong, and don't be sycophantic.
```

Notes for the skill:
- If the user can't fill "Domain landmines" yet, that is itself a finding —
  record "none known yet; expect to discover during <phase>" rather than
  omitting the section.
- The final line's directness instruction is load-bearing: it licenses the
  gate. Never soften it.
