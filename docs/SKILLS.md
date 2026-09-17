# Skills — the full roster

Moved out of README.md on 2026-09-17. The front door tells a stranger what
shape the pack is; this file is the index, and an index is not a front door.
`/audit readme` measures density against comparator projects, and a 33-row
table in the first screen is where the length was.

Every skill in the pack, by stage. Every one is
typed — `/plan` and `/eval-spec` are additionally hidden from the model's own
skill list, so they only ever run when you ask for them.

### Plan

| Skill | What it does | Typical invocation |
|---|---|---|
| `/plan` | Frozen BRIEF.md → written architecture pushback → living PLAN.md with runnable exit criteria | `/plan seed` |
| `/challenge` | Interrogate the BRIEF: premise attacks, a narrower wedge, cost and blast-radius checks | `/challenge` |
| `/plan-review` | Engineering lock on PLAN.md: data-flow trace, failure modes, test matrix → LOCKED or CHANGES REQUIRED | `/plan-review` |
| `/eval-spec` | The eval is the spec: golden set, category minimums, refusal cases, pinned grader — written before the system exists | `/eval-spec search` |

### Build

| Skill | What it does | Typical invocation |
|---|---|---|
| `/do` | Complete one numbered subtask: execute → verify acceptance → tick the exact box → commit plan and code together, locally | `/do 3.2.1` |
| `/ticket` | Capture a brain-dump as a well-formed work item; unknowns marked TBD, never invented | `/ticket "…"` |
| `/investigate` | Root-cause before any fix: minimal repro, hypotheses vs evidence, three-strikes stop rule | `/investigate "500 on save"` |
| `/resume` | Five-minute catch-up: where the project is, divergence flags, next 3 unblocked tasks | `/resume` |
| `/why` | Decision archaeology: BRIEF → dated PLAN verdicts → JOURNAL → git history, stopping at the first real answer | `/why "the /health name"` |
| `/refactor` | Behavior-preserving cleanup with proof: green before and after, with the same test count | `/refactor src/parser.py` |
| `/design` | Production-grade UI: DTCG tokens, wireframe before code, eight production-readiness items, gaps named | `/design "settings page"` |

### Verify

| Skill | What it does | Typical invocation |
|---|---|---|
| `/audit` | Six targets — code, docs, eval, tests, skills, readme — each with its own evidence rule | `/audit code src/` |
| `/secure` | Confidence-gated security review: a finding needs an exploit scenario and a rating. Reports only | `/secure src/` |
| `/qa` | Exercise the running app: happy-path flows, adversarial inputs, auth probing, exact repro commands | `/qa http://localhost:3000` |
| `/contract-check` | Breaking-change pre-flight for signatures, response shapes, exports, config keys → written GO/NO-GO | `/contract-check` |
| `/deps` | Dependency hygiene: is it imported, would stdlib do, is it maintained, does its license fit; `upgrade` mode pre-flights a version bump against your call sites → GO/NO-GO | `/deps` · `/deps upgrade zod 4` |
| `/migrate-check` | Read-only pre-flight for migrations against shared Postgres, per statement → GO/NO-GO | `/migrate-check` |
| `/eval-run` | Execute the eval, grade every case by its rule, compute the headline from the results file — never by hand | `/eval-run` |
| `/design-audit` | Static UI check: off-palette colors, dishonest data labels, AI-slop, leaked internal language | `/design-audit src/ui/` |

### Ship and reflect

| Skill | What it does | Typical invocation |
|---|---|---|
| `/ship` | Branch-level release behind five gates: clean state, tests, eval-vs-target, docs drift, attribution | `/ship` |
| `/journal` | End-of-session JOURNAL.md entry: exact bugs, before→after numbers, PLAN sync | `/journal` |
| `/retro` | Trend across sessions: velocity vs plan dates, eval-score trend, open-risk status | `/retro week` |
| `/learn` | Capture a durable lesson to LEARNINGS.md; recurring ones get promoted into known-bug-classes | `/learn "…"` |
| `/triage` | Backlog hygiene: stale, dupes, missing acceptance, ready work — report first, apply on approval | `/triage` |
| `/health` | Read-only checkup: docs, pointer, conduct block, config, secrets, attribution — every ✗ with its fix | `/health` |

`/plan` shadows built-in plan mode (Shift+Tab still enters it) and `/resume`
shadows built-in session resume (`claude -r` still works). Both kept
deliberately — the names are correct for what they do.

---

Back to [README.md](../README.md).
