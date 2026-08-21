# tests/test_tick_smoke.py
"""Smoke test: aether_tick main() must actually START the tick.

Regression 2026-08-21: a greedy regex deletion eviscerated main() — the tick
exited 0 in <1s with no output while GitHub Actions reported success, so two
production ticks were silent no-ops. This test runs the real entrypoint and
asserts the startup banner appears.
"""
import subprocess
import sys
from pathlib import Path

AETHER = Path(__file__).resolve().parent.parent / "Aether"


def test_tick_starts_and_prints_banner():
    proc = subprocess.run(
        [sys.executable, "aether_tick.py", "--max-inflight", "1"],
        cwd=str(AETHER),
        capture_output=True,
        text=True,
        timeout=120,
    )
    combined = proc.stdout + proc.stderr
    assert "[Tick] Aether tick starting" in combined, (
        "Tick never started — main() is broken. Output was:\n"
        + combined[-1500:]
    )
