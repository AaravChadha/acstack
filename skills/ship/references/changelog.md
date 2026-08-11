# Changelog entry — propose it, never commit it

`/ship` cuts releases and, until 4.64, wrote no changelog. This is the
missing half. It runs **after all five gates pass**, as part of the act.

**The entry is PROPOSED. It is never committed or pushed without the user
saying so** — a changelog is outward-facing text with the user's name on
it, and the same rule that stops `/ship` inventing a PR step stops it
writing release prose unasked. Print the entry, say where it goes, and
stop.

## Where the facts come from

Two sources, and they are not interchangeable:

| Source | Gives you | Never gives you |
|---|---|---|
| `git log <last-tag>..HEAD` | the exact range, the work-item refs, what actually landed | why a reader should care |
| `JOURNAL.md` entries in that range | the reader-facing framing, the numbers, the decisions | a complete list — a session can land work it does not journal |

**Use both.** Commits bound the range and prove nothing was missed;
the journal supplies the sentence a reader wants. An entry written from
commit subjects alone reads like a diff; one written from the journal
alone silently drops whatever went unjournaled.

```bash
git describe --tags --abbrev=0 2>/dev/null || echo "(no tag yet — use the first commit)"
git log <range> --format='%h %s'
```

**No tags yet?** Say so and use the range the user names. Do not guess a
release boundary — inventing one produces an entry that overlaps or skips
the previous release, and nobody notices until the next one.

## Shape

Match the project's existing `CHANGELOG.md` exactly — read it first and
copy its conventions rather than importing Keep-a-Changelog by reflex. If
the file does not exist, propose Keep-a-Changelog and say that is what you
are doing.

Read from the file, not from memory: the heading level, whether versions
carry dates or a status word, and whether entries are grouped by kind
(`### Added`) or by theme.

**Group by what changed for the reader, not by commit.** Five commits that
build one capability are one bullet. A commit that fixed a defect
introduced in the same range is not a bullet at all — the reader never saw
the defect.

**Lead each bullet with the noun.** `**New skill:** /why — decision
archaeology…` beats `Added a skill called /why which does…`. A changelog
is scanned, not read.

**State upgrade actions in the entry, not below it.** If a user must do
something after pulling — re-run an installer, re-index, migrate — that
belongs in the bullet where they will hit it. This pack shipped `/why` to
nobody because a pull left it unlinked and the instruction was elsewhere.

## Work-item references

- **Tickets mode:** commits carry `#N`. Cite the issue where it adds
  context; do not paste a bare list of numbers.
- **Document mode:** commits carry `task N.N`. Task IDs are internal —
  translate them into what the user got, and keep the ID out of the entry
  unless the project's own changelog already uses them.

## What NOT to write

- Attribution of any kind, per the `attribution` config (default `none`) —
  no tool mentions, no generated-by footers.
- Adjectives standing in for numbers. "Significantly faster" is not an
  entry; "94.2s → 71.2s" is.
- Anything the range does not contain. If a bullet cannot be traced to a
  commit in the range, it does not go in — that is how a changelog starts
  describing intentions.
- A version bump. `/ship` does not decide the version; the project does,
  and this pack's `scripts/check.sh` enforces `VERSION` against the first
  heading.
