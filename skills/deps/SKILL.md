---
name: deps
description: "Dependency hygiene review - for each declared package, whether it is imported at all, whether the standard library or an existing dependency already does its job, whether it is still maintained, and whether its license fits the project's. Reports findings against the manifest line, ordered by how decidable each one is, and never edits the manifest. The upgrade mode pre-flights a version bump against this repo's call sites and ends GO/NO-GO. Use when the user asks to review dependencies, check what a package is for, audit the manifest, or ask whether an upgrade is safe."
argument-hint: "[review | upgrade <package> <target-version> [<unpacked-target-dir>]]"
allowed-tools: Read, Grep, Glob, Bash(cat:*), Bash(ls:*), Bash(git ls-files:*), Bash(npm view:*)
---

# /deps — what did we take on, and does it earn its place

Agents add packages reflexively. Nothing else in this pack looks at what
accumulated. This skill is read-only: it has no Edit, no Write, and no
install or update command. It reports; the operator decides. Two modes:
`review` (the default) asks whether each dependency earns its place;
`upgrade` asks whether a version bump is safe to take.

`Adjacent skills:` /secure (vulnerabilities in what you depend on; this
covers whether you should depend on it) · /contract-check (breaking changes
in your own surface; this covers your suppliers) · /migrate-check (the same
gate shape, applied to the database).

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

## Mode: upgrade

`/deps upgrade <package> <target-version> [<unpacked-target-dir>]` — is this
version bump safe to take? Upgrading is a breaking-change problem, not a
justification problem:
the question is which changelog entries between the pinned and target
versions break a call site **this repo actually has**. A breaking change in
an API nothing here calls is not a blocker, and saying so is the value.

Full procedure: `references/upgrade.md` — where the pinned version, the
target's metadata and its changelog are read from (a local tree or the
registry; this skill has no network tool beyond `npm view`, so a changelog
is never fetched), the classification table, transitive bumps, the rollback
pin, and the report shape. The report anatomy is
`../migrate-check/references/gate-shape.md`: verdict first, every entry
classified, a safe alternative per destructive row, never fix, and state
what the verdict does not cover.

**Verdict rule.** `NO-GO` when any breaking entry has an affected call site
and no migration note names that site and its replacement; otherwise `GO`.
A migration note is a concrete plan per site — "we'll deal with it" is not
one. A changelog that cannot be read is a `NO-GO` naming the missing fact,
never a `GO` on the assumption that nothing changed.

## Report

Verdict first: in review, the count of findings or `no findings`; in
upgrade, `GO` or `NO-GO` as the literal first line. The review report then
carries one section per check that fired, each finding with **the manifest
line**. A dependency that passes all four is not listed — but the report
states how many were examined, so a reader can tell a clean manifest from a
short one. The upgrade report's sections are listed in
`references/upgrade.md`.

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
- Upgrade: the word BREAKING decides nothing — call sites decide, and every
  affected one is cited `file:line`.
- Upgrade: the rollback pin is the exact installed version, named in every
  report; a manifest range is not a pin, and is reported as a range.
