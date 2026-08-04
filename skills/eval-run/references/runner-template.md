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
   **Exclude `rubric:` cases from the headline too** — they are not
   machine-gradeable — and NAME every exclusion in the output. A case
   that leaves the denominator silently changes no percentage, which is
   exactly why it is invisible.
3. Grade each case by its own `grade_rule` — `exact`, `concept`,
   `numeric-tolerance:<x>`, `rubric:<name>` — normalizing Unicode
   (NFKC), case, and whitespace before any string compare. NFKC folds
   U+202F and U+00A0 to spaces on its own; U+2013 needs an explicit
   fold. A grader that fails on invisible characters reports a subject
   failure that never happened. Case folds only when the case does not
   carry `case_sensitive: true` — a flag the spec template documents,
   so a scaffold that folds unconditionally silently ignores the spec.
4. Apply `acceptable_failure` ONLY when the case carries a `reason`
   string — accepting BOTH shapes in the wild, a bool with a sibling
   `reason` and an object carrying its own — and record every
   application. Never apply it to an ungraded case.
5. Write `eval/results/<UTC-timestamp>.jsonl`, one record per case —
   including skipped and ungraded ones, each carrying a `status`
   (`scored` / `skipped-needs-data` / `needs-rubric-review` / `error`)
   so `/audit eval` can see everything the run saw: `id`, `category`,
   `pass`, `status`, `expected`, `actual`, `grade_rule`,
   `acceptable_failure_applied`. Sub-second timestamp precision, so two
   runs in one second cannot overwrite each other's evidence.
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

def norm(s, fold_case=True):
    """NFKC folds NBSP and narrow-NBSP to spaces on its own; the en-dash
    needs an explicit fold. Case folds by default — `exact` means the same
    answer, not the same keystrokes — EXCEPT when the case carries
    `case_sensitive: true`: then the output's shape is part of the
    contract and case is kept."""
    s = unicodedata.normalize("NFKC", str(s)).replace("\u2013", "-")
    s = re.sub(r"\s+", " ", s).strip()
    return s.lower() if fold_case else s

def run_subject(case):
    """THE ONE PROJECT-SPECIFIC FUNCTION. Return the system's answer as a
    string. Three shapes, pick one and delete the rest:

      CLI:      return subprocess.run([...], capture_output=True, text=True,
                                     check=True).stdout   # check=True is required:
                # without it a subject exiting non-zero returns its (empty)
                # stdout as a normal answer, which acceptable_failure can then
                # forgive — a crash laundered into a pass
      HTTP:     return requests.post(URL, json={"q": case["input"]}).json()["answer"]
      import:   from myapp import answer; return answer(case["input"])

    A model API call belongs here. It is the only place that spends money,
    and it is deliberately left unwired so a scaffold can never quietly bill.
    """
    raise NotImplementedError("wire run_subject to the system under test")

def accepted(case):
    """acceptable_failure is written two ways in the wild: a bool with a
    sibling `reason`, or an object carrying its own. Both are honored; a
    declaration with NO written reason is ignored, per /eval-spec."""
    af = case.get("acceptable_failure")
    if af is True:
        return bool(str(case.get("reason", "")).strip())
    if isinstance(af, dict):
        return bool(str(af.get("reason", "")).strip())
    return False

def grade(case, actual):
    """True / False, or None when the rule cannot be machine-graded."""
    rule = case.get("grade_rule", "exact")
    expected = case.get("expected", "")
    if rule == "exact":
        fold = not case.get("case_sensitive", False)
        return norm(actual, fold) == norm(expected, fold)
    if rule == "concept":
        # Substring containment is the floor, not the ideal: it is literal
        # enough to produce grader brittleness. When a case fails here but
        # the answer is right, fix the GRADER (widen to the concept), never
        # the case — /audit eval calls that bucket "grader brittleness".
        return norm(expected) in norm(actual)
    if rule.startswith("numeric-tolerance:"):
        raw = rule.split(":", 1)[1].strip()
        relative = raw.endswith("%")           # the spec allows ±x and ±x%
        tol = float(raw.rstrip("%"))
        nums = lambda s: [float(x) for x in re.findall(r"-?\d+\.?\d*", str(s))]
        a, e = nums(actual), nums(expected)
        if not (a and e):
            return False
        limit = abs(e[0]) * tol / 100 if relative else tol
        return abs(a[0] - e[0]) <= limit
    if rule.startswith("rubric:"):
        return None          # judged by a human or a model, never invented here
    raise ValueError(f"unknown grade_rule: {rule}")

