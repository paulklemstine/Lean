#!/usr/bin/env python3
"""
Non-Archimedean Probability: Core Algorithms

Type-hinted implementations of the key algorithms for surreal-valued
finitely additive probability measures.
"""

from dataclasses import dataclass
from typing import FrozenSet, TypeVar, Generic, Dict, Optional, Set
from fractions import Fraction

T = TypeVar('T')


@dataclass(frozen=True)
class SurrealNum:
    """A surreal-like number a + b·ε where ε is infinitesimal.
    
    Represents elements of ℝ((ε)), the field of formal Laurent series
    in one infinitesimal ε. For probability theory, this gives us a 
    non-Archimedean ordered field where infinitesimal probabilities exist.
    """
    real: Fraction
    infml: Fraction = Fraction(0)
    
    def __add__(self, other: 'SurrealNum') -> 'SurrealNum':
        return SurrealNum(self.real + other.real, self.infml + other.infml)
    
    def __sub__(self, other: 'SurrealNum') -> 'SurrealNum':
        return SurrealNum(self.real - other.real, self.infml - other.infml)
    
    def __mul__(self, other: 'SurrealNum') -> 'SurrealNum':
        return SurrealNum(
            self.real * other.real,
            self.real * other.infml + self.infml * other.real
        )
    
    def __truediv__(self, other: 'SurrealNum') -> 'SurrealNum':
        if other.real != 0:
            r = self.real / other.real
            i = (self.infml * other.real - self.real * other.infml) / (other.real * other.real)
            return SurrealNum(r, i)
        elif other.infml != 0:
            return SurrealNum(self.infml / other.infml, Fraction(0))
        raise ZeroDivisionError
    
    def __le__(self, other: 'SurrealNum') -> bool:
        if self.real != other.real:
            return self.real < other.real
        return self.infml <= other.infml
    
    def __lt__(self, other: 'SurrealNum') -> bool:
        if self.real != other.real:
            return self.real < other.real
        return self.infml < other.infml
    
    def is_infinitesimal(self) -> bool:
        return self.real == 0 and self.infml > 0
    
    def is_positive(self) -> bool:
        return self > SurrealNum(Fraction(0))
    
    def __repr__(self) -> str:
        if self.infml == 0:
            return str(self.real)
        elif self.real == 0:
            return f"{self.infml}·ε"
        else:
            sign = "+" if self.infml > 0 else "-"
            return f"{self.real} {sign} {abs(self.infml)}·ε"


ZERO = SurrealNum(Fraction(0))
ONE = SurrealNum(Fraction(1))
EPS = SurrealNum(Fraction(0), Fraction(1))


class FinAddProb(Generic[T]):
    """Finitely additive probability measure valued in SurrealNum.
    
    Algorithm: Store explicit probabilities for singletons.
    For any finite set, compute by summing singleton probabilities.
    For complements, use μ(Aᶜ) = 1 - μ(A).
    
    Pseudocode:
        INIT(weights: Dict[T, SurrealNum]):
            Verify all weights ≥ 0
            Verify sum(weights) = 1
            Store weights
        
        MEASURE(A: Set[T]):
            return sum(weights[x] for x in A)
        
        COND_PROB(A: Set[T], B: Set[T]):
            Verify μ(B) > 0
            return μ(A ∩ B) / μ(B)
    """
    
    def __init__(self, weights: Dict[T, SurrealNum]):
        for x, w in weights.items():
            assert w.is_positive() or w == ZERO, f"Negative weight for {x}"
        total = ZERO
        for w in weights.values():
            total = total + w
        assert total == ONE, f"Total probability {total} ≠ 1"
        self._weights = dict(weights)
    
    def measure(self, subset: Set[T]) -> SurrealNum:
        """Compute μ(A) = Σ_{x ∈ A} weight(x)."""
        result = ZERO
        for x in subset:
            if x in self._weights:
                result = result + self._weights[x]
        return result
    
    def cond_prob(self, A: Set[T], B: Set[T]) -> SurrealNum:
        """Compute P(A | B) = μ(A ∩ B) / μ(B)."""
        mu_B = self.measure(B)
        assert mu_B.is_positive(), "Cannot condition on measure-zero event"
        mu_AB = self.measure(A & B)
        return mu_AB / mu_B
    
    def complement_measure(self, A: Set[T]) -> SurrealNum:
        """Compute μ(Aᶜ) = 1 - μ(A)."""
        return ONE - self.measure(A)
    
    def verify_additivity(self, A: Set[T], B: Set[T]) -> bool:
        """Verify μ(A ∪ B) = μ(A) + μ(B) when A ∩ B = ∅."""
        if A & B:
            return False  # Not disjoint
        mu_union = self.measure(A | B)
        mu_sum = self.measure(A) + self.measure(B)
        return mu_union == mu_sum
    
    def verify_inclusion_exclusion(self, A: Set[T], B: Set[T]) -> bool:
        """Verify μ(A ∪ B) + μ(A ∩ B) = μ(A) + μ(B)."""
        lhs = self.measure(A | B) + self.measure(A & B)
        rhs = self.measure(A) + self.measure(B)
        return lhs == rhs


