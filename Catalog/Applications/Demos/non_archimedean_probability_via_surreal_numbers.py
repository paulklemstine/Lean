#!/usr/bin/env python3
"""
Non-Archimedean Probability: Numerical Demonstrations

Demonstrates the key results from the non-Archimedean probability theory:
1. The Archimedean impossibility: uniform ε always exceeds budget
2. The infinitesimal escape: symbolic computation with ε
3. Bayes' theorem with infinitesimal probabilities
4. Ratio independence from choice of infinitesimal
"""

from fractions import Fraction
from typing import Set, FrozenSet


class InfinitesimalProb:
    """
    Represents a non-Archimedean probability as a * ε + b,
    where ε is a formal infinitesimal (0 < ε < 1/n for all n).
    
    For simplicity, we represent probabilities as (coefficient, constant)
    meaning value = coefficient * ε + constant.
    """
    
    def __init__(self, coeff: Fraction, const: Fraction = Fraction(0)):
        self.coeff = coeff  # coefficient of ε
        self.const = const  # constant term
    
    def __repr__(self):
        parts = []
        if self.const != 0:
            parts.append(str(self.const))
        if self.coeff != 0:
            if self.coeff == 1:
                parts.append("ε")
            elif self.coeff == -1:
                parts.append("-ε")
            else:
                parts.append(f"{self.coeff}·ε")
        return " + ".join(parts) if parts else "0"
    
    def __add__(self, other):
        return InfinitesimalProb(self.coeff + other.coeff, self.const + other.const)
    
    def __sub__(self, other):
        return InfinitesimalProb(self.coeff - other.coeff, self.const - other.const)
    
    def __mul__(self, n: int):
        return InfinitesimalProb(self.coeff * n, self.const * n)
    
    def __truediv__(self, other):
        """Division: (a·ε + b) / (c·ε + d).
        If both are pure infinitesimal (b=d=0): a/c (standard).
        If denominator is standard (c=0): (a/d)·ε + b/d.
        """
        if other.const == 0 and self.const == 0:
            # Both infinitesimal: ratio is standard
            return InfinitesimalProb(Fraction(0), self.coeff / other.coeff)
        elif other.const != 0 and other.coeff == 0:
            # Denominator is standard
            return InfinitesimalProb(
                self.coeff / other.const, self.const / other.const
            )
        else:
            # General case: approximate by dropping ε² terms
            # (a·ε + b)/(c·ε + d) ≈ (a·ε + b)/d when ε is infinitesimal
            return InfinitesimalProb(
                self.coeff / other.const, self.const / other.const
            )
    
    def is_positive(self):
        """An infinitesimal a·ε + b is positive if b > 0, or b = 0 and a > 0."""
        if self.const > 0:
            return True
        if self.const == 0 and self.coeff > 0:
            return True
        return False
    
    def is_less_than_one(self):
        """a·ε + b < 1 iff b < 1, or b = 1 and a < 0."""
        if self.const < 1:
            return True
        if self.const == 1 and self.coeff < 0:
            return True
        return False


class UniformNonArchMeasure:
    """A uniform finitely additive measure with infinitesimal weight."""
    
    def __init__(self):
        self.weight = InfinitesimalProb(Fraction(1))  # weight = ε
    
    def measure(self, s: set) -> InfinitesimalProb:
        """μ(S) = |S| · ε"""
        return InfinitesimalProb(Fraction(len(s)))
    
    def cond_prob(self, a: set, b: set) -> InfinitesimalProb:
        """P(A | B) = μ(A ∩ B) / μ(B)"""
        intersection = a & b
        return self.measure(intersection) / self.measure(b)


def demo_archimedean_impossibility():
    """Demonstrate that in ℝ, uniform ε always exceeds 1 for large n."""
    print("=" * 60)
    print("DEMO 1: Archimedean Impossibility")
    print("=" * 60)
    
    for eps in [0.1, 0.01, 0.001, 0.0001]:
        n = int(1 / eps)
        print(f"  ε = {eps}: need n = {n} points for n·ε = {n * eps:.4f} ≥ 1")
    
    print("\n  No matter how small ε > 0 is, there exists n with n·ε ≥ 1.")
    print("  This is the Archimedean property in action.\n")


