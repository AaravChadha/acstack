# Target: readme — the front door as a stranger meets it

`/audit docs` checks the README against the tree: stale counts, absent
skills, checkbox reality. This target asks the different question — whether
the document *works on someone who has never seen the project*. A README can
be entirely accurate and still fail that.

Read it top to bottom once, as a stranger, before running a single check.
The findings below are what to look for on the second pass.

## The bar is measured, not asserted

Every threshold here comes from six comparator READMEs above 100k stars,
fetched live and measured on 2026-09-16: `anthropics/skills`,
`obra/superpowers`, `github/spec-kit`, `ohmyzsh/ohmyzsh`, `n8n-io/n8n`,
`langchain-ai/langchain`. Re-measure before quoting these as current —
a number copied from a doc is the thing this pack exists not to do.

**Count the same way the field was counted, or the numbers mean nothing.**
Lines: `wc -l`. H2 sections: `## ` at line start **outside** fenced blocks —
a heading inside a code fence is not a heading, and counting raw `^## `
overstated this pack's own README by one. Table rows: lines starting `|`,
**excluding** the `|---|` separators. Prose measures strip fenced code,
HTML, tables, headings and link URLs first. An unstated method is how two
honest measurements disagree.

| Dimension | The field | Why it matters |
|---|---|---|
| Length | 96–346 lines | Past ~350, every comparator adds navigation |
| H2 sections | 4–12 | More than 12 and the outline stops being scannable |
| Table rows | 0–19 (four of six have none) | Rosters are where density hides |
| First code fence | 21–38% into the doc | Later than that, the reader leaves before seeing it work |
| Install heading | 12–24% in | An install a reader has to hunt for is a install they don't do |

## The nine checks

1. **Who is this for, in the first screen?** Not what it does — who. A
   stranger deciding whether to keep reading is asking whether they are the
   audience. Absent → finding, with the line where it should go.
2. **Who is it NOT for?** Rare and valuable: only one of six comparators
   has it. If the project has one, protect it in a rewrite; the instinct to
   cut it is wrong.
3. **More than one way in.** A single worked example serves only the reader
   whose problem resembles it. `spec-kit` splits its front door into build /
   fix-a-bug / assess-an-idea. Name the entry paths the project's own skills
   already support; do not invent a flow that has no skill behind it.
4. **Install reachability.** Report the line and the percentage. Under 25%
   is fine; deep in the document is a finding.
5. **Roster completeness.** Every shipped skill appears, and every named
   skill exists. Derive both sides — `ls skills/` against the roster —
   never eyeball it. Two shipped skills were missing from this pack's own
   README for 19 days.
   **Follow the link first.** A README may summarise and link the full
   roster rather than inline it; that is a legitimate structure, and
   comparing `ls skills/` against the README *alone* then produces a
   guaranteed false finding for every skill that lives only in the linked
   file. Resolve any "full roster" link and count the union. Report a
   missing skill only when it appears in neither. (This pack's own README
   moved its roster to `docs/SKILLS.md` on 2026-09-17, and the first draft
   of this check would have flagged four skills that were never missing.)
6. **Stated counts and capability claims match the tree.** Both halves, and
   the count half stays here rather than being delegated.
   **Counts:** every number the README asserts — skills, checks, targets —
   is re-derived from the tree, including marked `count:` markers. `/audit
   docs` also checks these across the whole doc set; that overlap is
   deliberate, because a reader meets the front door without running the
   other target, and a stale number here is read by strangers first. An
   earlier draft delegated this and would have made the acceptance
   unsatisfiable: the seeded fixture carries a contradictory marker and the
   finding must come from *this* procedure.
   **Capabilities:** a claim like "nothing leaves your machine except X and
   Y" is checked against what the tree can actually run — every skill, not
   the ones the sentence happens to name, and including anything a shared
   runtime preamble does on invocation. This pack's own network claim was
   one command out of date for a month while a guard elsewhere had already
   admitted the command, and then still omitted a per-invocation fetch after
   being corrected twice.
7. **Density.** Count H2s, table rows, and total lines against the table
   above. Report the three largest sections by line count and the largest
   tables by row count — those are where the length is, and a rewrite that
   trims prose instead of rosters will make the document worse.
8. **Prose texture.** Compressed prose reads as blurted fragments, and it
   is measurable: em-dashes per 100 words of prose (strip code fences,
   tables, headings, and link URLs first). The field runs **0.0–0.2**.
   Above ~0.5 means clauses are being stacked into sentences with dashes
   rather than written as sentences.
   **The fix is the opposite of "shorten".** Over-compressed prose needs
   words *spent* unpacking it; the length comes out of the rosters in
   check 7. Report the em-dash rate, the mean and maximum sentence length,
   and quote the three densest sentences so the author can see the texture
   rather than argue with a number.

9. **Shadowed names are disclosed, and disclosure is not the same as
   discoverability.** Where a skill's name collides with a host built-in,
   the README must say so — but saying "these two shadow built-ins" is not
   enough on its own. Check whether the document tells the reader **which
   implementation answers** when they type the name, and whether the host's
   own listing shows the two indistinguishably. A flat list carrying the
   same name twice with no source label is a discoverability defect even
   when reachability is fine, and the front door is where a stranger meets
   it. Report what the document claims and what it leaves unsaid; if which
   one wins is genuinely unmeasured, that is the finding — do not guess it
   from a symlink.

## Report shape

Findings first, each with `file:line`, ordered by how decidable they are —
the counted ones (4, 5, 6, 7, 8) before the judged ones (1, 2, 3, 9), same
discipline `/deps` uses. State the measured value beside each threshold so
a reader can overrule the judgment. Close with what was **not** checked:
rendering (this reads source, not the rendered page), link liveness, and
anything requiring a browser.

## What this target must not do

- **Never rewrite.** `/audit` reports; the author edits. A README carries
  the project's voice, and a skill that rewrites it produces six projects
  that sound the same.
- **Never invent an entry path**, a target audience, or a tagline. A
  missing "who this is for" is a finding, not a prompt to write one.
- **Never treat the comparator numbers as rules.** They are what six
  popular projects happen to do. A project that deliberately diverges —
  hard-wrapped prose for diffable pull requests, say — is making a choice,
  and the finding is only that the choice is undeclared.
