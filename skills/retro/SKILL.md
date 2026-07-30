---
name: retro
description: Trend review across many sessions - velocity vs planned dates, eval-score trend toward target, failure-category trends from journal triage and investigations, and a status check on every open PLAN risk. Reads JOURNAL/PLAN/eval history, writes a dated retro entry into JOURNAL.md. Use when the user asks for a retro, a weekly review, or a phase-end wrap-up.
argument-hint: "[week | phase N | notes]"
---

# /retro — the trend across sessions

/journal records one session; /retro reads many and says where the line
is heading. Not a summary — a trend, with the numbers that make "we're
slipping" or "the eval is climbing" a fact instead of a feeling.

`Adjacent skills:` /journal (one session's worklog; /retro trends across
many) · /audit eval (one report's honesty; /retro the trend across runs)
· /triage (grooms the backlog; /retro reviews the trajectory).

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

## Inputs

- JOURNAL.md entries since the last retro (the window; `week` or
  `phase N` in the argument narrows it).
- PLAN.md: planned phase dates, exit criteria, the open risks and items.
- Eval artifacts when present: `eval/spec.md` targets and the result
  files across runs.
- `git log` over the window for commit / checkbox velocity.

## Sections

The four sections live in `references/retro-sections.md` with their
question sets and honest-degradation lines. Lead with a verdict:
`on plan` / `slipping — <where>` / `off plan`.

1. **Velocity vs plan.** Planned phase dates vs actual; boxes or issues
   closed per period vs the plan's implied rate; slippage named in days
   with the cause pulled from journal entries, not guessed.
2. **Eval trend.** Headline score per run across the window, per-category
   direction, distance to target. No eval history → one honest line and
   the section ends.
3. **Failure-category trends.** Counts by class from the journal's eval
   triage sections and /investigate write-ups; a class recurring 2+
   times is named as a /learn promotion candidate.
4. **Risk review.** Each open PLAN risk: still real / materialized /
   retired, with evidence. New risks are proposed as dated PLAN edits —
   proposed, never applied by /retro.

## Not in wave 3

No skill-usage / telemetry section — it arrives with the local
telemetry it reads (PLAN task 4.3, moved to wave 4.5 post-launch by the
2026-07-29 split). Don't emit a placeholder for it; its absence is
correct, not a gap.

## Output

Append to JOURNAL.md as a dated entry under `## Key decisions and
journey`, newest first:
`### Retro (YYYY-MM-DD — <window>)`. Commit using the project's
`journal-commit-format` (pack default `Journal <date>: <summary>`) with
`retro — <summary>` as the summary, brief body, attribution per config.
PLAN edits the retro proposes are listed for the user to apply
via `/plan replan` — /retro writes the journal, not the plan.

## Tickets-mode delta

Velocity becomes closed issues + milestone burn via
`gh issue list --state closed` and the milestone API; failure classes
are additionally mined from issue labels and closing comments.
Preconditions — `gh` installed, `gh auth status` succeeding, and a
GitHub remote present. Any failure names WHICH one failed and offers
document mode; never guess.
