#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from fractions import Fraction
from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple
from dataclasses import dataclass


@dataclass(frozen=True)
class SurrealProb:
    """
    Element of a non-Archimedean probability field, represented as a + b·ε + c·ε²
    where ε is infinitesimal. Ordered lexicographically on (a, b, c).
    """
    std: Fraction     # standard part
    eps1: Fraction = Fraction(0)  # coefficient of ε
    eps2: Fraction = Fraction(0)  # coefficient of ε²

    def __add__(self, other: 'SurrealProb') -> 'SurrealProb':
        return SurrealProb(self.std + other.std,
                           self.eps1 + other.eps1,
                           self.eps2 + other.eps2)

    def __sub__(self, other: 'SurrealProb') -> 'SurrealProb':
        return SurrealProb(self.std - other.std,
                           self.eps1 - other.eps1,
                           self.eps2 - other.eps2)

    def __mul__(self, other: 'SurrealProb') -> 'SurrealProb':
        return SurrealProb(
            self.std * other.std,
            self.std * other.eps1 + self.eps1 * other.std,
            self.std * other.eps2 + self.eps1 * other.eps1 + self.eps2 * other.std
        )

    def __truediv__(self, other: 'SurrealProb') -> 'SurrealProb':
        if other.std == 0:
            raise ZeroDivisionError("Cannot divide by element with zero standard part")
        a, b, c = self.std, self.eps1, self.eps2
        d, e, f = other.std, other.eps1, other.eps2
        q0 = a / d
        q1 = (b - q0 * e) / d
        q2 = (c - q0 * f - q1 * e) / d
        return SurrealProb(q0, q1, q2)

    def __lt__(self, other: 'SurrealProb') -> bool:
        if self.std != other.std: return self.std < other.std
        if self.eps1 != other.eps1: return self.eps1 < other.eps1
        return self.eps2 < other.eps2

    def __le__(self, other: 'SurrealProb') -> bool:
        return self == other or self < other

    def __repr__(self) -> str:
        parts = []
        if self.std != 0: parts.append(str(self.std))
        if self.eps1 != 0: parts.append(f"{self.eps1}ε")
        if self.eps2 != 0: parts.append(f"{self.eps2}ε²")
        return " + ".join(parts) if parts else "0"

    def is_positive(self) -> bool:
        return SurrealProb(Fraction(0)) < self

    def is_infinitesimal(self) -> bool:
        return self.std == 0 and self.is_positive()

    @staticmethod
    def zero() -> 'SurrealProb':
        return SurrealProb(Fraction(0))

    @staticmethod
    def one() -> 'SurrealProb':
        return SurrealProb(Fraction(1))

    @staticmethod
    def epsilon() -> 'SurrealProb':
        return SurrealProb(Fraction(0), Fraction(1))


@dataclass
class NonArchProbSpace:
    """
    A finitely additive probability space with surreal-valued weights.

    Algorithm: Store weights as a dictionary outcome → SurrealProb.
    Probability of an event is computed by summing weights.
    All operations are O(|event|) time.
    """
    outcomes: List[str]
    weights: Dict[str, SurrealProb]

    def __post_init__(self) -> None:
        total = SurrealProb.zero()
        for w in self.weights.values():
            total = total + w
        if total != SurrealProb.one():
            raise ValueError(f"Weights sum to {total}, not 1")

    def prob(self, event: Set[str]) -> SurrealProb:
        """Compute P(A) = ∑_{x ∈ A} w(x). O(|A|) time."""
        result = SurrealProb.zero()
        for x in event:
            if x in self.weights:
                result = result + self.weights[x]
        return result

    def cond_prob(self, A: Set[str], B: Set[str]) -> SurrealProb:
        """Compute P(A|B) = P(A∩B) / P(B). Requires P(B) ≠ 0."""
        return self.prob(A & B) / self.prob(B)

    def is_regular(self) -> bool:
        """Check if every singleton has positive probability."""
        return all(w.is_positive() for w in self.weights.values())

    def are_independent(self, A: Set[str], B: Set[str]) -> bool:
        """Check if P(A∩B) = P(A)·P(B)."""
        return self.prob(A & B) == self.prob(A) * self.prob(B)

    def expected_value(self, X: Callable[[str], SurrealProb]) -> SurrealProb:
        """Compute E[X] = ∑ w(x) · X(x)."""
        result = SurrealProb.zero()
        for x in self.outcomes:
            result = result + self.weights[x] * X(x)
        return result

    def markov_bound(self, X: Callable[[str], SurrealProb], a: SurrealProb) -> SurrealProb:
        """Compute E[X]/a (the Markov upper bound on P(X ≥ a))."""
        return self.expected_value(X) / a


