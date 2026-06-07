#!/usr/bin/env python3
"""
Non-Archimedean Probability: Core Algorithms

Type-hinted implementations of the key constructions from the formalization.
"""

from typing import Dict, List, Tuple, Optional, TypeVar, Generic, Callable
from dataclasses import dataclass
from fractions import Fraction
import math

T = TypeVar('T')


@dataclass
class InfinitesimalNumber:
    """
    Represents a number of the form a + b·ε + c·ε² where ε is infinitesimal.
    Truncated at second order for practical computation.

    In the surreal number field, ε = 1/ω where ω is the first infinite ordinal.
    """
    standard: Fraction  # The standard (real) part
    first_order: Fraction  # Coefficient of ε
    second_order: Fraction  # Coefficient of ε²

    @staticmethod
    def from_standard(x: Fraction) -> 'InfinitesimalNumber':
        """Create a standard (non-infinitesimal) number."""
        return InfinitesimalNumber(x, Fraction(0), Fraction(0))

    @staticmethod
    def epsilon() -> 'InfinitesimalNumber':
        """The canonical infinitesimal ε."""
        return InfinitesimalNumber(Fraction(0), Fraction(1), Fraction(0))

    def __add__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        return InfinitesimalNumber(
            self.standard + other.standard,
            self.first_order + other.first_order,
            self.second_order + other.second_order
        )

    def __sub__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        return InfinitesimalNumber(
            self.standard - other.standard,
            self.first_order - other.first_order,
            self.second_order - other.second_order
        )

    def __mul__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        return InfinitesimalNumber(
            self.standard * other.standard,
            self.standard * other.first_order + self.first_order * other.standard,
            self.standard * other.second_order + self.first_order * other.first_order
            + self.second_order * other.standard
        )

    def __truediv__(self, other: 'InfinitesimalNumber') -> 'InfinitesimalNumber':
        if other.standard == 0:
            if other.first_order == 0:
                raise ZeroDivisionError("Division by zero")
            # Dividing by bε: result has 1/ε terms (infinite)
            raise ValueError("Division by pure infinitesimal yields infinite result")
        inv_std = Fraction(1) / other.standard
        # (a + bε + cε²) / (d + eε + fε²)
        # = (a/d) + ((b·d - a·e)/d²)ε + higher order
        a, b, c = self.standard, self.first_order, self.second_order
        d, e, f = other.standard, other.first_order, other.second_order
        std = a * inv_std
        fo = (b * d - a * e) / (d * d)
        so = (c * d * d - b * d * e - a * d * f + a * e * e) / (d * d * d)
        return InfinitesimalNumber(std, fo, so)

    def is_positive(self) -> bool:
        if self.standard > 0:
            return True
        if self.standard == 0 and self.first_order > 0:
            return True
        if self.standard == 0 and self.first_order == 0:
            return self.second_order > 0
        return False

    def is_infinitesimal(self) -> bool:
        return self.standard == 0 and self.is_positive()

    def __repr__(self) -> str:
        parts = []
        if self.standard != 0:
            parts.append(str(self.standard))
        if self.first_order != 0:
            parts.append(f"{self.first_order}ε")
        if self.second_order != 0:
            parts.append(f"{self.second_order}ε²")
        return " + ".join(parts) if parts else "0"


class InfProbSpace(Generic[T]):
    """
    An infinitesimal probability space over a finite sample space.

    Implements the InfProbSpace structure from the Lean formalization:
    - prob : Ω → F (probability mass function)
    - prob_nonneg : ∀ x, 0 ≤ prob x
    - prob_total : ∑ x, prob x = 1

    Algorithm: Direct construction with validation.
    Time complexity: O(|Ω|) for construction, O(|A|) for event probability.
    """

    def __init__(self, outcomes: List[T], probs: List[InfinitesimalNumber]):
        """
        Construct a probability space.

        Preconditions (checked):
        1. len(outcomes) == len(probs)
        2. All probabilities are non-negative
        3. Probabilities sum to 1
        """
        if len(outcomes) != len(probs):
            raise ValueError("Outcomes and probabilities must have equal length")

        for i, p in enumerate(probs):
            if not (p.is_positive() or p == InfinitesimalNumber.from_standard(Fraction(0))):
                raise ValueError(f"Probability {i} is negative: {p}")

        total = InfinitesimalNumber.from_standard(Fraction(0))
        for p in probs:
            total = total + p
        if total.standard != Fraction(1) or total.first_order != Fraction(0):
            raise ValueError(f"Probabilities sum to {total}, not 1")

        self._outcomes = outcomes
        self._probs = {o: p for o, p in zip(outcomes, probs)}

    def prob(self, x: T) -> InfinitesimalNumber:
        """Return the probability of outcome x."""
        return self._probs.get(x, InfinitesimalNumber.from_standard(Fraction(0)))

    def event_prob(self, event: List[T]) -> InfinitesimalNumber:
        """
        Compute P(A) = ∑_{x ∈ A} prob(x).

        Corresponds to InfProbSpace.eventProb in the formalization.
        """
        result = InfinitesimalNumber.from_standard(Fraction(0))
        for x in event:
            result = result + self.prob(x)
        return result

    def cond_prob(self, a: List[T], b: List[T]) -> InfinitesimalNumber:
        """
        Compute P(A|B) = P(A∩B) / P(B).

        Precondition: P(B) > 0 (guaranteed by full support for non-empty B).
        Corresponds to InfProbSpace.condProb in the formalization.
        """
        b_set = set(b)
        intersection = [x for x in a if x in b_set]
        return self.event_prob(intersection) / self.event_prob(b)

    def is_full_support(self) -> bool:
        """Check if every outcome has strictly positive probability."""
        return all(p.is_positive() for p in self._probs.values())

    def has_infinitesimal_support(self) -> bool:
        """Check if every outcome has infinitesimal probability."""
        return all(p.is_infinitesimal() for p in self._probs.values())

    @staticmethod
    def uniform(n: int, field: str = "rational") -> 'InfProbSpace[int]':
        """
        Construct the uniform probability space on {0, 1, ..., n-1}.

        Corresponds to InfProbSpace.uniform in the formalization.
        """
        if n <= 0:
            raise ValueError("Need at least 1 outcome")
        p = InfinitesimalNumber.from_standard(Fraction(1, n))
        return InfProbSpace(list(range(n)), [p] * n)

    @staticmethod
    def mixture(
        mu: 'InfProbSpace[T]',
        nu: 'InfProbSpace[T]',
        t: Fraction
    ) -> 'InfProbSpace[T]':
        """
        Construct the mixture t·μ + (1-t)·ν.

        Precondition: 0 ≤ t ≤ 1.
        Corresponds to InfProbSpace.mixture in the formalization.
        """
        t_inf = InfinitesimalNumber.from_standard(t)
        one_minus_t = InfinitesimalNumber.from_standard(Fraction(1) - t)
        outcomes = mu._outcomes
        probs = [t_inf * mu.prob(x) + one_minus_t * nu.prob(x) for x in outcomes]
        return InfProbSpace(outcomes, probs)

    @staticmethod
    def product(
        mu: 'InfProbSpace[T]',
        nu: 'InfProbSpace'
    ) -> 'InfProbSpace[Tuple]':
        """
        Construct the product probability space μ ⊗ ν.

        Corresponds to InfProbSpace.product in the formalization.
        """
        outcomes = [(x, y) for x in mu._outcomes for y in nu._outcomes]
        probs = [mu.prob(x) * nu.prob(y) for x in mu._outcomes for y in nu._outcomes]
        return InfProbSpace(outcomes, probs)


