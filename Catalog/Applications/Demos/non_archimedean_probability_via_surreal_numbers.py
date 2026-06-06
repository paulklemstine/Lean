#!/usr/bin/env python3
"""
Non-Archimedean Probability via Surreal Numbers — Demonstrations

This script demonstrates the key concepts from the formalized theory:
1. The Archimedean impossibility: why ε > 0 in ℝ can't be infinitesimal
2. The non-Archimedean construction: uniform measures with infinitesimal weights
3. Finite additivity and monotonicity properties
4. The characterization theorem in action
"""

from fractions import Fraction
from typing import FrozenSet, TypeVar

T = TypeVar('T')


def archimedean_witness(epsilon: float, bound: float) -> int:
    """
    Find the smallest n such that n * epsilon > bound.
    This witnesses the Archimedean property: in ℝ, such n always exists.
    
    >>> archimedean_witness(0.01, 1.0)
    101
    >>> archimedean_witness(0.001, 1.0)
    1001
    """
    n = 0
    while n * epsilon <= bound:
        n += 1
    return n


def demonstrate_archimedean_impossibility():
    """
    Show that in ℝ, no positive ε can satisfy n·ε ≤ 1 for all n.
    For each ε, we find the n that breaks the bound.
    """
    print("=" * 60)
    print("ARCHIMEDEAN IMPOSSIBILITY IN ℝ")
    print("=" * 60)
    print("\nFor each ε > 0, we find n such that n·ε > 1:")
    print(f"{'ε':>15} {'n (witness)':>15} {'n·ε':>15}")
    print("-" * 50)
    
    for exp in range(1, 11):
        eps = 10 ** (-exp)
        n = archimedean_witness(eps, 1.0)
        print(f"{eps:>15.1e} {n:>15d} {n * eps:>15.4f}")
    
    print("\nConclusion: No matter how small ε is, some finite n")
    print("makes n·ε exceed 1. Infinitesimal probability is")
    print("IMPOSSIBLE in the real numbers.\n")


class SurrealLike:
    """
    A simplified model of surreal-like numbers for demonstration.
    Represents elements of the form a + b/ω where a, b ∈ ℚ.
    
    The element 1/ω is infinitesimal: positive but smaller than any 1/n.
    """
    
    def __init__(self, standard: Fraction = Fraction(0), 
                 infinitesimal: Fraction = Fraction(0)):
        self.std = standard      # the "standard part"
        self.inf = infinitesimal  # coefficient of 1/ω
    
    def __repr__(self):
        parts = []
        if self.std != 0:
            parts.append(str(self.std))
        if self.inf != 0:
            if self.inf == 1:
                parts.append("1/ω")
            elif self.inf == -1:
                parts.append("-1/ω")
            else:
                parts.append(f"{self.inf}/ω")
        return " + ".join(parts) if parts else "0"
    
    def __add__(self, other):
        return SurrealLike(self.std + other.std, self.inf + other.inf)
    
    def __sub__(self, other):
        return SurrealLike(self.std - other.std, self.inf - other.inf)
    
    def __mul__(self, n: int):
        return SurrealLike(self.std * n, self.inf * n)
    
    def __rmul__(self, n: int):
        return self.__mul__(n)
    
    def __le__(self, other):
        if self.std != other.std:
            return self.std <= other.std
        return self.inf <= other.inf
    
    def __lt__(self, other):
        return self <= other and not (self.std == other.std and self.inf == other.inf)
    
    def __eq__(self, other):
        if isinstance(other, int) and other == 0:
            return self.std == 0 and self.inf == 0
        return self.std == other.std and self.inf == other.inf
    
    def is_positive(self):
        if self.std > 0:
            return True
        if self.std == 0 and self.inf > 0:
            return True
        return False
    
    def is_infinitesimal(self):
        """True if this is positive but smaller than any positive rational."""
        return self.std == 0 and self.inf > 0


# Convenient constructors
ZERO = SurrealLike()
ONE = SurrealLike(Fraction(1))
EPSILON = SurrealLike(infinitesimal=Fraction(1))  # 1/ω


def uniform_measure(epsilon: SurrealLike, n: int) -> SurrealLike:
    """Uniform measure of a set with n elements: μ(S) = n · ε"""
    return n * epsilon


