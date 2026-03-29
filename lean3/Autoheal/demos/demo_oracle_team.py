#!/usr/bin/env python3
"""
Demo 3 — Oracle Team Council
==============================

Shows how the six-oracle council (Researcher → Hypothesizer →
Experimenter → Validator → Updater → Iterator) collaborates to
diagnose and fix a runtime error.

Uses a **mock AI backend** so no API key is needed.

Run::

    python -m autoheal.demos.demo_oracle_team
"""

import sys
import json
from pathlib import Path


# ── Mock AI Backend ───────────────────────────────────────────────────
# Simulates an LLM that understands Python errors and returns
# structured responses appropriate for each oracle role.

_ROUND_RESPONSES = {
    1: {
        "researcher": (
            "The error is a ZeroDivisionError on line 8 of calculator.py. "
            "The function `safe_divide(a, b)` calls `a / b` without checking "
            "if `b` is zero.  The function is called from `main()` with "
            "user-supplied inputs."
        ),
        "hypothesizer": (
            "Hypothesis 1 (HIGH confidence): `b` is zero and there is no "
            "guard.  Evidence: the traceback points to `return a / b`.  "
            "Falsification: add `assert b != 0` before the division.\n"
            "Hypothesis 2 (LOW): floating-point underflow masquerading as "
            "zero.  Evidence: would need to check input types."
        ),
        "experimenter": (
            "Experiment for H1: add `if b == 0: return float('inf')` as a "
            "guard before the division.  Minimal diff:\n"
            "```python\n"
            "def safe_divide(a, b):\n"
            "    if b == 0:\n"
            "        return float('inf')\n"
            "    return a / b\n"
            "```"
        ),
        "validator": (
            "The fix is correct: it prevents ZeroDivisionError.  "
            "Returning `float('inf')` is a reasonable sentinel.  "
            "The change is minimal (2 lines added).  No regressions expected."
        ),
        "updater": (
            "```python\n"
            "# calculator.py — fixed version\n"
            "def safe_divide(a, b):\n"
            "    if b == 0:\n"
            "        return float('inf')\n"
            "    return a / b\n\n"
            "def main():\n"
            "    result = safe_divide(10, 0)\n"
            "    print(f'Result: {result}')\n\n"
            "if __name__ == '__main__':\n"
            "    main()\n"
            "```"
        ),
        "iterator": "CONVERGED — the fix is minimal, correct, and safe.",
    },
}


def mock_backend(prompt: str) -> str:
    """Determine which role is speaking and return canned response."""
    prompt_lower = prompt.lower()
    for role, text in _ROUND_RESPONSES[1].items():
        if role in prompt_lower:
            return text
    # Default: researcher
    return _ROUND_RESPONSES[1]["researcher"]


def run_demo():
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))
    from autoheal.core.oracle import OracleTeam

    print("=" * 60)
    print("  AutoHeal Demo — Oracle Team Council")
    print("=" * 60)

    buggy_source = '''\
# calculator.py — buggy version
def safe_divide(a, b):
    return a / b

def main():
    result = safe_divide(10, 0)
    print(f"Result: {result}")

if __name__ == "__main__":
    main()
'''

    diagnosis_text = (
        "Category: ZeroDivisionError\n"
        "Message: division by zero\n"
        "File: calculator.py\n"
        "Line: 3\n"
    )

    print("\n📝 Buggy source:")
    print("   " + buggy_source.replace("\n", "\n   "))

    print("🧠 Assembling oracle team...")
    team = OracleTeam(backend=mock_backend, max_rounds=3)

    print("🔄 Running repair cycle...\n")
    fixed = team.run_repair_cycle(diagnosis_text, buggy_source)

    if fixed:
        print("✅ Oracle team converged!\n")
        print("📝 Fixed source:")
        print("   " + fixed.replace("\n", "\n   "))
    else:
        print("❌ Did not converge.")

    # Print notes
    print("\n" + "=" * 60)
    print("  Oracle Team Notes")
    print("=" * 60)
    print(team.get_notes_markdown())

    print("\n✅ Demo complete.")


if __name__ == "__main__":
    run_demo()
