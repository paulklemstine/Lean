#!/usr/bin/env python3
"""
Demo: Non-Archimedean Probability via Surreal-Valued Measures

Numerical examples illustrating the key theorems from the formalized theory.
"""

from fractions import Fraction
from typing import List, Dict, Set, FrozenSet


def weighted_measure(weights: Dict[str, Fraction], S: FrozenSet[str]) -> Fraction:
    """Compute the measure of set S under the given weights."""
    return sum(weights[x] for x in S if x in weights)


def demo_finite_additivity():
    """Demonstrate finite additivity: μ(A ∪ B) = μ(A) + μ(B) for disjoint A, B."""
    print("=" * 60)
    print("DEMO 1: Finite Additivity")
    print("=" * 60)
    
    # Uniform probability on {a, b, c, d}
    elements = ['a', 'b', 'c', 'd']
    weights = {x: Fraction(1, 4) for x in elements}
    
    A = frozenset(['a', 'b'])
    B = frozenset(['c', 'd'])
    
    mu_A = weighted_measure(weights, A)
    mu_B = weighted_measure(weights, B)
    mu_AB = weighted_measure(weights, A | B)
    
    print(f"Weights: {dict(weights)}")
    print(f"A = {set(A)}, B = {set(B)}")
    print(f"μ(A) = {mu_A} = {float(mu_A):.4f}")
    print(f"μ(B) = {mu_B} = {float(mu_B):.4f}")
    print(f"μ(A ∪ B) = {mu_AB} = {float(mu_AB):.4f}")
    print(f"μ(A) + μ(B) = {mu_A + mu_B} = {float(mu_A + mu_B):.4f}")
    print(f"Finite additivity holds: {mu_AB == mu_A + mu_B}")
    print()


def demo_no_free_lunch():
    """Demonstrate the No Free Lunch theorem with simulated infinitesimals."""
    print("=" * 60)
    print("DEMO 2: No Free Lunch Theorem")
    print("=" * 60)
    
    # Simulate infinitesimal ε as a very small fraction
    # In surreal numbers, ε would be genuinely infinitesimal
    for k in [10, 100, 1000, 10000]:
        eps = Fraction(1, k)
        n_points = 5
        weights = {str(i): eps for i in range(n_points)}
        total = weighted_measure(weights, frozenset(weights.keys()))
        
        print(f"ε = 1/{k}, n = {n_points}")
        print(f"  Each weight = {eps}")
        print(f"  Total = {n_points} × ε = {total} = {float(total):.6f}")
        print(f"  Total > 0: {total > 0}  (No Free Lunch!)")
    
    print("\nKey insight: No matter how small ε is (even infinitesimal),")
    print("n × ε > 0 always holds. This is anti-cancellation in action.")
    print()


def demo_archimedean_exclusion():
    """Show that ℚ and ℝ have no infinitesimals (Archimedean Exclusion)."""
    print("=" * 60)
    print("DEMO 3: Archimedean Exclusion Theorem")
    print("=" * 60)
    
    # For any ε > 0 in ℚ, find n such that n·ε ≥ 1
    test_epsilons = [Fraction(1, 3), Fraction(1, 100), Fraction(1, 10**6)]
    
    for eps in test_epsilons:
        # Find smallest n with n·ε ≥ 1
        n = 1
        while n * eps < 1:
            n += 1
        print(f"ε = {eps}")
        print(f"  Smallest n with n·ε ≥ 1: n = {n}")
        print(f"  n·ε = {n * eps} ≥ 1 ✓")
        print(f"  → ε is NOT infinitesimal in ℚ (Archimedean property)")
    
    print("\nConclusion: No rational (or real) number is infinitesimal.")
    print("Infinitesimal probability requires non-Archimedean fields")
    print("like Conway's surreal numbers.")
    print()


