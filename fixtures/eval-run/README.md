# /eval-run fixture — the false-pass control (PLAN 4.12 / 4.15)

Nine golden cases against a deterministic lookup table, seeded to
exercise every way a headline can lie:

| case | what it seeds | effect on the headline |
|---|---|---|
| q1, q2 | plain passes | counted |
| q3, q4 | `concept` matches | counted |
| q5 | **a real failure** (absent from the table) | counted, fails |
| q6 | `needs-data` | skipped, NOT counted, named in the report |
| q7 | `rubric:` — machine-ungradeable | excluded, NOT counted, named |
| q8 | a failure with `acceptable_failure: true` + a sibling `reason` | counted as ok, named with its reason |
| q9 | the same, in the **object** form — the shape that crashed the runner | counted as ok, named with its reason |

A correct runner reports **6/7 (85.7%)**, names both exclusions, and
lists both forgiven failures with their reasons.

Three ways a runner can be broken while looking green, all caught here:
counting a skip as a pass (would read 7/7), swallowing q5's failure
(same), or letting q7 vanish silently — which changes no percentage at
all and is therefore invisible without the explicit line. q8 and q9 together cover the schema crash: `acceptable_failure` is
written in the wild both as a bool with a sibling `reason` (q8) and as
an object carrying its own (q9). Reading `.get()` on the bool form
killed the run outright — after it had already spent money on every
earlier case — until 2026-07-31.

Run it (no network, no API key, no dependencies):

```bash
cd fixtures/eval-run && python3 eval/run.py
```