def demo_infinitesimal_measure():
    """Demonstrate the non-Archimedean uniform measure."""
    print("=" * 60)
    print("DEMO 2: Non-Archimedean Uniform Measure")
    print("=" * 60)
    
    m = UniformNonArchMeasure()
    
    for n in [1, 5, 10, 100, 1000000]:
        s = set(range(n))
        mu = m.measure(s)
        print(f"  μ(S) for |S| = {n}: {mu}")
        print(f"    Positive: {mu.is_positive()}, Less than 1: {mu.is_less_than_one()}")
    
    print("\n  All finite sets have measure < 1, no matter how large!\n")


def demo_bayes_theorem():
    """Demonstrate Bayes' theorem with infinitesimal probabilities."""
    print("=" * 60)
    print("DEMO 3: Non-Archimedean Bayes' Theorem")
    print("=" * 60)
    
    m = UniformNonArchMeasure()
    
    A = {1, 2, 3}
    B = {2, 3, 4, 5}
    
    p_a_given_b = m.cond_prob(A, B)
    p_b_given_a = m.cond_prob(B, A)
    
    print(f"  A = {A}, B = {B}")
    print(f"  A ∩ B = {A & B}")
    print(f"  μ(A) = {m.measure(A)}, μ(B) = {m.measure(B)}")
    print(f"  P(A|B) = {p_a_given_b}")
    print(f"  P(B|A) = {p_b_given_a}")
    
    # Verify Bayes: P(A|B) · μ(B) = P(B|A) · μ(A)
    lhs = p_a_given_b.const * Fraction(len(B))
    rhs = p_b_given_a.const * Fraction(len(A))
    print(f"\n  P(A|B) · |B| = {lhs}")
    print(f"  P(B|A) · |A| = {rhs}")
    print(f"  Equal: {lhs == rhs}  ← Bayes' theorem verified!\n")


def demo_ratio_independence():
    """Show that ratios are independent of the infinitesimal choice."""
    print("=" * 60)
    print("DEMO 4: Ratio Independence from Infinitesimal")
    print("=" * 60)
    
    m = UniformNonArchMeasure()
    
    S = {1, 2, 3}
    T = {10, 20, 30, 40, 50}
    
    mu_s = m.measure(S)
    mu_t = m.measure(T)
    
    ratio = mu_s / mu_t
    
    print(f"  S = {S} (|S| = {len(S)})")
    print(f"  T = {T} (|T| = {len(T)})")
    print(f"  μ(S) = {mu_s}")
    print(f"  μ(T) = {mu_t}")
    print(f"  μ(S)/μ(T) = {ratio}")
    print(f"  |S|/|T| = {Fraction(len(S), len(T))}")
    print(f"  Equal: {ratio.const == Fraction(len(S), len(T))}")
    print(f"\n  The ratio is a standard rational number, independent of ε!\n")


def demo_conditioning_singletons():
    """Conditioning on singletons — possible only in non-Archimedean setting."""
    print("=" * 60)
    print("DEMO 5: Conditioning on Singletons")
    print("=" * 60)
    
    m = UniformNonArchMeasure()
    
    universe = set(range(1, 7))  # {1, 2, 3, 4, 5, 6} — a die
    
    print(f"  Universe = {universe} (a fair die)")
    print(f"  μ({{x}}) = ε for each x (infinitesimal)")
    print()
    
    for event_name, event in [("even", {2, 4, 6}), ("≥ 4", {4, 5, 6})]:
        for x in [1, 3, 5]:
            p = m.cond_prob(event, {x})
            print(f"  P({event_name} | {{x={x}}}) = {p}")
    
    print()
    print("  Conditioning on singletons gives 0 or 1 — perfectly intuitive!")
    print("  In standard probability, P(A | {x}) is UNDEFINED (0/0).\n")


if __name__ == "__main__":
    demo_archimedean_impossibility()
    demo_infinitesimal_measure()
    demo_bayes_theorem()
    demo_ratio_independence()
    demo_conditioning_singletons()
    
    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Archimedean vs Non-Archimedean probability accumulation.

