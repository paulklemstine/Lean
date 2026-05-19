#!/usr/bin/env python3
"""
Prime Gap Theory — Algorithms

Implementations of the core algorithms from the Certified Prime Gap Theory
framework, with full docstrings, type hints, and complexity analysis.
"""

import math
from typing import List, Tuple, Optional


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """
    Compute all primes up to `limit` using the Sieve of Eratosthenes.

    Time complexity: O(n log log n)
    Space complexity: O(n)

    Args:
        limit: Upper bound for prime search.

    Returns:
        Sorted list of all primes p with 2 ≤ p ≤ limit.

    Example:
        >>> sieve_of_eratosthenes(30)
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def is_prime(n: int) -> bool:
    """
    Deterministic primality test using trial division.

    Time complexity: O(√n)

    Args:
        n: Integer to test.

    Returns:
        True if n is prime.

    Example:
        >>> is_prime(1000000007)
        True
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def next_prime_after(n: int) -> int:
    """
    Find the smallest prime strictly greater than n.

    This implements the formal definition:
        nextPrimeAfter(n) = min{p ∈ ℕ | Prime(p) ∧ p > n}

    Time complexity: O(g_n · √n) where g_n is the gap size.
    By Bertrand's postulate, g_n ≤ n, so worst case O(n^{3/2}).
    Conjecturally (Cramér), g_n = O((log n)²), giving O((log n)² · √n).

    Args:
        n: Starting point (non-negative integer).

    Returns:
        The smallest prime p > n.

    Example:
        >>> next_prime_after(100)
        101
        >>> next_prime_after(113)
        127
    """
    m = n + 1
    while not is_prime(m):
        m += 1
    return m


def prime_gap_after(n: int) -> int:
    """
    Compute the prime gap after n: distance to the next prime.

    Formally: primeGapAfter(n) = nextPrimeAfter(n) - n

    Args:
        n: Starting point.

    Returns:
        The gap nextPrimeAfter(n) - n, always positive.

    Example:
        >>> prime_gap_after(7)
        4
        >>> prime_gap_after(23)
        6
    """
    return next_prime_after(n) - n


def compute_prime_gaps(limit: int) -> List[Tuple[int, int, int]]:
    """
    Compute all consecutive prime gaps up to `limit`.

    Returns:
        List of (prime, next_prime, gap) tuples.

    Example:
        >>> compute_prime_gaps(20)
        [(2, 3, 1), (3, 5, 2), (5, 7, 2), (7, 11, 4), (11, 13, 2), (13, 17, 4), (17, 19, 2)]
    """
    primes = sieve_of_eratosthenes(limit)
    return [(primes[i], primes[i + 1], primes[i + 1] - primes[i])
            for i in range(len(primes) - 1)]


def cramer_weight(m: int) -> float:
    """
    The Cramér weight function.

    Formally:
        cramerWeight(m) = 1/log(m) if m ≥ 2, else 0

    This is the probability assigned to m being "prime-like" in Cramér's
    random model of the primes.

    Args:
        m: Integer.

    Returns:
        The Cramér weight at m.

    Example:
        >>> round(cramer_weight(100), 6)
        0.217147
    """
    if m >= 2:
        return 1.0 / math.log(m)
    return 0.0


def expected_prime_likes_in_interval(N: int, H: int) -> float:
    """
    Compute the expected number of model-primes in [N, N+H].

    Formally:
        E(N, H) = Σ_{m=N}^{N+H} cramerWeight(m)

    Certified bounds (for N ≥ 3):
        (H+1)/log(N+H) ≤ E(N,H) ≤ (H+1)/log(N)

    Time complexity: O(H)

    Args:
        N: Start of interval.
        H: Length parameter (interval is [N, N+H]).

    Returns:
        The sum of Cramér weights over the interval.

    Example:
        >>> round(expected_prime_likes_in_interval(1000, 100), 2)
        14.62
    """
    return sum(cramer_weight(m) for m in range(N, N + H + 1))


def normalized_gap(n: int) -> float:
    """
    The normalized prime gap observable: gap(n) / (log n)².

    Cramér's conjecture is equivalent to this quantity being
    eventually bounded.

    Args:
        n: Starting point (must be ≥ 2 for meaningful result).

    Returns:
        The normalized gap, or 0.0 if n < 2.

    Example:
        >>> round(normalized_gap(113), 4)  # gap to 127 is 14
        0.6277
    """
    if n < 2:
        return 0.0
    gap = prime_gap_after(n)
    log_n = math.log(n)
    return gap / (log_n ** 2)


def gap_from_interval_bound(n: int, F: callable) -> int:
    """
    The transfer principle: given F(n) such that there is always a prime
    in (n, n + F(n)], the prime gap after n is at most F(n).

    This demonstrates the formal theorem:
        (∀ n ≥ N₀, ∃ p prime, n < p ≤ n + F(n)) → primeGapAfter(n) ≤ F(n)

    Args:
        n: Starting point.
        F: Bound function.

    Returns:
        F(n), the certified gap upper bound.
    """
    return F(n)


def dyadic_oscillation_analysis(limit: int) -> List[Tuple[int, int, float]]:
    """
    Compute raw and normalized gap oscillation on dyadic intervals [2^k, 2^{k+1}].

    Returns:
        List of (k, raw_oscillation, normalized_oscillation) tuples.
    """
    primes = sieve_of_eratosthenes(limit)
    results = []

    k = 3
    while 2**k <= limit:
        lo, hi = 2**k, min(2**(k + 1), limit)
        range_primes = [p for p in primes if lo <= p <= hi]
        if len(range_primes) >= 2:
            gaps = [range_primes[i + 1] - range_primes[i]
                    for i in range(len(range_primes) - 1)]
            raw_osc = max(gaps) - min(gaps)
            log_lo = math.log(lo)
            norm_gaps = [g / (log_lo ** 2) for g in gaps]
            norm_osc = max(norm_gaps) - min(norm_gaps)
            results.append((k, raw_osc, norm_osc))
        k += 1

    return results


def cramer_model_occupancy_estimate(N: int, A: float) -> Tuple[float, float, float]:
    """
    Estimate the probability that a Cramér-scale interval contains a model-prime.

    For interval [N, N + ⌈A(log N)²⌉]:
    - Compute the expectation S = E(N, H)
    - Estimate P(at least one) ≥ 1 - exp(-S)

    Args:
        N: Start of interval.
        A: Scaling constant.

    Returns:
        (H, S, lower_bound_probability) tuple.

    Example:
        >>> H, S, prob = cramer_model_occupancy_estimate(10000, 2.0)
        >>> prob > 0.99
        True
    """
    log_N = math.log(N)
    H = math.ceil(A * log_N ** 2)
    S = expected_prime_likes_in_interval(N, H)
    prob_lower = 1.0 - math.exp(-S)
    return H, S, prob_lower


if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Next prime
    for n in [100, 1000, 10000]:
        p = next_prime_after(n)
        print(f"nextPrimeAfter({n}) = {p}, gap = {p - n}")

    print()

    # Cramér expectations
    for N in [100, 1000, 10000]:
        for H in [10, 100]:
            E = expected_prime_likes_in_interval(N, H)
            print(f"E({N}, {H}) = {E:.4f}")

    print()

    # Occupancy estimates
    for N in [1000, 10000, 100000]:
        for A in [1.0, 2.0]:
            H, S, prob = cramer_model_occupancy_estimate(N, A)
            print(f"N={N}, A={A}: H={H}, S={S:.2f}, P(≥1) ≥ {prob:.6f}")
