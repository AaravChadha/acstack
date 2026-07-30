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
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"
pack_root="$(dirname "$(dirname "$link")")"
[ -n "$link" ] && [ -f "$pack_root/CONDUCT.md" ] || pack_root=""
```

An unresolved `$pack_root` is reported `skipped — copy install`, never
substituted with `.`: `dirname` of an empty string is `.`, which would
compare the project's AGENTS.md against the project's own CONDUCT.md and
call a foreign block current.

Compare the AGENTS.md block against the same block in
`$pack_root/CONDUCT.md`; a diff means stale → show the exact replacement
edit as the fix.

## 3b. Referral roster

```bash
awk '/<!-- BEGIN:acstack-referrals -->/,/<!-- END:acstack-referrals -->/' AGENTS.md
```

Present and matching `$pack_root/AGENTS.md`'s block → ✓. Missing → ✗
with the fix "re-run `/plan seed` (idempotent)". Stale (the pack's
roster names a skill this copy lacks) → ✗ showing the diff. The roster
lists the skills carrying `disable-model-invocation: true`, which an
agent cannot see or invoke — a missing roster silently costs the user
every typed-only skill.

## 3c. One product per repo (info, never a failure)

```bash
find . -name PLAN.md -not -path './.git/*' -not -path './node_modules/*' | head
ls pnpm-workspace.yaml lerna.json turbo.json go.work 2>/dev/null
grep -l '"workspaces"' package.json 2>/dev/null
grep -l '^\[workspace\]' Cargo.toml 2>/dev/null
ls -d apps packages services 2>/dev/null
```

Signals, strongest first: more than one BRIEF/PLAN/JOURNAL below the
root; a workspace marker; `apps/`, `packages/`, or `services/` each
carrying their own manifest.

Report as **info**, worded as unsupported rather than broken — a
monorepo is not misconfigured, it is outside what the pack models. Name
every document set found and say which one the skills would read.
Every acstack skill assumes ONE product per repository; with two, a
`/retro` or `/resume` would confidently report on the wrong one.

## 4. Config

```bash
cat .claude/acstack.md 2>/dev/null || cat "$HOME/.claude/acstack.md" 2>/dev/null
```

Known keys are the config table in the pack's own README — resolve the
pack root through the symlink exactly as in §3 and read
`$pack_root/README.md` (the project's README is a different file and
has no such table). Anything else = info (extension hook). Consistency:
`tracking: tickets` requires all three of

```bash
command -v gh && gh auth status && git remote get-url origin
```

## 5. Secrets

Run ALL commands from the canonical secrets section,
`../../secure/references/security-surfaces.md` §2 Secrets hygiene —
tracked .env-class files, the `!.env` negation trap, the history sweep,
and the two key-shape/assignment greps — appending `| head` where the
checkup wants brevity. Nothing is duplicated here: the copies had
already drifted twice before canonicalization (`ghp_` present in one
copy and absent in the other; a history sweep narrowed to `'*.env'`
while the canonical one also covers `'*secret*'` and `'*credential*'`).

Any hit in history means the secret is burned regardless of the working
tree: the fix line says "rotate the key", not just "remove the file".

## 6. Attribution

```bash
git log -20 --format='%B' | grep -inE 'co-authored-by|generated with|🤖'
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
