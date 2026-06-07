#!/usr/bin/env python3
"""
Demo: Non-Archimedean Probability via Surreal-Valued Measures

Demonstrates the key results of the NAP framework using symbolic
computation with sympy's formal infinitesimal ε.
"""

from fractions import Fraction
from typing import FrozenSet, Set


class NAPSpace:
    """A uniform non-Archimedean probability space over a finite set.

    Each element receives probability atom = 1/|Ω| (which would be
    infinitesimal ε in the surreal setting when |Ω| is infinite).
    """

    def __init__(self, universe: set):
        if not universe:
            raise ValueError("Universe must be non-empty")
        self.universe = frozenset(universe)
        self.n = len(self.universe)
        self.atom = Fraction(1, self.n)

    def measure(self, event: set) -> Fraction:
        """μ(A) = |A| · atom"""
        subset = frozenset(event) & self.universe
        return Fraction(len(subset), 1) * self.atom

    def cond_prob(self, a: set, b: set) -> Fraction:
        """P(A|B) = |A ∩ B| / |B| (ratio stability: infinitesimals cancel)"""
        b_set = frozenset(b) & self.universe
        if not b_set:
            raise ValueError("Cannot condition on empty event")
        ab = frozenset(a) & b_set
        return Fraction(len(ab), len(b_set))

    def verify_bayes(self, a: set, b: set) -> bool:
        """Verify Bayes' theorem: P(A|B)·P(B) = P(B|A)·P(A)"""
        a_set = frozenset(a) & self.universe
        b_set = frozenset(b) & self.universe
        if not a_set or not b_set:
            return False
        lhs = self.cond_prob(a, b) * self.measure(b)
        rhs = self.cond_prob(b, a) * self.measure(a)
        return lhs == rhs

    def is_independent(self, a: set, b: set) -> bool:
        """Check if P(A ∩ B) = P(A) · P(B)"""
        return self.measure(frozenset(a) & frozenset(b)) == \
               self.measure(a) * self.measure(b)


def demo_basic():
    """Demo 1: Basic NAP space on a die."""
    print("=" * 60)
    print("DEMO 1: Non-Archimedean Probability on a Fair Die")
    print("=" * 60)

    die = NAPSpace({1, 2, 3, 4, 5, 6})
    print(f"Universe: {{1, 2, 3, 4, 5, 6}}")
    print(f"Atom (ε): {die.atom}")
    print()

    even = {2, 4, 6}
    high = {4, 5, 6}
    prime = {2, 3, 5}

    print(f"P(even) = {die.measure(even)} = {float(die.measure(even)):.4f}")
    print(f"P(high) = {die.measure(high)} = {float(die.measure(high)):.4f}")
    print(f"P(prime) = {die.measure(prime)} = {float(die.measure(prime)):.4f}")
    print()

    # Conditional probability — the key advantage
    print("--- Conditional Probability (always well-defined!) ---")
    print(f"P(even | high) = {die.cond_prob(even, high)} = {float(die.cond_prob(even, high)):.4f}")
    print(f"P(high | even) = {die.cond_prob(high, even)} = {float(die.cond_prob(high, even)):.4f}")
    print(f"P(prime | {{3}}) = {die.cond_prob(prime, {3})}  ← Conditioning on singleton!")
    print(f"P(even | {{3}}) = {die.cond_prob(even, {3})}  ← Classical would be 0/0!")
    print()

    # Bayes' theorem
    print("--- Bayes' Theorem Verification ---")
    print(f"P(even|high)·P(high) = {die.cond_prob(even, high) * die.measure(high)}")
    print(f"P(high|even)·P(even) = {die.cond_prob(high, even) * die.measure(even)}")
    print(f"Bayes verified: {die.verify_bayes(even, high)}")
    print()

    # Independence
    print("--- Independence ---")
    print(f"even ⊥ high? {die.is_independent(even, high)}")
    print(f"even ⊥ prime? {die.is_independent(even, prime)}")


def demo_singleton_conditioning():
    """Demo 2: Conditioning on singletons — impossible in classical probability."""
    print()
    print("=" * 60)
    print("DEMO 2: Singleton Conditioning (Classical vs NAP)")
    print("=" * 60)

    space = NAPSpace(set(range(100)))
    print(f"Universe: {{0, 1, ..., 99}}")
    print(f"Atom (ε): {space.atom}")
    print()

    # In classical continuous probability, P({x}) = 0, so P(A|{x}) is undefined
    # In NAP, P({x}) = ε > 0, so P(A|{x}) is always well-defined

    even = {x for x in range(100) if x % 2 == 0}
    for singleton_val in [42, 7, 0]:
        singleton = {singleton_val}
        p_even_given_x = space.cond_prob(even, singleton)
        print(f"P(even | {{{singleton_val}}}) = {p_even_given_x}")
        print(f"  Classical: UNDEFINED (0/0)")
        print(f"  NAP:       {p_even_given_x} (well-defined!)")
        print()


