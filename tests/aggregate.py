#!/usr/bin/env python3
"""Aggregate the autograde phase outcomes + honor status into grading/result.json.

Emits the machine-readable recon contract consumed by lectern's reg-lab-recon,
published as the grading-result CI run artifact (a durable, Classroom-independent
home that students cannot delete).

Usage (from the workflow, after the phase + honor steps):
    python3 tests/aggregate.py "$PHI" "$OMEGA" "$HONOR"
where each arg is the GitHub Actions step outcome ("success"/"failure"/...).
The in-workflow step.outcome is authoritative (the jobs-API conclusion is masked
to success by continue-on-error).
"""
from __future__ import annotations
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

ASSIGNMENT = "buffer-overflow"
# Phase Phi (WALK IN) 60, Phase Omega (COLD STEEL) 10; writeup 30 graded by ISA.
CHALLENGES = [("phi", 60), ("omega", 10)]
MAX_TOTAL = 100


def build(phi: str, omega: str, honor: str) -> dict:
    honor_ok = honor == "success"
    outcomes = {"phi": phi, "omega": omega}
    challenges = {}
    for key, pts in CHALLENGES:
        passed = honor_ok and outcomes[key] == "success"  # honor gate voids all phases
        challenges[key] = {"pass": passed, "points": pts if passed else 0, "max": pts}
    total = sum(c["points"] for c in challenges.values())
    return {
        "schema": 1,
        "assignment": ASSIGNMENT,
        "commit": os.environ.get("GITHUB_SHA", ""),
        "honor_ok": honor_ok,
        "challenges": challenges,
        "points": total,
        "max": MAX_TOTAL,
    }


def main(argv: list[str]) -> int:
    phi = argv[0] if len(argv) > 0 else ""
    omega = argv[1] if len(argv) > 1 else ""
    honor = argv[2] if len(argv) > 2 else ""
    result = build(phi, omega, honor)
    out = ROOT / "grading" / "result.json"
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
