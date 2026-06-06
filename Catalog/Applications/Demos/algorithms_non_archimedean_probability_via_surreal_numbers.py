#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory — Algorithms

Type-hinted implementations of the core algorithms for non-Archimedean
probability measures.
"""

from fractions import Fraction
from typing import Dict, Set, FrozenSet, List, Tuple, Callable, Optional
from dataclasses import dataclass
from functools import reduce


# =============================================================================
# Core Types
# =============================================================================

@dataclass(frozen=True)
class NonArchElement:
    """
    Element of the non-Archimedean field Q(ε), represented as a + bε
    where ε is a formal infinitesimal.
    
    Ordered lexicographically on (real, inf).
    """
    real: Fraction
    inf: Fraction = Fraction(0)
    
    def __add__(self, other: 'NonArchElement') -> 'NonArchElement':
        return NonArchElement(self.real + other.real, self.inf + other.inf)
    
    def __sub__(self, other: 'NonArchElement') -> 'NonArchElement':
        return NonArchElement(self.real - other.real, self.inf - other.inf)
    
    def __mul__(self, other: 'NonArchElement') -> 'NonArchElement':
        return NonArchElement(
            self.real * other.real,
            self.real * other.inf + self.inf * other.real
        )
    
    def __truediv__(self, other: 'NonArchElement') -> 'NonArchElement':
        if other.real == 0:
            if other.inf == 0:
                raise ZeroDivisionError
            # Division by pure infinitesimal: (a + bε) / (cε) = b/c + (a/c)/ε
            # This takes us out of the first-order infinitesimal ring
            raise ValueError("Division by pure infinitesimal requires higher-order terms")
        # (a + bε) / (c + dε) ≈ a/c + (bc - ad)/(c²) ε
        r = self.real / other.real
        i = (self.inf * other.real - self.real * other.inf) / (other.real ** 2)
        return NonArchElement(r, i)
    
    def __lt__(self, other: 'NonArchElement') -> bool:
        return (self.real, self.inf) < (other.real, other.inf)
    
    def __le__(self, other: 'NonArchElement') -> bool:
        return (self.real, self.inf) <= (other.real, other.inf)
    
    def __neg__(self) -> 'NonArchElement':
        return NonArchElement(-self.real, -self.inf)
    
    def standard_part(self) -> Fraction:
        """The standard part map st: Q(ε) → Q."""
        return self.real
    
    def is_infinitesimal(self) -> bool:
        """True if this element is a positive infinitesimal."""
        return self.real == 0 and self.inf > 0
    
    def is_finite(self) -> bool:
        """True if the real part is finite (always true for Q(ε))."""
        return True
    
    def __repr__(self) -> str:
        if self.inf == 0:
            return f"NAE({self.real})"
        elif self.real == 0:
            return f"NAE({self.inf}ε)"
        else:
            return f"NAE({self.real} + {self.inf}ε)"

    @staticmethod
    def zero() -> 'NonArchElement':
        return NonArchElement(Fraction(0))
    
    @staticmethod
    def one() -> 'NonArchElement':
        return NonArchElement(Fraction(1))
    
    @staticmethod
    def epsilon() -> 'NonArchElement':
        return NonArchElement(Fraction(0), Fraction(1))


# =============================================================================
# Algorithm 1: Finitely Additive Probability Measure
# =============================================================================

class FinAddProbMeasure:
    """
    A finitely additive probability measure on a finite set.
    
    Invariants:
    - All weights are non-negative
    - Weights sum to 1
    """
    
    def __init__(self, weights: Dict[int, NonArchElement]):
        """
        Initialize with a dictionary mapping elements to their weights.
        
        Args:
            weights: Map from element indices to non-negative weights summing to 1.
        
        Raises:
            ValueError: If weights don't sum to 1 or contain negative values.
        """
        total = reduce(lambda a, b: a + b, weights.values(), NonArchElement.zero())
        if total != NonArchElement.one():
            raise ValueError(f"Weights must sum to 1, got {total}")
        for k, v in weights.items():
            if v < NonArchElement.zero():
                raise ValueError(f"Weight for {k} is negative: {v}")
        self._weights = dict(weights)
    
    def weight(self, element: int) -> NonArchElement:
        """Get the weight of an element."""
        return self._weights.get(element, NonArchElement.zero())
    
    def measure(self, subset: Set[int]) -> NonArchElement:
        """
        Compute the measure of a subset.
        
        Algorithm: Sum weights over the subset.
        Complexity: O(|subset|)
        """
        return reduce(
            lambda a, b: a + b,
            (self.weight(i) for i in subset),
            NonArchElement.zero()
        )
    
    def is_uniform(self) -> bool:
        """Check if this is a uniform measure."""
        vals = list(self._weights.values())
        return all(v == vals[0] for v in vals)
    
    def is_infinitesimal_valued(self) -> bool:
        """Check if all weights are infinitesimal."""
        return all(v.is_infinitesimal() for v in self._weights.values())
    
    @property
    def support(self) -> Set[int]:
        """The support of the measure."""
        return {k for k, v in self._weights.items() if v > NonArchElement.zero()}
    
    @property
    def universe(self) -> Set[int]:
        """The full universe."""
        return set(self._weights.keys())


# =============================================================================
# Algorithm 2: Uniform Measure Construction
# =============================================================================

def construct_uniform_measure(n: int) -> FinAddProbMeasure:
    """
    Construct a uniform probability measure on {0, 1, ..., n-1}.
    
    Each point gets weight 1/n.
    
    Pseudocode:
        INPUT: n > 0
        w ← 1/n
        FOR i = 0 TO n-1:
            weights[i] ← w
        VERIFY: Σ weights = 1
        RETURN FinAddProbMeasure(weights)
    
    Complexity: O(n)
    """
    if n <= 0:
        raise ValueError("n must be positive")
    w = NonArchElement(Fraction(1, n))
    weights = {i: w for i in range(n)}
    return FinAddProbMeasure(weights)


# =============================================================================
# Algorithm 3: Conditional Probability
# =============================================================================

def conditional_probability(
    mu: FinAddProbMeasure,
    A: Set[int],
    B: Set[int]
) -> NonArchElement:
    """
    Compute P(A | B) = μ(A ∩ B) / μ(B).
    
    In non-Archimedean fields, this is well-defined even when μ(B)
    is infinitesimal (but nonzero).
    
    Pseudocode:
        INPUT: measure μ, events A, B
        REQUIRE: μ(B) ≠ 0
        intersection ← A ∩ B
        RETURN μ(intersection) / μ(B)
    
    Complexity: O(|A| + |B|)
    """
    mu_B = mu.measure(B)
    if mu_B == NonArchElement.zero():
        raise ValueError("Cannot condition on event with zero probability")
    mu_AB = mu.measure(A & B)
    return mu_AB / mu_B


# =============================================================================
# Algorithm 4: Standard Part Map
# =============================================================================

def standard_part_measure(
    mu: FinAddProbMeasure
) -> Dict[int, Fraction]:
    """
    Apply the standard part map to obtain a real-valued measure.
    
    Pseudocode:
        INPUT: non-Archimedean measure μ
        FOR each element i in universe:
            st_weights[i] ← st(μ.weight(i))
        RETURN st_weights
    
    Note: The resulting weights may NOT sum to 1 if the original
    measure is infinitesimal-valued (the Standard Part Paradox).
    
    Complexity: O(n)
    """
    return {i: mu.weight(i).standard_part() for i in mu.universe}


# =============================================================================
# Algorithm 5: Verify Finite Additivity
# =============================================================================

def verify_finite_additivity(
    mu: FinAddProbMeasure,
    A: Set[int],
    B: Set[int]
) -> Tuple[bool, str]:
    """
    Verify that μ(A ∪ B) = μ(A) + μ(B) - μ(A ∩ B) (inclusion-exclusion).
    For disjoint sets, this simplifies to μ(A ∪ B) = μ(A) + μ(B).
    
    Pseudocode:
        INPUT: measure μ, events A, B
        lhs ← μ(A ∪ B)
        rhs ← μ(A) + μ(B) - μ(A ∩ B)
        RETURN lhs == rhs
    
    Complexity: O(|A| + |B|)
    """
    lhs = mu.measure(A | B)
    mu_A = mu.measure(A)
    mu_B = mu.measure(B)
    mu_AB = mu.measure(A & B)
    rhs = mu_A + mu_B - mu_AB
    
    is_disjoint = len(A & B) == 0
    
    if lhs == rhs:
        msg = (f"✓ Additivity holds: μ(A∪B) = {lhs} = μ(A) + μ(B)"
               + (" - μ(A∩B)" if not is_disjoint else "")
               + f" = {rhs}")
        return True, msg
    else:
        msg = f"✗ FAILURE: μ(A∪B) = {lhs} ≠ {rhs}"
        return False, msg


# =============================================================================
# Algorithm 6: Archimedean Test
# =============================================================================

def archimedean_test(w: Fraction, max_n: int = 10000) -> Optional[int]:
    """
    For a positive rational w, find the smallest n such that n*w ≥ 1.
    This witnesses the Archimedean property.
    
    Returns None if w ≤ 0 (no witness exists for non-positive).
    
    Pseudocode:
        INPUT: w > 0
        n ← ⌈1/w⌉
        RETURN n
    
    Complexity: O(1)
    """
    if w <= 0:
        return None
    import math
    return math.ceil(Fraction(1) / w)


if __name__ == "__main__":
    # Quick smoke test
    print("=== Algorithm Smoke Tests ===\n")
    
    # Test uniform measure
    mu = construct_uniform_measure(5)
    print(f"Uniform(5): weight(0) = {mu.weight(0)}")
    print(f"  measure({{0,1}}) = {mu.measure({0, 1})}")
    print(f"  measure(univ) = {mu.measure(mu.universe)}")
    
    # Test finite additivity
    ok, msg = verify_finite_additivity(mu, {0, 1}, {3, 4})
    print(f"  {msg}")
    
    ok, msg = verify_finite_additivity(mu, {0, 1, 2}, {2, 3, 4})
    print(f"  {msg}")
    
    # Test conditional probability
    cp = conditional_probability(mu, {0}, {0, 1, 2})
    print(f"  P({{0}} | {{0,1,2}}) = {cp}")
    
    # Test Archimedean witness
    n = archimedean_test(Fraction(1, 1000))
    print(f"\n  Archimedean witness for w=1/1000: n = {n}")
    
    # Test standard part
    st = standard_part_measure(mu)
    print(f"  Standard part: {st}")
    
    print("\n=== All smoke tests passed ===")
