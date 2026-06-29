#!/usr/bin/env python3
"""
algorithms.py — Certified Bounded Search Algorithms

Implements the algorithms justified by the bounded divisor search theorems:
1. Trial division with certified √N cutoff
2. Compositeness testing via bounded witness search
3. Complete factorization using recursive bounded search
4. Factor pair enumeration over certified finite regions
"""

import math
from typing import List, Tuple, Optional


def trial_division_bounded(N: int) -> Optional[int]:
    """
    Find a nontrivial divisor of N by searching only [2, √N].

    Correctness guarantee (certified by formal proof):
      If N ≥ 2 is composite, this function returns a divisor d with 2 ≤ d ≤ √N.
      If N is prime, returns None.

    Time complexity: O(√N)
    Space complexity: O(1)

    >>> trial_division_bounded(15)
    3
    >>> trial_division_bounded(17)
    >>> trial_division_bounded(100)
    2
    """
    if N < 2:
        return None
    sqrt_N = math.isqrt(N)
    for d in range(2, sqrt_N + 1):
        if N % d == 0:
            return d
    return None


def is_composite_certified(N: int) -> bool:
    """
    Test if N is composite using certified bounded search.

    The formal theorem `composite_iff_exists_divisor_le_sqrt` guarantees that
    searching [2, √N] is both sound and complete for compositeness detection.

    >>> is_composite_certified(4)
    True
    >>> is_composite_certified(7)
    False
    >>> is_composite_certified(561)  # Carmichael number
    True
    """
    if N < 2:
        return False
    return trial_division_bounded(N) is not None


def complete_factorization(N: int) -> List[int]:
    """
    Compute the complete prime factorization of N using recursive bounded search.

    At each step, we find the smallest prime factor p ≤ √N (certified to exist
    if N is composite), then recurse on N/p.

    Time complexity: O(√N) per factor extraction
    Space complexity: O(log N) for the factor list

    >>> complete_factorization(1)
    []
    >>> complete_factorization(12)
    [2, 2, 3]
    >>> complete_factorization(2310)
    [2, 3, 5, 7, 11]
    >>> complete_factorization(1000000007)
    [1000000007]
    """
    if N <= 1:
        return []
    factors = []
    while N > 1:
        d = trial_division_bounded(N)
        if d is None:
            factors.append(N)
            break
        factors.append(d)
        N //= d
    return factors


def factor_pairs_in_Icc(N: int) -> List[Tuple[int, int]]:
    """
    Enumerate all factor pairs (d, N/d) with d in Finset.Icc 2 (√N).

    This is the computational instantiation of `composite_detection_complete_on_Icc`:
    the search region is finite and certified to contain all compositeness witnesses.

    >>> factor_pairs_in_Icc(12)
    [(2, 6), (3, 4)]
    >>> factor_pairs_in_Icc(36)
    [(2, 18), (3, 12), (4, 9), (6, 6)]
    >>> factor_pairs_in_Icc(7)
    []
    """
    pairs = []
    sqrt_N = math.isqrt(N)
    for d in range(2, sqrt_N + 1):
        if N % d == 0:
            pairs.append((d, N // d))
    return pairs


def search_space_metrics(N: int) -> dict:
    """
    Compute search space metrics comparing naive vs bounded search.

    Returns a dictionary with:
    - naive_size: |[2, N-1]| = N - 2
    - bounded_size: |[2, √N]| = √N - 1
    - reduction_ratio: 1 - bounded/naive
    - speedup: naive/bounded

    >>> m = search_space_metrics(1000000)
    >>> m['bounded_size']
    999
    >>> m['naive_size']
    999998
    """
    sqrt_N = math.isqrt(N)
    naive = max(N - 2, 0)
    bounded = max(sqrt_N - 1, 0)
    return {
        'N': N,
        'sqrt_N': sqrt_N,
        'naive_size': naive,
        'bounded_size': bounded,
        'reduction_ratio': 1 - (bounded / naive) if naive > 0 else 0,
        'speedup': naive / bounded if bounded > 0 else float('inf'),
    }


def canonical_witness(N: int) -> Optional[Tuple[int, int]]:
    """
    Find the canonical bounded witness for compositeness of N.

    Returns (d, N/d) where d is the smallest divisor ≥ 2, guaranteed to satisfy
    d ≤ √N by the formal theorem `exists_small_factor_of_composite`.

    >>> canonical_witness(15)
    (3, 5)
    >>> canonical_witness(17)
    >>> canonical_witness(100)
    (2, 50)
    """
    d = trial_division_bounded(N)
    if d is None:
        return None
    return (d, N // d)


def main():
    """Demonstrate all algorithms with examples."""
    print("=" * 60)
    print("  CERTIFIED BOUNDED SEARCH ALGORITHMS")
    print("=" * 60)

    # Trial division
    print("\n1. Trial Division (Bounded)")
    test_cases = [4, 6, 15, 17, 49, 97, 100, 561, 1000003]
    for N in test_cases:
        d = trial_division_bounded(N)
        status = f"divisor = {d}" if d else "prime"
        print(f"   N = {N:>10}: {status}")

    # Complete factorization
    print("\n2. Complete Factorization")
    for N in [12, 360, 2310, 1000000007, 123456789]:
        factors = complete_factorization(N)
        product = 1
        for f in factors:
            product *= f
        assert product == N, f"Factorization failed for {N}"
        print(f"   {N} = {' × '.join(map(str, factors))}")

    # Factor pairs
    print("\n3. Factor Pairs in Certified Region")
    for N in [12, 36, 100, 360]:
        pairs = factor_pairs_in_Icc(N)
        print(f"   N = {N}, √N = {math.isqrt(N)}: {pairs}")

    # Search space metrics
    print("\n4. Search Space Reduction")
    for N in [100, 10000, 1000000, 10**9, 10**12]:
        m = search_space_metrics(N)
        print(f"   N = {N:>15}: naive = {m['naive_size']:>15,}, "
              f"bounded = {m['bounded_size']:>8,}, "
              f"speedup = {m['speedup']:>10,.0f}x")

    print()


if __name__ == "__main__":
    main()
