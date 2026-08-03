---
name: design-audit
description: Static UI convention check - off-palette colors and wrong product-name casing, dishonest data labels (AI-generated or mock data shown as real), AI-slop (lorem remnants, hedge copy, emoji headings, uniform gradient grids), and client-facing language leaks. Reports file:line findings with fixes; conventions come from config layered over pack defaults. Use when the user asks to design-audit or check UI conventions, polish, or copy.
argument-hint: "[path | notes]"
allowed-tools: Read, Grep, Glob, Bash(grep:*), Bash(ls:*)
---

# /design-audit — conventions, honesty, and slop

A static pass over the UI's code and copy for the things reviewers skim
past: colors off the palette, mock data wearing a real-data face, the
tells of machine-generated filler, and internal language leaking to the
user. Nothing is rendered — a rendered mode arrives with the browser
probe (same deferral as /qa, decision 2026-07-27).

`Adjacent skills:` /qa (behavior; /design-audit is look and language) ·
/audit code (correctness; /design-audit is convention) · /secure
(exploitability; /design-audit flags leaked internals as language, not
as a vulnerability).

<!-- acstack:runtime -->
Run before the skill's steps — per invocation, not per session (4.36); failures degrade to markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; silent ONLY if already checked today
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + bug-class names, capped 3KB
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

## Conventions come from config

Read a `## design-audit` section from `.claude/acstack.md`:

- `palette:` — the allowed hex values; colors outside it are findings.
- `banned-palette:` — hex values that are findings wherever they appear,
  even if someone adds them to `palette`. Defaults to the violet-gradient
  family that generated UI reaches for (`references/ai-tells.md`).
- `product-names:` — exact casings; other casings are findings.

Config always wins over the brand-neutral defaults in
`references/design-conventions.md`. No config → use the defaults and say
so in scope: "no palette configured; flagged only obvious raw-hex
sprawl, not brand conformance."

## The four checks

Grep families and the default convention set live in
`references/design-conventions.md`. Apply them with the Grep tool — this
skill grants no shell `git grep`. No Grep tool? Use `grep -rnE`, never
`git grep`.

1. **Palette + branding.** Hardcoded colors outside the configured
   palette; product names in the wrong casing; spacing/font literals
   diverging from the project's own design tokens where tokens exist
   (a raw `#3b82f6` beside a `--color-primary` token is the finding).
2. **Honest data labels.** AI-generated, illustrative, sample, or mock
   data shown without saying so; a chart of fabricated numbers presented
   as real. The honest-measurement principle applied to pixels — the
   same stance /audit eval takes toward scores.
3. **Slop detection.** Placeholder/lorem remnants, emoji-decorated
   headings in product UI, uniform gradient-card grids, hedge copy
   ("simply", "just", "seamlessly", "powerful", "effortlessly"),
   user-visible debug strings (`console.log`, `TODO`, `FIXME` in
   rendered text).
4. **Client-facing language.** Internal jargon or codenames in UI
   strings; error messages exposing internals (stack traces, table
   names, file paths) — cross-referenced to /secure when they leak
   system detail; inconsistent terminology for the same object across
   screens ("order" here, "purchase" there).
5. **AI tells.** The signature of generated UI — violet gradients,
   eyebrows, fabricated statistics, motion and materials violations,
   interaction-feel misses. Rules and greps in `references/ai-tells.md`.

**Severity order is fixed: accessibility, then honesty, then everything
else** — regardless of how many hits each class produced. Unreadable text
and a fabricated statistic are harm; a gradient is embarrassment. One tell
is a choice; the full set is a signature, so say which it was.

**No UI files in the path → say so and stop.** If the target contains no
markup, styles, or component files, there is nothing to audit; report the
path, what was looked for, and stop. A "CLEAN" verdict over a directory
with no UI in it is a true statement that reads as a false reassurance.

## Stance and report shape

Read-only: findings and suggested fixes, never applied edits. First
line is the verdict: `CLEAN` or `<N> findings`. Then:

- **Findings**, grouped by the four checks: `file:line` · the
  convention violated · the suggested fix.
- **`Safety checks:`** the exact greps run.
- **Scope:** paths covered; static-only stated; whether a palette was
  configured or defaults were used.
