#!/usr/bin/env python3
"""
Tropical Sieve Energetics — Core Algorithms

Implements the algorithmic content of the tropical sieve framework:
1. Tropical (min-plus) convolution
2. Gap-pattern witness extraction
3. Residue-class twin-pair analysis
4. Gap profile computation

All algorithms include complexity analysis and type hints.
"""

import numpy as np
from typing import Set, List, Tuple, Optional, Callable, Dict


# ============================================================
# Algorithm 1: Min-Plus Convolution (Naive)
# ============================================================
def tropical_conv_naive(f: Callable[[int], float],
                        g: Callable[[int], float],
                        n: int) -> float:
    """
    Compute the min-plus (tropical) convolution of f and g at n.

    Definition:
        (f ⊕ g)(n) = min_{k=0}^{n} [f(k) + g(n-k)]

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        f: First function ℕ → ℝ
        g: Second function ℕ → ℝ
        n: Evaluation point

    Returns:
        The min-plus convolution value at n
    """
    return min(f(k) + g(n - k) for k in range(n + 1))


# ============================================================
# Algorithm 2: Min-Plus Convolution (Vectorized)
# ============================================================
def tropical_conv_array(f_vals: np.ndarray,
                        g_vals: np.ndarray,
                        N: int) -> np.ndarray:
    """
    Compute min-plus convolution for all points 0..N-1.

    Definition:
        result[n] = min_{k=0}^{n} [f[k] + g[n-k]]

    Time complexity: O(N²)
    Space complexity: O(N)

    Args:
        f_vals: Array of f values, length ≥ N
        g_vals: Array of g values, length ≥ N
        N: Number of output points

    Returns:
        Array of convolution values
    """
    result = np.full(N, np.inf)
    for n in range(N):
        vals = f_vals[:n + 1] + g_vals[n::-1][:n + 1]
        result[n] = np.min(vals)
    return result


# ============================================================
# Algorithm 3: Gap-Pattern Witness Extraction
# ============================================================
def extract_gap_witnesses(s: Set[int], N: int,
                          gap: int = 2) -> List[Tuple[int, int]]:
    """
    Extract all gap-pattern witnesses from a set.

    For each n in 0..N-1, finds k ≤ n such that k ∈ s and (n-k)+gap ∈ s.
    By Theorem C3, this is equivalent to finding where the tropical
    convolution of support costs vanishes.

    Time complexity: O(N · |s|)
    Space complexity: O(|s| + output)

    Args:
        s: The finite set
        N: Search range
        gap: The gap to detect (default 2 for twin pairs)

    Returns:
        List of (n, k) pairs where k is the witness for n
    """
    witnesses = []
    s_list = sorted(s)
    for n in range(N):
        for k in s_list:
            if k > n:
                break
            if (n - k) + gap in s:
                witnesses.append((n, k))
                break  # first witness suffices
    return witnesses


# ============================================================
# Algorithm 4: Twin-Pair Enumeration
# ============================================================
def enumerate_twin_pairs(s: Set[int]) -> List[Tuple[int, int]]:
    """
    Enumerate all twin pairs (n, n+2) in s.

    Time complexity: O(|s|)
    Space complexity: O(output)

    Args:
        s: The finite set

    Returns:
        List of (n, n+2) pairs
    """
    return [(n, n + 2) for n in sorted(s) if n + 2 in s]


# ============================================================
# Algorithm 5: Residue-Class Decomposition
# ============================================================
def residue_decomposition(s: Set[int],
                          modulus: int) -> Dict[int, Set[int]]:
    """
    Decompose a set into residue classes modulo m.

    By Theorem B2, each residue class mod 3 individually has zero
    twin pairs. Twin pairs arise only from cross-class interaction.

    Time complexity: O(|s|)
    Space complexity: O(|s|)

    Args:
        s: The finite set
        modulus: The modulus for decomposition

    Returns:
        Dict mapping residue r to {n ∈ s : n ≡ r (mod m)}
    """
    classes: Dict[int, Set[int]] = {r: set() for r in range(modulus)}
    for n in s:
        classes[n % modulus].add(n)
    return classes


