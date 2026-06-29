#!/usr/bin/env python3
"""
Algorithms for Benford Renormalization Analysis of Dynamical Orbits.

Implements the key computational procedures from the research paper:
1. Growth-renormalization constant estimation
2. Benford discrepancy computation
3. Torus orbit period detection
4. Weyl sum estimation
"""

import math
from collections import Counter
from typing import List, Tuple, Optional, Dict


def sieve_primes(n: int) -> List[int]:
    """
    Sieve of Eratosthenes for primes up to n.

    Time complexity: O(n log log n)
    Space complexity: O(n)

    >>> sieve_primes(20)
    [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def leading_digit_base(n: int, base: int = 10) -> int:
    """
    Compute the leading (most significant) digit of |n| in the given base.

    Algorithm: Repeatedly divide by base until result < base.
    Time complexity: O(log_b(n))

    Args:
        n: Integer whose leading digit to compute
        base: Number base (≥ 2)

    Returns:
        Leading digit in {1, ..., base-1}, or 0 if n = 0

    >>> leading_digit_base(314159, 10)
    3
    >>> leading_digit_base(255, 16)
    15
    >>> leading_digit_base(1024, 2)
    1
    """
    n = abs(n)
    if n == 0 or base < 2:
        return 0
    while n >= base:
        n //= base
    return n


def benford_target(m: int, base: int = 10) -> float:
    """
    Compute the Benford target probability for digit m in base b.

    Returns log_b(1 + 1/m) = log(1 + 1/m) / log(b).

    >>> abs(benford_target(1, 10) - 0.30103) < 1e-4
    True
    """
    return math.log(1 + 1/m) / math.log(base)


def estimate_growth_constant(
    c: int,
    prime_bound: int = 1000,
    max_iterates: int = 8
) -> Tuple[float, Dict]:
    """
    Estimate the growth-renormalization constant C for T_c(x) = x² + c.

    The theorem guarantees:
        |log|T_c^[n](p)| - 2^n · log(p)| ≤ C · 2^n / p

    This algorithm empirically estimates C by computing orbits.

    Algorithm:
        1. Generate primes up to prime_bound
        2. For each prime p, iterate T_c up to max_iterates times
        3. Compute normalized error: |log|T_c^[n](p)| - 2^n·log(p)| · p / 2^n
        4. Return max over all (p, n)

    Time: O(π(prime_bound) · max_iterates · B) where B is bigint arithmetic cost
    Space: O(π(prime_bound))

    Args:
        c: Parameter of the quadratic map
        prime_bound: Upper bound for prime seeds
        max_iterates: Maximum number of iterations

    Returns:
        Tuple of (estimated C, detailed statistics dict)
    """
    primes = sieve_primes(prime_bound)
    max_C = 0.0
    errors_by_n = {n: [] for n in range(1, max_iterates + 1)}

    for p in primes:
        x = p
        for n in range(1, max_iterates + 1):
            x = x * x + c
            if x <= 0:
                break
            try:
                predicted = (2 ** n) * math.log(p)
                actual = math.log(abs(x))
                raw_error = abs(actual - predicted)
                normalized = raw_error * p / (2 ** n)
                max_C = max(max_C, normalized)
                errors_by_n[n].append(normalized)
            except (ValueError, OverflowError):
                break

    stats = {
        'estimated_C': max_C,
        'c': c,
        'num_primes': len(primes),
        'max_iterates': max_iterates,
        'mean_error_by_n': {
            n: sum(errs) / len(errs) if errs else 0
            for n, errs in errors_by_n.items()
        }
    }
    return max_C, stats


def compute_benford_discrepancy(
    c: int,
    prime_bound: int = 5000,
    max_iterates: int = 12,
    base: int = 10
) -> Tuple[float, Dict[int, float]]:
    """
    Compute the Benford discrepancy for quadratic map orbits from prime seeds.

    The discrepancy is:
        D = max_{1 ≤ m < b} |f(m) - β_b(m)|
    where f(m) is the empirical frequency and β_b(m) = log_b(1 + 1/m).

    Algorithm:
        1. Generate all primes up to prime_bound
        2. For each prime p and each iterate n = 1, ..., max_iterates:
           - Compute T_c^[n](p)
           - Record leading digit in base b
        3. Compute empirical frequencies
        4. Return max deviation from Benford targets

    Time: O(π(X) · N · B) where B is bigint cost
    Space: O(b) for digit counts

    Args:
        c: Quadratic map parameter
        prime_bound: Upper bound for prime seeds
        max_iterates: Number of iterations
        base: Number base

    Returns:
        Tuple of (discrepancy, dict of observed frequencies by digit)
    """
    primes = sieve_primes(prime_bound)
    digit_counts = Counter()
    total = 0

    for p in primes:
        x = p
        for n in range(1, max_iterates + 1):
            x = x * x + c
            d = leading_digit_base(x, base)
            if d > 0:
                digit_counts[d] += 1
                total += 1

    frequencies = {}
    max_discrepancy = 0.0
    for m in range(1, base):
        freq = digit_counts[m] / total if total > 0 else 0
        frequencies[m] = freq
        target = benford_target(m, base)
        max_discrepancy = max(max_discrepancy, abs(freq - target))

    return max_discrepancy, frequencies


def detect_torus_period(
    d: int,
    a: int,
    q: int,
    max_search: int = 10000
) -> Tuple[Optional[int], Optional[int]]:
    """
    Detect the eventual period of the sequence fract(d^n · a/q) on the torus.

    By the pigeonhole principle, this sequence is eventually periodic with
    period at most q and pre-period at most q.

    Algorithm:
        1. Compute d^n · a mod q for n = 0, 1, 2, ...
        2. Use Floyd's cycle detection or simple tracking
        3. Return (pre-period N₀, period T)

    Time: O(q) in the worst case
    Space: O(q)

    Args:
        d: Base of exponential
        a: Numerator of rational phase
        q: Denominator of rational phase
        max_search: Maximum n to search

    Returns:
        Tuple (pre_period, period) or (None, None) if not found
    """
    if q <= 0:
        return None, None

    # Track residues d^n * a mod q
    seen = {}  # residue -> first occurrence
    residue = a % q
    for n in range(max_search):
        r = (pow(d, n, q) * a) % q
        if r in seen:
            pre_period = seen[r]
            period = n - pre_period
            return pre_period, period
        seen[r] = n

    return None, None


def weyl_sum_estimate(
    d: int,
    k: int,
    prime_bound: int,
    max_iterates: int,
    base: int = 10
) -> complex:
    """
    Estimate the Weyl sum for the Benford equidistribution criterion.

    Computes:
        S(k) = (1 / (π(X) · N)) Σ_{p ≤ X, prime} Σ_{n=1}^{N}
               exp(2πi · k · d^n · log_b(p))

    By Weyl's criterion, equidistribution holds iff S(k) → 0 for all k ≠ 0.

    Time: O(π(X) · N)
    Space: O(1)

    Args:
        d: Degree of the map (2 for quadratic)
        k: Weyl frequency parameter (nonzero integer)
        prime_bound: Upper bound X for prime seeds
        max_iterates: Number N of iterates
        base: Number base b

    Returns:
        Complex value of the Weyl sum
    """
    primes = sieve_primes(prime_bound)
    total = 0.0 + 0.0j
    count = 0

    log_base = math.log(base)
    for p in primes:
        log_p = math.log(p)
        for n in range(1, max_iterates + 1):
            phase = k * (d ** n) * log_p / log_base
            total += complex(math.cos(2 * math.pi * phase),
                           math.sin(2 * math.pi * phase))
            count += 1

    return total / count if count > 0 else 0


def convergence_rate_analysis(
    c: int,
    base: int = 10,
    prime_bounds: Optional[List[int]] = None,
    max_iterates: int = 10
) -> List[Tuple[int, float]]:
    """
    Analyze the convergence rate of digit discrepancy as X increases.

    For each prime bound X, computes the Benford discrepancy D(X).
    The theory predicts D(X) → 0 as X → ∞.

    Args:
        c: Quadratic map parameter
        base: Number base
        prime_bounds: List of X values to test
        max_iterates: Number of iterates N

    Returns:
        List of (X, discrepancy) pairs
    """
    if prime_bounds is None:
        prime_bounds = [100, 500, 1000, 2000, 5000, 10000]

    results = []
    for X in prime_bounds:
        D, _ = compute_benford_discrepancy(c, X, max_iterates, base)
        results.append((X, D))

    return results


if __name__ == "__main__":
    # Example usage
    print("=== Growth Constant Estimation ===")
    for c in [0, 1, -1, 5]:
        C, stats = estimate_growth_constant(c, prime_bound=500, max_iterates=6)
        print(f"c = {c:>3}: estimated C = {C:.4f}")

    print("\n=== Benford Discrepancy ===")
    D, freqs = compute_benford_discrepancy(1, prime_bound=5000, max_iterates=10)
    print(f"Discrepancy for T(x) = x² + 1: D = {D:.6f}")

    print("\n=== Torus Period Detection ===")
    for d, a, q in [(2, 1, 7), (3, 2, 5), (2, 1, 4)]:
        N0, T = detect_torus_period(d, a, q)
        print(f"d={d}, a/q={a}/{q}: pre-period={N0}, period={T}")

    print("\n=== Weyl Sum Magnitudes ===")
    for k in [1, 2, 3, 5, 10]:
        S = weyl_sum_estimate(2, k, 1000, 8)
        print(f"k = {k:>2}: |S(k)| = {abs(S):.6f}")

    print("\n=== Convergence Rate ===")
    results = convergence_rate_analysis(1)
    for X, D in results:
        print(f"X = {X:>6}: discrepancy = {D:.6f}")
