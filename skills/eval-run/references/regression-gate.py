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

Exit 0 = no category regressed (or no baseline). Exit 1 = blocked.
"""
import json
import pathlib
import sys


def rates(path):
    """category -> (passed, scored). Only `scored` records count; skipped,
    errored and rubric-review rows are excluded from both sides, exactly as
    the runner excludes them from the headline."""
    tally = {}
    for line in pathlib.Path(path).read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        rec = json.loads(line)
        if rec.get("status") != "scored":
            continue
        cat = rec.get("category", "<uncategorised>")
        p, n = tally.get(cat, (0, 0))
        tally[cat] = (p + (1 if rec.get("pass") else 0), n + 1)
    return {c: (p / n, p, n) for c, (p, n) in tally.items() if n}


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
    for cat, (rate, p, n) in sorted(cur.items()):
        if cat not in prev:
            continue  # new category: nothing to regress against
        prate, pp, pn = prev[cat]
        if rate < prate:
            regressed.append(
                f"  {cat}: {prate:.1%} ({pp}/{pn}) -> {rate:.1%} ({p}/{n})")

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
