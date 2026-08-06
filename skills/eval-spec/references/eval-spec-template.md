# eval/spec.md — template

```markdown
# Eval spec — <feature name>

> Written <YYYY-MM-DD>, BEFORE implementation. This document defines
> "done" for <feature>: the golden set + grader below are the spec.
> Run: `<exact command>` → prints per-category and overall scores from
> `eval/results/<latest>.json`.

## Isolation

The run command above MUST isolate the subject from the operator's own
agent configuration, and MUST pin the subject model. Without both, the run
does not measure the subject — it measures the subject plus whatever the
operator happens to have installed, on whatever model their CLI defaulted
to that week.

Four things leak by default, all of them invisible in the results file:

| Leak | What it does to the run |
|---|---|
| **User-level skills** (`~/.claude/skills/`) | The subject gains capabilities the spec never granted |
| **Hooks** (SessionStart and friends) | Text is injected into the session before the first case |
| **Memory / auto-memory / CLAUDE.md discovery** | Prior sessions' context bleeds into a supposedly cold run |
| **Output styles and user settings** | Response shape shifts, so shape-sensitive graders swing |

**The baseline arm is where this bites hardest.** A/B runs compare a
candidate against a baseline; anything the operator has installed lands in
BOTH arms, and in the baseline it can make the candidate look better or
worse than it is. An operator evaluating their own pack is the worst case —
their `~/.claude` is precisely the thing under test.

**Invocation (fill in for this project's stack):**

```
<exact command, carrying its isolation flags and its model pin>
```

Isolation flags are stack-specific. State what each one drops, and state
what still gets through — an isolation claim with no residual is a claim
nobody checked.

## Model pin

The subject model is pinned in the run command and **recorded with every
published number**. Unpinned, the eval silently runs whatever the operator
or the CLI release defaults to: the model varies between operators, drifts
over time, and per-token cost moves with it. Two runs whose model differs
are not comparable and must not be reported as a before/after.

Pinned subject model: `<exact model id>` — the full id, never an alias
that resolves differently later.

*(Grader pinning is separate and already required — see the Grader section
below.)*

## Targets

| Category | Definition | Min cases | Target |
|---|---|---|---|
| happy-path | <what a normal ask looks like here> | 10 | ≥ 90% |
| edge | <boundaries, empty data, ambiguity> | 5 | ≥ 80% |
| adversarial | <garbage, oversized, regex chars, injection-shaped> | 5 | ≥ 80% |
| refusal | <what MUST be declined and why> | 5 | 100% |
| <domain-specific> | <from the BRIEF's landmines> | … | … |

Adversarial and edge cases draw from the acstack pack's canonical
adversarial-input bank (the `/qa` skill's `adversarial-inputs.md`
reference) — do not restate it here.

**Overall target: ≥ <n>%** — the number wired into PLAN.md's exit
criterion for <phase>. Refusal is never averaged away: its target stands
alone.

## Grader

| grade_rule | How it's judged |
|---|---|
| exact | normalized string equality (Unicode NFKC, trimmed, case folded unless the case sets `case_sensitive: true`) |
| concept | expected lists concept keywords; pass = all present in any phrasing (normalized substring) |
| numeric-tolerance:<x> | parsed number within ±x (absolute) or ±x% (suffix `%`) of expected |
| rubric:<name> | LLM-graded against the named rubric below; grader model + prompt pinned here |

### Rubrics
**<name>**: dimensions — <d1>, <d2>, <d3>; each 0/1 with a one-line
criterion; pass = <threshold>. Grader model: <exact model id>, temperature 0.

## acceptable_failure policy

A case may carry `acceptable_failure` + `reason` when <the project's
standard — e.g. "provider nondeterminism the grader can't pin down">.
Declared per-case, in the dataset, with the reason in writing. Never
added in bulk after a bad run; never used to move a category over its
target. Current count: <n> (listed by id below when nonzero).

## Dataset

`eval/golden.jsonl` — <n> cases. Cases with `"status": "needs-data"`
are placeholders awaiting real examples and are EXCLUDED from scoring
(and counted here: <n>). A placeholder's `expected` is `null`, never a
plausible-looking value: an arbitrary expected on a row nobody scores is
a fabricated answer waiting to be counted the day the status changes. Superseded cases stay in the file with
`"status": "superseded"` and are excluded from scoring.
```

## golden.jsonl — line format

```json
{"id": "hp-001", "category": "happy-path", "input": "…", "expected": "…", "grade_rule": "concept"}
{"id": "hp-002", "category": "happy-path", "input": "…", "expected": "positive", "grade_rule": "exact", "case_sensitive": true}
{"id": "rf-003", "category": "refusal", "input": "…", "expected": "decline: out-of-domain", "grade_rule": "concept"}
{"id": "ed-002", "category": "edge", "input": "…", "expected": "…", "grade_rule": "numeric-tolerance:0.5", "acceptable_failure": true, "reason": "source data itself ambiguous — see spec"}
```

`case_sensitive: true` belongs on a row whose expected's SHAPE is part
of the contract (an exact lowercase label); the grader then keeps case
instead of folding it (see the Grader table).

Ids are `<category-prefix>-<zero-padded n>` and never reused — a
superseded `ed-002` is replaced by `ed-007`, not a new `ed-002`.
