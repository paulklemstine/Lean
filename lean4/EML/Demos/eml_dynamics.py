#!/usr/bin/env python3
"""
EML Dynamics Explorer
=====================
Explores the dynamical systems properties of the EML operator,
including fixed points, iteration orbits, and basins of attraction.

This demo investigates what happens when we iterate EML as a dynamical map.
"""

import numpy as np
from typing import List, Tuple
import json

# ============================================================================
# Core EML
# ============================================================================

def eml(x: complex, y: complex) -> complex:
    """eml(x,y) = exp(x) - ln(y)"""
    return np.exp(x) - np.log(y)

# ============================================================================
# Fixed Point Analysis
# ============================================================================

def find_diagonal_fixed_points(n_tries: int = 1000, 
                                x_range: Tuple[float, float] = (-5, 5)):
    """
    Find fixed points of the diagonal map f(z) = eml(z, z) = exp(z) - ln(z).
    A fixed point satisfies exp(z) - ln(z) = z, i.e., exp(z) = z + ln(z).
    """
    print("=" * 60)
    print("FIXED POINTS OF DIAGONAL EML: f(z) = eml(z,z) = exp(z) - ln(z)")
    print("=" * 60)
    print("\nSearching for z such that exp(z) - ln(z) = z...")
    print("Equivalently: exp(z) = z + ln(z)\n")
    
    fixed_points = []
    
    for _ in range(n_tries):
        # Random starting point in complex plane
        z = complex(
            np.random.uniform(x_range[0], x_range[1]),
            np.random.uniform(x_range[0], x_range[1])
        )
        
        # Newton's method for g(z) = exp(z) - ln(z) - z = 0
        # g'(z) = exp(z) - 1/z - 1
        for _ in range(100):
            try:
                gz = np.exp(z) - np.log(z) - z
                gpz = np.exp(z) - 1/z - 1
                if abs(gpz) < 1e-15:
                    break
                z_new = z - gz / gpz
                if abs(z_new - z) < 1e-14:
                    z = z_new
                    break
                z = z_new
            except (OverflowError, ZeroDivisionError):
                break
        
        # Check if it's actually a fixed point
        try:
            residual = abs(np.exp(z) - np.log(z) - z)
            if residual < 1e-10 and abs(z) < 100:
                # Check if we already found this one
                is_new = True
                for fp in fixed_points:
                    if abs(z - fp) < 1e-6:
                        is_new = False
                        break
                if is_new:
                    fixed_points.append(z)
        except:
            pass
    
    if fixed_points:
        print(f"Found {len(fixed_points)} fixed point(s):\n")
        for i, fp in enumerate(fixed_points):
            residual = abs(np.exp(fp) - np.log(fp) - fp)
            stability = abs(np.exp(fp) - 1/fp)  # |g'(z)| at fixed point
            stable = "STABLE" if stability < 1 else "UNSTABLE"
            print(f"  z_{i} = {fp.real:+.10f} {fp.imag:+.10f}i")
            print(f"       |residual| = {residual:.2e}")
            print(f"       |f'(z)|    = {stability:.6f}  ({stable})")
            print()
    else:
        print("  No fixed points found in search range.")
    
    return fixed_points

# ============================================================================
# Orbit Analysis
# ============================================================================

def trace_orbit(z0: complex, n_steps: int = 50, mode: str = "diagonal"):
    """Trace the orbit of z under EML iteration."""
    orbit = [z0]
    z = z0
    
    for _ in range(n_steps):
        try:
            if mode == "diagonal":
                z = eml(z, z)
            elif mode == "right_fixed":
                z = eml(z, 1)  # This is just exp iteration
            elif mode == "left_fixed":
                z = eml(1, z)  # This is e - ln(z)
            
            if abs(z) > 1e100:
                break
            orbit.append(z)
        except:
            break
    
    return orbit

