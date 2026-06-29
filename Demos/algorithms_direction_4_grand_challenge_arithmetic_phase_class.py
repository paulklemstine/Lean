#!/usr/bin/env python3
"""
Arithmetic Phase Classification — Core Algorithms

Implements the arithmetic torsion classifier for finite cyclic gauge models.
All algorithms have verified counterparts in Lean 4.

Time complexity: O(P * sqrt(P) * |moduli|) for profile computation
Space complexity: O(P) for the profile set
"""

from typing import List, Set, Tuple, Dict, Optional
from math import gcd, isqrt
from functools import reduce


# ─────────────────────────────────────────────────────────────────────────
# Core Primitives
# ─────────────────────────────────────────────────────────────────────────

def sieve_primes(P: int) -> List[int]:
    """
    Sieve of Eratosthenes up to P.

    Returns: sorted list of primes ≤ P.
    Time: O(P log log P)
    Space: O(P)
    """
    if P < 2:
        return []
    is_prime = [True] * (P + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, isqrt(P) + 1):
        if is_prime[i]:
            for j in range(i * i, P + 1, i):
                is_prime[j] = False
    return [i for i in range(2, P + 1) if is_prime[i]]


def prime_factors(n: int) -> Set[int]:
    """
    Compute the set of prime factors of n.

    Returns: set of primes dividing n.
    Time: O(sqrt(n))
    """
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def has_p_torsion_single(n: int, p: int) -> bool:
    """
    Check if ZMod(n) has p-torsion.

    Mathematically: ZMod(n) has p-torsion iff p | n.
    Corresponds to Lean theorem `HasPTorsion_ZMod_iff_dvd`.

    Args:
        n: modulus (positive integer)
        p: prime to test

    Returns: True iff ZMod(n) has nontrivial p-torsion.
    Time: O(1)
    """
    return n > 0 and p > 1 and n % p == 0


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 1: Torsion Profile Computation
# ─────────────────────────────────────────────────────────────────────────

def compute_torsion_profile(moduli: List[int], P: int) -> Set[int]:
    """
    Compute the torsion profile of a product of cyclic groups up to prime bound P.

    For the model ∏ᵢ ZMod(nᵢ), a prime p ≤ P is in the profile iff p | nᵢ
    for some i. This corresponds to:

        torsionProfileUpTo (∏ᵢ ZMod nᵢ) P = ⋃ᵢ torsionProfileUpTo (ZMod nᵢ) P

    which is the formal Lean theorem `torsionProfileUpTo_prod`.

    Args:
        moduli: list [n₁, ..., nₖ] of moduli for the cyclic factors
        P: prime scanning bound

    Returns: set of primes p ≤ P with p | nᵢ for some i.

    Time: O(P log log P + |primes(P)| * |moduli|)
    Space: O(P)

    Example:
        >>> sorted(compute_torsion_profile([6, 10], 11))
        [2, 3, 5]
    """
    primes = sieve_primes(P)
    profile = set()
    for p in primes:
        if any(has_p_torsion_single(n, p) for n in moduli):
            profile.add(p)
    return profile


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 2: Persistent Prime Support
# ─────────────────────────────────────────────────────────────────────────

def persistent_prime_support(
    filtration: Dict[int, List[int]],
    i: int,
    j: int,
    P: int
) -> Set[int]:
    """
    Compute the persistent prime support between levels i and j.

    A prime p is in the persistent support iff it is in the torsion profile
    at both level i and level j. Corresponds to Lean definition
    `persistentPrimeSupportUpTo`.

    Args:
        filtration: map from level index to list of moduli
        i, j: filtration levels
        P: prime scanning bound

    Returns: intersection of profiles at levels i and j.

    Time: O(P log log P + |primes(P)| * max(|moduli_i|, |moduli_j|))
    """
    profile_i = compute_torsion_profile(filtration.get(i, []), P)
    profile_j = compute_torsion_profile(filtration.get(j, []), P)
    return profile_i & profile_j


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 3: Phase Classification
# ─────────────────────────────────────────────────────────────────────────

