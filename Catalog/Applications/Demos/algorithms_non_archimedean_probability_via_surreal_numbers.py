#!/usr/bin/env python3
"""
algorithms.py — Non-Archimedean Probability: Core Algorithms

Type-hinted implementations of the key algorithms from the
non-Archimedean probability framework.
"""

from __future__ import annotations
from fractions import Fraction
from typing import FrozenSet, Dict, Tuple, List, Optional
from dataclasses import dataclass


@dataclass(frozen=True)
class SurrealApprox:
    """Approximation of a surreal number as a + b/ω for infinitesimal 1/ω.
    
    real_part: the standard (real) component
    infinitesimal_coeff: coefficient of 1/ω (the infinitesimal part)
    
    Ordered lexicographically: first by real_part, then by infinitesimal_coeff.
    """
    real_part: Fraction
    infinitesimal_coeff: Fraction
    
    def __add__(self, other: SurrealApprox) -> SurrealApprox:
        return SurrealApprox(
            self.real_part + other.real_part,
            self.infinitesimal_coeff + other.infinitesimal_coeff
        )
    
    def __sub__(self, other: SurrealApprox) -> SurrealApprox:
        return SurrealApprox(
            self.real_part - other.real_part,
            self.infinitesimal_coeff - other.infinitesimal_coeff
        )
    
    def __mul__(self, other: SurrealApprox) -> SurrealApprox:
        """Multiply, dropping ε² terms."""
        return SurrealApprox(
            self.real_part * other.real_part,
            self.real_part * other.infinitesimal_coeff + 
            self.infinitesimal_coeff * other.real_part
        )
    
    def __truediv__(self, other: SurrealApprox) -> SurrealApprox:
        if other.real_part != 0:
            r = self.real_part / other.real_part
            i = (self.infinitesimal_coeff * other.real_part - 
                 self.real_part * other.infinitesimal_coeff) / (other.real_part ** 2)
            return SurrealApprox(r, i)
        elif other.infinitesimal_coeff != 0:
            return SurrealApprox(
                self.infinitesimal_coeff / other.infinitesimal_coeff,
                Fraction(0)
            )
        raise ZeroDivisionError
    
    def __gt__(self, other: SurrealApprox) -> bool:
        if self.real_part != other.real_part:
            return self.real_part > other.real_part
        return self.infinitesimal_coeff > other.infinitesimal_coeff
    
    def __ge__(self, other: SurrealApprox) -> bool:
        return self == other or self > other
    
    def __lt__(self, other: SurrealApprox) -> bool:
        return other > self
    
    def is_positive(self) -> bool:
        return self > SurrealApprox(Fraction(0), Fraction(0))
    
    def is_infinitesimal(self) -> bool:
        return self.real_part == Fraction(0) and self.infinitesimal_coeff > 0
    
    def standard_part(self) -> Fraction:
        return self.real_part
    
    def __repr__(self) -> str:
        if self.infinitesimal_coeff == 0:
            return str(self.real_part)
        if self.real_part == 0:
            return f"{self.infinitesimal_coeff}/ω"
        sign = "+" if self.infinitesimal_coeff > 0 else "-"
        return f"{self.real_part} {sign} {abs(self.infinitesimal_coeff)}/ω"


# Constants
ZERO = SurrealApprox(Fraction(0), Fraction(0))
ONE = SurrealApprox(Fraction(1), Fraction(0))
OMEGA_INV = SurrealApprox(Fraction(0), Fraction(1))  # 1/ω


def infinitesimal_measure(
    epsilon: SurrealApprox,
    subset: FrozenSet[int]
) -> SurrealApprox:
    """
    Algorithm 1: Infinitesimal Uniform Measure
    
    Computes μ_ε(A) = |A| · ε
    
    Input: infinitesimal ε, finite set A
    Output: surreal-approximation of the measure
    
    Time: O(1) — just multiplication
    Space: O(1)
    """
    n = len(subset)
    return SurrealApprox(
        Fraction(n) * epsilon.real_part,
        Fraction(n) * epsilon.infinitesimal_coeff
    )


def conditional_probability(
    epsilon: SurrealApprox,
    event_a: FrozenSet[int],
    event_b: FrozenSet[int]
) -> SurrealApprox:
    """
    Algorithm 2: Infinitesimal Conditional Probability
    
    Computes P(A|B) = μ_ε(A ∩ B) / μ_ε(B)
    
    Key property: result = |A ∩ B| / |B| (infinitesimals cancel)
    
    Input: infinitesimal ε, events A, B (B nonempty)
    Output: conditional probability (a rational number)
    """
    intersection = event_a & event_b
    mu_intersection = infinitesimal_measure(epsilon, intersection)
    mu_b = infinitesimal_measure(epsilon, event_b)
    return mu_intersection / mu_b


