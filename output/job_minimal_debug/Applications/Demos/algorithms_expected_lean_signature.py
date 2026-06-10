#!/usr/bin/env python3
"""
Algorithms for Perfect Number Theory

Implements core algorithms from the research paper with complexity analysis.
"""

import math
from typing import List, Tuple, Optional, Dict


def sum_of_divisors(n: int) -> int:
    """
    Compute σ₁(n) = sum of all positive divisors of n.

    Time complexity: O(√n)
    Space complexity: O(1)

    >>> sum_of_divisors(6)
    12
    >>> sum_of_divisors(28)
    56
    """
    if n <= 0:
        return 0
    total = 0
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
    return total


def is_perfect(n: int) -> bool:
    """
    Test if n is a perfect number.

    Time complexity: O(√n)
    Space complexity: O(1)

    >>> is_perfect(6)
    True
    >>> is_perfect(28)
    True
    >>> is_perfect(12)
    False
    """
    return n > 0 and sum_of_divisors(n) == 2 * n


def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.

    Time complexity: O(√n)
    Space complexity: O(log n) for the factor dictionary

    >>> prime_factorization(28)
    {2: 2, 7: 1}
    >>> prime_factorization(496)
    {2: 4, 31: 1}
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


def is_prime(n: int) -> bool:
    """
    Miller-Rabin-style primality test (deterministic for n < 3.3 × 10^24).

    Time complexity: O(k · log²(n)) for k witnesses
    Space complexity: O(1)

    >>> is_prime(127)
    True
    >>> is_prime(128)
    False
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    # Deterministic witnesses for n < 3.3 × 10^24
    witnesses = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    d = n - 1
    r = 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in witnesses:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def lucas_lehmer_test(p: int) -> bool:
    """
    Lucas-Lehmer primality test for Mersenne numbers M_p = 2^p - 1.

    Time complexity: O(p² · log(p)) using fast multiplication
    Space complexity: O(p) for storing the intermediate values

    >>> lucas_lehmer_test(2)
    True
    >>> lucas_lehmer_test(3)
    True
    >>> lucas_lehmer_test(11)
    False
    >>> lucas_lehmer_test(13)
    True
    """
    if p == 2:
        return True
    if not is_prime(p):
        return False
    M = (1 << p) - 1  # 2^p - 1
    s = 4
    for _ in range(p - 2):
        s = (s * s - 2) % M
    return s == 0


def generate_even_perfect_numbers(max_p: int = 30) -> List[Tuple[int, int, int]]:
    """
    Generate even perfect numbers using Euclid's formula.

    For each prime p where 2^p - 1 is also prime (Mersenne prime),
    yields (p, mersenne_prime, perfect_number).

    Time complexity: O(max_p · p²) dominated by Lucas-Lehmer tests
    Space complexity: O(p) per test

    >>> nums = generate_even_perfect_numbers(20)
    >>> [n for _, _, n in nums]
    [6, 28, 496, 8128, 33550336, 8589869056, 137438691328]
    """
    results = []
    for p in range(2, max_p + 1):
        if lucas_lehmer_test(p):
            mersenne = (1 << p) - 1
            perfect = (1 << (p - 1)) * mersenne
            results.append((p, mersenne, perfect))
    return results


def euler_form_decomposition(n: int) -> Optional[Tuple[int, int, int]]:
    """
    Decompose n into Euler's form q^(4k+1) · m² if possible.

    Returns (q, k, m) where:
    - q is prime with q ≡ 1 (mod 4)
    - gcd(q, m) = 1
    - n = q^(4k+1) · m²

    Returns None if n doesn't have this form.

    Time complexity: O(√n) for factorization
    Space complexity: O(log n)

    >>> euler_form_decomposition(45)  # 5^1 × 3^2
    (5, 0, 3)
    >>> euler_form_decomposition(12) is None  # even
    True
    """
    if n <= 0 or n % 2 == 0:
        return None

    factors = prime_factorization(n)
    odd_exp_primes = [(p, e) for p, e in factors.items() if e % 2 == 1]

    if len(odd_exp_primes) != 1:
        return None

    q, exp = odd_exp_primes[0]
    if q % 4 != 1 or exp % 4 != 1:
        return None

    k = (exp - 1) // 4

    m_sq = n // (q ** exp)
    m = int(math.isqrt(m_sq))
    if m * m != m_sq:
        return None
    if math.gcd(q, m) != 1:
        return None

    return (q, k, m)


def sigma_prime_power(p: int, a: int) -> int:
    """
    Compute σ₁(p^a) = (p^(a+1) - 1) / (p - 1) for prime p.

    Time complexity: O(a · log(p)) for repeated squaring
    Space complexity: O(1)

    >>> sigma_prime_power(2, 3)
    15
    >>> sigma_prime_power(3, 2)
    13
    """
    if p == 1:
        return a + 1
    return (pow(p, a + 1) - 1) // (p - 1)


def abundance_ratio(n: int) -> float:
    """
    Compute the abundance ratio σ₁(n)/n.

    Perfect numbers have ratio exactly 2.0.
    Abundant numbers have ratio > 2.0.
    Deficient numbers have ratio < 2.0.

    >>> abs(abundance_ratio(6) - 2.0) < 1e-10
    True
    >>> abundance_ratio(12) > 2.0  # 12 is abundant
    True
    """
    if n <= 0:
        return 0.0
    return sum_of_divisors(n) / n


def find_perfect_numbers_below(limit: int) -> List[int]:
    """
    Find all perfect numbers below the given limit.

    Time complexity: O(limit^{3/2}) naively
    Space complexity: O(number of results)

    >>> find_perfect_numbers_below(10000)
    [6, 28, 496, 8128]
    """
    return [n for n in range(2, limit) if is_perfect(n)]


if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=True)

    print("\n=== Even Perfect Numbers (Mersenne Prime Construction) ===")
    for p, mersenne, perfect in generate_even_perfect_numbers(30):
        print(f"  p={p:>3}: M_p = {mersenne}, Perfect = {perfect}")

    print("\n=== Euler Form Decomposition Examples ===")
    for n in [45, 245, 3125, 117, 637]:
        result = euler_form_decomposition(n)
        if result:
            q, k, m = result
            print(f"  {n} = {q}^{4*k+1} × {m}² (q={q}, k={k}, m={m})")
        else:
            print(f"  {n}: not in Euler form")
