#!/usr/bin/env python3
"""
Master runner: executes all demos and generates all figures.

Usage: python run_all.py
"""

import subprocess
import sys
import os

DEMO_DIR = os.path.dirname(os.path.abspath(__file__))

demos = [
    'demo_berggren_tree.py',
    'demo_fractal_dimension.py',
    'demo_branching_entropy.py',
    'demo_quaternionic.py',
    'demo_padic.py',
    'demo_meta_oracle.py',
]

def main():
    print("=" * 70)
    print("  META-ORACLE RESEARCH: RUNNING ALL DEMOS")
    print("=" * 70)
    
    results = []
    for demo in demos:
        path = os.path.join(DEMO_DIR, demo)
        print(f"\n{'─'*70}")
        print(f"  Running: {demo}")
        print(f"{'─'*70}")
        
        try:
            result = subprocess.run(
                [sys.executable, path],
                capture_output=True, text=True, timeout=120
            )
            print(result.stdout)
            if result.stderr:
                print(f"  [stderr]: {result.stderr[:500]}")
            results.append((demo, result.returncode == 0))
        except subprocess.TimeoutExpired:
            print(f"  [TIMEOUT] {demo}")
            results.append((demo, False))
        except Exception as e:
            print(f"  [ERROR] {demo}: {e}")
            results.append((demo, False))
    
    print(f"\n{'='*70}")
    print("  SUMMARY")
    print(f"{'='*70}")
    for demo, success in results:
        status = "✓ PASS" if success else "✗ FAIL"
        print(f"  {status}  {demo}")
    
    passed = sum(1 for _, s in results if s)
    print(f"\n  {passed}/{len(results)} demos completed successfully")
    
    # List generated figures
    fig_dir = os.path.join(DEMO_DIR, '..', 'figures')
    if os.path.exists(fig_dir):
        figs = sorted(os.listdir(fig_dir))
        print(f"\n  Generated {len(figs)} figures:")
        for f in figs:
            size = os.path.getsize(os.path.join(fig_dir, f))
            print(f"    {f} ({size//1024} KB)")

if __name__ == '__main__':
    main()
