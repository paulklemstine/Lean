#!/usr/bin/env python3
"""
Algorithms for Prime Gap Analysis and Cramér's Conjecture

Type-hinted implementations of key algorithms formalized in the Lean proofs.
"""

import math
from typing import List, Optional, Tuple


def is_prime(n: int) -> bool:
    """Primality test by trial division. O(√n) time."""
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


def next_prime(n: int) -> int:
    """
    Find the smallest prime strictly greater than n.
    
    Corresponds to the Lean definition `nextPrime`.
    Guaranteed to terminate by Euclid's theorem (infinitely many primes).
    By Bertrand's postulate, terminates within n steps for n ≥ 1.
    """
    candidate = n + 1
    while not is_prime(candidate):
        candidate += 1
    return candidate


def prime_gap(n: int) -> int:
    """
    Compute the prime gap at n: nextPrime(n) - n.
    
    Corresponds to the Lean definition `primeGap`.
    """
    return next_prime(n) - n


def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes. Returns all primes up to limit."""
    if limit < 2:
        return []
    sieve = bytearray(b'\x01') * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(math.isqrt(limit)) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i in range(2, limit + 1) if sieve[i]]


def cramer_density(n: int) -> float:
    """
    Cramér model density: probability 1/log(n) for n ≥ 2.
    
    Corresponds to `CramerRandomModel.density` in Lean.
    """
    if n < 2:
        return 0.0
    return 1.0 / math.log(n)


def cramer_bound(p: int) -> float:
    """
    Cramér's conjectured upper bound on the prime gap at p: (log p)².
    
    For the strong form with C = 1.
    """
    if p < 2:
        return 0.0
    return math.log(p) ** 2


def bertrand_bound(p: int) -> int:
    """
    Bertrand's postulate bound: gap < p.
    
    Corresponds to `bertrand_prime_gap_lt` in Lean.
    """
    return p


def rsa_prime_search_bound(k: int) -> int:
    """
    Under Cramér's conjecture, worst-case number of candidates to
    test when searching for a k-bit prime: O(k²).
    
    Corresponds to `RSAPrimeSearchBound` in Lean.
    """
    return k * k


def verify_cramer_up_to(bound: int) -> Tuple[bool, Optional[int]]:
    """
    Verify Cramér's conjecture (with C=1) for all primes p with 11 ≤ p ≤ bound.
    
    Returns (True, None) if conjecture holds, or (False, counterexample_prime).
    Corresponds to `CramerTestable` in Lean.
    """
    primes = sieve_primes(bound + 1000)  # extra margin for next_prime
    for i in range(len(primes) - 1):
        p = primes[i]
        if p < 11 or p > bound:
            continue
        gap = primes[i + 1] - p
        if gap > math.log(p) ** 2:
            return (False, p)
    return (True, None)


def factorial_gap_construction(k: int) -> Tuple[int, int, int]:
    """
    Construct k consecutive composite numbers using the factorial method.
    
    Returns (start, end, gap_length) where start = (k+1)! + 2 and
    end = (k+1)! + (k+1) are all composite.
    
    Corresponds to the proof of `arbitrarily_large_prime_gaps` in Lean.
    """
    n = math.factorial(k + 1)
    start = n + 2
    end = n + k + 1
    return (start, end, k)


def log_sq_vs_linear(n: int) -> Tuple[float, float, float]:
    """
    Compare (log n)², n, and their ratio.
    
    Demonstrates `log_sq_lt_self`: (log n)² < n for n ≥ 1.
    """
    if n < 1:
        return (0.0, 0.0, 0.0)
    log_sq = math.log(n) ** 2
    return (log_sq, float(n), log_sq / n)


def gap_statistics(limit: int) -> dict:
    """Compute comprehensive prime gap statistics up to `limit`."""
    primes = sieve_primes(limit)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    
    if not gaps:
        return {}
    
    max_gap = max(gaps)
    max_gap_idx = gaps.index(max_gap)
    mean_gap = sum(gaps) / len(gaps)
    
    # Cramér ratio: gap / (log p)²
    cramer_ratios = []
    for i, g in enumerate(gaps):
        p = primes[i]
        if p >= 11:
            cramer_ratios.append(g / math.log(p) ** 2)
    
    return {
        "num_primes": len(primes),
        "num_gaps": len(gaps),
        "max_gap": max_gap,
        "max_gap_after_prime": primes[max_gap_idx],
        "mean_gap": mean_gap,
        "max_cramer_ratio": max(cramer_ratios) if cramer_ratios else 0,
        "mean_cramer_ratio": sum(cramer_ratios) / len(cramer_ratios) if cramer_ratios else 0,
        "cramer_violations": sum(1 for r in cramer_ratios if r > 1),
    }


if __name__ == "__main__":
    # Quick demo
    print("Prime gaps for first 20 primes:")
    primes = sieve_primes(80)
    for i in range(min(19, len(primes) - 1)):
        p = primes[i]
        g = primes[i + 1] - p
        cb = cramer_bound(p)
        print(f"  p={p:>3}, gap={g}, Cramér bound={(cb):.2f}, "
              f"ratio={g/cb:.3f}" if cb > 0 else f"  p={p:>3}, gap={g}")
    
    print(f"\nVerifying Cramér up to 100,000...")
    ok, cex = verify_cramer_up_to(100_000)
    print(f"  Result: {'HOLDS' if ok else f'FAILS at p={cex}'}")
    
    print(f"\nGap statistics up to 1,000,000:")
    stats = gap_statistics(1_000_000)
    for k, v in stats.items():
        print(f"  {k}: {v}")
