#!/usr/bin/env python3
"""
Demo: Non-Archimedean Probability via Surreal Numbers

This script demonstrates the key ideas of infinitesimal probability theory
using numerical simulations with symbolic computation (via fractions as a
stand-in for non-Archimedean fields).
"""

from fractions import Fraction
from typing import Dict, List, Set, Tuple
import math


def uniform_measure(n: int) -> Dict[int, Fraction]:
    """Standard uniform measure on {0, ..., n-1}."""
    w = Fraction(1, n)
    return {i: w for i in range(n)}


def infinitesimal_premeasure(n: int, eps_num: int = 1, eps_den: int = 1000000) -> Dict[str, object]:
    """
    Construct an infinitesimal pre-measure on {0, ..., n-1}.
    
    Each point gets weight ε = eps_num/eps_den.
    The defect is 1 - n*ε > 0.
    
    This models the behavior in a non-Archimedean field where ε would
    be truly infinitesimal.
    """
    eps = Fraction(eps_num, eps_den)
    total_mass = n * eps
    defect = 1 - total_mass
    
    return {
        'n': n,
        'epsilon': eps,
        'total_mass': total_mass,
        'defect': defect,
        'defect_positive': defect > 0,
        'weights': {i: eps for i in range(n)},
    }


def two_level_measure(n: int, eps: Fraction, distinguished: int = 0) -> Dict[int, Fraction]:
    """
    Construct a two-level probability measure.
    
    Each non-distinguished point gets weight ε.
    The distinguished point gets weight 1 - (n-1)*ε.
    Total = 1.
    """
    bulk_weight = 1 - (n - 1) * eps
    weights = {}
    for i in range(n):
        if i == distinguished:
            weights[i] = bulk_weight
        else:
            weights[i] = eps
    return weights


def conditional_probability(weights: Dict[int, Fraction], 
                           event_a: Set[int], 
                           event_b: Set[int]) -> Fraction:
    """P(B | A) = P(A ∩ B) / P(A)."""
    intersection = event_a & event_b
    p_a = sum(weights[i] for i in event_a if i in weights)
    p_ab = sum(weights[i] for i in intersection if i in weights)
    if p_a == 0:
        return Fraction(0)
    return p_ab / p_a


def verify_bayes(weights: Dict[int, Fraction], 
                 event_a: Set[int], 
                 event_b: Set[int]) -> bool:
    """Verify Bayes' theorem: P(B|A)·P(A) = P(A|B)·P(B)."""
    p_a = sum(weights[i] for i in event_a if i in weights)
    p_b = sum(weights[i] for i in event_b if i in weights)
    
    if p_a == 0 or p_b == 0:
        return True  # vacuously true
    
    p_b_given_a = conditional_probability(weights, event_a, event_b)
    p_a_given_b = conditional_probability(weights, event_b, event_a)
    
    lhs = p_b_given_a * p_a
    rhs = p_a_given_b * p_b
    
    return lhs == rhs


def demonstrate_archimedean_impossibility():
    """Show that in ℝ (Archimedean), infinitesimal probabilities don't exist."""
    print("=" * 60)
    print("ARCHIMEDEAN IMPOSSIBILITY")
    print("=" * 60)
    print()
    print("In an Archimedean ordered field (like ℝ), there are no")
    print("infinitesimals: for any ε > 0, there exists n with n·ε ≥ 1.")
    print()
    
    for eps_str, eps in [("0.1", 0.1), ("0.01", 0.01), ("1e-10", 1e-10), ("1e-100", 1e-100)]:
        n = math.ceil(1.0 / eps)
        print(f"  ε = {eps_str}: n = {n} gives n·ε = {n * eps:.2f} ≥ 1 ✓")
    
    print()
    print("No matter how small ε is, we can always find n to exceed 1.")
    print("This is why standard probability cannot have infinitesimal point masses.")
    print()


