#!/usr/bin/env python3
"""Run all 8 demo scripts for the New Stereographic Landscapes exploration."""
import subprocess
import sys
import os

demos = [
    "demo01_stereographic_dynamics.py",
    "demo02_fisher_sphere.py",
    "demo03_quantum_bloch.py",
    "demo04_stereographic_knots.py",
    "demo05_spectral_geometry.py",
    "demo06_mandelbrot_sphere.py",
    "demo07_conformal_flow.py",
    "demo08_grand_unification.py",
]

script_dir = os.path.dirname(os.path.abspath(__file__))

for demo in demos:
    print(f"\n{'='*60}")
    print(f"Running {demo}...")
    print('='*60)
    result = subprocess.run(
        [sys.executable, os.path.join(script_dir, demo)],
        capture_output=True, text=True, timeout=300
    )
    if result.returncode == 0:
        print(result.stdout)
    else:
        print(f"⚠️ {demo} had issues:")
        print(result.stderr[-500:] if result.stderr else "No error output")

print("\n" + "="*60)
print("All demos complete!")
print("="*60)
