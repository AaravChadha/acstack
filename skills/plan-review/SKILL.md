---
name: plan-review
description: Engineering review that locks PLAN.md before code - end-to-end data-flow trace, failure modes per phase with detection and recovery, the test matrix the plan implies but doesn't state, hidden assumptions with their cheapest probes, and a LOCKED or CHANGES REQUIRED verdict. Use when the user asks to review, lock, or sanity-check the plan before building. For doc-vs-reality drift use /audit docs; for interrogating the brief use /challenge.
argument-hint: "[phase N | notes]"
---

# /plan-review — the engineering lock

The written pushback /plan's gate promises, made mechanical. The plan is
reviewed as an engineering artifact: flows must connect, failures must be
detectable, criteria must be runnable, assumptions must be named.

`Adjacent skills:` /audit docs (does the doc match reality — drift, not
soundness) · /challenge (interrogates the brief's premise, not the plan's
engineering).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
pack="$(dirname "$(dirname "$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)")")"
if [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
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

## Precondition and scope

Read PLAN.md and BRIEF.md (legacy names per the principles block). No plan →
point at `/plan build`, stop. Scope defaults to the whole plan; a `phase N`
argument narrows it — say which scope was reviewed either way.

## The four dimensions

Question sets and finding formats in `references/review-dimensions.md`.

### 1. Data-flow trace

Walk the primary flow end to end, naming the actual component, file, or
store at every hop; every hop names its producer and its consumer. A hop
the plan doesn't cover is a finding, not a footnote. Where the plan names
a table, config key, or format, the trace uses that exact name — mismatched
names across phases are exactly the class of bug this catches.

### 2. Failure modes

Per phase in scope: what breaks first under bad input, partial failure,
and volume — each with how it would be DETECTED and what the recovery is.
"It won't fail" is not a detection story; neither is "we'd notice".

### 3. Test matrix

The dimensions × cases table the plan implies but doesn't state. Then flag,
by ID: every phase whose `**Exit criterion:**` is not literally runnable
(prose like "works well"), and every task group missing `**Acceptance:**`.

### 4. Hidden assumptions

A numbered list of things the plan treats as true without evidence:
library capabilities, data shapes, rate limits, auth behavior, third-party
uptime. Each with the CHEAPEST probe that would confirm or kill it — a
one-line script, a doc lookup, a 10-row sample query.

## Verdict

**Stated as the report's FIRST line**, before the four dimensions —
they are its evidence, not its build-up. Restate it here at the end.

- **`LOCKED`** — the plan survives all four dimensions. Append one additive
  line under PLAN.md's Gate verdict block:
  `**Plan review (YYYY-MM-DD): locked** — <one-line summary>`. That line is
  the only edit this skill ever makes.
- **`CHANGES REQUIRED`** — findings listed as exact supersede-style edits
  (`~~old~~ → **Verdict (date):** new — reason`, new tasks with IDs and
  acceptance lines) for the user to apply via `/plan replan`.

/plan-review proposes; it does not rewrite. The review's authority comes
from the user applying its findings, not from the reviewer holding the pen.

## Hard rules

- Every finding cites the plan line or phase it concerns; findings that
  can't name their target aren't findings.
- Review the plan that exists, not the plan you'd have written — style
  preferences are not findings.
- State what was NOT reviewed (phases out of scope, externals not probed).
- A `LOCKED` verdict with zero findings across all four dimensions means
  the review didn't dig; the trace and matrix are mandatory work products
  even when the verdict is clean.
