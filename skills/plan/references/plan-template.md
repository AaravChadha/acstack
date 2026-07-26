# PLAN.md template — the living plan

Grammar plus one fully worked mini-phase. Everything in `<...>` is a slot.

```markdown
# PLAN.md — <project name>

> **Purpose of this document.** Hierarchical breakdown of the work. Every
> phase has tasks; every task has subtasks; every subtask has acceptance
> criteria so we know it's done. Refer to `BRIEF.md` for the original problem
> statement (frozen reference).
>
> **Cross-cutting constraints (apply to every phase):**
> - <constraint, one per line, lifted from BRIEF.md and kept in sync by
>   dated verdicts — never silent edits>

**Gate verdict (YYYY-MM-DD):** <what was challenged in the written pushback,
what changed as a result, what was accepted as-is and why.>

## Index of phases

| Phase | Goal | Exit criterion |
|---|---|---|
| [Phase 1](#phase-1) | <one line> | <runnable check, abbreviated> |
| [Phase 2](#phase-2) | <one line> | <runnable check, abbreviated> |

---

## [ ] Phase 1 — <title> [Day 1]

**Goal:** <one sentence. What this phase proves, not what it contains.>

**Exit criterion:** `<command>` returns <expected output>.

### [ ] 1.1 <task group title>
- [ ] **1.1.1** Write `<file>` with `<function/constant>` doing <exact thing,
  with literal values in backticks>.
- [ ] **1.1.2** <next leaf — imperative, one line, machine-checkable>.

**Acceptance:** `<command>` produces <expected observable result>.

> **Decision (YYYY-MM-DD):** <the call>. Tradeoff: <what it costs>; mitigated
> by <mitigation>. Revisit when <trigger>.

---

## Cross-cutting risks (review weekly)

- **R1 — <risk name>.** <What could happen; what handles it.>
  **Owner: Phase <N.M>.**

## Open items (decide as we go)

- [ ] **<Item> (NEW YYYY-MM-DD).** <What must be decided, by when, and what
  it blocks.>

## Glossary

- **<Invented term>** — <definition>.
```

## Worked mini-phase (the texture to imitate)

```markdown
## [x] Phase 1 — Vertical slice (spine) [Day 1]

**Goal:** Prove the entire pipeline end-to-end on ONE field of ONE record.
Everything else is widening this spine.

**Exit criterion:** `python -c "from app.core import ask; print(ask('What is
the rate for item A?'))"` returns the correct number with a source citation.

### [x] 1.2 DB schema
- [x] **1.2.1** Write `db/schema.sql` containing the schema from
  `BRIEF.md` plus the deltas from the gate:
  - [x] **1.2.1.1** Add `records.record_uid TEXT UNIQUE NOT NULL`.
  - [x] **1.2.1.2** Add `snapshots.revision INT DEFAULT 1`; replace
    `UNIQUE(record_id, month)` with `UNIQUE(record_id, month, revision)`.
- [x] **1.2.2** Write `db/init_db.py`: idempotent — `--force` drops and
  recreates; otherwise creates tables only if absent.

**Acceptance:** `python db/init_db.py` produces `app.db`;
`sqlite3 app.db ".tables"` lists `records`, `snapshots`, `query_log`.
```

## Change rules (replan mode)

- Superseded decision:
  `~~Do NOT parse type-B files yet — phase-2 build.~~ → **Verdict
  (2026-05-12):** Done in-pilot. Parser handled type-B with ~80% reuse;
  added 2 fields. See "Phase 4.3 outcome" below.`
- Deferral breadcrumbs at both ends:
  origin: `1.4.2 and 1.4.3 moved to Phase 3.5 (needs facility service
  first)`; destination re-opens the original numbering.
- Reality update: `**Status (YYYY-MM-DD):** <measured state vs target,
  with numbers and what's tracked where>` — the original target stays.
- New mid-project scope: decimal phase (`Phase 3.5`) inserted in place.
