# Target: docs — drift check

Drift check — every claim a doc makes that reality can contradict:

- Project-structure blocks vs the actual tree (`ls`/glob against the ASCII
  tree line by line).
- Stale counts vs greppable reality: tool counts, test counts, table counts,
  record counts.
- **Work named as owed with nobody owning it.** A doc that says something
  "owes" a fix, a round, or a follow-up, without naming the open task that
  will do it, is drift the moment the sentence is written — the obligation
  reads as scheduled and is not. In an acstack repo the mechanical half of
  this runs in `scripts/check.sh` on every commit and covers only MARKED
  obligations (`[owed: N.NN]`); the judgment half is yours, and it is the
  unmarked prose the guard cannot see. Read for the promise, not the tag.
- Checkbox state, both directions: a `[x]` whose Acceptance command now
  fails, and a subtask `[ ]` whose artifact plainly exists. A phase heading
  `## [ ]` held open while its `**Exit criterion:**` is unmet is /do's gate,
  not drift — flag it only when the flip condition is met (the criterion
  passes, or none is declared and every child is checked).
- File-location tables vs actual paths.
- Run the README quickstart where cheap; a broken quickstart is drift.

Output: a verdict first — `NO DRIFT` or `<N> drift findings` — then a
numbered list of `doc says / reality is / fix` triples. Nothing else
counts as a docs finding. Close with scope: which documents and which
claims were checked, and which were too expensive to verify.
