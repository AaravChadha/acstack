#!/usr/bin/env python3
"""Per-category non-regression gate (acstack PLAN 4.46).

Copy this into the project beside the runner. It answers one question the
headline cannot: did any CATEGORY get worse than the last committed run?

Why the headline is not enough. /ship's eval gate compares one overall
number against a fixed target, and the spec's category minimums constrain
the GOLDEN SET's composition — neither compares a run to the previous run.
So a change that lifts the overall percentage while quietly breaking every
refusal case passes both. Refusal is exactly where that hurts: it is a
small category, so its collapse barely moves an average.

Baseline is the LAST COMMITTED RESULTS FILE (verdict 2026-08-06). The
spec's stated target was rejected as the baseline because the spec already
states per-category minimums, so flooring against them again would add a
gate that catches nothing new; a max-of-both ratchet was rejected as too
likely to block on ordinary eval noise.

    usage: regression-gate.py <current.jsonl> [previous.jsonl]

No previous file — a first run, or the first run after a spec change —
PASSES and says so. That path is stated rather than silent on purpose: an
absent baseline reported as a clean pass is the false confidence this gate
exists to remove.

TWO axes, deliberately separate (verdict 2026-08-07, PLAN 4.51). The gate
blocks on either:

  1. PASS RATE fell for a category, computed on scored records only.
  2. COVERAGE fell — fewer of a category's cases scored than last run,
     because they errored or stopped being emitted.

Shakedown 12 found the gate blind to (2): filtering to `status == "scored"`
before computing rates meant a category going 4/4 passing -> 1 passing +
3 erroring was compared on the one survivor, read as 100% -> 100%, and
passed clean. A category that crashes ENTIRELY was already caught by the
`gone` check; partial crashing — the likelier shape, since a subject
usually breaks on some inputs — was invisible.

The divergence with the headline STAYS, and is now explicit. The runner's
headline counts a crash as a failure; this gate does not fold errors into
the denominator, because one merged number answers neither "did the
subject get worse" nor "did the harness break" — and those have different
causes and different fixes. Reporting them on separate lines keeps that
distinction, which is the same one /ship's gate 3 needs from an exit code.

Exit 0 = no category regressed (or no baseline). Exit 1 = blocked.
"""
import json
import pathlib
import sys


def rates(path):
    """category -> (rate, passed, scored, errored).

    `rate` counts ONLY scored records, exactly as the runner excludes
    non-scored rows from the headline. `scored` and `errored` are carried
    alongside it because the rate alone cannot see a partial crash: a
    category whose cases start failing to run keeps a clean rate computed
    on the survivors while its real coverage collapses. main() compares
    the counts separately — see the coverage check there.

    Categories with zero scored records are still dropped, so a category
    that crashes ENTIRELY disappears from the mapping and is caught by
    main()'s `gone` check rather than reported twice.
    """
    tally = {}
    for line in pathlib.Path(path).read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        rec = json.loads(line)
        cat = rec.get("category", "<uncategorised>")
        p, n, e = tally.get(cat, (0, 0, 0))
        status = rec.get("status")
        if status == "scored":
            tally[cat] = (p + (1 if rec.get("pass") else 0), n + 1, e)
        elif status == "error":
            tally[cat] = (p, n, e + 1)
        # skipped and rubric-review rows count as neither: they are not a
        # score and not a crash, and treating a deliberate skip as lost
        # coverage would block on ordinary spec maintenance.
    return {c: (p / n, p, n, e) for c, (p, n, e) in tally.items() if n}


def main(argv):
    if not 2 <= len(argv) <= 3:
        sys.exit(__doc__.strip().splitlines()[-4].strip())
    cur = rates(argv[1])

    if len(argv) == 2 or not pathlib.Path(argv[2]).exists():
        print("regression-gate: NO BASELINE — no previous committed results "
              "file, so no category comparison was made. This run is not "
              "evidence that nothing regressed.")
        return 0

    prev = rates(argv[2])
    regressed = []
    for cat, (rate, p, n, e) in sorted(cur.items()):
        if cat not in prev:
            continue  # new category: nothing to regress against
        prate, pp, pn, pe = prev[cat]
        if rate < prate:
            regressed.append(
                f"  {cat}: pass rate {prate:.1%} ({pp}/{pn}) -> "
                f"{rate:.1%} ({p}/{n})")
        if n < pn:
            why = f", {e} errored this run" if e else ""
            regressed.append(
                f"  {cat}: coverage fell — {n} of {pn} cases scored{why}. "
                f"The pass rate is computed on the survivors, so it can "
                f"read clean while the category collapses.")

    gone = sorted(set(prev) - set(cur))
    if gone:
        regressed.append("  categories that vanished from the run: "
                         + ", ".join(gone))

    if regressed:
        print("regression-gate: BLOCKED — a category fell against the last "
              "committed run:")
        print("\n".join(regressed))
        print("The overall headline is not consulted here: it can rise while "
              "a category falls, which is the case this gate exists for.")
        return 1

    print(f"regression-gate: no category regressed "
          f"({len(cur)} categories compared against the baseline)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
