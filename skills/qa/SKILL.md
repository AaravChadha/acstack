---
name: qa
description: Exercise the running app through the probe layer - happy-path flows first, then adversarial inputs (garbage, oversized, regex-special, out-of-range) and auth-gate probing, reported with a PASS/FAIL verdict and exact repro commands. The http probe is implemented; browser mode declines honestly until it lands. Use when the user asks to QA, smoke-test, or probe the running app, an endpoint, or a flow.
argument-hint: "[flow | url | notes]"
---

# /qa — exercise the running system

Static review reads the code; /qa hits the thing that actually runs.
Flows first — a broken happy path makes every adversarial result noise —
then the inputs real users and hostile users will eventually send.

`Adjacent skills:` /secure (hunts vulnerabilities; /qa exercises
functionality — a /qa auth finding is handed to /secure) · /audit code
(reads the code; /qa probes the running system) · /design-audit (how it
looks; /qa is how it behaves).

<!-- acstack:runtime -->
Run once before the skill's steps; any failure degrades to pure markdown:
```bash
link="$(readlink "$HOME/.claude/skills/health" 2>/dev/null || true)"   # empty = not symlinked
pack="$(dirname "$(dirname "$link")")"   # NEVER trust this unless $link was non-empty
if [ "${link#/}" != "$link" ] && [ -x "$pack/bin/acstack-config" ] && ! "$pack/bin/acstack-config" runtime | grep -q '=off'; then
  "$pack/bin/acstack-config" || true          # resolved keys, with sources
  "$pack/bin/acstack-update-check" || true    # ≤1 fetch/day; prints the pull command when behind
  "$pack/bin/acstack-recall" || true          # LEARNINGS.md + bug-class names, capped 3KB
else
  echo "runtime off — proceeding without recall/update-check"
fi
```
<!-- /acstack:runtime -->

<!-- acstack:principles -->
## Operating principles

- Be direct. Push back in writing when the plan or the user is wrong. No sycophancy.
- Never delete a decision. Supersede it: `~~old~~ → **Verdict (YYYY-MM-DD):** new call — reason.`
- Never fix, tune, or delete a test or eval case to raise a score. Log the miss honestly and leave the case unchanged.
- Name exact things: regex patterns, function signatures, model names, before → after numbers. Never "fixed bugs".
- Attribution: follow the project's `attribution` setting (default `none`) — no AI-tool mentions in generated docs, no attribution trailers in commits or PRs. Commit with explicit `-m`/`-F` messages only.
- Config: read `.claude/acstack.md` at the project root (fall back to `~/.claude/acstack.md`) before acting. `## Settings` keys override pack defaults; a `## <skill-name>` section overrides both. Unknown keys and sections are ignored.
- Docs: BRIEF.md (frozen seed) / PLAN.md (living plan) / JOURNAL.md (rolling journal). If the repo uses legacy names (PLANNING_PROMPT.md / PLANNING.md / STATUS.md), use those instead — never create both.
- Recall: if `LEARNINGS.md` exists at the project root, read it before starting.
- Conduct: follow the `acstack-conduct` block in this repo's AGENTS.md — the word is the mode; the user sets the pace.
<!-- /acstack:principles -->

## The probe layer

A probe is the only thing that touches the target; this skill's method
and report never name a transport. Every probe provides three verbs —
**reach** (is the target up), **act** (deliver one input or step),
**observe** (status, body, error) — per the contract in
`references/probe-layer.md`.

- `probe: http` — implemented. curl conventions in the reference file.
- `probe: browser` — not yet implemented. Asked for it, say exactly:
  "browser probe deferred until first real need (decision 2026-07-27);
  http mode is available" — and offer http. Never fake a browser result.

The report skeleton below is identical whichever probe runs. That is
the seam: when the browser probe lands, only the reference file grows.

## Safety rule (binding)

Mutating probes — anything non-GET, form submits, state-changing steps —
run only against targets that are clearly local or dev (`localhost`,
`127.0.0.1`, a URL the user names as dev). Target not clearly local →
name the risk and get explicit confirmation BEFORE the first mutating
probe. Adversarial probing of a production URL never starts uninvited.

## Method

1. **Resolve the target.** Argument URL beats config `base-url` (from a
   `## qa` section). Neither → say exactly what's missing and stop:
   `BLOCKED — no target: pass a URL or set base-url in .claude/acstack.md`.
   **Never infer a target from source.** An `app.listen(3000)` in the code
   says a port the app *would* use if it were running, not an address that
   is serving now — probing a guessed URL either fails confusingly or, if
   something unrelated answers, produces results attributed to the wrong
   process. A target is supplied, never deduced. Same rule, same reason as
   the credential rule in step 6: the tempting value sitting in the repo is
   not the one you are entitled to use.
2. **Reach first.** One reach probe. Target down → `BLOCKED`, report
   ends; nothing else is meaningful.
3. **Enumerate flows** from BRIEF/PLAN (or run only the flow named in
   the argument). A flow is a named sequence of steps with an expected
   outcome — "search returns results", "unauthenticated save is
   rejected". No discoverable flows → probe the endpoints the user
   names, and say the flow map was thin.
4. **Happy path per flow.** Expected outcome observed, or a finding.
5. **Adversarial pass** per input surface, drawing from
   `references/adversarial-inputs.md`: garbage tokens, oversized input,
   regex-special characters, out-of-range numerics, empty and
   whitespace-only, wrong-type values. Expected: a controlled rejection
   (4xx, a validation message). A 5xx or a stack trace is a finding
   even when the input was absurd — absurd input is exactly what
   arrives in week one.
6. **Auth-gate probing.** Every gated endpoint, hit unauthenticated,
   must fail closed: 401/403. A 200 is a security finding — recorded
   here, handed to /secure. A 5xx is an error-hygiene finding.
   **Credentials come from the user, never from the repo.** Probing a
   gated flow as an authenticated user needs a token or session the user
   supplies for this run. Do NOT read one out of `.env`, a fixture, or a
   config file: a credential committed to the tree is a /secure finding,
   and using it here would launder a defect into a passing test. None
   supplied → probe the unauthenticated half (which is the security-
   relevant half anyway), and report the authenticated flows as
   `not probed — no credentials supplied`.

## Report shape

First line is the verdict: `PASS` / `FAIL — <n> findings` /
`BLOCKED — <precondition>`. Then:

- **Per-flow table:** step | input class | expected | observed | verdict.
- **Findings**, each with the exact repro command (the literal curl
  line) and observed output — a finding that can't be re-run isn't one.
- **Scope:** target probed, probe mode used, flows and surfaces NOT
  exercised. /qa reports; fixes are the user's call.
