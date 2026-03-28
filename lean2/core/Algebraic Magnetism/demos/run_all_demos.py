#!/usr/bin/env python3
"""
Master Runner — Algebraic Theory of Magnetism
===============================================

Run all demonstration scripts and generate all figures.
Requires: numpy, matplotlib, scipy

Usage:
    cd "Algebraic Magnetism/demos"
    python run_all_demos.py

Author: The Oracle Council
"""

import sys
import os
import time
import subprocess

# Ensure we can import from the demos directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def run_demo_subprocess(name, script_name):
    """Run a demo as a subprocess to avoid import caching issues."""
    print(f"\n{'='*70}")
    print(f"  Running: {name}")
    print(f"{'='*70}")
    
    t0 = time.time()
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), script_name)
    
    try:
        result = subprocess.run(
            [sys.executable, script_path],
            capture_output=True, text=True, timeout=300,
            cwd=os.path.dirname(os.path.abspath(__file__))
        )
        
        if result.stdout:
            # Print last few lines
            lines = result.stdout.strip().split('\n')
            for line in lines[-10:]:
                print(f"    {line}")
        
        elapsed = time.time() - t0
        
        if result.returncode == 0:
            print(f"\n  ✓ Completed in {elapsed:.1f}s")
            return True
        else:
            print(f"\n  ✗ Error (exit code {result.returncode})")
            if result.stderr:
                print(f"    {result.stderr[-200:]}")
            return False
            
    except subprocess.TimeoutExpired:
        print(f"\n  ✗ Timed out after 300s")
        return False
    except Exception as e:
        elapsed = time.time() - t0
        print(f"\n  ✗ Error: {e}")
        return False


def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                                                                    ║")
    print("║          THE ALGEBRAIC THEORY OF MAGNETISM                         ║")
    print("║          Demonstration Suite — Complete Edition                     ║")
    print("║                                                                    ║")
    print("║          Oracle Council Research Group                             ║")
    print("║                                                                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    # Ensure figures directory exists
    fig_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'figures')
    os.makedirs(fig_dir, exist_ok=True)
    
    t_total = time.time()
    
    demos = [
        ("Demo 1: The Spin Algebra — 𝔰𝔲(2) Foundations", "demo1_spin_algebra.py"),
        ("Demo 2: Magnetic Models as Algebraic Quotients", "demo2_magnetic_models.py"),
        ("Demo 3: Topological Magnetic Textures", "demo3_topological_textures.py"),
        ("Demo 4: Spin Dynamics and Magnon Algebra", "demo4_dynamics_magnons.py"),
        ("Demo 5: Mean Field Theory and Phase Transitions", "demo5_mean_field_algebra.py"),
        ("Demo 6: PREDICTION 1 — Higher Multipole Magnets", "demo6_multipole_magnets.py"),
        ("Demo 7: PREDICTION 2 — Algebraic Spin Liquids", "demo7_spin_liquids.py"),
        ("Demo 8: PREDICTION 3 — Designer Magnets", "demo8_designer_magnets.py"),
    ]
    
    results = []
    for name, script in demos:
        success = run_demo_subprocess(name, script)
        results.append((name, success))
    
    # Summary
    elapsed_total = time.time() - t_total
    print(f"\n\n{'='*70}")
    print("SUMMARY")
    print(f"{'='*70}")
    
    for name, success in results:
        status = "✓ PASSED" if success else "✗ FAILED"
        print(f"  {status}: {name}")
    
    n_passed = sum(1 for _, s in results if s)
    n_total = len(results)
    print(f"\n  {n_passed}/{n_total} demos completed successfully")
    print(f"  Total time: {elapsed_total:.1f}s")
    
    # List generated figures
    print(f"\n--- Generated Figures ---")
    if os.path.exists(fig_dir):
        figs = sorted(os.listdir(fig_dir))
        for f in figs:
            if f.endswith('.png'):
                size = os.path.getsize(os.path.join(fig_dir, f))
                print(f"  📊 {f} ({size//1024} KB)")
    
    print(f"\n  Total figures: {len([f for f in figs if f.endswith('.png')])} PNG files")
    
    print(f"\n{'='*70}")
    print("THE ALGEBRAIC THEORY OF MAGNETISM — All demonstrations complete.")
    print(f"{'='*70}")


if __name__ == '__main__':
    main()