def build_uniform_space(outcomes: List[str]) -> NonArchProbSpace:
    """
    Algorithm: Uniform Distribution
    Input: List of n outcomes
    Output: NonArchProbSpace with weight 1/n for each outcome
    Time: O(n)
    """
    n = len(outcomes)
    w = SurrealProb(Fraction(1, n))
    return NonArchProbSpace(outcomes, {x: w for x in outcomes})


def build_infinitesimal_perturbed_space(
    outcomes: List[str],
    base_weights: Dict[str, Fraction],
    perturbations: Dict[str, Fraction]
) -> NonArchProbSpace:
    """
    Algorithm: Infinitesimal Perturbation
    Input: Base weights (rational) and infinitesimal perturbations
    Output: NonArchProbSpace where w(x) = base(x) + perturbation(x)·ε
    Constraint: ∑ base = 1 and ∑ perturbation = 0

    This is the key algorithm for non-Archimedean probability:
    it allows breaking ties between events with equal standard probability
    using infinitesimal corrections.
    """
    weights = {}
    for x in outcomes:
        b = base_weights.get(x, Fraction(0))
        p = perturbations.get(x, Fraction(0))
        weights[x] = SurrealProb(b, p)
    return NonArchProbSpace(outcomes, weights)


def pigeonhole_witnesses(space: NonArchProbSpace) -> Tuple[str, str]:
    """
    Algorithm: Find Pigeonhole Witnesses
    Returns (x_min, x_max) where:
    - w(x_min) ≤ 1/n (exists by pigeonhole upper bound)
    - w(x_max) ≥ 1/n (exists by pigeonhole lower bound)
    """
    n = len(space.outcomes)
    threshold = SurrealProb(Fraction(1, n))

    x_min = min(space.outcomes, key=lambda x: space.weights[x])
    x_max = max(space.outcomes, key=lambda x: space.weights[x])

    assert space.weights[x_min] <= threshold, "Pigeonhole upper bound failed"
    assert threshold <= space.weights[x_max], "Pigeonhole lower bound failed"

    return x_min, x_max


def verify_bayes(space: NonArchProbSpace, A: Set[str], B: Set[str]) -> bool:
    """
    Algorithm: Verify Bayes' Theorem
    Check: P(A|B)·P(B) = P(B|A)·P(A)
    Returns True iff the identity holds.
    """
    pA = space.prob(A)
    pB = space.prob(B)
    if pA == SurrealProb.zero() or pB == SurrealProb.zero():
        return True  # vacuously true
    lhs = space.cond_prob(A, B) * pB
    rhs = space.cond_prob(B, A) * pA
    return lhs == rhs


if __name__ == "__main__":
    # Quick self-test
    space = build_uniform_space(["a", "b", "c", "d"])
    assert space.prob({"a", "b"}) == SurrealProb(Fraction(1, 2))
    assert space.is_regular()

    x_min, x_max = pigeonhole_witnesses(space)
    print(f"Pigeonhole: min={x_min}, max={x_max}")

    # Infinitesimal perturbation
    perturbed = build_infinitesimal_perturbed_space(
        ["a", "b", "c"],
        {"a": Fraction(1, 3), "b": Fraction(1, 3), "c": Fraction(1, 3)},
        {"a": Fraction(1), "b": Fraction(-1, 2), "c": Fraction(-1, 2)}
    )
    print(f"Perturbed P({{a}}) = {perturbed.prob({'a'})}")
    print(f"Perturbed P({{b}}) = {perturbed.prob({'b'})}")

    assert verify_bayes(perturbed, {"a"}, {"a", "b"})
    print("All self-tests passed.")
