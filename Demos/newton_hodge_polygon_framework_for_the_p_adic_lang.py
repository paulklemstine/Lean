#!/usr/bin/env python3
"""
Newton-Hodge Polygon Framework — Demonstration

Explores the monodromy defect invariant for 2-dimensional filtered φ-modules
in the p-adic Langlands correspondence for GL₂(ℚ_p).
"""

import math


def monodromy_defect(w1: float, w2: float, s1: float, s2: float) -> float:
    """Compute the monodromy defect δ = s₁ - w₁."""
    return s1 - w1


def is_weakly_admissible(w1: float, w2: float, s1: float, s2: float,
                          tol: float = 1e-10) -> bool:
    """Check weak admissibility: w₁ ≤ s₁ ≤ s₂ and s₁+s₂ = w₁+w₂."""
    return (w1 <= s1 + tol and s1 <= s2 + tol and
            abs((s1 + s2) - (w1 + w2)) < tol)


def admissibility_polytope_points(w1: float, w2: float, n: int = 50):
    """Generate n points in the admissibility polytope parameterized by δ."""
    max_delta = (w2 - w1) / 2.0
    points = []
    for i in range(n + 1):
        delta = max_delta * i / n
        s1 = w1 + delta
        s2 = w2 - delta
        points.append((s1, s2, delta))
    return points


