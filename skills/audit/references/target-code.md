# Target: code — defect hunt

Hunt defects in the named path, diff range, or PR. Consult
`references/known-bug-classes.md` — check every class that applies to the
stack. **Check the do-not-flag list in
`references/code-report-template.md` before writing any finding.** Report
per that template:

- **Lede** — the verdict with concrete evidence (a failing input, a number),
  never adjectives.
- **Numbered sections**, each stating the rejected alternative and why.
- **Defects** with root cause, exact `file:line`, and the input that fails.
- **`Safety checks:`** — the exact commands run and what they matched.
- **`## Verification`** — concrete inputs → observed outputs, including
  adversarial cases from the canonical bank in
  `../../qa/references/adversarial-inputs.md` (garbage strings, oversized
  input, regex-special chars, out-of-range values, empty query).
- **`Known gap:`** — what was not verified and why.
- **Scope** — what was deliberately not touched.

/audit reports; it does not fix. If the user wants fixes, they say so, and
fixes land as separate, reviewable commits.
