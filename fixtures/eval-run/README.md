# /eval-run fixture — the false-pass control (PLAN 4.12 / 4.15)

Six golden cases against a deterministic lookup table. **q5 is seeded to
FAIL** ("atlantis city" is not in the table) and q6 is `needs-data`.

The control: a correct runner reports **4/5 (80.0%)** — four scored
passes out of five scored cases, with q6 skipped and NOT counted. Any
runner reporting 100% is broken in one of the three ways that matter and
that a green report cannot reveal: it counted the skip as a pass, it
swallowed the failure, or it compared nothing at all.

Run it (no network, no API key, no dependencies):

```bash
cd fixtures/eval-run && python3 eval/run.py
```
