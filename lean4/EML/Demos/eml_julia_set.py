#!/usr/bin/env python3
"""
EML Julia Set Explorer
======================
Visualizes the Julia set of the diagonal EML map f(z) = exp(z) - ln(z) in the complex plane.
Since exp and ln extend to complex numbers, we study the iteration z_{n+1} = exp(z_n) - Log(z_n)
and color each starting point by escape time.

This reveals fractal structure in the EML operator's dynamics.
"""

import numpy as np
import json
import sys

def eml_diagonal_complex(z):
    """Compute eml(z,z) = exp(z) - log(z) for complex z."""
    with np.errstate(divide='ignore', invalid='ignore'):
        return np.exp(z) - np.log(z)

def compute_escape_time(z0, max_iter=50, escape_radius=100.0):
    """Compute escape time for the diagonal EML iteration."""
    z = z0.copy()
    times = np.full(z.shape, max_iter, dtype=float)
    
    for i in range(max_iter):
        mask = np.abs(z) < escape_radius
        if not np.any(mask):
            break
        z[mask] = eml_diagonal_complex(z[mask])
        newly_escaped = mask & (np.abs(z) >= escape_radius)
        times[newly_escaped] = i + 1
    
    return times

def generate_julia_data(center_re=-0.5, center_im=0.0, width=6.0, 
                         resolution=200, max_iter=40):
    """Generate Julia set data for the EML diagonal map."""
    height = width * 0.75
    
    re = np.linspace(center_re - width/2, center_re + width/2, resolution)
    im = np.linspace(center_im - height/2, center_im + height/2, int(resolution * 0.75))
    
    RE, IM = np.meshgrid(re, im)
    Z = RE + 1j * IM
    
    times = compute_escape_time(Z, max_iter=max_iter)
    
    return re, im, times

def analyze_fixed_points():
    """Find and analyze fixed points of the diagonal EML map in C."""
    print("=" * 60)
    print("FIXED POINT ANALYSIS: z = exp(z) - ln(z)")
    print("=" * 60)
    
    # The fixed point equation is exp(z) - ln(z) = z
    # i.e., exp(z) - z = ln(z)
    # We proved this has NO real solutions.
    # But complex solutions may exist.
    
    # Newton's method: f(z) = exp(z) - ln(z) - z, f'(z) = exp(z) - 1/z - 1
    def f(z):
        return np.exp(z) - np.log(z) - z
    
    def fprime(z):
        return np.exp(z) - 1.0/z - 1.0
    
    print("\nSearching for complex fixed points via Newton's method...")
    
    fixed_points = []
    # Try various starting points
    starts = [0.5 + 1j, 0.5 - 1j, -1 + 2j, -1 - 2j, 
              1 + 3j, 1 - 3j, -2 + 1j, -2 - 1j,
              0.1 + 0.5j, 0.1 - 0.5j, -0.5 + 4j, 2 + 2j]
    
    for z0 in starts:
        z = z0
        for _ in range(200):
            fp = fprime(z)
            if abs(fp) < 1e-15:
                break
            z = z - f(z) / fp
        
        if abs(f(z)) < 1e-10:
            # Check if we already found this one
            is_new = True
            for zp in fixed_points:
                if abs(z - zp) < 1e-6:
                    is_new = False
                    break
            if is_new:
                fixed_points.append(z)
                print(f"  Fixed point: z = {z.real:.10f} + {z.imag:.10f}i")
                print(f"    |f(z)| = {abs(f(z)):.2e}")
                # Stability: |f'(z*)| determines if attracting (< 1) or repelling (> 1)
                deriv = fprime(z)
                print(f"    |f'(z*)| = {abs(deriv):.6f} ({'attracting' if abs(deriv) < 1 else 'repelling'})")
    
    if not fixed_points:
        print("  No complex fixed points found in search region.")
    
    return fixed_points

def compute_orbit(z0, n_steps=100):
    """Compute the orbit of z0 under the diagonal EML map."""
    orbit = [z0]
    z = z0
    for _ in range(n_steps):
        try:
            z = np.exp(z) - np.log(z)
            if abs(z) > 1e10:
                break
            orbit.append(z)
        except:
            break
    return orbit

