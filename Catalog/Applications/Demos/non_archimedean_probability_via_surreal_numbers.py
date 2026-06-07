#!/usr/bin/env python3
"""
Non-Archimedean Probability: Numerical Demonstrations

Demonstrates key properties of infinitesimal probability measures using
a concrete model: formal Laurent series in an infinitesimal ε.
"""

from fractions import Fraction
from typing import FrozenSet, Set


class InfinitesimalNumber:
    """Represents a number of the form a + b*ε where ε is infinitesimal.
    
    This is the simplest non-Archimedean ordered field extending Q:
    the field Q(ε) with ε positive and smaller than all positive rationals.
    """
    
    def __init__(self, real_part: Fraction = Fraction(0), 
                 infinitesimal_part: Fraction = Fraction(0)):
        self.real = real_part
        self.inf = infinitesimal_part
    
    def __add__(self, other):
        return InfinitesimalNumber(self.real + other.real, self.inf + other.inf)
    
    def __sub__(self, other):
        return InfinitesimalNumber(self.real - other.real, self.inf - other.inf)
    
    def __mul__(self, other):
        # (a + bε)(c + dε) = ac + (ad + bc)ε + bdε² ≈ ac + (ad+bc)ε
        # We truncate at order ε (ignoring ε² terms, which are "more infinitesimal")
        return InfinitesimalNumber(
            self.real * other.real,
            self.real * other.inf + self.inf * other.real
        )
    
    def __truediv__(self, other):
        if other.real != 0:
            # (a + bε) / (c + dε) = (a/c) + (b/c - ad/c²)ε
            r = self.real / other.real
            i = (self.inf * other.real - self.real * other.inf) / (other.real ** 2)
            return InfinitesimalNumber(r, i)
        elif other.inf != 0:
            # Division by pure infinitesimal: (a + bε) / (dε) = a/d * ε⁻¹ + b/d
            # This goes to infinity; return the leading term
            return InfinitesimalNumber(self.inf / other.inf, Fraction(0))
        else:
            raise ZeroDivisionError("Division by zero")
    
    def __gt__(self, other):
        if self.real != other.real:
            return self.real > other.real
        return self.inf > other.inf
    
    def __eq__(self, other):
        if isinstance(other, InfinitesimalNumber):
            return self.real == other.real and self.inf == other.inf
        return NotImplemented
    
    def __repr__(self):
        if self.inf == 0:
            return f"{self.real}"
        elif self.real == 0:
            return f"{self.inf}ε"
        else:
            sign = "+" if self.inf > 0 else "-"
            return f"{self.real} {sign} {abs(self.inf)}ε"
    
    def is_infinitesimal(self) -> bool:
        """True if this number is positive but smaller than all positive rationals."""
        return self.real == 0 and self.inf > 0
    
    def standard_part(self) -> Fraction:
        """The real part, discarding infinitesimal terms."""
        return self.real


# Convenience constructors
ZERO = InfinitesimalNumber(Fraction(0), Fraction(0))
ONE = InfinitesimalNumber(Fraction(1), Fraction(0))
EPSILON = InfinitesimalNumber(Fraction(0), Fraction(1))


def infinitesimal_measure(epsilon: InfinitesimalNumber, 
                          subset: FrozenSet[int],
                          universe: FrozenSet[int] = None) -> InfinitesimalNumber:
    """Compute μ_ε(A) = |A| · ε"""
    n = len(subset)
    result = ZERO
    for _ in range(n):
        result = result + epsilon
    return result


def conditional_prob(epsilon: InfinitesimalNumber,
                     a: FrozenSet[int], b: FrozenSet[int]) -> InfinitesimalNumber:
    """Compute P(A|B) = μ_ε(A ∩ B) / μ_ε(B)"""
    intersection = a & b
    return infinitesimal_measure(epsilon, intersection) / infinitesimal_measure(epsilon, b)


def demo_impossibility():
    """Demo 1: No real uniform probability on infinite sets."""
    print("=" * 60)
    print("DEMO 1: Impossibility of Real Uniform Probability")
    print("=" * 60)
    print()
    print("Attempting to assign probability ε to each natural number...")
    print("For any ε > 0, we need n·ε ≤ 1 for all n.")
    print()
    
    for eps in [Fraction(1, 10), Fraction(1, 100), Fraction(1, 1000000)]:
        n_break = int(1 / eps) + 1
        print(f"  ε = {eps}: fails at n = {n_break}, since {n_break}·{eps} = {n_break * eps} > 1")
    
    print()
    print("CONCLUSION: No positive real ε works. The Archimedean property")
    print("of ℝ prevents uniform probability on infinite sets.")
    print()


