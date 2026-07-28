# Eval review rules

## The classification buckets

Every failure lands in exactly one. **The "Recommended remedy" column is
what to RECOMMEND, not work /audit performs** — /audit reports and never
fixes (SKILL.md). Where a bucket says "fix", the report names the fix and who
would apply it; the user decides, and any fix lands as its own reviewable
commit.

| Bucket | Meaning | Recommended remedy |
|---|---|---|
| prompt issue | The subject misbehaved because its instructions are wrong/ambiguous | Fix the prompt, re-run |
| grader brittleness | The subject was right; the assertion was too literal | Fix the grader (see below) |
| provider flake | Infra/API failure unrelated to the subject (malformed tool call, timeout, rate cap) | Track, retry policy, defer |
| data issue | The expected value itself is wrong at the source | Fix the source data |
| parser issue | Upstream extraction fed the subject bad data | Fix the parser, re-ingest, re-run |
| genuinely ambiguous | Reasonable readings disagree | `acceptable_failure: <written reason>` — the ONLY bucket that may survive unremedied |

`FAIL → fixed` notation for resolved failures; a "Read" column carries the
interpretation, not just the verdict.

## The never-inflate rule (absolute)

Never fix, tune, or delete a test or eval case to raise a score. The
canonical precedent: a subject rated a preservative-heavy serving `low` risk
vs an expected `moderate` — a defensible per-serving interpretation — and
the case was **left unchanged to keep the number honest**. 29/30 with an
explained miss is worth more than 30/30 with a massaged case.

Grader fixes are NOT inflation when they make the assertion test the
*concept* rather than the wording: substituting substring sets that assert
the computation happened for literal formatting checks; Unicode-normalizing
U+202F narrow spaces and en-dashes before compare. Log every grader change
and label it as such — the line between grader fix and score massage is
whether the *subject's behavior* was actually correct.

## Report format

Headline number first (`29/30 checks (96.7%)`), then methodology **with its
rationale** ("substring-based and case-insensitive — we test whether the
concept is captured, not the exact wording, because phrasing varies across
temperature runs"), then per-dimension table, per-case detail with ✓/✗
assertion lines, failures preserved with their interpretation.

## Audit checks on someone else's eval report

- Recompute the headline from the raw results file; mismatches are findings.
- Diff test cases against git history: any expected-value edit that
  coincided with a score improvement gets flagged and must justify itself.
- Every `acceptable_failure` must carry a reason a stranger would accept.
