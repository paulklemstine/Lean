#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of the core constructions and algorithms
from the non-Archimedean probability framework.
"""

from __future__ import annotations
from fractions import Fraction
from typing import Dict, FrozenSet, Generic, List, Optional, Set, TypeVar

T = TypeVar('T')


# ── Core Type: Surreal-Like Numbers ──────────────────────────────────────────

class SurrealLike:
    """
    Elements of the form a + b·ε where a,b ∈ ℚ and ε is infinitesimal.
    
    This is the simplest non-Archimedean extension of the rationals,
    isomorphic to ℚ(ε) with the lexicographic order.
    """
    
    def __init__(self, real: Fraction = Fraction(0), 
                 infinitesimal: Fraction = Fraction(0)) -> None:
        self.real = real
        self.inf = infinitesimal
    
    def __repr__(self) -> str:
        if self.inf == 0:
            return str(self.real)
        elif self.real == 0:
            if self.inf == 1:
                return "ε"
            return f"{self.inf}·ε"
        else:
            sign = "+" if self.inf > 0 else "-"
            coeff = abs(self.inf)
            return f"{self.real} {sign} {coeff}·ε"
    
    def __add__(self, other: SurrealLike) -> SurrealLike:
        return SurrealLike(self.real + other.real, self.inf + other.inf)
    
    def __sub__(self, other: SurrealLike) -> SurrealLike:
        return SurrealLike(self.real - other.real, self.inf - other.inf)
    
    def __mul__(self, other: SurrealLike) -> SurrealLike:
        return SurrealLike(
            self.real * other.real,
            self.real * other.inf + self.inf * other.real
        )
    
    def __truediv__(self, other: SurrealLike) -> SurrealLike:
        if other.real != 0:
            return SurrealLike(
                self.real / other.real,
                (self.inf * other.real - self.real * other.inf) / (other.real ** 2)
            )
        elif other.inf != 0:
            return SurrealLike(self.inf / other.inf, Fraction(0))
        raise ZeroDivisionError
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, SurrealLike):
            return NotImplemented
        return self.real == other.real and self.inf == other.inf
    
    def __lt__(self, other: SurrealLike) -> bool:
        return (self.real, self.inf) < (other.real, other.inf)
    
    def __le__(self, other: SurrealLike) -> bool:
        return self == other or self < other
    
    def __gt__(self, other: SurrealLike) -> bool:
        return other < self
    
    def __ge__(self, other: SurrealLike) -> bool:
        return other <= self
    
    def __hash__(self) -> int:
        return hash((self.real, self.inf))
    
    def is_infinitesimal(self) -> bool:
        return self.real == 0 and self.inf > 0
    
    def is_positive(self) -> bool:
        return self > SurrealLike()
    
    def is_nonneg(self) -> bool:
        return self >= SurrealLike()
    
    def standard_part(self) -> Fraction:
        """The 'shadow' of this surreal-like number on the reals."""
        return self.real
    
    @staticmethod
    def zero() -> SurrealLike:
        return SurrealLike()
    
    @staticmethod
    def one() -> SurrealLike:
        return SurrealLike(Fraction(1))
    
    @staticmethod
    def epsilon() -> SurrealLike:
        return SurrealLike(Fraction(0), Fraction(1))
    
    @staticmethod
    def from_rational(p: int, q: int = 1) -> SurrealLike:
        return SurrealLike(Fraction(p, q))


# ── Algorithm 1: Finite Probability Measure Construction ─────────────────────

def construct_uniform_measure(
    elements: List[str]
) -> Dict[str, SurrealLike]:
    """
    Construct the uniform probability measure on a finite set.
    
    Algorithm: Assign weight 1/n to each of n elements.
    Complexity: O(n)
    
    Returns: Dictionary mapping elements to their probabilities.
    """
    n = len(elements)
    if n == 0:
        raise ValueError("Cannot construct measure on empty set")
    weight = SurrealLike.from_rational(1, n)
    return {e: weight for e in elements}


def construct_infinitesimal_perturbed_measure(
    elements: List[str],
    perturbations: Dict[str, Fraction]
) -> Dict[str, SurrealLike]:
    """
    Construct a probability measure with infinitesimal perturbations.
    
    Each element gets weight (1/n + δᵢ·ε) where δᵢ are perturbation
    coefficients satisfying ∑δᵢ = 0.
    
    Algorithm:
    1. Compute base weight 1/n
    2. Add infinitesimal perturbation δᵢ·ε to each element
    3. Verify normalization (∑perturbations must be 0)
    
    Returns: Dictionary mapping elements to surreal-like probabilities.
    """
    n = len(elements)
    if n == 0:
        raise ValueError("Cannot construct measure on empty set")
    
    total_pert = sum(perturbations.get(e, Fraction(0)) for e in elements)
    if total_pert != 0:
        raise ValueError(f"Perturbations must sum to 0, got {total_pert}")
    
    base = Fraction(1, n)
    return {
        e: SurrealLike(base, perturbations.get(e, Fraction(0)))
        for e in elements
    }


# ── Algorithm 2: Measure of a Set ───────────────────────────────────────────

def measure_of(
    weights: Dict[str, SurrealLike],
    subset: Set[str]
) -> SurrealLike:
    """
    Compute the measure of a subset.
    
    Algorithm: Sum the weights of elements in the subset.
    Complexity: O(|subset|)
    """
    total = SurrealLike.zero()
    for e in subset:
        if e in weights:
            total = total + weights[e]
    return total


# ── Algorithm 3: Conditional Probability ─────────────────────────────────────

def conditional_probability(
    weights: Dict[str, SurrealLike],
    event_a: Set[str],
    event_b: Set[str]
) -> SurrealLike:
    """
    Compute P(A | B) = P(A ∩ B) / P(B).
    
    In a non-Archimedean field with strictly positive weights,
    this is always well-defined (P(B) > 0 for nonempty B).
    
    Algorithm:
    1. Compute P(A ∩ B)
    2. Compute P(B)
    3. Return their ratio
    
    Complexity: O(|A| + |B|)
    """
    p_intersection = measure_of(weights, event_a & event_b)
    p_b = measure_of(weights, event_b)
    
    if p_b == SurrealLike.zero():
        raise ValueError("Cannot condition on zero-probability event")
    
    return p_intersection / p_b


# ── Algorithm 4: Bayesian Update ─────────────────────────────────────────────

def bayesian_update(
    prior: Dict[str, SurrealLike],
    likelihood: Dict[str, SurrealLike],
    evidence: str
) -> Dict[str, SurrealLike]:
    """
    Perform Bayesian update with non-Archimedean probabilities.
    
    Given:
    - prior: P(hypothesis) for each hypothesis
    - likelihood: P(evidence | hypothesis) for each hypothesis
    - evidence: the observed evidence
    
    Computes: P(hypothesis | evidence) for each hypothesis
    
    Algorithm:
    1. Compute P(evidence) = ∑_h P(evidence|h) · P(h)
    2. For each hypothesis h: P(h|evidence) = P(evidence|h) · P(h) / P(evidence)
    
    Complexity: O(n) where n = number of hypotheses
    """
    # Compute P(evidence) = ∑ P(evidence|h) · P(h)
    p_evidence = SurrealLike.zero()
    for h in prior:
        p_evidence = p_evidence + likelihood.get(h, SurrealLike.zero()) * prior[h]
    
    if p_evidence == SurrealLike.zero():
        raise ValueError("Evidence has zero probability under all hypotheses")
    
    # Compute posterior
    posterior: Dict[str, SurrealLike] = {}
    for h in prior:
        numerator = likelihood.get(h, SurrealLike.zero()) * prior[h]
        posterior[h] = numerator / p_evidence
    
    return posterior


# ── Algorithm 5: Inclusion-Exclusion ─────────────────────────────────────────

def inclusion_exclusion_two(
    weights: Dict[str, SurrealLike],
    a: Set[str],
    b: Set[str]
) -> SurrealLike:
    """
    Compute P(A ∪ B) using inclusion-exclusion.
    
    P(A ∪ B) = P(A) + P(B) - P(A ∩ B)
    
    Complexity: O(|A| + |B|)
    """
    return measure_of(weights, a) + measure_of(weights, b) - measure_of(weights, a & b)


# ── Algorithm 6: Check Non-Archimedean Property ─────────────────────────────

def verify_infinitesimal(eps: SurrealLike, max_n: int = 1000) -> bool:
    """
    Verify that eps is infinitesimal (positive and < 1/n for checked n values).
    
    Note: In exact arithmetic, we check the structural property.
    For SurrealLike numbers, eps is infinitesimal iff eps.real == 0 and eps.inf > 0.
    """
    if not eps.is_positive():
        return False
    if eps.real != 0:
        return False  # Has a standard part, so not infinitesimal
    return eps.inf > 0


# ── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Demo: Bayesian update with infinitesimal prior
    eps = SurrealLike.epsilon()
    
    prior = {
        "rare_disease": eps,
        "common_cold": SurrealLike.from_rational(3, 10),
        "healthy": SurrealLike.one() - SurrealLike.from_rational(3, 10) - eps,
    }
    
    # Likelihood of symptom given each hypothesis
    likelihood = {
        "rare_disease": SurrealLike.from_rational(99, 100),
        "common_cold": SurrealLike.from_rational(80, 100),
        "healthy": SurrealLike.from_rational(5, 100),
    }
    
    print("Prior probabilities:")
    for h, p in prior.items():
        print(f"  P({h}) = {p}")
    
    posterior = bayesian_update(prior, likelihood, "symptom")
    
    print("\nPosterior probabilities (after observing symptom):")
    for h, p in posterior.items():
        print(f"  P({h} | symptom) = {p}")
    
    print(f"\n  Note: rare_disease posterior is proportional to ε")
    print(f"  — infinitesimal but DEFINED, unlike standard P(rare|symptom) = 0/0")
