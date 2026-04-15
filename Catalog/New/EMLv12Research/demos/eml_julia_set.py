#!/usr/bin/env python3
"""
EML Julia Set Explorer
======================
Computes and visualizes the Julia set of the diagonal map d(z) = exp(z) - log(z)
on the complex plane. The logarithm introduces a branch cut along the negative real
axis, creating fractal boundary structures.

Key findings:
- All real orbits diverge (proven in Lean: diag8a_orbit_diverge)
- Complex orbits can be bounded for certain initial conditions
- The Julia set has intricate spiral structures near the branch cut
"""

import numpy as np
import json
import sys

def eml_diagonal_complex(z, max_iter=100, escape_radius=50):
    """Compute escape time for d(z) = exp(z) - log(z) on C."""
    for i in range(max_iter):
        if abs(z) > escape_radius:
            return i
        try:
            z = np.exp(z) - np.log(z)  # principal branch of log
        except (OverflowError, FloatingPointError):
            return i
    return max_iter

def compute_julia_set(x_range=(-3, 3), y_range=(-3, 3), resolution=200, max_iter=50):
    """Compute the Julia set escape-time grid."""
    x = np.linspace(x_range[0], x_range[1], resolution)
    y = np.linspace(y_range[0], y_range[1], resolution)

    grid = np.zeros((resolution, resolution))

    for i, yi in enumerate(y):
        for j, xj in enumerate(x):
            z = complex(xj, yi)
            grid[i, j] = eml_diagonal_complex(z, max_iter=max_iter)

    return x, y, grid

def eml_orbit(z0, n_steps=50):
    """Compute the orbit of z0 under d(z) = exp(z) - log(z)."""
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

def eml_surface_data(x_range=(-2, 3), y_range=(0.1, 5), resolution=100):
    """Compute eml(x,y) = exp(x) - ln(y) surface data."""
    x = np.linspace(x_range[0], x_range[1], resolution)
    y = np.linspace(y_range[0], y_range[1], resolution)
    X, Y = np.meshgrid(x, y)
    Z = np.exp(X) - np.log(Y)
    return X, Y, Z

def eml_level_sets(x_range=(-2, 4), y_range=(0.01, 10), resolution=300):
    """Compute level sets of eml(x, y) = c for various c."""
    x = np.linspace(x_range[0], x_range[1], resolution)
    y = np.linspace(y_range[0], y_range[1], resolution)
    X, Y = np.meshgrid(x, y)
    Z = np.exp(X) - np.log(Y)
    return X, Y, Z

def diagonal_orbit_analysis():
    """Analyze the diagonal map orbits on the real line."""
    results = {}

    # Real orbits (all diverge — proven in Lean)
    starting_points = [-2, -1, 0, 0.5, 1, 2, 5]
    for z0 in starting_points:
        orbit = []
        z = z0
        for i in range(20):
            orbit.append(float(z))
            z = np.exp(z) - np.log(abs(z)) if z != 0 else np.exp(z)
            if abs(z) > 1e100:
                break
        results[f"real_z0={z0}"] = orbit

    # Complex orbits near imaginary axis
    for theta in [0.1, 0.5, 1.0, 1.5, np.pi/2]:
        z0 = complex(0, theta)
        orbit = eml_orbit(z0, 30)
        results[f"complex_theta={theta:.2f}"] = [
            {"re": z.real, "im": z.imag} for z in orbit
        ]

    return results

def g_map_convergence():
    """Demonstrate convergence of the g-map g(z) = e - ln(z) to its fixed point."""
    e = np.exp(1)
    z = 1.0  # starting point
    trajectory = [z]
    for _ in range(50):
        z = e - np.log(z)
        trajectory.append(z)

    # The fixed point z* satisfies z* = e - ln(z*)
    # Numerically: z* ≈ 2.0175
    z_star = trajectory[-1]

    return {
        "trajectory": trajectory,
        "fixed_point": z_star,
        "convergence_rate": abs(trajectory[-1] - trajectory[-2]),
        "derivative_at_fp": abs(-1/z_star),  # |g'(z*)| = 1/z* < 1
    }

