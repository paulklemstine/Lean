#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of the core algorithms from the formalized theory.
"""

from fractions import Fraction
from typing import (
    TypeVar, Generic, Callable, Dict, FrozenSet, Set, List, Tuple, Optional
)
from dataclasses import dataclass

T = TypeVar('T')  # Element type
V = TypeVar('V')  # Value type (e.g., Fraction, float)


@dataclass
class WeightedMeasure(Generic[T]):
    """A finitely additive measure determined by a weight function.
    
    Corresponds to the Lean definition:
        structure WeightedMeasure (α : Type*) (G : Type*) where
          weight : α → G
    """
    weights: Dict[T, Fraction]
    
    def measure(self, S: FrozenSet[T]) -> Fraction:
        """Compute μ(S) = ∑ x ∈ S, w(x).
        
        Implements WeightedMeasure.measure from the Lean formalization.
        """
        return sum(self.weights.get(x, Fraction(0)) for x in S)
    
    def is_prob(self) -> bool:
        """Check if this is a probability measure (total mass = 1).
        
        Implements WeightedMeasure.IsProb.
        """
        return self.measure(frozenset(self.weights.keys())) == Fraction(1)
    
    def is_nonneg(self) -> bool:
        """Check if all weights are non-negative."""
        return all(w >= 0 for w in self.weights.values())
    
    def is_pos(self) -> bool:
        """Check if all weights are strictly positive."""
        return all(w > 0 for w in self.weights.values())


def uniform_measure(elements: List[T]) -> WeightedMeasure[T]:
    """Create a uniform probability measure on the given elements.
    
    Implements uniformProb from the Lean formalization.
    Each element receives weight 1/n where n = len(elements).
    
    Algorithm:
        1. Compute n = |elements|
        2. Set w(x) = 1/n for each x
        3. Return WeightedMeasure with these weights
    
    Complexity: O(n)
    """
    n = len(elements)
    if n == 0:
        raise ValueError("Cannot create uniform measure on empty set")
    weight = Fraction(1, n)
    return WeightedMeasure({x: weight for x in elements})


def verify_finite_additivity(
    mu: WeightedMeasure[T],
    A: FrozenSet[T],
    B: FrozenSet[T]
) -> Tuple[bool, str]:
    """Verify finite additivity for disjoint sets A and B.
    
    Checks: μ(A ∪ B) = μ(A) + μ(B) when A ∩ B = ∅
    
    Returns (success, message).
    
    Algorithm:
        1. Check A ∩ B = ∅
        2. Compute μ(A), μ(B), μ(A ∪ B)
        3. Verify equality
    """
    if A & B:
        return False, f"Sets are not disjoint: intersection = {A & B}"
    
    mu_A = mu.measure(A)
    mu_B = mu.measure(B)
    mu_AB = mu.measure(A | B)
    
    if mu_AB == mu_A + mu_B:
        return True, f"μ(A∪B) = {mu_AB} = {mu_A} + {mu_B} = μ(A) + μ(B) ✓"
    else:
        return False, f"FAILED: μ(A∪B) = {mu_AB} ≠ {mu_A + mu_B} = μ(A) + μ(B)"


def archimedean_witness(epsilon: Fraction) -> Optional[int]:
    """Find n such that n * ε ≥ 1 (Archimedean property witness).
    
    Implements the constructive content of no_infinitesimal_in_archimedean.
    
    For any ε > 0 in ℚ, returns the smallest n ∈ ℕ with n·ε ≥ 1.
    Returns None if ε ≤ 0.
    
    Algorithm:
        1. If ε ≤ 0, return None (not a valid infinitesimal candidate)
        2. Compute n = ⌈1/ε⌉
        3. Return n
    
    Complexity: O(1) (exact rational arithmetic)
    """
    if epsilon <= 0:
        return None
    # Ceiling of 1/ε
    inv = Fraction(1) / epsilon
    n = int(inv)
    if Fraction(n) < inv:
        n += 1
    return n


def complement_probability(
    mu: WeightedMeasure[T],
    S: FrozenSet[T]
) -> Fraction:
    """Compute P(Sᶜ) = 1 - P(S) for a probability measure.
    
    Implements measure_compl_eq_one_sub.
    
    Algorithm:
        1. Compute P(S)
        2. Return 1 - P(S)
    """
    return Fraction(1) - mu.measure(S)


def partition_measure(
    mu: WeightedMeasure[T],
    classifier: Callable[[T], str]
) -> Dict[str, Fraction]:
    """Decompose measure by partition (fiber decomposition).
    
    Implements measure_eq_sum_fibers.
    
    Algorithm:
        1. Group elements by classifier(x)
        2. Compute μ(fiber) for each class
        3. Return dict mapping class → measure
    
    Invariant: sum of values = μ(universe)
    """
    fibers: Dict[str, Set[T]] = {}
    for x in mu.weights:
        key = classifier(x)
        if key not in fibers:
            fibers[key] = set()
        fibers[key].add(x)
    
    return {
        key: mu.measure(frozenset(fiber))
        for key, fiber in fibers.items()
    }


def no_free_lunch_check(
    mu: WeightedMeasure[T],
    S: FrozenSet[T]
) -> Tuple[bool, Fraction]:
    """Verify the No Free Lunch theorem: positive weights → positive measure.
    
    Implements weighted_measure_pos_of_pos_weights.
    
    Returns (all_positive, total_measure).
    If all weights on S are positive and S is nonempty, total must be > 0.
    """
    if not S:
        return True, Fraction(0)
    
    all_pos = all(mu.weights.get(x, Fraction(0)) > 0 for x in S)
    total = mu.measure(S)
    
    return all_pos, total


def monotonicity_check(
    mu: WeightedMeasure[T],
    A: FrozenSet[T],
    B: FrozenSet[T]
) -> Tuple[bool, str]:
    """Check monotonicity: if all weights nonneg and A ⊆ B, then μ(A) ≤ μ(B).
    
    Implements weighted_measure_mono_of_nonneg.
    """
    if not A.issubset(B):
        return False, "A is not a subset of B"
    
    if not all(mu.weights.get(x, Fraction(0)) >= 0 for x in B):
        return False, "Not all weights on B are non-negative"
    
    mu_A = mu.measure(A)
    mu_B = mu.measure(B)
    
    if mu_A <= mu_B:
        return True, f"μ(A) = {mu_A} ≤ {mu_B} = μ(B) ✓"
    else:
        return False, f"FAILED: μ(A) = {mu_A} > {mu_B} = μ(B)"


# Pseudocode for the main algorithm
PSEUDOCODE = """
Algorithm: Non-Archimedean Finitely Additive Probability

