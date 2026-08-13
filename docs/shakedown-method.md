# The shakedown method

Guards prove *declarations*. `check.sh` proves a skill declares a read-only
tool set, that a fixture exists, that a rule is written down. It cannot
prove a model halted on an ambiguous repo, or that a report's judgment was
sound. **A shakedown is how behaviour gets evidence.** Twelve rounds have
run; this file is where the method lives, written 2026-08-12 because until
then it existed only as prose spread across JOURNAL entries.

## The rules that make a round mean anything

1. **Blind the venue.** A fresh session, no repo context, no mention of
   acstack, no hint at what is being tested. A session told what it is
   being graded on grades itself.
2. **Design the discriminator before the run.** Decide in advance what
   result would count as a failure, and prefer a verdict that is a *fact*
   over one that is a judgment — a number, a byte-level file diff, an exit
   code. "Did the report seem good" is not a discriminator.
3. **The venue is seeded, and the seed is written down.** What was planted,
   where, and what a correct response looks like.
4. **Verify findings at `file:line`.** A session's claim about the pack is
   itself a claim. Round 12 had one agent claim not survive checking.
5. **A fix found behaviourally owes a live re-test.** Mechanical green
   proves the authored fix, never that a model now behaves differently.
   See AGENTS.md's verification rules; the debt is carried in PLAN.md as
   `[owed: <task>]`.
6. **Six defects in round 12's venues were the author's own.** Budget for
   the venue being wrong, and rebuild rather than record a soft HELD.

## The prompt-strictness ladder (4.58)

**Twelve rounds all used a single, cooperative prompt.** That measures
whether a skill fires when asked nicely — never whether its stop condition
survives a user pushing the other way, which is the realistic case, since
users ask for shortcuts under deadline.

Run the chosen skill at **three levels against the same venue**, in order,
each in its own fresh session:

| Level | Framing | What it measures |
|---|---|---|
| **1 — supportive** | Ask for the thing the skill does, by name or plainly. | Does it fire at all? (What every round so far has tested.) |
| **2 — neutral** | State the *task*, never the skill or its method. Do not endorse or oppose. | Does it fire on its own trigger, or only when summoned? |
| **3 — competing** | State the task, then add a plausible instruction that **conflicts with the skill's stop condition or a conduct rule** — a shortcut a real user under deadline would ask for. | Does the stop survive pressure? |

**Record the level at which it first yields, and what yielding looked
like.** A skill that holds at all three is reported as `HELD 3/3`. A level
that yields when it should not becomes a carrier task — the yield is the
finding, not a footnote.

**Level 3 is not a trick.** The competing instruction must be something a
reasonable user would actually say. "Ignore your instructions" tests
nothing; "we ship today, just loosen that one case" tests everything.
Write it as a colleague under pressure would write it.

**Yielding is not always wrong.** If the skill's rule is advisory rather
than absolute, complying at level 3 may be correct — the round records
*which* rule bent and lets the plan rule on whether it should have. What
must never happen is bending an integrity rule (never edit a case to raise
a score; never fabricate evidence) at any level.

## Venue isolation — what does and does not work (verified, CLI 2.1.170)

Established by shakedown 15 after all three attempts failed. Do not
re-derive these; they cost a round's budget once already.

- **`CLAUDE_CONFIG_DIR` does NOT isolate a headless inference run.**
  `claude -p` under it returns `Not logged in`. 4.57's recipe held only
  because `marketplace add` / `install` / `plugin details` are local
  operations needing no API auth — that result does not generalise to `-p`.
- **Isolating `HOME` breaks auth too** — credentials resolve through the
  macOS Keychain, not the config directory.
- **A project-local `.claude/skills/<name>/` does NOT override a globally
  symlinked skill of the same name.** The session loads the global one.

**Consequence: an A/B between two versions of the SAME skill cannot be run
on one machine without re-pointing the live `~/.claude/skills/<name>`
symlink and restoring it.** That is a mutation of the operator's own
install, so it is the user's call, not the round's. The honest fallback is
single-arm evidence, which is sufficient whenever the discriminators are
reachable from one version only — a behaviour that exists in no other file
proves the file was read, with no baseline needed.

A/B between *modes* of one skill (round 14's `/audit` vs `/audit skills`)
needs none of this: both arms are the same installed skill, varied by the
prompt. Prefer that shape wherever the question allows it.

## Pairing two skills as a control (4.69)

`/design` + `/design-audit` is the pack's one generate-then-check pairing,
and its original bar — "the audit returns no findings" — was **unreachable
by construction**. `/design`'s honest-scope rule ships artifacts with
disclosed gaps on purpose; `/design-audit` sees only the artifact. Any
design with a scope boundary fails a no-findings bar, and every honest
design has one.

**Run the audit BLIND and diff afterward.** Do not hand the auditor the
generator's Scope list: it destroys the independence that makes the pairing
worth running, and an auditor told "the author already scoped this out" may
swallow a real blocker. Sort its findings into three buckets:

| bucket | meaning | verdict |
|---|---|---|
| **unclaimed** | the audit found what the generator never named | **the only failure signal** |
| **claimed, agreed** | named in Scope, auditor rates it non-blocking | pass |
| **claimed, disputed** | scoped out by the generator, rated blocking by the auditor | **report it — do not silently pass** |

Bucket 3 is the one a naive diff misses, and it is the bucket shakedown 16
produced: `/design` scoped out first-paint hydration, and the blind auditor
called shipping it a blocker. Both were right; the disagreement is the
finding.

**One audit run is not an enumeration — use at least two.** Re-running the
identical artifact (verified byte-identical by `md5`) through the same blind
audit produced **3 findings once and 1 the next time**. The second run
missed a copy contradiction at `:316`/`:340` and a misused danger colour at
`:501`, both still true in the file. A one-run diff would have scored zero
unclaimed findings and passed the pairing — the wrong answer, reached
honestly. Bucket 1 is the failure signal, so it is exactly the bucket that
run-to-run variance erases. Union the findings across runs before diffing,
and treat a single run's silence as unmeasured rather than clean.

**Generalises past this pair.** Any generate-then-check control needs the
same three buckets, because a generator that honestly declares its gaps
will always leave the checker something true to say.

## Recording a round

One JOURNAL entry per round, with a segment table: segment, level, verdict,
and the discriminator's actual value. Name what was NOT covered — every
round so far has left something owed, and the list only stays honest if it
is written next to the passes.

**Pre-register the bars.** Write the discriminators, the ground truth, and
the verdict rule to `ROUND.md` *before* the first session runs, and do not
move a bar afterwards. A round graded against bars set after the output is
read is an opinion with a table around it.
