#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Primewise Torsion Persistence Stability

Implements the core computational methods for:
1. Computing p-primary torsion birth sets
2. Computing primewise stability constants
3. The prime shift bound formula
4. Prime birth energy decomposition
"""

from typing import Dict, List, Optional, Set, Tuple
from collections import defaultdict
import math


# =============================================================================
# Algorithm 1: Prime Factorization and Torsion Detection
# =============================================================================

def prime_factors(n: int) -> List[int]:
    """Compute the prime factorization of n.

    Time complexity: O(sqrt(n))
    Space complexity: O(log n)

    Args:
        n: A positive integer >= 2

    Returns:
        List of distinct prime factors of n, sorted ascending.

    Example:
        >>> prime_factors(30)
        [2, 3, 5]
        >>> prime_factors(12)
        [2, 3]
    """
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def has_p_torsion(cyclic_orders: List[int], p: int) -> bool:
    """Check if a finitely generated abelian group has p-torsion.

    The group is represented as a product of cyclic groups Z/n_i Z.
    A group has p-torsion iff some n_i is divisible by p.

    Time complexity: O(k) where k = number of cyclic factors
    Space complexity: O(1)

    Args:
        cyclic_orders: List of orders (0 = Z, n>0 = Z/nZ)
        p: Prime to test

    Returns:
        True if p-torsion is detected.

    Example:
        >>> has_p_torsion([6, 0], 2)  # Z/6Z × Z has 2-torsion
        True
        >>> has_p_torsion([6, 0], 7)  # Z/6Z × Z has no 7-torsion
        False
    """
    return any(order > 0 and order % p == 0 for order in cyclic_orders)


def detect_torsion_primes(cyclic_orders: List[int]) -> Set[int]:
    """Detect all primes p for which p-torsion exists.

    Time complexity: O(k * sqrt(max_order))
    Space complexity: O(number of distinct primes)

    Args:
        cyclic_orders: List of orders for the cyclic factors

    Returns:
        Set of primes p such that the group has p-torsion.

    Example:
        >>> sorted(detect_torsion_primes([30]))
        [2, 3, 5]
    """
    primes = set()
    for order in cyclic_orders:
        if order > 1:
            for p in prime_factors(order):
                primes.add(p)
    return primes


# =============================================================================
# Algorithm 2: P-Torsion Birth Set Computation
# =============================================================================

def compute_p_torsion_birth(
    filtration: List[List[int]],
    p: int
) -> Optional[int]:
    """Compute the p-torsion birth index for a filtration.

    ALGORITHM (P-Torsion Birth Detection):
        Input: Filtration F = [G_0, G_1, ..., G_N], prime p
        Output: Minimum index i such that G_i has p-torsion, or None

        1. For i = 0, 1, ..., N:
        2.   If has_p_torsion(G_i, p):
        3.     Return i
        4. Return None

    Time complexity: O(N * k) where N = filtration length, k = max group rank
    Space complexity: O(1)

    Args:
        filtration: List of groups, each represented as list of cyclic orders
        p: Prime to detect

    Returns:
        Birth index, or None if p-torsion is never detected.

    Example:
        >>> # Z -> Z/2Z -> Z/6Z
        >>> compute_p_torsion_birth([[0], [2], [6]], 2)
        1
        >>> compute_p_torsion_birth([[0], [2], [6]], 3)
        2
    """
    for i, group in enumerate(filtration):
        if has_p_torsion(group, p):
            return i
    return None


def compute_prime_birth_spectrum(
    filtration: List[List[int]],
    primes: List[int]
) -> Dict[int, Optional[int]]:
    """Compute the full prime birth spectrum of a filtration.

    ALGORITHM (Prime Birth Spectrum):
        Input: Filtration F, set of primes P
        Output: Dictionary {p: birth_index(p)} for each p in P

        For each prime p in P:
            spectrum[p] = compute_p_torsion_birth(F, p)

    Time complexity: O(|P| * N * k)
    Space complexity: O(|P|)

    Args:
        filtration: List of groups
        primes: List of primes to analyze

    Returns:
        Dictionary mapping each prime to its birth index (or None).

    Example:
        >>> compute_prime_birth_spectrum([[0], [2], [6]], [2, 3, 5])
        {2: 1, 3: 2, 5: None}
    """
    return {p: compute_p_torsion_birth(filtration, p) for p in primes}


# =============================================================================
# Algorithm 3: Stability Radius Computation
# =============================================================================

def primewise_stability_radius(
    p: int,
    F: List[List[int]],
    G: List[List[int]]
) -> Optional[int]:
    """Compute the optimal p-channel stability radius between two filtrations.

    ALGORITHM (Primewise Stability Radius):
        Input: Prime p, filtrations F and G
        Output: Hausdorff distance between PTorsionBirthSet(p, F)
                and PTorsionBirthSet(p, G)

        1. birth_F = compute_p_torsion_birth(F, p)
        2. birth_G = compute_p_torsion_birth(G, p)
        3. If both None: return 0 (both empty)
        4. If exactly one None: return None (infinite distance)
        5. Return |birth_F - birth_G|

    Time complexity: O(N * k)
    Space complexity: O(1)

    Args:
        p: Prime for the channel
        F: First filtration
        G: Second filtration

    Returns:
        Stability radius, or None if sets are incomparable.

    Example:
        >>> primewise_stability_radius(2, [[0], [2]], [[0], [0], [2]])
        1
    """
    bF = compute_p_torsion_birth(F, p)
    bG = compute_p_torsion_birth(G, p)

    if bF is None and bG is None:
        return 0
    if bF is None or bG is None:
        return None
    return abs(bF - bG)


def global_stability_radius(
    F: List[List[int]],
    G: List[List[int]]
) -> Optional[int]:
    """Compute the global torsion stability radius.

    Time complexity: O(N * k * sqrt(max_order))
    Space complexity: O(1)
    """
    def global_birth(filt):
        for i, group in enumerate(filt):
            if detect_torsion_primes(group):
                return i
        return None

    bF = global_birth(F)
    bG = global_birth(G)

    if bF is None and bG is None:
        return 0
    if bF is None or bG is None:
        return None
    return abs(bF - bG)


# =============================================================================
# Algorithm 4: Prime Shift Bound
# =============================================================================

def prime_shift_bound(p: int, delta: int) -> int:
    """Compute the conservative prime shift bound.

    ALGORITHM (Prime Shift Bound):
        Input: Prime p, interleaving parameter δ
        Output: Primewise stability modulus

        The conservative bound is simply δ.
        The improved (conjectural) bound is δ/p when p | δ.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        p: Prime for the channel
        delta: Global interleaving parameter

    Returns:
        Primewise stability modulus (conservative: δ)
    """
    return delta


def prime_shift_bound_improved(p: int, delta: int) -> int:
    """Compute the improved (conjectural) prime shift bound.

    When p divides δ, the bound improves to δ/p.
    This requires additional arithmetic control on the interleaving maps.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        p: Prime (>= 2)
        delta: Global interleaving parameter

    Returns:
        Improved primewise stability modulus.

    Example:
        >>> prime_shift_bound_improved(2, 6)
        3
        >>> prime_shift_bound_improved(3, 7)
        7
    """
    if p >= 2 and delta % p == 0:
        return delta // p
    return delta


# =============================================================================
# Algorithm 5: Prime Birth Energy
# =============================================================================

def prime_birth_energy(
    filtration: List[List[int]],
    N: int,
    primes: List[int]
) -> int:
    """Compute the prime birth energy at level N.

    ALGORITHM (Prime Birth Energy):
        Input: Filtration F, level N, set of primes P
        Output: Number of primes whose torsion is born at or before level N

        energy = 0
        For each prime p in P:
            birth = compute_p_torsion_birth(F, p)
            If birth is not None and birth <= N:
                energy += 1
        Return energy

    Time complexity: O(|P| * N * k)
    Space complexity: O(1)

    Args:
        filtration: The filtration
        N: Level up to which to count
        primes: Set of primes to consider

    Returns:
        Number of active prime channels at level N.

    Example:
        >>> prime_birth_energy([[0], [2], [6]], 1, [2, 3, 5])
        1
        >>> prime_birth_energy([[0], [2], [6]], 2, [2, 3, 5])
        2
    """
    energy = 0
    for p in primes:
        birth = compute_p_torsion_birth(filtration, p)
        if birth is not None and birth <= N:
            energy += 1
    return energy


# =============================================================================
# Algorithm 6: Strict Improvement Search
# =============================================================================

def find_strict_improvements(
    filtrations: List[Tuple[List[List[int]], List[List[int]]]],
    primes: List[int]
) -> List[Dict]:
    """Search for examples where primewise stability is strictly better.

    ALGORITHM (Strict Improvement Search):
        Input: List of filtration pairs (F, G), set of primes P
        Output: List of examples where ε_p < ε_global for some p

        results = []
        For each pair (F, G):
            ε_global = global_stability_radius(F, G)
            For each prime p in P:
                ε_p = primewise_stability_radius(p, F, G)
                If ε_p < ε_global:
                    Record (F, G, p, ε_p, ε_global)
        Return results

    Time complexity: O(|pairs| * |P| * N * k * sqrt(max_order))
    Space complexity: O(|results|)
    """
    results = []
    for F, G in filtrations:
        eps_global = global_stability_radius(F, G)
        if eps_global is None or eps_global == 0:
            continue

        for p in primes:
            eps_p = primewise_stability_radius(p, F, G)
            if eps_p is not None and eps_p < eps_global:
                results.append({
                    'prime': p,
                    'eps_p': eps_p,
                    'eps_global': eps_global,
                    'improvement_factor': eps_global / max(eps_p, 1),
                })
                break  # One improvement per pair suffices

    return results


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("Algorithms for Primewise Torsion Persistence Stability")
    print("=" * 55)

    # Example: Z -> Z/2 -> Z/6 -> Z/30
    F = [[0], [2], [6], [30]]
    print(f"\nFiltration: {F}")

    spectrum = compute_prime_birth_spectrum(F, [2, 3, 5, 7])
    print(f"Prime birth spectrum: {spectrum}")

    for N in range(len(F)):
        e = prime_birth_energy(F, N, [2, 3, 5, 7])
        print(f"  Energy at level {N}: {e}")

    # Example: compare two filtrations
    F1 = [[0], [2], [6]]
    F2 = [[0], [0], [2], [6]]

    for p in [2, 3]:
        r = primewise_stability_radius(p, F1, F2)
        print(f"\np={p} stability radius: {r}")

    g = global_stability_radius(F1, F2)
    print(f"Global stability radius: {g}")

    # Prime shift bound
    for p in [2, 3, 5]:
        for d in [4, 6, 10]:
            b = prime_shift_bound_improved(p, d)
            print(f"  primeShiftBound_improved({p}, {d}) = {b}")
