# Target: tests — does the suite have teeth

A green suite is evidence only if its tests could have failed. This target
sweeps an existing suite for tests that pass without catching anything —
the never-inflate rule pointed at tests instead of eval scores.

**No test suite found → say so and stop.** A test audit written from the
source alone would be fiction, the same way an eval audit without a results
file would be.

Output opens with the verdict — `suite has teeth` or `<N> findings` — then
the evidence, then scope (which files were swept, which were not, and
whether the mutation spot-check ran). Rules and detection commands live in
`references/test-audit-rules.md`; the five classes are assertion-free
tests, tautological assertions, mocks stubbing the unit under test, unread
snapshots plus accumulating skips, and the mutation spot-check.

The spot-check is the only one that proves rather than suggests: break the
production code deliberately and confirm the suite goes red. A mutation
that leaves it green is a confirmed coverage hole. **Revert every mutation
before reporting, say that you did, and verify it** — a mutation left
behind is a defect this audit introduced. Never mutate a tree that was
already dirty; you could not prove a clean revert.

Nothing here is fixed: a bad test is reported and left standing, because
deleting it hides the coverage gap it was proving.
