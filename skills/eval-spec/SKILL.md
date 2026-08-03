---
name: eval-spec
description: Write the eval before the system exists - golden questions with category minimums, refusal cases where declining is the right answer, a grader defined up front, and the acceptable_failure discipline. The score target becomes the plan's exit criterion before any code is written.
argument-hint: "[feature | notes]"
disable-model-invocation: true
---

# /eval-spec — the eval IS the spec

For an LLM-shaped feature, "done" is a score on a golden set that existed
before the code did. If the golden set doesn't define success, the code has
no target — it has vibes. This skill is user-invoked only: it creates
committed artifacts and sets score targets, a deliberate act like /plan.

`Adjacent skills:` /audit eval (reviews eval RESULTS after runs;
/eval-spec writes the eval before code exists).

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

## The sequence

0. **Refuse to overwrite an existing eval.** If `eval/spec.md` or
   `eval/golden.jsonl` already exists, stop and say so. A committed
   golden set is the definition of done; regenerating it silently
   rewrites the target, which is the never-inflate rule's exact failure
   mode. Offer instead to ADD cases to the existing set, or to supersede
   one specific case per the hard rules below. Proceed only when neither
   file exists.
1. **Read** BRIEF.md and PLAN.md. The BRIEF's domain landmines become
   adversarial cases — every do-NOT rule in the brief is a test waiting to
   be written. No BRIEF → say so and proceed from PLAN plus the
   interview, noting in `eval/spec.md` that landmines were not sourced
   from a brief.
2. **Interview** for categories: what kinds of questions will real users
   ask, what must the system refuse, what does partial credit mean. Push
   for the ugly categories the user hasn't thought about — the eval's value
   concentrates there.
3. **Write `eval/spec.md`** per `references/eval-spec-template.md`: the
   category table (name, definition, MINIMUM case count, target score),
   the grader definition per grade rule, the exact run command, and the
   `acceptable_failure` policy.
4. **Write `eval/golden.jsonl`** — one JSON object per line:
   `id`, `category`, `input`, `expected`, `grade_rule`
   (`exact` | `concept` | `numeric-tolerance:<x>` | `rubric:<name>`), and
   optionally `acceptable_failure` (MUST carry a `reason` string when
   present). Seed every category to at least its minimum; mark
   placeholder cases needing real data `"status": "needs-data"`.
5. **Wire the plan.** Propose the PLAN.md edit that makes the relevant
   phase's `**Exit criterion:**` the eval run command with its target
   (e.g. `python eval/run.py → overall ≥ 85%, refusal = 100%`). The target
   is set NOW, before code, while nobody is tempted to set it at whatever
   the system happens to score.

## Category minimums

Floors the spec states and the dataset must meet. Default floor set —
adjust in the interview, never silently:

- **happy-path** — representative real questions (≥10).
- **edge** — boundary values, empty/sparse data, ambiguous phrasing (≥5).
- **adversarial** — drawn from the canonical input bank in
  `../qa/references/adversarial-inputs.md`: garbage strings, oversized
  input, regex-special characters, out-of-range values,
  prompt-injection-shaped input (≥5).
- **refusal** — inputs where the CORRECT behavior is declining:
  out-of-domain, no-data-available, unsafe (≥5). A system that answers a
  refusal case fails that case — refusing well is a capability, not an
  absence.

## Grader discipline

Rules in `references/grader-rules.md`, aligned with /audit eval: assert
the concept, not the literal wording; normalize Unicode before substring
compares; numeric answers carry explicit tolerances; every rubric names
its dimensions. Grader-brittleness fixes are legitimate and logged;
editing a case or its expected value to raise a score never is.

## Hard rules

- The dataset is committed to the repo — the golden set is project memory,
  not a local file.
- A committed golden case is never edited to pass. A genuinely wrong case
  is superseded: `"status": "superseded", "superseded_by": "<new-id>",
  "reason": "<why>"` — and the corrected case gets a new id. The
  never-inflate rule applies to the dataset itself.
- `acceptable_failure` is declared per-case with a written reason, decided
  when the case is written or when a failure is classified — never bulk-
  applied after a bad run.
- The headline number is always computed from the raw results file, never
  transcribed by hand.
