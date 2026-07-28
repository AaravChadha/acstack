---
name: do
description: Complete one numbered subtask from PLAN.md end-to-end - execute exactly the named subtask, run its acceptance check, tick the exact box, commit with the task reference, push or open a PR per project config, report what was edited, and propose subtasks that group naturally with it. Use when the user asks to do or complete a specific numbered task like 3.2.1.
argument-hint: "<subtask-id> [notes]"
---

# /do — complete one subtask from the plan

You are completing exactly one unit of work from the living plan, leaving the
plan, the commit history, and the user's understanding all in sync. Nothing
more.

`Adjacent skills:` /ticket (captures work; /do performs it) · /ship
(releases a whole branch; /do completes one subtask) · /investigate (when
the subtask turns out to be a bug hunt).

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

## Before starting

1. Read the config (per the principles block). If `tracking: tickets` is
   set, follow `## Tickets mode` below instead of the document-mode
   sequence.
2. Locate the subtask named in the arguments (e.g. `3.2.1`) in PLAN.md. Read
   its full text, its parent task, and the parent's `**Acceptance:**` line.
3. If the subtask is ambiguous, conflicts with its acceptance criteria, or
   looks already done, push back in writing before touching code. Do not
   start work you'd have to defend later.

## The sequence

1. **Execute.** Complete the named subtask — strictly scoped to it. Adjacent
   improvements are proposed in step 6, not smuggled in.
2. **Verify.** Run the relevant `**Acceptance:**` command (or the phase
   `**Exit criterion:**` if this was the last open subtask) before declaring
   anything done. If it fails, say so with the output — do not check the box.
3. **Check off.** Tick exactly the completed box in PLAN.md. Parent boxes
   only when every child is checked. The phase heading `## [ ]` flips only
   when the phase's exit criterion actually passes.
4. **Commit.** Subject from `subtask-commit-format` (default
   `completed task <number> (<description>)`), plus a brief what-and-why
   body per CONDUCT rule 10. Include the PLAN.md checkbox change in the same
   commit so plan and code move together.
5. **Push.**
   - `push: direct` (default): `git push`.
   - `push: branch-pr`: create `<branch-prefix><short-topic>`, push, open a
     PR with `gh pr create`. The PR body follows the report shape: what
     changed, why, how it was verified. Attribution per config.
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
2. **Branch.** `<branch-prefix><n>-<slug>` (e.g. `feature/42-fix-parser`),
   regardless of the `push` setting — issue work is branch work.
3. **Work and commit.** Subjects use the tickets shape per CONDUCT rule 10:
   `#42: <subject>`. Issue-body checklist items are ticked via
   `gh issue edit` as they complete — the issue tracks progress the way
   PLAN.md checkboxes do in document mode.
4. **Verify.** Run the issue's `## Acceptance criteria` before anything
   closes. A failing acceptance becomes an issue comment with the exact
   output — the issue stays open, the failure is not papered over.
5. **Close via merge.** Work that completes the issue carries `Fixes #42` —
   in the PR body (`push: branch-pr`) or the final commit body
   (`push: direct`). Partial work references `#42` without `Fixes`.
6. **Report and propose** as in document mode; "groupable next" =
   unblocked issues in the same milestone touching the same files.

## Hard rules

- One subtask per invocation unless the user grouped them explicitly.
- A failing acceptance check is reported, never papered over.
- Never uncheck a box silently; a regression is recorded in PLAN.md as
  `~~[x]~~ → **Verdict (date):** re-opened — reason`.
