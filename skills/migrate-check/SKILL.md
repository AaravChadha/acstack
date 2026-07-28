---
name: migrate-check
description: Pre-flight safety check for Prisma/SQL migrations. MUST be run before creating or applying any migration in a project whose database is shared Postgres. Classifies every SQL statement additive vs destructive, checks migration-history drift and folder reuse, enforces create-only plus deploy discipline, identifies the backup path first, and ends with a written GO or NO-GO verdict. Never fixes anything - it blocks and explains.
argument-hint: "[prisma/migrations/<folder>]"
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(ls:*), Bash(cat:*), Bash(npx prisma migrate status:*)
---

# /migrate-check — the gate before the shared database

A teammate's migration once dropped a table from a shared production
database. This skill exists so that never happens again. It is structurally
read-only: the tool whitelist has no Edit, no Write, and no prisma
subcommand that mutates anything. It blocks and explains; it never fixes.

`Adjacent skills:` /secure (security review; /migrate-check is DB-change
safety) · /audit code (defects in code; this gates schema changes).

<!-- acstack:principles -->
## Operating principles

- Be direct. Push back in writing when the plan or the user is wrong. No sycophancy.
- Never delete a decision. Supersede it: `~~old~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- Never fix, tune, or delete a test or eval case to raise a score. Log the miss honestly and leave the case unchanged.
- Name exact things: regex patterns, function signatures, model names, before → after numbers. Never "fixed bugs".
- Attribution: follow the project's `attribution` setting (default `none`) — no AI-tool mentions in generated docs, no attribution trailers in commits or PRs. Commit with explicit `-m`/`-F` messages only.
- Config: read `.claude/acstack.md` at the project root (fall back to `~/.claude/acstack.md`) before acting. `## Settings` keys override pack defaults; a `## <skill-name>` section overrides both. Unknown keys and sections are ignored.
- Docs: BRIEF.md (frozen seed) / PLAN.md (living plan) / JOURNAL.md (rolling journal). If the repo uses legacy names (PLANNING_PROMPT.md / PLANNING.md / STATUS.md), use those instead — never create both.
- Recall: if `LEARNINGS.md` exists at the project root, read it before starting.
- Conduct: follow the `acstack-conduct` block in this repo's AGENTS.md — the word is the mode; the user sets the pace.
<!-- /acstack:principles -->

## Procedure

1. **Resolve the safety level** from config `db:`. Default when unspecified
   is **shared-prod** — the conservative assumption. `local` → lighter path
   (step 8). `none` → say so in one line and stop.
2. **Identify the target**: the folder named in the arguments, else the
   newest unapplied migration per `npx prisma migrate status`.
3. **Backup and undo path FIRST.** Name the exact backup command (default
   `pg_dump "$DATABASE_URL" > backups/pre_<timestamp>.sql`; config
   `## migrate-check` `backup-command` overrides) and the restore step. If
   no undo path can be identified, the verdict is **NO-GO** — automatically.
4. **Classify every statement** in the migration SQL per
   `references/sql-classification.md`. Output a per-statement table:
   statement / class / risk / safe alternative where one exists.
5. **History drift and folder reuse.** Compare `migrate status` output with
   `prisma/migrations/`. Enforce the re-land rule: re-landing a previously
   dropped migration requires a NEW timestamped folder — a reused folder
   name already recorded in `_prisma_migrations` is silently skipped and
   the table never created. Flag any drift between recorded history and the
   folder set.
6. **Command discipline** (shared-prod): author with
   `npx prisma migrate dev --create-only`, apply with
   `npx prisma migrate deploy`. NEVER plain `migrate dev` and never
   `db push` against a shared database — both can reset or drift it.
7. **Sequencing.** Migrations are applied manually BEFORE merging code that
   depends on them: CI/hosting builds run `prisma generate && next build`
   (or equivalent) and never run migrations, so merged code referencing a
   not-yet-existing column fails at runtime. Confirm the ordering plan.
8. **`db: local` lighter path**: file backup
   (`cp prisma/dev.db prisma/dev.db.backup_<timestamp>`), plain
   `migrate dev` acceptable, but statement classification (step 4) still
   runs — destructive is destructive on any database.

## The verdict

End with a written block, always:

- `**Verdict: GO**` — only when every statement is additive, history is
  clean, and the backup path is named. Include the exact next commands in
  order.
- `**Verdict: NO-GO — <reason>**` — for any destructive statement without
  an explicit user-acknowledged plan, missing undo path, folder reuse, or
  history drift. Include: what to check (expected row counts, expected
  `migrate status` output), and a symptom → cause → action table for the
  likely failure modes.

Destructive operations are never a hard stop forever — they are a stop
until the user explicitly acknowledges the classification table and the
backup is confirmed taken. The skill's job is to make "I didn't realize it
would drop that" impossible.
