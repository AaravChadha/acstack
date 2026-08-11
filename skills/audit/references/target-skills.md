# Target: skills — does this SKILL.md hold up?

Skill-authoring from the verification side. The field's most-recurring
verb is *writing* skills; this is the half nobody ships — checking that
the one you wrote will actually load, resolve, and behave.

**This audits ANY skill, not just an acstack one.** It re-expresses what
`scripts/check.sh` does for this pack so an adopter gets the same
discipline for their own `~/.claude/skills/<name>/SKILL.md`. Do not shell
out to the pack's guard: an adopter's skill is not in this tree.

**No SKILL.md at the named path → say so and stop.** An audit written from
the directory name alone would be fiction, the same way an eval audit
without a results file would be.

Output opens with the verdict — `skill is sound` or `<N> findings` — then
the evidence as `file:line`, then scope: which of the seven classes below
were checked and which could not be.

## The seven classes

**1. Frontmatter that YAML will truncate.** The highest-severity class,
because it fails silently and the skill still appears to load.

| Hazard | What YAML does |
|---|---|
| unquoted value containing ` #` | everything after it becomes a comment |
| unquoted value containing `: ` | ambiguous; may parse as a nested map |
| value starting with `#` | the whole value reads as null |
| an unterminated quote | the block runs into the body |

```bash
grep -nE '^description:[[:space:]]*[A-Za-z].*( #|: )' path/to/SKILL.md
grep -nE '^description:[[:space:]]*#' path/to/SKILL.md
```
The leading `[^"''' ]` is load-bearing: a QUOTED value may legitimately
contain `: `, and a grep without it flags correct skills. That false
positive was caught here by a negative-twin fixture, not by inspection.

A description that lost its tail is the defect this pack shipped for a
whole wave — `/ship`'s trigger sentence vanished at "wiring Fixes #N" and
nothing failed. **Verify the PARSED form, not the file**: read back what a
YAML parser returns, not what you wrote.

**2. `name:` must equal the directory name.** They are matched on disk;
a mismatch means the skill never resolves.

```bash
grep -nE '^name:' path/to/SKILL.md      # compare to basename $(dirname ...)
```

**3. The description is the whole trigger surface.** It is loaded at
EVERY session start, for every user, forever — the only cost here that
grows monotonically. It must say what the skill does *and* when to use
it; a description with no "use when" clause is a skill the model never
reaches for. Report its char count, and flag anything over ~600 chars as
eating a shared budget.

**4. Body budget.** Under 500 lines — which is both this pack's cap and
the Agent Skills spec's own recommendation, arrived at independently.
Over that, the fix is progressive disclosure, not deletion.

```bash
wc -l path/to/SKILL.md
```

**5. Every citation resolves.** A `references/<name>.md` in a SKILL.md
resolves from the skill directory; the same citation *inside* a reference
file also resolves from the skill directory, not from `references/`. A
`../other-skill/...` path gains a level when the citing file moves into
`references/`. Check the extension you are not thinking of — a named
extension list is a denylist, and this pack shipped a dead `.py`
citation for exactly that reason.

```bash
grep -noE '(references/|\.\./)[A-Za-z0-9._/-]+\.[A-Za-z0-9]+' path/to/SKILL.md
```

**6. `allowed-tools` honesty.** The declaration governs what the model is
OFFERED, never what it is prevented from doing. The finding is a skill
that declares a read-only tool set and then instructs the reader to
write, commit, or push. Compare the declaration against the verbs in the
body — this one is judgment, not grep.

**7. Conditional-branch waste.** Mutually exclusive `## Mode:` /
`## Target:` sections are loaded whole and mostly discarded. Report
wasted lines per invocation, not percentage: percentage flags a skill
that was already split correctly, because the pointers it keeps are
themselves conditional content. `scripts/conditional-ratio.sh` in this
pack is the same measurement if you want a number.

## What this target does NOT do

It does not run the skill, and it does not prove the model obeys it.
Every class above checks a *declaration* — that the frontmatter parses,
that a file exists, that a rule is written down. Whether a model actually
halts where the skill says halt is behavioural evidence, and only a live
run produces it. Say so in scope rather than implying the audit covered
it.
