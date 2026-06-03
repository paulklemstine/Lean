#!/usr/bin/env python3
"""
Algorithms for Product Collision Theory

Type-hinted implementations of the core algorithms for studying
generator sets, product collisions, and the collision spectrum.
"""

from collections import defaultdict
from math import gcd, log, sqrt
from typing import Optional


def detect_collisions(S: set[int]) -> list[tuple[int, int, int, int]]:
    """
    Detect all product collisions in a generator set S.

    A product collision is a quadruple (a, b, c, d) with a,b,c,d ∈ S,
    a*b = c*d, and {a,b} ≠ {c,d} as multisets.

    Time: O(|S|² log |S|)
    Space: O(|S|²)

    Args:
        S: A set of natural numbers (elements < 2 are ignored)

    Returns:
        List of collision quadruples (a, b, c, d) with a ≤ b, c ≤ d
    """
    products: dict[int, list[tuple[int, int]]] = defaultdict(list)
    elems = sorted(e for e in S if e >= 2)

    for i, a in enumerate(elems):
        for j in range(i, len(elems)):
            b = elems[j]
            products[a * b].append((a, b))

    collisions: list[tuple[int, int, int, int]] = []
    for pairs in products.values():
        for i in range(len(pairs)):
            for j in range(i + 1, len(pairs)):
                a, b = pairs[i]
                c, d = pairs[j]
                if (a, b) != (c, d):
                    collisions.append((a, b, c, d))
    return collisions


def is_collision_free(S: set[int]) -> bool:
    """Check if a set has no product collisions. O(|S|² log |S|)."""
    return len(detect_collisions(S)) == 0


def is_product_free(S: set[int]) -> bool:
    """Check if no product of two elements (≥2) lands in S. O(|S|²)."""
    elems = [e for e in S if e >= 2]
    for a in elems:
        for b in elems:
            if a * b in S:
                return False
    return True


def has_unique_factorization(S: set[int], max_n: int = 10000) -> bool:
    """
    Check unique factorization for S up to max_n by brute force.

    Enumerates all S-factorizations of each number up to max_n and
    checks for duplicates.

    Time: O(max_n * |S|^(log(max_n)/log(min(S))))
    """
    elems = sorted(e for e in S if e >= 2)
    if not elems:
        return True

    # For each n, find all factorizations
    factorizations: dict[int, list[tuple[int, ...]]] = defaultdict(list)

    def enumerate_factorizations(
        remaining: int, min_elem: int, current: list[int]
    ) -> None:
        if remaining == 1:
            factorizations[1].append(tuple(sorted(current))) if current else None
            return
        # Current product
        prod = 1
        for x in current:
            prod *= x
        if prod > max_n:
            return
        if prod > 1:
            factorizations[prod].append(tuple(sorted(current)))
        for e in elems:
            if e >= min_elem and prod * e <= max_n:
                current.append(e)
                enumerate_factorizations(remaining, e, current)
                current.pop()

    # Generate factorizations of all lengths
    for length in range(1, int(log(max_n) / log(min(elems))) + 2 if elems else 1):
        for e in elems:
            enumerate_factorizations(length, e, [e])

    for n, facts in factorizations.items():
        if len(set(facts)) > 1:
            return False
    return True


def collision_spectrum_level(
    S: set[int], k: int, max_n: int = 10000
) -> set[int]:
    """
    Compute the collision spectrum Σ_k(S): the set of numbers with
    two distinct S-factorizations of length exactly k.

    Args:
        S: Generator set
        k: Factorization length
        max_n: Upper bound for products to consider

    Returns:
        Set of numbers in the collision spectrum at level k
    """
    elems = sorted(e for e in S if e >= 2)
    factorizations: dict[int, set[tuple[int, ...]]] = defaultdict(set)

    def gen_multisets(
        remaining: int, min_idx: int, current: list[int], current_prod: int
    ) -> None:
        if remaining == 0:
            if current_prod <= max_n:
                factorizations[current_prod].add(tuple(current))
            return
        for i in range(min_idx, len(elems)):
            new_prod = current_prod * elems[i]
            if new_prod > max_n:
                break
            current.append(elems[i])
            gen_multisets(remaining - 1, i, current, new_prod)
            current.pop()

    gen_multisets(k, 0, [], 1)

    return {n for n, facts in factorizations.items() if len(facts) >= 2}


def collision_count(S: set[int]) -> int:
    """Count the number of product collisions in S."""
    return len(detect_collisions(S))


def pairwise_coprime_check(S: set[int]) -> tuple[bool, Optional[tuple[int, int]]]:
    """
    Check if S is pairwise coprime. If not, return a non-coprime pair.

    Returns:
        (True, None) if pairwise coprime, (False, (a, b)) otherwise
    """
    elems = sorted(S)
    for i in range(len(elems)):
        for j in range(i + 1, len(elems)):
            if gcd(elems[i], elems[j]) > 1:
                return False, (elems[i], elems[j])
    return True, None


def construct_collision_set(primes: list[int]) -> set[int]:
    """
    Construct a product-free set with collisions from 4 primes.

    Given primes [p, q, r, s], returns {p*q, p*s, q*r, r*s}
    which has the collision (p*q)*(r*s) = (p*s)*(q*r).

    Args:
        primes: List of 4 distinct primes

    Returns:
        A product-free set with at least one collision
    """
    assert len(primes) >= 4
    p, q, r, s = primes[:4]
    return {p * q, p * s, q * r, r * s}


def estimate_collision_threshold(N: int, n_samples: int = 1000) -> float:
    """
    Estimate the set size k at which 50% of random k-subsets of
    {2,...,N} have at least one collision.

    Uses binary search with random sampling.

    Returns:
        Estimated threshold k₀ where P(collision) ≈ 0.5
    """
    import random

    universe = list(range(2, N + 1))

    def collision_prob(k: int) -> float:
        if k > len(universe):
            return 1.0
        count = 0
        for _ in range(n_samples):
            S = set(random.sample(universe, k))
            if detect_collisions(S):
                count += 1
        return count / n_samples

    # Binary search for threshold
    lo, hi = 3, min(len(universe), int(2 * sqrt(N)))
    while lo < hi:
        mid = (lo + hi) // 2
        prob = collision_prob(mid)
        if prob < 0.5:
            lo = mid + 1
        else:
            hi = mid

    return lo


if __name__ == "__main__":
    # Quick self-test
    S = {6, 10, 21, 35}
    print(f"Collisions in {{6,10,21,35}}: {detect_collisions(S)}")
    print(f"Product-free: {is_product_free(S)}")
    print(f"Collision-free: {is_collision_free(S)}")

    primes_20 = {2, 3, 5, 7, 11, 13, 17, 19}
    print(f"\nCollisions in primes up to 20: {detect_collisions(primes_20)}")
    print(f"Collision-free: {is_collision_free(primes_20)}")

    # Construct collision set from primes
    S_constructed = construct_collision_set([2, 3, 5, 7])
    print(f"\nConstructed set from [2,3,5,7]: {sorted(S_constructed)}")
    print(f"Collisions: {detect_collisions(S_constructed)}")
