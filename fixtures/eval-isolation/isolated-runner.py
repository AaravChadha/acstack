#!/usr/bin/env python3
"""CORRECT FORM (PLAN 4.45). Identical to unisolated-runner.py except for
the invocation. The documented detection MUST accept this file — without
this direction, a guard that rejects every runner would score full marks."""
import subprocess

SUBJECT_MODEL = "pinned-model-id-recorded-with-results"


def run_subject(case):
    return subprocess.run(
        ["claude", "-p", case["input"],
         "--setting-sources", "", "--bare",
         "--disable-slash-commands", "--model", SUBJECT_MODEL],
        capture_output=True, text=True, check=True,
    ).stdout
