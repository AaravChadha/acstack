---
name: why
description: "Decision archaeology - answers why the code, config, or plan is the way it is by searching the record in a fixed order: BRIEF constraints, dated PLAN decisions, JOURNAL entries, then git history. Stops at the first real answer, cites it with a date, and says no recorded rationale rather than inventing one. Use when someone asks why something is this way, why a choice was made, or where a decision is written down."
argument-hint: "[question | file:line | symbol]"
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git status:*), Bash(grep:*), Bash(ls:*), Bash(wc:*)
---

# /why — decision archaeology

"Why is this like this?" is the question that stops a newcomer cold on an
agent-built codebase, and the one the pack's three documents are already
positioned to answer. This skill reads the record instead of guessing at
intent: it finds where a decision was written down, quotes it with its
date, and — when nothing was written — says exactly that.

The failure mode it exists to prevent is a plausible reconstruction. Code
shows WHAT was done; only the record shows WHY. Inferring a rationale from
the implementation and presenting it as history is the archaeology version
of inflating an eval score.

`Adjacent skills:` /investigate (why is it BROKEN — hypotheses and a root
cause; /why is why it is SHAPED this way) · /resume (where the work is
now) · /learn (writes the lesson /why will later find).

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

## The search order

Search in this order and **stop at the first real answer**. The order runs
from most deliberate to most incidental — a written verdict outranks a
commit message, which outranks a diff.

1. **BRIEF constraints.** The frozen seed. A constraint here explains
   whole classes of decision ("free tier only", "no build step") and is
   the answer whenever the question is "why is this so limited".
2. **Dated PLAN decision blocks.** The richest source: `**Verdict
   (YYYY-MM-DD):**` lines, superseded `~~strikethrough~~` entries, and the
   why-X-not-Y prose attached to tasks. A superseded decision is evidence,
   not noise — it records what was believed before.
3. **JOURNAL entries.** Dated work-log entries carry the reasoning that
   never made it into a task: what broke, what was tried, what the numbers
   said.
4. **Git history, last.** `git log -S'<exact text>'` finds the commit that
   introduced a line; `git log --oneline -- <path>` scopes to a file. Read
   the commit BODY, not just the subject — the pack's own commit rule puts
   the what-and-why there. History answers "when and by which change";
   it rarely answers "why" on its own.

Searching a later source before an earlier one is how a commit message
gets quoted as a rationale when a written verdict existed two files away.

## What counts as a real answer

A source is a real answer only when it states a **reason** — a constraint,
a tradeoff, a rejected alternative, a defect that forced the change. A
source that states only WHAT changed is a lead, not an answer: keep
searching, and cite it as supporting evidence if nothing better appears.

Partial answers are reported as partial. "The decision is recorded but its
reason is not" is a true and useful finding; dressing it up is not.

## Report shape

The **verdict is the first line**: the answer in one sentence, or
`no recorded rationale`. Then:

- **Answer** — the reason, in the record's own words where possible.
- **Source** — `file:line` plus the date, and the decision's status
  (current, or superseded by a later one — say which and quote it).
- **Chain** — which sources were searched, in order, and what each
  returned. This is what makes a `no recorded rationale` verdict
  trustworthy rather than a shrug.
- **Scope** — what was NOT searched (an unread archive, history before a
  rewrite, a document set that does not exist here), so the reader knows
  the boundary of the claim.

## Hard rules

- **Never invent a rationale.** If the record does not say why, the answer
  is `no recorded rationale` plus where someone would write it down
  (`/learn` for a lesson, a dated PLAN verdict for a decision). An
  unrecorded reason is a gap in the record, and naming it is the service.
- **Never infer intent from the implementation.** "The code does X, so
  they must have wanted Y" is reconstruction, not archaeology. Reading the
  code to understand WHAT is fine; presenting the result as WHY is not.
- **Quote, with the date.** A paraphrase drops the hedge that made the
  original honest. Dates matter because decisions supersede each other.
- **A superseded decision is still an answer** — report the current one
  and note what it replaced, per the pack's never-delete-a-decision rule.
- **Stop at the first real answer.** Continuing past it produces a wall of
  weakly-related citations that buries the one that mattered.
- Read-only: this skill reports and never edits the record it reads. That
  includes not "fixing" a document whose rationale is missing — the fix is
  the user's call, and the gap is the finding.