def analyze_cross_residue_twins(s: Set[int],
                                modulus: int) -> Dict[Tuple[int, int], int]:
    """
    Analyze which pairs of residue classes contribute twin pairs.

    For a twin pair (n, n+2): n mod m and (n+2) mod m determine
    the residue-class interaction. This reveals the arithmetic
    structure that tropicalization alone cannot capture.

    Time complexity: O(|s|)
    Space complexity: O(m²)

    Args:
        s: The finite set
        modulus: The modulus

    Returns:
        Dict mapping (r1, r2) to count of twin pairs with
        n ≡ r1, n+2 ≡ r2 (mod m)
    """
    cross_count: Dict[Tuple[int, int], int] = {}
    for n in s:
        if n + 2 in s:
            r1 = n % modulus
            r2 = (n + 2) % modulus
            key = (r1, r2)
            cross_count[key] = cross_count.get(key, 0) + 1
    return cross_count


# ============================================================
# Algorithm 6: Gap Profile Computation
# ============================================================
def compute_gap_profile(s: Set[int], N: int,
                        max_gap: int = 20) -> np.ndarray:
    """
    Compute the full gap profile of a set.

    gap_profile[h] = |{n < N : n ∈ s and n+h ∈ s}|

    Time complexity: O(N · max_gap)
    Space complexity: O(max_gap)

    Args:
        s: The finite set
        N: Range bound
        max_gap: Maximum gap to compute

    Returns:
        Array where result[h] = gap_profile(s, h, N)
    """
    profile = np.zeros(max_gap, dtype=int)
    for h in range(max_gap):
        profile[h] = sum(1 for n in range(N) if n in s and n + h in s)
    return profile


# ============================================================
# Algorithm 7: Tropical Support Convolution Profile
# ============================================================
def tropical_support_profile(s: Set[int], N: int,
                             gap: int = 2) -> np.ndarray:
    """
    Compute the tropical convolution of support costs for all n < N.

    By Theorem C3, result[n] = 0 iff there exists k ≤ n with
    k ∈ s and (n-k)+gap ∈ s.

    Time complexity: O(N²)
    Space complexity: O(N)
    """
    f = np.array([0.0 if i in s else 1.0 for i in range(N)])
    g = np.array([0.0 if i + gap in s else 1.0 for i in range(N)])
    return tropical_conv_array(f, g, N)


# ============================================================
# Demonstration
# ============================================================
if __name__ == "__main__":
    print("Tropical Sieve Energetics — Algorithm Demonstrations")
    print("=" * 60)

    # Primes < 100
    def is_prime(n):
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

    primes = {n for n in range(100) if is_prime(n)}
    print(f"\nPrimes < 100: {sorted(primes)}")

    # Twin pairs
    twins = enumerate_twin_pairs(primes)
    print(f"\nTwin prime pairs: {twins}")
    print(f"Twin count: {len(twins)}")

    # Gap profile
    profile = compute_gap_profile(primes, 100, 20)
    print(f"\nGap profile (primes < 100):")
    for h in range(1, 20):
        if profile[h] > 0:
            print(f"  gap {h:2d}: {profile[h]:3d} pairs")

    # Residue analysis
    print(f"\nResidue decomposition mod 3:")
    classes = residue_decomposition(primes, 3)
    for r, cl in classes.items():
        tc = len(enumerate_twin_pairs(cl))
        print(f"  r={r}: {sorted(cl)[:10]}... twin_count={tc}")

    # Cross-residue twin analysis
    cross = analyze_cross_residue_twins(primes, 3)
    print(f"\nCross-residue twin pairs (mod 3):")
    for (r1, r2), count in sorted(cross.items()):
        print(f"  ({r1}, {r2}): {count} twin pairs")

    # Tropical convolution
    print(f"\nTropical support convolution (first 20 values):")
    tsc = tropical_support_profile(primes, 20)
    for n in range(20):
        w = extract_gap_witnesses(primes, n + 1)
        witness_str = f"witness at k={w[-1][1]}" if w else "no witness"
        print(f"  n={n:2d}: conv={tsc[n]:.0f}  {witness_str}")
