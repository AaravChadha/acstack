# Runner template — scaffold only when none exists

The runner is the project's file, not the pack's: it is committed to the
project, edited by the project, and never regenerated once it exists.
Scaffold the shape below in the project's own language, then fill the ONE
project-specific function — `run_subject` — with how this system is
actually invoked.

## The contract every runner honors

Whatever the language, a runner MUST:

1. Read `eval/golden.jsonl`, one JSON object per line.
2. **Skip** `status: "needs-data"` (report as skipped, never as passed).
   **Exclude** `status: "superseded"` from the file and the denominator.
3. Grade each case by its own `grade_rule` — `exact`, `concept`,
   `numeric-tolerance:<x>`, `rubric:<name>` — normalizing Unicode
   (NFKC) and whitespace before any string compare. The lookalike trio
   (U+202F, U+00A0, U+2013) is why: a grader that fails on invisible
   characters reports a subject failure that never happened.
4. Apply `acceptable_failure` ONLY when the case carries a `reason`
   string, and record every application.
5. Write `eval/results/<UTC-timestamp>.jsonl`, one record per case:
   `id`, `category`, `pass`, `expected`, `actual`, `grade_rule`,
   `acceptable_failure_applied`.
6. Print the headline **computed from the records it just wrote** —
   overall %, per-category %, refusal % — never accumulated in a
   variable along the way. Reading back the file is what makes the
   number auditable by `/audit eval`.
7. Exit non-zero when the run could not complete, so `/ship`'s gate 3
   cannot mistake a crash for a pass.

## Python — `eval/run.py`

```python
#!/usr/bin/env python3
"""Eval runner. Grades eval/golden.jsonl, writes eval/results/<ts>.jsonl."""
import json, pathlib, sys, unicodedata, datetime, re

ROOT = pathlib.Path(__file__).resolve().parent
GOLDEN = ROOT / "golden.jsonl"
RESULTS_DIR = ROOT / "results"

def norm(s):
    s = unicodedata.normalize("NFKC", str(s))
    s = s.replace("–", "-").replace(" ", " ").replace(" ", " ")
    return re.sub(r"\s+", " ", s).strip().lower()

def run_subject(case):
    """THE ONE PROJECT-SPECIFIC FUNCTION. Return the system's answer as a
    string. Three shapes, pick one and delete the rest:

      CLI:      return subprocess.run([...], capture_output=True, text=True).stdout
      HTTP:     return requests.post(URL, json={"q": case["input"]}).json()["answer"]
      import:   from myapp import answer; return answer(case["input"])

    A model API call belongs here. It is the only place that spends money,
    and it is deliberately left empty so a scaffold can never quietly bill.
    """
    raise NotImplementedError("wire run_subject to the system under test")

def grade(case, actual):
    rule = case.get("grade_rule", "exact")
    expected = case.get("expected", "")
    if rule == "exact":
        return norm(actual) == norm(expected)
    if rule == "concept":
        return norm(expected) in norm(actual)
    if rule.startswith("numeric-tolerance:"):
        tol = float(rule.split(":", 1)[1])
        nums = lambda s: [float(x) for x in re.findall(r"-?\d+\.?\d*", str(s))]
        a, e = nums(actual), nums(expected)
        return bool(a and e and abs(a[0] - e[0]) <= tol)
    if rule.startswith("rubric:"):
        # Rubric grading is human or model-judged; the runner records the
        # answer and marks it for review rather than inventing a verdict.
        return None
    raise ValueError(f"unknown grade_rule: {rule}")

def main():
    cases = [json.loads(l) for l in GOLDEN.read_text().splitlines() if l.strip()]
    cases = [c for c in cases if c.get("status") != "superseded"]
    records, skipped = [], 0
    for c in cases:
        if c.get("status") == "needs-data":
            skipped += 1
            continue
        try:
            actual = run_subject(c)
            passed = grade(c, actual)
        except Exception as exc:                # a crash is a failure, never a skip
            actual, passed = f"ERROR: {exc}", False
        af = c.get("acceptable_failure")
        applied = bool(af and af.get("reason") and not passed)
        records.append({
            "id": c["id"], "category": c.get("category", "uncategorized"),
            "pass": passed, "expected": c.get("expected"), "actual": actual,
            "grade_rule": c.get("grade_rule", "exact"),
            "acceptable_failure_applied": applied,
        })
    RESULTS_DIR.mkdir(exist_ok=True)
    ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out = RESULTS_DIR / f"{ts}.jsonl"
    out.write_text("".join(json.dumps(r) + "\n" for r in records))

    # headline recomputed FROM THE FILE — the whole point
    written = [json.loads(l) for l in out.read_text().splitlines() if l.strip()]
    scored = [r for r in written if r["pass"] is not None]
    ok = sum(1 for r in scored if r["pass"] or r["acceptable_failure_applied"])
    print(f"results: {out}")
    print(f"overall: {ok}/{len(scored)} ({100*ok/len(scored):.1f}%)" if scored else "overall: no scored cases")
    by = {}
    for r in scored:
        d = by.setdefault(r["category"], [0, 0]); d[1] += 1
        if r["pass"] or r["acceptable_failure_applied"]: d[0] += 1
    for cat, (p, n) in sorted(by.items()):
        print(f"  {cat}: {p}/{n} ({100*p/n:.1f}%)")
    if skipped:
        print(f"skipped (needs-data): {skipped}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

## Node — `eval/run.mjs`

Same contract, same structure: `norm()` with NFKC plus the lookalike
folds, `runSubject(case)` as the single project-specific function,
`grade()` switching on `grade_rule`, results written to
`eval/results/<ts>.jsonl`, then **re-read** to compute the headline, and
`process.exit(1)` if the run could not complete. Keep it dependency-free
(`node:fs`, `node:path`) so the eval never drags in a package the project
does not already have.

## What the runner must NOT do

- Count skipped or superseded cases as passes.
- Compute the headline from in-memory tallies instead of the file.
- Retry a failing case until it passes.
- Edit `golden.jsonl` for any reason.
- Swallow an exception into a pass — a crash is a failure with the error
  as `actual`.
