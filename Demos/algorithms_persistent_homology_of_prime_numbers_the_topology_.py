#!/usr/bin/env python3
"""
Algorithms for Persistent Homology of Prime Point Clouds

Type-hinted implementations of the core algorithms used in
the persistent homology analysis of prime numbers.
"""

from typing import List, Tuple, Dict, Optional
import math


def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes returning all primes up to limit.

    Time complexity: O(n log log n)
    Space complexity: O(n)
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def prime_gaps(primes: List[int]) -> List[int]:
    """Compute consecutive prime gaps.

    Each gap g_i = p_{i+1} - p_i is the death time of bar i
    in the H₀ barcode.
    """
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def h0_barcode(primes: List[int]) -> List[Tuple[int, int]]:
    """Compute the H₀ persistent barcode of a 1D point cloud.

    For points on the real line, H₀ bars are determined entirely
    by consecutive gaps. Bar i is born at 0 and dies at gap_i.

    Returns: List of (birth, death) pairs.
    """
    gaps = prime_gaps(primes)
    return [(0, g) for g in gaps]


def count_components(gaps: List[int], epsilon: int) -> int:
    """Count connected components at scale epsilon.

    Theorem (Component-Gap Correspondence):
        components(ε) = 1 + #{i : gap_i > ε}

    This is the core link between persistent H₀ and prime gaps.
    """
    if not gaps:
        return 0
    return 1 + sum(1 for g in gaps if g > epsilon)


def persistence_diagram(primes: List[int]) -> List[Tuple[int, int]]:
    """Compute the persistence diagram for H₀.

    The persistence diagram plots (birth, death) for each bar.
    For the prime point cloud, all births are at 0, so the diagram
    is just the set of points (0, gap_i).
    """
    return h0_barcode(primes)


def total_persistence(primes: List[int], p: float = 1.0) -> float:
    """Compute the total p-persistence of the H₀ barcode.

    Total p-persistence = Σ |death_i - birth_i|^p = Σ gap_i^p

    For p=1, this equals the sum of all prime gaps = p_n - p_1.
    """
    gaps = prime_gaps(primes)
    return sum(g**p for g in gaps)


def gap_count_function(primes: List[int]) -> Dict[int, int]:
    """Count occurrences of each gap size.

    Returns a dictionary mapping gap sizes to their frequencies.
    This is the empirical distribution of H₀ bar lengths.
    """
    from collections import Counter
    return dict(Counter(prime_gaps(primes)))


def component_staircase(primes: List[int]) -> List[Tuple[int, int]]:
    """Compute the component count staircase function.

    Returns (epsilon, components) pairs at each transition point.
    The staircase is constant between consecutive gap values
    (proved in components_constant_between_gaps).
    """
    gaps = prime_gaps(primes)
    unique_gaps = sorted(set(gaps))

    staircase = [(0, len(primes))]  # ε=0: each prime is its own component
    for eps in unique_gaps:
        nc = count_components(gaps, eps)
        staircase.append((eps, nc))

    return staircase


def exponential_cdf(x: float, mean: float) -> float:
    """CDF of the exponential distribution with given mean."""
    if x < 0:
        return 0.0
    return 1.0 - math.exp(-x / mean)


def ks_statistic(gaps: List[int], predicted_mean: float) -> float:
    """Kolmogorov-Smirnov statistic comparing gap distribution
    to exponential(predicted_mean).

    This tests Cramér's conjecture that prime gaps follow
    an exponential distribution with mean ≈ log(N).
    """
    sorted_gaps = sorted(gaps)
    n = len(sorted_gaps)
    max_diff = 0.0
    for i, g in enumerate(sorted_gaps):
        empirical = (i + 1) / n
        theoretical = exponential_cdf(g, predicted_mean)
        max_diff = max(max_diff, abs(empirical - theoretical))
    return max_diff


def bertrand_gap_bound(p: int) -> int:
    """Upper bound on the gap after prime p, from Bertrand's postulate.

    Bertrand's postulate: ∀ n ≥ 1, ∃ prime q with n < q ≤ 2n.
    Therefore the next prime after p is at most 2p, giving gap < p.
    """
    return p  # gap < p, so p is an upper bound


def even_gap_verification(primes: List[int]) -> Tuple[int, int]:
    """Verify that all gaps between primes > 2 are even.

    Returns (total_gaps_checked, violations_found).
    By our theorem gap_between_odd_primes, violations should be 0.
    """
    gaps_to_check = [(primes[i], primes[i+1] - primes[i])
                     for i in range(len(primes) - 1)
                     if primes[i] > 2]
    violations = sum(1 for _, g in gaps_to_check if g % 2 != 0)
    return len(gaps_to_check), violations


def factorial_gap_witness(M: int) -> Tuple[int, int]:
    """Find a composite run of length ≥ M using the factorial construction.

    The numbers (M+1)!+2, (M+1)!+3, ..., (M+1)!+(M+1) are all composite.
    This witnesses our theorem exists_large_prime_gap.
    """
    n = M + 1
    factorial = math.factorial(n)
    start = factorial + 2
    end_ = factorial + n
    return start, end_


if __name__ == "__main__":
    primes = sieve_primes(10000)
    print(f"Primes up to 10000: {len(primes)} primes")
    print(f"Component staircase (first 10 transitions):")
    for eps, nc in component_staircase(primes)[:10]:
        print(f"  ε={eps}: {nc} components")

    total, violations = even_gap_verification(primes)
    print(f"\nEven gap verification: {total} gaps checked, {violations} violations")

    ks = ks_statistic(prime_gaps(primes), math.log(10000))
    print(f"\nKS statistic vs Exp(log 10000): {ks:.4f}")
