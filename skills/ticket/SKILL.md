---
name: ticket
description: Capture a brain-dump as a well-formed work item - verb-first title, acceptance criteria, file paths when known, an out-of-scope line. Files a GitHub issue in tickets mode or appends a numbered PLAN.md task in document mode; unknowns are marked TBD, never invented. Use when the user brain-dumps an idea, bug, or task to capture for later, or asks to ticket, file, or note something as work.
argument-hint: "<brain-dump>"
---

# /ticket — capture without friction, file without slop

The frictionless entry point that keeps ideas from routing around the
system. A thought arrives half-formed; it leaves as a work item the
next session can pick up cold — or it honestly wears a TBD.

`Adjacent skills:` /do (does the work; /ticket only captures it) ·
/triage (grooms the many existing items; /ticket files one new one).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + bug-class names, capped 3KB
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

## The bar

Every filed item has:

- **Verb-first title** — `fix scheme-name matching for hyphenated funds`,
  not `scheme names`.
- **Acceptance criteria** — runnable where possible; observable always.
- **File paths** — when known or cheaply inferable from the dump.
- **Out-of-scope line** — the adjacent thing this item deliberately does
  NOT cover; the line that prevents scope osmosis later.

What the dump doesn't say and the repo can't cheaply tell you is marked
explicitly — `Acceptance: TBD — needs <what>` — never invented. A wrong
guessed acceptance is worse than an honest TBD: it fails silently at /do
time.

At most ONE round of clarifying questions, and only when the item would
otherwise be unfileable (no discernible action at all). Friction is the
enemy here: a captured-but-imperfect item beats a perfect item the user
gave up on filing.

## Tickets mode (`tracking: tickets`)

Preconditions — `gh` installed, `gh auth status` succeeding, and a
GitHub remote present. Any failure names WHICH one failed and offers
document mode; never guess. Then `gh issue create`:

- Body follows `.github/ISSUE_TEMPLATE/task.md` (acceptance / files /
  out-of-scope sections).
- Best-fit label from the standard set (`bug` / `feature` / `chore`);
  items with TBD acceptance also get `needs-acceptance`.
- Milestone: the current one, unless the dump clearly targets another —
  ask only when genuinely ambiguous, and never more than once.

## Document mode

Append a numbered task to PLAN.md:

- Under the current open phase, taking the next free task number — existing
  tasks are NEVER renumbered.
- With its acceptance line (or the explicit TBD).
- No obvious phase → a dated checkbox under `## Open items` instead;
  /triage or the next `/plan replan` finds it a home.

## Report and stop

Report what was filed — the issue URL or the exact PLAN.md line — and
stop. Capture never starts the work (CONDUCT rule 5): /ticket writing
code because the fix "looked quick" is exactly the failure mode this
skill exists to prevent.
