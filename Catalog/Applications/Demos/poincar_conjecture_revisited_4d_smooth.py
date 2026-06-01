#!/usr/bin/env python3
"""
Demonstration of intersection form analysis for smooth 4-manifold topology.

Showcases:
1. E8 lattice properties (symmetry, determinant, evenness, positive definiteness)
2. Freedman-Donaldson obstruction
3. Hyperbolic form and indefinite classification
4. Furuta's 10/8 bound and the 11/8 conjecture
5. Minimum norm vectors in the E8 lattice
"""

import numpy as np
from algorithms import (
    e8_matrix, hyperbolic_matrix, evaluate_form, is_unimodular,
    is_symmetric, is_even, is_diagonal, is_positive_definite,
    donaldson_check, furuta_check, eleven_eighths_check,
    classify_form, cholesky_rational, direct_sum, find_minimum_norm
)


def demo_e8():
    """Demonstrate E8 lattice properties."""
    print("=" * 60)
    print("THE E₈ LATTICE")
    print("=" * 60)

    E8 = e8_matrix()
    print("\nE₈ Cartan Matrix:")
    print(E8)

    print(f"\n  Symmetric: {is_symmetric(E8)}")
    det = int(round(np.linalg.det(E8.astype(float))))
    print(f"  Determinant: {det}")
    print(f"  Unimodular: {is_unimodular(E8)}")
    print(f"  Even (Type II): {is_even(E8)}")
    print(f"  Diagonal: {is_diagonal(E8)}")
    print(f"  Positive definite: {is_positive_definite(E8)}")

    eigenvalues = np.linalg.eigvalsh(E8.astype(float))
    print(f"\n  Eigenvalues: {np.sort(eigenvalues).round(4)}")
    print(f"  Min eigenvalue: {min(eigenvalues):.6f}")
    print(f"  Max eigenvalue: {max(eigenvalues):.6f}")

    # Cholesky decomposition
    L, D = cholesky_rational(E8)
    print(f"\n  Cholesky pivots (D): {D.round(6)}")
    print(f"  All pivots positive: {all(d > 0 for d in D)}")
    print(f"  Product of pivots: {np.prod(D):.6f} (should be det = {det})")

    # Minimum norm
    min_val, min_vec = find_minimum_norm(E8, bound=2)
    print(f"\n  Minimum Q(v,v) for |v_i| ≤ 2: {min_val}")
    print(f"  Minimizing vector: {min_vec}")
    print(f"  (Root vectors of E₈ have norm 2)")


def demo_freedman_donaldson():
    """Demonstrate the Freedman-Donaldson obstruction."""
    print("\n" + "=" * 60)
    print("FREEDMAN-DONALDSON OBSTRUCTION")
    print("=" * 60)

    E8 = e8_matrix()

    passes, reason = donaldson_check(E8)
    print(f"\n  E₈ passes Donaldson check: {passes}")
    print(f"  Reason: {reason}")
    print(f"\n  → The E₈ form is positive definite, unimodular, and non-diagonal.")
    print(f"  → By Freedman: a topological 4-manifold with this form EXISTS.")
    print(f"  → By Donaldson: no SMOOTH 4-manifold can have this form.")
    print(f"  → Therefore: a topological manifold with NO smooth structure!")

    # Check diagonal forms (which DO pass)
    print(f"\n  Standard diagonal form I₈:")
    I8 = np.eye(8, dtype=np.int64)
    passes, reason = donaldson_check(I8)
    print(f"    Passes Donaldson: {passes} ({reason})")


def demo_hyperbolic():
    """Demonstrate hyperbolic form properties."""
    print("\n" + "=" * 60)
    print("THE HYPERBOLIC FORM")
    print("=" * 60)

    H = hyperbolic_matrix()
    print(f"\n  H = {H.tolist()}")

    props = classify_form(H)
    print(f"  Determinant: {props['determinant']}")
    print(f"  Unimodular: {props['unimodular']}")
    print(f"  Even: {props['even']}")
    print(f"  Signature: {props['signature']}")
    print(f"  b⁺ = {props['b_plus']}, b⁻ = {props['b_minus']}")

    # H ⊕ E₈: the form of K3 surface
    E8 = e8_matrix()
    H3 = direct_sum(direct_sum(H, H), H)  # H^3
    K3_form = direct_sum(H3, direct_sum(E8, E8))  # 3H ⊕ 2E₈ ≈ wrong. K3 = 3H ⊕ (-E₈)² 
    # Actually K3 has form -E₈ ⊕ -E₈ ⊕ 3H
    neg_E8 = -E8
    K3_form = direct_sum(direct_sum(neg_E8, neg_E8), H3)

    print(f"\n  K3 surface form (2(-E₈) ⊕ 3H), rank {K3_form.shape[0]}:")
    K3_props = classify_form(K3_form)
    print(f"    Determinant: {K3_props['determinant']}")
    print(f"    Even: {K3_props['even']}")
    print(f"    Signature: {K3_props['signature']}")
    print(f"    b⁺ = {K3_props['b_plus']}, b⁻ = {K3_props['b_minus']}")


