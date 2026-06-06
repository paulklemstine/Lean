#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory — Numerical Demonstrations

This module demonstrates the key results of non-Archimedean probability theory
using Python's Fraction type for exact arithmetic and symbolic infinitesimals.
"""

from fractions import Fraction
from typing import Dict, List, Tuple, Optional
import math


# =============================================================================
# 1. The Archimedean Impossibility
# =============================================================================

def archimedean_impossibility_demo():
    """
    Demonstrates that in the rationals (an Archimedean field), no uniform
    probability can assign the same weight to infinitely many points.
    
    For any w > 0, there exists n such that n*w > 1.
    """
    print("=" * 70)
    print("ARCHIMEDEAN IMPOSSIBILITY")
    print("=" * 70)
    
    weights = [Fraction(1, 10**k) for k in range(1, 8)]
    
    for w in weights:
        n_exceed = math.ceil(1 / w) + 1
        print(f"  w = {w}: n*w > 1 when n = {n_exceed} "
              f"(n*w = {Fraction(n_exceed) * w})")
    
    print("\n  → In ANY Archimedean field, for any w > 0, we can always find n")
    print("    such that n·w exceeds 1. Infinitesimal probability is impossible.")
    print()


# =============================================================================
# 2. Non-Archimedean Field: Dual Numbers with Lexicographic Order
# =============================================================================

class NonArchElement:
    """
    Represents an element of the non-Archimedean field Q(ε) where ε is
    infinitesimal. An element is (real_part, infinitesimal_part) meaning
    real_part + infinitesimal_part * ε.
    
    Ordered lexicographically: (a, b) < (c, d) iff a < c, or a = c and b < d.
    """
    
    def __init__(self, real: Fraction, inf: Fraction = Fraction(0)):
        self.real = real
        self.inf = inf
    
    def __add__(self, other: 'NonArchElement') -> 'NonArchElement':
        return NonArchElement(self.real + other.real, self.inf + other.inf)
    
    def __sub__(self, other: 'NonArchElement') -> 'NonArchElement':
        return NonArchElement(self.real - other.real, self.inf - other.inf)
    
    def __mul__(self, other: 'NonArchElement') -> 'NonArchElement':
        # (a + bε)(c + dε) = ac + (ad + bc)ε  (ignore ε² terms for simplicity)
        return NonArchElement(
            self.real * other.real,
            self.real * other.inf + self.inf * other.real
        )
    
    def __lt__(self, other: 'NonArchElement') -> bool:
        if self.real != other.real:
            return self.real < other.real
        return self.inf < other.inf
    
    def __le__(self, other: 'NonArchElement') -> bool:
        return self == other or self < other
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, NonArchElement):
            return NotImplemented
        return self.real == other.real and self.inf == other.inf
    
    def __repr__(self) -> str:
        if self.inf == 0:
            return str(self.real)
        elif self.real == 0:
            return f"{self.inf}ε"
        else:
            sign = "+" if self.inf > 0 else ""
            return f"{self.real} {sign} {self.inf}ε"
    
    def standard_part(self) -> Fraction:
        """The standard part map: rounds infinitesimals to 0."""
        return self.real
    
    def is_infinitesimal(self) -> bool:
        """Check if this element is infinitesimal (real part = 0, inf part > 0)."""
        return self.real == Fraction(0) and self.inf > Fraction(0)
    
    @staticmethod
    def epsilon() -> 'NonArchElement':
        return NonArchElement(Fraction(0), Fraction(1))
    
    @staticmethod
    def from_rational(q: Fraction) -> 'NonArchElement':
        return NonArchElement(q)


def non_archimedean_demo():
    """
    Demonstrates infinitesimal probability on a finite set using Q(ε).
    """
    print("=" * 70)
    print("NON-ARCHIMEDEAN PROBABILITY SPACE")
    print("=" * 70)
    
    eps = NonArchElement.epsilon()
    
    print(f"\n  ε = {eps}")
    print(f"  Is ε infinitesimal? {eps.is_infinitesimal()}")
    print(f"  Standard part of ε: {eps.standard_part()}")
    
    # For any n, n*ε has real part 0, so n*ε < 1
    for n in [10, 100, 1000, 10**6]:
        n_eps = NonArchElement(Fraction(0), Fraction(n))
        one = NonArchElement.from_rational(Fraction(1))
        print(f"  {n}·ε = {n_eps}, < 1? {n_eps < one}")
    
    print("\n  → ε is truly infinitesimal: n·ε < 1 for ALL n.")
    print()


# =============================================================================
# 3. Uniform Infinitesimal Measure on Fin n
# =============================================================================

def uniform_measure_demo():
    """
    Constructs uniform measures on finite sets and shows properties.
    """
    print("=" * 70)
    print("UNIFORM INFINITESIMAL MEASURE ON FINITE SETS")
    print("=" * 70)
    
    for n in [3, 5, 10, 100]:
        w = Fraction(1, n)
        total = sum(w for _ in range(n))
        print(f"\n  Fin {n}: weight = 1/{n}, total = {total}")
        
        # Show finite additivity
        if n >= 5:
            A = list(range(n // 2))
            B = list(range(n // 2, n))
            mu_A = sum(w for _ in A)
            mu_B = sum(w for _ in B)
            mu_union = sum(w for _ in range(n))
            print(f"    A = {{0,...,{n//2-1}}}: μ(A) = {mu_A}")
            print(f"    B = {{{n//2},...,{n-1}}}: μ(B) = {mu_B}")
            print(f"    μ(A∪B) = {mu_union} = μ(A) + μ(B) = {mu_A + mu_B}")
    print()


# =============================================================================
# 4. The Standard Part Paradox
# =============================================================================

def standard_part_paradox_demo():
    """
    Demonstrates the Standard Part Paradox: if all weights are infinitesimal,
    their standard parts are all 0, yet must sum to 1.
    """
    print("=" * 70)
    print("THE STANDARD PART PARADOX")
    print("=" * 70)
    
    n = 5
    eps = NonArchElement.epsilon()
    weights = [NonArchElement(Fraction(0), Fraction(1, n)) for _ in range(n)]
    
    print(f"\n  {n} points, each with weight ε/{n} = {weights[0]}")
    
    total = NonArchElement(Fraction(0), Fraction(0))
    for w in weights:
        total = total + w
    print(f"  Total weight = {total}")
    
    # Standard parts
    std_parts = [w.standard_part() for w in weights]
    std_total = sum(std_parts)
    print(f"\n  Standard part of each weight: {std_parts[0]}")
    print(f"  Sum of standard parts: {std_total}")
    print(f"  Standard part of total: {total.standard_part()}")
    
    print(f"\n  PARADOX: Each st(wᵢ) = 0, so Σ st(wᵢ) = 0")
    print(f"  But if total = 1 (not ε), then st(Σ wᵢ) = st(1) = 1")
    print(f"  This means st(Σ wᵢ) ≠ Σ st(wᵢ) when all weights are infinitesimal!")
    
    print(f"\n  RESOLUTION (Theorem NAPA.no_infinitesimal_valued):")
    print(f"  No NAPA can have all infinitesimal weights.")
    print(f"  An additive standard part map CANNOT coexist with")
    print(f"  all-infinitesimal probability. This is a fundamental")
    print(f"  incompatibility theorem.")
    print()


# =============================================================================
# 5. Bayes' Rule with Infinitesimal Conditioning
# =============================================================================

def bayes_demo():
    """
    Demonstrates Bayes' rule in non-Archimedean probability.
    """
    print("=" * 70)
    print("BAYES' RULE IN NON-ARCHIMEDEAN PROBABILITY")
    print("=" * 70)
    
    # Example: 4 points with weights 1/2, 1/4, 1/8, 1/8
    weights = [Fraction(1, 2), Fraction(1, 4), Fraction(1, 8), Fraction(1, 8)]
    n = len(weights)
    
    A = {0, 1}  # First two points
    B = {1, 2}  # Middle two points
    
    mu_A = sum(weights[i] for i in A)
    mu_B = sum(weights[i] for i in B)
    mu_AB = sum(weights[i] for i in A & B)
    
    P_A_given_B = mu_AB / mu_B
    P_B_given_A = mu_AB / mu_A
    
    print(f"\n  Weights: {weights}")
    print(f"  A = {A}, B = {B}")
    print(f"  μ(A) = {mu_A}, μ(B) = {mu_B}, μ(A∩B) = {mu_AB}")
    print(f"  P(A|B) = {P_A_given_B}")
    print(f"  P(B|A) = {P_B_given_A}")
    print(f"  P(A|B)·μ(B) = {P_A_given_B * mu_B}")
    print(f"  P(B|A)·μ(A) = {P_B_given_A * mu_A}")
    print(f"  Equal? {P_A_given_B * mu_B == P_B_given_A * mu_A} ✓ (Bayes)")
    print()


# =============================================================================
# 6. Complementation and Monotonicity
# =============================================================================

def complementation_demo():
    """
    Demonstrates the complementation property μ(Aᶜ) = 1 - μ(A).
    """
    print("=" * 70)
    print("COMPLEMENTATION AND MONOTONICITY")
    print("=" * 70)
    
    weights = [Fraction(3, 10), Fraction(1, 5), Fraction(1, 10), 
               Fraction(1, 4), Fraction(3, 20)]
    n = len(weights)
    
    print(f"\n  Weights: {[str(w) for w in weights]}")
    print(f"  Total: {sum(weights)}")
    
    A = {0, 2}
    mu_A = sum(weights[i] for i in A)
    complement_A = set(range(n)) - A
    mu_comp = sum(weights[i] for i in complement_A)
    
    print(f"\n  A = {A}: μ(A) = {mu_A}")
    print(f"  Aᶜ = {complement_A}: μ(Aᶜ) = {mu_comp}")
    print(f"  1 - μ(A) = {1 - mu_A}")
    print(f"  μ(Aᶜ) = 1 - μ(A)? {mu_comp == 1 - mu_A} ✓")
    
    # Monotonicity
    B = {0, 1, 2}
    mu_B = sum(weights[i] for i in B)
    print(f"\n  A = {A} ⊆ B = {B}")
    print(f"  μ(A) = {mu_A} ≤ μ(B) = {mu_B}? {mu_A <= mu_B} ✓")
    print()


if __name__ == "__main__":
    print("\n" + "█" * 70)
    print("  NON-ARCHIMEDEAN PROBABILITY THEORY — DEMONSTRATIONS")
    print("█" * 70 + "\n")
    
    archimedean_impossibility_demo()
    non_archimedean_demo()
    uniform_measure_demo()
    standard_part_paradox_demo()
    bayes_demo()
    complementation_demo()
    
    print("█" * 70)
    print("  ALL DEMONSTRATIONS COMPLETE")
    print("█" * 70)


#!/usr/bin/env python3
"""
Visualization: The Archimedean Barrier

