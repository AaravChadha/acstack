# PRINCIPLES.md — why acstack works the way it does

The operating principles ship inside every skill, byte-identical. This
file is the *why* behind each one. Nothing here is aspirational: every
principle exists because its absence produced a specific defect, and
most are enforced by `scripts/check.sh` rather than by good intentions.

**Positioning:** other packs simulate a team; acstack encodes a
discipline. The difference shows up in what gets written down and where
it lives.

---

## Repo-owned memory

All project memory — BRIEF, PLAN, JOURNAL, LEARNINGS — is committed
markdown in your repository. Not a database, not a daemon, not a
machine-local store.

**Why:** memory that lives outside the repo cannot be reviewed in a pull
request, shared with a teammate, or survive a laptop. Memory that lives
*in* the repo is diffable, blameable, and portable by construction; when
you clone the project you get its history of decisions with it. The cost
is honest and worth naming: capture is manual — `/journal` and `/learn`
must actually run. We took that trade deliberately over automatic
capture into a private store.

The only machine-local state in the entire pack is
`~/.acstack/update-stamp`: one line, one date.

## Never inflate a score

Never fix, tune, or delete a test or eval case to raise a number. A
genuinely wrong case is *superseded* — new id, written reason, old case
left standing.

**Why:** the moment a score can be edited to look better, it stops
measuring anything. This is the pack's sharpest rule and it applies to
its own machinery: `/eval-run` recomputes the headline from the results
file rather than tallying in memory, and its positive control is a
deliberately failing case that must drag the number below 100%. A runner
that reports a perfect score by construction is indistinguishable from a
working one — from the outside.

Grader brittleness is the one legitimate fix (assert the concept, not
the wording; normalize Unicode before comparing), and the report says
which remedy it recommends and why.

## Supersede, never delete

Decisions are struck through and dated, not removed:
`~~old~~ → **Verdict (YYYY-MM-DD):** new call — reason.`

**Why:** the record of what you believed and why you changed your mind
is more valuable than a tidy current state. A deleted decision gets
relitigated in six months by someone who cannot find the reasoning. This
is also why BRIEF.md is frozen after commit — it is the honest record of
what was believed at the start, which is its entire value as an
arbitration document.

## Runnable exit criteria

A phase ends with a command and its expected output, never "works well."
Task groups close with a runnable `**Acceptance:**` line.

**Why:** prose completion criteria are negotiable at exactly the moment
you are most motivated to negotiate them. A command is not.

## Mechanical over rhetorical

Where a rule can be a check, it becomes a check. `scripts/check.sh` has
grown to fifteen numbered sections; `allowed-tools` declarations replace prose
promises about not writing; `docs/guard-matrix.sh` proves each guard
fires before it is trusted.

**Why, with numbers:** three audit rounds on this repo found roughly 25,
39, and 35 defects — while the share *caused by the previous round's
fixes* ran 0%, then 25%, then 60%. Writing prose generates defects at a
real rate. What broke the cycle was writing the test first. A prose rule
degrades quietly; a check either fires or does not.

## Prove the check fails before trusting it

Every guard is demonstrated against a seeded defect before it counts as
coverage. Every check-shaped skill ships a positive-control fixture.

**Why:** this repo has produced three false passes — a secret regex that
stopped at the first hyphen and reported clean on a planted key; a
description guard whose first control passed because the text it tested
had already been fixed; and a palette check whose `\b` matched nothing
at all, because `git grep -E` is POSIX ERE. A broken check that returns
a pass is worse than no check: it converts an unknown into a false
certainty.

## Honest degradation

A skill that cannot do its job says which precondition failed and stops.
It never guesses, and it never silently does something smaller while
sounding complete. Ambiguity — two candidate document sets, an unstated
stack — is a reason to halt, not to pick.

**Why:** a confidently wrong answer costs more than no answer, because
nobody checks it. This is also why every report states what it did *not*
examine: a verdict is an input to your judgment, not a permission slip.

## The word is the mode

"Explain" means explain and stop. "Plan" means design artifacts only.
Build happens on an explicit go, and only the increment named. The user
sets the pace.

**Why:** the most common failures of agentic coding are not bad code but
bad conduct — building when asked to explain, racing ahead, asking
questions that are really announcements. That belief is why CONDUCT.md
is a shipped artifact rather than advice, and why the pack declines the
common pattern of gating all work behind a mandatory design dialogue:
overriding the mode the user chose is the same disrespect in the other
direction.

## Generic core, local context

No client, company, or collaborator names in pack content, enforced by a
guard whose list lives outside the tracked tree. Project-specific context
belongs in `.claude/acstack.md`.

**Why:** the pack is meant to be readable by strangers and shareable
without an audit. (The guard itself once hardcoded the roster it was
meant to protect, and excluded its own directory from the sweep — which
is exactly why the list moved out and the sweep grew to cover `scripts/`.)

## Zero required dependencies

Git and bash 3.2+. Everything beyond that — `gh`, `curl`, `pg_dump`, a
model API — is optional, per-capability, and degrades honestly.

**Why:** a pack that needs a runtime is a pack that breaks on someone
else's machine, and an install promise you cannot keep is a trust
problem before it is a technical one.

---

**Reading order:** `CONDUCT.md` for how the agent behaves with you,
`docs/ARCHITECTURE.md` for how the pieces fit, `CONTRIBUTING.md` if you
are adding to it.
