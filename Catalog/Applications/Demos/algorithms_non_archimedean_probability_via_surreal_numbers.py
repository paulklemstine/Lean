#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Spaces

Type-hinted implementations of the core mathematical constructions
from our formalization.
"""

from fractions import Fraction
from typing import Callable, Dict, FrozenSet, Generic, List, Optional, Set, TypeVar

T = TypeVar('T')


class NAProbSpace(Generic[T]):
    """A Non-Archimedean Probability Space over a finite sample space.

    Probability values are represented as Fraction for exact arithmetic,
    modeling an ordered field. All point probabilities are strictly positive
    (the regularity axiom), and the total probability is exactly 1.

    Attributes:
        omega: The sample space as a frozenset.
        prob: A dictionary mapping each outcome to its probability.
    """

    def __init__(self, prob: Dict[T, Fraction]) -> None:
        """Initialize a NAProbSpace from a probability mass function.

        Args:
            prob: Dict mapping each outcome to its (positive) probability.

        Raises:
            ValueError: If probabilities are not positive or don't sum to 1.
        """
        if not prob:
            raise ValueError("Sample space must be nonempty")
        for omega, p in prob.items():
            if p <= 0:
                raise ValueError(f"Probability of {omega} is {p} ≤ 0 (regularity violated)")
        total = sum(prob.values())
        if total != Fraction(1):
            raise ValueError(f"Total probability is {total}, not 1")
        self.omega: FrozenSet[T] = frozenset(prob.keys())
        self.prob: Dict[T, Fraction] = dict(prob)

    @classmethod
    def uniform(cls, elements: Set[T]) -> 'NAProbSpace[T]':
        """Create a uniform NAProbSpace where each element has equal probability.

        Args:
            elements: The sample space.

        Returns:
            A uniform NAProbSpace.
        """
        n = len(elements)
        if n == 0:
            raise ValueError("Sample space must be nonempty")
        p = Fraction(1, n)
        return cls({e: p for e in elements})

    def event_prob(self, event: Set[T]) -> Fraction:
        """Compute the probability of an event (subset of Ω).

        P(A) = Σ_{ω ∈ A} P({ω})

        Args:
            event: A subset of the sample space.

        Returns:
            The probability of the event.
        """
        return sum(self.prob[omega] for omega in event if omega in self.prob)

    def cond_prob(self, a: Set[T], b: Set[T]) -> Fraction:
        """Compute conditional probability P(A | B).

        P(A | B) = P(A ∩ B) / P(B)

        In NAProbSpace, this is always well-defined for nonempty B
        because regularity guarantees P(B) > 0.

        Args:
            a: The event to condition.
            b: The conditioning event (must be nonempty).

        Returns:
            The conditional probability P(A | B).

        Raises:
            ValueError: If B is empty.
        """
        if not b:
            raise ValueError("Cannot condition on empty event")
        pb = self.event_prob(b)
        if pb == 0:
            raise ValueError("Conditioning event has zero probability")
        return self.event_prob(a & b) / pb

    def is_independent(self, a: Set[T], b: Set[T]) -> bool:
        """Check if events A and B are independent.

        A and B are independent iff P(A ∩ B) = P(A) · P(B).

        Args:
            a: First event.
            b: Second event.

        Returns:
            True if A and B are independent.
        """
        return self.event_prob(a & b) == self.event_prob(a) * self.event_prob(b)

    def bayes_verify(self, a: Set[T], b: Set[T]) -> bool:
        """Verify Bayes' theorem: P(A|B)·P(B) = P(B|A)·P(A).

        Args:
            a: First event (nonempty).
            b: Second event (nonempty).

        Returns:
            True if Bayes' theorem holds (always True for NAProbSpace).
        """
        if not a or not b:
            return True  # Vacuously true
        lhs = self.cond_prob(a, b) * self.event_prob(b)
        rhs = self.cond_prob(b, a) * self.event_prob(a)
        return lhs == rhs

    def total_probability_verify(self, a: Set[T], b: Set[T]) -> bool:
        """Verify the Law of Total Probability.

        P(A) = P(A|B)·P(B) + P(A|Bᶜ)·P(Bᶜ)

        Args:
            a: The event.
            b: The partitioning event (neither empty nor full).

        Returns:
            True if the law holds (always True for NAProbSpace).
        """
        if not b or b == self.omega:
            return True
        bc = self.omega - b
        lhs = self.event_prob(a)
        rhs = (self.cond_prob(a, b) * self.event_prob(b) +
               self.cond_prob(a, bc) * self.event_prob(bc))
        return lhs == rhs

    def pushforward(self, f: Callable[[T], T], codomain: Set[T]) -> 'NAProbSpace[T]':
        """Compute the pushforward measure along f.

        (f_*μ)(ω') = Σ_{ω : f(ω) = ω'} μ(ω)

        Args:
            f: A function from Ω to Ω'.
            codomain: The codomain (must equal the range of f).

        Returns:
            The pushforward NAProbSpace.
        """
        new_prob: Dict[T, Fraction] = {}
        for omega_prime in codomain:
            new_prob[omega_prime] = sum(
                self.prob[omega] for omega in self.omega if f(omega) == omega_prime
            )
        return NAProbSpace(new_prob)


def is_infinitesimal(x: Fraction, bound: int = 1000) -> bool:
    """Check if a fraction is 'infinitesimal-like' (smaller than 1/n for all n ≤ bound).

    In exact arithmetic with Fraction, true infinitesimals don't exist in ℚ.
    This function checks if x < 1/n for all positive n up to bound.

    Args:
        x: The value to check.
        bound: Check against 1/n for n = 1, ..., bound.

    Returns:
        True if x is positive and smaller than 1/n for all tested n.
    """
    if x <= 0:
        return False
    return all(x < Fraction(1, n) for n in range(1, bound + 1))


def construct_uniform_naprobspace(n: int) -> NAProbSpace[int]:
    """Construct a uniform NAProbSpace on {0, 1, ..., n-1}.

    Args:
        n: Size of the sample space.

    Returns:
        A uniform NAProbSpace.
    """
    return NAProbSpace.uniform(set(range(n)))


def inclusion_exclusion(
    mu: NAProbSpace[T], a: Set[T], b: Set[T]
) -> Dict[str, Fraction]:
    """Compute all terms of the inclusion-exclusion formula.

    Returns:
        Dict with P(A), P(B), P(A∩B), P(A∪B), and verification.
    """
    pa = mu.event_prob(a)
    pb = mu.event_prob(b)
    pab = mu.event_prob(a & b)
    paub = mu.event_prob(a | b)
    ie = pa + pb - pab

    return {
        "P(A)": pa,
        "P(B)": pb,
        "P(A∩B)": pab,
        "P(A∪B)": paub,
        "P(A)+P(B)-P(A∩B)": ie,
        "verified": paub == ie,
    }


if __name__ == "__main__":
    # Quick test
    mu = NAProbSpace.uniform({1, 2, 3, 4, 5, 6})
    print("Uniform die:")
    print(f"  P({{1,2,3}}) = {mu.event_prob({1, 2, 3})}")
    print(f"  P({{1}}|{{1,2,3}}) = {mu.cond_prob({1}, {1, 2, 3})}")
    print(f"  Bayes verified: {mu.bayes_verify({1, 2}, {2, 3, 4})}")
    print(f"  Total prob verified: {mu.total_probability_verify({1, 2, 3}, {2, 3, 4, 5})}")

    # Large space
    N = 10000
    mu_large = construct_uniform_naprobspace(N)
    print(f"\nUniform on {{0,...,{N-1}}}:")
    print(f"  P({{0}}) = {mu_large.prob[0]} = {float(mu_large.prob[0]):.2e}")
    print(f"  'Infinitesimal-like' (< 1/n for n ≤ 100): {is_infinitesimal(mu_large.prob[0], 100)}")
