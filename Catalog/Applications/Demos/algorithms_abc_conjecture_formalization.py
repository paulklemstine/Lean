#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for ABC conjecture analysis

Implements:
1. Radical computation via trial division
2. ABC triple finder with quality ranking
3. Radical entropy and redundancy analysis
4. Prime factorization utilities
5. Fermat radical bound verification
"""

from math import gcd, log, factorial, prod, isqrt
from typing import Dict, List, Optional, Set, Tuple
from collections import defaultdict


def factorize(n: int) -> Dict[int, int]:
    """
    Complete prime factorization of n.

    Returns dict {prime: exponent}.
    Time complexity: O(sqrt(n))
    Space complexity: O(log n) for the factor dict.

    >>> factorize(360)
    {2: 3, 3: 2, 5: 1}
    """
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n: int) -> int:
    """
    Compute rad(n) = product of distinct prime factors of n.

    Time complexity: O(sqrt(n))

    >>> radical(360)
    30
    >>> radical(1)
    1
    """
    if n <= 1:
        return 1
    return prod(factorize(n).keys())


def prime_omega(n: int) -> int:
    """
    Count distinct prime factors: ω(n).

    >>> prime_omega(360)
    3
    """
    return len(factorize(n))


def big_omega(n: int) -> int:
    """
    Count prime factors with multiplicity: Ω(n).

    >>> big_omega(360)
    6
    """
    return sum(factorize(n).values())


def redundancy(n: int) -> float:
    """
    Compute redundancy = n / rad(n).
    Measures how much 'repeated' information the factorization carries.
    A number is squarefree iff redundancy = 1.

    >>> redundancy(360)
    12.0
    >>> redundancy(30)
    1.0
    """
    r = radical(n)
    return n / r if r > 0 else float('inf')


def abc_quality(a: int, b: int, c: int) -> float:
    """
    Compute the quality of an ABC triple: q(a,b,c) = log(c) / log(rad(abc)).

    The ABC conjecture states that for every ε > 0, there are only finitely
    many triples with quality > 1 + ε.

    >>> abc_quality(1, 8, 9)  # rad(72) = 6, log(9)/log(6) ≈ 1.226
    1.2264...
    """
    r = radical(a * b * c)
    if r <= 1:
        return float('inf')
    return log(c) / log(r)


def is_abc_triple(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) forms a valid ABC triple."""
    return a >= 1 and b >= 1 and c >= 1 and a + b == c and gcd(a, b) == 1


def find_high_quality_triples(
    limit: int,
    min_quality: float = 1.0
) -> List[Tuple[int, int, int, float]]:
    """
    Find all ABC triples (a, b, c) with c ≤ limit and quality > min_quality.

    Algorithm: Iterate over c from 3 to limit, then over a from 1 to c/2.
    Time complexity: O(limit^2 * sqrt(limit)) in worst case.

    Returns list of (a, b, c, quality) sorted by decreasing quality.
    """
    results: List[Tuple[int, int, int, float]] = []
    for c in range(3, limit + 1):
        for a in range(1, (c + 1) // 2):
            b = c - a
            if gcd(a, b) != 1:
                continue
            q = abc_quality(a, b, c)
            if q > min_quality:
                results.append((a, b, c, q))
    return sorted(results, key=lambda x: -x[3])


def radical_entropy_profile(n: int) -> Dict[str, float]:
    """
    Compute the 'radical entropy profile' of n.

    This cross-domain concept connects number theory to information theory:
    - diversity: number of distinct primes (ω(n))
    - redundancy: n / rad(n)
    - compression_ratio: log(rad(n)) / log(n)
    - entropy: -Σ (e_i/Ω(n)) * log(e_i/Ω(n)) over prime factors

    A squarefree number has maximal compression ratio (1.0) and
    zero redundancy beyond 1.
    """
    factors = factorize(n)
    if not factors:
        return {"diversity": 0, "redundancy": 1.0,
                "compression_ratio": 1.0, "entropy": 0.0}

    rad_n = prod(factors.keys())
    total_exp = sum(factors.values())

    # Shannon entropy of exponent distribution
    entropy = 0.0
    for e in factors.values():
        p = e / total_exp
        if p > 0:
            entropy -= p * log(p)

    return {
        "diversity": len(factors),
        "redundancy": n / rad_n,
        "compression_ratio": log(rad_n) / log(n) if n > 1 else 1.0,
        "entropy": entropy,
    }


def verify_fermat_radical_bound(max_base: int = 20, max_exp: int = 6) -> bool:
    """
    Verify that rad(x^n * y^n * z^n) ≤ xyz for small values.

    This is our formally proved theorem: for coprime x, y and z = x + y
    (or any z), the radical of the product of powers is bounded by the
    product of bases.
    """
    all_pass = True
    for x in range(1, max_base + 1):
        for y in range(1, max_base + 1):
            for n in range(1, max_exp + 1):
                z = x + y  # not a Fermat solution, but bound still holds
                val = x**n * y**n * z**n
                r = radical(val)
                bound = x * y * z
                if r > bound:
                    print(f"FAIL: rad({x}^{n}*{y}^{n}*{z}^{n}) = {r} > {bound}")
                    all_pass = False
    return all_pass


def verify_radical_factorial_bound(max_n: int = 100) -> bool:
    """
    Verify the conjecture rad(n!) ≥ n for n ≥ 2.

    This is formally proved using Bertrand's postulate in our Lean code.
    """
    all_pass = True
    for n in range(2, max_n + 1):
        r = radical(factorial(n))
        if r < n:
            print(f"FAIL: rad({n}!) = {r} < {n}")
            all_pass = False
    return all_pass


def primorial(n: int) -> int:
    """Compute the primorial: product of all primes ≤ n."""
    result = 1
    for p in sieve_primes(n):
        result *= p
    return result


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, isqrt(n) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


if __name__ == "__main__":
    # Quick verification
    print("Verifying Fermat radical bound (small values)...")
    assert verify_fermat_radical_bound(10, 4), "Fermat radical bound FAILED"
    print("✓ Passed\n")

    print("Verifying radical factorial bound...")
    assert verify_radical_factorial_bound(50), "Radical factorial bound FAILED"
    print("✓ Passed\n")

    # Show some high-quality triples
    print("High-quality ABC triples (c ≤ 10000):")
    triples = find_high_quality_triples(10000, 1.2)
    for a, b, c, q in triples[:10]:
        print(f"  ({a}, {b}, {c}): quality = {q:.4f}, rad = {radical(a*b*c)}")

    # Show entropy profiles
    print("\nRadical entropy profiles:")
    for n in [30, 360, 2310, 65536, 720720]:
        profile = radical_entropy_profile(n)
        print(f"  n={n}: {profile}")