def demo_ratio_stability():
    """Demo 3: Ratio stability — infinitesimals cancel."""
    print()
    print("=" * 60)
    print("DEMO 3: Ratio Stability (Infinitesimals Cancel)")
    print("=" * 60)

    # Show that for different "atom sizes" (simulating different
    # infinitesimals), conditional probabilities are the same
    for n in [6, 60, 600, 6000]:
        universe = set(range(n))
        space = NAPSpace(universe)

        # Events proportional to universe size
        a = {x for x in range(n) if x % 2 == 0}  # "even"
        b = {x for x in range(n) if x >= n * 2 // 3}  # "top third"

        cp = space.cond_prob(a, b)
        print(f"|Ω| = {n:5d}, atom = {str(space.atom):12s}, "
              f"P(A|B) = {cp} ≈ {float(cp):.6f}")

    print()
    print("→ The conditional probability is STABLE as the atom shrinks.")
    print("  In the limit ε → 0 (infinitesimal), the ratio is preserved.")


def demo_inclusion_exclusion():
    """Demo 4: Inclusion-exclusion for NAP measures."""
    print()
    print("=" * 60)
    print("DEMO 4: Inclusion-Exclusion")
    print("=" * 60)

    space = NAPSpace({1, 2, 3, 4, 5, 6, 7, 8, 9, 10})

    a = {1, 2, 3, 4, 5}
    b = {4, 5, 6, 7, 8}
    a_union_b = a | b
    a_inter_b = a & b

    mu_a = space.measure(a)
    mu_b = space.measure(b)
    mu_union = space.measure(a_union_b)
    mu_inter = space.measure(a_inter_b)

    print(f"A = {sorted(a)}")
    print(f"B = {sorted(b)}")
    print(f"A ∪ B = {sorted(a_union_b)}")
    print(f"A ∩ B = {sorted(a_inter_b)}")
    print()
    print(f"μ(A) = {mu_a}")
    print(f"μ(B) = {mu_b}")
    print(f"μ(A ∪ B) = {mu_union}")
    print(f"μ(A ∩ B) = {mu_inter}")
    print()
    print(f"μ(A) + μ(B) - μ(A ∩ B) = {mu_a + mu_b - mu_inter}")
    print(f"Inclusion-exclusion verified: {mu_union == mu_a + mu_b - mu_inter}")


def demo_complement():
    """Demo 5: Complement formula."""
    print()
    print("=" * 60)
    print("DEMO 5: Complement Formula")
    print("=" * 60)

    space = NAPSpace(set(range(1, 13)))  # months
    summer = {6, 7, 8}
    not_summer = space.universe - frozenset(summer)

    print(f"Universe: months {{1,...,12}}")
    print(f"Summer = {sorted(summer)}")
    print(f"¬Summer = {sorted(not_summer)}")
    print(f"μ(Summer) = {space.measure(summer)}")
    print(f"μ(¬Summer) = {space.measure(not_summer)}")
    print(f"μ(Summer) + μ(¬Summer) = {space.measure(summer) + space.measure(not_summer)}")
    print(f"1 - μ(Summer) = {1 - space.measure(summer)}")
    print(f"Complement formula verified: "
          f"{space.measure(not_summer) == 1 - space.measure(summer)}")


if __name__ == "__main__":
    demo_basic()
    demo_singleton_conditioning()
    demo_ratio_stability()
    demo_inclusion_exclusion()
    demo_complement()


#!/usr/bin/env python3
"""
Visualization: Ratio Stability of Non-Archimedean Conditional Probability

Shows that as the universe size grows (atom → 0, approaching infinitesimal),
the conditional probability P(A|B) remains stable — the infinitesimals cancel.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def compute_conditional_prob(n: int) -> float:
    """P(even | top_third) for universe {0, ..., n-1}."""
    even = set(x for x in range(n) if x % 2 == 0)
    top_third = set(x for x in range(n) if x >= 2 * n // 3)
    intersection = even & top_third
    if not top_third:
        return 0.0
    return len(intersection) / len(top_third)


def main():
    sizes = list(range(6, 10001, 2))
    cond_probs = [compute_conditional_prob(n) for n in sizes]
    atoms = [1.0 / n for n in sizes]

    fig, axes = plt.subplots(2, 1, figsize=(10, 8))

    # Plot 1: Conditional probability vs universe size
    ax1 = axes[0]
    ax1.plot(sizes, cond_probs, 'b-', linewidth=0.5, alpha=0.7)
    ax1.axhline(y=0.5, color='r', linestyle='--', label='Limit = 1/2')
    ax1.set_xlabel('Universe size |Ω|')
    ax1.set_ylabel('P(even | top third)')
    ax1.set_title('Ratio Stability: Conditional Probability vs Universe Size')
    ax1.legend()
    ax1.set_ylim(0.45, 0.55)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Atom size (log scale) vs conditional probability
    ax2 = axes[1]
    ax2.semilogx(atoms, cond_probs, 'g-', linewidth=0.5, alpha=0.7)
    ax2.axhline(y=0.5, color='r', linestyle='--', label='Limit = 1/2')
    ax2.set_xlabel('Atom size ε = 1/|Ω| (log scale)')
    ax2.set_ylabel('P(even | top third)')
    ax2.set_title('Conditional Probability Remains Stable as Atom → 0')
    ax2.legend()
    ax2.set_ylim(0.45, 0.55)
    ax2.grid(True, alpha=0.3)
    ax2.invert_xaxis()

    plt.tight_layout()
    plt.savefig('ratio_stability.png', dpi=150, bbox_inches='tight')
    print("Saved ratio_stability.png")


if __name__ == "__main__":
    main()
