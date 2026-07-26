# Review dimensions — question sets and finding formats

## 1. Data-flow trace

Walk: origin → ingestion → transformation(s) → storage → retrieval →
presentation. At each hop ask:

- What EXACTLY moves (fields, format, volume), produced by what, consumed
  by what — using the plan's own names for tables, files, and keys?
- Where does it live between hops, and what happens to in-flight data when
  the consumer is down?
- Is anything transformed twice, or assumed transformed that never is?
- Do the names match across phases? (Phase 2 writes `scores.json`, phase 4
  reads `results.json` — that's a finding.)

Finding format:
`TRACE: <hop> — <what's missing/mismatched> — plan line/phase — severity`

## 2. Failure modes

Per phase, run the triad:

- **Bad input:** malformed, empty, oversized, wrong-encoding, adversarial.
  Which task validates? Where does the reject go — error, log, silent drop?
- **Partial failure:** the API times out on call 3 of 10; the process dies
  mid-write. Is the state resumable, re-runnable, or corrupted? Is any
  operation non-idempotent and unprotected?
- **Volume:** 10× the assumed rows/requests/tokens. What saturates first —
  memory, rate limit, timeout, cost?

Each finding needs all three clauses:
`FAILURE: <trigger> → <consequence> — detected by <what> — recovery: <what>`
A finding with "detected by: nothing" is automatically CHANGES REQUIRED
material if the consequence is data loss or silent corruption.

## 3. Test matrix

Build the table the plan implies: rows = the flows/components the phases
deliver; columns = happy path, edge, bad input, failure injection. Fill
each cell with the concrete case or `—` for genuinely-not-applicable, and
`MISSING` where a case should exist but no task creates it.

Then the runnable-criteria sweep, by ID:

- `EXIT: Phase N — criterion "<quote>" is not runnable — propose: <command>`
- `ACCEPT: task N.M — group has no **Acceptance:** — propose: <command>`

## 4. Hidden assumptions

Sweep the plan for verbs that smuggle certainty: "just", "simply", "then
we parse", "the API returns", "supports", "handles". Each hit becomes:

`ASSUMPTION n: <claim> — believed because <source or "unstated"> —
cheapest probe: <one-liner> — if false: <which phases break>`

Rank by (cost if false × cheapness of probe). The top of that list is
what should be probed BEFORE the plan is locked — a 10-minute probe that
protects three phases is the best trade in planning.

## Severity scale (used across dimensions)

- **blocker** — plan cannot succeed as written; verdict cannot be LOCKED.
- **major** — a phase will visibly fail or rework; LOCKED only with a
  recorded decision accepting the risk.
- **minor** — friction, not failure; listed, never blocks.

## Report skeleton

```markdown
## Plan review — <repo> — <date> — scope: <whole plan | phase N>
**Verdict: LOCKED | CHANGES REQUIRED** — <one line>

### Data-flow trace
<hop list with per-hop notes, then TRACE findings>
### Failure modes
<FAILURE findings, grouped by phase>
### Test matrix
<the table, then EXIT/ACCEPT findings>
### Hidden assumptions
<ranked ASSUMPTION list>
### Proposed plan edits   (CHANGES REQUIRED only)
<exact supersede-style edits, ready for /plan replan>
### Not reviewed
<out-of-scope phases, unprobed externals>
```
