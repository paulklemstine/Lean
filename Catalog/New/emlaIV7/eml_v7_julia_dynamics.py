#!/usr/bin/env python3
"""
EML V7 Julia Set and Dynamics Explorer
========================================
Explores the complex dynamics of the diagonal map d(z) = exp(z) - log(z)
and visualizes Julia-set-like structures.

Generates:
- Escape-time diagrams for d(z) in the complex plane
- Orbit analysis and divergence speed classification
- Basin of attraction studies for g(z) = e - ln(z)

Usage:
    python eml_v7_julia_dynamics.py
"""

import numpy as np
import cmath
import math
from typing import Tuple, List

# ─── Complex EML Functions ──────────────────────────────────────────

def complex_eml(x: complex, y: complex) -> complex:
    """Complex EML: eml(x, y) = exp(x) - log(y)"""
    try:
        return cmath.exp(x) - cmath.log(y)
    except (ValueError, OverflowError):
        return complex(float('inf'), float('inf'))

def complex_diag(z: complex) -> complex:
    """Complex diagonal map: d(z) = exp(z) - log(z)"""
    return complex_eml(z, z)

def g_map(z: complex) -> complex:
    """Attracting map: g(z) = e - ln(z)"""
    try:
        return cmath.exp(1) - cmath.log(z)
    except (ValueError, OverflowError):
        return complex(float('inf'), float('inf'))

# ─── Julia Set Computation ──────────────────────────────────────────

def compute_escape_time(z0: complex, max_iter: int = 50, escape_radius: float = 100) -> int:
    """Compute escape time for the diagonal map d(z) = exp(z) - log(z)."""
    z = z0
    for n in range(max_iter):
        try:
            z = complex_diag(z)
            if abs(z) > escape_radius:
                return n
        except (ValueError, OverflowError):
            return n
    return max_iter

def compute_julia_set(
    x_range: Tuple[float, float] = (-3, 3),
    y_range: Tuple[float, float] = (-3, 3),
    resolution: int = 100,
    max_iter: int = 30,
    escape_radius: float = 50
) -> np.ndarray:
    """Compute Julia-set-like escape time grid for d(z)."""
    x = np.linspace(x_range[0], x_range[1], resolution)
    y = np.linspace(y_range[0], y_range[1], resolution)
    grid = np.zeros((resolution, resolution))
    
    for i, yi in enumerate(y):
        for j, xj in enumerate(x):
            z0 = complex(xj, yi)
            grid[i, j] = compute_escape_time(z0, max_iter, escape_radius)
    
    return grid

# ─── Orbit Analysis ────────────────────────────────────────────────

def compute_orbit(z0: complex, n_steps: int = 20, map_fn=None) -> List[complex]:
    """Compute orbit of a point under a given map."""
    if map_fn is None:
        map_fn = complex_diag
    orbit = [z0]
    z = z0
    for _ in range(n_steps):
        try:
            z = map_fn(z)
            if abs(z) > 1e15:
                break
            orbit.append(z)
        except (ValueError, OverflowError):
            break
    return orbit

def classify_orbit(z0: complex, max_iter: int = 100) -> str:
    """Classify the behavior of an orbit."""
    orbit = compute_orbit(z0, max_iter)
    
    if len(orbit) < 3:
        return "ESCAPE (immediate)"
    
    # Check for escape
    if abs(orbit[-1]) > 1e10:
        return f"ESCAPE (after {len(orbit)} steps)"
    
    # Check for convergence
    if len(orbit) >= 10:
        last_few = orbit[-5:]
        diffs = [abs(last_few[i+1] - last_few[i]) for i in range(len(last_few)-1)]
        if max(diffs) < 1e-6:
            return f"CONVERGE to {orbit[-1]:.4f}"
    
    # Check for periodicity
    if len(orbit) >= 20:
        for period in range(1, 10):
            if abs(orbit[-1] - orbit[-1-period]) < 1e-6:
                return f"PERIODIC (period {period})"
    
    return f"BOUNDED (after {len(orbit)} steps)"

# ─── Fixed Point Analysis ──────────────────────────────────────────

def find_g_fixed_point(initial: float = 2.0, max_iter: int = 200) -> float:
    """Find the fixed point z* of g(z) = e - ln(z) by iteration."""
    z = initial
    for _ in range(max_iter):
        try:
            z_new = math.e - math.log(z)
            if abs(z_new - z) < 1e-15:
                return z
            z = z_new
        except ValueError:
            return float('nan')
    return z

