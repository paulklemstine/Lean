#!/usr/bin/env python3
"""
Tropical Satake GL₃ — Demonstration and Visualization

This script demonstrates the key results of the tropical Satake
convolution-faithfulness theorem for GL₃:

1. The adjacentData map and its injectivity
2. Separation of dominant triples via Weyl chamber walls
3. The tropical Satake transform and its reconstruction properties
4. Visualization of Newton polygons on each wall

Usage:
    python demo.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import combinations
import os

# ===========================================================================
# Core definitions (matching the Lean formalization)
# ===========================================================================

def eval_weight(mu, x):
    """⟨μ, x⟩ = μ₁x₁ + μ₂x₂ + μ₃x₃"""
    return mu[0]*x[0] + mu[1]*x[1] + mu[2]*x[2]

def adjacent_data(mu):
    """Projects μ to two GL₂-type pairs:
       ((μ₁+μ₂, μ₃), (μ₁, μ₂+μ₃))"""
    return ((mu[0]+mu[1], mu[2]), (mu[0], mu[1]+mu[2]))

def is_dominant(mu):
    """Dominance condition: μ₁ ≥ μ₂ ≥ μ₃"""
    return mu[0] >= mu[1] and mu[1] >= mu[2]

def facet12_eval(mu, a, b):
    """Evaluation on Facet12: x = (a, a, b) → (μ₁+μ₂)a + μ₃b"""
    return (mu[0]+mu[1])*a + mu[2]*b

def facet23_eval(mu, a, b):
    """Evaluation on Facet23: x = (a, b, b) → μ₁a + (μ₂+μ₃)b"""
    return mu[0]*a + (mu[1]+mu[2])*b

def trop_sat(f_support, f_coeffs, x):
    """Min-plus tropical Satake transform: inf_μ (f(μ) + ⟨μ, x⟩)"""
    return min(c + eval_weight(mu, x) for mu, c in zip(f_support, f_coeffs))

# ===========================================================================
# Demo 1: adjacentData injectivity
# ===========================================================================

def demo_adjacent_data():
    print("=" * 60)
    print("DEMO 1: adjacentData Injectivity")
    print("=" * 60)
    print()
    print("The adjacentData map sends μ = (μ₁, μ₂, μ₃) to")
    print("  ((μ₁+μ₂, μ₃), (μ₁, μ₂+μ₃))")
    print()
    print("This is INJECTIVE: knowing both GL₂-type projections")
    print("uniquely determines the original weight triple.")
    print()

    # Generate all dominant triples with components ≤ 5
    dominant_triples = [(a, b, c) for a in range(6)
                        for b in range(a+1) for c in range(b+1)]

    # Check injectivity
    data_map = {}
    for mu in dominant_triples:
        ad = adjacent_data(mu)
        if ad in data_map:
            print(f"  COLLISION: {mu} and {data_map[ad]} → {ad}")
        data_map[ad] = mu

    print(f"  Checked {len(dominant_triples)} dominant triples with components ≤ 5:")
    print(f"  All {len(data_map)} adjacentData values are distinct. ✓")
    print()

    # Show some examples
    examples = [(3, 2, 1), (4, 1, 0), (2, 2, 0), (5, 3, 1)]
    print("  Examples:")
    for mu in examples:
        ad = adjacent_data(mu)
        print(f"    ({mu[0]},{mu[1]},{mu[2]}) → Facet12: ({ad[0][0]},{ad[0][1]}), "
              f"Facet23: ({ad[1][0]},{ad[1][1]})")
    print()

# ===========================================================================
# Demo 2: Separation on Weyl walls
# ===========================================================================

def demo_separation():
    print("=" * 60)
    print("DEMO 2: Separation of Distinct Weights on Weyl Walls")
    print("=" * 60)
    print()
    print("For any μ ≠ ν, there exists a test point x on Facet12 or")
    print("Facet23 with evalWeight(μ, x) < evalWeight(ν, x).")
    print()

    pairs = [((3,2,1), (2,1,0)), ((4,2,0), (3,3,0)),
             ((5,3,1), (4,4,1)), ((2,1,0), (1,1,1))]

    for mu, nu in pairs:
        # Try Facet12 first
        found = False
        for a in range(-5, 6):
            for b in range(-5, 6):
                e_mu = facet12_eval(mu, a, b)
                e_nu = facet12_eval(nu, a, b)
                if e_mu < e_nu:
                    print(f"  {mu} vs {nu}: Facet12 at (a={a},b={b}): "
                          f"eval({mu})={e_mu} < eval({nu})={e_nu} ✓")
                    found = True
                    break
            if found:
                break

        if not found:
            for a in range(-5, 6):
                for b in range(-5, 6):
                    e_mu = facet23_eval(mu, a, b)
                    e_nu = facet23_eval(nu, a, b)
                    if e_mu < e_nu:
                        print(f"  {mu} vs {nu}: Facet23 at (a={a},b={b}): "
                              f"eval({mu})={e_mu} < eval({nu})={e_nu} ✓")
                        found = True
                        break
                if found:
                    break
    print()

# ===========================================================================
# Demo 3: Tropical Satake transform reconstruction
# ===========================================================================

def demo_reconstruction():
    print("=" * 60)
    print("DEMO 3: Tropical Satake Transform Reconstruction")
    print("=" * 60)
    print()

    # Example: f with support {(3,1,0), (2,2,1)}
    f_support = [(3, 1, 0), (2, 2, 1)]
    f_coeffs = [2, 3]

    print("  f: support =", f_support, " coefficients =", f_coeffs)
    print()

    # Show wall-exposability
    for i, (mu, c) in enumerate(zip(f_support, f_coeffs)):
        print(f"  Exposing ({mu[0]},{mu[1]},{mu[2]}) with coefficient {c}:")
        best_x = None
        best_gap = -float('inf')

        for a in range(-20, 21):
            for b in range(-20, 21):
                # Try Facet12
                vals = [cc + facet12_eval(m, a, b) for m, cc in zip(f_support, f_coeffs)]
                gap = min(v - vals[i] for j, v in enumerate(vals) if j != i)
                if gap > best_gap:
                    best_gap = gap
                    best_x = ('F12', a, b)

                # Try Facet23
                vals = [cc + facet23_eval(m, a, b) for m, cc in zip(f_support, f_coeffs)]
                gap = min(v - vals[i] for j, v in enumerate(vals) if j != i)
                if gap > best_gap:
                    best_gap = gap
                    best_x = ('F23', a, b)

        wall, a, b = best_x
        if wall == 'F12':
            x = (a, a, b)
        else:
            x = (a, b, b)
        val_at_mu = c + eval_weight(mu, x)
        print(f"    Best exposing point: {wall} at (a={a},b={b}), x={x}")
        print(f"    tropSat(f)(x) = {trop_sat(f_support, f_coeffs, x)} = f(μ)+⟨μ,x⟩ = {val_at_mu}")
        print(f"    Gap to nearest competitor: {best_gap}")
        print()

    # Now show that changing a coefficient changes the transform
    print("  Coefficient sensitivity:")
    g_coeffs = [2, 5]  # Changed second coefficient
    print(f"  g has same support but coefficients = {g_coeffs}")

    found_diff = False
    for a in range(-10, 11):
        for b in range(-10, 11):
            x12 = (a, a, b)
            vf = trop_sat(f_support, f_coeffs, x12)
            vg = trop_sat(f_support, g_coeffs, x12)
            if vf != vg:
                print(f"  Facet12 at (a={a},b={b}): tropSat(f)={vf} ≠ tropSat(g)={vg} ✓")
                found_diff = True
                break
        if found_diff:
            break
    print()

# ===========================================================================
# Demo 4: Visualization
# ===========================================================================

def demo_visualization():
    print("=" * 60)
    print("DEMO 4: Generating Visualizations")
    print("=" * 60)
    print()

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # --- Panel 1: Newton polygon projections ---
    support = [(4, 2, 0), (3, 1, 1), (2, 2, 2), (5, 0, 0), (3, 3, 0)]
    coeffs = [1, 2, 3, 0, 2]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

    ax = axes[0]
    ax.set_title('Facet12 Projection\n$(\\mu_1+\\mu_2, \\mu_3)$', fontsize=12)

    for mu, c, col in zip(support, coeffs, colors):
        p, q = mu[0]+mu[1], mu[2]
        ax.scatter(p, q, c=col, s=120, zorder=5, edgecolors='black', linewidth=1)
        ax.annotate(f'$({mu[0]},{mu[1]},{mu[2]})$\nc={c}',
                   (p+0.1, q+0.1), fontsize=8)

    # Draw convex hull
    from scipy.spatial import ConvexHull
    pts12 = np.array([(mu[0]+mu[1], mu[2]) for mu in support])
    if len(pts12) >= 3:
        try:
            hull = ConvexHull(pts12)
            for simplex in hull.simplices:
                ax.plot(pts12[simplex, 0], pts12[simplex, 1], 'k-', alpha=0.3)
        except Exception:
            pass

    ax.set_xlabel('$\\mu_1 + \\mu_2$')
    ax.set_ylabel('$\\mu_3$')
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Facet23 projection ---
    ax = axes[1]
    ax.set_title('Facet23 Projection\n$(\\mu_1, \\mu_2+\\mu_3)$', fontsize=12)

    for mu, c, col in zip(support, coeffs, colors):
        p, q = mu[0], mu[1]+mu[2]
        ax.scatter(p, q, c=col, s=120, zorder=5, edgecolors='black', linewidth=1)
        ax.annotate(f'$({mu[0]},{mu[1]},{mu[2]})$\nc={c}',
                   (p+0.1, q+0.1), fontsize=8)

    pts23 = np.array([(mu[0], mu[1]+mu[2]) for mu in support])
    if len(pts23) >= 3:
        try:
            hull = ConvexHull(pts23)
            for simplex in hull.simplices:
                ax.plot(pts23[simplex, 0], pts23[simplex, 1], 'k-', alpha=0.3)
        except Exception:
            pass

    ax.set_xlabel('$\\mu_1$')
    ax.set_ylabel('$\\mu_2 + \\mu_3$')
    ax.grid(True, alpha=0.3)

    # --- Panel 3: Tropical Satake transform on Facet12 ---
    ax = axes[2]
    ax.set_title('Tropical Satake on Facet12\n$\\mathrm{tropSat}(f)(a,a,b)$', fontsize=12)

    a_range = np.linspace(-3, 3, 100)
    b_vals = [-2, 0, 2]
    for b in b_vals:
        ts_vals = [min(c + (mu[0]+mu[1])*a + mu[2]*b
                      for mu, c in zip(support, coeffs))
                  for a in a_range]
        ax.plot(a_range, ts_vals, label=f'b={b}', linewidth=2)

    ax.set_xlabel('$a$')
    ax.set_ylabel('$\\mathrm{tropSat}(f)(a,a,b)$')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_satake_gl3.png'),
                dpi=150, bbox_inches='tight')
    print("  Saved: tropical_satake_gl3.png")
    plt.close()

    # --- Figure 2: Wall-exposability demonstration ---
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    support2 = [(3, 1, 0), (1, 1, 1)]
    coeffs2 = [2, 4]

    for idx, (wall_name, eval_fn) in enumerate([
        ('Facet12: $x=(a,a,b)$', facet12_eval),
        ('Facet23: $x=(a,b,b)$', facet23_eval)
    ]):
        ax = axes[idx]
        ax.set_title(f'{wall_name}', fontsize=12)

        a_range = np.linspace(-5, 5, 200)
        for b in [-3, -1, 0, 1, 3]:
            ts_vals = [min(c + eval_fn(mu, a, b)
                          for mu, c in zip(support2, coeffs2))
                      for a in a_range]
            ax.plot(a_range, ts_vals, label=f'b={b}', alpha=0.7)

            # Also plot individual terms
            for mu, c, ls in zip(support2, coeffs2, ['--', ':']):
                term_vals = [c + eval_fn(mu, a, b) for a in a_range]
                ax.plot(a_range, term_vals, ls, alpha=0.2, color='gray')

        ax.set_xlabel('$a$')
        ax.set_ylabel('Value')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.suptitle(f'Support: {support2}, Coefficients: {coeffs2}', fontsize=11)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'wall_exposability.png'),
                dpi=150, bbox_inches='tight')
    print("  Saved: wall_exposability.png")
    plt.close()

    print()

# ===========================================================================
# Demo 5: Counterexample — non-injectivity without wall-exposability
# ===========================================================================

def demo_counterexample():
    print("=" * 60)
    print("DEMO 5: Non-injectivity Without Wall-Exposability")
    print("=" * 60)
    print()
    print("  The min-plus transform is NOT injective in general!")
    print("  Counterexample:")
    print()

    support = [(0, 0, 0), (1, 0, 0), (2, 0, 0)]
    f_coeffs = [0, 100, 0]
    g_coeffs = [0, 999, 0]

    print(f"  f: support = {support}, coefficients = {f_coeffs}")
    print(f"  g: support = {support}, coefficients = {g_coeffs}")
    print()
    print("  The middle weight (1,0,0) is in the convex hull of (0,0,0) and (2,0,0).")
    print("  It can NEVER achieve the minimum (always dominated).")
    print()

    # Verify they agree on both walls
    agree_12 = True
    agree_23 = True

    for a in range(-50, 51):
        for b in range(-50, 51):
            # Facet12
            vf = min(c + facet12_eval(mu, a, b) for mu, c in zip(support, f_coeffs))
            vg = min(c + facet12_eval(mu, a, b) for mu, c in zip(support, g_coeffs))
            if vf != vg:
                agree_12 = False
            # Facet23
            vf = min(c + facet23_eval(mu, a, b) for mu, c in zip(support, f_coeffs))
            vg = min(c + facet23_eval(mu, a, b) for mu, c in zip(support, g_coeffs))
            if vf != vg:
                agree_23 = False

    print(f"  tropSat(f) = tropSat(g) on Facet12 (tested |a|,|b| ≤ 50): {agree_12} ✓")
    print(f"  tropSat(f) = tropSat(g) on Facet23 (tested |a|,|b| ≤ 50): {agree_23} ✓")
    print(f"  But f ≠ g (coefficients differ at (1,0,0)): f=100, g=999")
    print()
    print("  The wall-exposability condition in our theorem rules out")
    print("  such 'invisible' support points.")
    print()

# ===========================================================================
# Main
# ===========================================================================

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Satake GL₃ — Convolution-Faithfulness Demo   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_adjacent_data()
    demo_separation()
    demo_reconstruction()
    demo_counterexample()

    try:
        demo_visualization()
    except ImportError as e:
        print(f"  (Visualization skipped — missing dependency: {e})")
    except Exception as e:
        print(f"  (Visualization error: {e})")

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)
