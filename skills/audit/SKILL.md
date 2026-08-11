---
name: audit
description: Audit one of five targets. code - defect hunt producing a report with safety checks and adversarial verification evidence; docs - drift check of README/PLAN/JOURNAL against the actual tree, counts, and checkbox reality; eval - failure classification with the never-inflate rule; tests - finds tests that pass without catching, including a mutation spot-check; skills - SKILL.md hygiene. Use when the user asks to audit or review code, a PR, project docs, an eval report, a test suite, or a skill.
argument-hint: "code|docs|eval|tests|skills [path | PR# | diff range]"
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git diff:*), Bash(git check-ignore:*), Bash(ls:*), Bash(grep:*), Bash(wc:*), Bash(gh pr view:*), Bash(gh pr diff:*)
---

# /audit — find what's wrong and report it honestly

Five targets, one stance: verdicts backed by evidence, misses logged rather
than massaged, and scope stated so the reader knows what was NOT checked.

`Adjacent skills:` /secure (security-only findings with exploit scenarios) ·
/qa (probes the running system; /audit reads code and docs) · /investigate
(root-causes one failure; /audit sweeps for many).

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

**Every line number is pasted, never counted — all five targets.** A
`file:line` in any report comes from line-numbered tool output
(`grep -n`), not from counting or recall: a wrong line number turns a
real finding into one the author can dismiss.

## Before any target — does this need the pass at all?

**First: does this target need the pass at all?** A diff that only moves
files, bumps a version, or changes generated output has nothing to audit —
say so in one line and stop. A review that manufactures findings because it
was invoked is worse than no review: it spends the reader's attention on
noise and trains them to skim the next one.

That gate is not code-specific; it was written "this target" and merely sat
under `code` until 4.61 moved it here. Each target's reference adds its own
stop condition (no results file, no test suite) on top of it.

## Target: code

Full procedure: `references/target-code.md` — read it when the
invocation names `code`, and not otherwise. It carries the known-bug-class
sweep, the report shape, and the reports-never-fixes rule. (The
does-this-need-auditing gate moved OUT of it in 4.61 and is above.)

## Target: docs

Full procedure: `references/target-docs.md` — read it when the
invocation names `docs`, and not otherwise. It carries the drift classes,
the owed-work rule, and the doc-says/reality-is output shape.

## Target: eval

Full procedure: `references/target-eval.md` — read it when the
invocation names `eval`, and not otherwise. It carries the no-results-file
stop, the failure buckets, and the never-inflate rule.

## Target: tests

Full procedure: `references/target-tests.md` — read it when the
invocation names `tests`, and not otherwise. It carries the five
no-teeth classes, the mutation spot-check, and the revert discipline.

## Target: skills

Full procedure: `references/target-skills.md` — read it when the
invocation names `skills`, and not otherwise. It carries the seven
classes: YAML-truncating frontmatter, name/dir match, description
trigger surface, body budget, citation resolution, allowed-tools
honesty, and conditional-branch waste.