def demo_uniform_measure():
    """Demonstrate the Uniform Measure Theorem."""
    print("=" * 60)
    print("DEMO 4: Uniform Measure Theorem")
    print("=" * 60)
    
    for n in [3, 5, 7, 12]:
        elements = [str(i) for i in range(n)]
        weight = Fraction(1, n)
        weights = {x: weight for x in elements}
        total = weighted_measure(weights, frozenset(elements))
        
        print(f"n = {n}: weight = 1/{n}, total = {n} × (1/{n}) = {total}")
        assert total == 1, f"Expected 1, got {total}"
    
    print("\nAll totals equal 1 — uniform probability works in any field!")
    print()


def demo_complement():
    """Demonstrate the complement formula: P(Aᶜ) = 1 - P(A)."""
    print("=" * 60)
    print("DEMO 5: Complement Formula")
    print("=" * 60)
    
    elements = ['a', 'b', 'c', 'd', 'e']
    weights = {x: Fraction(1, 5) for x in elements}
    universe = frozenset(elements)
    
    A = frozenset(['a', 'c'])
    A_complement = universe - A
    
    mu_A = weighted_measure(weights, A)
    mu_Ac = weighted_measure(weights, A_complement)
    
    print(f"Universe = {set(universe)}")
    print(f"A = {set(A)}")
    print(f"Aᶜ = {set(A_complement)}")
    print(f"P(A) = {mu_A}")
    print(f"P(Aᶜ) = {mu_Ac}")
    print(f"1 - P(A) = {1 - mu_A}")
    print(f"P(Aᶜ) = 1 - P(A): {mu_Ac == 1 - mu_A}")
    print()


def demo_partition_of_unity():
    """Demonstrate partition of unity over fibers."""
    print("=" * 60)
    print("DEMO 6: Partition of Unity")
    print("=" * 60)
    
    # Elements with non-uniform weights
    weights = {
        'a': Fraction(1, 6), 'b': Fraction(1, 6),
        'c': Fraction(1, 3), 'd': Fraction(1, 3)
    }
    
    # Partition by a function f
    def f(x):
        return "vowel" if x in ('a') else "consonant"
    
    # Actually let's use even/odd index
    elements = list(weights.keys())
    
    def parity(x):
        return "group1" if x in ('a', 'b') else "group2"
    
    fibers = {}
    for x in elements:
        key = parity(x)
        if key not in fibers:
            fibers[key] = set()
        fibers[key].add(x)
    
    total = sum(weights.values())
    fiber_sum = Fraction(0)
    
    print(f"Weights: {weights}")
    print(f"Total: {total}")
    print(f"Partition by parity:")
    
    for key, fiber in fibers.items():
        mu_fiber = weighted_measure(weights, frozenset(fiber))
        print(f"  {key} = {fiber}: μ = {mu_fiber}")
        fiber_sum += mu_fiber
    
    print(f"Sum of fiber measures: {fiber_sum}")
    print(f"Equals total: {fiber_sum == total}")
    print()


def demo_three_set_additivity():
    """Demonstrate three-set additivity for pairwise disjoint sets."""
    print("=" * 60)
    print("DEMO 7: Three-Set Additivity")
    print("=" * 60)
    
    elements = [str(i) for i in range(9)]
    weights = {x: Fraction(1, 9) for x in elements}
    
    A = frozenset(['0', '1', '2'])
    B = frozenset(['3', '4', '5'])
    C = frozenset(['6', '7', '8'])
    
    mu_A = weighted_measure(weights, A)
    mu_B = weighted_measure(weights, B)
    mu_C = weighted_measure(weights, C)
    mu_ABC = weighted_measure(weights, A | B | C)
    
    print(f"A = {set(A)}, B = {set(B)}, C = {set(C)}")
    print(f"μ(A) = {mu_A}, μ(B) = {mu_B}, μ(C) = {mu_C}")
    print(f"μ(A ∪ B ∪ C) = {mu_ABC}")
    print(f"μ(A) + μ(B) + μ(C) = {mu_A + mu_B + mu_C}")
    print(f"Three-set additivity holds: {mu_ABC == mu_A + mu_B + mu_C}")
    print()


if __name__ == '__main__':
    print("Non-Archimedean Probability: Numerical Demonstrations")
    print("=" * 60)
    print()
    
    demo_finite_additivity()
    demo_no_free_lunch()
    demo_archimedean_exclusion()
    demo_uniform_measure()
    demo_complement()
    demo_partition_of_unity()
    demo_three_set_additivity()
    
    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Measures

