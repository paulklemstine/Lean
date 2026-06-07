#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of core NAP space operations.
"""

from fractions import Fraction
from typing import FrozenSet, Set, Dict, Tuple, Optional, List


def nap_measure(event: FrozenSet[int], universe_size: int) -> Fraction:
    """Compute the uniform NAP measure of an event.

    μ(A) = |A| / |Ω| = |A| · ε where ε = 1/|Ω|

    Args:
        event: The event (subset of universe indices)
        universe_size: Size of the sample space

    Returns:
        The probability as an exact fraction
    """
    if universe_size <= 0:
        raise ValueError("Universe must be non-empty")
    return Fraction(len(event), universe_size)


def nap_conditional(
    a: FrozenSet[int], b: FrozenSet[int], universe_size: int
) -> Fraction:
    """Compute P(A|B) in a uniform NAP space.

    By the Ratio Stability Theorem, P(A|B) = |A ∩ B| / |B|.
    The infinitesimals cancel.

    Args:
        a: Event A
        b: Conditioning event B (must be non-empty)
        universe_size: Size of the sample space

    Returns:
        Conditional probability as exact fraction
    """
    if not b:
        raise ValueError("Cannot condition on empty event")
    intersection = a & b
    return Fraction(len(intersection), len(b))


def nap_bayes(
    a: FrozenSet[int], b: FrozenSet[int], universe_size: int
) -> Tuple[Fraction, Fraction, bool]:
    """Verify Bayes' theorem: P(A|B)·P(B) = P(B|A)·P(A).

    Args:
        a: Event A (must be non-empty)
        b: Event B (must be non-empty)
        universe_size: Size of the sample space

    Returns:
        Tuple of (LHS, RHS, verified)
    """
    if not a or not b:
        raise ValueError("Both events must be non-empty")

    p_a_given_b = nap_conditional(a, b, universe_size)
    p_b_given_a = nap_conditional(b, a, universe_size)
    p_a = nap_measure(a, universe_size)
    p_b = nap_measure(b, universe_size)

    lhs = p_a_given_b * p_b
    rhs = p_b_given_a * p_a
    return lhs, rhs, lhs == rhs


def nap_inclusion_exclusion(
    a: FrozenSet[int], b: FrozenSet[int], universe_size: int
) -> Tuple[Fraction, Fraction, bool]:
    """Verify inclusion-exclusion: μ(A∪B) = μ(A) + μ(B) - μ(A∩B).

    Returns:
        Tuple of (μ(A∪B), μ(A)+μ(B)-μ(A∩B), verified)
    """
    union = a | b
    intersection = a & b

    mu_union = nap_measure(union, universe_size)
    mu_a = nap_measure(a, universe_size)
    mu_b = nap_measure(b, universe_size)
    mu_inter = nap_measure(intersection, universe_size)

    rhs = mu_a + mu_b - mu_inter
    return mu_union, rhs, mu_union == rhs


def nap_independence_test(
    a: FrozenSet[int], b: FrozenSet[int], universe_size: int
) -> Tuple[bool, Fraction, Fraction]:
    """Test whether events A and B are independent.

    Independent iff μ(A ∩ B) = μ(A) · μ(B).

    Returns:
        Tuple of (independent, μ(A∩B), μ(A)·μ(B))
    """
    intersection = a & b
    mu_inter = nap_measure(intersection, universe_size)
    mu_product = nap_measure(a, universe_size) * nap_measure(b, universe_size)
    return mu_inter == mu_product, mu_inter, mu_product


def nap_complement(
    a: FrozenSet[int], universe_size: int
) -> Tuple[Fraction, Fraction, bool]:
    """Verify complement formula: μ(Ω\\A) = 1 - μ(A).

    Returns:
        Tuple of (μ(Ω\\A), 1-μ(A), verified)
    """
    mu_a = nap_measure(a, universe_size)
    complement_size = universe_size - len(a)
    mu_complement = Fraction(complement_size, universe_size)
    expected = Fraction(1) - mu_a
    return mu_complement, expected, mu_complement == expected


def construct_uniform_nap(n: int) -> Dict[str, object]:
    """Construct a uniform NAP space on {0, ..., n-1}.

    Returns a dictionary describing the space.
    """
    if n <= 0:
        raise ValueError("n must be positive")
    return {
        "universe": frozenset(range(n)),
        "universe_size": n,
        "atom": Fraction(1, n),
        "atom_positive": True,
        "total_measure": Fraction(1),
    }


def ratio_stability_demo(sizes: List[int]) -> List[Dict[str, object]]:
    """Demonstrate ratio stability across different universe sizes.

    For each size n, compute P(even|large) where:
    - even = {x : x is even}
    - large = {x : x >= n/2}

    Shows that the conditional probability stabilizes as n grows.
    """
    results = []
    for n in sizes:
        universe = frozenset(range(n))
        even = frozenset(x for x in range(n) if x % 2 == 0)
        large = frozenset(x for x in range(n) if x >= n // 2)

        cp = nap_conditional(even, large, n)
        results.append({
            "n": n,
            "atom": Fraction(1, n),
            "P(even|large)": cp,
            "P(even|large)_float": float(cp),
        })
    return results


if __name__ == "__main__":
    # Quick self-test
    n = 12
    space = construct_uniform_nap(n)
    print(f"Space: {space}")

    a = frozenset({2, 4, 6, 8, 10})
    b = frozenset({6, 7, 8, 9, 10, 11})

    print(f"\nBayes test: {nap_bayes(a, b, n)}")
    print(f"IE test: {nap_inclusion_exclusion(a, b, n)}")
    print(f"Independence: {nap_independence_test(a, b, n)}")
    print(f"Complement: {nap_complement(a, n)}")

    print(f"\nRatio stability:")
    for r in ratio_stability_demo([10, 100, 1000, 10000]):
        print(f"  n={r['n']:6d}: P(even|large) = {r['P(even|large)_float)']:.6f}"
              if 'P(even|large)_float)' in r else
              f"  n={r['n']:6d}: P(even|large) = {float(r['P(even|large)']):.6f}")
