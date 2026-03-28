#!/usr/bin/env python3
"""
Run all visualization demos for the Algebraic Theory of Reality.
Generates all figures in the figures/ directory.
"""

import subprocess
import sys
import os

demos = [
    '01_division_algebra_hierarchy.py',
    '02_hopf_fibrations.py',
    '03_magic_square.py',
    '04_quaternion_rotations.py',
    '05_octonion_physics.py',
    '06_sedenion_boundary.py',
    '07_grand_unified_visual.py',
]

script_dir = os.path.dirname(os.path.abspath(__file__))

print("=" * 60)
print("  THE ALGEBRAIC THEORY OF REALITY")
print("  Generating all visualizations...")
print("=" * 60)
print()

for demo in demos:
    path = os.path.join(script_dir, demo)
    print(f"Running {demo}...")
    try:
        result = subprocess.run([sys.executable, path],
                              capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            print(f"  {result.stdout.strip()}")
        else:
            print(f"  ❌ Error: {result.stderr.strip()}")
    except Exception as e:
        print(f"  ❌ Exception: {e}")
    print()

print("=" * 60)
print("  All demos complete!")
print(f"  Figures saved to: {os.path.join(os.path.dirname(script_dir), 'figures')}/")
print("=" * 60)