def demonstrate_infinitesimal_premeasure():
    """Demonstrate infinitesimal pre-measures."""
    print("=" * 60)
    print("INFINITESIMAL PRE-MEASURES")
    print("=" * 60)
    print()
    
    # Model: use very small rational ε as stand-in for infinitesimal
    for n in [10, 100, 1000]:
        eps = Fraction(1, 10**12)  # "infinitesimal" stand-in
        result = infinitesimal_premeasure(n, 1, 10**12)
        print(f"  n = {n}, ε = 10^(-12):")
        print(f"    Total mass = {float(result['total_mass']):.12e}")
        print(f"    Defect = {float(result['defect']):.12f}")
        print(f"    Defect > 0: {result['defect_positive']}")
        print()
    
    print("  Key insight: as n grows, total mass grows, but in a truly")
    print("  non-Archimedean field, n·ε < 1 for ALL n simultaneously.")
    print()


def demonstrate_two_level_measure():
    """Demonstrate the two-level probability construction."""
    print("=" * 60)
    print("TWO-LEVEL PROBABILITY MEASURE")
    print("=" * 60)
    print()
    
    n = 5
    eps = Fraction(1, 100)
    weights = two_level_measure(n, eps)
    
    print(f"  Space: {{0, 1, 2, 3, 4}}, ε = 1/100")
    print(f"  Distinguished element: 0")
    print()
    for i, w in weights.items():
        print(f"    P({i}) = {w} = {float(w):.4f}")
    
    total = sum(weights.values())
    print(f"\n  Total: {total} = {float(total):.4f}")
    print(f"  Sums to 1: {total == 1} ✓")
    print()
    
    # Verify finite additivity
    a = {1, 2}
    b = {3, 4}
    p_a = sum(weights[i] for i in a)
    p_b = sum(weights[i] for i in b)
    p_union = sum(weights[i] for i in a | b)
    print(f"  Finite additivity check:")
    print(f"    P({{1,2}}) = {p_a}")
    print(f"    P({{3,4}}) = {p_b}")
    print(f"    P({{1,2,3,4}}) = {p_union}")
    print(f"    P({{1,2}}) + P({{3,4}}) = {p_a + p_b}")
    print(f"    Additive: {p_union == p_a + p_b} ✓")
    print()


def demonstrate_bayes():
    """Demonstrate Bayes' theorem works with infinitesimal-scale measures."""
    print("=" * 60)
    print("BAYES' THEOREM IN NON-ARCHIMEDEAN SETTING")
    print("=" * 60)
    print()
    
    n = 6
    eps = Fraction(1, 1000)
    weights = two_level_measure(n, eps, distinguished=0)
    
    event_a = {0, 1, 2}
    event_b = {1, 2, 3}
    
    p_b_given_a = conditional_probability(weights, event_a, event_b)
    p_a_given_b = conditional_probability(weights, event_b, event_a)
    p_a = sum(weights[i] for i in event_a)
    p_b = sum(weights[i] for i in event_b)
    
    print(f"  Space: {{0,...,5}}, ε = 1/1000, distinguished = 0")
    print(f"  A = {{0,1,2}}, B = {{1,2,3}}")
    print(f"  P(A) = {p_a} ≈ {float(p_a):.6f}")
    print(f"  P(B) = {p_b} ≈ {float(p_b):.6f}")
    print(f"  P(B|A) = {p_b_given_a} ≈ {float(p_b_given_a):.6f}")
    print(f"  P(A|B) = {p_a_given_b} ≈ {float(p_a_given_b):.6f}")
    print()
    
    lhs = p_b_given_a * p_a
    rhs = p_a_given_b * p_b
    print(f"  Bayes check: P(B|A)·P(A) = {lhs}")
    print(f"               P(A|B)·P(B) = {rhs}")
    print(f"  Equal: {lhs == rhs} ✓")
    print()
    
    # Verify for multiple random event pairs
    import itertools
    violations = 0
    total_tests = 0
    for a_size in range(1, n):
        for b_size in range(1, n):
            for a_combo in itertools.combinations(range(n), a_size):
                for b_combo in itertools.combinations(range(n), b_size):
                    total_tests += 1
                    if not verify_bayes(weights, set(a_combo), set(b_combo)):
                        violations += 1
    
    print(f"  Exhaustive Bayes verification: {total_tests} event pairs tested")
    print(f"  Violations: {violations}")
    print()


