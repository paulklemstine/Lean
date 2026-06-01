#!/usr/bin/env python3
"""
Demo: Exotic Smooth Structure Detection on 4-Manifolds

This script demonstrates the algebraic machinery for detecting exotic
smooth structures using intersection form theory. It verifies that the
E₈ lattice constitutes an ExoticWitness — a certificate that the
corresponding topological 4-manifold cannot be given a smooth structure.
"""

import numpy as np
from algorithms import (
    e8_cartan_matrix,
    verify_exotic_witness,
    minimum_norm_search,
    furuta_bound_check,
    intersection_form_geography,
    signature_computation,
    quadratic_form,
)


def demo_e8_exotic_witness():
    """Demonstrate that E₈ is an ExoticWitness."""
    print("=" * 60)
    print("E₈ EXOTIC WITNESS VERIFICATION")
    print("=" * 60)
    
    E8 = e8_cartan_matrix()
    print("\nE₈ Cartan Matrix:")
    print(E8)
    
    result = verify_exotic_witness(E8)
    print(f"\nVerification Results:")
    print(f"  Rank:              {result['rank']}")
    print(f"  Symmetric:         {result['symmetric']}")
    print(f"  Even diagonal:     {result['even_diagonal']}")
    print(f"  Positive definite: {result['positive_definite']}")
    print(f"  Unimodular:        {result['unimodular']} (det = {result['determinant']})")
    print(f"  IS EXOTIC WITNESS: {result['is_exotic_witness']}")
    
    if result['is_exotic_witness']:
        print("\n  ✓ By Donaldson's theorem, no smooth 4-manifold has")
        print("    E₈ as its intersection form.")
        print("  ✓ By Freedman's theorem, the topological manifold EXISTS.")
        print("  ⟹ EXOTIC STRUCTURE DETECTED: topology ≠ smooth in dim 4!")


def demo_minimum_norm():
    """Demonstrate the minimum norm argument."""
    print("\n" + "=" * 60)
    print("MINIMUM NORM ANALYSIS")
    print("=" * 60)
    
    E8 = e8_cartan_matrix()
    min_norm, min_vec = minimum_norm_search(E8, search_radius=2)
    
    print(f"\nMinimum nonzero norm in E₈: {min_norm}")
    print(f"Achieved by vector: {min_vec}")
    print(f"Verification: v^T E₈ v = {quadratic_form(E8, min_vec)}")
    
    print(f"\nThe identity matrix I₈ has minimum norm 1 (from basis vectors).")
    print(f"E₈ has minimum norm {min_norm} ≥ 2 (from even + positive definite).")
    print(f"Therefore E₈ ≇ I₈ over ℤ — they are NOT equivalent!")
    
    # Also check the identity
    I8 = np.eye(8, dtype=int)
    min_norm_I, min_vec_I = minimum_norm_search(I8, search_radius=1)
    print(f"\nMinimum nonzero norm in I₈: {min_norm_I}")
    print(f"Achieved by vector: {min_vec_I}")


def demo_furuta_bounds():
    """Demonstrate Furuta's 10/8 theorem exclusions."""
    print("\n" + "=" * 60)
    print("FURUTA 10/8 BOUND ANALYSIS")
    print("=" * 60)
    
    test_cases = [
        ("E₈", 8, 8),
        ("E₈ ⊕ E₈", 16, 16),
        ("E₈ ⊕ H", 10, 8),
        ("2E₈ ⊕ 3H", 22, 16),
        ("3E₈ ⊕ 22H", 68, 24),
    ]
    
    print(f"\n{'Form':<15} {'Rank':>5} {'|σ|':>5} {'8r':>5} {'10|σ|+16':>9} {'Furuta':>7} {'11/8':>7}")
    print("-" * 60)
    
    for name, rank, abs_sig in test_cases:
        result = furuta_bound_check(rank, abs_sig)
        print(f"{name:<15} {rank:>5} {abs_sig:>5} {8*rank:>5} {10*abs_sig+16:>9} "
              f"{'✓' if result['furuta_satisfied'] else '✗':>7} "
              f"{'✓' if result['conjecture_11_8_satisfied'] else '✗':>7}")


