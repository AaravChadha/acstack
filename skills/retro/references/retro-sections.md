# Retro sections — question sets and honest degradation

Every claim carries its number and its source (the journal entry, the
result file, the git range). A section with no data says so in one line
and ends — a retro that pads absence with prose is the trend-level
version of inflating a score.

## 1. Velocity vs plan

Questions:

- What phase dates did PLAN.md project, and what were the actual dates
  the exit criteria passed (from journal entries)?
- Boxes or issues closed per period over the window vs the rate the plan
  implies to hit its dates.
- Where did slippage happen, in days, and what does the journal say
  caused it — blocked dependency, scope growth, rework?

```bash
git log --since='<window start>' --format='%ci %s' | grep -iE 'completed task|task [0-9]|ticket #|Fixes #|Journal'
```

Verdict form: "Phase 3 projected 2026-07-20, exit criterion passed
2026-07-27 — 7 days slip; journal cites the eval rewrite." Not "a bit
behind."

Degradation: no dated plan → "PLAN.md sets no phase dates; velocity
reported as raw close-rate only, no vs-plan comparison possible."

## 2. Eval trend

- Headline score per run across the window (from the raw result files,
  never transcribed by hand — the never-inflate rule).
- Per-category direction: which categories improved, which regressed.
- Distance to the `eval/spec.md` target, and whether the trend line
  reaches it at the current slope.

Degradation: no `eval/` history → "No eval runs in the window; eval
trend not assessable." One line, section ends. One run only → report the
single point, state that a trend needs a second.

## 3. Failure-category trends

Classes (shared with /audit eval and /journal): prompt issue / grader
brittleness / provider flake / data issue / parser issue / genuinely
ambiguous — plus code-defect classes from /investigate write-ups.

- Count each class over the window from journal triage sections.
- A class appearing 2+ times is a **/learn promotion candidate** — name
  it as such; recurring failures belong in known-bug-classes, not
  rediscovered each sprint.
- A class that appeared last window and not this one is retired — say
  so; disappearance is a result too.

Degradation: no classified failures in the window → "No eval/investigation
failures recorded this window."

## 4. Risk review

For each risk in PLAN.md's open risks / items:

- **Still real** — unchanged, restate it and its owner.
- **Materialized** — it happened; point to the journal entry, and check
  the mitigation was what the plan predicted.
- **Retired** — the condition that made it a risk is gone; say why.

New risks surfaced by the window's work are written as proposed dated
PLAN edits (`> **Risk (YYYY-MM-DD):** … **Owner: Phase N.M**`) for the
user to apply — /retro proposes, /plan replan disposes. Never edit
PLAN.md from /retro; the journal entry is /retro's only write.
