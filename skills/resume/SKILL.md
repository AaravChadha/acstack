---
name: resume
description: Resume a project in five minutes - read BRIEF/PLAN/JOURNAL plus git state, deliver a short where-we-are brief, divergence flags (uncommitted work, unjournaled commits, acceptance drift), and the next three unblocked tasks. Use at session start or when the user asks where were we, what's next, or to catch up on a project.
argument-hint: "[notes]"
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git status:*), Bash(git rev-parse:*), Bash(ls:*), Bash(grep:*), Bash(wc:*), Bash(gh issue list:*)
---

# /resume — resume in five minutes

You are rebuilding context, not doing work. Read the three documents and the
git state, say where the project actually is, and stop.

`Adjacent skills:` /journal (writes the session record at session end;
/resume reads it at session start) · /do (starts a task; /resume only names
the candidates) · /triage (full plan/backlog hygiene sweep; /resume flags
only what it trips over while reading).

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

## What to read

1. Config (per the principles block) — note `tracking` and
   `journal-commit-format`.
2. BRIEF.md, PLAN.md, JOURNAL.md (legacy names per the principles block).
   A missing document is reported as a fact and pointed at `/plan` — /resume
   never creates or scaffolds anything.
3. `git status`, and `git log` since the most recent commit whose subject
   matches the journal commit format (default `Journal <date>: <summary>`).
   No journal commit in history → say so and treat the log since the last
   dated JOURNAL.md entry (or, failing that, the whole log) as unjournaled.

## The brief — 10 lines or fewer

- What this project is: one line, from the BRIEF.
- Current phase, its `**Exit criterion:**`, and its checkbox state.
- What the last session actually did — from the newest JOURNAL entry, with
  its numbers (`88 passed, 40 skipped`), not a paraphrase.
- The state of the tree: clean or not, current branch, ahead/behind remote.

## Divergence flags

Report only what the reads above surface — this is a spot check, not an
audit (a full sweep is /triage's job):

- Uncommitted changes, by file.
- Commits made since the last journal entry — named as candidates for
  `/journal`, not journaled on the spot.
- Any checked box whose `**Acceptance:**` command is cheap to run and
  visibly fails now. Run only cheap checks (a grep, an `ls`, a file-exists
  test — not test suites); say which acceptance commands were NOT run.

## Next 3 unblocked subtasks

From PLAN.md in plan order: ID, task text, and its acceptance line.
Unblocked = every prerequisite box checked and not blocked by an open
decision in `## Open items`. Fewer than three exist → list what's there and
say why the rest are blocked.

## Tickets mode (`tracking: tickets`)

Preconditions first (gh present, authenticated, GitHub remote); a failure is
named exactly and the document-side reads above still happen. Then the
checkbox scan becomes a tracker query:

- `gh issue list` open issues in the current milestone; milestone burn
  stated as open/closed counts against its exit criterion.
- Next 3 = top unblocked open issues (no `blocked` label) in the current
  milestone, each with its acceptance section's first line.
- Read-only here too: no issue edits, no labels, no comments.

## Hard rules

- /resume writes no files and changes no state — in either mode.
- End with a status statement. Naming the next tasks is information, not an
  offer accepted: work starts only when the user picks something (CONDUCT
  rules 2 and 9).
- What was not checked is stated plainly — a five-minute brief that implies
  it verified everything is lying about its own depth.