def classify_phase(moduli: List[int], P: int) -> str:
    """
    Classify the arithmetic phase of a finite cyclic model.

    Classification:
    - "trivial": empty profile (free/torsion-free)
    - "p-primary": profile = {p} for a single prime p
    - "mixed": profile contains multiple primes
    - "rich": profile contains ≥ 3 primes

    Args:
        moduli: cyclic factors of the model
        P: prime scanning bound

    Returns: phase classification string

    Example:
        >>> classify_phase([2], 10)
        '2-primary'
        >>> classify_phase([6], 10)
        'mixed (primes: [2, 3])'
    """
    profile = compute_torsion_profile(moduli, P)
    if not profile:
        return "trivial"
    if len(profile) == 1:
        p = next(iter(profile))
        return f"{p}-primary"
    if len(profile) == 2:
        return f"mixed (primes: {sorted(profile)})"
    return f"rich (primes: {sorted(profile)})"


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 4: Phase Transition Detection
# ─────────────────────────────────────────────────────────────────────────

def detect_transitions(
    filtration: Dict[int, List[int]],
    P: int
) -> List[Tuple[int, Set[int], Set[int]]]:
    """
    Detect arithmetic phase transitions in a filtered system.

    A transition occurs at level k if the torsion profile changes from
    level k-1 to level k. Returns (level, births, deaths) for each transition.

    Args:
        filtration: map from level to moduli
        P: prime scanning bound

    Returns: list of (level, births, deaths) tuples

    Time: O(L * P log log P) where L = number of levels
    """
    levels = sorted(filtration.keys())
    transitions = []
    prev_profile = set()

    for level in levels:
        profile = compute_torsion_profile(filtration[level], P)
        births = profile - prev_profile
        deaths = prev_profile - profile
        if births or deaths:
            transitions.append((level, births, deaths))
        prev_profile = profile

    return transitions


# ─────────────────────────────────────────────────────────────────────────
# Algorithm 5: Completeness Check
# ─────────────────────────────────────────────────────────────────────────

def is_profile_complete(moduli: List[int], P: int) -> bool:
    """
    Check if the prime bound P is sufficient for completeness.

    The profile is complete if P ≥ max prime factor of any modulus.
    This corresponds to the Lean theorem
    `torsionProfileUpTo_complete_for_bounded_support`.

    Args:
        moduli: cyclic factors
        P: prime scanning bound

    Returns: True iff all torsion primes are ≤ P.

    Example:
        >>> is_profile_complete([6], 3)
        True
        >>> is_profile_complete([6], 2)
        False
    """
    all_primes = set()
    for n in moduli:
        all_primes |= prime_factors(n)
    return all(p <= P for p in all_primes)


def minimal_complete_bound(moduli: List[int]) -> int:
    """
    Compute the minimal P for which the profile is complete.

    Returns: smallest P such that all torsion primes are ≤ P.
    """
    all_primes = set()
    for n in moduli:
        all_primes |= prime_factors(n)
    return max(all_primes) if all_primes else 0


# ─────────────────────────────────────────────────────────────────────────
# Self-test
# ─────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm self-tests:")

    # Test 1: Profile computation
    assert compute_torsion_profile([2], 10) == {2}
    assert compute_torsion_profile([3], 10) == {3}
    assert compute_torsion_profile([6], 10) == {2, 3}
    assert compute_torsion_profile([30], 10) == {2, 3, 5}
    assert compute_torsion_profile([], 10) == set()
    print("  ✓ Profile computation")

    # Test 2: Phase classification
    assert classify_phase([2], 10) == "2-primary"
    assert classify_phase([3], 10) == "3-primary"
    assert classify_phase([], 10) == "trivial"
    assert "mixed" in classify_phase([6], 10)
    print("  ✓ Phase classification")

    # Test 3: Phase separation
    p1 = compute_torsion_profile([2], 10)
    p2 = compute_torsion_profile([3], 10)
    assert p1 != p2, "Toric code and Z/3Z gauge must be separated"
    print("  ✓ Phase separation (toric vs Z/3Z)")

    # Test 4: Completeness
    assert is_profile_complete([6], 3) == True
    assert is_profile_complete([6], 2) == False
    assert minimal_complete_bound([30]) == 5
    print("  ✓ Completeness checks")

    # Test 5: Transition detection
    filtration = {0: [], 1: [2], 2: [2, 3], 3: [2]}
    transitions = detect_transitions(filtration, 10)
    assert len(transitions) == 3
    print("  ✓ Transition detection")

    # Test 6: Product accumulation
    p_prod = compute_torsion_profile([2, 3], 10)
    p_union = compute_torsion_profile([2], 10) | compute_torsion_profile([3], 10)
    assert p_prod == p_union, "Product profile = union of factor profiles"
    print("  ✓ Product accumulation")

    print("\n  All tests passed! ✓")
