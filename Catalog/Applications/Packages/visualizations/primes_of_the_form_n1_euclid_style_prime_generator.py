#!/usr/bin/env python3
"""
Algorithms for studying primes and semiprimes of the form n² + 1.

Implements:
1. Efficient classification of n² + 1 values by prime factor count
2. Euclid-style prime generation for primes ≡ 1 (mod 4)
3. Root counting for X² + 1 over finite fields
4. Semiprime sieve for n² + 1
"""

import math
from typing import List, Tuple, Dict, Set, Optional


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """
    Generate all primes up to `limit` using the Sieve of Eratosthenes.

    Time complexity: O(n log log n)
    Space complexity: O(n)

    Args:
        limit: Upper bound for primes.

    Returns:
        Sorted list of primes up to limit.

    >>> sieve_of_eratosthenes(20)
    [2, 3, 5, 7, 11, 13, 17, 19]
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


def factorize(n: int, primes: Optional[List[int]] = None) -> List[int]:
    """
    Return the prime factorization of n as a sorted list with multiplicity.

    If a precomputed prime list is provided, uses trial division with those primes.
    Otherwise uses basic trial division.

    Time complexity: O(√n) without precomputed primes, O(√n / log n) with.

    Args:
        n: Number to factorize (must be ≥ 1).
        primes: Optional precomputed list of primes up to √n.

    Returns:
        Sorted list of prime factors with multiplicity.

    >>> factorize(12)
    [2, 2, 3]
    >>> factorize(17)
    [17]
    """
    if n <= 1:
        return []
    factors = []
    if primes:
        for p in primes:
            if p * p > n:
                break
            while n % p == 0:
                factors.append(p)
                n //= p
    else:
        d = 2
        while d * d <= n:
            while n % d == 0:
                factors.append(d)
                n //= d
            d += 1
    if n > 1:
        factors.append(n)
    return factors


def classify_sq_plus_one(limit: int) -> Dict[str, List[int]]:
    """
    Classify values of n² + 1 for n = 1, ..., limit by their prime structure.

    Algorithm:
        1. Precompute primes up to limit² + 1 using sieve.
        2. For each n, compute n² + 1 and count prime factors.
        3. Classify into primes, semiprimes, and higher.

    Time complexity: O(limit² log log(limit²)) for sieve + O(limit · √(limit²)) for factoring.
    Space complexity: O(limit²) for the sieve.

    Args:
        limit: Maximum value of n to test.

    Returns:
        Dictionary with keys 'primes', 'semiprimes', 'three_factors', etc.
        Each maps to a list of n values producing that category.

    >>> result = classify_sq_plus_one(10)
    >>> 1 in result['primes']  # 1² + 1 = 2 is prime
    True
    >>> 3 in result['semiprimes']  # 3² + 1 = 10 = 2 × 5
    True
    """
    # Precompute primes for faster factoring
    max_val = limit * limit + 1
    small_primes = sieve_of_eratosthenes(int(max_val**0.5) + 1)

    result: Dict[str, List[int]] = {
        'primes': [],
        'semiprimes': [],
        'three_factors': [],
        'four_plus_factors': []
    }

    for n in range(1, limit + 1):
        val = n * n + 1
        omega = len(factorize(val, small_primes))

        if omega == 1:
            result['primes'].append(n)
        elif omega == 2:
            result['semiprimes'].append(n)
        elif omega == 3:
            result['three_factors'].append(n)
        else:
            result['four_plus_factors'].append(n)

    return result


def euclid_style_prime_generator(bound: int) -> List[Tuple[int, int, int]]:
    """
    Generate primes ≡ 1 (mod 4) dividing values of n² + 1 using the
    Euclid-style construction from Theorem D.

    Algorithm (pseudocode):
        Input: bound B
        1. Compute B!
        2. Set M = (2 · B!)² + 1
        3. Find all prime factors of M
        4. Return those that are > B and ≡ 1 (mod 4)

    Each returned prime q comes with a witness n = 2 · B! such that q | n² + 1.

    Args:
        bound: The bound B. Returns primes > B.

    Returns:
        List of tuples (q, n, B) where q is prime, q > B, q ≡ 1 (mod 4),
        and q | n² + 1.

    >>> results = euclid_style_prime_generator(3)
    >>> all(q > 3 and q % 4 == 1 for q, _, _ in results)
    True
    """
    factorial_B = math.factorial(bound)
    n_witness = 2 * factorial_B
    M = n_witness * n_witness + 1

    factors = factorize(M)
    primes = sorted(set(factors))

    results = []
    for q in primes:
        if q > bound and q % 4 == 1:
            results.append((q, n_witness, bound))

    return results


def root_count_x_sq_plus_one(p: int) -> Tuple[int, List[int]]:
    """
    Count roots of X² + 1 in ℤ/pℤ and return them.

    This computes ω(p) = |{n ∈ ℤ/pℤ : n² + 1 ≡ 0 (mod p)}|,
    which is the local density used in sieve theory.

    Algorithm:
        For each n ∈ {0, 1, ..., p-1}, check if (n² + 1) mod p = 0.

    Time complexity: O(p)
    Space complexity: O(p) for storing roots.

    The expected pattern (provable from quadratic reciprocity):
        ω(2) = 1
        ω(p) = 2 if p ≡ 1 (mod 4)
        ω(p) = 0 if p ≡ 3 (mod 4)

    Args:
        p: A prime number.

    Returns:
        Tuple of (count, list_of_roots).

    >>> root_count_x_sq_plus_one(5)
    (2, [2, 3])
    >>> root_count_x_sq_plus_one(7)
    (0, [])
    """
    roots = [n for n in range(p) if (n * n + 1) % p == 0]
    return len(roots), roots


def semiprime_sieve_sq_plus_one(limit: int) -> List[Tuple[int, int, List[int]]]:
    """
    Find all n ≤ limit where n² + 1 is prime or semiprime.

    Returns each qualifying n along with n² + 1 and its factorization.

    Algorithm:
        1. Precompute small primes.
        2. For each n, factorize n² + 1.
        3. Keep those with Ω(n² + 1) ≤ 2.

    Time complexity: O(limit · √(limit²)) = O(limit²)
    Space complexity: O(√(limit²)) for prime table.

    Args:
        limit: Maximum n to check.

    Returns:
        List of (n, n²+1, factorization) triples where Ω(n²+1) ≤ 2.

    >>> results = semiprime_sieve_sq_plus_one(5)
    >>> (1, 2, [2]) in results  # 1² + 1 = 2 (prime)
    True
    """
    max_val = limit * limit + 1
    small_primes = sieve_of_eratosthenes(int(max_val**0.5) + 1)

    results = []
    for n in range(1, limit + 1):
        val = n * n + 1
        factors = factorize(val, small_primes)
        if len(factors) <= 2:
            results.append((n, val, factors))

    return results


def admissibility_check(f, var_count: int, test_primes: List[int]) -> Dict[int, Tuple[bool, Optional[Tuple]]]:
    """
    Check local admissibility of a polynomial function for given primes.

    For each prime p, finds a witness (n₁, ..., nₖ) with p ∤ f(n₁, ..., nₖ),
    or reports that p divides all values (which should never happen for
    admissible polynomials).

    Algorithm:
        For each prime p, iterate over small input values until finding
        one where f(...) is not divisible by p.

    Args:
        f: Function taking `var_count` natural number arguments.
        var_count: Number of variables (1 or 2).
        test_primes: List of primes to test.

    Returns:
        Dict mapping each prime to (is_admissible, witness_or_None).

    >>> f = lambda n: n**2 + 1
    >>> result = admissibility_check(f, 1, [2, 3, 5, 7])
    >>> all(v[0] for v in result.values())
    True
    """
    results = {}

    for p in test_primes:
        found = False
        if var_count == 1:
            for n in range(p):
                if f(n) % p != 0:
                    results[p] = (True, (n,))
                    found = True
                    break
        elif var_count == 2:
            for a in range(p):
                for b in range(p):
                    if f(a, b) % p != 0:
                        results[p] = (True, (a, b))
                        found = True
                        break
                if found:
                    break

        if not found:
            results[p] = (False, None)

    return results


if __name__ == "__main__":
    print("=== Classification of n² + 1 for n ≤ 100 ===")
    result = classify_sq_plus_one(100)
    print(f"Primes (Ω=1): {len(result['primes'])} values")
    print(f"  n = {result['primes'][:15]}...")
    print(f"Semiprimes (Ω=2): {len(result['semiprimes'])} values")
    print(f"Three factors (Ω=3): {len(result['three_factors'])} values")
    print(f"Four+ factors (Ω≥4): {len(result['four_plus_factors'])} values")
    print()

    print("=== Euclid-style prime generation ===")
    for B in [3, 5, 7, 10]:
        primes = euclid_style_prime_generator(B)
        print(f"B = {B}: found primes {[q for q, _, _ in primes]}")
    print()

    print("=== Root counts of X² + 1 mod p ===")
    for p in sieve_of_eratosthenes(30):
        count, roots = root_count_x_sq_plus_one(p)
        print(f"  p = {p:>3} (≡ {p%4} mod 4): {count} roots {roots}")
    print()

    print("=== Admissibility check ===")
    primes_50 = sieve_of_eratosthenes(50)
    print("n² + 1:", all(v[0] for v in admissibility_check(lambda n: n**2 + 1, 1, primes_50).values()))
    print("a² + b⁴:", all(v[0] for v in admissibility_check(lambda a, b: a**2 + b**4, 2, primes_50).values()))
