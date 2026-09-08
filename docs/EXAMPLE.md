# A worked session

A real session on a small Python project, recorded end to end. Every command
was run and every output pasted verbatim. The project counts word
frequencies; the plan says what "correct" means.

The defect blocks only reproduce *before* the fix — that is the point of
showing them — so each is labelled with the state it runs against. The short
hashes are from the scratch project this was recorded in; they label the two
states, not commits you can check out. The commands use double quotes
throughout so they survive copy-paste — an earlier version of this page did
not, which is exactly the kind of thing this pack exists to catch.

## Task 1.1.1 — `/do` runs the acceptance line before doing the work

```
$ python3 -c "from wordfreq import top_words; assert top_words(\"don't don't stop\")[0] == (\"don't\", 2); print('acceptance PASSES before any work')"
acceptance PASSES before any work
```

It already passes — the tokenizer's character class includes the apostrophe,
so the task was written against a bug that does not exist. The box is ticked
with a verdict and **no code is written**.

A runnable acceptance line can tell you the work is unnecessary; prose
criteria never do.

## Task 1.1.2 — real work

Quoted words count as separate words (before the fix):

```
$ python3 -c "from wordfreq import top_words; print(top_words(\"'the' the the\"))"
[('the', 2), ("'the'", 1)]

$ python3 -c "from wordfreq import top_words; assert top_words(\"'the' the the\") == [('the', 3)]" 2>&1 | tail -1
AssertionError
```

Fix: strip surrounding quotes, keep internal ones. Both acceptances after the
change:

```
$ python3 -c "from wordfreq import top_words; assert top_words(\"'the' the the\") == [('the', 3)]; print('PASS')"
PASS
$ python3 -c "from wordfreq import top_words; assert top_words(\"don't don't stop\")[0] == (\"don't\", 2); print('PASS')"
PASS
```

The second is 1.1.1 re-run — the earlier task still holds.

## The commit

Plan and code commit together, locally:

```
$ git log --oneline
f054971 completed task 1.1.2 (strip surrounding quotes from words)
fa331d6 add plan
dfd3459 add wordfreq
```

`/do` never pushes — publishing is `/ship`'s job, behind five gates.

## What comes next

`/resume` to catch up after a break, `/investigate` when something breaks,
`/audit code` before you trust a change, `/secure` before you ship it.
Nothing runs on its own — you type it.