def demo_finite_additivity():
    """Demo 2: Finite additivity of infinitesimal measures."""
    print("=" * 60)
    print("DEMO 2: Finite Additivity of Infinitesimal Measures")
    print("=" * 60)
    print()
    
    A = frozenset({1, 2, 3})
    B = frozenset({4, 5})
    AuB = A | B
    
    eps = EPSILON
    mu_A = infinitesimal_measure(eps, A)
    mu_B = infinitesimal_measure(eps, B)
    mu_AuB = infinitesimal_measure(eps, AuB)
    mu_sum = mu_A + mu_B
    
    print(f"  A = {set(A)}, B = {set(B)}")
    print(f"  A ∪ B = {set(AuB)}")
    print(f"  μ(A) = {mu_A}")
    print(f"  μ(B) = {mu_B}")
    print(f"  μ(A) + μ(B) = {mu_sum}")
    print(f"  μ(A ∪ B) = {mu_AuB}")
    print(f"  μ(A ∪ B) = μ(A) + μ(B)? {mu_AuB == mu_sum}")
    print()


def demo_normalization():
    """Demo 3: Normalization to probability 1."""
    print("=" * 60)
    print("DEMO 3: Normalization — Total Mass = 1")
    print("=" * 60)
    print()
    
    for n in [3, 5, 10, 100]:
        universe = frozenset(range(n))
        eps = InfinitesimalNumber(Fraction(1, n), Fraction(0))
        total = infinitesimal_measure(eps, universe)
        print(f"  n = {n}: ε = 1/{n}, μ(Ω) = {total}")
    
    print()
    print("  With ε = 1/n, every n-element space has total mass exactly 1.")
    print()


def demo_conditional_probability():
    """Demo 4: Conditional probability reduces to counting."""
    print("=" * 60)
    print("DEMO 4: Conditional Probability = Counting Formula")
    print("=" * 60)
    print()
    
    universe = frozenset({1, 2, 3, 4, 5, 6})  # Die roll
    A = frozenset({2, 4, 6})  # Even
    B = frozenset({1, 2, 3, 4})  # ≤ 4
    
    eps = EPSILON
    p_cond = conditional_prob(eps, A, B)
    
    intersection = A & B
    classical = Fraction(len(intersection), len(B))
    
    print(f"  Ω = {set(universe)} (fair die)")
    print(f"  A = {set(A)} (even)")
    print(f"  B = {set(B)} (≤ 4)")
    print(f"  A ∩ B = {set(intersection)}")
    print(f"  P(A|B) via infinitesimals = {p_cond}")
    print(f"  P(A|B) via counting = |A∩B|/|B| = {len(intersection)}/{len(B)} = {classical}")
    print(f"  Match? {p_cond.standard_part() == classical}")
    print()
    
    # Conditioning on a singleton — impossible in standard theory!
    C = frozenset({3})
    p_singleton = conditional_prob(eps, A, C)
    print(f"  Conditioning on singleton: P(even | {{3}}) = {p_singleton}")
    print(f"  (In standard probability, this requires measure-theoretic machinery)")
    print()


def demo_dichotomy():
    """Demo 5: Archimedean vs Non-Archimedean."""
    print("=" * 60)
    print("DEMO 5: The Infinitesimal Dichotomy")
    print("=" * 60)
    print()
    
    print("  Q (rationals): Archimedean — no infinitesimals")
    print("    For any q > 0, there exists n with 1/n ≤ q:")
    for q in [Fraction(1, 100), Fraction(1, 10**6), Fraction(1, 10**12)]:
        n = int(1 / q)
        print(f"      q = {q}, n = {n}, 1/{n} = {Fraction(1, n)} ≤ {q}? {Fraction(1, n) <= q}")
    
    print()
    print("  Q(ε) (rationals with infinitesimal): Non-Archimedean")
    print(f"    ε = {EPSILON}")
    print(f"    ε > 0? {EPSILON > ZERO}")
    print(f"    ε is infinitesimal? {EPSILON.is_infinitesimal()}")
    print(f"    For any n, n·ε = {InfinitesimalNumber(Fraction(0), Fraction(1000000))} < 1")
    print()


def demo_anti_cancellation():
    """Demo 6: Anti-cancellation principle."""
    print("=" * 60)
    print("DEMO 6: Anti-Cancellation — Positive Sums Stay Positive")
    print("=" * 60)
    print()
    
    weights = [EPSILON, EPSILON, EPSILON, EPSILON, EPSILON]
    total = ZERO
    for w in weights:
        total = total + w
    
    print(f"  Weights: [{', '.join(str(w) for w in weights)}]")
    print(f"  Sum = {total}")
    print(f"  Sum > 0? {total > ZERO}")
    print()
    print("  Even though each weight is infinitesimal, their sum is positive.")
    print("  This is the algebraic engine behind infinitesimal probability.")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  NON-ARCHIMEDEAN PROBABILITY: NUMERICAL DEMONSTRATIONS  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_impossibility()
    demo_finite_additivity()
    demo_normalization()
    demo_conditional_probability()
    demo_dichotomy()
    demo_anti_cancellation()
    
    print("=" * 60)
    print("All demonstrations complete.")
    print("Key insight: Infinitesimal probability resolves the tension")
    print("between equal weights and finite total mass by moving to")
    print("non-Archimedean ordered fields.")


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean vs Standard Probability