def demonstrate_non_archimedean_measure():
    """
    Show that in the surreal-like numbers, 1/ω is infinitesimal
    and the uniform measure with weight 1/ω works perfectly.
    """
    print("=" * 60)
    print("NON-ARCHIMEDEAN MEASURE WITH SURREAL NUMBERS")
    print("=" * 60)
    
    eps = EPSILON
    print(f"\nWeight ε = {eps}")
    print(f"ε is positive: {eps.is_positive()}")
    print(f"ε is infinitesimal: {eps.is_infinitesimal()}")
    
    print(f"\n{'n (set size)':>15} {'μ(S) = n·ε':>20} {'μ(S) ≤ 1?':>10}")
    print("-" * 50)
    
    for n in [1, 5, 10, 100, 1000, 10**6, 10**9]:
        mu = uniform_measure(eps, n)
        bounded = mu <= ONE
        print(f"{n:>15d} {str(mu):>20s} {'YES' if bounded else 'NO':>10s}")
    
    print("\nConclusion: n · (1/ω) ≤ 1 for ALL finite n.")
    print("Every point has positive probability 1/ω > 0,")
    print("yet no finite collection exceeds total mass 1.\n")


def demonstrate_finite_additivity():
    """
    Verify finite additivity: μ(S ∪ T) = μ(S) + μ(T) for disjoint S, T.
    """
    print("=" * 60)
    print("FINITE ADDITIVITY VERIFICATION")
    print("=" * 60)
    
    eps = EPSILON
    
    test_cases = [
        (3, 5),   # |S| = 3, |T| = 5
        (10, 20), # |S| = 10, |T| = 20
        (1, 1),   # singletons
        (0, 7),   # empty + nonempty
        (100, 200),
    ]
    
    print(f"\n{'|S|':>5} {'|T|':>5} {'μ(S∪T)':>15} {'μ(S)+μ(T)':>15} {'Equal?':>8}")
    print("-" * 55)
    
    for s_size, t_size in test_cases:
        mu_union = uniform_measure(eps, s_size + t_size)
        mu_s = uniform_measure(eps, s_size)
        mu_t = uniform_measure(eps, t_size)
        mu_sum = mu_s + mu_t
        equal = mu_union == mu_sum
        print(f"{s_size:>5d} {t_size:>5d} {str(mu_union):>15s} {str(mu_sum):>15s} {'✓' if equal else '✗':>8s}")
    
    print("\nFinite additivity holds perfectly.\n")


def demonstrate_monotonicity():
    """
    Verify monotonicity: S ⊆ T implies μ(S) ≤ μ(T).
    """
    print("=" * 60)
    print("MONOTONICITY VERIFICATION")
    print("=" * 60)
    
    eps = EPSILON
    
    print(f"\n{'|S|':>5} {'|T|':>5} {'μ(S)':>15} {'μ(T)':>15} {'μ(S) ≤ μ(T)?':>15}")
    print("-" * 60)
    
    for s_size, t_size in [(1, 5), (3, 3), (0, 10), (7, 100), (50, 51)]:
        mu_s = uniform_measure(eps, s_size)
        mu_t = uniform_measure(eps, t_size)
        mono = mu_s <= mu_t
        print(f"{s_size:>5d} {t_size:>5d} {str(mu_s):>15s} {str(mu_t):>15s} {'✓' if mono else '✗':>15s}")
    
    print()


def demonstrate_complementary_bound():
    """
    Show that b - μ(S) ≥ 0 for all finite S when ε is infinitesimal w.r.t. b.
    """
    print("=" * 60)
    print("COMPLEMENTARY BOUND: NO FINITE SET EXHAUSTS THE MASS")
    print("=" * 60)
    
    eps = EPSILON
    b = ONE
    
    print(f"\nTotal mass b = {b}")
    print(f"Weight ε = {eps}")
    
    print(f"\n{'|S|':>12} {'μ(S)':>15} {'b - μ(S)':>20} {'≥ 0?':>6}")
    print("-" * 58)
    
    for n in [1, 10, 100, 1000, 10**6]:
        mu = uniform_measure(eps, n)
        remaining = b - mu
        nonneg = SurrealLike() <= remaining
        print(f"{n:>12d} {str(mu):>15s} {str(remaining):>20s} {'✓' if nonneg else '✗':>6s}")
    
    print(f"\nRemaining mass is always 1 - n/ω, which is positive")
    print(f"for all finite n. The total mass is never exhausted.\n")