def demonstrate_hierarchy():
    """Demonstrate the infinitesimal hierarchy ε > ε² > ε³ > ..."""
    print("=" * 60)
    print("INFINITESIMAL HIERARCHY")
    print("=" * 60)
    print()
    
    eps = Fraction(1, 1000)  # Stand-in for infinitesimal
    print(f"  ε = {eps}")
    print()
    
    for k in range(1, 6):
        val = eps ** k
        print(f"  ε^{k} = {val} = {float(val):.15e}")
    
    print()
    print("  In a non-Archimedean field, each power ε^k is infinitesimal")
    print("  relative to ε^(k-1), creating a natural hierarchy of scales.")
    print("  This hierarchy is absent in Archimedean fields.")
    print()


if __name__ == "__main__":
    demonstrate_archimedean_impossibility()
    demonstrate_infinitesimal_premeasure()
    demonstrate_two_level_measure()
    demonstrate_bayes()
    demonstrate_hierarchy()
    
    print("=" * 60)
    print("SUMMARY OF FORMALIZED RESULTS")
    print("=" * 60)
    print()
    print("All of the above demonstrations correspond to formally")
    print("verified theorems in Lean 4:")
    print()
    print("  1. archimedean_no_infinitesimal: No infinitesimals in Archimedean fields")
    print("  2. surreal_not_archimedean: Surreal numbers ARE non-Archimedean")
    print("  3. measure_finite_additivity: Finite additivity of measures")
    print("  4. bayes_formula: Bayes' theorem in ordered fields")
    print("  5. two_level_measure_exists: Construction of two-level measures")
    print("  6. infinitesimal_squared_smaller: ε² < ε hierarchy")
    print("  7. measure_complement: Complement formula")
    print("  8. measure_union_inter: Inclusion-exclusion")


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Measures

