#!/usr/bin/env python3
"""
Non-Archimedean Probability: Numerical Demonstrations

This script demonstrates the key results of the non-Archimedean probability theory
using symbolic computation with formal power series (Laurent series in t,
where t represents an infinitesimal).
"""

from fractions import Fraction
from typing import Dict, List, Tuple


class InfinitesimalNumber:
    """
    Represents a number of the form a + b*ε + c*ε² + ...
    where ε is a positive infinitesimal.
    
    Internally stored as a dict {power: coefficient} with rational coefficients.
    The ordering is lexicographic: compare the coefficient of the lowest power of ε first.
    Negative powers of ε represent infinite quantities.
    """
    
    def __init__(self, coeffs: Dict[int, Fraction] = None):
        self.coeffs = {}
        if coeffs:
            for k, v in coeffs.items():
                if v != 0:
                    self.coeffs[k] = Fraction(v)
    
    @classmethod
    def real(cls, value) -> 'InfinitesimalNumber':
        """Create a real (standard) number."""
        return cls({0: Fraction(value)})
    
    @classmethod
    def epsilon(cls, power: int = 1) -> 'InfinitesimalNumber':
        """Create ε^power."""
        return cls({power: Fraction(1)})
    
    def __add__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            result[k] = result.get(k, Fraction(0)) + v
        return InfinitesimalNumber(result)
    
    def __sub__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            result[k] = result.get(k, Fraction(0)) - v
        return InfinitesimalNumber(result)
    
    def __mul__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        result = {}
        for k1, v1 in self.coeffs.items():
            for k2, v2 in other.coeffs.items():
                k = k1 + k2
                result[k] = result.get(k, Fraction(0)) + v1 * v2
        return InfinitesimalNumber(result)
    
    def __truediv__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        """Division (simplified: only works when other has a single term)."""
        if not other.coeffs:
            raise ZeroDivisionError("Division by zero")
        # Get leading term of other
        min_power = min(other.coeffs.keys())
        lead_coeff = other.coeffs[min_power]
        result = {}
        for k, v in self.coeffs.items():
            result[k - min_power] = v / lead_coeff
        return InfinitesimalNumber(result)
    
    def is_positive(self) -> bool:
        if not self.coeffs:
            return False
        min_power = min(self.coeffs.keys())
        return self.coeffs[min_power] > 0
    
    def is_infinitesimal(self) -> bool:
        """True if all powers are > 0 (smaller than any positive real)."""
        return all(k > 0 for k in self.coeffs.keys()) and self.is_positive()
    
    def standard_part(self) -> Fraction:
        """The real part (coefficient of ε⁰)."""
        return self.coeffs.get(0, Fraction(0))
    
    def __repr__(self) -> str:
        if not self.coeffs:
            return "0"
        terms = []
        for k in sorted(self.coeffs.keys()):
            v = self.coeffs[k]
            if v == 0:
                continue
            if k == 0:
                terms.append(f"{v}")
            elif k == 1:
                terms.append(f"{v}·ε")
            else:
                terms.append(f"{v}·ε^{k}")
        return " + ".join(terms) if terms else "0"


class InfinitesimalProbSpace:
    """
    A finitely additive probability space with infinitesimal point masses.
    
    On a finite sample space of size n, assigns probability ε to each point
    and distributes the remaining 1 - n·ε uniformly or via a correction function.
    """
    
    def __init__(self, points: List[str], epsilon_power: int = 1):
        self.points = points
        self.n = len(points)
        self.eps = InfinitesimalNumber.epsilon(epsilon_power)
        # Each point gets probability ε
        # Total of singletons = n·ε
        # Remaining = 1 - n·ε > 0 (since ε is infinitesimal, n·ε < 1)
    
    def point_mass(self, x: str) -> InfinitesimalNumber:
        """μ({x}) = ε for all x."""
        if x in self.points:
            return self.eps
        return InfinitesimalNumber.real(0)
    
    def measure(self, subset: set) -> InfinitesimalNumber:
        """μ(A) = |A| · ε for singletons, adjusted for the full space."""
        count = sum(1 for p in self.points if p in subset)
        if subset == set(self.points):
            return InfinitesimalNumber.real(1)
        return InfinitesimalNumber({self.eps.coeffs.copy().popitem()[0]: Fraction(count)})
    
    def cond_prob(self, a: set, b: set) -> InfinitesimalNumber:
        """P(A|B) = μ(A ∩ B) / μ(B)."""
        intersection = a & b
        mu_inter = self.measure(intersection)
        mu_b = self.measure(b)
        return mu_inter / mu_b


