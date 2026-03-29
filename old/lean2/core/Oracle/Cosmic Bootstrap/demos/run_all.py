#!/usr/bin/env python3
"""
Run all Oracle Bootstrap experiments and generate all visualizations.

Usage: python run_all.py

Requirements: numpy, matplotlib, scipy
Install: pip install numpy matplotlib scipy
"""

import subprocess
import sys
import os

scripts = [
    "oracle_bootstrap_basics.py",
    "julia_set_fractal.py",
    "cosmic_flow.py",
    "encryption_attack.py",
    "fractal_dimension.py",
    "hypothesis_experiments.py",
]

dir_path = os.path.dirname(os.path.abspath(__file__))

print("=" * 70)
print("  ORACLE BOOTSTRAP: Running All Experiments")
print("=" * 70)

for script in scripts:
    path = os.path.join(dir_path, script)
    print(f"\n{'─' * 70}")
    print(f"  Running: {script}")
    print(f"{'─' * 70}")
    result = subprocess.run([sys.executable, path], cwd=dir_path,
                          capture_output=False)
    if result.returncode != 0:
        print(f"  ⚠ {script} exited with code {result.returncode}")

print(f"\n{'=' * 70}")
print("  All experiments complete!")
print(f"{'=' * 70}")
