#!/usr/bin/env python3
"""
Run All Demos for the Algebraic Theory of Chemistry
=====================================================

This script runs all five demonstration scripts in sequence,
generating all visualizations in the output/ directory.

Requirements: numpy, scipy, matplotlib
Install: pip install numpy scipy matplotlib
"""

import subprocess
import sys
import os

os.chdir(os.path.dirname(os.path.abspath(__file__)))

demos = [
    ("Demo 1: Stoichiometric Algebra", "demo1_stoichiometric_algebra.py"),
    ("Demo 2: Molecular Symmetry", "demo2_molecular_symmetry.py"),
    ("Demo 3: Reaction Kinetics", "demo3_reaction_kinetics.py"),
    ("Demo 4: Periodic Table Algebra", "demo4_periodic_table_algebra.py"),
    ("Demo 5: Categorical Chemistry", "demo5_categorical_chemistry.py"),
]

print("=" * 60)
print("  THE ALGEBRAIC THEORY OF CHEMISTRY")
print("  Running All Demonstrations")
print("=" * 60)

for title, script in demos:
    print(f"\n{'─' * 60}")
    print(f"  {title}")
    print(f"{'─' * 60}")
    result = subprocess.run([sys.executable, script], capture_output=False)
    if result.returncode != 0:
        print(f"  ⚠️  {script} exited with code {result.returncode}")
    else:
        print(f"  ✅ {title} completed successfully")

print(f"\n{'=' * 60}")
print("  All demos complete!")
print(f"  Output images saved to: {os.path.abspath('output')}/")
print(f"{'=' * 60}")
