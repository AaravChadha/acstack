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

**No PLAN.md → stop and say so.** There is no backlog to groom, and
inventing one would be fiction. Name `/plan seed` and stop.

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

## Root-cause clustering (both modes)

Every sweep above is a **local** comparison — this item against that item,
this box against its acceptance. Clustering is the **global** one: twelve
items that are all one cause is a finding no pairwise duplicate check can
see, because no two of them are duplicates.

Run it last, over the whole backlog at once, after the local sweeps have
already removed the noise.

**A cluster needs a stated cause, not a shared topic.** "These five all
mention the parser" is a tag. "These five all fail because the tokenizer
drops the final field when the input has no trailing newline" is a cause.
The test is one sentence: **would fixing the named cause close every item
in the cluster?** If some would survive it, the cluster is wrong — split it
or drop it.

The bar, all three required:

- **Three or more items to propose a PARENT.** A parent over two items is
  more structure than it earns.
  **But a same-cause pair is still named, never dropped.** Two items sharing
  a cause are not a duplicate pair — the duplicate sweep keys on overlapping
  text and will not see them, so a pair that falls below this bar would
  otherwise vanish between the two sweeps. Report it under
  `Related pairs`: the cause, both items, and the evidence, with no parent
  proposed. Found by shakedown 7, where two items sharing a UTC-boundary
  cause were invisible to both passes.
- **A cause written as a sentence**, naming the mechanism — not a
  component, a label, or a theme.
- **Evidence per member**: the quoted line, error, or acceptance that ties
  that specific item to that cause. An item nobody can tie to the cause is
  not in the cluster.

**Propose nothing when the backlog is genuinely independent.** This is the
half that keeps the pass honest: a backlog of unrelated work is the normal,
healthy state, and a clustering step that always finds clusters is
astrology. Say plainly that no root-cause groups were found and move on —
that is a real result, not a failed sweep. Never widen a cause until items
fit it; a cause broad enough to cover everything explains nothing.

What the report proposes, per cluster:

- **A parent** — in tickets mode a new issue titled by the CAUSE; in
  document mode a parent task in PLAN.md with the children as its subtasks.
  Never a parent that merely renames the group.
- **The children redirected**, each with the same standardized line so the
  tree stays navigable: `rolled up into <parent> — same cause: <cause>`.
- **What stays independent**, listed. An item that resisted clustering is
  information, not a leftover.

Approval-gated exactly like the rest of this skill: the clusters are
proposed with their evidence, and nothing is filed, edited, or closed until
the user says so. Getting a cluster wrong reshapes someone's whole backlog,
so this is the sweep where a wrong proposal costs the most.

## Hard rules

- Findings without evidence (the quoted text, the failing command, the
  date arithmetic) don't make the report.
- The report states what was NOT swept (e.g. acceptance commands too
  expensive to run) — a sweep that implies totality it didn't do is
  drift about drift.
- Applied actions are listed at the end exactly as executed — issue
  numbers, label names, PLAN.md lines — so the JOURNAL entry can cite
  them.