def explore_orbits():
    """Explore various EML iteration orbits."""
    print("\n" + "=" * 60)
    print("EML ORBIT ANALYSIS")
    print("=" * 60)
    
    # Mode 1: eml(z, 1) = exp(z) — always diverges for Re(z) > 0
    print("\n--- Mode: eml(z, 1) = exp(z) [exponential iteration] ---")
    for z0 in [0.5, 1.0, -1.0, 0.1j]:
        orbit = trace_orbit(complex(z0), n_steps=10, mode="right_fixed")
        print(f"  z₀ = {z0}: ", end="")
        for i, z in enumerate(orbit[:5]):
            print(f"{z.real:.4f}{z.imag:+.4f}i", end="  ")
        if len(orbit) > 5:
            print("... (diverges)")
        else:
            print("(diverges quickly)")
    
    # Mode 2: eml(1, z) = e - ln(z) — may have interesting dynamics
    print("\n--- Mode: eml(1, z) = e - ln(z) [log iteration] ---")
    for z0 in [0.5, 1.0, 2.0, 5.0, 0.1]:
        orbit = trace_orbit(complex(z0), n_steps=20, mode="left_fixed")
        print(f"  z₀ = {z0}: ", end="")
        vals = [z.real for z in orbit[:8]]
        for v in vals:
            print(f"{v:.6f}", end="  ")
        # Check for convergence
        if len(orbit) > 10:
            last_few = [z.real for z in orbit[-5:]]
            if max(last_few) - min(last_few) < 1e-6:
                print(f"→ converges to {last_few[-1]:.8f}")
            else:
                print("(oscillating)")
        print()
    
    # Mode 3: diagonal eml(z, z) = exp(z) - ln(z)
    print("\n--- Mode: eml(z, z) = exp(z) - ln(z) [diagonal] ---")
    for z0 in [0.1, 0.5, -0.5, 1.0]:
        orbit = trace_orbit(complex(z0), n_steps=10, mode="diagonal")
        print(f"  z₀ = {z0}: ", end="")
        for z in orbit[:4]:
            print(f"{z.real:.4f}", end="  ")
        print("... (diverges rapidly via double-exp)")

# ============================================================================
# 2D Map Analysis
# ============================================================================

def analyze_2d_map():
    """Analyze the 2D map (x,y) → (eml(x,y), eml(y,x))."""
    print("\n" + "=" * 60)
    print("2D EML MAP: (x,y) → (eml(x,y), eml(y,x))")
    print("=" * 60)
    
    print("\nThis symmetric 2D map swaps the roles of x and y.")
    print("Fixed points satisfy: eml(x,y) = x AND eml(y,x) = y")
    print("i.e., exp(x) - ln(y) = x AND exp(y) - ln(x) = y")
    print()
    
    # Search for fixed points using Newton's method
    fixed_points_2d = []
    
    for _ in range(500):
        x = complex(np.random.uniform(-2, 2), np.random.uniform(-1, 1))
        y = complex(np.random.uniform(-2, 2), np.random.uniform(-1, 1))
        
        for _ in range(200):
            try:
                f1 = np.exp(x) - np.log(y) - x
                f2 = np.exp(y) - np.log(x) - y
                
                if abs(f1) + abs(f2) < 1e-12:
                    break
                
                # Jacobian
                df1dx = np.exp(x) - 1
                df1dy = -1/y
                df2dx = -1/x
                df2dy = np.exp(y) - 1
                
                det = df1dx * df2dy - df1dy * df2dx
                if abs(det) < 1e-15:
                    break
                
                dx = (df2dy * f1 - df1dy * f2) / det
                dy = (df1dx * f2 - df2dx * f1) / det
                
                x -= dx
                y -= dy
                
                if abs(x) > 100 or abs(y) > 100:
                    break
            except:
                break
        
        try:
            r1 = abs(np.exp(x) - np.log(y) - x)
            r2 = abs(np.exp(y) - np.log(x) - y)
            if r1 + r2 < 1e-10 and abs(x) < 50 and abs(y) < 50:
                is_new = True
                for fx, fy in fixed_points_2d:
                    if abs(x - fx) + abs(y - fy) < 1e-4:
                        is_new = False
                        break
                if is_new:
                    fixed_points_2d.append((x, y))
        except:
            pass
    
    if fixed_points_2d:
        print(f"Found {len(fixed_points_2d)} fixed point(s) of the 2D map:\n")
        for i, (x, y) in enumerate(fixed_points_2d[:10]):
            print(f"  ({x.real:+.8f}{x.imag:+.8f}i, {y.real:+.8f}{y.imag:+.8f}i)")
    else:
        print("  No 2D fixed points found.")

