#!/usr/bin/env python3
"""
Algorithms for Additive Prime Decomposition Theory.

Implements efficient algorithms for:
1. Goldbach witness enumeration (ordered and unordered)
2. Parity census computation
3. Symmetry transfer computation
4. Weak Chen decomposition search
5. Semiprime testing and enumeration
"""

from typing import List, Tuple, Optional, Dict, Set
from sympy import isprime, primerange, factorint
import math


# ============================================================
# Algorithm 1: Goldbach Witness Enumeration
# ============================================================

def goldbach_witnesses_ordered(n: int) -> List[Tuple[int, int]]:
    """
    Enumerate all ordered pairs (p, q) of primes with p + q = n.

    Time complexity: O(n / ln(n)) using prime sieve
    Space complexity: O(n / ln(n))

    Args:
        n: Target sum (positive integer)

    Returns:
        List of (p, q) pairs with p, q prime and p + q = n

    Example:
        >>> goldbach_witnesses_ordered(10)
        [(3, 7), (5, 5), (7, 3)]
    """
    if n < 4:
        return []
    witnesses = []
    for p in primerange(2, n):
        q = n - p
        if q >= 2 and isprime(q):
            witnesses.append((p, q))
    return witnesses


def goldbach_witnesses_unordered(n: int) -> List[Tuple[int, int]]:
    """
    Enumerate canonical pairs (p, q) with p ≤ q, both prime, p + q = n.

    Time complexity: O(n / (2 ln(n)))
    Space complexity: O(n / ln(n))

    Args:
        n: Target sum

    Returns:
        List of (p, q) pairs with p ≤ q, both prime, p + q = n

    Example:
        >>> goldbach_witnesses_unordered(10)
        [(3, 7), (5, 5)]
    """
    if n < 4:
        return []
    witnesses = []
    for p in primerange(2, n // 2 + 1):
        q = n - p
        if isprime(q):
            witnesses.append((p, q))
    return witnesses


# ============================================================
# Algorithm 2: Parity Census Law Computation
# ============================================================

def count_twos(primes: List[int]) -> int:
    """
    Count the number of 2s in a list.

    Time complexity: O(k) where k = len(primes)

    Args:
        primes: List of prime numbers

    Returns:
        Number of elements equal to 2

    Example:
        >>> count_twos([2, 3, 2, 5])
        2
    """
    return primes.count(2)


def verify_parity_census(primes: List[int]) -> bool:
    """
    Verify the parity census law: countTwos(L) % 2 == (sum(L) + len(L)) % 2.

    This is a O(k) verification of the universal conservation law.

    Args:
        primes: List of prime numbers

    Returns:
        True if the parity census law holds

    Example:
        >>> verify_parity_census([3, 7])
        True
        >>> verify_parity_census([2, 3, 5])
        True
    """
    ct = count_twos(primes)
    return ct % 2 == (sum(primes) + len(primes)) % 2


# ============================================================
# Algorithm 3: Symmetry Transfer Computation
# ============================================================

def symmetry_decomposition(n: int) -> Dict[str, int]:
    """
    Decompose Goldbach witnesses into strict, diagonal, and gt parts.

    Implements the orbit decomposition under the Z/2 swap action:
      |ordered| = 2 * |strict| + |diagonal|

    Time complexity: O(n / ln(n))

    Args:
        n: Even target sum

    Returns:
        Dictionary with 'ordered', 'strict', 'diagonal', 'gt' counts

    Example:
        >>> symmetry_decomposition(10)
        {'ordered': 3, 'strict': 1, 'diagonal': 1, 'gt': 1}
    """
    ordered = goldbach_witnesses_ordered(n)
    strict = [(p, q) for p, q in ordered if p < q]
    diagonal = [(p, q) for p, q in ordered if p == q]
    gt = [(p, q) for p, q in ordered if p > q]

    return {
        'ordered': len(ordered),
        'strict': len(strict),
        'diagonal': len(diagonal),
        'gt': len(gt),
        'formula_check': len(ordered) == 2 * len(strict) + len(diagonal)
    }


# ============================================================
# Algorithm 4: Semiprime Testing
# ============================================================

def is_semiprime(n: int) -> bool:
    """
    Test if n is a product of exactly two primes (with multiplicity).

    Uses trial division. A number is semiprime if its prime factorization
    has exactly two prime factors counting multiplicity.

    Time complexity: O(√n)

    Args:
        n: Positive integer to test

    Returns:
        True if n is semiprime

    Example:
        >>> is_semiprime(6)   # 2 * 3
        True
        >>> is_semiprime(4)   # 2 * 2
        True
        >>> is_semiprime(8)   # 2^3
        False
    """
    if n < 4:
        return False
    factors = factorint(n)
    total_multiplicity = sum(factors.values())
    return total_multiplicity == 2


# ============================================================
# Algorithm 5: Weak Chen Decomposition Search
# ============================================================

def weak_chen_search(n: int) -> Optional[Tuple[int, int, str]]:
    """
    Find a weak Chen decomposition n = p + s where p is prime
    and s is prime or semiprime.

    Strategy: try small primes p first, check if n - p is prime
    or semiprime.

    Time complexity: O(n * √n / ln(n)) worst case

    Args:
        n: Even positive integer ≥ 4

    Returns:
        (p, s, type) where type is "prime" or "semiprime",
        or None if no decomposition found

    Example:
        >>> weak_chen_search(10)
        (3, 7, 'prime')
    """
    for p in primerange(2, n):
        s = n - p
        if s < 2:
            continue
        if isprime(s):
            return (p, s, "prime")
        if is_semiprime(s):
            return (p, s, "semiprime")
    return None


def weak_chen_all_decompositions(n: int) -> List[Tuple[int, int, str]]:
    """
    Find all weak Chen decompositions of n.

    Args:
        n: Positive integer

    Returns:
        List of (p, s, type) triples

    Example:
        >>> weak_chen_all_decompositions(10)
        [(3, 7, 'prime'), (5, 5, 'prime'), (7, 3, 'prime')]
    """
    results = []
    for p in primerange(2, n):
        s = n - p
        if s < 2:
            continue
        if isprime(s):
            results.append((p, s, "prime"))
        elif is_semiprime(s):
            results.append((p, s, "semiprime"))
    return results


# ============================================================
# Algorithm 6: Goldbach Count Statistics
# ============================================================

def goldbach_count_table(start: int, end: int) -> List[Dict]:
    """
    Compute Goldbach representation statistics for a range of even numbers.

    Args:
        start: Starting even number (≥ 4)
        end: Ending even number (inclusive)

    Returns:
        List of dictionaries with n, ordered_count, unordered_count,
        has_diagonal, and formula verification

    Example:
        >>> table = goldbach_count_table(4, 20)
        >>> table[0]
        {'n': 4, 'ordered': 1, 'unordered': 1, 'diagonal': True, ...}
    """
    results = []
    for n in range(start, end + 1, 2):
        ord_witnesses = goldbach_witnesses_ordered(n)
        unord_witnesses = goldbach_witnesses_unordered(n)
        has_diag = any(p == q for p, q in ord_witnesses)
        strict = sum(1 for p, q in ord_witnesses if p < q)

        results.append({
            'n': n,
            'ordered': len(ord_witnesses),
            'unordered': len(unord_witnesses),
            'strict': strict,
            'diagonal': has_diag,
            'formula_ok': len(ord_witnesses) == 2 * strict + (1 if has_diag else 0)
        })
    return results


if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    print("Goldbach witnesses for 30:")
    print(f"  Ordered: {goldbach_witnesses_ordered(30)}")
    print(f"  Unordered: {goldbach_witnesses_unordered(30)}")
    print()

    print("Parity census verification:")
    for L in [[2, 3], [3, 7], [2, 5, 11], [3, 5, 7, 11]]:
        print(f"  {L}: {verify_parity_census(L)}")
    print()

    print("Symmetry decomposition for n=30:")
    print(f"  {symmetry_decomposition(30)}")
    print()

    print("Semiprimes up to 20:")
    print(f"  {[n for n in range(4, 21) if is_semiprime(n)]}")
    print()

    print("Weak Chen decomposition for n=36:")
    print(f"  {weak_chen_search(36)}")
    print()

    print("Goldbach count table (4-30):")
    for row in goldbach_count_table(4, 30):
        print(f"  n={row['n']:>3}: ord={row['ordered']:>2}, "
              f"unord={row['unordered']:>2}, "
              f"diag={'Y' if row['diagonal'] else 'N'}, "
              f"formula={'✓' if row['formula_ok'] else '✗'}")
