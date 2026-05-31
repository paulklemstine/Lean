#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Demonstration Script

Demonstrates key results from the formalization:
1. Conformal factor properties
2. Möbius transformations preserving the disk
3. Lattice point counting for PSL(2,Z)
4. Hyperbolic area growth
5. Hyperbolic zeta function computation
"""

import math
from algorithms import (
    poincare_cf, mobius_map, hyp_dist, hyp_area,
    lattice_count_psl2z, hyp_zeta_partial,
    test_lattice_growth, conformal_factor_along_radius,
    hyp_area_vs_euclidean, enumerate_psl2z
)


def demo_conformal_factor():
    """Demonstrate conformal factor properties."""
    print("=" * 60)
    print("1. POINCARÉ CONFORMAL FACTOR λ(z) = 2/(1-|z|²)")
    print("=" * 60)

    print("\nλ(0) = {:.4f}  (should be 2.0)".format(poincare_cf(0)))

    print("\nMonotonicity along real axis:")
    for r in [0.0, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        z = complex(r, 0)
        print(f"  |z| = {r:.2f}  →  λ(z) = {poincare_cf(z):.4f}")

    print("\nDivergence at boundary: λ(z) → ∞ as |z| → 1")
    for r in [0.999, 0.9999, 0.99999]:
        z = complex(r, 0)
        print(f"  |z| = {r}  →  λ(z) = {poincare_cf(z):.2f}")


def demo_mobius():
    """Demonstrate Möbius transformations."""
    print("\n" + "=" * 60)
    print("2. MÖBIUS TRANSFORMATIONS φ_a(z) = (z-a)/(1-ā·z)")
    print("=" * 60)

    a = complex(0.3, 0.4)
    print(f"\na = {a},  |a| = {abs(a):.4f}")
    print(f"φ_a(a) = {mobius_map(a, a):.6f}  (should be 0)")
    print(f"φ_0(z) = z: φ_0(0.5+0.3i) = {mobius_map(0, 0.5+0.3j)}")

    print("\nDisk preservation: |z| < 1 → |φ_a(z)| < 1")
    test_points = [0.1+0.2j, 0.5+0.3j, -0.4+0.6j, 0.8+0.1j]
    for z in test_points:
        w = mobius_map(a, z)
        print(f"  z = {z}, |z| = {abs(z):.4f} → φ_a(z) = {w:.4f}, |φ_a(z)| = {abs(w):.4f}")


def demo_hyperbolic_distance():
    """Demonstrate hyperbolic distance."""
    print("\n" + "=" * 60)
    print("3. HYPERBOLIC DISTANCE d_H(z,w) = 2·artanh(|φ_w(z)|)")
    print("=" * 60)

    print("\nd_H(z, z) = 0:")
    z = complex(0.3, 0.4)
    print(f"  d_H({z}, {z}) = {hyp_dist(z, z):.10f}")

    print("\nDistance from origin: d_H(r, 0) = 2·artanh(r)")
    for r in [0.1, 0.3, 0.5, 0.7, 0.9]:
        d = hyp_dist(complex(r, 0), 0)
        expected = 2 * math.atanh(r)
        print(f"  r = {r:.1f}: d_H = {d:.6f}, 2·artanh(r) = {expected:.6f}")


def demo_lattice_counting():
    """Demonstrate lattice point counting for PSL(2,Z)."""
    print("\n" + "=" * 60)
    print("4. LATTICE COUNTING FOR PSL(2,ℤ)")
    print("=" * 60)

    print("\nN(R) = #{γ ∈ PSL(2,ℤ) : d_H(i, γ·i) ≤ R}")
    print("\nSelberg-Huber prediction: N(R) ~ e^R / (π/3) = 3e^R/π")
    print(f"\n{'R':>6} {'N(R)':>10} {'3eᴿ/π':>12} {'Ratio':>8}")
    print("-" * 40)

    for R in [1.0, 2.0, 3.0, 4.0, 5.0]:
        N = lattice_count_psl2z(R)
        predicted = 3.0 * math.exp(R) / math.pi
        ratio = N / predicted if predicted > 0 else 0
        print(f"{R:6.1f} {N:10d} {predicted:12.1f} {ratio:8.4f}")


def demo_hyperbolic_area():
    """Demonstrate hyperbolic area growth."""
    print("\n" + "=" * 60)
    print("5. HYPERBOLIC AREA: A(R) = 2π(cosh R - 1)")
    print("=" * 60)

    print(f"\nA(0) = {hyp_area(0):.6f}  (should be 0)")

    print(f"\n{'R':>6} {'A_hyp(R)':>12} {'π·eᴿ':>12} {'Ratio':>8}")
    print("-" * 42)
    for R in [0.5, 1.0, 2.0, 3.0, 5.0, 10.0]:
        A = hyp_area(R)
        bound = math.pi * math.exp(R)
        ratio = A / bound
        print(f"{R:6.1f} {A:12.2f} {bound:12.2f} {ratio:8.4f}")

    print("\nNote: A(R)/πeᴿ → 1 as R → ∞ (exponential growth)")


def demo_zeta():
    """Demonstrate hyperbolic zeta function."""
    print("\n" + "=" * 60)
    print("6. HYPERBOLIC ZETA FUNCTION ζ_H(s)")
    print("=" * 60)

    print("\nPartial sums for PSL(2,ℤ), R_max = 5.0:")
    print(f"\n{'s':>6} {'ζ_H(s)':>12}")
    print("-" * 20)
    for s in [0.6, 0.8, 1.0, 1.5, 2.0, 3.0]:
        zeta = hyp_zeta_partial(5.0, s)
        print(f"{s:6.1f} {zeta:12.6f}")


def demo_growth_conjecture():
    """Test the lattice growth conjecture."""
    print("\n" + "=" * 60)
    print("7. TESTING LATTICE GROWTH CONJECTURE")
    print("=" * 60)

    print("\nConjecture: N(R) · (π/3) / e^R → 1 as R → ∞")
    print(f"\n{'R':>6} {'N(R)':>10} {'N·V/eᴿ':>12}")
    print("-" * 30)

    results = test_lattice_growth([1.0, 2.0, 3.0, 4.0, 5.0])
    for R, N, ratio in results:
        print(f"{R:6.1f} {N:10d} {ratio:12.6f}")

    print("\nThe ratio should approach 1 as R increases.")
    print("(For small R, finite-size effects cause deviations.)")


if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════╗")
    print("║  HYPERBOLIC NUMBER THEORY: ARITHMETIC ON THE DISK     ║")
    print("╚════════════════════════════════════════════════════════╝")

    demo_conformal_factor()
    demo_mobius()
    demo_hyperbolic_distance()
    demo_lattice_counting()
    demo_hyperbolic_area()
    demo_zeta()
    demo_growth_conjecture()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Poincaré Disk Tessellation and Lattice Points

Self-contained matplotlib visualization showing:
1. The Poincaré disk with conformal factor heatmap
2. PSL(2,Z) orbit points (hyperbolic integers)
3. Conformal factor divergence at boundary
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def poincare_cf(x, y):
    """Conformal factor at point (x, y) in the disk."""
    r2 = x**2 + y**2
    if r2 >= 1.0:
        return float('nan')
    return 2.0 / (1.0 - r2)


def mobius_map(a, z):
    """Möbius automorphism φ_a(z) = (z-a)/(1-conj(a)*z)."""
    denom = 1.0 - a.conjugate() * z
    if abs(denom) < 1e-15:
        return complex(float('inf'))
    return (z - a) / denom


def upper_half_to_disk(z):
    """Map z from upper half-plane to Poincaré disk."""
    return (z - 1j) / (z + 1j)


def sl2z_action(a, b, c, d, z):
    """Action of [[a,b],[c,d]] on z in upper half-plane."""
    denom = c * z + d
    if abs(denom) < 1e-15:
        return complex(float('inf'))
    return (a * z + b) / denom


def enumerate_sl2z_orbit(R_max, basepoint=1j):
    """Enumerate PSL(2,Z) orbit of basepoint in disk coordinates."""
    bound = 2.0 * math.cosh(R_max)
    max_val = int(math.sqrt(bound)) + 1
    points = []
    dists = []

    for a in range(-max_val, max_val + 1):
        for b in range(-max_val, max_val + 1):
            for c in range(-max_val, max_val + 1):
                for d in range(-max_val, max_val + 1):
                    if a * d - b * c != 1:
                        continue
                    trace_sq = a*a + b*b + c*c + d*d
                    if trace_sq > bound:
                        continue
                    # Map basepoint
                    w = sl2z_action(a, b, c, d, basepoint)
                    if w.imag <= 0:
                        continue
                    # Convert to disk
                    p = upper_half_to_disk(w)
                    if abs(p) < 1.0:
                        dist = 2.0 * math.acosh(max(1.0, trace_sq / 2.0))
                        points.append(p)
                        dists.append(dist)

    return points, dists


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Conformal factor heatmap
    ax1 = axes[0]
    N = 400
    x = np.linspace(-1, 1, N)
    y = np.linspace(-1, 1, N)
    X, Y = np.meshgrid(x, y)
    Z = np.full_like(X, np.nan)

    for i in range(N):
        for j in range(N):
            r2 = X[i, j]**2 + Y[i, j]**2
            if r2 < 0.99:
                Z[i, j] = np.log10(2.0 / (1.0 - r2))

    im = ax1.pcolormesh(X, Y, Z, cmap='inferno', shading='auto')
    circle = plt.Circle((0, 0), 1, fill=False, color='white', linewidth=2)
    ax1.add_patch(circle)
    ax1.set_xlim(-1.1, 1.1)
    ax1.set_ylim(-1.1, 1.1)
    ax1.set_aspect('equal')
    ax1.set_title('Conformal Factor log₁₀(λ)', fontsize=14)
    ax1.set_xlabel('Re(z)')
    ax1.set_ylabel('Im(z)')
    plt.colorbar(im, ax=ax1, label='log₁₀(λ(z))')

    # Panel 2: PSL(2,Z) lattice points on disk
    ax2 = axes[1]
    circle2 = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax2.add_patch(circle2)

    points, dists = enumerate_sl2z_orbit(5.0)
    if points:
        xs = [p.real for p in points]
        ys = [p.imag for p in points]
        cs = dists
        sc = ax2.scatter(xs, ys, c=cs, cmap='viridis', s=15, alpha=0.8,
                         edgecolors='none')
        plt.colorbar(sc, ax=ax2, label='d_H(i, γ·i)')

    # Mark origin (image of i)
    bp = upper_half_to_disk(1j)
    ax2.plot(bp.real, bp.imag, 'r*', markersize=15, label='basepoint (i)')
    ax2.set_xlim(-1.1, 1.1)
    ax2.set_ylim(-1.1, 1.1)
    ax2.set_aspect('equal')
    ax2.set_title('PSL(2,ℤ) Lattice Points', fontsize=14)
    ax2.set_xlabel('Re(z)')
    ax2.set_ylabel('Im(z)')
    ax2.legend(loc='upper right', fontsize=10)

    # Panel 3: Area growth comparison
    ax3 = axes[2]
    R_vals = np.linspace(0.01, 6, 100)
    hyp_areas = [2 * math.pi * (math.cosh(R) - 1) for R in R_vals]
    exp_bounds = [math.pi * math.exp(R) for R in R_vals]
    euc_areas = [math.pi * math.tanh(R/2)**2 for R in R_vals]

    ax3.semilogy(R_vals, hyp_areas, 'b-', linewidth=2, label='A_hyp(R) = 2π(cosh R - 1)')
    ax3.semilogy(R_vals, exp_bounds, 'r--', linewidth=2, label='π·e^R (upper bound)')
    ax3.semilogy(R_vals, euc_areas, 'g-.', linewidth=2, label='π·tanh²(R/2) (Euclidean)')
    ax3.set_xlabel('Hyperbolic radius R', fontsize=12)
    ax3.set_ylabel('Area', fontsize=12)
    ax3.set_title('Hyperbolic vs Euclidean Area', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('poincare_disk_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: poincare_disk_visualization.png")


if __name__ == "__main__":
    main()
