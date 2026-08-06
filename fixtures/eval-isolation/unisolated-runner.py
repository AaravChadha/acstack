#!/usr/bin/env python3
"""SEEDED DEFECT (PLAN 4.45). The subject is invoked with the operator's
ambient configuration and no model pin. The documented detection MUST
reject this file; a run that reports it clean has stopped comparing."""
import subprocess


def run_subject(case):
    return subprocess.run(
        ["claude", "-p", case["input"]],
        capture_output=True, text=True, check=True,
    ).stdout
