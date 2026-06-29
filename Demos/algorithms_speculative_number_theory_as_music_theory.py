#!/usr/bin/env python3
"""
Spectral Arithmetic: Core Algorithms

Type-hinted implementations of the main spectral arithmetic functions.
"""

from fractions import Fraction
from typing import Dict, List, Tuple, Optional
import math


def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.

    Returns a dictionary mapping each prime factor to its exponent.
    For n ≤ 1, returns an empty dictionary.

    Time complexity: O(√n)

    Examples:
        >>> prime_factorization(12)
        {2: 2, 3: 1}
        >>> prime_factorization(360)
        {2: 3, 3: 2, 5: 1}
    """
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def spectral_weight(n: int) -> Fraction:
    """
    Compute the spectral weight (harmonic weight) of a natural number.

    sw(n) = Σ_{p prime, p|n} v_p(n) / p

    where v_p(n) is the p-adic valuation of n.

    Properties (proven in Lean 4):
    - sw(1) = 0
    - sw(p) = 1/p for prime p
    - sw(p^k) = k/p
    - sw(m·n) = sw(m) + sw(n) for m,n > 0 (complete additivity)
    - sw(n) ≤ Ω(n)/2 where Ω(n) = number of prime factors with multiplicity

    Args:
        n: A non-negative integer

    Returns:
        The spectral weight as an exact rational number
    """
    if n <= 0:
        return Fraction(0)
    factors = prime_factorization(n)
    return sum(Fraction(exp, p) for p, exp in factors.items())


def consonance_distance(m: int, n: int) -> Fraction:
    """
    Compute the consonance distance between two positive integers.

    cd(m, n) = sw(lcm(m,n)) - sw(gcd(m,n))

    For coprime m, n: cd(m, n) = sw(m) + sw(n)

    Smaller values indicate more consonant intervals.
    Proven ordering: unison(0) < octave(1/2) < fifth(5/6) < fourth(4/3)

    Args:
        m, n: Positive integers representing a musical ratio

    Returns:
        The consonance distance as an exact rational number
    """
    if m <= 0 or n <= 0:
        return Fraction(0)
    g = math.gcd(m, n)
    l = (m * n) // g
    return spectral_weight(l) - spectral_weight(g)


def big_omega(n: int) -> int:
    """Number of prime factors of n counted with multiplicity."""
    return sum(prime_factorization(n).values()) if n > 1 else 0


def harmonic_rank(n: int) -> int:
    """Number of distinct prime factors of n."""
    return len(prime_factorization(n))


def generalized_spectral_weight(
    n: int, weight_fn: callable = lambda p: Fraction(1, p)
) -> Fraction:
    """
    Compute a generalized spectral weight with arbitrary weight function.

    gsw_w(n) = Σ_{p prime, p|n} v_p(n) · w(p)

    The standard spectral weight uses w(p) = 1/p.
    Other useful choices:
    - w(p) = 1: recovers Ω(n) for squarefree n
    - w(p) = log(p): related to log(n) = Σ v_p(n)·log(p)
    - w(p) = 1/p²: more heavily penalizes small primes
    """
    if n <= 0:
        return Fraction(0)
    factors = prime_factorization(n)
    return sum(Fraction(exp) * weight_fn(p) for p, exp in factors.items())


def spectral_density(p: int, N: int) -> Fraction:
    """
    Compute the p-spectral density at level N.

    δ_p(N) = (1/N) Σ_{k=1}^{N} v_p(k) / p

    Conjectured limit: δ_p(N) → 1/(p(p-1)) as N → ∞.
    """
    if N == 0 or p < 2:
        return Fraction(0)
    total = Fraction(0)
    for k in range(1, N + 1):
        v = 0
        m = k
        while m % p == 0:
            v += 1
            m //= p
        total += Fraction(v, p)
    return total / N


def rank_intervals_by_consonance(
    intervals: List[Tuple[str, int, int]]
) -> List[Tuple[str, int, int, Fraction]]:
    """
    Rank musical intervals by their consonance distance.

    Args:
        intervals: List of (name, numerator, denominator) tuples

    Returns:
        Sorted list of (name, num, den, consonance_dist) tuples,
        from most consonant to most dissonant.
    """
    result = [(name, m, n, consonance_distance(m, n)) for name, m, n in intervals]
    result.sort(key=lambda x: x[3])
    return result


def find_numbers_with_weight(
    target: Fraction, max_n: int = 10000
) -> List[int]:
    """
    Find all n ≤ max_n with spectral_weight(n) = target.

    This solves the inverse spectral problem for a given target weight.
    """
    return [n for n in range(1, max_n + 1) if spectral_weight(n) == target]


def spectral_zeta_partial_sum(N: int) -> Fraction:
    """
    Compute the partial sum Σ_{k=2}^{N} sw(k) / k².

    This connects the spectral weight to the Riemann zeta function.
    """
    return sum(
        spectral_weight(k) / Fraction(k * k)
        for k in range(2, N + 1)
    )


if __name__ == "__main__":
    # Quick verification
    assert spectral_weight(1) == 0
    assert spectral_weight(2) == Fraction(1, 2)
    assert spectral_weight(4) == 1
    assert spectral_weight(6) == Fraction(5, 6)
    assert spectral_weight(12) == Fraction(4, 3)

    # Complete additivity check
    for m in range(1, 20):
        for n in range(1, 20):
            assert spectral_weight(m * n) == spectral_weight(m) + spectral_weight(n), \
                f"Failed for m={m}, n={n}"

    # Upper bound check
    for n in range(1, 1000):
        assert spectral_weight(n) <= Fraction(big_omega(n), 2), \
            f"Upper bound failed for n={n}"

    print("All assertions passed!")
