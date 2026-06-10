#!/usr/bin/env python3
"""
Algorithms for Fermat Near-Miss Analysis

Type-hinted implementations of the core algorithms used in the
Fermat near-miss research.
"""

from typing import List, Tuple, Optional
import math


def fermat_defect(n: int, a: int, b: int, c: int) -> int:
    """
    Compute the Fermat defect: a^n + b^n - c^n.

    Parameters:
        n: The exponent (≥ 2 for interesting cases)
        a, b, c: Positive integers forming the triple

    Returns:
        The signed defect. Zero iff (a,b,c) is a Fermat solution.
    """
    return a**n + b**n - c**n


def mixed_term_sum(n: int, a: int, b: int) -> int:
    """
    Compute the mixed-term sum: (a+b)^n - a^n - b^n.

    This equals the sum of all mixed binomial terms C(n,k) * a^k * b^(n-k)
    for 0 < k < n. Always positive for a, b > 0 and n ≥ 2.

    Parameters:
        n: The exponent (≥ 2)
        a, b: Positive integers

    Returns:
        The mixed-term sum (always positive for valid inputs)
    """
    return (a + b)**n - a**n - b**n


def radical(n: int) -> int:
    """
    Compute the radical of n: the product of its distinct prime factors.

    The radical is the key quantity in the ABC conjecture:
    for a + b = c with gcd(a,b) = 1, the conjecture says
    c < rad(abc)^(1+ε) for all ε > 0 with finitely many exceptions.

    Parameters:
        n: A positive integer

    Returns:
        The radical of n
    """
    if n <= 1:
        return max(n, 1)
    rad = 1
    d = 2
    temp = abs(n)
    while d * d <= temp:
        if temp % d == 0:
            rad *= d
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        rad *= temp
    return rad


def quality_ratio(n: int, a: int, b: int, c: int) -> float:
    """
    Compute the Fermat quality ratio |a^n + b^n - c^n| / c^n.

    Smaller values indicate better near-misses. The unit family
    (1, c, c) achieves quality 1/c^n, which vanishes as c → ∞.

    Parameters:
        n: The exponent
        a, b, c: The triple (c must be positive)

    Returns:
        The quality ratio in [0, ∞)
    """
    if c == 0:
        return float('inf')
    return abs(fermat_defect(n, a, b, c)) / c**n


def power_gap_bounds(c: int, n: int) -> Tuple[int, int, int]:
    """
    Compute the power gap and its sandwich bounds.

    Returns (lower_bound, gap, upper_bound) where:
        lower = n * c^(n-1)
        gap = (c+1)^n - c^n
        upper = n * (c+1)^(n-1)

    The sandwich theorem guarantees lower ≤ gap ≤ upper.

    Parameters:
        c: Base (non-negative integer)
        n: Exponent (≥ 1)

    Returns:
        Tuple (lower, gap, upper)
    """
    lower = n * c**(n - 1)
    gap = (c + 1)**n - c**n
    upper = n * (c + 1)**(n - 1)
    return lower, gap, upper


def find_best_near_misses(
    n: int,
    N: int,
    count: int = 10,
    coprime_only: bool = False
) -> List[Tuple[int, int, int, int, float]]:
    """
    Find the best near-misses for x^n + y^n ≈ z^n up to bound N.

    Algorithm:
    1. For each c from 2 to N, compute c^n
    2. For each pair (a, b) with 1 ≤ a ≤ b ≤ c, compute |a^n + b^n - c^n|
    3. Track the smallest nonzero defects

    Parameters:
        n: The exponent (≥ 3 for FLT relevance)
        N: Upper bound on triple entries
        count: Number of best misses to return
        coprime_only: If True, only consider triples with gcd = 1

    Returns:
        List of (a, b, c, defect, quality) tuples, sorted by quality
    """
    results: List[Tuple[int, int, int, int, float]] = []

    for c in range(2, N + 1):
        cn = c**n
        for a in range(1, c + 1):
            an = a**n
            for b in range(a, c + 1):
                if coprime_only and math.gcd(math.gcd(a, b), c) != 1:
                    continue
                d = an + b**n - cn
                if d == 0:
                    continue
                q = abs(d) / cn
                results.append((a, b, c, d, q))

    results.sort(key=lambda x: x[4])
    return results[:count]


def near_miss_density(n: int, N: int, D: int) -> float:
    """
    Compute the near-miss density: fraction of triples with |defect| ≤ D.

    Parameters:
        n: The exponent
        N: Bound on triple entries
        D: Maximum allowed defect

    Returns:
        Density in [0, 1]
    """
    total = 0
    hits = 0
    for a in range(1, N + 1):
        for b in range(1, N + 1):
            for c in range(1, N + 1):
                total += 1
                if abs(fermat_defect(n, a, b, c)) <= D:
                    hits += 1
    return hits / total if total > 0 else 0.0


def abc_quality_triple(a: int, b: int, c: int) -> float:
    """
    Compute the ABC quality of a triple: log(max(a,b,c)) / log(rad(a*b*c)).

    High quality triples are rare and relate to deep number theory.
    The ABC conjecture says the quality is bounded for coprime triples.

    Parameters:
        a, b, c: Positive integers

    Returns:
        The ABC quality
    """
    r = radical(a * b * c)
    if r <= 1:
        return 0.0
    return math.log(max(a, b, c)) / math.log(r)


if __name__ == "__main__":
    # Quick self-test
    assert fermat_defect(3, 1, 1, 1) == 1
    assert fermat_defect(2, 3, 4, 5) == 0
    assert mixed_term_sum(2, 1, 1) == 2  # (1+1)^2 - 1 - 1 = 2
    assert radical(12) == 6
    assert radical(30) == 30

    print("All self-tests passed.")

    print("\nTop 10 near-misses for n=3, N=30:")
    for a, b, c, d, q in find_best_near_misses(3, 30, 10, coprime_only=True):
        print(f"  ({a}, {b}, {c}): defect={d}, quality={q:.6f}")