# ============================================================================
# EML Number Theory: Which integers have short EML representations?
# ============================================================================

def eml_number_theory():
    """Explore which numbers arise from small EML trees."""
    print("\n" + "=" * 60)
    print("EML NUMBER THEORY: Constants from Small Trees")
    print("=" * 60)
    
    # Generate all constant EML expressions up to depth 3
    # with only terminal symbol 1
    
    results = {}
    
    # Depth 0
    results['1'] = 1.0
    
    # Depth 1
    results['eml(1,1)'] = np.exp(1) - np.log(1)  # = e
    
    # Depth 2
    d1 = np.exp(1)  # eml(1,1) = e
    depth2 = {
        'eml(eml(1,1), 1)': np.exp(d1) - np.log(1),      # exp(e)
        'eml(1, eml(1,1))': np.exp(1) - np.log(d1),       # e - 1
        'eml(eml(1,1), eml(1,1))': np.exp(d1) - np.log(d1),  # exp(e) - 1
    }
    results.update(depth2)
    
    # Depth 3 (selected)
    ee = np.exp(np.e)
    em1 = np.e - 1
    eem1 = np.exp(np.e) - 1
    
    depth3_inputs = {
        'eml(1,1)': np.e,
        'eml(eml(1,1),1)': ee,
        'eml(1,eml(1,1))': em1,
        'eml(eml(1,1),eml(1,1))': eem1,
        '1': 1.0
    }
    
    count = 0
    for name_l, val_l in depth3_inputs.items():
        for name_r, val_r in depth3_inputs.items():
            try:
                val = np.exp(complex(val_l)) - np.log(complex(val_r))
                label = f'eml({name_l}, {name_r})'
                if abs(val.imag) < 1e-10 and abs(val.real) < 1e15:
                    results[label] = val.real
                    count += 1
            except:
                pass
    
    # Sort by value and display
    sorted_results = sorted(results.items(), key=lambda x: x[1])
    
    print(f"\nDistinct real values from EML trees up to depth 3:")
    print(f"(Using only terminal symbol 1)\n")
    print(f"  {'Value':<25} {'Expression'}")
    print(f"  {'-'*70}")
    
    for expr, val in sorted_results[:30]:
        # Check if close to any known constant
        known = ""
        if abs(val - 0) < 1e-10: known = " = 0"
        elif abs(val - 1) < 1e-10: known = " = 1"
        elif abs(val - np.e) < 1e-10: known = " = e"
        elif abs(val - np.e + 1) < 1e-10: known = " = e-1"
        elif abs(val - np.exp(np.e)) < 1e-10: known = " = e^e"
        elif abs(val - np.exp(np.e) + 1) < 1e-10: known = " = e^e - 1"
        
        print(f"  {val:<25.10f} {expr}{known}")

# ============================================================================
# Main
# ============================================================================

def main():
    print("\n" + "╔" + "═" * 56 + "╗")
    print("║   EML DYNAMICS EXPLORER                                ║")
    print("║   Investigating iteration, fixed points, and orbits    ║")
    print("╚" + "═" * 56 + "╝\n")
    
    find_diagonal_fixed_points()
    explore_orbits()
    analyze_2d_map()
    eml_number_theory()
    
    print("\n" + "=" * 60)
    print("SUMMARY OF FINDINGS:")
    print("- The diagonal map eml(z,z) has complex fixed points")
    print("- The log iteration eml(1,z) can have convergent orbits")
    print("- The 2D symmetric map reveals rich fixed-point structure")
    print("- Small EML trees generate a sparse but structured set")
    print("  of real constants centered around powers of e")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()
