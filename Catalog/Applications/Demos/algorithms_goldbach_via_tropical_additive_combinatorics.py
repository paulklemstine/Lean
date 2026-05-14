#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Algorithms

Implements core algorithms from the research paper with full documentation,
type hints, complexity analysis, and example usage.
"""

from typing import Optional, Set, List, Tuple, Callable
import math


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Tropical Convolution (Naive)
# ═══════════════════════════════════════════════════════════════════════════

def tropical_convolution_naive(
    f: Callable[[int], Optional[int]],
    g: Callable[[int], Optional[int]],
    n: int
) -> Optional[int]:
    """
    Compute the min-plus (tropical) convolution of f and g at n.

    (f ⋆ₜ g)(n) = min_{a+b=n} (f(a) + g(b))

    where addition with ∞ (None) gives ∞.

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        f: Cost function ℕ → WithTop ℕ (None represents ⊤)
        g: Cost function ℕ → WithTop ℕ
        n: Point at which to evaluate the convolution

    Returns:
        The minimum cost decomposition, or None if all decompositions cost ⊤.

    Example:
        >>> A = {1, 3, 5}
        >>> f = lambda x: 0 if x in A else None
        >>> g = f  # self-convolution
        >>> tropical_convolution_naive(f, g, 4)  # 1+3 = 4
        0
        >>> tropical_convolution_naive(f, g, 3)  # no a+b=3 with both in A
        None
    """
    result = None
    for a in range(n + 1):
        fa = f(a)
        gb = g(n - a)
        if fa is not None and gb is not None:
            val = fa + gb
            if result is None or val < result:
                result = val
    return result


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Convolution (Batch)
# ═══════════════════════════════════════════════════════════════════════════

def tropical_convolution_batch(
    f: Callable[[int], Optional[int]],
    g: Callable[[int], Optional[int]],
    N: int
) -> List[Optional[int]]:
    """
    Compute the tropical convolution at all points 0, 1, ..., N-1.

    Time complexity: O(N²)
    Space complexity: O(N)

    Args:
        f, g: Cost functions
        N: Upper bound (exclusive)

    Returns:
        List where result[n] = (f ⋆ₜ g)(n) for n = 0, ..., N-1.

    Example:
        >>> primes = {2, 3, 5, 7, 11, 13}
        >>> pc = lambda n: 0 if n in primes else None
        >>> result = tropical_convolution_batch(pc, pc, 20)
        >>> [n for n in range(20) if result[n] == 0]
        [4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 16, 18]
    """
    result = [None] * N
    for n in range(N):
        for a in range(n + 1):
            fa = f(a)
            gb = g(n - a)
            if fa is not None and gb is not None:
                val = fa + gb
                if result[n] is None or val < result[n]:
                    result[n] = val
    return result


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Goldbach Verification
# ═══════════════════════════════════════════════════════════════════════════

def sieve_of_eratosthenes(limit: int) -> List[bool]:
    """Sieve of Eratosthenes returning boolean array."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return is_prime


def goldbach_tropical_verify(N: int) -> Tuple[bool, List[int]]:
    """
    Verify Goldbach's conjecture tropically for all even n in [4, N].

    Computes goldbachTrop(n) for each even n and checks if it equals 0.
    Returns the verification result and any counterexamples found.

    Time complexity: O(N² / log N) using sieve
    Space complexity: O(N)

    Args:
        N: Upper bound for verification

    Returns:
        (all_verified, counterexamples): Tuple of bool and list of
        any even numbers where goldbachTrop ≠ 0.

    Example:
        >>> verified, failures = goldbach_tropical_verify(10000)
        >>> verified
        True
        >>> failures
        []
    """
    is_prime = sieve_of_eratosthenes(N)
    counterexamples = []

    for n in range(4, N + 1, 2):
        found = False
        for p in range(2, n):
            if is_prime[p] and is_prime[n - p]:
                found = True
                break
        if not found:
            counterexamples.append(n)

    return len(counterexamples) == 0, counterexamples