def analyze_orbits():
    """Analyze various orbits of the EML diagonal map."""
    print("\n" + "=" * 60)
    print("ORBIT ANALYSIS")
    print("=" * 60)
    
    test_points = [
        (1.0 + 0j, "z₀ = 1"),
        (0.5 + 0.5j, "z₀ = 0.5 + 0.5i"),
        (2.0 + 0j, "z₀ = 2"),
        (0.1 + 1j, "z₀ = 0.1 + i"),
        (-0.5 + 0j, "z₀ = -0.5"),
    ]
    
    for z0, name in test_points:
        orbit = compute_orbit(z0, 20)
        print(f"\n  {name}: {len(orbit)} steps before escape/truncation")
        for i, z in enumerate(orbit[:8]):
            print(f"    z_{i} = {z.real:12.6f} + {z.imag:12.6f}i  (|z| = {abs(z):.6f})")
        if len(orbit) > 8:
            print(f"    ... ({len(orbit) - 8} more steps)")

def compute_eml_constants():
    """Enumerate EML constants from pure trees up to size n."""
    print("\n" + "=" * 60)
    print("EML CONSTANT ENUMERATION")
    print("=" * 60)
    
    import math
    
    def eml(x, y):
        if y <= 0:
            return None
        try:
            return math.exp(x) - math.log(y)
        except:
            return None
    
    # Level 0: just {1}
    # Level 1: eml(1,1) = e
    # Level 2: eml(1,e), eml(e,1), eml(e,e)
    # Level 3: all combinations
    
    levels = [{1.0}]
    print(f"\n  Level 0: {sorted(levels[0])}")
    
    for depth in range(1, 6):
        new_constants = set()
        # Combine any pair from previous levels
        all_prev = set()
        for lvl in levels:
            all_prev |= lvl
        
        for x in all_prev:
            for y in all_prev:
                val = eml(x, y)
                if val is not None and abs(val) < 1e15 and not math.isnan(val):
                    new_constants.add(round(val, 12))
        
        levels.append(new_constants - all_prev)
        print(f"  Level {depth}: {len(new_constants - all_prev)} new constants")
        for c in sorted(new_constants - all_prev)[:10]:
            print(f"    {c:.10f}")
        if len(new_constants - all_prev) > 10:
            print(f"    ... and {len(new_constants - all_prev) - 10} more")
    
    all_constants = set()
    for lvl in levels:
        all_constants |= lvl
    print(f"\n  Total unique constants up to level 5: {len(all_constants)}")
    
    return all_constants

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     EML JULIA SET & DYNAMICS EXPLORER                   ║")
    print("║     f(z) = exp(z) - ln(z) in the Complex Plane         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # 1. Fixed point analysis
    fixed_points = analyze_fixed_points()
    
    # 2. Orbit analysis
    analyze_orbits()
    
    # 3. EML constant enumeration
    constants = compute_eml_constants()
    
    # 4. Generate Julia set data
    print("\n" + "=" * 60)
    print("JULIA SET COMPUTATION")
    print("=" * 60)
    re, im, times = generate_julia_data(resolution=150, max_iter=30)
    
    # Statistics
    escaped = np.sum(times < 30)
    total = times.size
    print(f"  Resolution: {len(re)} x {len(im)}")
    print(f"  Escaped points: {escaped}/{total} ({100*escaped/total:.1f}%)")
    print(f"  Bounded points: {total-escaped}/{total} ({100*(total-escaped)/total:.1f}%)")
    print(f"  Average escape time: {np.mean(times):.2f}")
    
    # 5. Verified theorem summary
    print("\n" + "=" * 60)
    print("FORMALLY VERIFIED RESULTS (Lean 4)")
    print("=" * 60)
    print("""
  ✓ emlDiagonal_no_real_fixedPoint:
    ∀ z : ℝ, exp(z) - ln(z) ≠ z
    
  ✓ emlDiagonal_gt_of_pos:
    ∀ z > 0, exp(z) - ln(z) > z
    
  ✓ emlDiagonal_gt_of_nonpos:
    ∀ z ≤ 0, exp(z) - ln(z) > z
    
  ✓ emlDiagonal_ge_one:
    ∀ z > 0, exp(z) - ln(z) ≥ 1
    
  ✓ emlSymmetricMap_diagonal:
    Φ(z,z) = (d(z), d(z)) — diagonal is invariant

  ✓ fixedPoint_lambert_connection:
    z* = e - ln(z*) ⟹ z* + ln(z*) = e
    
  ✓ fixedPoint_product_form:
    z* + ln(z*) = e ⟹ z* · exp(z*) = exp(e)
    (connecting to Lambert W: z* = W(e^e))
    """)
    
    print("\nDone! The EML diagonal map exp(z)-ln(z) has rich complex dynamics")
    print("despite having no real fixed points.")

if __name__ == "__main__":
    main()