def verify_bayes_theorem(
    space: InfProbSpace[T],
    a: List[T],
    b: List[T]
) -> Tuple[InfinitesimalNumber, InfinitesimalNumber, bool]:
    """
    Verify Bayes' theorem: P(A|B)·P(B) = P(B|A)·P(A).

    Returns (LHS, RHS, are_equal).
    Corresponds to InfProbSpace.bayes_theorem in the formalization.
    """
    pa = space.event_prob(a)
    pb = space.event_prob(b)
    pab = space.cond_prob(a, b)
    pba = space.cond_prob(b, a)

    lhs = pab * pb
    rhs = pba * pa

    equal = (lhs.standard == rhs.standard and
             lhs.first_order == rhs.first_order)
    return lhs, rhs, equal


def archimedean_witness(eps: Fraction) -> int:
    """
    Given ε > 0, find the smallest n such that n·ε ≥ 1.
    This witnesses the Archimedean property and proves ε is not infinitesimal.

    Corresponds to InfProbSpace.archimedean_no_infinitesimal in the formalization.
    """
    if eps <= 0:
        raise ValueError("Need ε > 0")
    n = 1
    while Fraction(n) * eps < 1:
        n += 1
    return n


# ============================================================
# Main: Run demonstrations
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Uniform space
    print("1. Uniform probability on 5 points:")
    u5 = InfProbSpace.uniform(5)
    print(f"   P(0) = {u5.prob(0)}")
    print(f"   P({{0,1,2}}) = {u5.event_prob([0,1,2])}")
    print(f"   Full support: {u5.is_full_support()}")

    # 2. Bayes verification
    print("\n2. Bayes' theorem verification:")
    lhs, rhs, eq = verify_bayes_theorem(u5, [0, 1], [1, 2, 3])
    print(f"   A = {{0,1}}, B = {{1,2,3}}")
    print(f"   P(A|B)·P(B) = {lhs}")
    print(f"   P(B|A)·P(A) = {rhs}")
    print(f"   Equal: {eq}")

    # 3. Archimedean witness
    print("\n3. Archimedean witnesses:")
    for eps in [Fraction(1, 10), Fraction(1, 1000), Fraction(1, 1000000)]:
        n = archimedean_witness(eps)
        print(f"   ε = {eps}: n = {n}, nε = {Fraction(n) * eps}")

    # 4. Mixture
    print("\n4. Mixture of distributions:")
    fair = InfProbSpace.uniform(2)
    biased = InfProbSpace(
        [0, 1],
        [InfinitesimalNumber.from_standard(Fraction(3, 4)),
         InfinitesimalNumber.from_standard(Fraction(1, 4))]
    )
    mix = InfProbSpace.mixture(fair, biased, Fraction(1, 2))
    print(f"   Fair: P(0) = {fair.prob(0)}")
    print(f"   Biased: P(0) = {biased.prob(0)}")
    print(f"   50-50 mixture: P(0) = {mix.prob(0)}")

    # 5. Product space
    print("\n5. Product space:")
    coin = InfProbSpace.uniform(2)
    dice = InfProbSpace.uniform(6)
    prod = InfProbSpace.product(coin, dice)
    print(f"   Coin × Dice: P((0,0)) = {prod.prob((0, 0))}")
    print(f"   P(heads, even) = {prod.event_prob([(0, i) for i in range(0, 6, 2)])}")
