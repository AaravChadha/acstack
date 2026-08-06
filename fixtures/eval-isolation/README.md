# Eval-runner isolation fixture (PLAN 4.45)

Seeds the contamination an eval run must be isolated from, plus one runner
that isolates and one that does not. `scripts/controls.sh` extracts the
documented flags from `skills/eval-run/references/runner-template.md` at run
time and checks both directions, so a doc edit that drops a flag fails
there rather than shipping as a false pass.

| Path | Role |
|---|---|
| `contaminating-home/.claude/` | A user-level config carrying all four leak classes the spec template names: an installed skill, a SessionStart hook, a memory file, and an output style in settings |
| `unisolated-runner.py` | Invokes the subject with none of the flags and no model pin. The detection MUST reject it |
| `isolated-runner.py` | The correct form. The detection MUST accept it — without this direction a guard that rejects everything would score full marks |

The two runners are otherwise identical, so the only variable is the
invocation. Neither is executed; they are read as text, the same way a
reviewer reads a scaffolded runner.
