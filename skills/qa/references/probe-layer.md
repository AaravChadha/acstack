# Probe layer — the seam contract

A probe is the only component that touches the target. The skill decides
WHAT to exercise; the probe decides HOW. Reports never name a transport
in their structure — only in the scope line ("probe mode used: http").

## The contract — three verbs

Every probe mode implements exactly these:

- **reach(target)** → up / down / unreachable-with-error. Run once
  before anything else; a down target ends the run as `BLOCKED`.
- **act(step, input)** → deliver one input or perform one step against
  the target. One act per table row — never batch, so every row has one
  observable outcome.
- **observe(result)** → status, response body (first ~500 bytes unless
  more is load-bearing), timing when notable, error text verbatim.

Anything a probe can't express through these three verbs (cookies,
sessions, multi-step auth) is set up before the run and stated in the
report's scope line.

## http probe (implemented)

- **reach:** `curl -sS -o /dev/null -w '%{http_code}' --max-time 5 <base>/`
- **act:** one curl per probe, always recorded verbatim in the report:

  ```bash
  curl -sS -w '\n%{http_code}' --max-time 10 \
    -X POST -H 'Content-Type: application/json' \
    -d '<payload>' <base>/<path>
  ```

- **observe:** record the status code, the first ~500 bytes of body,
  and any error text exactly. Timings only when they're the finding
  (a 30-second search is a finding; 180ms vs 210ms is noise).

Conventions:

- `--max-time` on every call — a hung endpoint is a finding
  (`observed: timeout after 10s`), not a hung QA run.
- Auth setup (tokens, cookies) is done once, stated in scope, and the
  unauthenticated variant is probed WITHOUT it (the auth-gate pass).
- Non-GET calls obey the safety rule in SKILL.md: clearly-local targets
  only, or explicit user confirmation first.
- Repro fidelity is absolute: the report's curl line, run by the user,
  must reproduce the observed result — no cleaned-up placeholders in
  place of the literal values probed (secrets excepted: redact tokens
  as `$TOKEN` and say so).

## browser probe (deferred — decision 2026-07-27)

Not implemented. Deferred until first real need (a UI whose flows can't
be exercised over http). When asked for it, decline honestly with the
dated deferral above and offer http — never simulate or hand-wave a
browser result.

When it lands, it implements the same three verbs (reach = page load,
act = one user action, observe = resulting DOM state / visible text /
console errors) and feeds the identical report skeleton. Nothing in
SKILL.md changes except the mode list — that is the promise this file
exists to keep.
