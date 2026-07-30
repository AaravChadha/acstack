---
name: journal
description: Update JOURNAL.md, the rolling project journal, after a work session. Writes a dated work-log entry with exact names and before/after numbers, classifies eval failures, syncs PLAN.md checkboxes to reality, and commits. Use at the end of a work session or when the user asks to journal, log, or write up what happened.
argument-hint: "[notes about the session]"
---

# /journal — record what actually happened

The journal is the anti-relearning device: a fresh collaborator (or
future-you) opens the repo and resumes in five minutes without re-deriving a
single decision. It records reality, not intentions — the plan says what
should happen; the journal says what did.

`Adjacent skills:` /retro (trends across many sessions; /journal records
one) · /learn (one durable lesson; /journal the whole session) · /resume
(reads what /journal wrote).

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

## Procedure

1. **Gather.** Read the config, JOURNAL.md (create from
   `references/journal-template.md` if missing), PLAN.md, and
   `git log` since the last journal commit. Get current test counts — run
   the suite if it's cheap; otherwise use the last recorded counts and say
   you did.
2. **Write the entry** under `## Key decisions and journey`, newest first,
   heading `### <what changed> (YYYY-MM-DD[ morning/evening])`. Follow
   `references/worklog-rules.md` for granularity — exact bugs, exact
   numbers, why-X-not-Y, what did NOT change, validation close.
3. **Classify any eval results.** Every failure gets a bucket from the
   canonical table in `../audit/references/eval-review-rules.md`: prompt
   issue / grader brittleness / provider flake / data issue / parser
   issue / genuinely ambiguous. Genuinely-ambiguous survives only as
   `acceptable_failure: <written reason>`. Use `FAIL → fixed` notation for
   resolved ones, and add a "Read" column giving the interpretation, not
   just the verdict. Never adjust a case to raise the number.
4. **Update the skeleton sections**: the top blockquote (`**Last update**:`
   date + 2-3 sentence delta), TL;DR, the what's-built table, pending-from-
   you table, deferred list. Keep "how to run" honest — rerun it if it may
   have drifted.
5. **Sync PLAN.md.** Check off boxes whose Acceptance actually passes now
   (verify — don't assume). A regression is recorded as
   `~~[x]~~ → **Verdict (date):** re-opened — reason`, never a silent
   uncheck.
6. **Commit** with subject from `journal-commit-format` (default
   `Journal YYYY-MM-DD: <summary>`) plus a brief body, per CONDUCT rule 10.
   Include the PLAN.md sync in the same commit.

## Hard rules

- Numbers over adjectives: `60/90 → 8/123 flagged`, `94.2s → 71.2s (~25%)`,
  `88 passed, 40 skipped (was 79/40)`. If a claim has no number, ask
  whether it deserves to be in the journal.
- Log incidental discoveries, including self-indicting ones ("the test was
  already stale before this change").
- Deferrals get a reason and a sequence ("after X, so Y is measured against
  real data"), never a bare "later".
