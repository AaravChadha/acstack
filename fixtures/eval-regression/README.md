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
