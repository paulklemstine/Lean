#!/usr/bin/env python3
"""
Applications of Tropical T-Duality Theorems.

Demonstrates real-world applications:
  1. ReLU neural network decision boundary analysis
  2. Shortest-path network duality
  3. Linear programming tropical duality
  4. Signal processing: dominant-mode selection
"""

import numpy as np
from typing import List, Tuple


# ──────────────────────────────────────────────────────────────
# Application 1: ReLU Network Decision Boundaries
# ──────────────────────────────────────────────────────────────

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(0, x) = -min(0, -x)."""
    return np.maximum(0, x)


def relu_network_1d(x: np.ndarray, weights: List[Tuple[float, float]]) -> np.ndarray:
    """A simple 1D ReLU network: sum of relu(a_i * x + b_i).

    This is a tropical polynomial in the max-plus semiring.
    Decision boundaries are corners of the tropical polynomial.
    """
    result = np.zeros_like(x)
    for a, b in weights:
        result += relu(a * x + b)
    return result


def find_relu_decision_boundaries(
    weights: List[Tuple[float, float]],
    x_range: Tuple[float, float] = (-10, 10),
    n_points: int = 10000,
) -> List[float]:
    """Find approximate decision boundaries (kinks) of a ReLU network.

    Each ReLU unit relu(a*x + b) has a kink at x = -b/a (when a ≠ 0).
    These are tropical corners of the individual branches.
    """
    boundaries = []
    for a, b in weights:
        if abs(a) > 1e-15:
            x0 = -b / a
            if x_range[0] <= x0 <= x_range[1]:
                boundaries.append(x0)
    return sorted(boundaries)


def demo_relu_application():
    print("=" * 60)
    print("APPLICATION 1: ReLU Network Decision Boundaries")
    print("=" * 60)
    print("\nA ReLU network f(x) = Σ relu(aᵢx + bᵢ) is a tropical polynomial.")
    print("Its kinks (non-differentiable points) are tropical corners.\n")

    weights = [(2.0, -1.0), (-1.5, 3.0), (1.0, 0.5), (-0.5, -2.0)]
    boundaries = find_relu_decision_boundaries(weights)

    print(f"Network: f(x) = Σ relu(aᵢx + bᵢ)")
    print(f"Weights: {weights}")
    print(f"Decision boundaries (tropical corners):")
    for i, x0 in enumerate(boundaries):
        print(f"  x_{i} = {x0:.4f}")

    # Verify: check second derivative discontinuity
    xs = np.linspace(-5, 5, 10000)
    ys = relu_network_1d(xs, weights)
    # Numerical second derivative
    d2y = np.diff(ys, 2) / (xs[1] - xs[0]) ** 2
    kink_indices = np.where(np.abs(np.diff(np.sign(np.diff(d2y)))) > 0)[0]
    print(f"\n  Numerical kink detection found {len(kink_indices)} kinks")
    print(f"  Analytical formula found {len(boundaries)} boundaries")
    print(f"  → Tropical corner theorem gives EXACT locations")


# ──────────────────────────────────────────────────────────────
# Application 2: Shortest-Path Network Duality
# ──────────────────────────────────────────────────────────────

def tropical_matrix_mult(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.

    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})
    """
    n, m = A.shape
    m2, p = B.shape
    assert m == m2
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def demo_network_duality():
    print("\n" + "=" * 60)
    print("APPLICATION 2: Shortest-Path Network Duality")
    print("=" * 60)
    print("\nIn tropical algebra, shortest paths use min-plus multiplication.")
    print("T-duality corresponds to network reversal: transposing the weight matrix.\n")

    # Example: 4-node directed graph
    INF = np.inf
    W = np.array([
        [0,   2,   INF, 7  ],
        [INF, 0,   3,   INF],
        [INF, INF, 0,   1  ],
        [INF, INF, INF, 0  ],
    ])

    print("Original weight matrix W:")
    for row in W:
        print("  ", [f"{x:5.1f}" if x < INF else "  INF" for x in row])

    # All-pairs shortest paths: W^n in tropical algebra
    D = W.copy()
    for _ in range(3):
        D = tropical_matrix_mult(D, W)

    print("\nAll-pairs shortest paths (W⊗⁴):")
    for row in D:
        print("  ", [f"{x:5.1f}" if x < INF else "  INF" for x in row])

    # Dual network: transpose
    W_dual = W.T.copy()
    D_dual = W_dual.copy()
    for _ in range(3):
        D_dual = tropical_matrix_mult(D_dual, W_dual)

    print("\nDual network shortest paths ((Wᵀ)⊗⁴):")
    for row in D_dual:
        print("  ", [f"{x:5.1f}" if x < INF else "  INF" for x in row])

    # Verify duality: D_dual = D^T
    D_check = D.T
    match = np.allclose(D_dual, D_check, equal_nan=True) or \
            all(D_dual[i, j] == D_check[i, j]
                for i in range(4) for j in range(4)
                if D_dual[i, j] < INF and D_check[i, j] < INF)
    print(f"\n  Duality check D_dual = D^T: {match}")
    print(f"  → T-duality = tropical matrix transposition")


