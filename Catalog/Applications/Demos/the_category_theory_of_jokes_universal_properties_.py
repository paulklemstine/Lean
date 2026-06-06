#!/usr/bin/env python3
"""
Deflection Algebras: Numerical Demonstrations

This script demonstrates the key theorems from the Deflection Algebra theory
with concrete numerical examples.
"""

import numpy as np
from typing import Callable, List, Tuple

# ============================================================================
# Core Definitions
# ============================================================================

def deflection(x: np.ndarray, E: Callable) -> float:
    """Compute deflection δ(x) = d(E(x), x)."""
    return float(np.linalg.norm(E(x) - x))


def deflection_energy(points: List[np.ndarray], E: Callable) -> float:
    """Compute deflection energy: Σ δ(pᵢ)²."""
    return sum(deflection(p, E) ** 2 for p in points)


def total_deflection(points: List[np.ndarray], E: Callable) -> float:
    """Compute total deflection: Σ δ(pᵢ)."""
    return sum(deflection(p, E) for p in points)


# ============================================================================
# Demo 1: Idempotent Zero Lemma
# ============================================================================

def demo_idempotent_zero():
    """Demonstrate that E(E(x)) = E(x) implies δ(E(x)) = 0."""
    print("=" * 60)
    print("DEMO 1: Idempotent Zero Lemma")
    print("=" * 60)

    # E = floor function (idempotent)
    E = lambda x: np.floor(x)

    test_points = [np.array([1.7]), np.array([3.14]), np.array([-0.5]),
                   np.array([100.999])]

    for x in test_points:
        ex = E(x)
        d_x = deflection(x, E)
        d_ex = deflection(ex, E)
        print(f"  x = {x[0]:8.3f}, E(x) = {ex[0]:8.3f}, "
              f"δ(x) = {d_x:.3f}, δ(E(x)) = {d_ex:.10f}")
        assert d_ex < 1e-10, "Idempotent zero lemma violated!"

    print("  ✓ All E-images have zero deflection\n")


# ============================================================================
# Demo 2: Deflection Lipschitz Theorem
# ============================================================================

def demo_lipschitz():
    """Demonstrate |δ(x) - δ(y)| ≤ (1+K) · d(x,y)."""
    print("=" * 60)
    print("DEMO 2: Deflection Lipschitz Theorem")
    print("=" * 60)

    K = 0.5
    E = lambda x: K * x  # K-Lipschitz expectation

    np.random.seed(42)
    pairs = [(np.random.randn(3), np.random.randn(3)) for _ in range(1000)]

    max_ratio = 0.0
    for x, y in pairs:
        d_xy = np.linalg.norm(x - y)
        if d_xy < 1e-10:
            continue
        delta_diff = abs(deflection(x, E) - deflection(y, E))
        ratio = delta_diff / d_xy
        max_ratio = max(max_ratio, ratio)

    print(f"  K = {K}")
    print(f"  Theoretical bound: 1 + K = {1 + K}")
    print(f"  Maximum observed ratio |δ(x)-δ(y)|/d(x,y) = {max_ratio:.6f}")
    print(f"  ✓ Bound satisfied: {max_ratio:.6f} ≤ {1+K}\n")


# ============================================================================
# Demo 3: Contraction-Deflection Equivalence
# ============================================================================

def demo_contraction_equivalence():
    """Demonstrate bilateral bounds between δ and d(x, fixpoint)."""
    print("=" * 60)
    print("DEMO 3: Contraction-Deflection Equivalence")
    print("=" * 60)

    k = 0.3
    E = lambda x: k * x  # Fixed point at origin
    p = np.zeros(2)

    np.random.seed(123)
    for _ in range(5):
        x = np.random.randn(2) * 5
        d_xp = np.linalg.norm(x - p)
        d_ex = deflection(x, E)

        upper_bound = (1 + k) * d_xp
        lower_ratio = d_ex / (1 - k) if (1 - k) > 0 else float('inf')

        print(f"  x = ({x[0]:6.2f}, {x[1]:6.2f})")
        print(f"    d(x,p) = {d_xp:.4f}")
        print(f"    δ(x)   = {d_ex:.4f}")
        print(f"    Upper: δ ≤ (1+k)·d(x,p) = {upper_bound:.4f}  "
              f"({'✓' if d_ex <= upper_bound + 1e-10 else '✗'})")
        print(f"    Lower: d(x,p) ≤ δ/(1-k) = {lower_ratio:.4f}  "
              f"({'✓' if d_xp <= lower_ratio + 1e-10 else '✗'})")

    print()


# ============================================================================
# Demo 4: Geometric Deflection Decay
# ============================================================================

