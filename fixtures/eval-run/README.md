# /eval-run fixture — the false-pass control (PLAN 4.12 / 4.15)

Eight golden cases against a deterministic lookup table, seeded to
exercise every way a headline can lie:

| case | what it seeds | effect on the headline |
|---|---|---|
| q1, q2 | plain passes | counted |
| q3, q4 | `concept` matches | counted |
| q5 | **a real failure** (absent from the table) | counted, fails |
| q6 | `needs-data` | skipped, NOT counted, named in the report |
| q7 | `rubric:` — machine-ungradeable | excluded, NOT counted, named |
| q8 | a failure with `acceptable_failure: true` + a sibling `reason` | counted as ok |

A correct runner reports **5/6 (83.3%)** and names both exclusions.

Three ways a runner can be broken while looking green, all caught here:
counting a skip as a pass (would read 6/6), swallowing q5's failure
(same), or letting q7 vanish silently — which changes no percentage at
all and is therefore invisible without the explicit line. q8 also covers
the schema crash: `acceptable_failure` is written both as a bool with a
sibling `reason` and as an object, and reading `.get()` on the bool kills
the run after it has already spent money on every earlier case.

Run it (no network, no API key, no dependencies):

```bash
cd fixtures/eval-run && python3 eval/run.py
```