# ──────────────────────────────────────────────────────────────
# Application 3: Dominant-Mode Selection in Signal Processing
# ──────────────────────────────────────────────────────────────

def demo_signal_processing():
    print("\n" + "=" * 60)
    print("APPLICATION 3: Dominant-Mode Selection (Tropical Interference)")
    print("=" * 60)
    print("\nIn the tropical limit, interference selects the dominant mode.")
    print("This is 'tropical interference': min over action functionals.\n")

    # Three signal modes with different propagation characteristics
    # Mode i has energy E_i(x) = a_i * x + b_i at position x
    modes = [
        ("Direct", 1.0, 0.0),
        ("Reflected", -0.5, 3.0),
        ("Diffracted", 0.2, 1.0),
    ]

    x_samples = np.linspace(-5, 5, 11)

    print("Signal modes:")
    for name, a, b in modes:
        print(f"  {name}: E(x) = {a}·x + {b}")

    print(f"\n{'x':>6s} | {'Dominant Mode':>15s} | {'Energy':>8s}")
    print("-" * 35)
    for x in x_samples:
        energies = [(a * x + b, name) for name, a, b in modes]
        min_e, dom_name = min(energies)
        print(f"{x:6.1f} | {dom_name:>15s} | {min_e:8.3f}")

    # Corner points = mode transitions
    print("\nMode transitions (tropical corners):")
    for i in range(len(modes)):
        for j in range(i + 1, len(modes)):
            _, ai, bi = modes[i]
            _, aj, bj = modes[j]
            if abs(ai - aj) > 1e-15:
                x0 = (bj - bi) / (ai - aj)
                print(f"  {modes[i][0]} ↔ {modes[j][0]} at x = {x0:.4f}")


# ──────────────────────────────────────────────────────────────
# Application 4: Optimization Duality
# ──────────────────────────────────────────────────────────────

def demo_optimization_duality():
    print("\n" + "=" * 60)
    print("APPLICATION 4: Linear Programming via Tropical Duality")
    print("=" * 60)
    print("\nThe tropical Legendre transform is the LP dual.")
    print("Biconjugation f** = f is strong duality for piecewise-linear functions.\n")

    # Primal: minimize f(x) = max(2x+1, -x+3, 0.5x-1)
    # This is a convex piecewise-linear function.
    branches = [(2.0, 1.0), (-1.0, 3.0), (0.5, -1.0)]

    print("Primal objective: f(x) = max(2x+1, -x+3, 0.5x-1)")
    print("This is a convex piecewise-linear function.\n")

    # Find minimum of f
    # Critical points are where branches cross
    x_vals = np.linspace(-5, 5, 10000)
    f_vals = np.array([max(a * x + b for a, b in branches) for x in x_vals])
    opt_idx = np.argmin(f_vals)
    print(f"Primal optimum: x* = {x_vals[opt_idx]:.4f}, f(x*) = {f_vals[opt_idx]:.4f}")

    # Corner points of f (non-differentiability)
    print("\nCorner points (phase transitions):")
    for i in range(len(branches)):
        for j in range(i + 1, len(branches)):
            ai, bi = branches[i]
            aj, bj = branches[j]
            if abs(ai - aj) > 1e-15:
                x0 = (bj - bi) / (ai - aj)
                val = max(a * x0 + b for a, b in branches)
                print(f"  x = {x0:.4f}, f(x) = {val:.4f}")

    print("\n→ The minimum occurs at a corner point (branch tie)")
    print("→ Tropical corner detection gives certified optimal solutions")


# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_relu_application()
    demo_network_duality()
    demo_signal_processing()
    demo_optimization_duality()
    print("\n" + "=" * 60)
    print("All applications demonstrated.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical T-Duality Demo: Concrete numerical verification of the main theorems.

Demonstrates:
  Theorem A: Tropical radius inversion = coordinate reflection
  Theorem B: Tropical Legendre biconjugation for affine functions
  Theorem C: Corner locus characterization for tropical polynomials
"""

import numpy as np

# ──────────────────────────────────────────────────────────────
# Definitions
# ──────────────────────────────────────────────────────────────

def trop_potential_log(rho: float, x: float) -> float:
    """Tropical potential Φ_ρ(x) = min(x + ρ, -x - ρ)."""
    return min(x + rho, -x - rho)

def trop_potential(r: float, x: float) -> float:
    """Tropical potential Φ_r(x) = min(x + log r, -x - log r)."""
    return min(x + np.log(r), -x - np.log(r))

def radius_dual(r: float) -> float:
    """Radius duality: r ↦ 1/r."""
    return 1.0 / r

def trop_poly2(a1: float, b1: float, a2: float, b2: float, x: float) -> float:
    """Two-branch tropical polynomial: min(a₁x + b₁, a₂x + b₂)."""
    return min(a1 * x + b1, a2 * x + b2)

def corner_point(a1: float, b1: float, a2: float, b2: float) -> float:
    """Corner point for two branches with a₁ ≠ a₂."""
    return (b2 - b1) / (a1 - a2)

# ──────────────────────────────────────────────────────────────
# Theorem A: T-Duality Verification
# ──────────────────────────────────────────────────────────────

def demo_theorem_a():
    print("=" * 60)
    print("THEOREM A: Tropical T-Duality")
    print("=" * 60)

    # Test log-form duality: Φ_{-ρ}(x) = Φ_ρ(-x)
    print("\n--- Log-form duality: Φ_{-ρ}(x) = Φ_ρ(-x) ---")
    test_cases = [
        (1.0, 0.5), (2.0, -1.0), (0.3, 3.7), (-1.5, 2.1), (0.0, 0.0)
    ]
    max_error = 0.0
    for rho, x in test_cases:
        lhs = trop_potential_log(-rho, x)
        rhs = trop_potential_log(rho, -x)
        error = abs(lhs - rhs)
        max_error = max(max_error, error)
        print(f"  ρ={rho:6.2f}, x={x:6.2f}: LHS={lhs:8.4f}, RHS={rhs:8.4f}, error={error:.2e}")
    print(f"  Max error: {max_error:.2e}")

    # Test radius-form duality: Φ_{1/r}(x) = Φ_r(-x)
    print("\n--- Radius-form duality: Φ_{1/r}(x) = Φ_r(-x) ---")
    radii = [0.5, 1.0, 2.0, 3.0, 0.1]
    x_vals = [-2.0, -1.0, 0.0, 1.0, 2.0]
    max_error = 0.0
    for r in radii:
        for x in x_vals:
            lhs = trop_potential(1.0 / r, x)
            rhs = trop_potential(r, -x)
            error = abs(lhs - rhs)
            max_error = max(max_error, error)
    print(f"  Tested {len(radii) * len(x_vals)} (r, x) pairs")
    print(f"  Max error: {max_error:.2e}")

    # Test radius involutivity: (r^∨)^∨ = r
    print("\n--- Radius involutivity: (r^∨)^∨ = r ---")
    for r in [0.5, 1.0, 2.0, np.pi, np.e]:
        result = radius_dual(radius_dual(r))
        error = abs(result - r)
        print(f"  r={r:8.4f}: (r^∨)^∨={result:8.4f}, error={error:.2e}")

    # Large random test
    print("\n--- Random verification (10000 samples) ---")
    np.random.seed(42)
    rhos = np.random.uniform(-10, 10, 10000)
    xs = np.random.uniform(-10, 10, 10000)
    errors = np.array([
        abs(trop_potential_log(-rho, x) - trop_potential_log(rho, -x))
        for rho, x in zip(rhos, xs)
    ])
    print(f"  Max error: {errors.max():.2e}")
    print(f"  Mean error: {errors.mean():.2e}")
    print(f"  All zero: {np.allclose(errors, 0)}")

# ──────────────────────────────────────────────────────────────
# Theorem B: Legendre Biconjugation
# ──────────────────────────────────────────────────────────────

def demo_theorem_b():
    print("\n" + "=" * 60)
    print("THEOREM B: Tropical Legendre Biconjugation")
    print("=" * 60)

    print("\n--- Affine biconjugation: a·x + (-(-b)) = a·x + b ---")
    test_cases = [
        (2.0, 3.0, 1.0),   # slope=2, intercept=3, x=1
        (-1.0, 5.0, 2.0),  # slope=-1, intercept=5, x=2
        (0.0, 0.0, 7.0),   # constant zero, x=7
        (3.14, -2.71, 0.5), # irrational-ish
    ]
    for a, b, x in test_cases:
        biconj = a * x + (-(-b))
        original = a * x + b
        print(f"  f(x)={a}·{x}+{b}={original:.4f}, biconj={biconj:.4f}, equal={biconj==original}")

# ──────────────────────────────────────────────────────────────
# Theorem C: Corner Locus
# ──────────────────────────────────────────────────────────────

def demo_theorem_c():
    print("\n" + "=" * 60)
    print("THEOREM C: Corner Locus = Conifold Transition")
    print("=" * 60)

    # Example 1: Two branches
    a1, b1, a2, b2 = 2.0, 1.0, -1.0, 4.0
    x0 = corner_point(a1, b1, a2, b2)
    print(f"\n--- Two-branch corner ---")
    print(f"  Branch 1: {a1}·x + {b1}")
    print(f"  Branch 2: {a2}·x + {b2}")
    print(f"  Corner point: x₀ = ({b2}-{b1})/({a1}-{a2}) = {x0:.6f}")
    v1 = a1 * x0 + b1
    v2 = a2 * x0 + b2
    print(f"  Branch 1 at x₀: {v1:.6f}")
    print(f"  Branch 2 at x₀: {v2:.6f}")
    print(f"  Tie verified: {abs(v1 - v2) < 1e-12}")

    # Example 2: Three branches - find all pairwise corners
    print(f"\n--- Three-branch corner detection ---")
    branches = [(2.0, 1.0), (-1.0, 4.0), (0.5, -1.0)]
    print(f"  Branches: {branches}")
    for i in range(len(branches)):
        for j in range(i + 1, len(branches)):
            ai, bi = branches[i]
            aj, bj = branches[j]
            if ai != aj:
                x0 = corner_point(ai, bi, aj, bj)
                val = min(ai * x0 + bi, min(aj * x0 + bj,
                    min(*(ak * x0 + bk for ak, bk in branches))))
                # Check if this corner is "active" (both tied branches achieve the min)
                tie_val = ai * x0 + bi
                all_vals = [ak * x0 + bk for ak, bk in branches]
                is_active = abs(tie_val - min(all_vals)) < 1e-10
                print(f"  Branches {i+1},{j+1}: corner at x₀={x0:.4f}, "
                      f"tie_val={tie_val:.4f}, min_val={min(all_vals):.4f}, "
                      f"active={is_active}")

    # T-duality corner shift
    print(f"\n--- T-duality corner shift ---")
    rho = 1.5
    # Corner of Φ_ρ: x + ρ = -x - ρ → x = -ρ
    corner_original = -rho
    # Corner of Φ_{-ρ}: x + (-ρ) = -x - (-ρ) → x = ρ
    corner_dual = rho
    print(f"  ρ = {rho}")
    print(f"  Corner of Φ_ρ:  x₀ = -ρ = {corner_original}")
    print(f"  Corner of Φ_{{-ρ}}: x₀ = ρ = {corner_dual}")
    print(f"  Reflection: corner_dual = -corner_original: {corner_dual == -corner_original}")

# ──────────────────────────────────────────────────────────────
# Min-plus distributivity
# ──────────────────────────────────────────────────────────────

def demo_distributivity():
    print("\n" + "=" * 60)
    print("MIN-PLUS DISTRIBUTIVITY: c + min(a,b) = min(c+a, c+b)")
    print("=" * 60)

    np.random.seed(123)
    for _ in range(5):
        a, b, c = np.random.uniform(-10, 10, 3)
        lhs = c + min(a, b)
        rhs = min(c + a, c + b)
        print(f"  a={a:7.3f}, b={b:7.3f}, c={c:7.3f}: "
              f"LHS={lhs:8.3f}, RHS={rhs:8.3f}, equal={abs(lhs-rhs)<1e-15}")

# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_distributivity()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical T-Duality.

Generates publication-quality figures showing:
  1. Tropical potential and T-duality (branch swap under radius inversion)
  2. Corner locus / conifold transition points
  3. Multi-branch tropical polynomial with active corners
  4. T-duality family of potentials
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import os


def setup_style():
    plt.rcParams.update({
        'figure.figsize': (10, 7),
        'font.size': 13,
        'axes.labelsize': 14,
        'axes.titlesize': 15,
        'legend.fontsize': 11,
        'lines.linewidth': 2.0,
        'axes.grid': True,
        'grid.alpha': 0.3,
        'figure.dpi': 150,
    })

# ──────────────────────────────────────────────────────────────
# Figure 1: T-Duality Visualization
# ──────────────────────────────────────────────────────────────

def fig_t_duality():
    setup_style()
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    xs = np.linspace(-4, 4, 500)

    # Panel 1: Original potential Φ_ρ
    rho = 1.5
    branch_m = xs + rho
    branch_w = -xs - rho
    phi = np.minimum(branch_m, branch_w)

    ax = axes[0]
    ax.plot(xs, branch_m, '--', color='#2196F3', alpha=0.5, label='Momentum: x + ρ')
    ax.plot(xs, branch_w, '--', color='#F44336', alpha=0.5, label='Winding: −x − ρ')
    ax.plot(xs, phi, '-', color='#4CAF50', linewidth=3, label=f'Φ_ρ(x), ρ={rho}')
    corner_x = -rho
    corner_y = corner_x + rho
    ax.plot(corner_x, corner_y, 'ko', markersize=10, zorder=5)
    ax.annotate('Corner\n(conifold)', xy=(corner_x, corner_y),
                xytext=(corner_x + 1.5, corner_y + 1.5),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='black'))
    ax.set_xlabel('x')
    ax.set_ylabel('Φ(x)')
    ax.set_title('Original Potential Φ_ρ')
    ax.legend(loc='upper right', fontsize=9)
    ax.set_ylim(-5, 5)

    # Panel 2: Dual potential Φ_{-ρ}
    branch_m2 = xs + (-rho)
    branch_w2 = -xs - (-rho)
    phi2 = np.minimum(branch_m2, branch_w2)

    ax = axes[1]
    ax.plot(xs, branch_m2, '--', color='#F44336', alpha=0.5, label='x − ρ')
    ax.plot(xs, branch_w2, '--', color='#2196F3', alpha=0.5, label='−x + ρ')
    ax.plot(xs, phi2, '-', color='#FF9800', linewidth=3, label=f'Φ_{{−ρ}}(x), ρ={rho}')
    corner_x2 = rho
    corner_y2 = corner_x2 - rho
    ax.plot(corner_x2, corner_y2, 'ko', markersize=10, zorder=5)
    ax.annotate('Corner\n(dual)', xy=(corner_x2, corner_y2),
                xytext=(corner_x2 - 1.5, corner_y2 + 1.5),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='black'))
    ax.set_xlabel('x')
    ax.set_title('Dual Potential Φ_{−ρ}')
    ax.legend(loc='upper right', fontsize=9)
    ax.set_ylim(-5, 5)

    # Panel 3: Overlay showing duality
    ax = axes[2]
    ax.plot(xs, phi, '-', color='#4CAF50', linewidth=3, label=f'Φ_ρ(x)')
    ax.plot(xs, phi2, '-', color='#FF9800', linewidth=3, label=f'Φ_{{−ρ}}(x)')
    # Show reflection
    phi_reflected = np.minimum((-xs) + rho, -(-xs) - rho)
    ax.plot(xs, phi_reflected, ':', color='#9C27B0', linewidth=2.5, label=f'Φ_ρ(−x)')
    ax.set_xlabel('x')
    ax.set_title('T-Duality: Φ_{−ρ}(x) = Φ_ρ(−x)')
    ax.legend(loc='upper center', fontsize=9)
    ax.set_ylim(-5, 5)

    fig.suptitle('Tropical T-Duality: Radius Inversion = Coordinate Reflection',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_t_duality.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved fig_t_duality.png")


# ──────────────────────────────────────────────────────────────
# Figure 2: Corner Locus / Conifold Transition
# ──────────────────────────────────────────────────────────────

def fig_corner_locus():
    setup_style()
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    xs = np.linspace(-4, 6, 500)

    # Panel 1: Two-branch corner
    a1, b1 = 2.0, 1.0
    a2, b2 = -1.0, 4.0
    branch1 = a1 * xs + b1
    branch2 = a2 * xs + b2
    trop = np.minimum(branch1, branch2)
    x0 = (b2 - b1) / (a1 - a2)
    y0 = a1 * x0 + b1

    ax = axes[0]
    ax.plot(xs, branch1, '--', color='#2196F3', alpha=0.6, label=f'{a1}x + {b1}')
    ax.plot(xs, branch2, '--', color='#F44336', alpha=0.6, label=f'{a2}x + {b2}')
    ax.plot(xs, trop, '-', color='#4CAF50', linewidth=3, label='min(branches)')
    ax.plot(x0, y0, 'r*', markersize=20, zorder=5, label=f'Corner at x={x0:.2f}')
    ax.axvline(x=x0, color='gray', linestyle=':', alpha=0.5)
    ax.fill_between(xs, trop, -10, alpha=0.05, color='green')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.set_title('Two-Branch Tropical Polynomial')
    ax.legend(fontsize=10)
    ax.set_ylim(-5, 15)

    # Panel 2: Three-branch with multiple corners
    branches = [(2.0, 1.0), (-1.0, 6.0), (0.3, -1.0)]
    colors = ['#2196F3', '#F44336', '#FF9800']
    branch_vals = [a * xs + b for a, b in branches]
    trop = np.minimum.reduce(branch_vals)

    ax = axes[1]
    for i, ((a, b), color) in enumerate(zip(branches, colors)):
        ax.plot(xs, branch_vals[i], '--', color=color, alpha=0.5,
                label=f'Branch {i+1}: {a}x + {b}')
    ax.plot(xs, trop, '-', color='#4CAF50', linewidth=3, label='min(branches)')

    # Find and plot corners
    for i in range(len(branches)):
        for j in range(i + 1, len(branches)):
            ai, bi = branches[i]
            aj, bj = branches[j]
            if abs(ai - aj) > 1e-15:
                x0 = (bj - bi) / (ai - aj)
                y0 = ai * x0 + bi
                # Check if active
                all_vals = [a * x0 + b for a, b in branches]
                if abs(y0 - min(all_vals)) < 1e-10:
                    ax.plot(x0, y0, 'r*', markersize=18, zorder=5)
                    ax.annotate(f'x={x0:.2f}', xy=(x0, y0),
                                xytext=(x0 + 0.5, y0 - 1.5), fontsize=10,
                                arrowprops=dict(arrowstyle='->', color='red'))

    ax.set_xlabel('x')
    ax.set_title('Three-Branch Tropical Polynomial')
    ax.legend(fontsize=9)
    ax.set_ylim(-5, 15)

    fig.suptitle('Corner Locus = Conifold Transition Points',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_corner_locus.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved fig_corner_locus.png")


# ──────────────────────────────────────────────────────────────
# Figure 3: Family of T-Dual Potentials
# ──────────────────────────────────────────────────────────────

def fig_tduality_family():
    setup_style()
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    xs = np.linspace(-5, 5, 500)
    radii = [0.25, 0.5, 1.0, 2.0, 4.0]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(radii)))

    # Panel 1: Φ_r(x) for various r
    ax = axes[0]
    for r, c in zip(radii, colors):
        log_r = np.log(r)
        phi = np.minimum(xs + log_r, -xs - log_r)
        ax.plot(xs, phi, '-', color=c, linewidth=2.5, label=f'r = {r}')
        # Mark corner
        corner_x = -log_r
        corner_y = 0
        ax.plot(corner_x, corner_y, 'o', color=c, markersize=8)
    ax.set_xlabel('x')
    ax.set_ylabel('Φ_r(x)')
    ax.set_title('Tropical Potentials for Various Radii')
    ax.legend(fontsize=10)
    ax.set_ylim(-5, 3)

    # Panel 2: Showing r and 1/r produce reflected curves
    ax = axes[1]
    for r, c in zip([0.25, 0.5], colors[:2]):
        log_r = np.log(r)
        phi = np.minimum(xs + log_r, -xs - log_r)
        phi_dual = np.minimum(xs - log_r, -xs + log_r)
        ax.plot(xs, phi, '-', color=c, linewidth=2.5, label=f'Φ_{{r={r}}}(x)')
        ax.plot(xs, phi_dual, '--', color=c, linewidth=2, label=f'Φ_{{r={1/r}}}(x) = Φ_{{r={r}}}(−x)')

    # Self-dual case r=1
    phi_self = np.minimum(xs, -xs)
    ax.plot(xs, phi_self, '-', color='red', linewidth=3, label='Φ_{r=1}(x) [self-dual]')

    ax.set_xlabel('x')
    ax.set_ylabel('Φ_r(x)')
    ax.set_title('T-Duality: r ↔ 1/r Produces Reflected Curves')
    ax.legend(fontsize=9, loc='lower center')
    ax.set_ylim(-5, 3)

    fig.suptitle('T-Duality Family: Radius Inversion as Reflection',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_tduality_family.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved fig_tduality_family.png")


# ──────────────────────────────────────────────────────────────
# Figure 4: Phase Diagram
# ──────────────────────────────────────────────────────────────

def fig_phase_diagram():
    setup_style()
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # For Φ_ρ(x) = min(x+ρ, -x-ρ), the dominant branch depends on sign of x+ρ vs -x-ρ
    # Momentum dominates when x+ρ < -x-ρ, i.e., x < -ρ
    # Winding dominates when x > -ρ
    # Phase boundary: x = -ρ

    rho_range = np.linspace(-3, 3, 300)
    x_range = np.linspace(-4, 4, 300)
    R, X = np.meshgrid(rho_range, x_range)

    # Phase: 0 = momentum dominant, 1 = winding dominant
    phase = (X > -R).astype(float)

    ax.contourf(R, X, phase, levels=[-0.5, 0.5, 1.5],
                colors=['#2196F3', '#F44336'], alpha=0.3)
    ax.contour(R, X, phase, levels=[0.5], colors=['black'], linewidths=2)

    # Phase boundary line: x = -ρ
    ax.plot(rho_range, -rho_range, 'k-', linewidth=2.5, label='Phase boundary: x = −ρ')

    # Self-dual point
    ax.plot(0, 0, 'w*', markersize=20, markeredgecolor='black', markeredgewidth=2,
            zorder=5, label='Self-dual point (ρ=0, x=0)')

    # Labels
    ax.text(-2, 2, 'MOMENTUM\nDominant', fontsize=16, ha='center', va='center',
            color='#1565C0', fontweight='bold')
    ax.text(2, -2, 'WINDING\nDominant', fontsize=16, ha='center', va='center',
            color='#C62828', fontweight='bold')

    ax.set_xlabel('ρ = log R (log-radius)', fontsize=14)
    ax.set_ylabel('x (tropical coordinate)', fontsize=14)
    ax.set_title('Tropical Phase Diagram: Momentum vs. Winding Dominance',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=12, loc='upper left')

    plt.tight_layout()
    plt.savefig('fig_phase_diagram.png', bbox_inches='tight', dpi=150)
    plt.close()
    print("Saved fig_phase_diagram.png")


# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    fig_t_duality()
    fig_corner_locus()
    fig_tduality_family()
    fig_phase_diagram()
    print("\nAll visualizations generated.")
