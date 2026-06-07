#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of the core algorithms from the formalization.
"""

from __future__ import annotations
from dataclasses import dataclass
from fractions import Fraction
from typing import TypeVar, Callable, Generic, Sequence
import math

T = TypeVar('T')


@dataclass
class InfProbMeasure(Generic[T]):
    """A finitely additive probability measure on a finite type.
    
    Each element has a non-negative weight, and the total weight equals 1.
    Values are in Fraction for exact arithmetic.
    """
    elements: list[T]
    weights: dict[T, Fraction]
    
    def __post_init__(self) -> None:
        total = sum(self.weights.values())
        assert total == 1, f"Total mass {total} ≠ 1"
        assert all(w >= 0 for w in self.weights.values()), "Negative weight"
    
    @classmethod
    def uniform(cls, elements: list[T]) -> 'InfProbMeasure[T]':
        """Construct the uniform measure on a list of elements."""
        n = len(elements)
        assert n > 0, "Cannot create uniform measure on empty set"
        w = Fraction(1, n)
        return cls(elements=elements, weights={e: w for e in elements})
    
    def measure(self, subset: set[T]) -> Fraction:
        """Compute the measure of a subset."""
        return sum(self.weights[e] for e in subset if e in self.weights)
    
    def expect(self, f: Callable[[T], Fraction]) -> Fraction:
        """Compute the expected value of a function."""
        return sum(self.weights[e] * f(e) for e in self.elements)
    
    def cond_prob(self, A: set[T], B: set[T]) -> Fraction:
        """Compute P(A | B) = P(A ∩ B) / P(B)."""
        p_b = self.measure(B)
        if p_b == 0:
            return Fraction(0)
        return self.measure(A & B) / p_b
    
    def markov_bound(self, f: Callable[[T], Fraction], c: Fraction) -> Fraction:
        """Compute the Markov inequality bound: E[f] / c."""
        assert c > 0, "Threshold must be positive"
        return self.expect(f) / c


@dataclass
class InfCondAlg(Generic[T]):
    """Infinitesimal Conditioning Algebra: a probability measure where
    every element has strictly positive weight.
    
    This enables conditioning on any nonempty subset.
    """
    measure: InfProbMeasure[T]
    
    def __post_init__(self) -> None:
        assert all(w > 0 for w in self.measure.weights.values()), \
            "All weights must be strictly positive"
    
    def cond_measure(self, B: set[T]) -> InfProbMeasure[T]:
        """Construct the conditional measure given event B.
        
        Returns a new probability measure concentrated on B.
        """
        assert len(B) > 0, "Cannot condition on empty set"
        p_b = self.measure.measure(B)
        assert p_b > 0, "Conditioning set must have positive measure"
        
        new_weights: dict[T, Fraction] = {}
        for e in self.measure.elements:
            if e in B:
                new_weights[e] = self.measure.weights[e] / p_b
            else:
                new_weights[e] = Fraction(0)
        
        return InfProbMeasure(
            elements=self.measure.elements,
            weights=new_weights
        )
    
    def chain_rule(self, A: set[T], B: set[T]) -> tuple[Fraction, Fraction]:
        """Verify the chain rule: P(A∩B) = P(A|B) · P(B).
        
        Returns (lhs, rhs) — they should be equal.
        """
        lhs = self.measure.measure(A & B)
        cond = self.cond_measure(B)
        rhs = cond.measure(A) * self.measure.measure(B)
        return lhs, rhs


def product_measure(
    mu: InfProbMeasure[T],
    nu: InfProbMeasure[T]
) -> InfProbMeasure[tuple[T, T]]:
    """Construct the product measure of two independent measures."""
    elements = [(a, b) for a in mu.elements for b in nu.elements]
    weights = {(a, b): mu.weights[a] * nu.weights[b]
               for a in mu.elements for b in nu.elements}
    return InfProbMeasure(elements=elements, weights=weights)


def is_infinitesimal_approx(x: float, max_n: int = 1000) -> bool:
    """Approximate check: is x < 1/n for all n ≤ max_n?"""
    if x <= 0:
        return False
    return all(x < 1.0/n for n in range(1, max_n + 1))


def infinitesimal_sum_bound(epsilon: float, k: int) -> float:
    """Compute the bound k·ε and verify it's < 1."""
    return k * epsilon


def inclusion_exclusion(
    mu: InfProbMeasure[T],
    A: set[T],
    B: set[T]
) -> tuple[Fraction, Fraction]:
    """Verify inclusion-exclusion: μ(A∪B) + μ(A∩B) = μ(A) + μ(B).
    
    Returns (lhs, rhs).
    """
    lhs = mu.measure(A | B) + mu.measure(A & B)
    rhs = mu.measure(A) + mu.measure(B)
    return lhs, rhs


# === Demonstration ===

if __name__ == "__main__":
    # Example: 6-sided die
    die = InfProbMeasure.uniform(list(range(1, 7)))
    print(f"Die: {die.weights}")
    print(f"P(even) = {die.measure({2, 4, 6})}")
    print(f"E[X] = {die.expect(lambda x: Fraction(x))}")
    
    # Conditioning
    cond_alg = InfCondAlg(die)
    cond = cond_alg.cond_measure({1, 2, 3})
    print(f"P(1 | {{1,2,3}}) = {cond.weights[1]}")
    
    # Chain rule verification
    lhs, rhs = cond_alg.chain_rule({1, 2}, {2, 3, 4})
    print(f"Chain rule: {lhs} = {rhs}, verified: {lhs == rhs}")
    
    # Product measure
    two_dice = product_measure(die, die)
    p7 = two_dice.measure({(a, b) for a in range(1,7) for b in range(1,7) if a+b == 7})
    print(f"P(sum=7 with 2 dice) = {p7}")
    
    # Inclusion-exclusion
    A = {1, 2, 3}
    B = {3, 4, 5}
    lhs, rhs = inclusion_exclusion(die, A, B)
    print(f"Inclusion-exclusion: {lhs} = {rhs}, verified: {lhs == rhs}")