Compares standard real-valued probability (where point masses = 0)
with infinitesimal probability (where point masses = ε > 0).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def plot_archimedean_barrier():
    """Plot showing how n·ε exceeds 1 for any real ε > 0."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: n*ε vs n for various ε
    ax1 = axes[0]
    ns = np.arange(1, 50)
    for eps in [0.1, 0.05, 0.02, 0.01]:
        values = ns * eps
        ax1.plot(ns, values, label=f'ε = {eps}', linewidth=2)
    ax1.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Total mass = 1')
    ax1.set_xlabel('Number of points n', fontsize=12)
    ax1.set_ylabel('n · ε', fontsize=12)
    ax1.set_title('Archimedean Barrier: n·ε always exceeds 1', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 2.5)
    ax1.grid(True, alpha=0.3)
    
    # Right: Infinitesimal measure stays bounded
    ax2 = axes[1]
    ns = np.arange(1, 100)
    # Simulate infinitesimal: use 1/N for large N
    for N in [100, 1000, 10000]:
        eps = 1.0 / N
        values = ns * eps
        ax2.plot(ns, values, label=f'ε = 1/{N} (→ 1/ω)', linewidth=2, alpha=0.7)
    ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Total mass = 1')
    ax2.set_xlabel('Number of points n', fontsize=12)
    ax2.set_ylabel('n · ε', fontsize=12)
    ax2.set_title('Non-Archimedean: n·ε stays infinitesimal for finite n', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 1.2)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('archimedean_barrier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: archimedean_barrier.png")


def plot_measure_comparison():
    """Plot comparing standard vs infinitesimal measures."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Standard probability on [0,1] — point masses are 0
    ax1 = axes[0]
    x_points = np.linspace(0, 1, 20)
    ax1.stem(x_points, np.zeros_like(x_points), linefmt='b-', markerfmt='bo', basefmt='b-')
    ax1.fill_between([0, 1], 0, 1, alpha=0.2, color='blue', label='Density = 1')
    ax1.axhline(y=1, color='blue', linestyle='-', alpha=0.5)
    ax1.set_xlabel('x ∈ [0,1]', fontsize=12)
    ax1.set_ylabel('P({x})', fontsize=12)
    ax1.set_title('Standard: P({x}) = 0 for all x', fontsize=13)
    ax1.set_ylim(-0.1, 1.5)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.annotate('Each point has\nprobability ZERO', xy=(0.5, 0), xytext=(0.5, 0.7),
                fontsize=11, ha='center', arrowprops=dict(arrowstyle='->', color='red'),
                color='red', fontweight='bold')
    
    # Right: Infinitesimal probability — point masses are ε > 0
    ax2 = axes[1]
    n = 20
    x_points = np.linspace(0, 1, n)
    eps_display = 0.05  # Visual representation of infinitesimal
    ax2.stem(x_points, np.full_like(x_points, eps_display), 
             linefmt='g-', markerfmt='go', basefmt='g-')
    ax2.axhline(y=eps_display, color='green', linestyle='--', alpha=0.5, 
                label=f'ε = 1/{n} (infinitesimal)')
    ax2.set_xlabel('x ∈ Ω', fontsize=12)
    ax2.set_ylabel('P({x})', fontsize=12)
    ax2.set_title(f'Infinitesimal: P({{x}}) = ε > 0 for all x', fontsize=13)
    ax2.set_ylim(-0.01, 0.15)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.annotate('Each point has\nprobability ε > 0!', xy=(0.5, eps_display), 
                xytext=(0.5, 0.12),
                fontsize=11, ha='center', arrowprops=dict(arrowstyle='->', color='green'),
                color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('measure_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: measure_comparison.png")


def plot_conditional_probability():
    """Plot showing conditional probability computation."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Universe = {1,...,6}, A = even, B = ≤ 4
    universe = range(1, 7)
    A = {2, 4, 6}
    B = {1, 2, 3, 4}
    AnB = A & B
    
    colors = []
    for x in universe:
        if x in AnB:
            colors.append('#2ecc71')  # green: in both
        elif x in A:
            colors.append('#3498db')  # blue: only in A
        elif x in B:
            colors.append('#e74c3c')  # red: only in B
        else:
            colors.append('#95a5a6')  # gray: neither
    
    bars = ax.bar(list(universe), [1]*6, color=colors, edgecolor='black', linewidth=1.5)
    
    ax.set_xlabel('Element', fontsize=12)
    ax.set_ylabel('Weight (ε)', fontsize=12)
    ax.set_title('P(Even | ≤ 4) = |A∩B| / |B| = 2/4 = 1/2\n'
                 'Infinitesimals cancel in the ratio!', fontsize=13)
    
    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#2ecc71', edgecolor='black', label='A∩B (even AND ≤4)'),
        Patch(facecolor='#3498db', edgecolor='black', label='A only (even, >4)'),
        Patch(facecolor='#e74c3c', edgecolor='black', label='B only (odd, ≤4)'),
    ]
    ax.legend(handles=legend_elements, fontsize=10, loc='upper right')
    ax.set_xticks(list(universe))
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('conditional_probability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conditional_probability.png")


if __name__ == "__main__":
    plot_archimedean_barrier()
    plot_measure_comparison()
    plot_conditional_probability()
    print("\nAll visualizations generated!")
