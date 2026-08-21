# tests/test_tick_smoke.py
"""Smoke test: aether_tick main() must actually START the tick.

Regression 2026-08-21: a greedy regex deletion eviscerated main() — the tick
exited 0 in <1s with no output while GitHub Actions reported success, so two
production ticks were silent no-ops. This test runs the real entrypoint,
streams its output, and asserts the startup banner appears; it terminates the
tick as soon as the banner is seen (a full tick takes minutes).
"""
import os
import subprocess
import sys
from pathlib import Path

AETHER = Path(__file__).resolve().parent.parent / "Aether"


def test_tick_starts_and_prints_banner():
    env = {**os.environ, "PYTHONUNBUFFERED": "1"}
    proc = subprocess.Popen(
        [sys.executable, "aether_tick.py", "--max-inflight", "1"],
        cwd=str(AETHER),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        env=env,
    )
    seen_banner = False
    tail = []
    try:
        for line in proc.stdout:
            tail.append(line)
            if "[Tick] Aether tick starting" in line:
                seen_banner = True
                break
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=15)
        except subprocess.TimeoutExpired:
            proc.kill()
    assert seen_banner, (
        "Tick never started — main() is broken. Last output:\n"
        + "".join(tail[-30:])
    )