Generates plots comparing standard uniform measures with two-level
infinitesimal-style measures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_uniform_vs_two_level():
    """Compare uniform and two-level measures."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    n = 10
    elements = list(range(n))
    
    # Panel 1: Standard uniform
    ax = axes[0]
    weights = [1/n] * n
    ax.bar(elements, weights, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.set_title('Standard Uniform Measure', fontsize=12, fontweight='bold')
    ax.set_xlabel('Element')
    ax.set_ylabel('Probability')
    ax.set_ylim(0, 1.05)
    ax.axhline(y=1/n, color='red', linestyle='--', alpha=0.5, label=f'w = 1/{n}')
    ax.legend()
    
    # Panel 2: Two-level with small ε
    ax = axes[1]
    eps = 0.02
    bulk = 1 - (n-1) * eps
    weights_2 = [bulk] + [eps] * (n-1)
    colors = ['gold'] + ['steelblue'] * (n-1)
    ax.bar(elements, weights_2, color=colors, alpha=0.8, edgecolor='navy')
    ax.set_title(f'Two-Level Measure (ε={eps})', fontsize=12, fontweight='bold')
    ax.set_xlabel('Element')
    ax.set_ylabel('Probability')
    ax.set_ylim(0, 1.05)
    ax.axhline(y=eps, color='red', linestyle='--', alpha=0.5, label=f'ε = {eps}')
    ax.legend()
    
    # Panel 3: Two-level with very small ε
    ax = axes[2]
    eps = 0.001
    bulk = 1 - (n-1) * eps
    weights_3 = [bulk] + [eps] * (n-1)
    colors = ['gold'] + ['steelblue'] * (n-1)
    ax.bar(elements, weights_3, color=colors, alpha=0.8, edgecolor='navy')
    ax.set_title(f'Two-Level Measure (ε={eps})', fontsize=12, fontweight='bold')
    ax.set_xlabel('Element')
    ax.set_ylabel('Probability')
    ax.set_ylim(0, 1.05)
    ax.axhline(y=eps, color='red', linestyle='--', alpha=0.5, label=f'ε = {eps}')
    ax.legend()
    
    plt.suptitle('From Uniform to Infinitesimal: The Non-Archimedean Transition', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('measure_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: measure_comparison.png")


def plot_defect_scaling():
    """Plot how the defect scales with set size for fixed ε."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    epsilons = [0.1, 0.01, 0.001, 0.0001]
    
    for eps in epsilons:
        ns = list(range(1, int(0.9/eps) + 1))
        defects = [1 - n * eps for n in ns]
        ax.plot(ns, defects, '-o', markersize=3, label=f'ε = {eps}')
    
    ax.set_xlabel('Set Size n', fontsize=12)
    ax.set_ylabel('Defect (1 - n·ε)', fontsize=12)
    ax.set_title('Probability Defect vs Set Size\nIn non-Archimedean fields, defect stays positive for ALL n', 
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('defect_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: defect_scaling.png")


def plot_infinitesimal_hierarchy():
    """Visualize the hierarchy of infinitesimal scales."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    eps_base = 0.1
    depths = range(1, 8)
    values = [eps_base ** k for k in depths]
    
    ax.semilogy(list(depths), values, 'o-', color='darkred', markersize=10, linewidth=2)
    
    for k, v in zip(depths, values):
        ax.annotate(f'ε^{k} = {v:.1e}', 
                    xy=(k, v), xytext=(k + 0.3, v * 1.5),
                    fontsize=10, ha='left')
    
    ax.set_xlabel('Power k', fontsize=12)
    ax.set_ylabel('ε^k (log scale)', fontsize=12)
    ax.set_title('Infinitesimal Hierarchy: ε > ε² > ε³ > ...\n'
                 'Each level is infinitesimally small relative to the previous',
                 fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3, which='both')
    
    plt.tight_layout()
    plt.savefig('hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hierarchy.png")


def plot_archimedean_vs_non():
    """Contrast Archimedean and non-Archimedean behavior."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Archimedean (ℝ)
    ax = axes[0]
    eps_values = np.logspace(-6, -1, 50)
    for eps in eps_values:
        n_exceed = int(np.ceil(1.0 / eps))
        ax.scatter(eps, n_exceed, c='steelblue', s=20, alpha=0.7)
    
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlabel('ε', fontsize=12)
    ax.set_ylabel('Smallest n with n·ε ≥ 1', fontsize=12)
    ax.set_title('Archimedean World (ℝ)\nEvery ε is eventually exceeded', 
                 fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Right: Non-Archimedean (Surreal)
    ax = axes[1]
    # In surreals, for a true infinitesimal ε, n·ε < 1 for ALL n
    ns = np.arange(1, 101)
    eps_surreal = 0.001  # visual stand-in
    
    # Show multiple "infinitesimal" levels
    for level, color in [(1, 'steelblue'), (2, 'darkorange'), (3, 'green')]:
        masses = ns * (eps_surreal ** level)
        ax.plot(ns, masses, '-', color=color, linewidth=2, 
                label=f'n·ε^{level}', alpha=0.8)
    
    ax.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Threshold = 1')
    ax.set_xlabel('n (number of elements)', fontsize=12)
    ax.set_ylabel('Total mass n·ε^k', fontsize=12)
    ax.set_title('Non-Archimedean World (Surreal)\nInfinitesimal mass NEVER reaches 1', 
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('The Archimedean-NonArchimedean Dichotomy', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('dichotomy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dichotomy.png")


if __name__ == "__main__":
    plot_uniform_vs_two_level()
    plot_defect_scaling()
    plot_infinitesimal_hierarchy()
    plot_archimedean_vs_non()
    print("\nAll visualizations generated.")