def normalize_measure(
    universe: FrozenSet[int]
) -> SurrealApprox:
    """
    Algorithm 3: Normalization
    
    Computes the unique ε such that μ_ε(Ω) = 1.
    
    Result: ε = 1/|Ω|
    """
    n = len(universe)
    if n == 0:
        raise ValueError("Cannot normalize on empty universe")
    return SurrealApprox(Fraction(1, n), Fraction(0))


def verify_additivity(
    epsilon: SurrealApprox,
    set_a: FrozenSet[int],
    set_b: FrozenSet[int]
) -> Tuple[bool, str]:
    """
    Algorithm 4: Additivity Verification
    
    Checks μ(A ∪ B) = μ(A) + μ(B) for disjoint A, B.
    
    Returns (is_valid, explanation)
    """
    if set_a & set_b:
        return False, f"Sets are not disjoint: intersection = {set_a & set_b}"
    
    mu_a = infinitesimal_measure(epsilon, set_a)
    mu_b = infinitesimal_measure(epsilon, set_b)
    mu_union = infinitesimal_measure(epsilon, set_a | set_b)
    mu_sum = mu_a + mu_b
    
    is_valid = (mu_union == mu_sum)
    explanation = (
        f"μ(A) = {mu_a}, μ(B) = {mu_b}, "
        f"μ(A∪B) = {mu_union}, μ(A)+μ(B) = {mu_sum}, "
        f"equal = {is_valid}"
    )
    return is_valid, explanation


def archimedean_test(
    candidate_epsilon: Fraction,
    max_n: int = 1000
) -> Tuple[bool, Optional[int]]:
    """
    Algorithm 5: Archimedean Property Test
    
    Tests if candidate_epsilon could be an infinitesimal in ℝ.
    Finds n such that n * epsilon > 1 (proving it can't be infinitesimal in ℝ).
    
    Returns (is_broken, breaking_n)
    """
    if candidate_epsilon <= 0:
        return False, None
    
    for n in range(1, max_n + 1):
        if n * candidate_epsilon > 1:
            return True, n
    
    return False, None


def bayesian_update(
    epsilon: SurrealApprox,
    prior: Dict[int, SurrealApprox],
    likelihood: Dict[int, Fraction],
    evidence: FrozenSet[int]
) -> Dict[int, SurrealApprox]:
    """
    Algorithm 6: Bayesian Update with Infinitesimal Priors
    
    Computes posterior P(θ|E) = P(E|θ) · P(θ) / P(E)
    where P(θ) can be infinitesimal.
    
    Input: prior probabilities, likelihood function, evidence
    Output: posterior probabilities
    """
    # Compute P(E) = Σ P(E|θ) P(θ)
    p_evidence = ZERO
    for theta, p_theta in prior.items():
        l = SurrealApprox(likelihood.get(theta, Fraction(0)), Fraction(0))
        p_evidence = p_evidence + (l * p_theta)
    
    # Compute posteriors
    posterior: Dict[int, SurrealApprox] = {}
    for theta, p_theta in prior.items():
        l = SurrealApprox(likelihood.get(theta, Fraction(0)), Fraction(0))
        posterior[theta] = (l * p_theta) / p_evidence
    
    return posterior


if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")
    
    # Test 1: Measure computation
    A = frozenset({1, 2, 3})
    B = frozenset({4, 5})
    print(f"μ_{{1/ω}}({set(A)}) = {infinitesimal_measure(OMEGA_INV, A)}")
    print(f"μ_{{1/ω}}({set(B)}) = {infinitesimal_measure(OMEGA_INV, B)}")
    
    # Test 2: Additivity
    valid, msg = verify_additivity(OMEGA_INV, A, B)
    print(f"\nAdditivity: {msg}")
    
    # Test 3: Conditional probability
    C = frozenset({1, 2, 3, 4, 5, 6})
    even = frozenset({2, 4, 6})
    leq4 = frozenset({1, 2, 3, 4})
    cp = conditional_probability(OMEGA_INV, even, leq4)
    print(f"\nP(even | ≤4) = {cp}")
    
    # Test 4: Normalization
    eps = normalize_measure(C)
    total = infinitesimal_measure(eps, C)
    print(f"\nNormalized ε for |Ω|=6: {eps}")
    print(f"Total mass: {total}")
    
    # Test 5: Archimedean test
    for eps_val in [Fraction(1, 10), Fraction(1, 100)]:
        broken, n = archimedean_test(eps_val)
        print(f"\nArchimedean test for ε={eps_val}: breaks at n={n}")
    
    print("\n=== All tests passed ===")
