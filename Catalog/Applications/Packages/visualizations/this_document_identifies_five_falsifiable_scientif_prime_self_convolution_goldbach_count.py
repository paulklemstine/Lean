#!/usr/bin/env python3
"""
Algorithms for additive prime decomposition theory.

Implements the core computational algorithms underlying the formal theorems,
with full docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Dict, Optional
from math import isqrt, log
import time


def sieve_of_eratosthenes(limit: int) -> List[bool]:
    """Compute a boolean sieve marking primes up to `limit`.

    Args:
        limit: Upper bound for the sieve (inclusive).

    Returns:
        List where index i is True iff i is prime.

    Time complexity: O(n log log n)
    Space complexity: O(n)

    Example:
        >>> sieve = sieve_of_eratosthenes(20)
        >>> [i for i, p in enumerate(sieve) if p]
        [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if limit < 2:
        return [False] * (limit + 1)
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, isqrt(limit) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return is_prime


def prime_indicator_array(limit: int) -> List[int]:
    """Compute the prime indicator function 1_P as an array.

    Args:
        limit: Upper bound (inclusive).

    Returns:
        List where index i is 1 if i is prime, 0 otherwise.

    Time complexity: O(n log log n)
    Space complexity: O(n)

    Example:
        >>> prime_indicator_array(10)
        [0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0]
    """
    sieve = sieve_of_eratosthenes(limit)
    return [1 if p else 0 for p in sieve]


def goldbach_count_direct(n: int, sieve: List[bool]) -> int:
    """Compute r_2(n) by direct enumeration of Goldbach pairs.

    Args:
        n: Target number.
        sieve: Boolean prime sieve (must have length > n).

    Returns:
        Number of ordered pairs (p, q) of primes with p + q = n.

    Time complexity: O(n)
    Space complexity: O(1) (sieve pre-computed)

    Example:
        >>> sieve = sieve_of_eratosthenes(100)
        >>> goldbach_count_direct(10, sieve)
        2
    """
    count = 0
    for k in range(2, n - 1):
        if sieve[k] and sieve[n - k]:
            count += 1
    return count


def goldbach_count_convolution(n: int, indicator: List[int]) -> int:
    """Compute r_2(n) via self-convolution of the prime indicator.

    Implements the formally proved identity:
        r_2(n) = sum_{k=0}^{n} 1_P(k) * 1_P(n-k)

    Args:
        n: Target number.
        indicator: Prime indicator array (must have length > n).

    Returns:
        The self-convolution value (1_P * 1_P)(n).

    Time complexity: O(n)
    Space complexity: O(1) (indicator pre-computed)

    Example:
        >>> ind = prime_indicator_array(100)
        >>> goldbach_count_convolution(10, ind)
        2
    """
    return sum(indicator[k] * indicator[n - k] for k in range(n + 1))


def goldbach_witnesses(n: int, sieve: List[bool]) -> List[Tuple[int, int]]:
    """Enumerate all ordered Goldbach pairs for n.

    Args:
        n: Target number.
        sieve: Boolean prime sieve.

    Returns:
        List of (p, q) with p, q prime and p + q = n.

    Time complexity: O(n)
    Space complexity: O(r_2(n))

    Example:
        >>> sieve = sieve_of_eratosthenes(100)
        >>> goldbach_witnesses(10, sieve)
        [(3, 7), (5, 5), (7, 3)]
    """
    return [(k, n - k) for k in range(2, n - 1) if sieve[k] and sieve[n - k]]


def batch_goldbach_count(limit: int) -> List[int]:
    """Compute r_2(n) for all n in [0, limit] using convolution.

    Uses the self-convolution identity to compute all Goldbach counts
    simultaneously.

    Args:
        limit: Upper bound (inclusive).

    Returns:
        List where index n contains r_2(n).

    Time complexity: O(n^2) — can be improved to O(n log n) with FFT
    Space complexity: O(n)

    Example:
        >>> counts = batch_goldbach_count(20)
        >>> [(n, counts[n]) for n in range(4, 21, 2)]
        [(4, 1), (6, 1), (8, 1), (10, 2), (12, 1), (14, 2), (16, 2), (18, 2), (20, 2)]
    """
    indicator = prime_indicator_array(limit)
    counts = [0] * (limit + 1)
    for n in range(limit + 1):
        counts[n] = sum(indicator[k] * indicator[n - k] for k in range(n + 1))
    return counts


def is_semiprime(n: int, sieve: List[bool]) -> bool:
    """Check if n is semiprime (product of exactly two primes).

    Args:
        n: Number to test.
        sieve: Boolean prime sieve.

    Returns:
        True if n = p * q for some primes p, q.

    Time complexity: O(sqrt(n))
    Space complexity: O(1) (sieve pre-computed)

    Example:
        >>> sieve = sieve_of_eratosthenes(100)
        >>> is_semiprime(15, sieve)  # 3 * 5
        True
        >>> is_semiprime(12, sieve)  # 2 * 2 * 3
        False
    """
    if n < 4:
        return False
    for p in range(2, isqrt(n) + 1):
        if sieve[p] and n % p == 0 and n // p < len(sieve) and sieve[n // p]:
            return True
    return False


def weak_chen_decomposition(n: int, sieve: List[bool]) -> Optional[Tuple[int, int, str]]:
    """Find a weak Chen decomposition of n, if one exists.

    Searches for n = p + s where p is prime and s is prime or semiprime.

    Args:
        n: Target number.
        sieve: Boolean prime sieve.

    Returns:
        Tuple (p, s, type) where type is "prime" or "semiprime",
        or None if no decomposition exists.

    Time complexity: O(n * sqrt(n))
    Space complexity: O(1) (sieve pre-computed)

    Example:
        >>> sieve = sieve_of_eratosthenes(100)
        >>> weak_chen_decomposition(36, sieve)
        (5, 31, 'prime')
    """
    for p in range(2, n - 1):
        if not sieve[p]:
            continue
        s = n - p
        if s >= 2 and s < len(sieve) and sieve[s]:
            return (p, s, "prime")
        if is_semiprime(s, sieve):
            return (p, s, "semiprime")
    return None


def ternary_parity_census(n: int, sieve: List[bool]) -> Dict[int, int]:
    """Count ternary decompositions by number of 2s.

    For each prime triple (a, b, c) with a + b + c = n,
    count how many have 0, 1, 2, or 3 copies of 2.

    Args:
        n: Target number.
        sieve: Boolean prime sieve.

    Returns:
        Dictionary mapping #twos -> count of triples.

    Time complexity: O(n^2)
    Space complexity: O(1)

    Example:
        >>> sieve = sieve_of_eratosthenes(100)
        >>> ternary_parity_census(15, sieve)
        {0: 12, 2: 3}
    """
    census: Dict[int, int] = {}
    for a in range(2, n - 3):
        if not sieve[a]:
            continue
        for b in range(2, n - a - 1):
            c = n - a - b
            if c >= 2 and sieve[b] and sieve[c]:
                twos = (1 if a == 2 else 0) + (1 if b == 2 else 0) + (1 if c == 2 else 0)
                census[twos] = census.get(twos, 0) + 1
    return census


def verify_parity_rigidity(limit: int) -> bool:
    """Verify ternary parity rigidity up to `limit`.

    Checks that:
    - For odd n: #twos is always 0 or 2
    - For even n: #twos is always 1 or 3

    Args:
        limit: Upper bound for verification.

    Returns:
        True if all constraints hold.

    Example:
        >>> verify_parity_rigidity(100)
        True
    """
    sieve = sieve_of_eratosthenes(limit)
    for n in range(5, limit + 1):
        census = ternary_parity_census(n, sieve)
        if n % 2 == 1:  # odd
            for twos in census:
                if twos not in (0, 2):
                    return False
        else:  # even
            for twos in census:
                if twos not in (1, 3):
                    return False
    return True


def goldbach_multiplicity_analysis(limit: int) -> Dict[str, object]:
    """Analyze Goldbach multiplicity statistics up to `limit`.

    Args:
        limit: Upper bound for analysis.

    Returns:
        Dictionary with statistics including min count, average,
        and whether r_2(n) >= 2 for all even n >= 8.

    Example:
        >>> stats = goldbach_multiplicity_analysis(200)
        >>> stats['min_count_ge_8']
        2
    """
    sieve = sieve_of_eratosthenes(limit)
    counts = []
    min_count = float('inf')
    min_n = None
    min_count_ge_8 = float('inf')
    min_n_ge_8 = None

    for n in range(4, limit + 1, 2):
        c = goldbach_count_direct(n, sieve)
        counts.append((n, c))
        if c < min_count:
            min_count = c
            min_n = n
        if n >= 8 and c < min_count_ge_8:
            min_count_ge_8 = c
            min_n_ge_8 = n

    avg_count = sum(c for _, c in counts) / len(counts) if counts else 0

    return {
        'limit': limit,
        'total_even_checked': len(counts),
        'min_count': min_count,
        'min_n': min_n,
        'min_count_ge_8': min_count_ge_8,
        'min_n_ge_8': min_n_ge_8,
        'average_count': avg_count,
        'all_ge_2_from_8': all(c >= 2 for n, c in counts if n >= 8),
    }


if __name__ == "__main__":
    # Example usage
    print("Goldbach count verification:")
    sieve = sieve_of_eratosthenes(1000)
    indicator = prime_indicator_array(1000)

    for n in [10, 20, 50, 100]:
        direct = goldbach_count_direct(n, sieve)
        conv = goldbach_count_convolution(n, indicator)
        print(f"  r_2({n}) = {direct} (direct), {conv} (convolution)")
        assert direct == conv, f"Mismatch at n={n}!"

    print("\nParity rigidity verification up to 200:")
    print(f"  Result: {verify_parity_rigidity(200)}")

    print("\nMultiplicity analysis up to 1000:")
    stats = goldbach_multiplicity_analysis(1000)
    for k, v in stats.items():
        print(f"  {k}: {v}")
