#!/usr/bin/env python3
"""
Non-Archimedean Probability: Algorithms

Type-hinted implementations of the core algorithms for non-Archimedean
probability computation.
"""

from fractions import Fraction
from typing import TypeVar, Set, FrozenSet, Dict, Tuple, Optional

T = TypeVar('T')


def uniform_measure(s: Set[T]) -> Tuple[Fraction, str]:
    """
    Compute the uniform non-Archimedean measure of a finite set.
    
    Returns (coefficient, "ε") where μ(S) = coefficient · ε.
    
    Algorithm:
        1. Count elements: n = |S|
        2. Return n · ε
    
    Complexity: O(|S|) for counting
    
    Args:
        s: A finite set
    
    Returns:
        (n, "ε") representing n · ε
    """
    return (Fraction(len(s)), "ε")


def conditional_probability(
    a: Set[T], b: Set[T]
) -> Fraction:
    """
    Compute P(A | B) for a uniform non-Archimedean measure.
    
    Since μ(A ∩ B) = |A ∩ B| · ε and μ(B) = |B| · ε,
    the infinitesimals cancel: P(A | B) = |A ∩ B| / |B|.
    
    Algorithm:
        1. Compute intersection A ∩ B
        2. Return |A ∩ B| / |B|
    
    Complexity: O(min(|A|, |B|)) for intersection
    
    Args:
        a: Event A
        b: Event B (must be nonempty)
    
    Returns:
        P(A | B) as a rational number
    
    Raises:
        ValueError: if B is empty
    """
    if not b:
        raise ValueError("Cannot condition on empty set")
    
    intersection = a & b
    return Fraction(len(intersection), len(b))


def bayes_update(
    prior_a: Fraction,
    likelihood_b_given_a: Fraction,
    evidence_b: Fraction
) -> Fraction:
    """
    Bayesian update: P(A | B) = P(B | A) · P(A) / P(B).
    
    In non-Archimedean probability, all three quantities can be
    infinitesimal, but the ratio is always a standard rational.
    
    Algorithm:
        1. Compute numerator = P(B|A) · P(A)
        2. Divide by P(B)
    
    Complexity: O(1) arithmetic
    
    Args:
        prior_a: P(A) — can be infinitesimal (represented as rational)
        likelihood_b_given_a: P(B | A)
        evidence_b: P(B) — must be nonzero
    
    Returns:
        P(A | B) as a rational number
    """
    if evidence_b == 0:
        raise ValueError("Evidence probability must be nonzero")
    
    return likelihood_b_given_a * prior_a / evidence_b


def inclusion_exclusion_two(
    mu_a: Fraction, mu_b: Fraction, mu_intersect: Fraction
) -> Fraction:
    """
    Compute μ(A ∪ B) using inclusion-exclusion.
    
    μ(A ∪ B) = μ(A) + μ(B) - μ(A ∩ B)
    
    This works in both Archimedean and non-Archimedean settings.
    
    Args:
        mu_a: μ(A)
        mu_b: μ(B)
        mu_intersect: μ(A ∩ B)
    
    Returns:
        μ(A ∪ B)
    """
    return mu_a + mu_b - mu_intersect


def archimedean_break_point(epsilon: float) -> int:
    """
    Find the smallest n such that n · ε ≥ 1.
    
    This demonstrates the Archimedean impossibility: in ℝ,
    for any ε > 0, such an n always exists.
    
    Algorithm:
        1. Return ⌈1/ε⌉
    
    Complexity: O(1)
    
    Args:
        epsilon: A positive real number
    
    Returns:
        Smallest n with n · ε ≥ 1
    """
    import math
    if epsilon <= 0:
        raise ValueError("ε must be positive")
    return math.ceil(1 / epsilon)


def uniform_measure_card(
    card: int, weight_coeff: Fraction = Fraction(1)
) -> Fraction:
    """
    Compute μ(S) = |S| · ε for a uniform measure.
    
    The coefficient of ε is |S| · weight_coeff.
    
    Args:
        card: Cardinality of the set
        weight_coeff: Coefficient of the infinitesimal weight (default 1)
    
    Returns:
        Coefficient of ε in the measure value
    """
    return Fraction(card) * weight_coeff


def ratio_of_sets(
    card_s: int, card_t: int
) -> Fraction:
    """
    Compute μ(S)/μ(T) for a uniform non-Archimedean measure.
    
    Since μ(S) = |S|·ε and μ(T) = |T|·ε, the ratio is |S|/|T|,
    independent of the choice of infinitesimal.
    
    This is the ratio_eq_card_ratio theorem in action.
    
    Args:
        card_s: |S|
        card_t: |T| (must be positive)
    
    Returns:
        |S|/|T| as a rational number
    """
    if card_t == 0:
        raise ValueError("Denominator set must be nonempty")
    return Fraction(card_s, card_t)


if __name__ == "__main__":
    # Quick test
    A = {1, 2, 3}
    B = {2, 3, 4, 5}
    
    print(f"μ(A) = {uniform_measure(A)}")
    print(f"μ(B) = {uniform_measure(B)}")
    print(f"P(A|B) = {conditional_probability(A, B)}")
    print(f"P(B|A) = {conditional_probability(B, A)}")
    print(f"Ratio |A|/|B| = {ratio_of_sets(len(A), len(B))}")
    print(f"Archimedean break for ε=0.01: n = {archimedean_break_point(0.01)}")
