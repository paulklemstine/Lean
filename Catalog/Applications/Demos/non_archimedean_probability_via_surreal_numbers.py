"""
Non-Archimedean Probability: Numerical Demonstrations

Demonstrates the key theorems using rational arithmetic to simulate
infinitesimal behavior. We use 1/N for large N as a stand-in for
infinitesimals, showing how the theorems manifest computationally.
"""

from fractions import Fraction
from itertools import combinations
from typing import List, Set, Tuple


def is_approximately_infinitesimal(eps: Fraction, max_n: int = 1000) -> bool:
    """Check if eps < 1/(n+1) for all n up to max_n."""
    return all(eps < Fraction(1, n + 1) for n in range(max_n))


def uniform_measure(eps: Fraction, S: Set[int]) -> Fraction:
    """Uniform infinitesimal measure: μ_ε(S) = |S| · ε"""
    return len(S) * eps


def conditional_probability(eps: Fraction, A: Set[int], B: Set[int]) -> Fraction:
    """Conditional probability P_ε(A|B) = μ_ε(A∩B) / μ_ε(B)"""
    if not B:
        raise ValueError("Cannot condition on empty set")
    return uniform_measure(eps, A & B) / uniform_measure(eps, B)


def demonstrate_archimedean_barrier():
    """Theorem 1: In ℚ (Archimedean), no infinitesimal exists."""
    print("=" * 60)
    print("THEOREM 1: Archimedean Barrier")
    print("=" * 60)
    print()

    for N in [10, 100, 1000, 10**6]:
        eps = Fraction(1, N)
        # Find n where (n+1)*eps >= 1
        n_bound = N - 1  # (N-1+1) * (1/N) = 1
        print(f"  ε = 1/{N}:")
        print(f"    {n_bound + 1} · ε = {(n_bound + 1) * eps} ≥ 1  ✓")
        print(f"    Not infinitesimal: fails at n = {n_bound}")
    print()
    print("  → In ℚ (or ℝ), every positive number eventually exceeds 1/(n+1).")
    print()


def demonstrate_finite_additivity():
    """Theorem 2: Uniform measure is finitely additive."""
    print("=" * 60)
    print("THEOREM 2: Finite Additivity")
    print("=" * 60)
    print()

    eps = Fraction(1, 10**9)  # Very small but not infinitesimal
    S = {0, 1, 2, 3}
    T = {4, 5, 6}

    mu_S = uniform_measure(eps, S)
    mu_T = uniform_measure(eps, T)
    mu_ST = uniform_measure(eps, S | T)

    print(f"  ε = 1/10⁹")
    print(f"  S = {S}, T = {T}")
    print(f"  μ(S) = {len(S)}ε = {mu_S}")
    print(f"  μ(T) = {len(T)}ε = {mu_T}")
    print(f"  μ(S∪T) = {len(S | T)}ε = {mu_ST}")
    print(f"  μ(S) + μ(T) = {mu_S + mu_T}")
    print(f"  μ(S∪T) = μ(S) + μ(T)? {mu_ST == mu_S + mu_T}  ✓")
    print()


def demonstrate_conditional_universality():
    """Theorem 3: Conditional probability is independent of ε."""
    print("=" * 60)
    print("THEOREM 3: Infinitesimal Universality")
    print("=" * 60)
    print()

    A = {0, 1, 2}
    B = {1, 2, 3, 4, 5}
    print(f"  A = {A}, B = {B}")
    print(f"  A ∩ B = {A & B}")
    print(f"  |A ∩ B| / |B| = {len(A & B)} / {len(B)} = {Fraction(len(A & B), len(B))}")
    print()

    for N in [10, 1000, 10**6, 10**12, 10**100]:
        eps = Fraction(1, N)
        cp = conditional_probability(eps, A, B)
        label = f"10^{len(str(N))-1}" if N > 100 else str(N)
        print(f"  ε = 1/{label:>12s}:  P(A|B) = {cp}")

    # All the same!
    print()
    eps_values = [Fraction(1, N) for N in [7, 13, 997, 10**6]]
    cps = [conditional_probability(eps, A, B) for eps in eps_values]
    print(f"  All conditional probabilities equal? {len(set(cps)) == 1}  ✓")
    print(f"  Value: {cps[0]} (= |A∩B|/|B| = 2/5)")
    print()


def demonstrate_infinitesimal_stratification():
    """Theorem 4: ε² ≪ ε (higher-order infinitesimal)."""
    print("=" * 60)
    print("THEOREM 4: Infinitesimal Stratification")
    print("=" * 60)
    print()

    N = 10**6
    eps = Fraction(1, N)
    eps_sq = eps * eps

    print(f"  ε = 1/{N}")
    print(f"  ε² = 1/{N**2}")
    print()

    for n in [1, 10, 100, 1000]:
        ratio = (n + 1) * eps_sq
        print(f"  (n+1)·ε² for n={n}: {float(ratio):.2e}  < ε = {float(eps):.2e}?  {ratio < eps}  ✓")

    print()
    print(f"  Key: ε²/ε = ε = {float(eps):.2e} → 0 as ε → 0")
    print(f"  The ratio shrinks, showing ε² is 'doubly infinitesimal'")
    print()


