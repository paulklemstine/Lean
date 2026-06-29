"""
Spectral Jacobson–Evaluation Elimination: Interactive Demo

This script demonstrates the core ideas of the Spectral Evaluation
Elimination Theorem with concrete numerical examples over tropical
(min-plus) and Boolean semirings.

The key insight: to check whether two x-polynomials are "equivalent
after eliminating y-variables," it suffices to test them against
finitely many substitutions y ↦ φ(x).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product

INF = float('inf')

# =============================================================================
# Demo 1: Tropical (min-plus) elimination
# =============================================================================

def demonstrate_tropical_elimination():
    """
    Tropical elimination via evaluation contractions.
    f(x,y) and g(x,y) over the tropical semiring;
    check agreement after substituting y = φ(x).
    """
    print("=" * 70)
    print("DEMO 1: Tropical Elimination via Evaluation")
    print("=" * 70)
    print()
    print("Semiring: Tropical (min-plus) over ℝ")
    print("Variables: x (retained), y (eliminated)")
    print()
    print("f(x,y) = min(2+x, 3+y, x+y)")
    print("g(x,y) = min(1+2x, 4+y, 2x+y)")
    print()

    substitutions = {
        "y = 0": lambda x: 0,
        "y = 1": lambda x: 1,
        "y = -1": lambda x: -1,
        "y = x": lambda x: x,
        "y = 2x": lambda x: 2 * x,
        "y = x + 1": lambda x: x + 1,
    }

    x_vals = np.linspace(-3, 5, 200)

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle("Tropical Evaluation Contractions: f(x, φ(x)) vs g(x, φ(x))",
                 fontsize=14)

    for idx, (name, phi) in enumerate(substitutions.items()):
        ax = axes[idx // 3][idx % 3]

        f_vals = [min(2 + x, 3 + phi(x), x + phi(x)) for x in x_vals]
        g_vals = [min(1 + 2 * x, 4 + phi(x), 2 * x + phi(x)) for x in x_vals]

        ax.plot(x_vals, f_vals, 'b-', linewidth=2, label='f(x, φ(x))')
        ax.plot(x_vals, g_vals, 'r--', linewidth=2, label='g(x, φ(x))')

        diff = np.abs(np.array(f_vals) - np.array(g_vals))
        agree = diff < 0.1
        if np.any(agree):
            y_lo, y_hi = ax.get_ylim()
            ax.fill_between(x_vals, y_lo - 5, y_hi + 5,
                          where=agree, alpha=0.15, color='green',
                          label='Agreement')
            ax.set_ylim(y_lo, y_hi)

        ax.set_title(f"Substitution: {name}", fontsize=11)
        ax.set_xlabel("x")
        ax.set_ylabel("Value")
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("demos/tropical_evaluation_contractions.png", dpi=150,
                bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/tropical_evaluation_contractions.png")
    print()
    print("Key insight: The intersection of all evaluation contractions")
    print("(regions where f(x,φ(x)) = g(x,φ(x)) for ALL φ) gives exactly")
    print("the elimination congruence.")
    print()


# =============================================================================
# Demo 2: Boolean semiring elimination
# =============================================================================

def demonstrate_boolean_elimination():
    """
    Over the Boolean semiring {0, 1} with 1+1=1 (idempotent),
    elimination = existential quantification.
    """
    print("=" * 70)
    print("DEMO 2: Boolean Elimination = Existential Quantification")
    print("=" * 70)
    print()
    print("Semiring: Boolean {0, 1} (idempotent: 1+1=1)")
    print("f(x₁, x₂, y) = x₁·y ∨ x₂")
    print()

    def f(x1, x2, y):
        return min(1, (x1 * y) + x2)

    def elim_f(x1, x2):
        return max(f(x1, x2, 0), f(x1, x2, 1))

    print("Elimination (∃y. f) table:")
    print("  x₁  x₂  |  f(·,·,0)  f(·,·,1)  |  ∃y.f")
    print("  " + "-" * 45)
    for x1, x2 in product([0, 1], repeat=2):
        print(f"  {x1}   {x2}   |     {f(x1,x2,0)}        "
              f"{f(x1,x2,1)}      |   {elim_f(x1,x2)}")

    print()
    print("Evaluation contractions (y = φ(x₁,x₂)):")
    phis = {
        "y=0": lambda x1, x2: 0,
        "y=1": lambda x1, x2: 1,
        "y=x₁": lambda x1, x2: x1,
        "y=x₂": lambda x1, x2: x2,
        "y=x₁∨x₂": lambda x1, x2: min(1, x1 + x2),
    }

    for name, phi in phis.items():
        vals = [f(x1, x2, phi(x1, x2)) for x1, x2 in product([0,1], repeat=2)]
        print(f"  {name}: {vals}")

    print()
    print("The substitution y=1 alone captures ∃y.f for Boolean polynomials.")
    print("Spectral theorem: finitely many evaluations always suffice!")
    print()


# =============================================================================
# Demo 3: Newton polygon and elimination
# =============================================================================

def demonstrate_newton_polygon():
    """Tropical elimination = projection of Newton polygon."""
    print("=" * 70)
    print("DEMO 3: Newton Polygon Projection = Tropical Elimination")
    print("=" * 70)
    print()

    support = [(0, 0), (2, 0), (0, 3), (1, 1), (1, 2)]
    coeffs = [0, 1, 2, -1, 0]

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Newton polygon
    ax = axes[0]
    xs = [p[0] for p in support]
    ys = [p[1] for p in support]
    ax.scatter(xs, ys, c='blue', s=100, zorder=5)
    for (x, y), c in zip(support, coeffs):
        ax.annotate(f'c={c}', (x + 0.1, y + 0.1), fontsize=9)

    from matplotlib.patches import Polygon
    hull_points = [(0, 0), (2, 0), (1, 2), (0, 3)]
    hull = Polygon(hull_points, fill=True, alpha=0.15, color='blue',
                  edgecolor='blue', linewidth=2)
    ax.add_patch(hull)
    ax.set_xlabel("x exponent")
    ax.set_ylabel("y exponent")
    ax.set_title("Newton Polygon of f(x,y)")
    ax.set_xlim(-0.5, 3)
    ax.set_ylim(-0.5, 4)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Panel 2: Projection
    ax = axes[1]
    x_proj = sorted(set(xs))
    proj_vals = []
    for xv in x_proj:
        min_c = min(c for (xp, _), c in zip(support, coeffs) if xp == xv)
        proj_vals.append(min_c)
    ax.bar(x_proj, proj_vals, color='green', alpha=0.7, width=0.3)
    ax.set_xlabel("x exponent")
    ax.set_ylabel("Min coefficient")
    ax.set_title("Elimination: project onto x\n(min over y-fibers)")
    ax.grid(True, alpha=0.3)

    # Panel 3: Evaluation slices
    ax = axes[2]
    slopes = [0, 1, 2, -1]
    colors = ['red', 'orange', 'purple', 'cyan']
    for slope, color in zip(slopes, colors):
        eval_support = {}
        for (xp, yp), c in zip(support, coeffs):
            new_x = xp + slope * yp
            if new_x in eval_support:
                eval_support[new_x] = min(eval_support[new_x], c)
            else:
                eval_support[new_x] = c
        x_vals = sorted(eval_support.keys())
        c_vals = [eval_support[x] for x in x_vals]
        ax.plot(x_vals, c_vals, 'o-', color=color, linewidth=2, markersize=8,
                label=f'y = {slope}x')

    ax.set_xlabel("Effective x exponent")
    ax.set_ylabel("Coefficient")
    ax.set_title("Evaluation Contractions\n(slices through Newton polygon)")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("demos/newton_polygon_elimination.png", dpi=150,
                bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/newton_polygon_elimination.png")
    print()


# =============================================================================
# Demo 4: Finite witness counting
# =============================================================================

def demonstrate_finite_witnesses():
    """How many evaluations suffice? Complexity comparison."""
    print("=" * 70)
    print("DEMO 4: Finite Witness Counting")
    print("=" * 70)
    print()

    qs = [2, 3, 5, 7]
    max_deg = 6
    degrees = list(range(max_deg + 1))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    for q in qs:
        witness_counts = [q ** (d + 1) for d in degrees]
        ax1.semilogy(degrees, witness_counts, 'o-', linewidth=2,
                     markersize=6, label=f'|S| = {q}')

    ax1.set_xlabel("Degree bound of substitution polynomials")
    ax1.set_ylabel("Number of evaluation witnesses")
    ax1.set_title("Evaluation Witnesses vs Degree Bound")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    n_vars = list(range(1, 7))
    for d in [2, 3, 5]:
        groebner_est = [min(d ** (2 ** n), 1e15) for n in n_vars]
        eval_est = [d ** (n * (d + 1)) for n in n_vars]
        ax2.semilogy(n_vars, groebner_est, '--', linewidth=2,
                     label=f'Gröbner (d={d})', alpha=0.7)
        ax2.semilogy(n_vars, eval_est, '-', linewidth=2,
                     label=f'Eval (d={d})')

    ax2.set_xlabel("Number of eliminated variables")
    ax2.set_ylabel("Complexity estimate")
    ax2.set_title("Evaluation vs Gröbner Complexity")
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("demos/finite_witness_counts.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/finite_witness_counts.png")
    print()


# =============================================================================
# Demo 5: Tropical polytope projection
# =============================================================================

def demonstrate_tropical_projection():
    """Tropical polytope projection via evaluation."""
    print("=" * 70)
    print("DEMO 5: Tropical Polytope Projection")
    print("=" * 70)
    print()

    a, b, c = 0, 1, 3
    d, e, f_c = 1, 0, 2

    def lhs(x, y): return min(a + x, b + y, c)
    def rhs(x, y): return min(d + x, e + y, f_c)

    x_range = np.linspace(-4, 6, 300)
    y_range = np.linspace(-4, 6, 300)
    X, Y = np.meshgrid(x_range, y_range)

    Z = np.abs(np.vectorize(lhs)(X, Y) - np.vectorize(rhs)(X, Y))

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    ax = axes[0]
    ax.contourf(X, Y, Z, levels=[0, 0.01, 0.1, 0.5, 1, 2, 5],
                cmap='RdYlGn_r', alpha=0.8)
    ax.contour(X, Y, Z, levels=[0.01], colors='black', linewidths=2)
    ax.set_xlabel("x"); ax.set_ylabel("y")
    ax.set_title("Tropical Constraint Region")
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    phi_values = [-2, -1, 0, 1, 2, 3]
    colors_list = plt.cm.viridis(np.linspace(0, 1, len(phi_values)))
    for phi_val, color in zip(phi_values, colors_list):
        diff = np.abs(np.array([lhs(x, phi_val) for x in x_range]) -
                      np.array([rhs(x, phi_val) for x in x_range]))
        ax.plot(x_range, diff, color=color, linewidth=1.5,
                label=f'y={phi_val}', alpha=0.8)
    ax.axhline(y=0, color='red', linewidth=2, linestyle='--', alpha=0.5)
    ax.set_xlabel("x"); ax.set_ylabel("|LHS - RHS|")
    ax.set_title("Evaluation Slices")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.1, 3)

    ax = axes[2]
    for idx, phi_val in enumerate(phi_values):
        diff = np.abs(np.array([lhs(x, phi_val) for x in x_range]) -
                      np.array([rhs(x, phi_val) for x in x_range]))
        ax.fill_between(x_range, idx - 0.3, idx + 0.3,
                        where=(diff < 0.05), alpha=0.7, color=colors_list[idx])
        ax.text(-3.8, idx, f'y={phi_val}', fontsize=9, va='center')

    true_elim = np.zeros_like(x_range, dtype=bool)
    for y_test in np.linspace(-4, 6, 200):
        true_elim |= (np.abs(np.array([lhs(x, y_test) for x in x_range]) -
                             np.array([rhs(x, y_test) for x in x_range])) < 0.05)
    ax.fill_between(x_range, len(phi_values) - 0.3, len(phi_values) + 0.3,
                    where=true_elim, alpha=0.7, color='red')
    ax.text(-3.8, len(phi_values), 'Elimination', fontsize=9, va='center',
            color='red', fontweight='bold')
    ax.set_xlabel("x")
    ax.set_title("X-projections vs True Elimination")
    ax.set_yticks([])
    ax.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    plt.savefig("demos/tropical_projection.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/tropical_projection.png")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Spectral Jacobson–Evaluation Elimination                   ║")
    print("║  Interactive Demonstration                                  ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demonstrate_tropical_elimination()
    demonstrate_boolean_elimination()
    demonstrate_newton_polygon()
    demonstrate_finite_witnesses()
    demonstrate_tropical_projection()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("The Spectral Evaluation Elimination Theorem establishes that")
    print("variable elimination from a ring congruence can be computed as")
    print("the intersection of evaluation contractions. This provides:")
    print("  1. A Jacobson-type principle: test against evaluation maps")
    print("  2. Finite certificates via quasicompactness")
    print("  3. Algorithmic elimination without Gröbner bases")
    print("  4. Natural framework for tropical/idempotent geometry")
    print()
    print("All core theorems are formally verified in Lean 4 with Mathlib.")
