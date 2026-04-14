#!/usr/bin/env python3
"""
EML Julia Set & Dynamics Visualizer
====================================
Computes the Julia set of d(z) = exp(z) - log(z) on the complex plane,
the Mandelbrot-like parameter space, and orbit diagrams.
"""

import math
import cmath

# ── Complex EML dynamics ─────────────────────────────────────────────

def d_complex(z):
    """d(z) = exp(z) - log(z) for complex z."""
    try:
        return cmath.exp(z) - cmath.log(z)
    except (ValueError, OverflowError):
        return complex(float('inf'), float('inf'))

def escape_time(z0, max_iter=100, escape_radius=50.0):
    """Compute escape time for d iteration."""
    z = z0
    for i in range(max_iter):
        try:
            z = d_complex(z)
            if abs(z) > escape_radius:
                return i
        except (ValueError, OverflowError):
            return i
    return max_iter

# ── ASCII Julia set ──────────────────────────────────────────────────

def ascii_julia(x_range=(-3, 5), y_range=(-4, 4), width=80, height=40):
    """Print ASCII art Julia set of d(z)."""
    chars = " .:-=+*#%@"
    max_iter = len(chars) - 1

    print("Julia Set of d(z) = exp(z) - log(z)")
    print(f"Region: [{x_range[0]}, {x_range[1]}] × [{y_range[0]}i, {y_range[1]}i]")
    print()

    for j in range(height):
        line = ""
        y = y_range[1] - (y_range[1] - y_range[0]) * j / height
        for i in range(width):
            x = x_range[0] + (x_range[1] - x_range[0]) * i / width
            z0 = complex(x, y)
            t = escape_time(z0, max_iter=max_iter * 3, escape_radius=50)
            idx = min(t * len(chars) // (max_iter * 3 + 1), len(chars) - 1)
            line += chars[idx]
        print(line)

# ── Orbit analysis ───────────────────────────────────────────────────

def compute_orbit(z0, n_iter=20):
    """Compute the orbit of z0 under d."""
    orbit = [z0]
    z = z0
    for _ in range(n_iter):
        try:
            z = d_complex(z)
            if abs(z) > 1e15:
                break
            orbit.append(z)
        except (ValueError, OverflowError):
            break
    return orbit

print("=" * 80)
print("EML JULIA SET & DYNAMICS ANALYSIS")
print("=" * 80)

# Show orbits for various starting points
print("\n── ORBIT ANALYSIS ──")
starting_points = [
    complex(0.5, 0),
    complex(1, 0),
    complex(2, 0),
    complex(0, 1),
    complex(1, 1),
    complex(-1, 0.5),
]

for z0 in starting_points:
    orbit = compute_orbit(z0, 10)
    print(f"\nz₀ = {z0}")
    for i, z in enumerate(orbit[:8]):
        print(f"  d^{i}(z₀) = {z.real:10.4f} + {z.imag:10.4f}i  (|z| = {abs(z):.4f})")
    if len(orbit) < 10:
        print(f"  → Escaped after {len(orbit)} iterations")
    else:
        print(f"  → Still bounded after {len(orbit)} iterations")

# Fixed point of g(z) = e - ln(z) on the real line
print("\n── REAL FIXED POINT OF g(z) = e - ln(z) ──")
z = 3.0
for i in range(30):
    z = math.e - math.log(z)
z_star = z
print(f"z* ≈ {z_star:.12f}")
print(f"z* + ln(z*) ≈ {z_star + math.log(z_star):.12f}")
print(f"e ≈ {math.e:.12f}")
print(f"|g'(z*)| = 1/z* ≈ {1/z_star:.6f} < 1 (contractive)")

# ASCII Julia set
print("\n── JULIA SET (ASCII) ──")
ascii_julia(x_range=(-2, 4), y_range=(-3, 3), width=70, height=30)

# Diagonal map minimum analysis
print("\n── DIAGONAL MAP MINIMUM ──")
print("d(z) = exp(z) - ln(z), d'(z) = exp(z) - 1/z")
print("Critical point: z₀ = W(1) ≈ 0.5671")
from functools import reduce

# Newton's method for d'(z) = 0
z = 0.5
for _ in range(50):
    # d'(z) = exp(z) - 1/z, d''(z) = exp(z) + 1/z²
    dp = math.exp(z) - 1/z
    dpp = math.exp(z) + 1/(z*z)
    z -= dp / dpp

z_crit = z
print(f"W(1) ≈ {z_crit:.10f}")
print(f"d(W(1)) ≈ {diag_val:.10f}" if (diag_val := math.exp(z_crit) - math.log(z_crit)) else "")
print(f"d(W(1)) ≈ {math.exp(z_crit) - math.log(z_crit):.10f}")
print(f"Verification: z·exp(z) = {z_crit * math.exp(z_crit):.10f} (should be 1)")
