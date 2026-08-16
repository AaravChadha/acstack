---
name: contract-check
description: "Breaking-change pre-flight for the surface callers depend on - function signatures, API response shapes, public exports, config keys. Classifies every change in a diff additive vs destructive, names the add-new-then-deprecate alternative for each destructive one, and opens with a written GO or NO-GO verdict. Never fixes anything - it blocks and explains. Use before merging or releasing a change that touches a public interface, or when the user asks to check for breaking changes."
argument-hint: "[<git-ref> | <diff-range>]"
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git ls-files:*), Bash(ls:*), Bash(cat:*), Bash(gh pr diff:*)
---

# /contract-check — the gate before the callers find out

A rename ships, the tests are green, and something downstream breaks that
nobody in this repo owns. This skill exists to catch that before the merge.
It is structurally read-only: no Edit, no Write, no command that mutates
anything. It blocks and explains; it never fixes. (One residual: `git log`
and `git diff` accept `--output=FILE`, which a prefix grant cannot exclude;
the skill never uses it — see check.sh §13.)

`Adjacent skills:` /migrate-check (the same gate applied to schema changes;
this one covers the code surface) · /ship (runs before release; this gate
answers one of its questions in depth).

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

**The report anatomy is not restated here.** It is
`../migrate-check/references/gate-shape.md` — verdict first, classify every
change including the safe ones, a safe alternative per destructive row,
never fix, and state what the verdict does not cover. Read it before
reporting.

## The surface

Four things callers depend on and cannot see you change:

| Surface | Where to look |
|---|---|
| Public exports | index/barrel files, `__all__`, `export` statements, package entry points |
| Function signatures | exported/public functions only — an internal helper is not a contract |
| API response shapes | serializers, response models, schema files, fixtures that encode a response |
| Config keys | template/example config, documented keys, environment variable reads |

**Scope is the diff, not the repo.** Everything classified must appear in the
range under review. A finding about code the diff never touched belongs in
`/audit code`, not here.

## Classification

Decidable rules, not judgment. Each row of the table below is a class, and
the third column is what goes in the safe-alternative column.

| Change | Class | Safe alternative |
|---|---|---|
| Public export renamed | **destructive** | add the new name, re-export the old, deprecate, remove next major |
| Public export removed | **destructive** | deprecate first, remove next major |
| Field dropped from a response shape | **destructive** | add the replacement, mark the old optional, drop next major |
| Field's type narrowed or nullable → required | **destructive** | accept both, warn on the old form |
| Required parameter added to a public signature | **destructive** | give it a default, or add an overload |
| Parameter type tightened | **destructive** | accept the union, warn on the narrow case |
| Config key renamed or removed | **destructive** | read both keys, warn on the old |
| Anything added and optional by default | **additive** | — |
| Internal-only change, no exported surface touched | **additive** | — |

**A rename is never additive.** It looks like one in a diff — a line
removed, a line added, the same body — and reporting it as additive is the
single failure this skill exists to prevent. When a removed name and an
added name share a body, that is a rename until proven otherwise, and the
burden is on the evidence that some compatibility shim keeps the old name
reachable.

## Procedure

1. **Resolve the range.** An argument is a ref or a range; with none, use
   the working diff against the default branch. State which you used — a
   verdict against the wrong range is worse than no verdict.
2. **Extract the surface.** For each of the four surfaces, list what the
   diff adds, removes and changes. Nothing inferred: cite `file:line`.
3. **Classify every item**, additive or destructive, per the table above.
4. **Pair each destructive item with its alternative.** No blank cells; if
   none exists, say so in the cell.
5. **Verdict.** `NO-GO` if any destructive change lacks an accepted
   migration path in the diff itself; otherwise `GO`.
6. **Name the blind spots.** Callers outside this repo, runtime consumers no
   static read reaches, and any surface the range does not include.

## Hard rules

- One verdict per invocation, and it is the report's literal first line — no
  preamble before it (see `gate-shape.md` §1).
- Every classified item cites `file:line` from the diff under review.
- A rename reported as additive is a defect in this skill, not a judgment
  call.
- Never edits the diff, the code, or the config it is reviewing.
- `GO` means "no destructive change without a migration path in this range",
  never "this change is safe" — say so when the distinction could mislead.
