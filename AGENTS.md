# Agent rules — acstack repo

This repo IS the acstack skill pack, so it eats its own cooking: the conduct
block below binds every session here, the roadmap lives in `PLAN.md`, and the
build history lives in `JOURNAL.md`. Read those two before changing anything.

Binding rules for this repo:

- Run `scripts/check.sh` before every commit. A failing guard blocks the
  commit — fix the drift, don't skip the check.
- The `acstack:principles` block is edited ONLY in README.md (canonical),
  then propagated verbatim to every `skills/*/SKILL.md`.
- No client, company, or collaborator names anywhere in pack content — the
  guard enforces a banned list; when in doubt, genericize.
- Skills stay under 500 lines and plain markdown — no bash preambles until
  the wave-4 runtime lands, and none beyond its documented budget after.
- Commit style: lowercase `<verb> <object> (<detail>)` subject + a brief
  what-and-why body, no attribution trailers (CONDUCT rule 10).

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
   explicit uptake; never repeat the question.
10. Commits: short subject starting with the work-item reference
    (`T4: …` / `#42: …` per tracking mode), a brief what-and-why body,
    and no attribution trailers — no Co-Authored-By bots, no
    "Generated with" footers (per the `attribution` config, default none).
<!-- END:acstack-conduct -->
