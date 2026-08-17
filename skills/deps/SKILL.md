---
name: deps
description: "Dependency hygiene review - for each declared package, whether it is imported at all, whether the standard library or an existing dependency already does its job, whether it is still maintained, and whether its license fits the project's. Reports findings against the manifest line, ordered by how decidable each one is, and never edits the manifest. Use when the user asks to review dependencies, check what a package is for, or audit the manifest."
argument-hint: "[review]"
allowed-tools: Read, Grep, Glob, Bash(cat:*), Bash(ls:*), Bash(git ls-files:*), Bash(npm view:*)
---

# /deps — what did we take on, and does it earn its place

Agents add packages reflexively. Nothing else in this pack looks at what
accumulated. This skill is read-only: it has no Edit, no Write, and no
install or update command. It reports; the operator decides.

`Adjacent skills:` /secure (vulnerabilities in what you depend on; this
covers whether you should depend on it) · /contract-check (breaking changes
in your own surface; this covers your suppliers).

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

## Mode: review (the default)

Four checks, and **the order is the point**. They are listed most-decidable
first, and the report must preserve that order and that framing — a judgment
call printed beside a fact, in the same voice, reads as a fact.

### 1. Never imported — decidable, stated flatly

For every declared dependency, search the tree for an import, require, or
other use site. A package with zero use sites is dead weight: the finding is
certain, and it is the only one stated without hedging.

Search the source, not the lockfile. Exclude the manifest itself — a package
naming itself in `package.json` is not a use site. Report the package, its
manifest line, and the fact that no site was found.

### 2. The standard library already does this — evidence, then judgment

Name the stdlib call that replaces it, so the reader can disagree. "This is
`Object.assign`" is checkable; "this seems unnecessary" is not.

Only claim it when the replacement is a genuine one-liner. A package that
handles edge cases the stdlib call does not is a real dependency, and saying
otherwise burns the reader's trust in the other three findings.

### 3. Unmaintained — a date, never an adjective

Read the registry (`npm view <pkg> time.modified`) and report the **date**.
The bar is no release in over two years; state the date and let the reader
apply their own bar.

**If the registry cannot be reached, say the check did not run.** Do not
infer staleness from a version number, a lockfile, or vibes. A skipped check
named is honest; a guessed one is the confident-wrong answer this pack
exists to prevent.

### 4. License conflict — both licenses named

Read the project's declared license and each dependency's from its installed
metadata. Report the pair — `project MIT vs dep GPL-3.0` — never a verdict
like "incompatible" on its own. Licence compatibility is a legal judgment;
the skill's job is to surface the pair that needs one.

## Report

Verdict first: the count of findings, or `no findings`. Then one section per
check that fired, each finding carrying **the manifest line**. A dependency
that passes all four is not listed — but the report states how many were
examined, so a reader can tell a clean manifest from a short one.

State what was not checked: dependencies whose registry lookup failed,
ecosystems the pass did not cover, and transitive dependencies, which are
out of scope here.

## Hard rules

- Never edits the manifest, the lockfile, or any dependency.
- Check 1 is the only one stated as fact; 2 through 4 carry their evidence so
  the reader can overrule them.
- No finding without its manifest line.
- A registry lookup that failed is reported as not-run, never as a pass and
  never as staleness.
- `no findings` means the four checks found nothing, not that the dependency
  set is good.