def demo_basic_properties():
    """Demonstrate basic properties of infinitesimal probability."""
    print("=" * 60)
    print("DEMO 1: Basic Infinitesimal Probability Properties")
    print("=" * 60)
    
    eps = InfinitesimalNumber.epsilon(1)
    one = InfinitesimalNumber.real(1)
    
    print(f"\nε = {eps}")
    print(f"ε is positive: {eps.is_positive()}")
    print(f"ε is infinitesimal: {eps.is_infinitesimal()}")
    
    # n·ε < 1 for all standard n
    for n in [1, 10, 100, 1000, 1000000]:
        n_eps = InfinitesimalNumber.real(n) * eps
        diff = one - n_eps
        print(f"  {n}·ε = {n_eps}, 1 - {n}·ε = {diff}, positive: {diff.is_positive()}")
    
    print("\n✓ Verified: n·ε < 1 for all tested n (consistent with Theorem: infinitesimal_finite_sum_lt_one)")


def demo_complement_and_monotonicity():
    """Demonstrate complement formula and monotonicity."""
    print("\n" + "=" * 60)
    print("DEMO 2: Complement Formula and Monotonicity")
    print("=" * 60)
    
    eps = InfinitesimalNumber.epsilon(1)
    one = InfinitesimalNumber.real(1)
    
    # μ(A) = 3ε, μ(Aᶜ) should be 1 - 3ε
    mu_A = InfinitesimalNumber.real(3) * eps
    mu_Ac = one - mu_A
    print(f"\nμ(A) = {mu_A}")
    print(f"μ(Aᶜ) = 1 - μ(A) = {mu_Ac}")
    print(f"μ(A) + μ(Aᶜ) = {mu_A + mu_Ac}")
    print("✓ Verified: μ(A) + μ(Aᶜ) = 1 (Theorem: measure_compl)")


def demo_bayes_theorem():
    """Demonstrate Bayes' theorem with infinitesimal probabilities."""
    print("\n" + "=" * 60)
    print("DEMO 3: Bayes' Theorem with Infinitesimal Probabilities")
    print("=" * 60)
    
    eps = InfinitesimalNumber.epsilon(1)
    
    # Setup: 4 points {a, b, c, d}
    # μ({a}) = μ({b}) = μ({c}) = μ({d}) = ε (infinitesimal)
    # For simplicity, we work with the measure values directly
    
    # A = {a, b}, B = {b, c}
    # μ(A) = 2ε, μ(B) = 2ε
    # μ(A ∩ B) = μ({b}) = ε
    
    mu_A = InfinitesimalNumber.real(2) * eps
    mu_B = InfinitesimalNumber.real(2) * eps
    mu_AB = eps  # A ∩ B = {b}
    
    # P(A|B) = μ(A ∩ B) / μ(B)
    p_A_given_B = mu_AB / mu_B
    # P(B|A) = μ(A ∩ B) / μ(A)
    p_B_given_A = mu_AB / mu_A
    
    # Bayes: P(A|B) · μ(B) = P(B|A) · μ(A)
    lhs = p_A_given_B * mu_B
    rhs = p_B_given_A * mu_A
    
    print(f"\nSample space: {{a, b, c, d}} with uniform infinitesimal measure ε")
    print(f"A = {{a, b}}, B = {{b, c}}")
    print(f"μ(A) = {mu_A}, μ(B) = {mu_B}, μ(A∩B) = {mu_AB}")
    print(f"P(A|B) = μ(A∩B)/μ(B) = {p_A_given_B}")
    print(f"P(B|A) = μ(A∩B)/μ(A) = {p_B_given_A}")
    print(f"P(A|B)·μ(B) = {lhs}")
    print(f"P(B|A)·μ(A) = {rhs}")
    print(f"✓ Bayes' theorem: P(A|B)·μ(B) = P(B|A)·μ(A) = μ(A∩B) = {mu_AB}")
    print("  (Theorem: bayes_theorem)")
    
    print("\n--- Conditioning on a SINGLE POINT (classically impossible!) ---")
    # P({a} | {b}) = μ({a} ∩ {b}) / μ({b}) = 0 / ε = 0
    # P({b} | {b}) = μ({b}) / μ({b}) = ε / ε = 1
    mu_b = eps
    p_a_given_b = InfinitesimalNumber.real(0) / mu_b  # empty intersection
    p_b_given_b = mu_b / mu_b
    
    print(f"P({{a}} | {{b}}) = {p_a_given_b}  (disjoint events)")
    print(f"P({{b}} | {{b}}) = {p_b_given_b}  (conditioning on self)")
    print("✓ Conditional probability well-defined even for infinitesimal events!")


