# Grader rules — judging answers without lying to yourself

## Assert the concept, not the literal wording

A grader that demands "the schema migration is destructive" fails a
correct answer phrased "this migration will drop data". Expected values
for `concept` cases list the CONCEPTS ("destructive", "data loss",
"backup first") — the grader passes any phrasing containing them after
normalization. If you find yourself tightening wording to make a wrong
answer fail, the case belongs in `rubric`, not `concept`.

## Normalize before comparing

Unicode NFC first; then trim, collapse internal whitespace. The classic
silent killers: U+202F narrow no-break space (thousands separators in
some locales), en-dash vs hyphen in ranges, curly vs straight quotes.
A grader that misses these reports subject failures that are actually
grader bugs — /audit eval calls this grader brittleness, and it is
fixable WITHOUT touching the case: fix the comparison, log the fix.

## Numbers get tolerances, stated

`numeric-tolerance:0.5` means ±0.5 absolute; `numeric-tolerance:2%`
means relative. The tolerance is chosen when the case is written — from
the data's real precision, not from what the system manages to produce.
Parsing rule: first number in the answer unless the case pins a label
(`"parse": "label:total"`), so a verbose answer isn't graded on its
page number.

## Rubrics are pinned or they drift

An LLM-graded rubric names: its dimensions (each 0/1 with a one-line
criterion), the pass threshold, the exact grader model id, temperature 0.
Changing any of these is a grader change — logged in the spec's history,
rescoring everything, never quietly.

## Refusal cases grade the refusal

Expected for refusal cases is the BEHAVIOR (`decline: out-of-domain`,
optionally + concept for what a good refusal mentions). An answer that
attempts the task — however accurately — fails. Partial credit does not
exist for refusal: the category target is 100% because one confident
answer where a refusal belonged is the worst failure the system has.

## The line between grader fix and inflation

| Action | Verdict |
|---|---|
| Fix Unicode normalization in the comparator | grader fix — log it |
| Widen `concept` keywords because a correct phrasing failed | grader fix — log it, keep the failing transcript |
| Loosen a tolerance because the system is off by 0.6 | inflation |
| Edit a case's expected value after seeing the system's answer | inflation |
| Mark `acceptable_failure` with a written reason at classification time | honest — count stays visible |
| Mark `acceptable_failure` in bulk to clear a category | inflation |

When in doubt: a grader fix makes the grader agree with a HUMAN judging
the same transcript; inflation makes the grader agree with the SYSTEM.
