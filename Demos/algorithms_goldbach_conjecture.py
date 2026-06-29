#!/usr/bin/env python3
"""
Algorithms for additive prime decomposition theory.

Implements efficient algorithms for:
- Goldbach witness enumeration
- Representation counting via sieve
- Semiprime detection
- Weak Chen decomposition search
- Convolution-based Goldbach counting
"""

import math
from typing import List, Tuple, Optional, Dict


def sieve_of_eratosthenes(limit: int) -> List[bool]:
    """
    Compute a boolean sieve up to `limit`.

    Returns:
        is_prime: list where is_prime[i] is True iff i is prime.

    Time: O(n log log n)
    Space: O(n)
    """
    is_prime = [False] * (limit + 1)
    if limit >= 2:
        is_prime[2] = True
    for i in range(3, limit + 1, 2):
        is_prime[i] = True
    p = 3
    while p * p <= limit:
        if is_prime[p]:
            for j in range(p * p, limit + 1, 2 * p):
                is_prime[j] = False
        p += 2
    return is_prime


def goldbach_count_sieve(limit: int) -> List[int]:
    """
    Compute r₂(n) for all n in [0, limit] using a prime indicator convolution.

    This is the discrete convolution approach:
        r₂(n) = Σ_{p ≤ n} 1_prime(p) · 1_prime(n - p)

    Time: O(n · π(n)) where π(n) ~ n/ln(n)
    Space: O(n)

    Args:
        limit: upper bound for computation

    Returns:
        counts: list where counts[n] = r₂(n) (ordered pairs)
    """
    is_prime = sieve_of_eratosthenes(limit)
    primes = [p for p in range(2, limit + 1) if is_prime[p]]
    counts = [0] * (limit + 1)

    for p in primes:
        for q in primes:
            s = p + q
            if s > limit:
                break
            counts[s] += 1

    return counts


def goldbach_witnesses(n: int, is_prime: Optional[List[bool]] = None) -> List[Tuple[int, int]]:
    """
    Find all ordered Goldbach pairs (p, q) with p + q = n.

    Args:
        n: target sum
        is_prime: precomputed sieve (optional)

    Returns:
        List of (p, q) pairs where both are prime and p + q = n

    Time: O(n) with sieve, O(n√n) without
    """
    if is_prime is None:
        is_prime = sieve_of_eratosthenes(n)

    pairs = []
    for p in range(2, n):
        q = n - p
        if q >= 2 and p < len(is_prime) and q < len(is_prime):
            if is_prime[p] and is_prime[q]:
                pairs.append((p, q))
    return pairs


def is_semiprime(n: int, is_prime: Optional[List[bool]] = None) -> bool:
    """
    Check if n is a product of exactly two primes (not necessarily distinct).

    Args:
        n: number to check
        is_prime: precomputed sieve (optional)

    Returns:
        True if n = p * q for primes p, q

    Time: O(√n) with sieve
    """
    if n < 4:
        return False
    if is_prime is None:
        is_prime = sieve_of_eratosthenes(n)

    for p in range(2, int(math.isqrt(n)) + 1):
        if p < len(is_prime) and is_prime[p] and n % p == 0:
            q = n // p
            if q < len(is_prime) and is_prime[q]:
                return True
    return False


def weak_chen_witnesses(
    n: int, is_prime: Optional[List[bool]] = None
) -> List[Tuple[int, int, str]]:
    """
    Find all weak Chen decompositions n = p + s where p is prime
    and s is prime or semiprime.

    Args:
        n: target sum
        is_prime: precomputed sieve (optional)

    Returns:
        List of (p, s, kind) where kind is "prime" or "semiprime"

    Time: O(n√n) worst case
    """
    if is_prime is None:
        is_prime = sieve_of_eratosthenes(n)

    results = []
    for p in range(2, n):
        s = n - p
        if s < 2 or p >= len(is_prime) or not is_prime[p]:
            continue
        if s < len(is_prime) and is_prime[s]:
            results.append((p, s, "prime"))
        elif is_semiprime(s, is_prime):
            results.append((p, s, "semiprime"))
    return results


def goldbach_count_statistics(limit: int) -> Dict[str, float]:
    """
    Compute statistics about Goldbach representation counts.

    Returns dictionary with:
    - min_count: minimum r₂(n) for even n ≥ 4
    - min_n: where minimum occurs
    - max_count: maximum r₂(n)
    - max_n: where maximum occurs
    - avg_count: average r₂(n) over even n in [4, limit]
    - all_positive: whether all counts are positive

    Time: O(limit · π(limit))
    """
    counts = goldbach_count_sieve(limit)

    even_counts = [(n, counts[n]) for n in range(4, limit + 1, 2)]
    if not even_counts:
        return {}

    min_entry = min(even_counts, key=lambda x: x[1])
    max_entry = max(even_counts, key=lambda x: x[1])
    avg = sum(c for _, c in even_counts) / len(even_counts)

    return {
        "min_count": min_entry[1],
        "min_n": min_entry[0],
        "max_count": max_entry[1],
        "max_n": max_entry[0],
        "avg_count": avg,
        "all_positive": all(c > 0 for _, c in even_counts),
        "min_count_ge8": min(c for n, c in even_counts if n >= 8),
    }


def transfer_binary_to_ternary(n: int, is_prime: Optional[List[bool]] = None) -> Optional[Tuple[int, int, int]]:
    """
    Given odd n > 5, find a ternary Goldbach decomposition n = 3 + p + q
    using the binary-to-ternary transfer.

    Args:
        n: odd integer > 5

    Returns:
        (3, p, q) where p, q are primes with 3 + p + q = n, or None
    """
    if n <= 5 or n % 2 == 0:
        return None
    m = n - 3  # m is even and > 2
    if is_prime is None:
        is_prime = sieve_of_eratosthenes(m)
    pairs = goldbach_witnesses(m, is_prime)
    if pairs:
        p, q = pairs[0]
        return (3, p, q)
    return None


# ── Example Usage ──────────────────────────────────────────────────

if __name__ == "__main__":
    print("Goldbach Count Statistics up to 10000:")
    stats = goldbach_count_statistics(10000)
    for k, v in stats.items():
        print(f"  {k}: {v}")

    print("\nBinary → Ternary Transfer examples:")
    sieve = sieve_of_eratosthenes(1000)
    for n in [7, 9, 11, 21, 99, 101, 999]:
        result = transfer_binary_to_ternary(n, sieve)
        if result:
            a, b, c = result
            print(f"  {n} = {a} + {b} + {c}")

    print("\nWeak Chen decompositions for n = 20:")
    for p, s, kind in weak_chen_witnesses(20):
        print(f"  20 = {p} + {s} ({kind})")
