#!/usr/bin/env python3
"""Run all seven demos and generate all visualizations."""

import subprocess
import sys
import os

demos = [
    "demo1_cosmic_timeline.py",
    "demo2_dark_energy_fates.py",
    "demo3_entropy_arrow_of_time.py",
    "demo4_goedel_incompleteness.py",
    "demo5_hawking_radiation.py",
    "demo6_computational_limits.py",
    "demo7_the_answer.py",
]

script_dir = os.path.dirname(os.path.abspath(__file__))

print("=" * 60)
print("  THE END OF EVERYTHING: Running All Demos")
print("=" * 60)

for demo in demos:
    path = os.path.join(script_dir, demo)
    print(f"\n▶ Running {demo}...")
    result = subprocess.run([sys.executable, path], capture_output=True, text=True)
    print(result.stdout, end="")
    if result.returncode != 0:
        print(f"  ⚠ Error: {result.stderr}")

print("\n" + "=" * 60)
print("  All demos complete. Outputs in demos/output/")
print("=" * 60)
