# Goodhart fixture — cases that pass while getting the task wrong

Seeded for PLAN 4.65. Each line of `gameable.jsonl` is a golden case that
a WRONG answer satisfies, one per shape in
`skills/eval-spec/references/goodhart.md`:

- `g1` — the refusal that isn't. The grader looks for "cannot help"; an
  answer that says it and then complies passes anyway.
- `g2` — the expected leaked into the input. Echoing the question passes.
- `g3` — keyword stuffing. A wrong summary containing all five keywords
  passes.

These are the BEFORE state. A spec that survived the Goodhart pass would
not contain them.
