#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Algorithms

Implements the core algorithms from the research paper on tropical
(min-plus) convolution methods for additive number theory.
"""

import math
from typing import Callable, Dict, List, Optional, Tuple

INF = float('inf')


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Sieve of Eratosthenes (prime generation)
# ═══════════════════════════════════════════════════════════════

def sieve_of_eratosthenes(limit: int) -> List[bool]:
    """
    Generate a boolean sieve marking primes up to limit.

    Time:  O(n log log n)
    Space: O(n)

    Args:
        limit: Upper bound (inclusive).

    Returns:
        List where is_prime[i] is True iff i is prime.
    """
    is_prime = [False, False] + [True] * (limit - 1)
    for i in range(2, int(math.isqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return is_prime


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Cost Functions
# ═══════════════════════════════════════════════════════════════

def tropical_cost_array(predicate: List[bool]) -> List[float]:
    """
    Build tropical cost array from a boolean predicate array.

    c(n) = 0 if predicate[n] else ∞

    Time:  O(n)
    Space: O(n)

    Args:
        predicate: Boolean array where predicate[i] indicates membership.

    Returns:
        Array of tropical costs.
    """
    return [0.0 if p else INF for p in predicate]


def soft_cost_array(predicate: List[bool], K: float) -> List[float]:
    """
    Build soft tropical cost array.

    c(n) = 0 if predicate[n] else K

    Args:
        predicate: Boolean array.
        K: Penalty for non-membership.

    Returns:
        Array of soft tropical costs.
    """
    return [0.0 if p else K for p in predicate]


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Min-Plus Convolution (naive)
# ═══════════════════════════════════════════════════════════════

def minplus_conv_naive(f: List[float], g: List[float], n: int) -> float:
    """
    Compute min-plus convolution at a single point n.

    (f ⋆ g)(n) = min { f(a) + g(b) : a + b = n, 0 ≤ a,b }

    Time:  O(n)
    Space: O(1)

    Args:
        f: First cost function array.
        g: Second cost function array.
        n: Point at which to evaluate.

    Returns:
        The min-plus convolution value.
    """
    result = INF
    for a in range(min(n + 1, len(f))):
        b = n - a
        if b < len(g):
            val = f[a] + g[b]
            if val < result:
                result = val
    return result


def minplus_conv_full(f: List[float], g: List[float]) -> List[float]:
    """
    Compute the full min-plus convolution array.

    Time:  O(n²) where n = len(f) + len(g)
    Space: O(n)

    Args:
        f: First cost function array (length m).
        g: Second cost function array (length k).

    Returns:
        Array of length m+k-1 with all convolution values.
    """
    m, k = len(f), len(g)
    result = [INF] * (m + k - 1)
    for a in range(m):
        if f[a] == INF:
            continue
        for b in range(k):
            if g[b] == INF:
                continue
            idx = a + b
            val = f[a] + g[b]
            if val < result[idx]:
                result[idx] = val
    return result


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Goldbach Verification Engine
# ═══════════════════════════════════════════════════════════════

def verify_goldbach_range(limit: int) -> Tuple[bool, Optional[int], Dict[int, Tuple[int, int]]]:
    """
    Verify Goldbach's conjecture for all even numbers in [4, limit].

    Uses sieve-based approach for efficiency.

    Time:  O(n² / log n) expected (by prime density)
    Space: O(n)

    Args:
        limit: Upper bound for verification.

    Returns:
        Tuple of (all_verified, first_failure, decompositions)
        where decompositions maps each even n to a (p, q) pair.

    Example:
        >>> ok, fail, decomps = verify_goldbach_range(100)
        >>> ok
        True
        >>> decomps[10]
        (3, 7)
    """
    sieve = sieve_of_eratosthenes(limit)
    decompositions: Dict[int, Tuple[int, int]] = {}

    for n in range(4, limit + 1, 2):
        found = False
        for p in range(2, n // 2 + 1):
            if sieve[p] and sieve[n - p]:
                decompositions[n] = (p, n - p)
                found = True
                break
        if not found:
            return (False, n, decompositions)

    return (True, None, decompositions)


def goldbach_representation_count(limit: int) -> List[int]:
    """
    Count Goldbach representations r₂(n) for even n in [0, limit].

    r₂(n) = |{(p,q) : p ≤ q, p+q = n, p,q prime}|

    Time:  O(n² / log² n) expected
    Space: O(n)

    Args:
        limit: Upper bound.

    Returns:
        Array where result[n] = r₂(n) for even n, 0 for odd n.

    Example:
        >>> counts = goldbach_representation_count(20)
        >>> counts[10]  # 10 = 3+7 = 5+5
        2
    """
    sieve = sieve_of_eratosthenes(limit)
    counts = [0] * (limit + 1)

    for n in range(4, limit + 1, 2):
        for p in range(2, n // 2 + 1):
            if sieve[p] and sieve[n - p]:
                counts[n] += 1

    return counts


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Tropical Support Analysis
# ═══════════════════════════════════════════════════════════════

def tropical_support(costs: List[float]) -> List[int]:
    """
    Extract the support (zero locus) of a tropical cost function.

    supp(f) = {n : f(n) = 0}

    Time:  O(n)
    Space: O(|supp|)

    Args:
        costs: Tropical cost array.

    Returns:
        Sorted list of indices where cost is 0.
    """
    return [i for i, c in enumerate(costs) if c == 0.0]


def sumset(A: List[int], B: List[int], limit: int) -> List[int]:
    """
    Compute the sumset A + B = {a + b : a ∈ A, b ∈ B} up to limit.

    Time:  O(|A| × |B|)
    Space: O(limit)

    Args:
        A: First set (sorted list).
        B: Second set (sorted list).
        limit: Upper bound for elements.

    Returns:
        Sorted list of elements in A + B up to limit.
    """
    result_set = set()
    for a in A:
        for b in B:
            s = a + b
            if s <= limit:
                result_set.add(s)
            else:
                break  # B is sorted, so all subsequent b give s > limit
    return sorted(result_set)


def tropical_covering_density(predicate: List[bool], n: int) -> float:
    """
    Compute the Schnirelmann-style density of a predicate up to n.

    σ(A, n) = |{a ∈ A : a ≤ n}| / n  for n ≥ 1

    Time:  O(n)
    Space: O(1)

    Args:
        predicate: Boolean membership array.
        n: Upper bound.

    Returns:
        The density value.
    """
    if n < 1:
        return 0.0
    count = sum(1 for i in range(1, n + 1) if i < len(predicate) and predicate[i])
    return count / n


def schnirelmann_density(predicate: List[bool], limit: int) -> float:
    """
    Compute the Schnirelmann density: inf_{n≥1} |A ∩ [1,n]| / n.

    Time:  O(limit)
    Space: O(1)

    Args:
        predicate: Boolean membership array.
        limit: Upper bound for the infimum search.

    Returns:
        The Schnirelmann density.
    """
    min_density = 1.0
    count = 0
    for n in range(1, min(limit + 1, len(predicate))):
        if predicate[n]:
            count += 1
        density = count / n
        if density < min_density:
            min_density = density
    return min_density


# ═══════════════════════════════════════════════════════════════
# Algorithm 6: Certificate Extraction
# ═══════════════════════════════════════════════════════════════

def extract_certificate(
    costs: List[float],
    n: int
) -> Optional[Tuple[int, int]]:
    """
    Extract a witness (a, b) achieving the minimum in (f ⋆ f)(n).

    If the convolution is 0, returns (a, b) with a+b=n and f(a)=f(b)=0.

    Time:  O(n)
    Space: O(1)

    Args:
        costs: Tropical cost array.
        n: Target value.

    Returns:
        Witness tuple (a, b) or None if convolution is infinite.

    Example:
        >>> sieve = sieve_of_eratosthenes(100)
        >>> costs = tropical_cost_array(sieve)
        >>> extract_certificate(costs, 10)
        (3, 7)
    """
    best_val = INF
    best_pair = None
    for a in range(min(n + 1, len(costs))):
        b = n - a
        if b < len(costs):
            val = costs[a] + costs[b]
            if val < best_val:
                best_val = val
                best_pair = (a, b)
    return best_pair if best_val < INF else None


# ═══════════════════════════════════════════════════════════════
# Main: Run all algorithms with example usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    LIMIT = 200

    print("Tropical Additive Combinatorics — Algorithm Suite")
    print("=" * 60)

    # Generate primes
    sieve = sieve_of_eratosthenes(LIMIT)
    primes = [i for i, p in enumerate(sieve) if p]
    print(f"\nPrimes up to {LIMIT}: {len(primes)} found")
    print(f"First 20: {primes[:20]}")

    # Tropical costs
    hard_costs = tropical_cost_array(sieve)
    soft_costs = soft_cost_array(sieve, K=5)

    # Full convolution
    print(f"\nComputing min-plus self-convolution...")
    conv_hard = minplus_conv_full(hard_costs)
    conv_soft = minplus_conv_full(soft_costs)

    # Verify support = sumset equivalence (Theorem A)
    support_conv = set(tropical_support(conv_hard))
    prime_sumset = set(sumset(primes, primes, 2 * LIMIT))

    print(f"\nTheorem A verification:")
    print(f"  Support of (π_trop ⋆ π_trop): {len(support_conv)} elements")
    print(f"  Prime sumset P + P:            {len(prime_sumset)} elements")
    print(f"  Sets equal: {support_conv == prime_sumset}")

    # Goldbach verification
    print(f"\nGoldbach verification up to {LIMIT}:")
    ok, fail, decomps = verify_goldbach_range(LIMIT)
    print(f"  All verified: {ok}")
    if not ok:
        print(f"  First failure: {fail}")

    # Representation counts
    counts = goldbach_representation_count(LIMIT)
    max_reps = max(counts)
    avg_reps = sum(counts[n] for n in range(4, LIMIT + 1, 2)) / ((LIMIT - 2) // 2)
    print(f"\nGoldbach representation statistics:")
    print(f"  Max r₂(n) for n ≤ {LIMIT}: {max_reps}")
    print(f"  Average r₂(n): {avg_reps:.2f}")

    # Schnirelmann density
    sd = schnirelmann_density(sieve, LIMIT)
    print(f"\nSchnirelmann density of primes (up to {LIMIT}): {sd:.6f}")

    # Certificate extraction
    print(f"\nCertificate extraction examples:")
    for n in [4, 6, 8, 10, 20, 100]:
        cert = extract_certificate(hard_costs, n)
        if cert:
            print(f"  {n} = {cert[0]} + {cert[1]}")
        else:
            print(f"  {n}: no decomposition")

    # Monotonicity check
    print(f"\nMonotonicity (Theorem C) verification:")
    violations = 0
    for n in range(len(conv_hard)):
        if n < len(conv_soft) and conv_soft[n] > conv_hard[n]:
            violations += 1
    print(f"  soft ⋆ soft ≤ hard ⋆ hard: "
          f"{'✓' if violations == 0 else f'✗ ({violations} violations)'}")

    print(f"\nAll algorithms completed successfully.")