def demo_geography():
    """Demonstrate the geography of even smooth 4-manifolds."""
    print("\n" + "=" * 60)
    print("GEOGRAPHY OF EVEN SMOOTH 4-MANIFOLDS")
    print("=" * 60)
    
    feasible = intersection_form_geography(max_rank=40)
    
    print(f"\nFeasible (rank, |σ|) pairs with rank ≤ 40:")
    print(f"{'Rank':>5} {'|σ|':>5} {'b⁺':>5} {'b⁻':>5} {'Margin':>7} {'11/8?':>6}")
    print("-" * 40)
    
    for entry in feasible[:20]:
        print(f"{entry['rank']:>5} {entry['abs_signature']:>5} "
              f"{entry['b_plus']:>5} {entry['b_minus']:>5} "
              f"{entry['furuta_margin']:>7} "
              f"{'✓' if entry['conjecture_11_8'] else '✗':>6}")
    
    if len(feasible) > 20:
        print(f"  ... ({len(feasible)} total feasible pairs)")


def demo_signature_additivity():
    """Demonstrate signature additivity under direct sum."""
    print("\n" + "=" * 60)
    print("SIGNATURE ADDITIVITY")
    print("=" * 60)
    
    E8 = e8_cartan_matrix()
    sig_E8 = signature_computation(E8)
    
    # Direct sum E₈ ⊕ (-E₈)
    neg_E8 = -E8
    sig_neg_E8 = signature_computation(neg_E8)
    
    # Block diagonal sum
    E8_sum = np.block([
        [E8, np.zeros((8, 8), dtype=int)],
        [np.zeros((8, 8), dtype=int), neg_E8]
    ])
    sig_sum = signature_computation(E8_sum)
    
    print(f"\nE₈:         σ = {sig_E8['signature']:>3}  (b⁺={sig_E8['b_plus']}, b⁻={sig_E8['b_minus']})")
    print(f"-E₈:        σ = {sig_neg_E8['signature']:>3}  (b⁺={sig_neg_E8['b_plus']}, b⁻={sig_neg_E8['b_minus']})")
    print(f"E₈ ⊕ (-E₈): σ = {sig_sum['signature']:>3}  (b⁺={sig_sum['b_plus']}, b⁻={sig_sum['b_minus']})")
    print(f"\nAdditivity: {sig_E8['signature']} + {sig_neg_E8['signature']} = {sig_E8['signature'] + sig_neg_E8['signature']} = {sig_sum['signature']} ✓")


if __name__ == "__main__":
    demo_e8_exotic_witness()
    demo_minimum_norm()
    demo_furuta_bounds()
    demo_geography()
    demo_signature_additivity()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
Key results verified numerically:

1. E₈ is an ExoticWitness (symmetric, even, pos.def., unimodular)
2. E₈ has minimum norm 2, proving it's not ℤ-equivalent to I₈
3. Furuta's 10/8 bound excludes E₈ and E₈ ⊕ E₈ from being smooth
4. Signatures are additive under direct sum
5. The geography of feasible even smooth forms is highly constrained

These results establish the algebraic foundation for detecting exotic
smooth structures on 4-manifolds — one of the deepest phenomena in
modern mathematics.
""")


#!/usr/bin/env python3
"""
Visualization: Geography of Smooth 4-Manifold Intersection Forms