def demonstrate_characterization():
    """
    Demonstrate the characterization theorem:
    ∃ infinitesimal ↔ not Archimedean.
    """
    print("=" * 60)
    print("CHARACTERIZATION: INFINITESIMAL ↔ NON-ARCHIMEDEAN")
    print("=" * 60)
    
    print("""
    Structure        | Archimedean? | Has infinitesimal? | Infinitesimal prob?
    -----------------+--------------+--------------------+--------------------
    ℝ (reals)        | YES          | NO                 | IMPOSSIBLE
    ℚ (rationals)    | YES          | NO                 | IMPOSSIBLE  
    ℤ (integers)     | YES          | NO                 | IMPOSSIBLE
    Surreals (No)    | NO           | YES (1/ω)          | POSSIBLE
    Hyperreals (*ℝ)  | NO           | YES (ε)            | POSSIBLE
    Laurent series   | NO           | YES (t)            | POSSIBLE

    The characterization theorem proves these are not coincidences:
    the Archimedean property is EXACTLY the obstruction to
    infinitesimal probability.
    """)


if __name__ == "__main__":
    demonstrate_archimedean_impossibility()
    demonstrate_non_archimedean_measure()
    demonstrate_finite_additivity()
    demonstrate_monotonicity()
    demonstrate_complementary_bound()
    demonstrate_characterization()
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
    Key Results (all formally verified in Lean 4):
    
    1. IMPOSSIBILITY (Archimedean Obstruction Theorem):
       In ℝ, ℚ, or any Archimedean structure, no positive element
       can be infinitesimal. Uniform positive probability on
       individual points is impossible.
    
    2. POSSIBILITY (Non-Archimedean Construction):
       In surreal numbers or any non-Archimedean structure,
       infinitesimals exist, enabling uniform positive probability
       on every point while keeping all finite unions bounded.
    
    3. CHARACTERIZATION:
       (∃ infinitesimal) ↔ (not Archimedean)
       This is a complete equivalence, not just one direction.
    
    4. BRIDGE:
       This connects order theory, measure theory, and
       nonstandard analysis through a single algebraic property.
    """)


#!/usr/bin/env python3
"""
Visualization: Archimedean vs Non-Archimedean Probability