def main():
    cases = [json.loads(l) for l in GOLDEN.read_text().splitlines() if l.strip()]
    cases = [c for c in cases if c.get("status") != "superseded"]
    records, errors = [], 0
    for c in cases:
        rec = {"id": c["id"], "category": c.get("category", "uncategorized"),
               "grade_rule": c.get("grade_rule", "exact"),
               "expected": c.get("expected"), "actual": None,
               "pass": None, "status": "scored",
               "acceptable_failure_applied": False,
               "acceptable_failure_reason": None}
        if c.get("status") == "needs-data":
            rec["status"] = "skipped-needs-data"
            records.append(rec); continue
        try:
            rec["actual"] = run_subject(c)
            rec["pass"] = grade(c, rec["actual"])
        except Exception as exc:              # a crash is a failure, never a skip
            rec["actual"], rec["pass"], rec["status"] = f"ERROR: {exc}", False, "error"
            errors += 1
        if rec["pass"] is None and rec["status"] == "scored":
            rec["status"] = "needs-rubric-review"
        elif rec["pass"] is False and rec["status"] != "error" and accepted(c):
            # status guard is load-bearing: a case that CRASHED must never be
            # forgiven. acceptable_failure means "this answer is wrong for a
            # known reason", not "this run blew up" — and swallowing an
            # exception into a pass is the very thing this file forbids.
            rec["acceptable_failure_applied"] = True
            af = c.get("acceptable_failure")
            rec["acceptable_failure_reason"] = (af.get("reason") if isinstance(af, dict)
                                                else c.get("reason"))
        records.append(rec)

    RESULTS_DIR.mkdir(exist_ok=True)
    ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    out = RESULTS_DIR / f"{ts}.jsonl"
    out.write_text("".join(json.dumps(r) + "\n" for r in records))

    # headline recomputed FROM THE FILE — the whole point
    written = [json.loads(l) for l in out.read_text().splitlines() if l.strip()]
    scored = [r for r in written if r["status"] in ("scored", "error")]
    ok = sum(1 for r in scored if r["pass"] or r["acceptable_failure_applied"])
    print(f"results: {out}")
    print(f"overall: {ok}/{len(scored)} ({100*ok/len(scored):.1f}%)" if scored
          else "overall: no scored cases")
    if scored and all(r["status"] == "error" for r in scored):
        # zero graded cases: the number above measures the environment
        # (missing key, dead endpoint), never the subject — say so.
        print("NO SCORE: every case errored — nothing was graded; "
              "fix the environment and re-run before reading the number")
    by = {}
    for r in scored:
        d = by.setdefault(r["category"], [0, 0, 0]); d[1] += 1
        if r["pass"]: d[0] += 1
        elif r["acceptable_failure_applied"]: d[2] += 1
    for cat, (p, n, af) in sorted(by.items()):
        # a forgiven failure is shown, never folded silently into the pass
        # count — "2/2 (100.0%)" hiding a failure moves the number UP
        # without naming anything, which is inflation, not rounding.
        note = f"  [{af} acceptable_failure]" if af else ""
        print(f"  {cat}: {p + af}/{n} ({100*(p+af)/n:.1f}%){note}")

    # every case excluded from the denominator is named — silence here is
    # how a headline lies. Each of these has a record in the file too.
    for label, st in (("skipped (needs-data)", "skipped-needs-data"),
                      ("needs rubric review", "needs-rubric-review")):
        n = sum(1 for r in written if r["status"] == st)
        if n:
            print(f"{label}: {n} (excluded from the headline)")
    # every forgiven failure is named with its reason — an unlisted
    # acceptable_failure is a failure silently converted into a pass.
    forgiven = [r for r in written if r["acceptable_failure_applied"]]
    if forgiven:
        print(f"acceptable_failure applied to {len(forgiven)} case(s), each counted as ok:")
        for r in forgiven:
            print(f"  {r['id']} ({r['category']}): {r.get('acceptable_failure_reason') or '(no reason recorded)'}")
    if errors:
        print(f"errors: {errors} — run did not complete cleanly")
    return 1 if errors else 0

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