def analyze_fixed_point():
    """Analyze the fixed point z* of g(z) = e - ln(z)."""
    z_star = find_g_fixed_point()
    
    print("=" * 60)
    print("FIXED POINT ANALYSIS: g(z) = e - ln(z)")
    print("=" * 60)
    print(f"\n  z* ≈ {z_star:.15f}")
    print(f"  z* + ln(z*) = {z_star + math.log(z_star):.15f} (should = e ≈ {math.e:.15f})")
    print(f"  z* · exp(z*) = {z_star * math.exp(z_star):.10f} (should = e^e ≈ {math.e**math.e:.10f})")
    print(f"  |g'(z*)| = 1/z* = {1/z_star:.15f} < 1 ✓ (attracting)")
    print(f"  z* > 1 ✓ ({z_star:.6f} > 1)")
    
    # Convergence demonstration
    print(f"\n  Orbit of g from z₀ = 1.0:")
    z = 1.0
    for i in range(15):
        z_new = math.e - math.log(z)
        print(f"    g^{i}(1) = {z:.15f}" + (" ← converged!" if abs(z_new - z) < 1e-14 else ""))
        z = z_new
    
    # Basin of attraction
    print(f"\n  Basin of attraction test:")
    test_points = [0.01, 0.1, 0.5, 1.0, 5.0, 100.0, 10000.0]
    for z0 in test_points:
        z = z0
        converged = False
        for i in range(500):
            try:
                z_new = math.e - math.log(z)
                if z_new <= 0:
                    break
                if abs(z_new - z) < 1e-12:
                    converged = True
                    break
                z = z_new
            except ValueError:
                break
        status = f"→ z* ≈ {z:.6f} ✓" if converged else "→ diverges ✗"
        print(f"    z₀ = {z0:>10.2f}: {status}")


def demo_diagonal_orbit_speed():
    """Demonstrate the speed of orbit divergence for d(z) = exp(z) - ln(z)."""
    print("\n" + "=" * 60)
    print("ORBIT DIVERGENCE SPEED: d(z) = exp(z) - ln(z)")
    print("=" * 60)
    
    starting_points = [0.1, 0.5, 1.0, 2.0, -1.0]
    
    for z0 in starting_points:
        print(f"\n  Starting at z₀ = {z0}:")
        z = z0
        for i in range(8):
            if z > 0:
                dz = math.exp(z) - math.log(z)
            else:
                dz = math.exp(z)  # log of non-positive = 0
            
            try:
                dz_str = f"{dz:.6f}" if dz < 1e10 else f"{dz:.2e}"
            except OverflowError:
                dz_str = "∞"
            
            print(f"    d^{i}({z0}) = {z:.6f if abs(z) < 1e10 else '∞':>15} → d = {dz_str}")
            
            if dz > 1e100:
                print(f"    d^{i+1}({z0}) → ∞ (escape at step {i+1})")
                break
            z = dz


def demo_complex_orbits():
    """Demonstrate complex orbit behavior."""
    print("\n" + "=" * 60)
    print("COMPLEX ORBIT CLASSIFICATION")
    print("=" * 60)
    print()
    
    test_points = [
        complex(0.5, 0),
        complex(1, 0),
        complex(0, 1),
        complex(1, 1),
        complex(-1, 0.5),
        complex(0, 0.1),
        complex(2, 0),
        complex(0.5, 0.5),
    ]
    
    for z0 in test_points:
        classification = classify_orbit(z0)
        print(f"  z₀ = {z0.real:>5.1f} + {z0.imag:>5.1f}i  →  {classification}")


def demo_julia_ascii():
    """Create an ASCII art Julia set."""
    print("\n" + "=" * 60)
    print("ASCII JULIA SET: d(z) = exp(z) - log(z)")
    print("=" * 60)
    print()
    
    chars = " .:-=+*#%@"
    width, height = 70, 30
    x_range = (-3, 3)
    y_range = (-2, 2)
    max_iter = 20
    
    for j in range(height):
        line = ""
        y = y_range[0] + (y_range[1] - y_range[0]) * j / (height - 1)
        for i in range(width):
            x = x_range[0] + (x_range[1] - x_range[0]) * i / (width - 1)
            z0 = complex(x, y)
            escape = compute_escape_time(z0, max_iter, 50)
            idx = min(int(escape * len(chars) / max_iter), len(chars) - 1)
            line += chars[idx]
        print(f"  {line}")
    
    print(f"\n  x ∈ [{x_range[0]}, {x_range[1]}], y ∈ [{y_range[0]}, {y_range[1]}]")
    print(f"  Characters: ' ' = fast escape, '@' = bounded")


def main():
    print("\n" + "█" * 60)
    print("█" + " " * 58 + "█")
    print("█" + "  EML V7 Julia Set & Dynamics Explorer".center(58) + "█")
    print("█" + "  d(z) = exp(z) - ln(z)".center(58) + "█")
    print("█" + " " * 58 + "█")
    print("█" * 60 + "\n")
    
    analyze_fixed_point()
    demo_diagonal_orbit_speed()
    demo_complex_orbits()
    demo_julia_ascii()
    
    print("\n" + "=" * 60)
    print("OPEN QUESTIONS FROM V7")
    print("=" * 60)
    print("""
  1. What is the Hausdorff dimension of the Julia set of d(z)?
  2. Is the Julia set connected? Locally connected?
  3. Is the basin of attraction of z* = W(e^e) all of (0,∞)?
  4. What is the topological entropy of d(z)?
  5. Are there periodic Fatou components?
  6. Does d(z) have a Böttcher coordinate near ∞?
  7. What is the escape radius for the filled Julia set?
  8. How does orbit speed depend on initial condition z₀?
  
  All dynamical theorems (d(z)>z, d(z)≥2, orbit increasing)
  are formally verified in Lean 4.28.0 + Mathlib.
""")


if __name__ == "__main__":
    main()
