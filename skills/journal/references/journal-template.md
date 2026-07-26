# JOURNAL.md template — the rolling journal

```markdown
# JOURNAL — <project name>

> **What this file is.** A rolling snapshot of where the project actually
> is, so a fresh dev (or future-you) can open the repo and resume in 5
> minutes. Read this first, then `PLAN.md` for the full phase plan.
> **Last update**: YYYY-MM-DD. <2-3 sentence delta since the last update.>

## TL;DR

<5-8 bullets: what exists, what works, the headline numbers, the one thing
to know before touching anything.>

## How to run it right now

```bash
<numbered, copy-pasteable, verified-recently commands>
```

## What's been built

| Phase | Status | Highlights |
|---|---|---|
| 1 — <title> | ✅ | <one line with a number> |
| 2 — <title> | 🟡 partial | <what's missing> |

## Key decisions and journey (so you don't relearn)

### <What changed> (YYYY-MM-DD evening)

<Open with the state before the change and why it was bad, in concrete user
terms. Then the change, with named parameters. See worklog-rules.md.>

## What's still pending — from you

| Item | Why | What unblocks it |
|---|---|---|
| <item> | <why it matters> | <who must do what> |

## Deferred (with estimates)

1. <Item> — <why deferred, what sequence it waits on> (~<time estimate>).

## Important file locations

| Path | Purpose |
|---|---|
| `<path>` | <purpose> |

## Commit log highlights

```
<hash>  <message>          ← only the load-bearing ones
```
```

## Worked entry (the texture to imitate)

```markdown
### Retired the schema-lookup tool; moved schema into the system prompt (2026-05-16)

Every question paid a round-trip: the model called `get_schema` before
writing SQL, adding ~20s to simple lookups (Q01: 94.2s total).

Moved the schema (~600 tokens) into SYSTEM_PROMPT and deleted the tool.
Tool count 6 → 5. Q01 latency 94.2s → 71.2s (~25% reduction).

**Why prompt-injection and not caching the tool result:** the schema changes
only on migration; a cache would add invalidation logic to save tokens the
prompt-cache already deduplicates.

**What it does NOT change:** token spend per answer (cached prefix), eval
scores, tool-call behavior for the remaining 5 tools.

Also incidentally fixed: `tests/test_tools.py::test_tools_schema_well_formed`
was already stale before this change — it asserted `len(TOOLS) == 4` while
TOOLS had 6 entries; the assertion was updated with the real count.

Validation: full pytest **88 passed, 40 skipped** (was 79/40; +9 new, no
regressions).
```

## Eval classification table (when a session ran evals)

```markdown
| ID | Bucket | Result | Read |
|---|---|---|---|
| Q08 | grader brittleness | FAIL → fixed | Bot wrote "1-Year Return"; assertion required literal "1Y". Grader fixed — asserts the concept, not the wording. NOT a bot failure. |
| Q09 | real miss | FAIL → fix landed | Over-refusal: filtered too strictly on 3Y metrics (NULL for funds <3yr) and refused. New no-perfect-fit rule in SYSTEM_PROMPT. |
| Q20 | provider flake | FAIL | Malformed tool call, reproduces across providers. Tracked as deferred item 3. |
```
