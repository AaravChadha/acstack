# Eval non-regression fixture (PLAN 4.46)

Seeds the case the headline cannot see. Against `previous.jsonl`:

| File | overall | happy-path | refusal | gate |
|---|---|---|---|---|
| `previous.jsonl` (baseline) | 50.0% | 25.0% | 100.0% | — |
| `current.jsonl` | **66.7% (rises)** | 100.0% | **0.0% (falls)** | must BLOCK |
| `no-regression.jsonl` | 66.7% | 50.0% | 100.0% | must PASS |

`current.jsonl` is the discriminator: a gate that only reads the overall
number sees an improvement and lets it through. `no-regression.jsonl` is
the other direction — same overall rise, no category down — so a gate that
blocked everything would fail here rather than score full marks.

## Partial crashing (PLAN 4.51)

The pair above only moves pass/fail. It cannot catch a category whose cases
stop *running*, which is what shakedown 12 found. Against
`crash-previous.jsonl`:

| File | refusal, as the gate saw it | refusal, in truth | gate |
|---|---|---|---|
| `crash-previous.jsonl` (baseline) | 100.0% (4/4) | 4 of 4 scored | — |
| `partial-crash.jsonl` | **100.0% (1/1)** | **1 of 4 scored, 3 errored** | must BLOCK |

This is the trap: filtering to `status == "scored"` before computing the
rate compares the survivors alone, so a real collapse from 100% to 25%
reads as no change at all. The gate shipped blind to it for one day. A
category that crashes ENTIRELY is caught by the `gone` check — this fixture
seeds the shape in between, which is the likelier one, since a subject
usually breaks on some inputs rather than all of them.

`no-regression.jsonl` doubles as the negative control here: its scored
counts are unchanged, so a coverage check written `<=` instead of `<`
would block it and be caught.
