#!/usr/bin/env python3
"""
Run All Demos — Complexity Transmutation Research
Generates all visualizations for the research project.
"""

import subprocess
import sys
import os

demos = [
    ("demo_01_complexity_landscape.py", "Complexity Class Landscape"),
    ("demo_02_stereographic_complexity.py", "Stereographic Projection & Complexity"),
    ("demo_03_tropical_families.py", "Tropical Semiring Families"),
    ("demo_04_custom_universes.py", "Custom Mathematical Universes & Defect Algebras"),
    ("demo_05_tropical_stereo_synthesis.py", "Tropical-Stereographic Synthesis"),
    ("demo_06_defect_algebra_experiments.py", "Defect Algebra Experiments"),
]

print("=" * 70)
print("  COMPLEXITY TRANSMUTATION — DEMO SUITE")
print("  Oracle Council Research Project")
print("=" * 70)
print()

script_dir = os.path.dirname(os.path.abspath(__file__))
results = []

for filename, title in demos:
    print(f"🔮 Running: {title}")
    print(f"   Script: {filename}")
    filepath = os.path.join(script_dir, filename)
    try:
        result = subprocess.run(
            [sys.executable, filepath],
            capture_output=True, text=True, timeout=120
        )
        if result.returncode == 0:
            print(f"   {result.stdout.strip()}")
            results.append((title, "✅ SUCCESS"))
        else:
            print(f"   ❌ FAILED: {result.stderr[:200]}")
            results.append((title, "❌ FAILED"))
    except subprocess.TimeoutExpired:
        print(f"   ⏰ TIMEOUT")
        results.append((title, "⏰ TIMEOUT"))
    except Exception as e:
        print(f"   ❌ ERROR: {e}")
        results.append((title, f"❌ ERROR: {e}"))
    print()

print("=" * 70)
print("  RESULTS SUMMARY")
print("=" * 70)
for title, status in results:
    print(f"  {status}  {title}")

print()
print("Generated images:")
for f in sorted(os.listdir(script_dir)):
    if f.endswith('.png'):
        size = os.path.getsize(os.path.join(script_dir, f))
        print(f"  📊 {f} ({size//1024} KB)")
print()
print("Done! 🎉")