def demo_furuta():
    """Demonstrate Furuta's bound and the 11/8 conjecture."""
    print("\n" + "=" * 60)
    print("FURUTA'S BOUND AND THE 11/8 CONJECTURE")
    print("=" * 60)

    print("\n  Testing various (n, b⁺, b⁻) combinations:")
    print(f"  {'n':>4} {'b⁺':>4} {'b⁻':>4} {'|σ|':>4} {'Furuta':>10} {'11/8':>10}")
    print(f"  {'-'*4} {'-'*4} {'-'*4} {'-'*4} {'-'*10} {'-'*10}")

    test_cases = [
        (22, 3, 19),   # K3 surface
        (8, 0, 8),     # E₈ (definite)
        (16, 0, 16),   # 2E₈ (definite)
        (10, 1, 9),    # Generic spin
        (4, 1, 3),     # Small example
        (24, 8, 16),   # Niemeier-like
        (32, 12, 20),  # Larger example
    ]

    for n, bp, bm in test_cases:
        d = abs(bp - bm)
        f_pass, _ = furuta_check(n, bp, bm)
        e_pass, _ = eleven_eighths_check(n, bp, bm)
        print(f"  {n:4d} {bp:4d} {bm:4d} {d:4d} {'✓' if f_pass else '✗':>10} {'✓' if e_pass else '✗':>10}")


def demo_direct_sums():
    """Demonstrate direct sum constructions."""
    print("\n" + "=" * 60)
    print("DIRECT SUM CONSTRUCTIONS")
    print("=" * 60)

    E8 = e8_matrix()
    H = hyperbolic_matrix()

    forms = {
        "E₈": E8,
        "H": H,
        "E₈ ⊕ E₈": direct_sum(E8, E8),
        "-E₈": -E8,
        "H ⊕ H": direct_sum(H, H),
        "I₁": np.array([[1]], dtype=np.int64),
        "-I₁": np.array([[-1]], dtype=np.int64),
    }

    print(f"\n  {'Form':<12} {'Rank':>5} {'Det':>5} {'Unim':>6} {'Even':>5} "
          f"{'Def':>5} {'Diag':>5} {'Donaldson':>15}")
    print(f"  {'-'*12} {'-'*5} {'-'*5} {'-'*6} {'-'*5} {'-'*5} {'-'*5} {'-'*15}")

    for name, Q in forms.items():
        props = classify_form(Q)
        d_pass, d_reason = props['donaldson']
        print(f"  {name:<12} {props['rank']:>5} {props['determinant']:>5} "
              f"{'✓' if props['unimodular'] else '✗':>6} "
              f"{'✓' if props['even'] else '✗':>5} "
              f"{'✓' if props['definite'] else '✗':>5} "
              f"{'✓' if props['diagonal'] else '✗':>5} "
              f"{'✓' if d_pass else '✗':>15}")


if __name__ == "__main__":
    demo_e8()
    demo_freedman_donaldson()
    demo_hyperbolic()
    demo_furuta()
    demo_direct_sums()
    print("\n" + "=" * 60)
    print("Done!")


