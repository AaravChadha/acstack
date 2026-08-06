# Seeded orphan document (fixture for PLAN 4.47)

INPUT fixture. Every owed-marker below is broken on purpose, one per
failure mode the rule has actually produced. `scripts/reach-check.sh` must
reject this file; a run that reports it clean has stopped resolving
carriers.

- A dangling carrier: the reword owes a live re-test [owed: 4.99].
- A closed carrier: this behavioural half owes a round [owed: 4.42].
- A decline with no reason: [owed: declined].
- An unreadable carrier: [owed: someday].