Standalone script using matplotlib to visualize key concepts.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction


def plot_archimedean_exclusion():
    """Visualize why Archimedean fields exclude infinitesimals."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Archimedean property in ℝ
    epsilons = [0.5, 0.2, 0.1, 0.05, 0.01]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(epsilons)))
    
    for eps, color in zip(epsilons, colors):
        n_needed = int(np.ceil(1.0 / eps))
        ns = np.arange(0, n_needed + 2)
        values = ns * eps
        ax1.plot(ns, values, 'o-', color=color, markersize=3,
                label=f'ε = {eps}, n* = {n_needed}')
        ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5)
        ax1.plot(n_needed, n_needed * eps, 's', color=color, markersize=10)
    
    ax1.set_xlabel('n (multiples of ε)')
    ax1.set_ylabel('n · ε')
    ax1.set_title('Archimedean Property: n·ε always reaches 1')
    ax1.legend(fontsize=8)
    ax1.set_ylim(-0.1, 2.0)
    ax1.grid(True, alpha=0.3)
    
    # Right: Non-Archimedean (conceptual)
    ns = np.arange(0, 50)
    # Standard ε
    ax2.fill_between(ns, 0, np.ones_like(ns), alpha=0.1, color='red',
                     label='Standard: reaches 1')
    ax2.plot(ns, ns * 0.05, 'b-', linewidth=2, label='ε = 0.05 (standard)')
    
    # "Infinitesimal" (never reaches 1) - conceptual
    inf_values = 1 - 1.0 / (ns + 1)  # Approaches but never reaches 1
    ax2.plot(ns, inf_values * 0.3, 'g-', linewidth=2,
            label='ε = infinitesimal (non-Archimedean)')
    ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='y = 1 barrier')
    
    ax2.set_xlabel('n')
    ax2.set_ylabel('n · ε')
    ax2.set_title('Non-Archimedean: n·ε never reaches 1')
    ax2.legend(fontsize=8)
    ax2.set_ylim(-0.1, 2.0)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('archimedean_exclusion.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: archimedean_exclusion.png")


def plot_no_free_lunch():
    """Visualize the No Free Lunch theorem."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Three scenarios with decreasing weights
    scenarios = [
        ("Standard weights", [0.3, 0.25, 0.2, 0.15, 0.1]),
        ("Small weights", [0.02, 0.02, 0.02, 0.02, 0.02]),
        ("Tiny weights (→ infinitesimal)", [0.001, 0.001, 0.001, 0.001, 0.001]),
    ]
    
    for ax, (title, weights) in zip(axes, scenarios):
        n = len(weights)
        x = np.arange(n)
        total = sum(weights)
        
        bars = ax.bar(x, weights, color='steelblue', alpha=0.7, edgecolor='navy')
        ax.axhline(y=0, color='black', linewidth=0.5)
        
        # Show total
        ax.bar(n + 0.5, total, color='gold', alpha=0.7, edgecolor='darkgoldenrod',
              width=0.8)
        ax.text(n + 0.5, total + max(weights) * 0.05, f'Σ = {total:.4f}',
               ha='center', fontsize=9, fontweight='bold')
        
        ax.set_title(title, fontsize=11)
        ax.set_xticks(list(range(n)) + [n + 0.5])
        ax.set_xticklabels([f'w{i+1}' for i in range(n)] + ['Total'])
        ax.set_ylabel('Weight')
        
        # Highlight: total > 0
        if total > 0:
            ax.annotate('> 0 ✓', xy=(n + 0.5, total / 2),
                       fontsize=14, color='green', fontweight='bold',
                       ha='center')
    
    fig.suptitle('No Free Lunch: Positive Weights → Positive Total\n'
                '(Even infinitesimal weights sum to a positive total)',
                fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('no_free_lunch.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: no_free_lunch.png")


def plot_bridge_diagram():
    """Visualize the bridge between Lorentzian polynomials and probability."""
    fig, ax = plt.subplots(figsize=(12, 7))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Lorentzian Polynomials box
    lp_box = mpatches.FancyBboxPatch((0.5, 5.5), 3.5, 2, boxstyle="round,pad=0.2",
                                      facecolor='#E8F4FD', edgecolor='#2196F3', linewidth=2)
    ax.add_patch(lp_box)
    ax.text(2.25, 7.0, 'Lorentzian\nPolynomials', ha='center', va='center',
           fontsize=12, fontweight='bold', color='#1565C0')
    ax.text(2.25, 5.9, 'Anti-cancellation\nSupport exactness', ha='center', va='center',
           fontsize=9, color='#424242')
    
    # Probability Theory box
    pt_box = mpatches.FancyBboxPatch((6, 5.5), 3.5, 2, boxstyle="round,pad=0.2",
                                      facecolor='#FFF3E0', edgecolor='#FF9800', linewidth=2)
    ax.add_patch(pt_box)
    ax.text(7.75, 7.0, 'Probability\nTheory', ha='center', va='center',
           fontsize=12, fontweight='bold', color='#E65100')
    ax.text(7.75, 5.9, 'Measure positivity\nNo Free Lunch', ha='center', va='center',
           fontsize=9, color='#424242')
    
    # Bridge arrow
    ax.annotate('', xy=(6, 6.5), xytext=(4, 6.5),
               arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=3))
    ax.text(5, 6.9, 'BRIDGE', ha='center', va='center',
           fontsize=11, fontweight='bold', color='#2E7D32')
    ax.text(5, 6.2, 'Same algebraic\nfoundation', ha='center', va='center',
           fontsize=9, color='#388E3C', style='italic')
    
    # Ordered Algebra foundation
    oa_box = mpatches.FancyBboxPatch((2.5, 2.5), 5, 1.8, boxstyle="round,pad=0.2",
                                      facecolor='#E8F5E9', edgecolor='#4CAF50', linewidth=2)
    ax.add_patch(oa_box)
    ax.text(5, 3.8, 'Ordered Algebra', ha='center', va='center',
           fontsize=12, fontweight='bold', color='#1B5E20')
    ax.text(5, 3.0, 'Linearly ordered cancellative add comm monoid\n'
           '∀ f ≥ 0, ∃ k: f(k) > 0 → Σ f > 0', ha='center', va='center',
           fontsize=9, color='#424242', family='monospace')
    
    # Arrows from foundation
    ax.annotate('', xy=(2.25, 5.5), xytext=(3.5, 4.3),
               arrowprops=dict(arrowstyle='->', color='#666', lw=1.5))
    ax.annotate('', xy=(7.75, 5.5), xytext=(6.5, 4.3),
               arrowprops=dict(arrowstyle='->', color='#666', lw=1.5))
    
    # Non-Archimedean extension
    na_box = mpatches.FancyBboxPatch((2.5, 0.3), 5, 1.5, boxstyle="round,pad=0.2",
                                      facecolor='#F3E5F5', edgecolor='#9C27B0', linewidth=2)
    ax.add_patch(na_box)
    ax.text(5, 1.35, 'Non-Archimedean Fields', ha='center', va='center',
           fontsize=12, fontweight='bold', color='#4A148C')
    ax.text(5, 0.7, 'Surreal numbers · Hyperreals · Levi-Civita field\n'
           'Infinitesimal ε: 0 < ε < 1/n for all n',
           ha='center', va='center', fontsize=9, color='#424242')
    
    ax.annotate('', xy=(5, 2.5), xytext=(5, 1.8),
               arrowprops=dict(arrowstyle='->', color='#9C27B0', lw=1.5))
    
    ax.set_title('Bridge: Lorentzian Polynomials ↔ Non-Archimedean Probability',
                fontsize=14, fontweight='bold', pad=20)
    
    plt.savefig('bridge_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: bridge_diagram.png")


if __name__ == '__main__':
    plot_archimedean_exclusion()
    plot_no_free_lunch()
    plot_bridge_diagram()
    print("\nAll visualizations generated!")
