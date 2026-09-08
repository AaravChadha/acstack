# Agent Skills spec: where acstack diverges, and what it costs you

**Verdict 2026-08-11 — acstack targets Claude Code, and keeps two fields the
Agent Skills spec does not define.** Written down here so you learn it from
us rather than from someone else's validator.

## The two fields

| Field | Used by | Why it stays |
|---|---|---|
| `argument-hint` | every skill | Typed invocation is the primary path here; the hint is what makes `/do 3.2.1` legible in the CLI |
| `disable-model-invocation` | `/plan`, `/eval-spec` | Load-bearing, not cosmetic: `scripts/check.sh` derives the typed-only roster from this field and fails if `AGENTS.md`'s referral table disagrees. Removing it deletes a guard |

## What the spec does constrain, acstack already satisfies

Name and description limits, one-level `references/`, and bodies well under
the "< 5000 tokens" guidance. The 500-line SKILL.md cap this pack enforces
turns out to be the spec's own recommendation, arrived at independently.

## What the divergence costs

The pack cannot be uploaded to claude.ai, consumed through the Skills API, or
packaged with the official `package_skill.py`.

If you need any of those, strip the two fields — you lose the typed-only
roster guard and the CLI hints, nothing else.

**This cost is carried from a 2026-08-07 measurement with the standard's own
validator — 0/23 passing, 23/23 after stripping, at the 23 skills of that
date — and is not re-run by our CI**, which has no dependency on that
validator. Treat the ratio as a dated observation, not a live number.
