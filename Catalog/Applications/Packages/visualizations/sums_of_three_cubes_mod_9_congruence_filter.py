#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Sums of Three Cubes

Implements the algorithms described in the research paper, each with
formal correctness guarantees traceable to verified theorems.

All algorithms are self-contained and can be run independently.
"""

from typing import Optional, Set, List, Tuple, Dict
from collections import defaultdict
import math


# ============================================================================
# Algorithm 1: Congruence Filter
# ============================================================================

def mod9_filter(k: int) -> bool:
    """Certified congruence filter for impossible targets.

    Returns True if k is admissible (not forbidden mod 9).
    Returns False if k is provably not a sum of three cubes.

    Correctness: forbiddenModNine_not_representable
    Complexity: O(1) time and space

    Examples:
        >>> mod9_filter(0)
        True
        >>> mod9_filter(4)
        False
        >>> mod9_filter(5)
        False
        >>> mod9_filter(33)
        True
        >>> mod9_filter(42)
        True
    """
    return k % 9 not in (4, 5)


def admissible_residues_mod(n: int) -> Set[int]:
    """Compute all residues mod n achievable by x³+y³+z³.

    Returns the set of r ∈ {0,...,n-1} such that
    ∃ x,y,z ∈ Z/nZ: x³+y³+z³ ≡ r (mod n).

    Correctness: exhaustive enumeration over (Z/nZ)³
    Complexity: O(n³) time, O(n) space

    Examples:
        >>> sorted(admissible_residues_mod(9))
        [0, 1, 2, 3, 6, 7, 8]
    """
    cubes = {pow(x, 3, n) for x in range(n)}
    achievable = set()
    for a in cubes:
        for b in cubes:
            for c in cubes:
                achievable.add((a + b + c) % n)
    return achievable


def forbidden_residues_mod(n: int) -> Set[int]:
    """Compute residues mod n that are NOT achievable by x³+y³+z³.

    Examples:
        >>> sorted(forbidden_residues_mod(9))
        [4, 5]
        >>> sorted(forbidden_residues_mod(7))
        []
    """
    achievable = admissible_residues_mod(n)
    return set(range(n)) - achievable


# ============================================================================
# Algorithm 2: Local Solubility Checker
# ============================================================================

def local_solubility_check(k: int, n: int) -> bool:
    """Check if x³+y³+z³ ≡ k (mod n) is soluble.

    Correctness: Corresponds to LocallyAtMod k n
    Complexity: O(n²) time, O(n) space

    Examples:
        >>> local_solubility_check(0, 9)
        True
        >>> local_solubility_check(4, 9)
        False
        >>> local_solubility_check(33, 9)
        True
    """
    cubes = {pow(x, 3, n) for x in range(n)}
    target = k % n
    pair_sums = {(a + b) % n for a in cubes for b in cubes}
    return any((target - c) % n in pair_sums for c in cubes)


def full_local_check(k: int, moduli: Optional[List[int]] = None) -> Dict[int, bool]:
    """Check local solubility at multiple moduli.

    Returns a dictionary mapping each modulus to its solubility status.

    Correctness: global_implies_local ensures that if k is representable,
    all entries must be True.

    Examples:
        >>> result = full_local_check(33)
        >>> all(result.values())
        True
        >>> result = full_local_check(4)
        >>> result[9]
        False
    """
    if moduli is None:
        moduli = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 25, 27, 49, 64, 81]
    return {n: local_solubility_check(k, n) for n in moduli}


# ============================================================================
# Algorithm 3: Symmetry-Reduced Bounded Search
# ============================================================================

def symmetry_reduced_search(
    k: int,
    bound: int = 10000,
    verbose: bool = False
) -> Optional[Tuple[int, int, int]]:
    """Search for x,y,z with x³+y³+z³=k using symmetry reduction.

    Exploits:
    1. Mod 9 filter (certified by forbiddenModNine_not_representable)
    2. Ordering x ≤ y ≤ z (S₃ symmetry reduction)
    3. Cube-root inversion (reduces O(B³) to O(B²))

    Returns (x, y, z) with x ≤ y ≤ z, or None.

    Correctness: If a triple is returned, it satisfies x³+y³+z³=k.
    Complexity: O(B²) time

    Examples:
        >>> symmetry_reduced_search(0)
        (0, 0, 0)
        >>> symmetry_reduced_search(2)
        (0, 1, 1)
        >>> symmetry_reduced_search(4)  # Forbidden mod 9
    """
    # Step 1: Certified filter
    if not mod9_filter(k):
        if verbose:
            print(f"  k={k} is forbidden mod 9. Certified impossible.")
        return None

    # Step 2: Symmetry-reduced search with cube-root inversion
    triples_checked = 0
    for z in range(-bound, bound + 1):
        z3 = z ** 3
        for y in range(-bound, z + 1):
            y3 = y ** 3
            remainder = k - y3 - z3
            triples_checked += 1

            # Compute cube root
            if remainder == 0:
                x = 0
            elif remainder > 0:
                x = round(remainder ** (1.0 / 3.0))
            else:
                x = -round((-remainder) ** (1.0 / 3.0))

            # Check x and neighbors (floating point precision)
            for x_try in range(x - 2, x + 3):
                if x_try ** 3 == remainder and x_try <= y:
                    if verbose:
                        print(f"  Found after checking {triples_checked} (y,z) pairs")
                    return (x_try, y, z)

    if verbose:
        print(f"  No solution found after {triples_checked} (y,z) pairs")
    return None


def naive_search(k: int, bound: int = 1000) -> Optional[Tuple[int, int, int]]:
    """Naive exhaustive search (for benchmarking comparison).

    Complexity: O(B³) time
    """
    if not mod9_filter(k):
        return None
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            for z in range(-bound, bound + 1):
                if x**3 + y**3 + z**3 == k:
                    return (x, y, z)
    return None


# ============================================================================
# Algorithm 4: Polynomial Family Generator
# ============================================================================

def vieta_family(a: int, b: int) -> Tuple[int, Tuple[int, int, int]]:
    """Generate a representable integer from the Vieta identity.

    a³ + b³ + (-a-b)³ = -3ab(a+b)

    Returns (k, (a, b, -a-b)) where k = -3ab(a+b).

    Correctness: vieta_cubes_identity, representable_neg3_family

    Examples:
        >>> vieta_family(1, 1)
        (-6, (1, 1, -2))
        >>> k, (x, y, z) = vieta_family(2, 3)
        >>> x**3 + y**3 + z**3 == k
        True
    """
    c = -a - b
    k = -3 * a * b * (a + b)
    return (k, (a, b, c))


def generate_representable_family(n: int) -> List[Tuple[int, Tuple[int, int, int]]]:
    """Generate n representable integers from the Vieta family and cubes.

    Combines:
    - Cubes: m³ = m³ + 0³ + 0³ (three_cube_representable_of_cube)
    - Vieta: -3ab(a+b) (representable_neg3_family)

    Examples:
        >>> family = generate_representable_family(20)
        >>> all(x**3 + y**3 + z**3 == k for k, (x, y, z) in family)
        True
    """
    results = set()
    seen_k = set()

    # Cubes
    for m in range(-n, n + 1):
        k = m ** 3
        if k not in seen_k:
            results.add((k, (m, 0, 0)))
            seen_k.add(k)

    # Vieta family
    for a in range(1, n + 1):
        for b in range(1, n + 1):
            k, triple = vieta_family(a, b)
            if k not in seen_k:
                results.add((k, triple))
                seen_k.add(k)
            if len(results) >= n:
                break
        if len(results) >= n:
            break

    return sorted(results, key=lambda x: abs(x[0]))[:n]


# ============================================================================
# Density Analysis
# ============================================================================

def admissibility_density(N: int) -> float:
    """Compute the fraction of integers in [0, N) that are admissible.

    Theoretical limit: 7/9 ≈ 0.7778 (admissible_residues_count)

    Examples:
        >>> abs(admissibility_density(9000) - 7/9) < 0.001
        True
    """
    count = sum(1 for k in range(N) if mod9_filter(k))
    return count / N


# ============================================================================
# Main demo
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Algorithms for Sums of Three Cubes")
    print("=" * 60)

    # Demo 1: Forbidden residues at various moduli
    print("\n--- Forbidden residues at various moduli ---")
    for n in [4, 7, 8, 9, 16, 27]:
        forb = forbidden_residues_mod(n)
        print(f"  mod {n:>3}: forbidden = {sorted(forb) if forb else '∅'}")

    # Demo 2: Local solubility
    print("\n--- Local solubility for k = 0..20 mod 9 ---")
    for k in range(20):
        sol = local_solubility_check(k, 9)
        print(f"  k={k:>2}: {'soluble' if sol else 'NOT soluble'} mod 9 "
              f"(residue {k%9}, {'admissible' if mod9_filter(k) else 'FORBIDDEN'})")

    # Demo 3: Symmetry-reduced search
    print("\n--- Symmetry-reduced search (bound=1000) ---")
    for k in [0, 1, 2, 3, 6, 7, 8, 10, 17, 29, 30]:
        result = symmetry_reduced_search(k, bound=1000, verbose=False)
        if result:
            x, y, z = result
            print(f"  k={k:>3}: ({x})³ + ({y})³ + ({z})³ = {x**3+y**3+z**3}")
        else:
            print(f"  k={k:>3}: no solution within bound")

    # Demo 4: Vieta family
    print("\n--- Vieta polynomial family ---")
    family = generate_representable_family(15)
    for k, (x, y, z) in family:
        print(f"  k={k:>6}: ({x})³ + ({y})³ + ({z})³ = {x**3+y**3+z**3}")

    # Demo 5: Density convergence
    print("\n--- Admissibility density convergence ---")
    for N in [9, 90, 900, 9000, 90000]:
        d = admissibility_density(N)
        print(f"  N={N:>6}: density = {d:.6f}  (7/9 = {7/9:.6f})")
