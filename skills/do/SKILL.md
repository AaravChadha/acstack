---
name: do
description: Complete one numbered subtask from PLAN.md end-to-end - execute exactly the named subtask, run its acceptance check, tick the exact box, commit with the task reference locally (never pushes - that is /ship's job), report what was edited, and propose subtasks that group naturally with it. Use when the user asks to do or complete a specific numbered task like 3.2.1.
argument-hint: "<subtask-id> [notes]"
---

# /do — complete one subtask from the plan

You are completing exactly one unit of work from the living plan, leaving the
plan, the commit history, and the user's understanding all in sync. Nothing
more.

`Adjacent skills:` /ticket (captures work; /do performs it) · /ship
(releases a whole branch; /do completes one subtask) · /investigate (when
the subtask turns out to be a bug hunt).

<!-- acstack:runtime -->
Run before the skill's steps — per invocation, not per session (4.36); failures degrade to markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; silent ONLY if already checked today
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

## Before starting

1. Read the config (per the principles block). If `tracking: tickets` is
   set, follow `## Tickets mode` below instead of the document-mode
   sequence.
2. Locate the subtask named in the arguments (e.g. `3.2.1`) in PLAN.md. Read
   its full text, its parent task, and the parent's `**Acceptance:**` line.
3. If the subtask is ambiguous, conflicts with its acceptance criteria, or
   looks already done, push back in writing before touching code. Do not
   start work you'd have to defend later.

**When a precondition fails, stop and say which** — never guess a target:

- **No PLAN.md** (and no legacy `PLANNING.md`) → say so, point at
  `/plan build`, stop.
- **The named ID is not in PLAN.md** → say the ID was not found, list the
  closest open subtask IDs, and ask. Never silently pick a neighbour.
- **Bare `/do` with no argument** → propose the top unblocked subtask
  (every prerequisite box checked, in plan order) and confirm before
  starting — matching tickets mode's behavior rather than guessing.
- **The box is already `[x]`** → re-run its acceptance. Passing → say it
  is already done and stop. Failing → report the regression and offer
  `/triage`'s re-open verdict; do not silently redo the work.

## The sequence

1. **Execute.** Complete the named subtask — strictly scoped to it. Adjacent
   improvements are proposed in step 6, not smuggled in.

   **Climb the simplicity ladder BEFORE writing.** Stop at the first rung
   that holds; most work stops early:
   1. Does this need to exist at all? (If the subtask is satisfied without
      it, say so and build nothing.)
   2. Does the codebase already do it? → reuse.
   3. Does the standard library? → use it.
   4. Does the platform/framework already in use? → use it.
   5. Does an already-installed dependency? → use it. (A NEW dependency is
      a decision to surface, not a rung to climb past quietly.)
   6. Is it one line? → write the one line.
   7. Only then: the minimal thing that satisfies the acceptance.

   This runs *before* code, which is the point — a cleanup pass afterwards
   cannot recover the "didn't need to exist" rung. **Be lazy about the
   solution, NEVER about validation, error handling, security, or
   accessibility** — those are not padding to trim, and the ladder is not a
   licence to skip them. Reading is never the thing you skimp on either:
   climb only after you understand the problem.
2. **Verify.** Run the relevant `**Acceptance:**` command (or the phase
   `**Exit criterion:**` if this was the last open subtask) before declaring
   anything done. If it fails, say so with the output — do not check the box.
   **The task has no `**Acceptance:**` line at all** → do not tick it on
   the strength of "it looks done". State that the task carries no
   acceptance, say what you did and what you observed, and either propose
   an acceptance line for the user to approve or leave the box open with
   that reason. Declaring done-unverified is precisely the rot /triage and
   /plan-review exist to flag, and it costs nothing to name instead.
3. **Check off.** Tick exactly the completed box in PLAN.md. Parent boxes
   only when every child is checked. The phase heading `## [ ]` flips when
   its `**Exit criterion:**` passes — or, if the phase declares none, when
   every child is checked (a phase with no gate is done once its subtasks
   are; without this rule an exit-criterion-less phase could never flip,
   and /audit docs would forever flag it as drift).
4. **Commit.** Subject from `subtask-commit-format` (default
   `task <number>: <description>`), plus a brief what-and-why
   body per CONDUCT rule 10. Include the PLAN.md checkbox change in the same
   commit so plan and code move together.
5. **Stop at the commit — /do never pushes.** The commit is local and
   reversible; a push is outward-facing and is not. `/do` is
   model-invocable, so an agent can reach it without the user typing
   anything, and an unattended push is the one step of this sequence that
   cannot be undone quietly. Report the commit and let the user push.

   Say so explicitly in the report: `committed locally — not pushed`, plus
   the exact command they would run (`git push`, or
   `git push -u origin <branch>` on a new branch). Publishing a subtask is
   `/ship`'s job, and it runs five gates first.
6. **Report and propose.** Tell the user exactly what was edited — files,
   functions, literals — then name any subtasks that group naturally with
   this one (same file, same layer, unblocked by it) and ask whether to
   proceed. Do not start them on your own.

## Tickets mode (`tracking: tickets`)

Preconditions first: `gh` present and authenticated, GitHub remote exists.
Any failure → name the exact missing precondition, offer document mode.

1. **Pick up.** `/do 42` (or `#42`) takes that issue. Bare `/do` proposes
   the top unblocked open issue in the current milestone (no `blocked`
   label) and confirms before starting — it never just begins.
2. **Branch.** `<branch-prefix><n>-<slug>` (e.g. `feature/42-fix-parser`)
   — issue work is branch work. Created locally; not pushed.
3. **Work and commit.** Subjects use the tickets shape per CONDUCT rule 10:
   `#42: <subject>`. Issue-body checklist items are ticked via
   `gh issue edit` as they complete — the issue tracks progress the way
   PLAN.md checkboxes do in document mode.
4. **Verify.** Run the issue's `## Acceptance criteria` before anything
   closes. A failing acceptance becomes an issue comment with the exact
   output — the issue stays open, the failure is not papered over.
5. **Close via merge.** Work that completes the issue carries `Fixes #42`
   in the final commit body; partial work references `#42` without `Fixes`.
   The branch stays local until the user pushes it or runs `/ship` — the
   issue closes when the branch merges, which is a human act either way.
6. **Report and propose** as in document mode; "groupable next" =
   unblocked issues in the same milestone touching the same files.

## Hard rules

- One subtask per invocation unless the user grouped them explicitly.
- A failing acceptance check is reported, never papered over.
- Never uncheck a box silently; a regression is recorded in PLAN.md as
  `~~[x]~~ → **Verdict (date):** re-opened — reason`.
