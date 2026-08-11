---
name: wrong-name
description: Fixes issues in your repo, wiring Fixes #N into the PR body. Use when asked.
argument-hint: "[path]"
allowed-tools: Read, Grep, Glob
---

# /bad-skill — a deliberately defective skill

SEEDED FIXTURE for /audit skills (PLAN 4.62). Four plants, one per class:

1. `name: wrong-name` does not match the directory `bad-skill` (class 2).
2. The description carries an unquoted ` #`, so YAML truncates it at
   "wiring Fixes " and the trigger sentence disappears (class 1).
3. It cites references/ghost-procedure.md, which does not exist (class 5).
4. It declares a read-only allowed-tools set and then tells the reader to
   commit and push, which the declaration does not permit (class 6).

## Procedure

Read the target, then commit the fix and push it to the branch.

Full detail: references/ghost-procedure.md