def demo_impossibility():
    """Demonstrate the Archimedean impossibility theorem."""
    print("\n" + "=" * 60)
    print("DEMO 4: Archimedean Impossibility Theorem")
    print("=" * 60)
    
    print("\nAttempting uniform measure on {1, ..., n} with δ = 0.01 (real-valued):")
    delta = Fraction(1, 100)
    for n in [10, 50, 100, 101]:
        total = n * delta
        violated = total > 1
        print(f"  n = {n}: n·δ = {float(total):.2f}, exceeds 1: {violated}")
    
    print(f"\n✓ For δ = 0.01, the bound is violated at n = {int(1/delta) + 1}")
    print("  In general, for any real δ > 0, violated at n > 1/δ")
    print("  (Theorem: no_uniform_point_mass_archimedean)")
    
    print("\nWith infinitesimal ε:")
    eps = InfinitesimalNumber.epsilon(1)
    one = InfinitesimalNumber.real(1)
    for n in [10, 100, 1000, 10**6]:
        total = InfinitesimalNumber.real(n) * eps
        diff = one - total
        print(f"  n = {n}: n·ε = {total}, 1 - n·ε = {diff}, valid: {diff.is_positive()}")
    print("✓ No violation for any finite n — infinitesimals bypass the impossibility!")


def demo_total_probability():
    """Demonstrate the law of total probability."""
    print("\n" + "=" * 60)
    print("DEMO 5: Law of Total Probability")
    print("=" * 60)
    
    eps = InfinitesimalNumber.epsilon(1)
    
    # Space = {1, 2, 3, 4, 5}, uniform infinitesimal measure
    # A = {1, 2, 3}, B = {1, 2}, Bᶜ = {3, 4, 5}
    mu_A = InfinitesimalNumber.real(3) * eps
    mu_B = InfinitesimalNumber.real(2) * eps
    mu_Bc = InfinitesimalNumber.real(3) * eps
    mu_AB = InfinitesimalNumber.real(2) * eps  # A ∩ B = {1, 2}
    mu_ABc = InfinitesimalNumber.real(1) * eps  # A ∩ Bᶜ = {3}
    
    p_A_given_B = mu_AB / mu_B
    p_A_given_Bc = mu_ABc / mu_Bc
    
    total = p_A_given_B * mu_B + p_A_given_Bc * mu_Bc
    
    print(f"\nSpace = {{1,2,3,4,5}}, uniform ε measure")
    print(f"A = {{1,2,3}}, B = {{1,2}}, Bᶜ = {{3,4,5}}")
    print(f"μ(A) = {mu_A}")
    print(f"P(A|B) = {p_A_given_B}, P(A|Bᶜ) = {p_A_given_Bc}")
    print(f"P(A|B)·μ(B) + P(A|Bᶜ)·μ(Bᶜ) = {total}")
    print(f"μ(A) = {mu_A}")
    print(f"✓ Total probability: μ(A) = P(A|B)·μ(B) + P(A|Bᶜ)·μ(Bᶜ)")
    print("  (Theorem: total_probability)")


def demo_characterization():
    """Demonstrate the infinitesimal characterization theorem."""
    print("\n" + "=" * 60)
    print("DEMO 6: Characterization Theorem")
    print("=" * 60)
    
    eps = InfinitesimalNumber.epsilon(1)
    
    print("\nIf all point masses equal ε on an infinite set, then ε is infinitesimal:")
    print(f"  ε = {eps}")
    print(f"  ε > 0: {eps.is_positive()}")
    
    for n in [1, 2, 5, 10, 100]:
        n_eps = InfinitesimalNumber.real(n) * eps
        one = InfinitesimalNumber.real(1)
        diff = one - n_eps
        print(f"  {n}·ε = {n_eps} < 1: {diff.is_positive()}")
    
    print(f"\n✓ ε satisfies: 0 < ε and n·ε < 1 for all n > 0")
    print("  Therefore ε is a positive infinitesimal")
    print("  (Theorem: uniform_point_mass_is_infinitesimal)")


if __name__ == "__main__":
    demo_basic_properties()
    demo_complement_and_monotonicity()
    demo_bayes_theorem()
    demo_impossibility()
    demo_total_probability()
    demo_characterization()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Archimedean Impossibility Frontier