Plots the feasible region for even unimodular intersection forms
under the Rohlin, Furuta, and conjectured 11/8 constraints.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_geography():
    """Plot the geography of even smooth 4-manifold intersection forms."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    
    max_sig = 80
    max_rank = 100
    
    # Shaded regions for constraints
    sig_range = np.linspace(0, max_sig, 500)
    
    # Furuta bound: r >= (10/8)|σ| + 2
    furuta_line = (10/8) * sig_range + 2
    ax.fill_between(sig_range, furuta_line, max_rank, alpha=0.15, color='green',
                    label='Furuta feasible (r ≥ 10|σ|/8 + 2)')
    ax.plot(sig_range, furuta_line, 'g-', linewidth=2)
    
    # 11/8 conjecture: r >= (11/8)|σ|
    conj_line = (11/8) * sig_range
    ax.plot(sig_range, conj_line, 'b--', linewidth=2, alpha=0.7,
            label='11/8 conjecture (r ≥ 11|σ|/8)')
    
    # Trivial bound: r >= |σ|
    ax.plot(sig_range, sig_range, 'k:', linewidth=1, alpha=0.5, label='r ≥ |σ|')
    
    # Mark Rohlin-allowed points
    rohlin_points_x = []
    rohlin_points_y = []
    excluded_x = []
    excluded_y = []
    
    for sig in range(0, max_sig + 1, 16):  # Rohlin: σ ≡ 0 mod 16
        for rank in range(sig, max_rank + 1, 2):  # Parity constraint
            if 8 * rank >= 10 * sig + 16:
                rohlin_points_x.append(sig)
                rohlin_points_y.append(rank)
            elif rank >= sig:
                excluded_x.append(sig)
                excluded_y.append(rank)
    
    ax.scatter(rohlin_points_x, rohlin_points_y, c='green', s=15, alpha=0.6,
              zorder=5, label='Feasible lattice points')
    ax.scatter(excluded_x, excluded_y, c='red', s=15, alpha=0.4,
              marker='x', zorder=4, label='Excluded by Furuta')
    
    # Mark specific forms
    forms = {
        'E₈': (8, 8),
        'E₈⊕E₈': (16, 16),
        'K3': (16, 22),
    }
    
    for name, (sig, rank) in forms.items():
        color = 'red' if 8 * rank < 10 * sig + 16 else 'blue'
        ax.annotate(name, (sig, rank), fontsize=11, fontweight='bold',
                   color=color, ha='left', va='bottom',
                   xytext=(5, 5), textcoords='offset points')
        ax.plot(sig, rank, 'o', color=color, markersize=8, zorder=10)
    
    ax.set_xlabel('|Signature| = |σ|', fontsize=13)
    ax.set_ylabel('Rank = r', fontsize=13)
    ax.set_title('Geography of Even Smooth 4-Manifold Intersection Forms', fontsize=14)
    ax.legend(loc='upper left', fontsize=10)
    ax.set_xlim(-2, max_sig)
    ax.set_ylim(-2, max_rank)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('geography_plot.png', dpi=150)
    print("Saved: geography_plot.png")


def plot_minimum_norm():
    """Visualize the minimum norm argument for E₈ vs identity."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Norm distribution for E₈
    # Generate random integer vectors and compute norms
    np.random.seed(42)
    E8 = np.array([
        [ 2, -1,  0,  0,  0,  0,  0,  0],
        [-1,  2, -1,  0,  0,  0,  0,  0],
        [ 0, -1,  2, -1,  0,  0,  0, -1],
        [ 0,  0, -1,  2, -1,  0,  0,  0],
        [ 0,  0,  0, -1,  2, -1,  0,  0],
        [ 0,  0,  0,  0, -1,  2, -1,  0],
        [ 0,  0,  0,  0,  0, -1,  2,  0],
        [ 0,  0, -1,  0,  0,  0,  0,  2],
    ], dtype=int)
    
    I8 = np.eye(8, dtype=int)
    
    # Sample random vectors
    n_samples = 5000
    vectors = np.random.randint(-3, 4, size=(n_samples, 8))
    vectors = vectors[np.any(vectors != 0, axis=1)]  # Remove zero vectors
    
    norms_e8 = np.array([v @ E8 @ v for v in vectors])
    norms_id = np.array([v @ I8 @ v for v in vectors])
    
    axes[0].hist(norms_e8, bins=range(0, 100, 2), color='steelblue', alpha=0.7,
                edgecolor='navy', linewidth=0.5)
    axes[0].axvline(x=2, color='red', linewidth=2, linestyle='--', label='Minimum norm = 2')
    axes[0].axvline(x=1, color='orange', linewidth=2, linestyle=':', alpha=0.7, label='Norm 1 (impossible)')
    axes[0].set_xlabel('Q(v) = vᵀE₈v', fontsize=12)
    axes[0].set_ylabel('Count', fontsize=12)
    axes[0].set_title('E₈ Quadratic Form Values\n(all even, minimum = 2)', fontsize=12)
    axes[0].legend(fontsize=10)
    axes[0].set_xlim(-1, 80)
    
    axes[1].hist(norms_id, bins=range(0, 80), color='coral', alpha=0.7,
                edgecolor='darkred', linewidth=0.5)
    axes[1].axvline(x=1, color='red', linewidth=2, linestyle='--', label='Minimum norm = 1')
    axes[1].set_xlabel('Q(v) = vᵀIv = ||v||²', fontsize=12)
    axes[1].set_ylabel('Count', fontsize=12)
    axes[1].set_title('Identity Form Values\n(minimum = 1, includes odd values)', fontsize=12)
    axes[1].legend(fontsize=10)
    axes[1].set_xlim(-1, 80)
    
    plt.suptitle('Why E₈ Cannot Be Diagonalized: The Minimum Norm Gap', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('minimum_norm_plot.png', dpi=150)
    print("Saved: minimum_norm_plot.png")


if __name__ == "__main__":
    plot_geography()
    plot_minimum_norm()