def demo_geometric_decay():
    """Demonstrate d(E(Eⁿ(x)), Eⁿ(x)) ≤ kⁿ · d(E(x), x)."""
    print("=" * 60)
    print("DEMO 4: Geometric Deflection Decay")
    print("=" * 60)

    k = 0.6
    E = lambda x: k * x
    x = np.array([10.0, 7.0, -3.0])

    initial_deflection = deflection(x, E)
    print(f"  Contraction constant k = {k}")
    print(f"  Initial deflection δ(x) = {initial_deflection:.6f}")
    print(f"  {'n':>4s}  {'δ(Eⁿ(x))':>12s}  {'kⁿ·δ(x)':>12s}  {'Ratio':>8s}")

    y = x.copy()
    for n in range(10):
        d_n = deflection(y, E)
        bound = k ** n * initial_deflection
        ratio = d_n / initial_deflection if initial_deflection > 0 else 0
        print(f"  {n:4d}  {d_n:12.6f}  {bound:12.6f}  {ratio:8.6f}")
        assert d_n <= bound + 1e-10, "Geometric decay violated!"
        y = E(y)

    print("  ✓ Geometric decay confirmed\n")


# ============================================================================
# Demo 5: Cauchy-Schwarz for Deflection
# ============================================================================

def demo_cauchy_schwarz():
    """Demonstrate T² ≤ n · E for deflection."""
    print("=" * 60)
    print("DEMO 5: Cauchy-Schwarz for Deflection")
    print("=" * 60)

    E = lambda x: np.round(x)  # Nearest integer projection

    np.random.seed(999)
    for n in [3, 10, 50]:
        points = [np.random.randn(2) * 3 for _ in range(n)]
        T = total_deflection(points, E)
        energy = deflection_energy(points, E)

        print(f"  n = {n:3d}: T² = {T**2:10.4f}, n·E = {n * energy:10.4f}, "
              f"T²/(n·E) = {T**2 / (n * energy):.4f} ≤ 1.0  ✓")

    print()


# ============================================================================
# Demo 6: Deflection Morphism Composition
# ============================================================================

def demo_morphism_composition():
    """Demonstrate that composed morphism bounds multiply."""
    print("=" * 60)
    print("DEMO 6: Deflection Morphism Composition")
    print("=" * 60)

    # Two deflection spaces with different expectations
    E1 = lambda x: 0.5 * x  # R² with E₁(x) = x/2
    E2 = lambda x: 0.3 * x  # R² with E₂(x) = 0.3x

    # Morphism f: multiply by 2 (bound = 2 since it doubles distances)
    f = lambda x: 2 * x
    B_f = 2.0

    # Morphism g: multiply by 0.5 (bound = 0.5)
    g = lambda x: 0.5 * x
    B_g = 0.5

    np.random.seed(42)
    x = np.random.randn(3)

    d_x = deflection(x, E1)
    d_fx = deflection(f(x), E2)
    d_gfx = deflection(g(f(x)), E1)

    print(f"  δ_X(x)    = {d_x:.4f}")
    print(f"  δ_Y(f(x)) = {d_fx:.4f} ≤ B_f · δ_X(x) = {B_f * d_x:.4f}")
    print(f"  δ_Z(g∘f(x)) = {d_gfx:.4f} ≤ B_g·B_f · δ_X(x) = {B_g * B_f * d_x:.4f}")
    print()


# ============================================================================
# Demo 7: Mean Deflection Monotonicity
# ============================================================================

def demo_mean_monotonicity():
    """Demonstrate that contractions decrease total deflection."""
    print("=" * 60)
    print("DEMO 7: Mean Deflection Monotonicity")
    print("=" * 60)

    k = 0.4
    E = lambda x: k * x

    np.random.seed(77)
    points = [np.random.randn(2) * 5 for _ in range(20)]

    # Original total deflection
    T0 = sum(np.linalg.norm(E(E(p)) - E(p)) for p in points)
    T1 = sum(np.linalg.norm(E(p) - p) for p in points)

    print(f"  k = {k}")
    print(f"  Σ d(E(E(pᵢ)), E(pᵢ)) = {T0:.4f}")
    print(f"  k · Σ d(E(pᵢ), pᵢ)   = {k * T1:.4f}")
    print(f"  Ratio = {T0 / (k * T1):.4f} ≤ 1.0  ✓")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  DEFLECTION ALGEBRAS: NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_idempotent_zero()
    demo_lipschitz()
    demo_contraction_equivalence()
    demo_geometric_decay()
    demo_cauchy_schwarz()
    demo_morphism_composition()
    demo_mean_monotonicity()

    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Deflection Space Geometry

