# Agent rules — acstack repo

This repo IS the acstack skill pack, so it eats its own cooking: the conduct
block below binds every session here, the roadmap lives in `PLAN.md`, and the
build history lives in `JOURNAL.md`. Read those two before changing anything.

Binding rules for this repo:

- Run `scripts/check.sh` before every commit. A failing guard blocks the
  commit — fix the drift, don't skip the check.
- The `acstack:principles` block is edited ONLY in README.md (canonical),
  then propagated verbatim to every `skills/*/SKILL.md`.
- No client, company, or collaborator names anywhere in pack content. The
  guard reads its list from untracked `.acstack-banned` (see
  `.acstack-banned.example`) and sweeps `scripts/` and `setup` too — the
  list was hardcoded inside check.sh until 2026-07-29, in a repo destined
  to go public, and the sweep excluded its own directory so it could never
  catch itself. When in doubt, genericize.
- Skills stay under 500 lines and plain markdown — no bash preambles until
  the wave-4 runtime lands, and none beyond its documented budget after.
- Commit style: lowercase `<verb> <object> (<detail>)` subject + a brief
  what-and-why body, no attribution trailers. This is a deliberate
  **exception** to CONDUCT rule 10's work-item-referenced subject, not a
  derivation from it — the pack itself has no ticket or task ID per commit.
  Rule 10's no-attribution half still binds.

Verification rules (added 2026-07-29, each from a defect this repo shipped):

- **Verify the consumed form, not the authored form.** The file you wrote is
  not evidence; the thing that reads it is. Check the parsed frontmatter, the
  rendered markdown, the command's actual output — not your own text. `/ship`
  shipped for a whole wave with a YAML-truncated description, losing its
  entire trigger sentence, because it was re-read instead of parsed.
- **Prove a new check fails before trusting that it passes.** Seed the defect
  the check exists to catch and watch it fire. A green check with no
  demonstrated failure mode is decoration. This repo has produced two: the
  `sk-[A-Za-z0-9]{20,}` secret regex that reported clean on a planted key, and
  the description guard whose first positive control passed misleadingly
  because the text it tested had already been fixed.
- **Anything named as needed work gets a carrier task in the same edit.**
  Recording it is not scheduling it. This covers cross-cutting rules,
  proposed skills, deferred fixes — anything a future reader would expect to
  happen. Three rules (multi-product detection, positive controls, the
  commit-subject format) were binding with nobody owning the work until an
  audit found them orphaned; then two proposed skills (refactor safety,
  dependency upgrade) were named in analysis and never scheduled, slipping
  past the first version of this rule because it said "cross-cutting rule"
  and they were skills. If you write that something is needed, either open
  the task or write down that it was deliberately declined.
- **A claim about a set enumerates the set.** "The six read-only skills" was
  written without opening six files, and `/retro` — which appends to
  JOURNAL.md and commits — was in the list. Count it, list it, or don't claim
  it. This applies to your own earlier statements too: in a long session,
  re-read before restating, or you will contradict yourself in writing.

These four are repo-binding, not part of the shipped conduct block. Promote
one into CONDUCT.md only if it proves out across projects — the same bar
`/learn` uses for promoting a lesson into known-bug-classes.

<!-- BEGIN:acstack-referrals -->
## Typed-only skills

These skills carry `disable-model-invocation: true`, so an agent cannot
see or invoke them — it can only mention them. Suggest one when its
column-three condition is true, per conduct rule 9: name it once, never
repeat it, and treat silence or a pivot as a no.

| Skill | What it does | Suggest when |
|---|---|---|
| `/plan` | Frozen BRIEF → written architecture pushback → living PLAN.md with runnable exit criteria | The repo has no PLAN.md (or legacy equivalent) and the user is starting something new — **or** a build request lands in such a repo and the work is not a bounded single-file change (new files, new surface, or multi-file). Never for a one-line fix. Do the work first; make the offer with the end-of-increment status statement, naming concrete options and a recommendation ("spec first in docs/ / a short design sketch / keep building as-is — I'd suggest X because Y"), with one clause of reason: simple-looking work is where unexamined assumptions cost most. Once per session per repo; nothing is recorded, so a later session may ask once more. |
| `/eval-spec` | The eval is the spec: golden set with category minimums, refusal cases, pinned grader — written before the system exists | An LLM-shaped feature is heading into build and no `eval/` exists |
<!-- END:acstack-referrals -->

<!-- BEGIN:acstack-conduct -->
## Agent conduct

These rules bind every session in this repo. Full text: CONDUCT.md in the
acstack pack.

1. The word is the mode. "Explain" = complete explanation, then stop — no
   menus, no actions, no scaffolding in the same turn. "Plan" = design docs
   only. Build only on an explicit go.
2. The user sets the pace. An approved plan authorizes the what, not the
   when. End each increment with a status statement; do not roll into the
   next increment uninvited.
3. Answer what was asked before anything else. The answer is the
   deliverable; don't bury it.
4. Be direct. Push back in writing when the user is wrong. No sycophancy.
5. Don't ask permission for what was requested; don't do what wasn't.
6. Don't relitigate decided things. New evidence gets one plain sentence,
   then the user rules.
7. Surface conflicts between instructions, conventions, or config — never
   silently pick a side.
8. When unsure, ask before starting. Ambiguity is a reason to stop, not to
   guess-and-build.
9. Closing offer-questions are allowed but expectation-free: they often go
   unanswered; silence or a pivot is not consent; offered work waits for
   explicit uptake; never repeat the question. Referrals to typed-only
   skills (the `acstack-referrals` roster) are offers under this rule:
   name one once, never repeat it, and do the requested work first.
10. Commits: short subject starting with the work-item reference
    (`#42: …` in tickets mode; `completed task 3.2.1 (…)` in document
    mode), a brief what-and-why body, and no attribution trailers — no
    Co-Authored-By bots, no "Generated with" footers (per the
    `attribution` config, default none).
<!-- END:acstack-conduct -->