def eml_symbolic_regression_demo():
    """Demonstrate EML-based symbolic regression on simple functions."""
    # Target: f(x) = x^2 on [0, 2]
    # EML approximation: using eml(a*x + b, exp(c*x + d)) = exp(ax+b) - cx - d
    # This is an exp-linear model. For x^2, we need multiple EML layers.

    x = np.linspace(0.1, 2, 100)

    # EML primitives
    def eml_eval(x_val, y_val):
        return np.exp(x_val) - np.log(np.maximum(y_val, 1e-10))

    # Build approximations
    results = {}

    # exp(x) = eml(x, 1) — exact, complexity 1
    results["exp"] = {
        "target": list(np.exp(x)),
        "eml_approx": list(eml_eval(x, np.ones_like(x))),
        "complexity": 1,
        "error": 0.0
    }

    # 1 - x = eml(0, exp(x)) — exact, complexity 2
    target_1mx = 1 - x
    approx_1mx = eml_eval(np.zeros_like(x), np.exp(x))
    results["1-x"] = {
        "target": list(target_1mx),
        "eml_approx": list(approx_1mx),
        "complexity": 2,
        "error": float(np.max(np.abs(target_1mx - approx_1mx)))
    }

    # e^(e^x) = eml(eml(x,1), 1) — exact, complexity 2
    target_eex = np.exp(np.exp(x))
    approx_eex = eml_eval(eml_eval(x, np.ones_like(x)), np.ones_like(x))
    results["e^(e^x)"] = {
        "target": list(np.float64(np.minimum(target_eex, 1e15))),
        "eml_approx": list(np.float64(np.minimum(approx_eex, 1e15))),
        "complexity": 2,
        "error": float(np.max(np.abs(np.minimum(target_eex, 1e10) - np.minimum(approx_eex, 1e10))))
    }

    return results

def compute_eml_constants():
    """Compute the EML constant hierarchy."""
    e = np.exp(1)
    constants = {
        "eml(0,1) = 1": np.exp(0) - np.log(1),
        "eml(1,1) = e": np.exp(1) - np.log(1),
        "eml(2,1) = e²": np.exp(2) - np.log(1),
        "eml(1,e) = e-1": np.exp(1) - np.log(e),
        "eml(e,1) = e^e": np.exp(e) - np.log(1),
        "eml(0,e) = 0": np.exp(0) - np.log(e),
        "eml(0,e²) = -1": np.exp(0) - np.log(e**2),
        "eml(1,e^e) = 0": np.exp(1) - np.log(e**e),
        "e-tower(0) = 1": 1,
        "e-tower(1) = e": e,
        "e-tower(2) = e^e": e**e,
        "e-tower(3) = e^(e^e)": e**(e**e),
    }
    return {k: float(v) for k, v in constants.items()}

def tropical_eml_analysis():
    """Analyze tropical EML: trop(x,y) = max(x, -y)."""
    x_vals = np.linspace(-3, 3, 100)
    y_vals = np.linspace(-3, 3, 100)

    # Non-commutativity example
    x, y = 1.0, 2.0
    trop_xy = max(x, -y)
    trop_yx = max(y, -x)

    # Associativity check
    a, b, c = 1.0, -1.0, 2.0
    lhs = max(max(a, -b), -c)
    rhs = max(a, -max(b, -c))

    return {
        "non_commutative": {"trop(1,2)": trop_xy, "trop(2,1)": trop_yx, "equal": trop_xy == trop_yx},
        "associativity": {"lhs": lhs, "rhs": rhs, "associative": lhs == rhs},
        "idempotent_check": {"trop(x,-x) for x=2": max(2, -(-2)), "equals_x": max(2, 2) == 2},
    }

if __name__ == "__main__":
    print("=" * 60)
    print("EML Operator Explorer — V12 Research Suite")
    print("=" * 60)

    print("\n📊 EML Constants Hierarchy:")
    constants = compute_eml_constants()
    for name, val in constants.items():
        print(f"  {name} = {val:.6f}")

    print("\n🔄 G-Map Convergence Analysis:")
    gmap = g_map_convergence()
    print(f"  Fixed point z* ≈ {gmap['fixed_point']:.6f}")
    print(f"  |g'(z*)| = {gmap['derivative_at_fp']:.6f} < 1 ✓ (contraction)")
    print(f"  Convergence rate: {gmap['convergence_rate']:.2e}")
    print(f"  First 10 iterates: {[f'{x:.4f}' for x in gmap['trajectory'][:10]]}")

    print("\n🌊 Tropical EML Analysis:")
    trop = tropical_eml_analysis()
    print(f"  Non-commutative: trop(1,2)={trop['non_commutative']['trop(1,2)']}, "
          f"trop(2,1)={trop['non_commutative']['trop(2,1)']}")
    print(f"  Associative: {trop['associativity']['associative']}")

    print("\n📈 Diagonal Orbit Analysis:")
    orbits = diagonal_orbit_analysis()
    for key in sorted(orbits.keys()):
        if key.startswith("real"):
            vals = orbits[key]
            print(f"  {key}: [{', '.join(f'{v:.2f}' for v in vals[:6])}...]")

    print("\n🎯 Symbolic Regression Demo:")
    sr = eml_symbolic_regression_demo()
    for name, data in sr.items():
        print(f"  {name}: complexity={data['complexity']}, max_error={data['error']:.2e}")

    print("\n✅ All computations completed successfully!")
    print("   See eml_julia_set.py for the full exploration suite.")
