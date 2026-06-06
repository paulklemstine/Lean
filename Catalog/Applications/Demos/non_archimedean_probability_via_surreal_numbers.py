#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory — Demonstration

This script demonstrates the key concepts from the non-Archimedean probability
theory developed in this research cycle:

1. The Archimedean impossibility: why standard ℝ can't have infinitesimal probabilities
2. Finite approximations to infinitesimal probability measures
3. The infinitesimal gap property
4. Strict monotonicity of positive-weight measures
"""

from fractions import Fraction
from typing import List, Set


def archimedean_impossibility_demo():
    """Demonstrate that in ℝ, any ε > 0 eventually exceeds 1 when summed."""
    print("=" * 60)
    print("ARCHIMEDEAN IMPOSSIBILITY THEOREM")
    print("In ℝ, for any ε > 0, there exists n with n·ε > 1")
    print("=" * 60)

    for eps in [0.1, 0.01, 0.001, 1e-6, 1e-10]:
        # Compute n analytically: n = ceil(1/eps)
        import math
        n = math.ceil(1.0 / eps)
        print(f"  ε = {eps:<15}  →  n = {n:>15,} copies needed to exceed 1")
        print(f"    n·ε = {n * eps:.6f}")
    print()


def uniform_measure_demo():
    """Demonstrate uniform finitely additive measures on Fin(n)."""
    print("=" * 60)
    print("UNIFORM FINITELY ADDITIVE MEASURES")
    print("On Fin(n), each point gets weight 1/n, total = 1")
    print("=" * 60)

    for n in [3, 5, 10, 100]:
        eps = Fraction(1, n)
        total = sum(eps for _ in range(n))
        assert total == 1, f"Total should be 1, got {total}"
        print(f"  Fin({n}): ε = 1/{n}, total = {total}")

        # Demonstrate additivity for disjoint subsets
        s1 = set(range(n // 3))
        s2 = set(range(n // 3, 2 * n // 3))
        mu_s1 = Fraction(len(s1), n)
        mu_s2 = Fraction(len(s2), n)
        mu_union = Fraction(len(s1 | s2), n)
        assert mu_union == mu_s1 + mu_s2
        print(f"    μ(S1) = {mu_s1}, μ(S2) = {mu_s2}, "
              f"μ(S1∪S2) = {mu_union} = μ(S1)+μ(S2) ✓")
    print()


def infinitesimal_approximation_demo():
    """Approximate infinitesimal probability with very small rationals."""
    print("=" * 60)
    print("INFINITESIMAL PROBABILITY APPROXIMATION")
    print("As ε → 0, we can weight more points while staying below 1")
    print("=" * 60)

    # Simulate with exact rational arithmetic
    for power in [2, 4, 8, 16, 32]:
        omega = 10 ** power  # "infinite" number
        eps = Fraction(1, omega)
        # Assign weight ε to each of k points
        for k_power in [1, 2, 4, 8]:
            k = 10 ** k_power
            if k < omega:
                total = eps * k
                gap = 1 - total
                print(f"  ω = 10^{power}, ε = 1/ω, k = 10^{k_power}: "
                      f"total = {float(total):.2e}, gap = {float(gap):.10f}")
        print()


def strict_monotonicity_demo():
    """Demonstrate strict monotonicity of positive-weight measures."""
    print("=" * 60)
    print("STRICT MONOTONICITY")
    print("S ⊂ T with positive weights ⟹ μ(S) < μ(T)")
    print("=" * 60)

    n = 10
    # Use different positive weights
    weights = [Fraction(1, k + 1) for k in range(n)]
    print(f"  Weights: {[str(w) for w in weights]}")

    # Show strict monotonicity for nested subsets
    for size in range(1, n + 1):
        subset = set(range(size))
        mu = sum(weights[i] for i in subset)
        print(f"  |S| = {size:2d}: μ(S) = {float(mu):.6f} ({mu})")
    print()


def gap_persistence_demo():
    """Demonstrate that the infinitesimal gap never closes."""
    print("=" * 60)
    print("INFINITESIMAL GAP PERSISTENCE")
    print("For all finite n: 1 - n·ε > 0 (the gap never closes)")
    print("=" * 60)

    omega = 10**20  # Large "infinite" number
    eps = Fraction(1, omega)

    print(f"  ε = 1/{omega} (approximating an infinitesimal)")
    for n in [1, 10, 100, 1000, 10**6, 10**9, 10**12, 10**15, 10**18]:
        total = eps * n
        gap = 1 - total
        print(f"  n = {n:>20,}: gap = 1 - n·ε = {float(gap):.20f}")

    print(f"\n  At n = ω = {omega}: gap = 1 - ω·ε = {float(1 - eps * omega):.1f}")
    print("  ↑ The gap closes ONLY at the hyperfinite boundary!")
    print()


def complement_formula_demo():
    """Demonstrate μ(Aᶜ) = 1 - μ(A)."""
    print("=" * 60)
    print("COMPLEMENT FORMULA: μ(Aᶜ) = 1 - μ(A)")
    print("=" * 60)

    n = 12
    eps = Fraction(1, n)

    for subset_size in [0, 1, 3, 6, 9, 12]:
        mu_a = eps * subset_size
        mu_comp = 1 - mu_a
        comp_direct = eps * (n - subset_size)
        assert mu_comp == comp_direct
        print(f"  |A| = {subset_size:2d}: μ(A) = {float(mu_a):.4f}, "
              f"μ(Aᶜ) = {float(mu_comp):.4f}, "
              f"μ(A) + μ(Aᶜ) = {float(mu_a + mu_comp):.1f} ✓")
    print()


if __name__ == "__main__":
    print("Non-Archimedean Probability Theory — Demonstrations")
    print("=" * 60)
    print()

    archimedean_impossibility_demo()
    uniform_measure_demo()
    infinitesimal_approximation_demo()
    strict_monotonicity_demo()
    gap_persistence_demo()
    complement_formula_demo()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Archimedean vs Non-Archimedean Probability

Shows how sums n·ε behave differently in Archimedean and non-Archimedean fields.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_archimedean_vs_nonarch():
    """Plot the fundamental difference between Archimedean and non-Archimedean sums."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Archimedean case (ε = 0.1, 0.01, 0.001)
    ax1 = axes[0]
    n_values = np.arange(0, 200)

    for eps, color, label in [
        (0.1, '#e74c3c', 'ε = 0.1'),
        (0.01, '#3498db', 'ε = 0.01'),
        (0.001, '#2ecc71', 'ε = 0.001')
    ]:
        sums = n_values * eps
        ax1.plot(n_values, sums, color=color, label=label, linewidth=2)

    ax1.axhline(y=1, color='black', linestyle='--', linewidth=1.5, label='Total = 1')
    ax1.set_xlabel('Number of points n', fontsize=12)
    ax1.set_ylabel('Total weight n·ε', fontsize=12)
    ax1.set_title('Archimedean Field (ℝ)\nEvery ε > 0 eventually exceeds 1', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.05, 2.0)
    ax1.grid(True, alpha=0.3)

    # Right: Non-Archimedean case (simulated)
    ax2 = axes[1]
    n_values_na = np.arange(0, 10000)

    # Simulate "infinitesimal" as 1/ω for large ω
    for omega, color, label in [
        (100000, '#e74c3c', 'ε = 1/ω (ω=10⁵)'),
        (1000000, '#3498db', 'ε = 1/ω (ω=10⁶)'),
        (10000000, '#2ecc71', 'ε = 1/ω (ω=10⁷)')
    ]:
        eps = 1.0 / omega
        sums = n_values_na * eps
        ax2.plot(n_values_na, sums, color=color, label=label, linewidth=2)

    ax2.axhline(y=1, color='black', linestyle='--', linewidth=1.5, label='Total = 1')
    ax2.set_xlabel('Number of points n', fontsize=12)
    ax2.set_ylabel('Total weight n·ε', fontsize=12)
    ax2.set_title('Non-Archimedean Field\nInfinitesimal ε: n·ε < 1 for all finite n', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(-0.05, 1.2)
    ax2.grid(True, alpha=0.3)

    # Add annotation
    ax2.annotate('Gap always positive!',
                xy=(8000, 0.85), fontsize=11, color='#8e44ad',
                fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='#8e44ad'),
                xytext=(5000, 0.5))

    plt.tight_layout()
    plt.savefig('archimedean_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: archimedean_comparison.png")


def plot_gap_persistence():
    """Plot how the gap 1 - n·ε persists for infinitesimal ε."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Different "ω" values
    omegas = [10**k for k in range(3, 9)]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(omegas)))

    for omega, color in zip(omegas, colors):
        eps = 1.0 / omega
        n_max = min(omega // 2, 100000)
        n_values = np.linspace(0, n_max, 1000)
        gaps = 1.0 - n_values * eps
        ax.plot(n_values / omega, gaps, color=color,
                label=f'ω = 10^{int(np.log10(omega))}', linewidth=2)

    ax.set_xlabel('Fraction of ω used (n/ω)', fontsize=12)
    ax.set_ylabel('Gap: 1 - n·ε', fontsize=12)
    ax.set_title('Infinitesimal Gap Persistence\n'
                 'The gap 1 - n·ε remains positive for all n < ω', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(0.4, 1.05)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='red', linestyle=':', linewidth=1, alpha=0.5)

    plt.tight_layout()
    plt.savefig('gap_persistence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gap_persistence.png")


def plot_strict_monotonicity():
    """Visualize strict monotonicity of positive-weight measures."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n = 15
    # Positive weights (decreasing for visual interest)
    weights = [1.0 / (k + 1) for k in range(n)]

    # Compute cumulative measures for nested subsets
    subset_sizes = list(range(n + 1))
    measures = [sum(weights[:k]) for k in subset_sizes]

    ax.bar(subset_sizes, measures, color='#3498db', alpha=0.7, edgecolor='#2980b9')
    ax.plot(subset_sizes, measures, 'o-', color='#e74c3c', linewidth=2, markersize=6)

    # Highlight strict increase
    for i in range(1, len(measures)):
        if measures[i] > measures[i-1]:
            ax.annotate('', xy=(i, measures[i]),
                       xytext=(i-1, measures[i-1]),
                       arrowprops=dict(arrowstyle='->', color='#2ecc71',
                                      lw=1.5))

    ax.set_xlabel('Subset size |S|', fontsize=12)
    ax.set_ylabel('Measure μ(S)', fontsize=12)
    ax.set_title('Strict Monotonicity of Positive-Weight Measures\n'
                 'S ⊂ T ⟹ μ(S) < μ(T) when all weights > 0', fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('strict_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: strict_monotonicity.png")


if __name__ == "__main__":
    plot_archimedean_vs_nonarch()
    plot_gap_persistence()
    plot_strict_monotonicity()
    print("\nAll visualizations generated.")