def tropical_distance(p: tuple, q: tuple) -> float:
    """Compute tropical L∞ distance between two slope pairs."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def slope_discriminant(s1: float, s2: float) -> float:
    """Compute the slope discriminant (s₁ - s₂)²."""
    return (s1 - s2) ** 2


def main():
    print("=" * 70)
    print("Newton-Hodge Polygon Framework — Numerical Demonstrations")
    print("=" * 70)

    # Example 1: Weight 12 modular form (like Ramanujan Δ)
    print("\n--- Example 1: Weight 12 modular form (Hodge-Tate weights 0, 11) ---")
    w1, w2 = 0, 11
    print(f"Hodge-Tate weights: ({w1}, {w2})")
    print(f"Spectral gap: {w2 - w1}")
    print(f"Max monodromy defect: {(w2 - w1) / 2}")

    # Ordinary case
    s1_ord, s2_ord = 0, 11
    delta_ord = monodromy_defect(w1, w2, s1_ord, s2_ord)
    print(f"\n  Ordinary case: slopes ({s1_ord}, {s2_ord})")
    print(f"    δ = {delta_ord}")
    print(f"    Admissible: {is_weakly_admissible(w1, w2, s1_ord, s2_ord)}")
    print(f"    Discriminant: {slope_discriminant(s1_ord, s2_ord)}")

    # Supersingular case
    s1_ss, s2_ss = 5.5, 5.5
    delta_ss = monodromy_defect(w1, w2, s1_ss, s2_ss)
    print(f"\n  Supersingular case: slopes ({s1_ss}, {s2_ss})")
    print(f"    δ = {delta_ss}")
    print(f"    Admissible: {is_weakly_admissible(w1, w2, s1_ss, s2_ss)}")
    print(f"    Discriminant: {slope_discriminant(s1_ss, s2_ss)}")

    # Intermediate case
    s1_int, s2_int = 3, 8
    delta_int = monodromy_defect(w1, w2, s1_int, s2_int)
    print(f"\n  Intermediate case: slopes ({s1_int}, {s2_int})")
    print(f"    δ = {delta_int}")
    print(f"    Admissible: {is_weakly_admissible(w1, w2, s1_int, s2_int)}")
    print(f"    Discriminant: {slope_discriminant(s1_int, s2_int)}")

    # Verify symmetry: δ = s₁ - w₁ = w₂ - s₂
    print(f"    Symmetry check: s₁ - w₁ = {s1_int - w1}, w₂ - s₂ = {w2 - s2_int}")

    # Example 2: Admissibility polytope
    print("\n--- Example 2: Admissibility Polytope for weights (0, 11) ---")
    points = admissibility_polytope_points(w1, w2, n=10)
    print(f"  {'δ':>6} | {'s₁':>8} | {'s₂':>8} | {'Δ':>10} | {'Admissible':>10}")
    print(f"  {'-'*6}-+-{'-'*8}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}")
    for s1, s2, delta in points:
        disc = slope_discriminant(s1, s2)
        adm = is_weakly_admissible(w1, w2, s1, s2)
        print(f"  {delta:6.2f} | {s1:8.3f} | {s2:8.3f} | {disc:10.3f} | {str(adm):>10}")

    # Example 3: Tropical distance
    print("\n--- Example 3: Tropical Distance on the Polytope ---")
    p1 = (w1 + 1.0, w2 - 1.0)  # δ₁ = 1
    p2 = (w1 + 3.0, w2 - 3.0)  # δ₂ = 3
    d = tropical_distance(p1, p2)
    print(f"  Point 1: slopes {p1}, δ₁ = 1.0")
    print(f"  Point 2: slopes {p2}, δ₂ = 3.0")
    print(f"  Tropical distance: {d}")
    print(f"  |δ₁ - δ₂|: {abs(1.0 - 3.0)}")
    print(f"  Match: {abs(d - abs(1.0 - 3.0)) < 1e-10}")

    # Example 4: Slope midpoint conjecture test
    print("\n--- Example 4: Slope Midpoint Conjecture Test ---")
    for k in range(2, 20):
        w1_k, w2_k = 0, k - 1
        mid = (w1_k + w2_k) / 2.0
        adm = is_weakly_admissible(w1_k, w2_k, mid, mid)
        print(f"  k={k:2d}: weights (0, {k-1:2d}), "
              f"midpoint slope = {mid:5.1f}, admissible = {adm}")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Newton-Hodge Polygons and the Monodromy Defect

Generates a multi-panel figure showing:
1. Newton vs Hodge polygons for ordinary/intermediate/supersingular cases
2. The admissibility polytope parameterized by δ
3. Discriminant as a function of δ
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def newton_polygon_values(s1: float, s2: float) -> tuple:
    """Return (x, y) arrays for the Newton polygon."""
    return np.array([0, 1, 2]), np.array([0, s1, s1 + s2])


def hodge_polygon_values(w1: float, w2: float) -> tuple:
    """Return (x, y) arrays for the Hodge polygon."""
    return np.array([0, 1, 2]), np.array([0, w1, w1 + w2])


def main():
    w1, w2 = 0, 11  # Weight 12 modular form

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Newton vs Hodge polygons for three cases
    ax = axes[0]
    hx, hy = hodge_polygon_values(w1, w2)
    ax.plot(hx, hy, 'k-o', linewidth=2.5, label='Hodge polygon', markersize=8)

    cases = [
        (0, 11, 'Ordinary (δ=0)', 'tab:blue', '--'),
        (3, 8, 'Intermediate (δ=3)', 'tab:orange', '-.'),
        (5.5, 5.5, 'Supersingular (δ=5.5)', 'tab:red', ':'),
    ]
    for s1, s2, label, color, ls in cases:
        nx, ny = newton_polygon_values(s1, s2)
        ax.plot(nx, ny, linestyle=ls, color=color, linewidth=2, label=label,
                marker='s', markersize=6)

    ax.set_xlabel('Vertex index', fontsize=12)
    ax.set_ylabel('Polygon value', fontsize=12)
    ax.set_title('Newton vs Hodge Polygons', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Panel 2: Admissibility polytope
    ax = axes[1]
    deltas = np.linspace(0, (w2 - w1) / 2, 100)
    s1_vals = w1 + deltas
    s2_vals = w2 - deltas

    ax.fill_between(s1_vals, s2_vals, alpha=0.2, color='tab:green',
                     label='Admissibility polytope')
    ax.plot(s1_vals, s2_vals, 'tab:green', linewidth=2)
    ax.plot([w1], [w2], 'bo', markersize=10, label='Ordinary', zorder=5)
    ax.plot([(w1+w2)/2], [(w1+w2)/2], 'r^', markersize=10,
            label='Supersingular', zorder=5)
    ax.plot([3], [8], 'ks', markersize=8, label='Example (δ=3)', zorder=5)

    ax.set_xlabel('s₁ (first Newton slope)', fontsize=12)
    ax.set_ylabel('s₂ (second Newton slope)', fontsize=12)
    ax.set_title('Admissibility Polytope', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Panel 3: Discriminant and defect
    ax = axes[2]
    discriminants = (s1_vals - s2_vals) ** 2
    ax.plot(deltas, discriminants, 'tab:purple', linewidth=2.5,
            label='Δ = (s₁−s₂)²')
    ax.axhline(y=0, color='gray', linewidth=0.8)
    ax.axvline(x=0, color='tab:blue', linewidth=1, linestyle='--',
               alpha=0.7, label='Ordinary (δ=0)')
    ax.axvline(x=(w2-w1)/2, color='tab:red', linewidth=1, linestyle='--',
               alpha=0.7, label='Supersingular')

    ax.set_xlabel('Monodromy defect δ', fontsize=12)
    ax.set_ylabel('Slope discriminant Δ', fontsize=12)
    ax.set_title('Discriminant vs Defect', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('newton_hodge_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: newton_hodge_visualization.png")


if __name__ == "__main__":
    main()
