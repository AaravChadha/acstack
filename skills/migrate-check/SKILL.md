---
name: migrate-check
description: "Pre-flight safety check for Prisma/SQL migrations. MUST be run before creating or applying any migration in a project whose database is shared Postgres. Opens with a written GO or NO-GO verdict, then classifies every SQL statement additive vs destructive, checks migration-history drift and folder reuse, enforces create-only plus deploy discipline, and identifies the backup path first. Never fixes anything - it blocks and explains."
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

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + pack known-bug-classes, capped 6KB
else
  echo "runtime off — proceeding without recall/update-check"
fi
```
<!-- /acstack:runtime -->

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
2. **Identify the target**: the folder or file named in the arguments,
   else the newest unapplied migration. Resolution is stack-dependent —
   `npx prisma migrate status` for Prisma; otherwise the newest unapplied
   file in the project's migrations directory (Drizzle, Rails, Alembic,
   Flyway, plain SQL). **If the stack cannot be determined or the target
   cannot be resolved, say exactly that and ask for the target path —
   never assume Prisma.**

   **Honest scope on non-Prisma stacks.** Steps 3 (backup path) and 4
   (classification) are stack-agnostic and run normally. Steps 5, 6, 7,
   and 8 name Prisma commands specifically, and the `allowed-tools`
   whitelist deliberately permits no migration CLI except
   `prisma migrate status` — running an
   arbitrary stack's CLI is exactly the mutation risk this skill exists
   to prevent. So on Drizzle/Alembic/Rails/Flyway/plain SQL, say plainly:
   *"history-drift and command-discipline checks skipped — <stack> CLI is
   outside this skill's read-only whitelist; verify applied-migration
   history manually before the GO."* A narrowed verdict stated is honest;
   a full verdict implied from a partial check is not.
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

**The verdict is the report's FIRST line**, then the evidence that earned
it — a reader who stops after one line must still get the answer. Restate
it at the end as a written block, always:

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