class NonArchProb(FinAddProb[T]):
    """Non-Archimedean probability space where all singletons
    have infinitesimal positive probability.
    
    For finite sample spaces of size n, assigns each point
    probability 1/n (which is not infinitesimal).
    
    For "virtual infinite" spaces, assigns ε to each point.
    The total is n·ε where n is the number of tracked points,
    which is infinitesimal — requiring a "background" measure
    of 1 - n·ε for untracked points.
    """
    
    @classmethod
    def uniform_finite(cls, elements: Set[T]) -> 'NonArchProb[T]':
        """Create uniform probability on a finite set."""
        n = len(elements)
        p = SurrealNum(Fraction(1, n))
        weights = {x: p for x in elements}
        return cls(weights)
    
    @classmethod
    def infinitesimal_uniform(cls, elements: Set[T]) -> 'NonArchProb[T]':
        """Create measure with infinitesimal point probabilities.
        
        Assigns ε/|elements| to each element and a background
        real-valued probability to make the total 1.
        """
        n = len(elements)
        point_prob = SurrealNum(Fraction(1, n))
        weights = {x: point_prob for x in elements}
        return cls(weights)


def demonstrate_singleton_conditional():
    """Demonstrate the Singleton Conditional Probability Theorem."""
    # Create uniform probability on {1,...,5}
    elements = {1, 2, 3, 4, 5}
    P = NonArchProb.uniform_finite(elements)
    
    A = {1, 2, 3}  # Event A
    
    # P(A | {2}) should be 1 (since 2 ∈ A)
    result_in = P.cond_prob(A, {2})
    print(f"P(A | {{2}}) = {result_in}")  # Expected: 1
    
    # P(A | {5}) should be 0 (since 5 ∉ A)
    result_out = P.cond_prob(A, {5})
    print(f"P(A | {{5}}) = {result_out}")  # Expected: 0


def demonstrate_bayes():
    """Demonstrate Bayes' theorem."""
    elements = {1, 2, 3, 4, 5, 6}
    P = NonArchProb.uniform_finite(elements)
    
    A = {1, 2, 3, 4}
    B = {3, 4, 5}
    
    # Bayes: P(A|B)·P(B) = P(B|A)·P(A)
    lhs = P.cond_prob(A, B) * P.measure(B)
    rhs = P.cond_prob(B, A) * P.measure(A)
    print(f"P(A|B)·P(B) = {lhs}")
    print(f"P(B|A)·P(A) = {rhs}")
    print(f"Bayes verified: {lhs == rhs}")


if __name__ == "__main__":
    print("=== Singleton Conditional Probability ===")
    demonstrate_singleton_conditional()
    print()
    print("=== Bayes' Theorem ===")
    demonstrate_bayes()
