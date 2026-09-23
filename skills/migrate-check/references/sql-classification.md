# SQL statement classification

Every statement in a migration gets exactly one class. When in doubt,
classify DOWN (toward destructive) — the cost of over-caution is one
confirmation; the cost of under-caution is data.

## Additive (safe to GO)

| Statement | Notes |
|---|---|
| `CREATE TABLE` | New table, no existing data touched |
| `ALTER TABLE … ADD COLUMN` (nullable, or with `DEFAULT`) | Existing rows get NULL/default |
| `CREATE INDEX` / `CREATE UNIQUE INDEX` on a NEW table | No lock concern on empty tables |
| `ADD CONSTRAINT … NOT VALID` | Validates future writes only |
| `CREATE EXTENSION IF NOT EXISTS` | Idempotent |

## Flagged (needs a look, often fine)

| Statement | Risk | Safe alternative |
|---|---|---|
| `CREATE INDEX` on a LARGE existing table | Locks writes for the build | `CREATE INDEX CONCURRENTLY` (outside a transaction) |
| `ADD UNIQUE` constraint on existing data | Fails if duplicates exist | Check duplicates first: `SELECT col, COUNT(*) … HAVING COUNT(*) > 1` |
| `SET DEFAULT` / `DROP DEFAULT` | Behavioral change for new rows | Confirm application code expects it |
| Widening type change (`VARCHAR(50) → TEXT`, `INT → BIGINT`) | Usually safe; still a table rewrite on some engines | Verify lock behavior at table size |

## Destructive (NO-GO without acknowledged plan + confirmed backup)

| Statement | What it destroys | Safe alternative |
|---|---|---|
| `DROP TABLE` | The table and all rows | Rename to `<name>_deprecated_<date>`, drop after a full cycle |
| `DROP COLUMN` | The column's data everywhere | Stop reading it first; drop in a later migration |
| `ALTER COLUMN … TYPE` (narrowing: `TEXT → VARCHAR(10)`, `BIGINT → INT`) | Truncates/fails on out-of-range values | Add new column, backfill with validation, swap, drop old later |
| `ALTER COLUMN … SET NOT NULL` on existing column | Fails on NULLs; blocks writes during scan | Add nullable → backfill → `SET NOT NULL` in a later migration |
| `ADD COLUMN … NOT NULL` without `DEFAULT` on a non-empty table | Migration fails outright | Add with DEFAULT, or nullable + backfill |
| `UPDATE` / `DELETE` / `INSERT … SELECT` (data rewrites inside a schema migration) | Rows, irreversibly | Move to a dry-run-by-default script with counts printed, run separately |
| `RENAME TABLE` / `RENAME COLUMN` | Prisma emits these as DROP + CREATE in some flows — check the actual SQL | Verify the generated SQL is a true rename; otherwise treat as drop |
| `TRUNCATE` | All rows | Almost never belongs in a migration |

## Not SQL, still checked

- **Folder reuse**: a migration folder name already present in
  `_prisma_migrations` is silently skipped on deploy. Re-lands need a new
  timestamped folder.
- **History drift**: folders on disk not recorded as applied (or vice
  versa) mean the live DB and the repo disagree — resolve before ANY
  migration runs.
- **Data scripts hiding in migrations**: seeds and backfills belong in
  scripts with dry-run defaults (`--apply` to execute), printing expected
  counts ("expect Inserted: 3, Updated: 122") — not inside schema
  migrations.