Input: A finite set S = {x₁, ..., xₙ}, a weight function w : S → F
       where F is a linearly ordered field (possibly non-Archimedean)

Output: A finitely additive probability measure μ on 2^S

1. DEFINE μ(A) = Σ_{x ∈ A} w(x) for each A ⊆ S

2. VERIFY probability axioms:
   a. μ(∅) = 0                              [Empty set]
   b. μ(S) = Σ w(xᵢ)                        [Total mass]
   c. For disjoint A, B:                     [Finite additivity]
      μ(A ∪ B) = μ(A) + μ(B)

3. IF w(x) = 1/n for all x (uniform case):
   THEN μ(S) = n · (1/n) = 1               [Probability measure]

4. IF w(x) > 0 for all x ∈ A and A ≠ ∅:
   THEN μ(A) > 0                            [No Free Lunch]
   (This holds even when w(x) is infinitesimal!)

5. ARCHIMEDEAN TEST:
   IF F is Archimedean (e.g., ℝ, ℚ):
     THEN no w(x) can be infinitesimal
     (For any w > 0, ∃ n: n·w ≥ 1)
   ELSE (F is non-Archimedean, e.g., surreal numbers):
     w(x) CAN be infinitesimal
     μ(A) is infinitesimal but positive for finite A
"""


if __name__ == '__main__':
    # Quick test
    elements = ['a', 'b', 'c', 'd']
    mu = uniform_measure(elements)
    
    assert mu.is_prob(), "Uniform measure should be a probability measure"
    assert mu.is_pos(), "Uniform measure should have positive weights"
    
    A = frozenset(['a', 'b'])
    B = frozenset(['c', 'd'])
    
    ok, msg = verify_finite_additivity(mu, A, B)
    assert ok, msg
    
    n = archimedean_witness(Fraction(1, 100))
    assert n is not None and n * Fraction(1, 100) >= 1
    
    print("All algorithm tests passed!")
    print()
    print(PSEUDOCODE)