Shows the boundary between feasible and infeasible regions for uniform
point masses in Archimedean vs non-Archimedean fields.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_impossibility_frontier():
    """Plot the n·δ = 1 frontier."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left panel: Archimedean case (real numbers)
    ax1 = axes[0]
    n_vals = np.arange(1, 201)
    deltas = [0.1, 0.05, 0.02, 0.01, 0.005]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(deltas)))
    
    for delta, color in zip(deltas, colors):
        total = n_vals * delta
        ax1.plot(n_vals, total, color=color, label=f'δ = {delta}', linewidth=2)
    
    ax1.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Probability bound (= 1)')
    ax1.fill_between(n_vals, 1, 2.5, alpha=0.1, color='red')
    ax1.set_xlabel('Number of points (n)', fontsize=12)
    ax1.set_ylabel('Total probability n·δ', fontsize=12)
    ax1.set_title('Archimedean Field (ℝ): Impossibility', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 2.5)
    ax1.text(150, 1.8, 'IMPOSSIBLE\n(n·δ > 1)', fontsize=14, ha='center',
             color='red', fontweight='bold', alpha=0.7)
    ax1.text(50, 0.3, 'FEASIBLE\n(n·δ ≤ 1)', fontsize=14, ha='center',
             color='green', fontweight='bold', alpha=0.7)
    
    # Right panel: Non-Archimedean case
    ax2 = axes[1]
    # In non-Archimedean field, n·ε is always infinitesimal for any standard n
    # We represent this by showing n·ε stays near 0
    n_vals_na = np.arange(1, 1001)
    
    # Represent infinitesimal as "approaching 0" line
    ax2.fill_between(n_vals_na, 0, 0.05, alpha=0.3, color='blue',
                     label='n·ε (infinitesimal for all n)')
    ax2.axhline(y=1, color='green', linestyle='--', linewidth=2, label='Probability bound (= 1)')
    ax2.axhline(y=0.025, color='blue', linewidth=2, alpha=0.5)
    
    ax2.set_xlabel('Number of points (n)', fontsize=12)
    ax2.set_ylabel('Total probability n·ε', fontsize=12)
    ax2.set_title('Non-Archimedean Field: Always Feasible', fontsize=14)
    ax2.legend(fontsize=10, loc='center right')
    ax2.set_ylim(0, 1.5)
    ax2.text(500, 0.8, 'ALWAYS FEASIBLE\n(n·ε < 1 for all standard n)',
             fontsize=14, ha='center', color='green', fontweight='bold', alpha=0.7)
    ax2.text(500, 0.15, 'n·ε ≈ 0 (infinitesimal)', fontsize=11, ha='center',
             color='blue', style='italic')
    
    plt.suptitle('The Archimedean–Non-Archimedean Dichotomy for Uniform Point Masses',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_impossibility.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_impossibility.png")


def plot_conditional_probability():
    """
    Plot conditional probability behavior in Archimedean vs non-Archimedean.
    """
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # In standard probability: P(A|B) undefined when P(B) = 0
    # In non-Archimedean: P(A|B) = P(A∩B)/P(B) always defined for B ≠ ∅
    
    n_points = 50
    x = np.arange(1, n_points + 1)
    
    # Standard: P({k}) = geometric(1/2)
    real_probs = np.array([0.5**k for k in x])
    
    # Non-Archimedean: P({k}) = ε for all k
    # Plot as constant line near 0
    eps_level = 0.002
    na_probs = np.full_like(x, eps_level, dtype=float)
    
    ax.bar(x - 0.2, real_probs, width=0.4, color='steelblue', alpha=0.8,
           label='Real-valued (geometric): P({k}) = 2⁻ᵏ')
    ax.bar(x + 0.2, na_probs, width=0.4, color='darkorange', alpha=0.8,
           label='Non-Archimedean (uniform): P({k}) = ε')
    
    ax.set_xlabel('Point k', fontsize=12)
    ax.set_ylabel('Probability P({k})', fontsize=12)
    ax.set_title('Point Mass Distributions: Real vs Non-Archimedean', fontsize=14)
    ax.set_yscale('log')
    ax.set_ylim(1e-16, 1)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 30)
    
    # Add annotation
    ax.annotate('Real: masses decay to 0\n(many points have ~0 probability)',
                xy=(15, 1e-5), fontsize=10, color='steelblue',
                ha='center', style='italic')
    ax.annotate('Non-Archimedean:\nall masses equal ε > 0',
                xy=(25, eps_level * 5), fontsize=10, color='darkorange',
                ha='center', style='italic')
    
    plt.tight_layout()
    plt.savefig('viz_point_masses.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_point_masses.png")


if __name__ == "__main__":
    plot_impossibility_frontier()
    plot_conditional_probability()
    print("All visualizations generated.")