#!/usr/bin/env python3
"""
Visualization of the E8 lattice and intersection form properties.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def e8_matrix():
    return np.array([
        [ 2, -1,  0,  0,  0,  0,  0,  0],
        [-1,  2, -1,  0,  0,  0,  0,  0],
        [ 0, -1,  2, -1,  0,  0,  0, -1],
        [ 0,  0, -1,  2, -1,  0,  0,  0],
        [ 0,  0,  0, -1,  2, -1,  0,  0],
        [ 0,  0,  0,  0, -1,  2, -1,  0],
        [ 0,  0,  0,  0,  0, -1,  2,  0],
        [ 0,  0, -1,  0,  0,  0,  0,  2]
    ], dtype=np.int64)


def plot_e8_dynkin():
    """Plot the E8 Dynkin diagram."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("E₈ Lattice and 4-Manifold Intersection Forms", fontsize=16, fontweight='bold')

    # --- Panel 1: E8 Dynkin diagram ---
    ax = axes[0, 0]
    ax.set_title("E₈ Dynkin Diagram", fontsize=13)

    # Node positions
    nodes = {0: (0, 0), 1: (1, 0), 2: (2, 0), 3: (3, 0),
             4: (4, 0), 5: (5, 0), 6: (6, 0), 7: (2, 1)}
    edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,6), (2,7)]

    for i, j in edges:
        x = [nodes[i][0], nodes[j][0]]
        y = [nodes[i][1], nodes[j][1]]
        ax.plot(x, y, 'k-', linewidth=2)

    for idx, (x, y) in nodes.items():
        circle = plt.Circle((x, y), 0.15, color='#2196F3', ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y - 0.35, f"v{idx}", ha='center', fontsize=9)

    ax.set_xlim(-0.5, 6.5)
    ax.set_ylim(-0.7, 1.7)
    ax.set_aspect('equal')
    ax.axis('off')

    # --- Panel 2: E8 matrix heatmap ---
    ax = axes[0, 1]
    ax.set_title("E₈ Cartan Matrix", fontsize=13)
    E8 = e8_matrix()
    im = ax.imshow(E8, cmap='RdBu_r', vmin=-2, vmax=2, aspect='equal')
    for i in range(8):
        for j in range(8):
            color = 'white' if abs(E8[i, j]) > 1 else 'black'
            ax.text(j, i, str(E8[i, j]), ha='center', va='center', fontsize=11, color=color, fontweight='bold')
    ax.set_xticks(range(8))
    ax.set_yticks(range(8))
    plt.colorbar(im, ax=ax, fraction=0.046)

    # --- Panel 3: Eigenvalue spectrum ---
    ax = axes[1, 0]
    ax.set_title("Eigenvalue Spectrum of E₈", fontsize=13)
    eigenvalues = np.linalg.eigvalsh(E8.astype(float))
    colors = ['#4CAF50' if e > 0 else '#F44336' for e in eigenvalues]
    ax.bar(range(8), sorted(eigenvalues), color=colors, edgecolor='black', linewidth=1)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel("Eigenvalue Index")
    ax.set_ylabel("Value")
    ax.set_xticks(range(8))
    green_patch = mpatches.Patch(color='#4CAF50', label='Positive (→ pos. definite)')
    ax.legend(handles=[green_patch], loc='upper left')

    # --- Panel 4: Donaldson obstruction summary ---
    ax = axes[1, 1]
    ax.set_title("Donaldson Obstruction", fontsize=13)
    ax.axis('off')

    text = """
    FREEDMAN-DONALDSON THEOREM

    ✓ E₈ is positive definite
    ✓ E₈ is unimodular (det = 1)
    ✗ E₈ is NOT diagonal

    By Freedman (1982):
      The E₈ topological manifold EXISTS

    By Donaldson (1983):
      Definite forms of smooth manifolds
      must be diagonal

    ∴ The E₈ manifold has
      NO smooth structure!

    This phenomenon is unique
    to dimension 4.
    """
    ax.text(0.1, 0.95, text, transform=ax.transAxes, fontsize=11,
            verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig('e8_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved e8_visualization.png")


def plot_furuta_bounds():
    """Plot the Furuta and 11/8 bounds."""
    fig, ax = plt.subplots(figsize=(10, 7))
    ax.set_title("Smooth 4-Manifold Geography: Rank vs Signature", fontsize=14, fontweight='bold')

    # The constraints for spin manifolds:
    # Furuta: 8n >= 10|σ| + 16, i.e., n >= 10|σ|/8 + 2
    # 11/8: 8n >= 11|σ|, i.e., n >= 11|σ|/8

    sigma = np.linspace(0, 40, 200)

    # Furuta bound
    n_furuta = 10 * sigma / 8 + 2
    # 11/8 bound
    n_118 = 11 * sigma / 8
    # Trivial bound n >= |σ| (rank >= |signature|)
    n_trivial = sigma

    ax.fill_between(sigma, n_furuta, 50, alpha=0.15, color='green', label='Allowed by Furuta (10/8 + 2)')
    ax.fill_between(sigma, n_118, 50, alpha=0.15, color='blue', label='Allowed by 11/8 conjecture')

    ax.plot(sigma, n_furuta, 'g-', linewidth=2, label='Furuta bound: n ≥ 10|σ|/8 + 2')
    ax.plot(sigma, n_118, 'b--', linewidth=2, label='11/8 conjecture: n ≥ 11|σ|/8')
    ax.plot(sigma, n_trivial, 'k:', linewidth=1, alpha=0.5, label='Trivial: n ≥ |σ|')

    # Mark known manifolds
    manifolds = {
        'K3': (16, 22),
        'E₈': (8, 8),
        'S²×S²': (0, 2),
        '2E₈': (16, 16),
    }
    for name, (sig, rank) in manifolds.items():
        color = 'red' if rank < 10*sig/8 + 2 else 'green'
        ax.plot(sig, rank, 'o', markersize=10, color=color, zorder=5)
        ax.annotate(name, (sig, rank), textcoords="offset points", xytext=(8, 5), fontsize=10)

    ax.set_xlabel("|Signature σ|", fontsize=12)
    ax.set_ylabel("Rank n", fontsize=12)
    ax.set_xlim(0, 40)
    ax.set_ylim(0, 50)
    ax.legend(loc='upper left', fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('furuta_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved furuta_bounds.png")


if __name__ == "__main__":
    plot_e8_dynkin()
    plot_furuta_bounds()
