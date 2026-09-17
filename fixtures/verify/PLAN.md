# PLAN — wordcount fixture

A deliberately tiny project, so `/verify` has a real acceptance command to
run rather than a diff to read. Three claims are made against it in
`CLAIMS.md`; exactly one is true, one is half true, and one is false.

## [ ] Phase 1 — counting

- [x] **1.1** `wc.py count` reports the number of words in a string.
  **Acceptance:** `python3 wc.py count "a b c"` prints `3`.
- [x] **1.2** Contractions count as one word, not two.
  **Acceptance:** `python3 wc.py count "don't stop"` prints `2`.
- [x] **1.3** `wc.py longest` reports the longest word.
  **Acceptance:** `python3 wc.py longest "a bb ccc"` prints `ccc`.
