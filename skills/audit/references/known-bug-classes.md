# Known bug classes

Recurring defect patterns, each as symptom → cause → check. /audit code
walks every class that applies to the stack; /learn promotes new recurring
lessons into this file.

## Postgres case-sensitivity behind an ORM

- **Symptom:** search worked in dev, returns 0 results in prod for
  lowercase queries (`hdfc` → 0, `HDFC` → 7).
- **Cause:** Prisma's `contains` compiles to case-sensitive `LIKE` on
  Postgres; SQLite's `LIKE` is case-insensitive, so the bug hides until the
  DB switch.
- **Check:** grep for `contains:` without `mode: 'insensitive'` in any
  Prisma query touching user input.

## Stale hardcoded test assertions

- **Symptom:** a test asserts a count or name-set that drifted from a
  growing registry (`len(TOOLS) == 4` while TOOLS has 6).
- **Cause:** the registry changed; the assertion was written as a literal.
- **Check:** grep tests for `== <integer>` and literal list assertions
  against anything that grows; verify each against the current registry.

## Unicode lookalikes breaking string comparison

- **Symptom:** a grader or matcher fails on visually identical text.
- **Cause:** U+202F narrow no-break space, U+2013 en dash, U+00A0 NBSP in
  one side of the compare.
- **Check:** normalize (NFKC + space/dash folding) before any substring
  assertion. Grep (the tool, or `grep -rnE` if absent — never shell
  `git grep`) for raw membership comparisons on external text:
  `git grep -nE 'if .* in .*:|\.includes\('` — the pattern the pack's
  own positive control re-runs, so it is documented rather than
  restated only in the control.

## Relative paths resolving from the wrong root

- **Symptom:** a tool reads/creates a file in a nested duplicate directory
  (`prisma/prisma/dev.db`) or "file not found" only when invoked from
  elsewhere.
- **Cause:** the path is resolved relative to the config file's directory
  (Prisma's `DATABASE_URL`) or the CWD, not the project root.
- **Check:** every relative path in config answers "relative to WHAT?" —
  verify by invoking from a different directory.

## Layout-coordinate assumptions in parsers

- **Symptom:** parser extracts garbage or NULLs for a subset of documents
  that render fine to the eye.
- **Cause:** hardcoded page numbers, x/y bands, or column positions that a
  template variant shifts (the section moved from page 3 to page 2).
- **Check:** anchor extraction on labels/structure, not coordinates; test
  against the known variant set, not one golden sample.

## Delete-then-insert without a transaction

- **Symptom:** occasional data loss — rows deleted, insert failed, nothing
  restored.
- **Cause:** re-ingest implemented as DELETE + INSERT in autocommit mode.
- **Check:** every delete-then-write pair is wrapped in one transaction
  with rollback verified by a forced-failure test.

## Silently skipped re-landed migrations

- **Symptom:** a re-added table never appears in the shared DB despite the
  migration "running".
- **Cause:** the re-land reused a previously applied migration folder name;
  the migration table says "already applied" and skips it.
- **Check:** re-lands get a NEW timestamped folder — see /migrate-check.

## Secret-scan regex missing prefixed key formats

- **Symptom:** a hardcoded API key sits in tracked source, but the
  secret grep reports clean — the key is never surfaced.
- **Cause:** a pattern like `sk-[A-Za-z0-9]{20,}` assumes the token is
  alphanumerics straight after `sk-`. Real keys carry a separator-joined
  prefix — OpenAI project keys `sk-proj-…`, Stripe `sk_live_…` /
  `sk_test_…` — so the first `-` or `_` ends the character class and the
  match fails.
- **Check:** allow the separators in the class:
  `sk[-_][A-Za-z0-9_-]{20,}`. Verify against `sk-proj-…`, `sk_live_…`,
  and a bare `sk-…` sample before trusting a "no secrets" result.

## Gitignore negation leaking secrets

- **Symptom:** a real `.env` is committed despite `.env*` in .gitignore.
- **Cause:** a later `!.env` negation line un-ignores it; the file also
  survives in git history after deletion.
- **Check:** `git check-ignore .env` says ignored; `git log --all -- '*.env'`
  is empty. If history contains it, the key is burned — rotate.
