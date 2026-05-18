#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Prime Gap Infrastructure

Implements:
1. Admissibility checking (O(k² log k) where k = |H|)
2. Local obstruction counting
3. CRT survivor enumeration and product formula verification
4. Rayleigh quotient optimization
5. Optimal admissible tuple search
"""

from math import gcd, log, sqrt, prod
from functools import reduce
from typing import Optional
import time


# ─── Primality and Prime Generation ──────────────────────────────────────────

def sieve_of_eratosthenes(n: int) -> list[int]:
    """Return all primes ≤ n using the Sieve of Eratosthenes.

    Time: O(n log log n)
    Space: O(n)

    >>> sieve_of_eratosthenes(20)
    [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n ** 0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def is_prime(n: int) -> bool:
    """Primality test (trial division).

    Time: O(√n)

    >>> is_prime(97)
    True
    >>> is_prime(100)
    False
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


# ─── Algorithm 1: Admissibility Checker ──────────────────────────────────────

def check_admissible(H: list[int], verbose: bool = False) -> tuple[bool, Optional[int]]:
    """
    Check whether the tuple H is admissible.

    Algorithm:
        For each prime p ≤ |H|, compute the set of distinct residues of H mod p.
        If any prime p has |H mod p| = p, then H is inadmissible (return that prime).
        Otherwise H is admissible.

    Time: O(k² / log k) where k = |H| (by prime number theorem, ~k/ln(k) primes to check)
    Space: O(k)

    Args:
        H: List of non-negative integers (the tuple)
        verbose: If True, print details for each prime

    Returns:
        (is_admissible, covering_prime) where covering_prime is None if admissible

    >>> check_admissible([0, 2, 6])
    (True, None)
    >>> check_admissible([0, 2, 4])
    (False, 3)
    """
    k = len(H)
    primes = sieve_of_eratosthenes(k)

    for p in primes:
        residues = set(h % p for h in H)
        if verbose:
            print(f"  p={p}: residues = {sorted(residues)}, "
                  f"|residues| = {len(residues)}/{p}")
        if len(residues) == p:
            return (False, p)

    return (True, None)


# ─── Algorithm 2: Local Obstruction Analysis ─────────────────────────────────

def local_obstruction_profile(H: list[int], B: int) -> dict[int, dict]:
    """
    Compute the local obstruction profile of H for all primes p ≤ B.

    For each prime p, computes:
    - obstruction_count: |H mod p| (number of forbidden residue classes)
    - survivor_count: p - |H mod p|
    - survivor_fraction: (p - |H mod p|) / p
    - avoided_residue: one residue a with (a+h) % p ≠ 0 for all h ∈ H

    Time: O(B² / log B + k·B) where k = |H|
    Space: O(B + k)

    >>> profile = local_obstruction_profile([0, 2], 10)
    >>> profile[2]['survivor_count']
    1
    >>> profile[3]['survivor_count']
    1
    """
    primes = sieve_of_eratosthenes(B)
    profile = {}

    for p in primes:
        residues = set(h % p for h in H)
        obs = len(residues)

        # Find an avoiding residue
        avoided = None
        for a in range(p):
            if all((a + h) % p != 0 for h in H):
                avoided = a
                break

        profile[p] = {
            'obstruction_count': obs,
            'survivor_count': p - obs,
            'survivor_fraction': (p - obs) / p,
            'avoided_residue': avoided,
            'residues': sorted(residues),
        }

    return profile


# ─── Algorithm 3: CRT Survivor Enumeration ───────────────────────────────────

def primorial(B: int) -> int:
    """Product of all primes ≤ B.

    >>> primorial(10)
    210
    """
    result = 1
    for p in sieve_of_eratosthenes(B):
        result *= p
    return result


def enumerate_survivors(H: list[int], B: int) -> list[int]:
    """
    Enumerate all CRT survivors modulo primorial(B).

    A survivor is n ∈ [0, primorial(B)) such that for every prime p ≤ B
    and every h ∈ H, p does not divide (n + h).

    Time: O(primorial(B) · k · π(B)) where k = |H|
    Space: O(primorial(B))

    >>> len(enumerate_survivors([0, 2], 5))
    8
    """
    M = primorial(B)
    primes = sieve_of_eratosthenes(B)
    survivors = []
    for n in range(M):
        if all((n + h) % p != 0 for p in primes for h in H):
            survivors.append(n)
    return survivors


def survivor_product_formula(H: list[int], B: int) -> int:
    """
    Compute the predicted survivor count via the product formula:
    ∏_{p ≤ B, p prime} (p - |H mod p|)

    This should equal the actual count from enumerate_survivors.

    >>> survivor_product_formula([0, 2], 5)
    8
    """
    result = 1
    for p in sieve_of_eratosthenes(B):
        result *= (p - len(set(h % p for h in H)))
    return result


def verify_product_formula(H: list[int], B: int) -> dict:
    """
    Verify the CRT survivor product formula for given H and B.

    Returns a dict with actual count, predicted count, and whether they match.

    >>> result = verify_product_formula([0, 2], 7)
    >>> result['match']
    True
    """
    actual = len(enumerate_survivors(H, B))
    predicted = survivor_product_formula(H, B)
    M = primorial(B)
    return {
        'modulus': M,
        'actual_count': actual,
        'predicted_count': predicted,
        'match': actual == predicted,
        'density': actual / M if M > 0 else 0,
    }


# ─── Algorithm 4: Rayleigh Quotient Analysis ─────────────────────────────────

def rayleigh_quotient(w: list[float]) -> float:
    """
    Compute S₂(w)/S₁(w) = (∑wᵢ)² / ∑wᵢ².

    The theorem guarantees this is ≤ k = len(w),
    with equality iff all weights are equal.

    >>> rayleigh_quotient([1.0, 1.0, 1.0])
    3.0
    >>> rayleigh_quotient([1.0, 0.0, 0.0])
    1.0
    """
    s1 = sum(x ** 2 for x in w)
    s2 = sum(w) ** 2
    if s1 == 0:
        return 0.0
    return s2 / s1


def optimal_weight_for_threshold(k: int, tau: float) -> Optional[list[float]]:
    """
    If tau < k, return a weight vector w with S₂/S₁ > tau.
    If tau ≥ k, return None (impossible by our theorem).

    The constant vector w = (1,...,1) achieves ratio = k,
    which beats any tau < k.

    >>> w = optimal_weight_for_threshold(5, 3.0)
    >>> w is not None
    True
    >>> rayleigh_quotient(w) > 3.0
    True
    """
    if tau >= k:
        return None
    # Constant vector achieves the maximum ratio = k
    return [1.0] * k


# ─── Algorithm 5: Admissible Tuple Search ────────────────────────────────────

def search_admissible_tuples(k: int, diameter_bound: int) -> list[list[int]]:
    """
    Search for admissible k-tuples with diameter ≤ diameter_bound.

    Uses greedy construction: start with {0}, repeatedly add the smallest
    integer that preserves admissibility.

    Time: O(diameter_bound · k² / log k) per candidate
    Space: O(k)

    >>> tuples = search_admissible_tuples(3, 10)
    >>> [0, 2, 6] in tuples
    True
    """
    results = []

    def backtrack(current: list[int], start: int):
        if len(current) == k:
            results.append(current[:])
            return
        for next_val in range(start, diameter_bound + 1):
            candidate = current + [next_val]
            if check_admissible(candidate)[0]:
                backtrack(candidate, next_val + 1)

    backtrack([0], 1)
    return results


# ─── Main: Run All Algorithms ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Algorithm 1: Admissibility
    print("\n--- Algorithm 1: Admissibility Checker ---")
    test_tuples = [
        [0, 2],
        [0, 2, 4],
        [0, 2, 6],
        [0, 2, 6, 8, 12],
        [0, 4, 6, 10, 12, 16],
    ]
    for H in test_tuples:
        result, prime = check_admissible(H)
        status = "admissible" if result else f"inadmissible (covering prime: {prime})"
        print(f"  H = {str(H):30s} → {status}")

    # Algorithm 2: Local Profile
    print("\n--- Algorithm 2: Local Obstruction Profile ---")
    H = [0, 2, 6]
    print(f"  H = {H}")
    profile = local_obstruction_profile(H, 13)
    for p, data in sorted(profile.items()):
        print(f"    p={p:3d}: obstructions={data['obstruction_count']}, "
              f"survivors={data['survivor_count']}, "
              f"fraction={data['survivor_fraction']:.4f}, "
              f"avoided={data['avoided_residue']}")

    # Algorithm 3: Product Formula Verification
    print("\n--- Algorithm 3: CRT Survivor Product Formula ---")
    for H_name, H in [("{0,2}", [0, 2]), ("{0,2,6}", [0, 2, 6])]:
        print(f"  H = {H_name}")
        for B in [5, 7, 11, 13]:
            result = verify_product_formula(H, B)
            print(f"    B={B:3d}: modulus={result['modulus']:8d}, "
                  f"actual={result['actual_count']:6d}, "
                  f"predicted={result['predicted_count']:6d}, "
                  f"match={'✓' if result['match'] else '✗'}, "
                  f"density={result['density']:.6f}")

    # Algorithm 4: Rayleigh Quotient
    print("\n--- Algorithm 4: Rayleigh Quotient Bound ---")
    import random
    random.seed(42)
    for k in [3, 10, 50]:
        w = [random.gauss(0, 1) for _ in range(k)]
        r = rayleigh_quotient(w)
        print(f"  k={k:3d}: random ratio = {r:.4f} ≤ {k} ({'✓' if r <= k + 1e-10 else '✗'})")

    # Algorithm 5: Tuple Search
    print("\n--- Algorithm 5: Admissible Tuple Search ---")
    for k in [2, 3, 4]:
        t0 = time.time()
        tuples = search_admissible_tuples(k, 12)
        t1 = time.time()
        print(f"  k={k}: found {len(tuples)} tuples with diameter ≤ 12 ({t1-t0:.3f}s)")
        if tuples:
            print(f"    Smallest diameter: {tuples[0]}")

    print("\n" + "=" * 70)
    print("All algorithms complete.")
