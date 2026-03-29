#!/usr/bin/env python3
"""
Demo 4 — Full Pipeline End-to-End
===================================

Runs the complete AutoHealer pipeline:

1. Creates a buggy app that writes errors to a log
2. Starts AutoHealer with a mock oracle
3. Triggers the app error
4. Watches AutoHeal detect → diagnose → patch → compile → hot-swap
5. Verifies the fix is live

Run::

    python -m autoheal.demos.demo_full_pipeline
"""

import sys
import os
import time
import tempfile
import shutil
import threading
import logging
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s — %(message)s",
)

DEMO_DIR = Path(tempfile.mkdtemp(prefix="autoheal_full_"))
SRC_DIR = DEMO_DIR / "src"
LOG_FILE = DEMO_DIR / "app.log"
SRC_DIR.mkdir()


def write_buggy_app():
    """Write a buggy module that we'll heal."""
    code = '''\
# app_module.py — has a missing colon bug
def process(data):
    if data is None
        return []
    return [x * 2 for x in data]
'''
    path = SRC_DIR / "app_module.py"
    path.write_text(code)
    return path


def simulate_error():
    """Try to import the buggy module and log the traceback."""
    import subprocess
    mod_path = SRC_DIR / "app_module.py"
    result = subprocess.run(
        [sys.executable, str(mod_path)],
        capture_output=True, text=True,
    )
    with open(LOG_FILE, "a") as f:
        f.write(result.stderr)
        f.write(f'\n  File "{mod_path}", line 3\n')
        f.write("SyntaxError: expected ':'\n")


def mock_oracle(prompt: str) -> str:
    """Simple mock that returns the fixed code."""
    return (
        "```python\n"
        "# app_module.py — fixed\n"
        "def process(data):\n"
        "    if data is None:\n"
        "        return []\n"
        "    return [x * 2 for x in data]\n"
        "```"
    )


def run_demo():
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))
    from autoheal import AutoHealer
    from autoheal.core.diagnostician import Severity

    print("=" * 60)
    print("  AutoHeal Demo — Full Pipeline")
    print("=" * 60)

    # Step 1
    mod_path = write_buggy_app()
    print(f"\n📝 Buggy module: {mod_path}")
    print("   " + mod_path.read_text().replace("\n", "\n   "))

    # Step 2: Start healer
    healer = AutoHealer(
        log_path=LOG_FILE,
        watch_dir=SRC_DIR,
        oracle_backend=mock_oracle,
        auto_apply=True,
        min_severity=Severity.ERROR,
        cooldown=1.0,
        poll_interval=0.2,
    )

    heal_events = []
    healer.on_heal(lambda ev: heal_events.append(ev))
    healer.start()
    print("🟢 AutoHealer started.\n")

    # Step 3: Trigger error
    print("💥 Simulating application crash...")
    simulate_error()

    # Step 4: Wait for heal
    print("⏳ Waiting for AutoHeal to detect and fix...")
    for _ in range(30):
        time.sleep(0.5)
        if heal_events:
            break

    healer.stop()

    # Step 5: Report
    if heal_events:
        ev = heal_events[0]
        print(f"\n🔍 Diagnosis: [{ev.diagnosis.category}] {ev.diagnosis.message}")
        if ev.patch:
            print(f"🔧 Patch valid: {ev.patch.is_valid}")
            print(f"   Diff:\n{ev.patch.unified_diff}")
        print(f"📦 Swapped: {ev.swapped}")
        print(f"⏱  Elapsed: {ev.elapsed_seconds:.2f}s")

        # Check if source is fixed
        fixed_code = mod_path.read_text()
        print(f"\n📝 Source after heal:")
        print("   " + fixed_code.replace("\n", "\n   "))
    else:
        print("⚠️  No heal events detected (mock oracle may not match diagnosis).")
        print("   This is expected — the heuristic fixer will try instead.")

    print(f"\n📊 Report:\n{healer.get_report()}")

    shutil.rmtree(DEMO_DIR, ignore_errors=True)
    print("\n✅ Demo complete.")


if __name__ == "__main__":
    run_demo()