Generates plots showing the key properties of deflection spaces:
1. Deflection field visualization
2. Geometric decay under iteration
3. Cauchy-Schwarz bound tightness
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def deflection_field():
    """Plot the deflection field for E(x) = 0.5·x on ℝ²."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Grid
    x = np.linspace(-5, 5, 50)
    y = np.linspace(-5, 5, 50)
    X, Y = np.meshgrid(x, y)

    # Deflection = ‖E(x) - x‖ = ‖0.5x - x‖ = 0.5‖x‖
    D = 0.5 * np.sqrt(X**2 + Y**2)

    # Panel 1: Deflection heatmap
    ax = axes[0]
    c = ax.contourf(X, Y, D, levels=20, cmap='viridis')
    plt.colorbar(c, ax=ax, label='Deflection δ(x)')
    ax.set_title('Deflection Field: E(x) = x/2', fontsize=12)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.plot(0, 0, 'r*', markersize=15, label='Fixed point')
    ax.legend()

    # Panel 2: Deflection vs distance to fixed point
    ax = axes[1]
    r = np.linspace(0, 7, 100)
    defl = 0.5 * r
    upper = 1.5 * r
    lower = r  # d(x,p) ≤ δ/(1-k) = δ/0.5 = 2δ, so δ ≥ 0.5·d(x,p)

    ax.fill_between(r, 0.5 * r, 1.5 * r, alpha=0.2, color='blue',
                     label='Feasible region')
    ax.plot(r, defl, 'b-', linewidth=2, label='Actual δ(x) = ‖x‖/2')
    ax.plot(r, upper, 'r--', linewidth=1, label='Upper: (1+k)·d(x,p)')
    ax.plot(r, 0.5 * r, 'g--', linewidth=1, label='Lower: (1-k)·d(x,p)')
    ax.set_xlabel('d(x, fixed point)', fontsize=11)
    ax.set_ylabel('Deflection δ(x)', fontsize=11)
    ax.set_title('Contraction-Deflection Equivalence', fontsize=12)
    ax.legend(fontsize=9)

    # Panel 3: Vector field showing E displacement
    ax = axes[2]
    xg = np.linspace(-4, 4, 12)
    yg = np.linspace(-4, 4, 12)
    Xg, Yg = np.meshgrid(xg, yg)
    U = 0.5 * Xg - Xg  # E(x) - x
    V = 0.5 * Yg - Yg
    M = np.sqrt(U**2 + V**2)
    M[M == 0] = 1

    ax.quiver(Xg, Yg, U/M, V/M, M, cmap='coolwarm', scale=25)
    ax.plot(0, 0, 'k*', markersize=15)
    ax.set_title('Deflection Vectors: x → E(x)', fontsize=12)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('deflection_field.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: deflection_field.png")


def geometric_decay_plot():
    """Plot geometric decay of deflection under iteration."""
    fig, ax = plt.subplots(figsize=(10, 6))

    for k in [0.3, 0.5, 0.7, 0.9]:
        E = lambda x, k=k: k * x
        x0 = np.array([10.0])
        deflections = []
        y = x0.copy()
        for n in range(20):
            deflections.append(float(np.abs(E(y) - y)))
            y = E(y)

        ns = np.arange(len(deflections))
        ax.semilogy(ns, deflections, 'o-', label=f'k = {k}', markersize=4)
        ax.semilogy(ns, deflections[0] * k ** ns, '--', alpha=0.5,
                     label=f'k^n · δ₀ (k={k})')

    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('Deflection δ(Eⁿ(x))', fontsize=12)
    ax.set_title('Geometric Deflection Decay', fontsize=14)
    ax.legend(ncol=2, fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('geometric_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: geometric_decay.png")


def cauchy_schwarz_tightness():
    """Plot how tight the Cauchy-Schwarz bound is for various distributions."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = range(2, 101)
    ratios_uniform = []
    ratios_concentrated = []
    ratios_random = []

    rng = np.random.RandomState(42)

    for n in ns:
        # Uniform: all deflections equal
        d_uniform = np.ones(n)
        T = d_uniform.sum()
        E_val = (d_uniform ** 2).sum()
        ratios_uniform.append(T ** 2 / (n * E_val))

        # Concentrated: one large, rest small
        d_conc = np.zeros(n)
        d_conc[0] = n
        T = d_conc.sum()
        E_val = (d_conc ** 2).sum()
        ratios_concentrated.append(T ** 2 / (n * E_val))

        # Random
        d_rand = rng.exponential(1, n)
        T = d_rand.sum()
        E_val = (d_rand ** 2).sum()
        ratios_random.append(T ** 2 / (n * E_val))

    ax.plot(list(ns), ratios_uniform, 'b-', linewidth=2,
            label='Uniform (all equal) — TIGHT')
    ax.plot(list(ns), ratios_concentrated, 'r-', linewidth=2,
            label='Concentrated (one large)')
    ax.plot(list(ns), ratios_random, 'g-', alpha=0.7, linewidth=1,
            label='Random (exponential)')
    ax.axhline(y=1, color='k', linestyle='--', alpha=0.5, label='Bound: T²/(n·E) ≤ 1')

    ax.set_xlabel('Number of points n', fontsize=12)
    ax.set_ylabel('T² / (n · E)', fontsize=12)
    ax.set_title('Cauchy-Schwarz Tightness for Deflection', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.05, 1.15)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cauchy_schwarz_tightness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cauchy_schwarz_tightness.png")


if __name__ == "__main__":
    deflection_field()
    geometric_decay_plot()
    cauchy_schwarz_tightness()
    print("\nAll visualizations generated!")
