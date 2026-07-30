---
name: challenge
description: Interrogate a BRIEF before committing to it - premise attacks with steelmans, a narrower-wedge proposal, cost/hours/blast-radius reality checks, forcing questions, and a proceed / narrow-first / rethink verdict. Use when the user asks to challenge, stress-test, or poke holes in a brief, an idea, or a product premise.
argument-hint: "[notes]"
---

# /challenge — interrogate the brief

One written interrogation of the product premise, anchored to the BRIEF
document line by line. Not persona theater — every attack cites the line it
attacks, and the output ends in a verdict, not a mood.

`Adjacent skills:` /plan-review (reviews the plan, not the brief —
engineering soundness, not product premise).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + pack known-bug-classes, capped 6KB
else
  echo "runtime off — proceeding without recall/update-check"
fi
```
<!-- /acstack:runtime -->

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

**One document set.** Resolve exactly ONE BRIEF/PLAN/JOURNAL set and name
its path in the report's scope line. If more than one candidate set exists
— a monorepo, nested products, an `apps/*` tree each with its own docs —
list the candidates and STOP. Never pick one silently: a confident answer
about the wrong product is worse than no answer (conduct rule 8).

## Precondition

Read BRIEF.md (legacy: PLANNING_PROMPT.md). No brief exists → say so, point
at `/plan seed`, stop. An interrogation without a document to cite becomes
opinion trading, which is exactly what this skill exists to prevent.

## The report — in this order

The report's FIRST line is the verdict — `proceed` / `narrow first` /
`rethink`, with one line of reason — stated as the report's FIRST line:
verdict up front, evidence after. No middle mush; "proceed with caveats"
is `narrow first` wearing a softer coat. The sections below are the
evidence for it.

### 1. Premise attacks

For each load-bearing premise in the BRIEF's Context: steelman it in one
sentence, then attack it — who exactly has this problem, what do they do
about it today, why does now matter. A premise the BRIEF states without
evidence is called out as unevidenced, in those words. Each attack cites
the BRIEF line it targets.

### 2. Narrower wedge

At least one smaller version that still proves the core value:
`Wedge: <scope> — drops <what>, still proves <what>`. If the full scope is
genuinely the minimum viable test of the premise, say so and defend why no
smaller wedge exists.

### 3. Constraint reality checks

The three checks from `references/challenge-checklist.md`, run with
numbers, not adjectives:

- **Cost/tier ceiling** — does the plan fit the stated budget and free-tier
  limits (requests/day, storage, seats)? Show the arithmetic.
- **Hours reality** — estimated build hours vs the hours the Context says
  exist. A 60-hour plan against 10 hours/week is a 6-week plan; say that.
- **Blast radius** — what the first users experience if this breaks in
  week one, and whether the BRIEF's Constraints and Context accept that
  exposure.

### 4. Forcing questions

Numbered, each answerable in one sentence, each one the user must answer —
not rhetorical devices. Draw from the question bank in the checklist
reference where it fits the project type.

### 5. Scope

What was NOT interrogated — premises out of scope, reality checks that
lacked the numbers to run — so the verdict's coverage is honest.

## Timing and where answers land

/challenge is designed for the window between `/plan seed` and the BRIEF's
commit — answers can still be edited into the draft. Once the BRIEF is
frozen, outcomes land in PLAN.md as dated decisions with the
`(Originally X, changed YYYY-MM-DD)` breadcrumb; the BRIEF itself is never
edited (its value is being an honest record of what was believed at the
start).

## Hard rules

- Interrogate the product, not the person. Attacks name premises, never
  competence.
- Report only: no scaffolding, no code, no PLAN.md edits in the same turn.
  The verdict is delivered, then the user rules (CONDUCT rules 1 and 2).
- A verdict of `proceed` must still contain the attacks — a challenge that
  found nothing to attack didn't look.
