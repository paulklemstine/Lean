#!/usr/bin/env python3
"""Quick syntax check - runs via Windows Python reading WSL files."""
import ast
import sys
import os

base = r"\\wsl.localhost\Ubuntu\home\raver1975\lean\Aether"
files = ["catalog_analyzer.py", "pi_agent_client.py", "pi_orchestrator.py"]

errors = []
for f in files:
    path = os.path.join(base, f)
    try:
        with open(path, "r", encoding="utf-8") as fh:
            source = fh.read()
        ast.parse(source)
        print(f"OK {f}")
    except SyntaxError as e:
        print(f"SYNTAX ERROR {f} line {e.lineno}: {e.msg}")
        errors.append(f)
    except Exception as e:
        print(f"ERROR {f}: {e}")
        errors.append(f)

if errors:
    print(f"\nFAILED: {errors}")
    sys.exit(1)
else:
    print("\nAll 3 files pass syntax check.")
