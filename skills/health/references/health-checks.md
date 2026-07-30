# Health checks — exact commands

One section per check. Commands are POSIX + git + gh only; every ✗ in
the report quotes the command that produced it, so the user can rerun.

## 1. Docs

```bash
ls BRIEF.md PLAN.md JOURNAL.md 2>/dev/null           # canonical names
ls PLANNING_PROMPT.md PLANNING.md STATUS.md 2>/dev/null  # legacy names
git log -1 --format='%ci %h' -- JOURNAL.md            # journal last touch
git log -5 --format='%ci %h %s'                       # recent work commits
```

Journal is stale when non-journal commits postdate its last touch by
more than a session. PLAN check: the topmost `## [ ]` phase must carry
an `**Exit criterion:**` whose command is literally runnable.

## 2. Pointer

```bash
cat CLAUDE.md
```

Healthy = exactly `@AGENTS.md` (one line). More content → flag with the
proposed move of that content into AGENTS.md; never rewrite it yourself.

## 3. Conduct block

```bash
awk '/<!-- BEGIN:acstack-conduct -->/,/<!-- END:acstack-conduct -->/' AGENTS.md
```

Locate the installed pack root through the symlink (skip with
`skipped — copy install` when not symlinked):

```bash
pack_root="$(dirname "$(dirname "$(readlink "$HOME/.claude/skills/health")")")"
```

Compare the AGENTS.md block against the same block in
`$pack_root/CONDUCT.md`; a diff means stale → show the exact replacement
edit as the fix.

## 4. Config

```bash
cat .claude/acstack.md 2>/dev/null || cat "$HOME/.claude/acstack.md" 2>/dev/null
```

Known keys are the README config table; anything else = info (extension
hook). Consistency: `tracking: tickets` requires all three of

```bash
command -v gh && gh auth status && git remote get-url origin
```

## 5. Secrets

```bash
git ls-files | grep -E '(^|/)\.env(\.|$)'             # tracked .env-class
grep -n '^!' .gitignore 2>/dev/null                   # negation trap
git log --all --oneline -- '*.env' | head -5          # .env in history
```

Key-shape and assignment-pattern greps: run the two `git grep` commands
from the canonical secrets section, `../../secure/references/security-surfaces.md`
§2 Secrets hygiene, appending `| head -10` for checkup brevity. The
`sk[-_]` prefix-class rationale is documented there — the pattern is NOT
duplicated here because the two copies had already drifted once (`ghp_`
present in one, absent in the other).

Any hit in history means the secret is burned regardless of the working
tree: the fix line says "rotate the key", not just "remove the file".

## 6. Attribution

```bash
git log -20 --format='%B' | grep -inE 'co-authored-by|generated with'
```

Hits while `attribution: none` (the default) → ✗, listing the offending
commit subjects. Under `attribution: standard` this check reports info
only.

## 7. Learnings

```bash
git log -1 --format='%ci' -- LEARNINGS.md 2>/dev/null
```

Missing, or older than `stale-days`: info → "capture with /learn". This
check never fails the project.

## 8. Tickets extras (`tracking: tickets` only)

```bash
gh auth status
gh label list --json name --jq '.[].name'    # expect blocked, needs-acceptance, bug, feature, chore
ls .github/ISSUE_TEMPLATE/task.md
gh issue list --state open --json number,updatedAt   # stale count vs stale-days
```

Missing labels/template → ✗ with the fix "re-run /plan's tickets
bootstrap (idempotent)". The stale count is reported as a number and a
pointer to /triage — /health counts rot, it does not groom it.