Shows how n·ε grows with n in Archimedean (real) and 
non-Archimedean (surreal-like) settings.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_archimedean_vs_non_archimedean():
    """
    Plot the growth of n·ε in Archimedean vs non-Archimedean settings.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left plot: Archimedean (ℝ)
    ax1 = axes[0]
    ns = np.arange(0, 150)
    
    for eps_val, label, color in [
        (0.01, "ε = 0.01", "#e74c3c"),
        (0.005, "ε = 0.005", "#3498db"),
        (0.002, "ε = 0.002", "#2ecc71"),
    ]:
        values = ns * eps_val
        ax1.plot(ns, values, label=label, color=color, linewidth=2)
    
    ax1.axhline(y=1, color='black', linestyle='--', linewidth=2, label='bound = 1')
    ax1.fill_between(ns, 1, 1.5, alpha=0.15, color='red')
    ax1.set_xlabel('n (number of points)', fontsize=12)
    ax1.set_ylabel('n · ε (total measure)', fontsize=12)
    ax1.set_title('Archimedean (ℝ): Every ε > 0\neventually exceeds bound', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 1.5)
    ax1.set_xlim(0, 150)
    ax1.text(120, 1.2, 'FORBIDDEN\nZONE', ha='center', fontsize=11, 
             color='red', fontweight='bold')
    ax1.grid(True, alpha=0.3)
    
    # Right plot: Non-Archimedean (surreal-like)
    ax2 = axes[1]
    
    # In the surreal setting, n/ω is always infinitesimal
    # We represent this by showing the "standard part" staying at 0
    # and a zoomed inset showing the infinitesimal growth
    
    ns_large = np.arange(0, 10001)
    # Standard part is always 0
    standard_parts = np.zeros_like(ns_large, dtype=float)
    
    ax2.plot(ns_large, standard_parts, color='#2ecc71', linewidth=3, 
             label='st(n/ω) = 0 for all finite n')
    ax2.axhline(y=1, color='black', linestyle='--', linewidth=2, label='bound = 1')
    ax2.set_xlabel('n (number of points)', fontsize=12)
    ax2.set_ylabel('standard part of n · ε', fontsize=12)
    ax2.set_title('Non-Archimedean (Surreal): n/ω\nnever reaches any positive real', fontsize=13)
    ax2.legend(fontsize=10, loc='upper left')
    ax2.set_ylim(-0.1, 1.5)
    ax2.set_xlim(0, 10000)
    ax2.grid(True, alpha=0.3)
    
    # Add annotation
    ax2.annotate('n/ω is infinitesimal\nfor ALL finite n', 
                xy=(5000, 0), xytext=(5000, 0.5),
                arrowprops=dict(arrowstyle='->', color='#2ecc71', lw=2),
                fontsize=11, ha='center', color='#2ecc71', fontweight='bold')
    
    # Add safe zone
    ax2.fill_between(ns_large, 0, 1, alpha=0.05, color='green')
    ax2.text(8000, 0.7, 'ALWAYS\nSAFE', ha='center', fontsize=11,
             color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Novelty/SurrealProbability/archimedean_comparison.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved archimedean_comparison.png")


def plot_measure_properties():
    """
    Plot the key measure properties: additivity, monotonicity, boundedness.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Finite additivity
    ax1 = axes[0]
    n_vals = range(1, 11)
    mu_vals = list(n_vals)  # μ(S) = n (in units of ε)
    
    # Show μ(S ∪ T) = μ(S) + μ(T)
    s_sizes = [2, 3, 5, 1, 4, 6, 7, 2, 8, 3]
    t_sizes = [3, 2, 1, 4, 3, 2, 1, 5, 1, 4]
    union_sizes = [s + t for s, t in zip(s_sizes, t_sizes)]
    
    x = range(len(s_sizes))
    width = 0.25
    
    ax1.bar([i - width for i in x], s_sizes, width, label='μ(S)/ε', color='#3498db', alpha=0.8)
    ax1.bar(list(x), t_sizes, width, label='μ(T)/ε', color='#e74c3c', alpha=0.8)
    ax1.bar([i + width for i in x], union_sizes, width, label='μ(S∪T)/ε', color='#2ecc71', alpha=0.8)
    
    ax1.set_xlabel('Trial', fontsize=11)
    ax1.set_ylabel('Measure (in units of ε)', fontsize=11)
    ax1.set_title('Finite Additivity\nμ(S∪T) = μ(S) + μ(T)', fontsize=12)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3, axis='y')
    
    # Plot 2: Monotonicity
    ax2 = axes[1]
    ns = np.arange(0, 51)
    
    ax2.fill_between(ns, ns, 50, alpha=0.1, color='blue')
    ax2.plot(ns, ns, color='#3498db', linewidth=3, label='μ(S) = |S|·ε')
    
    # Highlight subset relationships
    for s, t in [(10, 30), (5, 15), (20, 40)]:
        ax2.annotate('', xy=(t, t), xytext=(s, s),
                    arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2))
        ax2.plot([s], [s], 'o', color='#e74c3c', markersize=8)
        ax2.plot([t], [t], 's', color='#2ecc71', markersize=8)
    
    ax2.set_xlabel('|S| (set cardinality)', fontsize=11)
    ax2.set_ylabel('μ(S) (in units of ε)', fontsize=11)
    ax2.set_title('Monotonicity\nS ⊆ T → μ(S) ≤ μ(T)', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Boundedness (complementary bound)
    ax3 = axes[2]
    ns = np.arange(0, 101)
    # In units of ε, remaining = b/ε - n (where b = 1, ε = 1/ω, b/ε = ω)
    # But in standard part, it's always 1
    remaining_standard = np.ones_like(ns, dtype=float)
    
    ax3.fill_between(ns, 0, remaining_standard, alpha=0.15, color='green')
    ax3.plot(ns, remaining_standard, color='#2ecc71', linewidth=3, 
             label='st(1 - n/ω) = 1')
    ax3.axhline(y=0, color='gray', linestyle='-', linewidth=1)
    
    ax3.set_xlabel('|S| (points measured)', fontsize=11)
    ax3.set_ylabel('Remaining mass (standard part)', fontsize=11)
    ax3.set_title('Complementary Bound\n1 - μ(S) ≥ 0 always', fontsize=12)
    ax3.legend(fontsize=10)
    ax3.set_ylim(-0.1, 1.5)
    ax3.grid(True, alpha=0.3)
    ax3.text(50, 0.5, 'Mass never\nexhausted', ha='center', fontsize=12,
             color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Novelty/SurrealProbability/measure_properties.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved measure_properties.png")


if __name__ == "__main__":
    plot_archimedean_vs_non_archimedean()
    plot_measure_properties()
