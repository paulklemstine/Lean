#!/usr/bin/env python3
"""
algorithms.py — Algorithms for prime-gap analysis around square intervals.

Implements the computational components of the Legendre conjecture framework:
  1. Efficient prime sieve for square intervals
  2. Cramér-model expectation computation
  3. Maximal prime gap analysis
  4. Finite verification engine for Legendre's conjecture
  5. Gap-threshold analysis
"""

import math
from typing import List, Tuple, Optional, Dict
from collections import defaultdict


def sieve_of_eratosthenes(limit: int) -> List[bool]:
    """Return a boolean array where is_prime[i] is True iff i is prime.
    
    Time: O(n log log n), Space: O(n)
    
    Args:
        limit: Upper bound (inclusive) for the sieve.
    
    Returns:
        List of booleans indexed 0..limit.
    """
    if limit < 2:
        return [False] * (limit + 1)
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(math.isqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return is_prime


def square_interval_primes(n: int, sieve: Optional[List[bool]] = None) -> List[int]:
    """Return all primes in the open interval (n², (n+1)²).
    
    Args:
        n: The base integer.
        sieve: Optional precomputed sieve covering up to (n+1)².
    
    Returns:
        Sorted list of primes strictly between n² and (n+1)².
    """
    lo = n * n + 1
    hi = (n + 1) * (n + 1)
    if sieve is not None:
        return [k for k in range(lo, hi) if sieve[k]]
    else:
        # Use trial division for small cases
        result = []
        for k in range(lo, hi):
            if k < 2:
                continue
            if k == 2 or k == 3:
                result.append(k)
                continue
            if k % 2 == 0 or k % 3 == 0:
                continue
            d = 5
            is_p = True
            while d * d <= k:
                if k % d == 0 or k % (d + 2) == 0:
                    is_p = False
                    break
                d += 6
            if is_p:
                result.append(k)
        return result


def cramer_expectation(n: int) -> float:
    """Compute the Cramér-model expected prime count in (n², (n+1)²).
    
    E_n = Σ_{k=n²+1}^{(n+1)²-1} 1/log(k)
    
    This is the sum of independent Bernoulli parameters in the Cramér
    random model where integer k is "prime" with probability 1/log(k).
    
    Time: O(n), Space: O(1)
    
    Args:
        n: The base integer (n ≥ 1).
    
    Returns:
        The expected count E_n.
    """
    total = 0.0
    for k in range(n * n + 1, (n + 1) * (n + 1)):
        if k >= 2:
            total += 1.0 / math.log(k)
    return total


def cramer_lower_bound(n: int) -> float:
    """Compute the rigorous lower bound (2n-1)/log((n+1)²).
    
    This is the formally verified lower bound on E_n.
    
    Args:
        n: The base integer (n ≥ 2).
    
    Returns:
        The lower bound value.
    """
    if n < 2:
        return 0.0
    return (2 * n - 1) / math.log((n + 1) ** 2)


def maximal_prime_gaps_near_squares(max_n: int) -> List[Tuple[int, int, int, int]]:
    """Find the maximal prime gap within each square interval.
    
    For each n, computes the largest gap between consecutive primes
    in (n², (n+1)²), and tracks where the largest gaps occur.
    
    Time: O(max_n² log log max_n²), Space: O(max_n²)
    
    Args:
        max_n: Check intervals for n = 1, ..., max_n.
    
    Returns:
        List of (n, max_gap, prime_before_gap, prime_after_gap) for each n.
    """
    limit = (max_n + 1) ** 2
    sieve = sieve_of_eratosthenes(limit)
    
    results = []
    for n in range(1, max_n + 1):
        primes = square_interval_primes(n, sieve)
        if len(primes) < 2:
            max_gap = 0
            results.append((n, max_gap, 0, 0))
            continue
        
        max_gap = 0
        gap_start = primes[0]
        gap_end = primes[1]
        for i in range(1, len(primes)):
            g = primes[i] - primes[i - 1]
            if g > max_gap:
                max_gap = g
                gap_start = primes[i - 1]
                gap_end = primes[i]
        results.append((n, max_gap, gap_start, gap_end))
    
    return results


def gap_threshold_analysis(max_m: int) -> Tuple[bool, int, int, int]:
    """Check if every m in [1, max_m] has a prime in (m, m + 2√m + 1].
    
    This tests the gap hypothesis used in the reduction theorem.
    
    Time: O(max_m * √max_m), Space: O(max_m)
    
    Args:
        max_m: Upper bound for m.
    
    Returns:
        (all_pass, first_failure, num_checked, num_failures)
    """
    limit = max_m + 2 * int(math.isqrt(max_m)) + 2
    sieve = sieve_of_eratosthenes(limit)
    
    first_failure = -1
    num_failures = 0
    
    for m in range(1, max_m + 1):
        L = 2 * int(math.isqrt(m)) + 1
        found = False
        for p in range(m + 1, m + L + 1):
            if p <= limit and sieve[p]:
                found = True
                break
        if not found:
            num_failures += 1
            if first_failure == -1:
                first_failure = m
    
    return (num_failures == 0, first_failure, max_m, num_failures)


def verify_legendre_exhaustive(max_n: int) -> Dict[str, object]:
    """Exhaustively verify Legendre's conjecture for n = 1 to max_n.
    
    Also collects statistics about prime counts per interval.
    
    Time: O(max_n² log log max_n²), Space: O(max_n²)
    
    Args:
        max_n: Upper bound for verification.
    
    Returns:
        Dictionary with verification results and statistics.
    """
    limit = (max_n + 1) ** 2
    sieve = sieve_of_eratosthenes(limit)
    
    min_count = float('inf')
    min_n = -1
    max_count = 0
    max_count_n = -1
    total_primes = 0
    all_verified = True
    first_failure = -1
    counts = []
    
    for n in range(1, max_n + 1):
        primes = square_interval_primes(n, sieve)
        c = len(primes)
        counts.append(c)
        total_primes += c
        
        if c == 0:
            all_verified = False
            if first_failure == -1:
                first_failure = n
        
        if c < min_count:
            min_count = c
            min_n = n
        if c > max_count:
            max_count = c
            max_count_n = n
    
    return {
        "verified": all_verified,
        "max_n": max_n,
        "first_failure": first_failure,
        "min_count": min_count,
        "min_count_at": min_n,
        "max_count": max_count,
        "max_count_at": max_count_n,
        "avg_count": total_primes / max_n,
        "total_primes": total_primes,
    }


def cramer_calibration(max_n: int, sample_step: int = 1) -> List[Tuple[int, int, float, float]]:
    """Compare actual prime counts with Cramér predictions.
    
    Computes the ratio actual/expected for sampled values of n.
    
    Args:
        max_n: Upper bound.
        sample_step: Step size for sampling.
    
    Returns:
        List of (n, actual, expected, ratio) tuples.
    """
    limit = (max_n + 1) ** 2
    sieve = sieve_of_eratosthenes(limit)
    
    results = []
    for n in range(2, max_n + 1, sample_step):
        actual = len(square_interval_primes(n, sieve))
        expected = cramer_expectation(n)
        ratio = actual / expected if expected > 0 else 0.0
        results.append((n, actual, expected, ratio))
    
    return results


if __name__ == "__main__":
    print("=== Gap Threshold Analysis ===")
    result = gap_threshold_analysis(10000)
    print(f"All m ∈ [1, {result[2]}] have prime in (m, m+2√m+1]: {result[0]}")
    if not result[0]:
        print(f"First failure: m = {result[1]}, total failures: {result[3]}")
    
    print("\n=== Legendre Verification ===")
    stats = verify_legendre_exhaustive(1000)
    print(f"Verified for n = 1..{stats['max_n']}: {stats['verified']}")
    print(f"Min prime count: {stats['min_count']} at n = {stats['min_count_at']}")
    print(f"Max prime count: {stats['max_count']} at n = {stats['max_count_at']}")
    print(f"Average prime count: {stats['avg_count']:.2f}")
    
    print("\n=== Cramér Calibration (sampled) ===")
    cal = cramer_calibration(500, sample_step=50)
    print(f"{'n':>6} {'actual':>8} {'expected':>10} {'ratio':>8}")
    for n, actual, expected, ratio in cal:
        print(f"{n:>6} {actual:>8} {expected:>10.2f} {ratio:>8.3f}")
