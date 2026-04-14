#!/usr/bin/env python3
"""
EML V8 Julia Set and Dynamics Visualizer

Computes and analyzes the Julia set of the diagonal map d(z) = exp(z) - log(z)
in the complex plane, along with dynamical system properties.

Usage: python eml_v8_julia_set.py
"""

import numpy as np
from typing import Tuple

def eml_diagonal_complex(z: complex, max_val: float = 1e10) -> complex:
    """Compute d(z) = exp(z) - log(z) for complex z"""
    try:
        if abs(z) < 1e-15:
            return complex(float('inf'))
        result = np.exp(z) - np.log(z)
        if abs(result) > max_val:
            return complex(max_val)
        return result
    except (OverflowError, ValueError):
        return complex(max_val)

def compute_escape_grid(
    x_range: Tuple[float, float] = (-3, 3),
    y_range: Tuple[float, float] = (-3, 3),
    resolution: int = 200,
    max_iter: int = 30,
    escape_radius: float = 100.0
) -> np.ndarray:
    """Compute escape time for each point in the complex plane"""
    x = np.linspace(x_range[0], x_range[1], resolution)
    y = np.linspace(y_range[0], y_range[1], resolution)
    escape_time = np.zeros((resolution, resolution))

    for i in range(resolution):
        for j in range(resolution):
            z = complex(x[j], y[i])
            for k in range(max_iter):
                try:
                    z = eml_diagonal_complex(z)
                    if abs(z) > escape_radius:
                        escape_time[i, j] = k + 1
                        break
                except:
                    escape_time[i, j] = k + 1
                    break
            else:
                escape_time[i, j] = max_iter

    return escape_time

def analyze_dynamics():
    """Analyze key dynamical properties of d(z) = exp(z) - log(z)"""
    print("EML V8 Julia Set Analysis")
    print("=" * 50)

    # 1. Fixed point analysis
    print("\n1. Fixed Point Analysis")
    print("   g(z) = e - ln(z), fixed point z* ≈ 2.017")
    z_star = 2.0
    for _ in range(100):
        z_star = np.e - np.log(z_star)
    print(f"   z* = {z_star:.12f}")
    print(f"   |g'(z*)| = 1/z* = {1/z_star:.12f} < 1 (attracting)")

    # 2. Diagonal map minimum
    from scipy.optimize import minimize_scalar
    result = minimize_scalar(lambda z: np.exp(z) - np.log(z), bounds=(0.01, 5), method='bounded')
    w1 = result.x
    print(f"\n2. Diagonal Map Minimum")
    print(f"   W(1) ≈ {w1:.12f} (Lambert W function)")
    print(f"   d(W(1)) = {np.exp(w1) - np.log(w1):.12f}")
    print(f"   d(W(1)) ≥ 2: {np.exp(w1) - np.log(w1) >= 2}")

    # 3. Orbit analysis from various points
    print(f"\n3. Orbit Analysis")
    for z0 in [0.1, 0.5, 1.0, 2.0, -0.5]:
        z = z0
        orbit = [z]
        for _ in range(5):
            if z <= 0:
                z = np.exp(z)
            else:
                z = np.exp(z) - np.log(z)
            orbit.append(z)
        print(f"   z₀ = {z0:5.1f}: orbit = {' → '.join(f'{v:.3f}' for v in orbit[:4])} → ...")

    # 4. Escape analysis
    print(f"\n4. Escape Time Statistics")
    grid = compute_escape_grid(resolution=100, max_iter=20)
    avg_escape = np.mean(grid)
    never_escaped = np.sum(grid == 20) / grid.size * 100
    print(f"   Average escape time: {avg_escape:.2f}")
    print(f"   Points not escaping in 20 iter: {never_escaped:.1f}%")
    print(f"   This suggests the Julia set has complex structure")

    # 5. Lyapunov exponent estimate
    print(f"\n5. Lyapunov Exponent (on real line)")
    z = 1.0
    lyap_sum = 0
    n_iter = 1000
    for _ in range(n_iter):
        if z > 0:
            deriv = np.exp(z) + 1/z  # |d'(z)| = |exp(z) + 1/z| (note the sign)
            lyap_sum += np.log(abs(deriv))
            z = np.exp(z) - np.log(z)
        else:
            z = np.exp(z)
            break
        if z > 1e100:
            break
    print(f"   λ ≈ {lyap_sum/n_iter:.4f} (positive → chaotic on real line)")
    print(f"   (Orbits diverge super-exponentially)")

if __name__ == "__main__":
    try:
        analyze_dynamics()
    except ImportError:
        print("Note: scipy not available, running basic analysis only")
        print("EML V8 Julia Set Analysis (basic mode)")

        z_star = 2.0
        for _ in range(100):
            z_star = np.e - np.log(z_star)
        print(f"Fixed point z* = {z_star:.12f}")
        print(f"|g'(z*)| = {1/z_star:.12f}")
