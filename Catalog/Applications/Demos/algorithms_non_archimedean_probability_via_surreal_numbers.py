#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of the core algorithms for constructing and
manipulating probability measures in non-Archimedean ordered fields.
"""

from fractions import Fraction
from typing import Dict, FrozenSet, Generic, List, Optional, Set, TypeVar
from dataclasses import dataclass


T = TypeVar('T')  # Element type
F = TypeVar('F')  # Field type


@dataclass
class FinAddProb(Generic[T]):
    """Finitely additive probability measure on a finite set.
    
    Invariants:
    - All weights are non-negative
    - Weights sum to 1
    """
    weights: Dict[T, Fraction]
    
    def __post_init__(self) -> None:
        assert all(w >= 0 for w in self.weights.values()), "Weights must be non-negative"
        total = sum(self.weights.values())
        assert total == 1, f"Weights must sum to 1, got {total}"
    
    def measure(self, s: Set[T]) -> Fraction:
        """Compute the measure of a subset."""
        return sum(self.weights.get(x, Fraction(0)) for x in s)
    
    def cond_prob(self, event_a: Set[T], event_b: Set[T]) -> Optional[Fraction]:
        """Compute P(B | A) = P(A ∩ B) / P(A).
        
        Returns None if P(A) = 0.
        """
        p_a = self.measure(event_a)
        if p_a == 0:
            return None
        p_ab = self.measure(event_a & event_b)
        return p_ab / p_a
    
    @property
    def is_uniform(self) -> bool:
        """Check if the measure is uniform (all weights equal)."""
        vals = list(self.weights.values())
        return len(set(vals)) <= 1
    
    @property
    def universe(self) -> Set[T]:
        """The underlying sample space."""
        return set(self.weights.keys())


@dataclass 
class InfinitesimalPreMeasure(Generic[T]):
    """Infinitesimal pre-measure: assigns weight ε to every point.
    
    The total mass n·ε < 1, leaving a positive defect.
    This models the behavior in a non-Archimedean field.
    """
    elements: List[T]
    epsilon: Fraction
    
    def __post_init__(self) -> None:
        assert self.epsilon > 0, "ε must be positive"
        n = len(self.elements)
        total = n * self.epsilon
        assert total < 1, f"Total mass {total} must be < 1"
    
    @property
    def total_mass(self) -> Fraction:
        """The total mass n·ε."""
        return len(self.elements) * self.epsilon
    
    @property
    def defect(self) -> Fraction:
        """The probability defect: 1 - n·ε > 0."""
        return 1 - self.total_mass


def construct_uniform(elements: List[T]) -> FinAddProb[T]:
    """Construct the unique uniform probability measure on a finite set.
    
    Algorithm:
    1. Compute n = |elements|
    2. Assign weight 1/n to each element
    3. Return the FinAddProb
    
    Theorem (uniform_finaddprob_weight): This is the UNIQUE uniform measure.
    """
    n = len(elements)
    assert n > 0, "Need at least one element"
    w = Fraction(1, n)
    return FinAddProb(weights={x: w for x in elements})


def construct_two_level(elements: List[T], 
                        epsilon: Fraction, 
                        distinguished: T) -> FinAddProb[T]:
    """Construct a two-level probability measure.
    
    Algorithm:
    1. Assign weight ε to every non-distinguished element
    2. Assign weight 1 - (n-1)·ε to the distinguished element
    3. Total = ε·(n-1) + (1-(n-1)·ε) = 1
    
    Precondition: n·ε < 1 (so distinguished weight > 0)
    
    Theorem (two_level_measure_exists): This construction is valid.
    """
    n = len(elements)
    assert n > 0
    assert n * epsilon < 1, f"Need n·ε < 1, got {n * epsilon}"
    
    bulk_weight = 1 - (n - 1) * epsilon
    weights = {}
    for x in elements:
        if x == distinguished:
            weights[x] = bulk_weight
        else:
            weights[x] = epsilon
    
    return FinAddProb(weights=weights)


def verify_finite_additivity(mu: FinAddProb[T], 
                             s: Set[T], 
                             t: Set[T]) -> bool:
    """Verify μ(S ∪ T) = μ(S) + μ(T) for disjoint S, T.
    
    Theorem (measure_finite_additivity): Always holds for FinAddProb.
    """
    if s & t:  # not disjoint
        return False  # not applicable
    
    lhs = mu.measure(s | t)
    rhs = mu.measure(s) + mu.measure(t)
    return lhs == rhs


def verify_inclusion_exclusion(mu: FinAddProb[T], 
                                s: Set[T], 
                                t: Set[T]) -> bool:
    """Verify μ(S ∪ T) + μ(S ∩ T) = μ(S) + μ(T).
    
    Theorem (measure_union_inter): Always holds for FinAddProb.
    """
    lhs = mu.measure(s | t) + mu.measure(s & t)
    rhs = mu.measure(s) + mu.measure(t)
    return lhs == rhs


def verify_bayes(mu: FinAddProb[T], 
                 a: Set[T], 
                 b: Set[T]) -> bool:
    """Verify P(B|A)·P(A) = P(A|B)·P(B).
    
    Theorem (bayes_formula): Always holds when P(A), P(B) > 0.
    """
    p_a = mu.measure(a)
    p_b = mu.measure(b)
    
    if p_a == 0 or p_b == 0:
        return True
    
    p_b_given_a = mu.cond_prob(a, b)
    p_a_given_b = mu.cond_prob(b, a)
    
    if p_b_given_a is None or p_a_given_b is None:
        return True
    
    return p_b_given_a * p_a == p_a_given_b * p_b


def infinitesimal_hierarchy(epsilon: Fraction, depth: int = 5) -> List[Fraction]:
    """Generate the infinitesimal hierarchy ε, ε², ε³, ...
    
    Theorem (infinitesimal_squared_smaller): ε² < ε when 0 < ε < 1.
    Each level is infinitesimally small compared to the previous.
    """
    return [epsilon ** k for k in range(1, depth + 1)]


if __name__ == "__main__":
    # Example usage
    elements = list(range(10))
    
    # Uniform measure
    mu = construct_uniform(elements)
    print(f"Uniform measure on {{0,...,9}}:")
    print(f"  P({{0}}) = {mu.measure({0})}")
    print(f"  P({{0,1,2}}) = {mu.measure({0,1,2})}")
    print()
    
    # Two-level measure
    eps = Fraction(1, 100)
    mu2 = construct_two_level(elements, eps, distinguished=0)
    print(f"Two-level measure (ε=1/100, distinguished=0):")
    print(f"  P({{0}}) = {mu2.measure({0})} = {float(mu2.measure({0})):.4f}")
    print(f"  P({{1}}) = {mu2.measure({1})} = {float(mu2.measure({1})):.4f}")
    print(f"  P(total) = {mu2.measure(set(elements))}")
    print()
    
    # Bayes verification
    a, b = {0, 1, 2}, {2, 3, 4}
    print(f"Bayes' theorem verification:")
    print(f"  A = {a}, B = {b}")
    print(f"  Holds: {verify_bayes(mu2, a, b)}")
    print()
    
    # Hierarchy
    print(f"Infinitesimal hierarchy (ε = 1/100):")
    for k, val in enumerate(infinitesimal_hierarchy(eps), 1):
        print(f"  ε^{k} = {val} = {float(val):.2e}")
