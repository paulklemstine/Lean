#!/usr/bin/env python3
"""
Demo 2 — Live Hot-Swap
========================

Demonstrates hot-swapping a function in a running process:

1. Import a module with ``greet() -> "Hello v1"``
2. A background thread calls ``greet()`` every second
3. Mid-flight, we rewrite the source to ``"Hello v2"``, recompile,
   and hot-swap — the running thread sees the new version *without
   restart*.

Run::

    python -m autoheal.demos.demo_hot_swap
"""

import sys
import time
import types
import tempfile
import threading
import importlib.util
from pathlib import Path

DEMO_DIR = Path(tempfile.mkdtemp(prefix="autoheal_hotswap_"))
MOD_FILE = DEMO_DIR / "live_module.py"


def write_version(version: int):
    MOD_FILE.write_text(
        f"def greet():\n    return 'Hello from version {version}!'\n"
    )


def load_module(name: str, path: Path) -> types.ModuleType:
    spec = importlib.util.spec_from_file_location(name, str(path))
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


def run_demo():
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))
    from autoheal.core.hot_swapper import HotSwapper
    from autoheal.core.compiler import Compiler

    print("=" * 60)
    print("  AutoHeal Demo — Live Hot-Swap")
    print("=" * 60)

    # Write v1
    write_version(1)
    mod = load_module("live_module", MOD_FILE)

    results = []
    stop = threading.Event()

    def worker():
        while not stop.is_set():
            # Always call through sys.modules to see swaps
            m = sys.modules["live_module"]
            results.append(m.greet())
            time.sleep(0.3)

    t = threading.Thread(target=worker, daemon=True)
    t.start()

    time.sleep(1.0)  # let v1 run a few times
    print(f"\n📌 Version 1 running — collected: {results[-1]}")

    # Write v2 and hot-swap
    write_version(2)
    print("📝 Wrote version 2 to disk.")

    compiler = Compiler(DEMO_DIR)
    result = compiler.compile_and_load(MOD_FILE)
    print(f"🔨 Compiled: success={result.success}")

    swapper = HotSwapper()
    if result.success and result.module:
        n = swapper.swap_module("live_module", result.module)
        print(f"🔄 Hot-swapped {n} attributes.")

    time.sleep(1.0)  # let v2 run
    stop.set()
    t.join(timeout=2)

    print(f"\n📌 After swap — latest: {results[-1]}")
    print(f"\n📋 Full call log ({len(results)} calls):")
    for i, r in enumerate(results):
        marker = " ←  swap happened here" if i > 0 and results[i] != results[i - 1] else ""
        print(f"   [{i:>2}] {r}{marker}")

    # Cleanup
    import shutil
    shutil.rmtree(DEMO_DIR, ignore_errors=True)
    print("\n✅ Demo complete.")


if __name__ == "__main__":
    run_demo()