def goldbach_representation_count(N: int) -> List[int]:
    """
    Count the number of Goldbach representations for each even n ≤ N.

    r(n) = |{(p, q) : p ≤ q, p + q = n, both prime}|

    This is the classical representation function whose positivity is
    equivalent to goldbachTrop(n) = 0.

    Time complexity: O(N² / log² N)
    Space complexity: O(N)

    Example:
        >>> counts = goldbach_representation_count(20)
        >>> [(n, counts[n]) for n in range(4, 21, 2)]
        [(4, 1), (6, 1), (8, 1), (10, 2), (12, 1), (14, 2), (16, 2), (18, 2), (20, 2)]
    """
    is_prime = sieve_of_eratosthenes(N)
    counts = [0] * (N + 1)

    for n in range(4, N + 1, 2):
        for p in range(2, n // 2 + 1):
            if is_prime[p] and is_prime[n - p]:
                counts[n] += 1

    return counts


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Cofinite Set Convolution Threshold
# ═══════════════════════════════════════════════════════════════════════════

def cofinite_convolution_threshold(exceptions: Set[int]) -> int:
    """
    Compute the threshold N such that for all n ≥ N, the tropical
    self-convolution of the cofinite set ℕ \\ exceptions vanishes.

    The theoretical bound is N = 2 * (max(exceptions) + 1).

    Time complexity: O(|exceptions|)
    Space complexity: O(1)

    Args:
        exceptions: Finite set of excluded natural numbers

    Returns:
        Threshold N such that tropConv(A, A)(n) = 0 for all n ≥ N.

    Example:
        >>> cofinite_convolution_threshold({0, 1, 2, 3})
        8
        >>> cofinite_convolution_threshold({5, 10, 15})
        32
    """
    if not exceptions:
        return 0
    M = max(exceptions) + 1
    return 2 * M


def verify_cofinite_threshold(exceptions: Set[int], test_range: int = 100) -> bool:
    """
    Verify the cofinite convolution threshold by testing.

    Args:
        exceptions: Finite set of excluded natural numbers
        test_range: Number of values to test beyond the threshold

    Returns:
        True if all values at or above threshold have conv = 0.
    """
    threshold = cofinite_convolution_threshold(exceptions)
    A = set(range(threshold + test_range + 1)) - exceptions

    f_A = lambda n: 0 if n in A else None

    for n in range(threshold, threshold + test_range):
        if tropical_convolution_naive(f_A, f_A, n) != 0:
            return False
    return True


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: Sumset via Tropical Convolution
# ═══════════════════════════════════════════════════════════════════════════

def sumset_via_tropical(A: Set[int], B: Set[int]) -> Set[int]:
    """
    Compute the Minkowski sum A + B using tropical convolution.

    This demonstrates the equivalence: n ∈ A + B ↔ (tropInd(A) ⋆ₜ tropInd(B))(n) = 0.

    Time complexity: O(N²) where N = max(A) + max(B)
    Space complexity: O(N)

    Args:
        A, B: Finite sets of natural numbers

    Returns:
        The sumset A + B = {a + b : a ∈ A, b ∈ B}

    Example:
        >>> sumset_via_tropical({1, 2, 3}, {10, 20})
        {11, 12, 13, 21, 22, 23}
    """
    if not A or not B:
        return set()

    N = max(A) + max(B) + 1
    f_A = lambda n: 0 if n in A else None
    f_B = lambda n: 0 if n in B else None

    conv = tropical_convolution_batch(f_A, f_B, N + 1)
    return {n for n in range(N + 1) if conv[n] == 0}


# ═══════════════════════════════════════════════════════════════════════════
# Main: Run examples
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Algorithm 1: Basic convolution
    print("\n--- Tropical Convolution ---")
    A = {2, 3, 5, 7}
    f = lambda n: 0 if n in A else None
    for n in range(15):
        val = tropical_convolution_naive(f, f, n)
        print(f"  (tropInd(A) ⋆ₜ tropInd(A))({n}) = {val if val is not None else '⊤'}")

    # Algorithm 3: Goldbach verification
    print("\n--- Goldbach Verification ---")
    verified, failures = goldbach_tropical_verify(10000)
    print(f"  Goldbach verified up to 10000: {verified}")
    print(f"  Counterexamples: {failures}")

    # Representation counts
    print("\n--- Goldbach Representation Counts ---")
    counts = goldbach_representation_count(50)
    for n in range(4, 51, 2):
        print(f"  r({n}) = {counts[n]}")

    # Algorithm 4: Cofinite threshold
    print("\n--- Cofinite Set Threshold ---")
    exc = {0, 1, 2, 7, 11}
    threshold = cofinite_convolution_threshold(exc)
    verified = verify_cofinite_threshold(exc)
    print(f"  Exceptions: {exc}")
    print(f"  Threshold: {threshold}")
    print(f"  Verified: {verified}")

    # Algorithm 5: Sumset
    print("\n--- Sumset via Tropical Convolution ---")
    A = {1, 4, 7}
    B = {2, 3, 8}
    result = sumset_via_tropical(A, B)
    expected = {a + b for a in A for b in B}
    print(f"  A = {sorted(A)}")
    print(f"  B = {sorted(B)}")
    print(f"  A + B (tropical) = {sorted(result)}")
    print(f"  A + B (direct)   = {sorted(expected)}")
    print(f"  Match: {result == expected}")