Shows how in Archimedean fields, n·w inevitably exceeds 1 for any w > 0,
while in non-Archimedean fields, n·ε stays below 1 for all n.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_archimedean_barrier():
    """Create a visualization of the Archimedean barrier."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left panel: Archimedean case
    n_vals = np.arange(1, 51)
    
    for w_inv in [5, 10, 20, 50]:
        w = 1.0 / w_inv
        cumsum = n_vals * w
        ax1.plot(n_vals, cumsum, label=f'w = 1/{w_inv}', linewidth=2)
    
    ax1.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Total = 1')
    ax1.set_xlabel('Number of points n', fontsize=12)
    ax1.set_ylabel('n · w (cumulative weight)', fontsize=12)
    ax1.set_title('Archimedean Field (ℚ, ℝ)\nCumulative weight always exceeds 1', 
                   fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 3)
    ax1.grid(True, alpha=0.3)
    
    # Shade the "forbidden zone" above 1
    ax1.fill_between(n_vals, 1, 3, alpha=0.1, color='red')
    ax1.text(25, 2, 'Exceeds total\nmass = 1', ha='center', va='center',
             fontsize=11, color='red', fontweight='bold')
    
    # Right panel: Non-Archimedean case (conceptual)
    # In non-Archimedean field, n·ε approaches but never reaches 1
    n_dense = np.linspace(1, 200, 500)
    
    # Use 1 - 1/n as a metaphor for the non-Archimedean behavior
    ax2.plot(n_dense, 1 - 1/n_dense, color='blue', linewidth=2.5,
             label='n · ε (conceptual)')
    ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Total = 1')
    
    ax2.set_xlabel('Number of points n', fontsize=12)
    ax2.set_ylabel('n · ε (cumulative weight)', fontsize=12)
    ax2.set_title('Non-Archimedean Field (with infinitesimals)\nn · ε < 1 for ALL n', 
                   fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 1.5)
    ax2.grid(True, alpha=0.3)
    
    # Shade the safe zone below 1
    ax2.fill_between(n_dense, 0, 1 - 1/n_dense, alpha=0.1, color='green')
    ax2.text(100, 0.4, 'Always below\ntotal mass', ha='center', va='center',
             fontsize=11, color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('archimedean_barrier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: archimedean_barrier.png")


if __name__ == "__main__":
    plot_archimedean_barrier()
