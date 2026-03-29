#!/usr/bin/env python3
"""
Demo 1 — Basic Self-Healing Loop
==================================

This demo creates a deliberately buggy Python script, runs it (generating
errors in a log file), and lets AutoHeal detect, patch, recompile, and
hot-swap the fix — all live.

Run::

    python -m autoheal.demos.demo_basic
"""

import sys
import os
import time
import tempfile
import logging
import shutil
from pathlib import Path

# ── Setup logging ──────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s — %(message)s",
)
log = logging.getLogger("demo_basic")

# ── Paths ──────────────────────────────────────────────────────────────
DEMO_DIR = Path(tempfile.mkdtemp(prefix="autoheal_demo_"))
SRC_DIR = DEMO_DIR / "src"
LOG_FILE = DEMO_DIR / "app.log"
SRC_DIR.mkdir()

log.info("Demo directory: %s", DEMO_DIR)


def write_buggy_module():
    """Write a Python module with a deliberate SyntaxError."""
    code = '''\
# buggy_module.py — a module with a deliberate bug
import math

def compute_area(radius):
    """Compute circle area."""
    # BUG: missing colon on the if-statement
    if radius < 0
        raise ValueError("Radius must be non-negative")
    return math.pi * radius ** 2

def greet(name):
    return f"Hello, {name}!"
'''
    target = SRC_DIR / "buggy_module.py"
    target.write_text(code)
    log.info("Wrote buggy module to %s", target)
    return target


def simulate_app_crash(module_path: Path):
    """
    Try to import the buggy module and log the error to LOG_FILE,
    simulating what a real application would do.
    """
    import subprocess
    result = subprocess.run(
        [sys.executable, "-c", f"import importlib.util; "
         f"spec = importlib.util.spec_from_file_location('buggy', '{module_path}'); "
         f"mod = importlib.util.module_from_spec(spec); "
         f"spec.loader.exec_module(mod)"],
        capture_output=True, text=True,
    )
    with open(LOG_FILE, "a") as f:
        if result.returncode != 0:
            f.write(result.stderr)
            log.info("App crashed — error logged.")
        else:
            f.write("INFO: Module loaded successfully.\n")
            log.info("App ran successfully!")
    return result.returncode


def run_demo():
    """Run the full demo."""
    # Import here so the library path is resolved
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))
    from autoheal.core.tail_watcher import TailWatcher
    from autoheal.core.diagnostician import Diagnostician, Severity
    from autoheal.core.code_surgeon import CodeSurgeon
    from autoheal.core.compiler import Compiler

    print("=" * 60)
    print("  AutoHeal Demo — Basic Self-Healing Loop")
    print("=" * 60)

    # Step 1: Write buggy code
    module_path = write_buggy_module()
    print(f"\n📝 Buggy module written to: {module_path}")
    print("   Contents:")
    print("   " + module_path.read_text().replace("\n", "\n   "))

    # Step 2: Crash
    print("\n💥 Running buggy module...")
    rc = simulate_app_crash(module_path)
    print(f"   Exit code: {rc}")
    print(f"   Log output:\n   {LOG_FILE.read_text().replace(chr(10), chr(10) + '   ')}")

    # Step 3: Diagnose
    print("\n🔍 Diagnosing...")
    from autoheal.core.tail_watcher import LogLine
    diagnostician = Diagnostician()
    for i, line in enumerate(LOG_FILE.read_text().splitlines()):
        ll = LogLine(text=line, line_number=i + 1, timestamp=time.time(), source_file=str(LOG_FILE))
        diag = diagnostician.classify(ll)
        if diag and diag.severity >= Severity.ERROR:
            print(f"   🚨 {diag.severity.name}: [{diag.category}] {diag.message}")

            # Step 4: Attempt patch
            print("\n🔧 Attempting repair...")
            surgeon = CodeSurgeon(watch_dir=SRC_DIR)
            # Manually set source info for the heuristic fixer
            diag.source_file = str(module_path)
            patch = surgeon.propose_patch(diag)
            if patch and patch.is_valid:
                print("   ✅ Valid patch generated!")
                print(f"   Diff:\n{patch.unified_diff}")

                # Apply
                surgeon.apply_patch(patch)
                print("   📦 Patch applied.")

                # Step 5: Verify
                print("\n🔄 Re-running patched module...")
                rc2 = simulate_app_crash(module_path)
                print(f"   Exit code: {rc2}")
                if rc2 == 0:
                    print("   🎉 Module healed successfully!")
                else:
                    print("   ⚠️  Still broken — would need Oracle for deeper fix.")
            else:
                print("   ❌ No valid heuristic patch found — Oracle needed.")
            break

    print(f"\n🧹 Cleaning up: {DEMO_DIR}")
    shutil.rmtree(DEMO_DIR, ignore_errors=True)
    print("\nDone.")


if __name__ == "__main__":
    run_demo()