Shows how uniform probability accumulates as more points are added:
- In Archimedean (real) fields: always exceeds 1 eventually
- In non-Archimedean fields: stays below 1 forever
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_archimedean_impossibility():
    """Plot cumulative probability for various ε values in ℝ."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Archimedean case
    epsilons = [0.1, 0.05, 0.02, 0.01]
    ns = np.arange(1, 201)
    
    for eps in epsilons:
        cumulative = ns * eps
        ax1.plot(ns, cumulative, label=f'ε = {eps}')
    
    ax1.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Budget = 1')
    ax1.set_xlabel('Number of points n', fontsize=12)
    ax1.set_ylabel('Cumulative probability n·ε', fontsize=12)
    ax1.set_title('Archimedean Field (ℝ): Budget Always Exceeded', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 2.5)
    ax1.grid(True, alpha=0.3)
    
    # Annotate break points
    for eps in epsilons:
        break_n = int(np.ceil(1 / eps))
        if break_n <= 200:
            ax1.plot(break_n, 1, 'ro', markersize=8)
            ax1.annotate(f'n={break_n}', (break_n, 1), 
                        textcoords="offset points", xytext=(10, 10),
                        fontsize=9, color='red')
    
    # Right: Non-Archimedean case (symbolic)
    ns_nonarch = np.arange(1, 1001)
    
    # In non-Archimedean: n·ε < 1 for ALL n
    # We visualize this as the "height" approaching but never reaching 1
    for label, asymptote in [('ε₁ (very small)', 0.3), ('ε₂ (smaller)', 0.2), 
                               ('ε₃ (infinitesimal limit)', 0.1)]:
        curve = asymptote * (1 - np.exp(-ns_nonarch / 200))
        ax2.plot(ns_nonarch, curve, label=label, linewidth=2)
    
    ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Budget = 1')
    ax2.set_xlabel('Number of points n', fontsize=12)
    ax2.set_ylabel('Cumulative probability (symbolic)', fontsize=12)
    ax2.set_title('Non-Archimedean Field: Budget Never Exceeded', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 1.5)
    ax2.grid(True, alpha=0.3)
    ax2.text(500, 0.7, 'n·ε < 1 for ALL n', fontsize=14, 
             ha='center', style='italic', color='green',
             bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('archimedean_vs_nonarch.png', dpi=150, bbox_inches='tight')
    print("Saved: archimedean_vs_nonarch.png")


def plot_conditional_probability():
    """Show conditional probability landscape for non-Archimedean measures."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    # Universe = {1, ..., 20}
    n = 20
    universe = set(range(1, n + 1))
    
    # Compute P(A|B) = |A ∩ B| / |B| for various A, B sizes
    sizes_a = range(1, n + 1)
    sizes_b = range(1, n + 1)
    
    # For each (|A|, |B|), compute expected |A ∩ B| / |B|
    # when A, B are random subsets of {1,...,20}
    # E[|A ∩ B|] = |A| · |B| / n, so E[P(A|B)] = |A| / n
    
    data = np.zeros((n, n))
    for i, sa in enumerate(sizes_a):
        for j, sb in enumerate(sizes_b):
            # Expected conditional probability
            expected_intersect = sa * sb / n
            data[i, j] = expected_intersect / sb  # = sa / n
    
    im = ax.imshow(data, origin='lower', cmap='viridis', aspect='auto',
                   extent=[0.5, n + 0.5, 0.5, n + 0.5])
    ax.set_xlabel('|B| (conditioning event size)', fontsize=12)
    ax.set_ylabel('|A| (target event size)', fontsize=12)
    ax.set_title('Expected P(A | B) in Non-Archimedean Probability\n'
                 '(Universe size = 20, uniform infinitesimal weight)', fontsize=14)
    plt.colorbar(im, ax=ax, label='E[P(A|B)] = |A|/|Universe|')
    
    # Highlight the diagonal where |A| = |B|
    ax.plot([0.5, n + 0.5], [0.5, n + 0.5], 'r--', linewidth=1, alpha=0.5)
    
    plt.tight_layout()
    plt.savefig('conditional_probability_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved: conditional_probability_landscape.png")


if __name__ == "__main__":
    plot_archimedean_impossibility()
    plot_conditional_probability()
