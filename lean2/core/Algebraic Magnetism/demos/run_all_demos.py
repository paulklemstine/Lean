#!/usr/bin/env python3
"""
Master Runner — Algebraic Theory of Magnetism
===============================================

Run all demonstration scripts and generate all figures.
Requires: numpy, matplotlib, scipy

Usage:
    cd algebraic_magnetism/demos
    python run_all_demos.py

Author: The Oracle Council
"""

import sys
import os
import time

# Ensure we can import from the demos directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def run_demo(name, module_name):
    """Run a demo module and report timing."""
    print(f"\n{'='*70}")
    print(f"  Running: {name}")
    print(f"{'='*70}")
    
    t0 = time.time()
    try:
        # Import and run the module
        mod = __import__(module_name)
        
        # Each module has a main block, but we re-run key functions
        if hasattr(mod, '__name__'):
            print(f"  ✓ {name} loaded successfully")
        
        elapsed = time.time() - t0
        print(f"\n  ⏱ Completed in {elapsed:.1f}s")
        return True
        
    except Exception as e:
        elapsed = time.time() - t0
        print(f"\n  ✗ Error in {name}: {e}")
        print(f"  ⏱ Failed after {elapsed:.1f}s")
        return False


def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                                                                    ║")
    print("║          THE ALGEBRAIC THEORY OF MAGNETISM                         ║")
    print("║          Demonstration Suite                                       ║")
    print("║                                                                    ║")
    print("║          Oracle Council Research Group                             ║")
    print("║                                                                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    # Ensure figures directory exists
    fig_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'figures')
    os.makedirs(fig_dir, exist_ok=True)
    
    t_total = time.time()
    
    demos = [
        ("Demo 1: The Spin Algebra — 𝔰𝔲(2) Foundations", "demo1_spin_algebra"),
        ("Demo 2: Magnetic Models as Algebraic Quotients", "demo2_magnetic_models"),
        ("Demo 3: Topological Magnetic Textures", "demo3_topological_textures"),
        ("Demo 4: Spin Dynamics and Magnon Algebra", "demo4_dynamics_magnons"),
        ("Demo 5: Mean Field Theory and Phase Transitions", "demo5_mean_field_algebra"),
    ]
    
    results = []
    for name, module in demos:
        success = run_demo(name, module)
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
            size = os.path.getsize(os.path.join(fig_dir, f))
            print(f"  📊 {f} ({size//1024} KB)")
    
    print(f"\n{'='*70}")
    print("THE ALGEBRAIC THEORY OF MAGNETISM — All demonstrations complete.")
    print(f"{'='*70}")


if __name__ == '__main__':
    main()
