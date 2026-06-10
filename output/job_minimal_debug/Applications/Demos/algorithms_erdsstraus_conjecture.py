#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for Erdős–Straus Decompositions

Implements the core algorithms from the formal framework:
1. Parametric family evaluation (even, mod-4≡3)
2. Ordered search with geometric bound pruning
3. Scaling/transfer principle
4. Surface lattice point analysis

All algorithms correspond to formally verified Lean theorems.
"""

from fractions import Fraction
from typing import Optional
from collections import Counter
import math


# ─── Parametric Families ─────────────────────────────────────────────

def even_family(m: int) -> tuple[int, int, int]:
    """Compute the even-family decomposition: 4/(2m) = 1/m + 1/(2m) + 1/(2m).

    Corresponds to: erdos_straus_even (Lean)

    Args:
        m: positive integer ≥ 1
    Returns:
        (x, y, z) such that 4/(2m) = 1/x + 1/y + 1/z
    """
    assert m >= 1, "m must be ≥ 1"
    return (m, 2 * m, 2 * m)


def mod4_eq3_family(k: int) -> tuple[int, int, int]:
    """Compute the mod-4≡3 family decomposition.

    4/(4k+3) = 1/(k+2) + 1/((k+1)(k+2)) + 1/((k+1)(4k+3))

    Corresponds to: erdos_straus_mod4_eq3 (Lean)

    Args:
        k: non-negative integer
    Returns:
        (x, y, z) such that 4/(4k+3) = 1/x + 1/y + 1/z
    """
    assert k >= 0, "k must be ≥ 0"
    n = 4 * k + 3
    x = k + 2
    y = (k + 1) * (k + 2)
    z = (k + 1) * n
    return (x, y, z)


# ─── Search Algorithm ────────────────────────────────────────────────

def candidate_z(n: int, x: int, y: int) -> Optional[int]:
    """Compute candidate z from the cleared equation.

    From 4xyz = n(xy + xz + yz), solving for z:
      z = nxy / (4xy - nx - ny)

    Corresponds to: candidateZ (Lean)

    Args:
        n, x, y: positive integers
    Returns:
        z if it exists as a positive integer, else None
    """
    denom = 4 * x * y - n * x - n * y
    if denom <= 0:
        return None
    num = n * x * y
    if num % denom != 0:
        return None
    z = num // denom
    return z if z >= 1 else None


def search_ordered(n: int, bound: int) -> Optional[tuple[int, int, int]]:
    """Search for an ordered ESWitness with denominators ≤ bound.

    Iterates x from 1 to min(bound, 3n//4), y from x to bound.
    Uses the geometric bound 4x ≤ 3n (Theorem 3.7) to prune.

    Corresponds to: searchES (Lean), with geometric pruning.

    Args:
        n: denominator (≥ 2)
        bound: maximum value for x, y, z
    Returns:
        (x, y, z) with x ≤ y ≤ z if found, else None

    Time complexity: O(bound²) worst case, typically much less due to pruning.
    Space complexity: O(1).
    """
    x_max = min(bound, 3 * n // 4)
    for x in range(1, x_max + 1):
        for y in range(x, bound + 1):
            z = candidate_z(n, x, y)
            if z is not None and z >= y:
                return (x, y, z)
    return None


def check_witness(n: int, x: int, y: int, z: int) -> bool:
    """Verify the integer surface equation: 4xyz = n(xy + xz + yz).

    Corresponds to: checkESWitness (Lean)
    """
    return (x >= 1 and y >= 1 and z >= 1 and
            4 * x * y * z == n * (x * y + x * z + y * z))


def verified_search(n: int, bound: int = 10000) -> Optional[tuple[int, int, int]]:
    """Search with post-verification.

    Corresponds to: searchESVerified (Lean)
    """
    result = search_ordered(n, bound)
    if result and check_witness(n, *result):
        return result
    return None


# ─── Scaling Principle ───────────────────────────────────────────────

def scale_witness(x: int, y: int, z: int, k: int) -> tuple[int, int, int]:
    """Apply the scaling principle: (x,y,z) for n → (kx,ky,kz) for kn.

    Corresponds to: ESDecomposition.scale / ESWitness.scale (Lean)
    """
    assert k >= 1, "k must be ≥ 1"
    return (k * x, k * y, k * z)


# ─── Combined Solver ─────────────────────────────────────────────────

def solve(n: int, bound: int = 10000) -> Optional[tuple[int, int, int]]:
    """Find a decomposition for 4/n, trying families then search.

    Strategy (corresponds to erdos_straus_cover_large_subfamily):
    1. If n is even, use even_family
    2. If n ≡ 3 (mod 4), use mod4_eq3_family
    3. Otherwise, fall back to verified_search

    Args:
        n: denominator (≥ 2)
        bound: search bound for fallback
    Returns:
        (x, y, z) such that 4/n = 1/x + 1/y + 1/z, or None
    """
    if n < 2:
        return None

    # Even family
    if n % 2 == 0:
        m = n // 2
        result = even_family(m)
        assert check_witness(n, *result), f"Even family failed for n={n}"
        return result

    # Mod-4≡3 family
    if n % 4 == 3:
        k = (n - 3) // 4
        result = mod4_eq3_family(k)
        assert check_witness(n, *result), f"Mod4≡3 family failed for n={n}"
        return result

    # Search (n ≡ 1 mod 4)
    return verified_search(n, bound)


# ─── Analysis Tools ──────────────────────────────────────────────────

def count_witnesses(n: int, bound: int) -> int:
    """Count the number of ordered witnesses (x ≤ y ≤ z) with z ≤ bound.

    Useful for testing the sparsity conjecture.
    """
    count = 0
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            z = candidate_z(n, x, y)
            if z is not None and z >= y and z <= bound:
                count += 1
    return count


def residue_class_coverage(N: int) -> dict[int, float]:
    """Compute coverage by residue class mod 4 up to N.

    Returns dict mapping residue class → fraction covered.
    """
    classes: dict[int, list[bool]] = {0: [], 1: [], 2: [], 3: []}
    for n in range(2, N + 1):
        result = solve(n)
        classes[n % 4].append(result is not None)

    return {r: sum(v) / max(len(v), 1) for r, v in classes.items()}


def simplex_coordinates(n: int, x: int, y: int, z: int) -> tuple[Fraction, Fraction, Fraction]:
    """Compute simplex coordinates: (n/(4x), n/(4y), n/(4z)).

    These sum to 1 by Theorem 3.8.
    """
    return (Fraction(n, 4 * x), Fraction(n, 4 * y), Fraction(n, 4 * z))


def all_witnesses(n: int, bound: int) -> list[tuple[int, int, int]]:
    """Find all ordered witnesses for n with z ≤ bound."""
    results = []
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            z = candidate_z(n, x, y)
            if z is not None and z >= y and z <= bound:
                results.append((x, y, z))
    return results


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Erdős–Straus Algorithms — Test Suite")
    print("=" * 50)

    # Test parametric families
    print("\n1. Even family tests:")
    for m in [1, 2, 5, 10, 50]:
        x, y, z = even_family(m)
        n = 2 * m
        ok = check_witness(n, x, y, z)
        print(f"   4/{n} = 1/{x} + 1/{y} + 1/{z}  {'✓' if ok else '✗'}")

    print("\n2. Mod-4≡3 family tests:")
    for k in [0, 1, 2, 5, 10]:
        n = 4 * k + 3
        x, y, z = mod4_eq3_family(k)
        ok = check_witness(n, x, y, z)
        print(f"   4/{n} = 1/{x} + 1/{y} + 1/{z}  {'✓' if ok else '✗'}")

    # Test complete solver
    print("\n3. Complete solver (includes n ≡ 1 mod 4):")
    for n in [5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 49, 97, 101]:
        result = solve(n)
        if result:
            x, y, z = result
            ok = check_witness(n, x, y, z)
            print(f"   4/{n} = 1/{x} + 1/{y} + 1/{z}  {'✓' if ok else '✗'}")
        else:
            print(f"   4/{n}: no solution found")

    # Test scaling
    print("\n4. Scaling principle:")
    base_n, bx, by_, bz = 5, 2, 4, 20
    for k in [1, 2, 3, 5]:
        kx, ky, kz = scale_witness(bx, by_, bz, k)
        kn = k * base_n
        ok = check_witness(kn, kx, ky, kz)
        print(f"   k={k}: 4/{kn} = 1/{kx} + 1/{ky} + 1/{kz}  {'✓' if ok else '✗'}")

    # Coverage analysis
    print("\n5. Coverage by residue class (n ≤ 200):")
    coverage = residue_class_coverage(200)
    for r in sorted(coverage):
        print(f"   n ≡ {r} (mod 4): {coverage[r]*100:.1f}% covered")

    # Witness counting (sparsity)
    print("\n6. Witness counts (sparsity analysis):")
    for n in [5, 7, 11, 13]:
        for B in [50, 100, 200]:
            c = count_witnesses(n, B)
            print(f"   n={n}, B={B}: {c} ordered witnesses")
