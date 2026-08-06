---
name: plan
description: Create or evolve project planning docs. Modes - seed (write BRIEF.md, the frozen problem statement, and gate on written architecture pushback), build (write PLAN.md, the living phase plan with runnable exit criteria), replan (supersede decisions with dated verdicts, insert decimal phases). Hackathon shape via config or the hackathon argument.
argument-hint: "[seed|build|replan] [hackathon] [notes]"
disable-model-invocation: true
---

# /plan — the seed, the gate, and the living plan

Planning docs are deliberate artifacts. This skill is user-invoked only and
never regenerates a plan spontaneously.

`Adjacent skills:` /challenge (interrogates the BRIEF this creates) ·
/plan-review (locks the PLAN this creates before code) · /eval-spec (sets
the score targets a phase exit criterion cites) · /do (executes the tasks).

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

## Mode dispatch

Parse the arguments. No mode given: if no BRIEF.md exists → `seed`; if
BRIEF.md exists but no PLAN.md → `build`; otherwise ask which mode is wanted.
**`seed` when BRIEF.md already exists → STOP.** The BRIEF is the frozen
record of what was believed at the start; regenerating it destroys the
only artifact that can later be compared against what was learned. Say it
exists, name its path, and offer the two honest routes: `build` if the
plan is what's missing, or `replan` to supersede a decision with a dated
verdict. Editing the BRIEF is the user's own call, never this skill's side
effect.
`hackathon` as an argument (or `mode: hackathon` in config) switches the
templates to the hackathon shape.

## Mode: seed — write the frozen BRIEF

Full procedure: `references/mode-seed.md` — read it when the dispatch
selects `seed`, and not otherwise. It carries the BRIEF's sections, the
interview discipline, and the never-regenerate rule.

## The gate — before build

`build` runs only after the gate: deliver written architecture pushback on
the BRIEF — what won't work, where the user is being naive, risks, the
rejected alternatives reconsidered — and get the user's explicit
acknowledgment. Record the verdict in a short **Gate verdict** block at the
top of PLAN.md (date, what was challenged, what changed, what was accepted
as-is). No pushback delivered → no plan, no code.

## Mode: build — write the living PLAN

Generate `PLAN.md` following `references/plan-template.md`. The grammar:

- Top: purpose blockquote (what this doc is, pointer to BRIEF.md) +
  cross-cutting constraints blockquote + the Gate verdict block.
- `## Index of phases` — table: Phase | Goal | Exit criterion (add Days when
  timeboxed).
- Phase headings carry state: `## [ ] Phase N — Title`.
- Each phase: `**Goal:**` one-liner, then `**Exit criterion:**` as a
  RUNNABLE command with expected output — never prose like "works well".
- Tasks: numbered bold-ID checkboxes 3–5 levels deep
  (`- [ ] **1.2.3** …`), leaf text naming exact files, functions, and
  literal values. Task groups close with `**Acceptance:**` — also runnable.
- Decisions: `> **Decision (YYYY-MM-DD):** <call>. Tradeoff: <cost>;
  mitigated by <mitigation>. Revisit when <trigger>.`
- `## Cross-cutting risks` — each risk owned: `**Owner: Phase N.M**`.
- `## Open items` — dated checkboxes.
- Optional `## Glossary` for invented terms.

## Mode: replan — change the plan honestly

- Nothing is deleted or silently edited. Changed decisions:
  `~~old text~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- New scope discovered mid-project becomes a decimal phase (`Phase 3.5`)
  inserted in place, with a Goal explaining why it exists mid-stream.
- Deferred work leaves a breadcrumb at both ends: the origin notes
  `1.4.2 moved to Phase 3.5 (<reason>)`; the destination names the origin.
- Reality diverging from plan gets `**Status (YYYY-MM-DD):**` lines under
  the phase, keeping the original target visible.

## Tickets mode (`tracking: tickets`)

Full deltas: `references/tickets-mode.md` — read it when the resolved
config sets `tracking: tickets`, and not otherwise. Document mode is the
default and needs none of it.

## Hackathon mode

Use `references/hackathon-template.md` instead: clock-window phase headings
with hour estimates, a `> **Build order:**` blockquote with arrows and
unblock rationale, owner tags from the config's `## Collaborators`,
`← unblocks <owner>` annotations, a `## Demo Script` section, a
`## Future Extensions (mention, don't build)` section, and a submission
checklist that includes verifying `.env` was never committed
(`git log --all -- '*.env'`) and that any event-required sections are
present and user-authored.
