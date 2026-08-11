# Target: eval — failure classification

Read the eval report or results file. **No results file → say so and
stop**; there is nothing to audit and a report written from the spec
alone would be fiction.

Output opens with the verdict — `headline verified` or
`<N> findings (headline overstated by <x>)` — then the evidence below,
and closes with scope (which cases were reviewed, which were not). Rules
per `references/eval-review-rules.md`:

- Every failure classified: prompt issue / grader brittleness / provider
  flake / data issue / parser issue / genuinely ambiguous.
- **The never-inflate rule is absolute:** never adjust a test case or its
  expected values to raise the score. `acceptable_failure` survives only
  with a written justification. A real miss is logged and left standing.
- Grader brittleness is distinct from subject failure and its remedy IS
  legitimate (asserting the concept instead of the literal wording;
  Unicode normalization before substring compare). Recommending a grader
  fix is not inflation — but the report says which remedy it recommends
  and why. /audit still does not apply it.
- Verify the report's own arithmetic and that its headline number matches
  the raw results file.
