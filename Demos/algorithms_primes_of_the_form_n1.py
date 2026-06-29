#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for studying primes of the form n² + 1.

Type-hinted implementations of:
1. Bateman-Horn constant computation
2. n² + 1 prime counting
3. Semi-prime detection and counting
4. Mod-4 constraint verification
5. Friedlander-Iwaniec set enumeration
"""

from math import log, sqrt, isqrt
from typing import List, Tuple, Set, Dict, Optional


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Return all primes up to limit using the Sieve of Eratosthenes.

    Args:
        limit: Upper bound for prime search.

    Returns:
        Sorted list of primes ≤ limit.
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, isqrt(limit) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i, v in enumerate(is_prime) if v]


def is_prime(n: int) -> bool:
    """Deterministic primality test for n.

    Uses trial division up to √n. For large n, consider Miller-Rabin.

    Args:
        n: Non-negative integer to test.

    Returns:
        True if n is prime.
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


def prime_factorization(n: int) -> List[int]:
    """Return the prime factorization of n as a sorted list with multiplicity.

    Args:
        n: Positive integer ≥ 2.

    Returns:
        List of prime factors, e.g. [2, 2, 3] for n=12.
    """
    if n < 2:
        return []
    factors: List[int] = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n: int) -> int:
    """Compute Ω(n), the number of prime factors of n with multiplicity.

    Args:
        n: Positive integer ≥ 1.

    Returns:
        Number of prime factors with multiplicity.
    """
    return len(prime_factorization(n))


def is_semiprime(n: int) -> bool:
    """Test whether n is a semi-prime (product of exactly two primes).

    Args:
        n: Positive integer.

    Returns:
        True if Ω(n) = 2.
    """
    return big_omega(n) == 2


def is_almost_prime(k: int, n: int) -> bool:
    """Test whether n is a P_k number (at most k prime factors with multiplicity).

    Args:
        k: Maximum number of prime factors allowed.
        n: Positive integer > 1.

    Returns:
        True if n > 1 and Ω(n) ≤ k.
    """
    return n > 1 and big_omega(n) <= k


def count_nsq_plus_one_primes(N: int) -> int:
    """Count n in [0, N) such that n² + 1 is prime.

    Args:
        N: Upper bound (exclusive) for n.

    Returns:
        Number of n < N with n² + 1 prime.
    """
    count = 0
    for n in range(N):
        if is_prime(n * n + 1):
            count += 1
    return count


def count_nsq_plus_one_semiprimes(N: int) -> int:
    """Count n in [0, N) such that n² + 1 is a semi-prime.

    Args:
        N: Upper bound (exclusive) for n.

    Returns:
        Number of n < N with n² + 1 semi-prime.
    """
    count = 0
    for n in range(N):
        if is_semiprime(n * n + 1):
            count += 1
    return count


def bateman_horn_constant(num_primes: int = 10000) -> float:
    """Compute the Bateman-Horn/Hardy-Littlewood constant for n² + 1.

    The constant is C = ∏_{p odd prime} (1 - χ₋₄(p)/(p-1))
    where χ₋₄(p) = +1 if p ≡ 1 (mod 4), -1 if p ≡ 3 (mod 4).

    Args:
        num_primes: Number of odd primes to include in the product.

    Returns:
        Approximation of the constant C.
    """
    primes = sieve_of_eratosthenes(num_primes * 15)  # generous upper bound
    C = 1.0
    count = 0
    for p in primes:
        if p == 2:
            continue
        if p % 4 == 1:
            C *= 1.0 - 1.0 / (p - 1)
        else:  # p % 4 == 3
            C *= 1.0 + 1.0 / (p - 1)
        count += 1
        if count >= num_primes:
            break
    return C


def hardy_littlewood_prediction(N: int, C: Optional[float] = None) -> float:
    """Predict π_{n²+1}(N) using the Hardy-Littlewood conjecture.

    Prediction: π_{n²+1}(N) ~ C · N / ln(N)

    Args:
        N: Upper bound.
        C: The Hardy-Littlewood constant. If None, computed automatically.

    Returns:
        Predicted count of primes of the form n² + 1 with n < N.
    """
    if N <= 2:
        return 0.0
    if C is None:
        C = bateman_horn_constant()
    return C * N / log(N)


def verify_mod4_constraint(N: int) -> Tuple[Set[int], Set[int]]:
    """Verify that all odd prime divisors of n² + 1 are ≡ 1 (mod 4).

    Args:
        N: Check for all n < N.

    Returns:
        Tuple of (primes_1mod4, primes_3mod4) that divide some n² + 1.
        The second set should always be empty.
    """
    primes_1mod4: Set[int] = set()
    primes_3mod4: Set[int] = set()

    for n in range(N):
        val = n * n + 1
        for p in set(prime_factorization(val)):
            if p == 2:
                continue
            if p % 4 == 1:
                primes_1mod4.add(p)
            else:
                primes_3mod4.add(p)

    return primes_1mod4, primes_3mod4


def enumerate_friedlander_iwaniec_primes(bound: int) -> List[Tuple[int, int, int]]:
    """Find primes of the form a² + b⁴ up to bound.

    Args:
        bound: Upper limit for the prime value.

    Returns:
        List of (prime, a, b) triples.
    """
    results: List[Tuple[int, int, int]] = []
    b = 1
    while b ** 4 < bound:
        a = 0
        while a * a + b ** 4 < bound:
            val = a * a + b ** 4
            if is_prime(val):
                results.append((val, a, b))
            a += 1
        b += 1
    results.sort()
    return results


def omega_distribution(N: int) -> Dict[int, int]:
    """Compute the distribution of Ω(n² + 1) for n < N.

    Args:
        N: Upper bound for n.

    Returns:
        Dictionary mapping Ω values to their counts.
    """
    dist: Dict[int, int] = {}
    for n in range(N):
        val = n * n + 1
        omega = big_omega(val)
        dist[omega] = dist.get(omega, 0) + 1
    return dist


if __name__ == "__main__":
    # Quick verification
    C = bateman_horn_constant(10000)
    print(f"Hardy-Littlewood constant: {C:.6f}")

    N = 10000
    actual = count_nsq_plus_one_primes(N)
    predicted = hardy_littlewood_prediction(N, C)
    print(f"Primes n²+1 for n < {N}: actual={actual}, predicted={predicted:.1f}")

    p1, p3 = verify_mod4_constraint(10000)
    print(f"Mod-4 constraint: {len(p1)} primes ≡ 1, {len(p3)} primes ≡ 3 (should be 0)")
