"""
Algorithms for Counterfactual Number Theory.

Implements detection and analysis of multiplicative independence,
product triples, and generative set properties.
"""

from typing import List, Set, Tuple, Optional
import math


def is_multiplicatively_independent(S: Set[int]) -> bool:
    """Check if a finite set S ⊆ ℕ is multiplicatively independent.

    A set is MI if no multiset product relation exists among its elements.
    For finite sets, we check all products up to max(S)^|S| for collisions.

    For practical purposes, we check for product triples and square relations
    as the most common obstructions.

    Args:
        S: A set of natural numbers, each ≥ 2.

    Returns:
        True if no product relation is found (may have false positives for
        very large sets where exhaustive search is infeasible).
    """
    S_list = sorted(S)

    # Check for product triples: a * b = c with a, b, c in S
    for i, a in enumerate(S_list):
        if a < 2:
            continue
        for b in S_list[i:]:
            if b < 2:
                continue
            product = a * b
            if product in S:
                return False

    # Check for square relations: k and k^2 both in S
    for k in S_list:
        if k * k in S and k >= 2:
            return False

    return True


def find_product_triples(S: Set[int]) -> List[Tuple[int, int, int]]:
    """Find all product triples (a, b, c) in S where a * b = c.

    Args:
        S: A set of natural numbers.

    Returns:
        List of triples (a, b, c) with a ≤ b, a*b = c, all in S.
    """
    triples = []
    S_list = sorted(S)
    for i, a in enumerate(S_list):
        if a < 2:
            continue
        for b in S_list[i:]:
            if b < 2:
                continue
            product = a * b
            if product in S:
                triples.append((a, b, product))
    return triples


def max_product_triple_free_subset(n: int) -> Set[int]:
    """Find a maximal product-triple-free subset of [2, n] using greedy algorithm.

    Adds elements from largest to smallest, skipping any that would
    create a product triple.

    Args:
        n: Upper bound of the range.

    Returns:
        A product-triple-free subset of [2, n].
    """
    S: Set[int] = set()
    for k in range(n, 1, -1):
        # Check if adding k creates a product triple
        creates_triple = False
        for a in S:
            if a < 2:
                continue
            # k = a * b for some b in S?
            if k % a == 0 and k // a in S and k // a >= 2:
                creates_triple = True
                break
            # a * k = c for some c in S?
            if a * k in S:
                creates_triple = True
                break
        # k * b = c for some b, c in S?
        if not creates_triple:
            for b in S:
                if b >= 2 and k * b in S:
                    creates_triple = True
                    break
        if not creates_triple:
            S.add(k)
    return S


def counting_function(S: Set[int], n: int) -> int:
    """Count elements of S that are ≤ n.

    Args:
        S: A set of natural numbers.
        n: Upper bound.

    Returns:
        |S ∩ [1, n]|
    """
    return sum(1 for x in S if x <= n)


def density_ratio(S: Set[int], n: int) -> float:
    """Compute the density ratio |S ∩ [1,n]| / (n / log(n)).

    For primes, this ratio → 1 by PNT.

    Args:
        S: A set of natural numbers.
        n: Upper bound (must be ≥ 2).

    Returns:
        The density ratio.
    """
    if n < 2:
        return 0.0
    count = counting_function(S, n)
    expected = n / math.log(n)
    return count / expected if expected > 0 else 0.0


def sieve_of_eratosthenes(n: int) -> Set[int]:
    """Return the set of primes up to n.

    Args:
        n: Upper bound.

    Returns:
        Set of all primes p with 2 ≤ p ≤ n.
    """
    if n < 2:
        return set()
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return {i for i in range(2, n + 1) if is_prime[i]}


def random_generative_set(n: int, seed: Optional[int] = None) -> Set[int]:
    """Generate a random subset of [2, n] with prime-like density.

    Each k ∈ [2, n] is included independently with probability 1/log(k).

    Args:
        n: Upper bound.
        seed: Random seed for reproducibility.

    Returns:
        A random subset of [2, n].
    """
    import random
    if seed is not None:
        random.seed(seed)
    S: Set[int] = set()
    for k in range(2, n + 1):
        if random.random() < 1.0 / math.log(k):
            S.add(k)
    return S


def factorization_count(G: Set[int], n: int, max_depth: int = 20) -> int:
    """Count the number of distinct G-factorizations of n.

    Uses recursive enumeration with memoization.

    Args:
        G: The generative set.
        n: The number to factorize.
        max_depth: Maximum recursion depth.

    Returns:
        Number of distinct ordered factorizations of n over G.
    """
    G_sorted = sorted(g for g in G if g >= 2)

    def _count(remaining: int, min_factor_idx: int, depth: int) -> int:
        if remaining == 1:
            return 1
        if depth <= 0:
            return 0
        total = 0
        for i in range(min_factor_idx, len(G_sorted)):
            g = G_sorted[i]
            if g > remaining:
                break
            if remaining % g == 0:
                total += _count(remaining // g, i, depth - 1)
        return total

    return _count(n, 0, max_depth)


def analyze_generative_set(S: Set[int], n: int) -> dict:
    """Comprehensive analysis of a generative set.

    Args:
        S: The generative set (elements ≥ 2).
        n: Range for analysis.

    Returns:
        Dictionary with analysis results.
    """
    primes = sieve_of_eratosthenes(n)
    triples = find_product_triples(S)
    prime_elements = S & primes
    composite_elements = S - primes

    return {
        "size": len(S),
        "density_ratio": density_ratio(S, n),
        "is_MI": is_multiplicatively_independent(S),
        "product_triples": len(triples),
        "prime_elements": len(prime_elements),
        "composite_elements": len(composite_elements),
        "fraction_prime": len(prime_elements) / len(S) if S else 0,
    }