def demonstrate_archimedean_measure_duality():
    """Theorem 5: Archimedean ↔ no universal point mass."""
    print("=" * 60)
    print("THEOREM 5: Archimedean-Measure Duality")
    print("=" * 60)
    print()

    print("  Archimedean side (ℚ):")
    for eps_denom in [10, 100, 1000]:
        eps = Fraction(1, eps_denom)
        N_bound = eps_denom  # N·ε ≥ 1
        print(f"    ε = 1/{eps_denom}: need N ≥ {N_bound} for N·ε ≥ 1")

    print()
    print("  Non-Archimedean side (simulated with ε = 1/10¹⁰⁰):")
    eps = Fraction(1, 10**100)
    for n in [1, 10**10, 10**50, 10**99]:
        val = n * eps
        print(f"    n = 10^{len(str(n))-1}: n·ε = {float(val):.2e} < 1?  True")

    print()
    print("  In a truly non-Archimedean field, n·ε < 1 for ALL finite n.")
    print()


def demonstrate_bridge_theorem():
    """Bridge: Positive weights give positive measures."""
    print("=" * 60)
    print("BRIDGE: Positive Weight Anti-Cancellation")
    print("=" * 60)
    print()

    eps = Fraction(1, 10**15)
    weights = {i: eps * (i + 1) for i in range(5)}

    print(f"  Weights: w(i) = (i+1) · ε where ε = 1/10¹⁵")
    for i, w in weights.items():
        print(f"    w({i}) = {float(w):.2e}")

    for subset_size in range(1, 6):
        for S in [set(range(subset_size))]:
            total = sum(weights[i] for i in S)
            print(f"  μ({S}) = {float(total):.2e} > 0? {total > 0}  ✓")
    print()
    print("  → All nonempty sets get strictly positive measure,")
    print("    even with infinitesimal weights. (Anti-cancellation)")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  NON-ARCHIMEDEAN PROBABILITY: NUMERICAL DEMONSTRATIONS  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demonstrate_archimedean_barrier()
    demonstrate_finite_additivity()
    demonstrate_conditional_universality()
    demonstrate_infinitesimal_stratification()
    demonstrate_archimedean_measure_duality()
    demonstrate_bridge_theorem()

    print("All demonstrations completed successfully.")


"""
Visualization: Infinitesimal Stratification

Shows how powers of an infinitesimal create a hierarchy of scales,
using log-scale plots with 1/N as a stand-in for infinitesimals.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_infinitesimal_stratification():
    """Plot the hierarchy ε ≫ ε² ≫ ε³ for various ε values."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: stratification for fixed ε, varying order
    ax1 = axes[0]
    N_values = [10, 100, 1000, 10000]
    orders = range(1, 6)

    for N in N_values:
        eps = 1.0 / N
        values = [eps**k for k in orders]
        ax1.semilogy(list(orders), values, 'o-', label=f'ε = 1/{N}', markersize=8)

    ax1.set_xlabel('Order k', fontsize=14)
    ax1.set_ylabel('ε^k (log scale)', fontsize=14)
    ax1.set_title('Infinitesimal Stratification\nε ≫ ε² ≫ ε³ ≫ ...', fontsize=16)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Right: domination bound (n+1)·ε² < ε
    ax2 = axes[1]
    n_range = np.arange(1, 101)

    for N in [10, 50, 200, 1000]:
        eps = 1.0 / N
        lhs = (n_range + 1) * eps**2
        ax2.semilogy(n_range, lhs, '-', label=f'(n+1)·ε² (ε=1/{N})', alpha=0.8)
        ax2.axhline(y=eps, linestyle='--', alpha=0.4)

    ax2.set_xlabel('n', fontsize=14)
    ax2.set_ylabel('Value (log scale)', fontsize=14)
    ax2.set_title('Domination: (n+1)·ε² < ε\nfor all n (Theorem 4)', fontsize=16)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('stratification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved stratification.png")


def plot_archimedean_duality():
    """Plot the Archimedean barrier: N·ε vs 1."""
    fig, ax = plt.subplots(figsize=(10, 6))

    N_range = np.arange(1, 201)

    for eps_inv in [20, 50, 100, 200]:
        eps = 1.0 / eps_inv
        vals = N_range * eps
        ax.plot(N_range, vals, '-', label=f'N·ε (ε=1/{eps_inv})', linewidth=2)

    ax.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Threshold = 1')
    ax.fill_between(N_range, 1, 2, alpha=0.1, color='red')

    ax.set_xlabel('N (number of points)', fontsize=14)
    ax.set_ylabel('Total measure N·ε', fontsize=14)
    ax.set_title('Archimedean Barrier: N·ε Eventually Exceeds 1\n'
                 '(Theorem 5: No universal point mass in Archimedean fields)',
                 fontsize=14)
    ax.legend(fontsize=12)
    ax.set_ylim(0, 2)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('archimedean_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved archimedean_duality.png")


if __name__ == "__main__":
    plot_infinitesimal_stratification()
    plot_archimedean_duality()
    print("All visualizations generated.")
