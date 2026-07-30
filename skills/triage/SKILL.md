---
name: triage
description: Backlog hygiene sweep - stale items, duplicate pairs, missing acceptance criteria, unblocked-but-unassigned work, and milestone burn, delivered as a report first with only user-approved actions applied. Works on GitHub Issues in tickets mode and on PLAN.md checkboxes in document mode. Use when the user asks to triage, groom, or clean up the backlog or the plan's open tasks.
argument-hint: "[notes]"
---

# /triage — keep the backlog honest

A backlog rots in specific, findable ways. This skill finds them, reports
them with evidence, and applies exactly the actions the user approves —
nothing more, and nothing silently.

`Adjacent skills:` /audit docs (read-only drift report; /triage proposes
and applies tracker/plan actions) · /ticket (files one new item; /triage
grooms the many existing ones).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
pack="$(dirname "$(dirname "$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)")")"
if [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
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

## Stance: report, then apply

The report opens with a one-line verdict — `backlog healthy` or
`<N> findings across <M> categories` — before any finding. Then the
numbered findings, each with its evidence and its proposed action.
Then the user picks; only approved actions are executed, and the
report closes with the applied-actions list — each action confirmed
by name.
Nothing is ever silently deleted or closed: every close carries a written
reason. Supersede-don't-delete applies to backlogs exactly as it applies
to decisions.

Config: `stale-days` from a `## triage` section in `.claude/acstack.md`
(default 30).

## Tickets mode (`tracking: tickets`)

Preconditions — `gh` installed, `gh auth status` succeeding, and a
GitHub remote present. Any failure names WHICH one failed and offers
document mode; never guess. The sweep:

1. **Stale.** Open issues with no activity in `stale-days` days → propose
   close-with-reason (`superseded by #M` / `no longer planned — <reason>`)
   or re-prioritize into a milestone. Staleness is evidence of drift, not
   a death sentence — the proposal says which, per issue.
2. **Duplicates.** Candidate pairs with the overlapping text QUOTED as
   evidence. The newer closes as `duplicate of #N` — only after the user
   confirms the pair is real.
3. **Missing acceptance.** Issues without an `## Acceptance criteria`
   section → listed, labeled `needs-acceptance`; the report proposes
   acceptance lines where the issue body implies them.
4. **Unblocked-but-unassigned.** In the current milestone, no `blocked`
   label, no assignee → surfaced as ready work, ordered by milestone
   position.
5. **Milestone burn.** Per milestone: open/closed counts, the exit
   criterion restated from its description, and an honest verdict on
   whether what remains can meet it — "12 open, 3 weeks of history says
   2/week" is a verdict; "tight but doable" is not.

## Document mode

The same rot, PLAN.md-shaped:

1. **Checked but failing.** `[x]` whose `**Acceptance:**` command fails
   now → propose re-open: `~~[x]~~ → **Verdict (date):** re-opened —
   <what broke>`. Run cheap acceptance commands; name the expensive ones
   skipped.
2. **Done but unchecked.** `[ ]` whose artifact plainly exists → VERIFY
   the acceptance actually passes before proposing the tick; existence is
   not acceptance.
3. **No acceptance line.** Task groups without `**Acceptance:**` → listed
   with proposed runnable lines.
4. **Stale open items.** `## Open items` entries dated older than
   `stale-days` → propose: decide now, re-date with a reason, or record
   as deliberately deferred.
5. **Phase-state drift.** Phase headings whose `[ ]`/`[x]` disagrees with
   their children's state or their exit criterion's reality.

## Hard rules

- Findings without evidence (the quoted text, the failing command, the
  date arithmetic) don't make the report.
- The report states what was NOT swept (e.g. acceptance commands too
  expensive to run) — a sweep that implies totality it didn't do is
  drift about drift.
- Applied actions are listed at the end exactly as executed — issue
  numbers, label names, PLAN.md lines — so the JOURNAL entry can cite
  them.
