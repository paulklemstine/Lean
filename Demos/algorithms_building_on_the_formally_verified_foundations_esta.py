#!/usr/bin/env python3
"""
Perfect Cuboid Modular Sieve — Algorithms

Core algorithms for the modular residue sieve approach to the perfect
cuboid problem. Includes efficient sieve construction, CRT decomposition,
and density analysis.
"""

from itertools import product
from math import gcd, isqrt
from functools import reduce
from typing import Optional


# ============================================================================
# Algorithm 1: Quadratic Residue Computation
# ============================================================================

def quadratic_residues(M: int) -> set[int]:
    """
    Compute the set of quadratic residues modulo M.

    Time complexity: O(M)
    Space complexity: O(M)

    A quadratic residue mod M is any integer a such that x² ≡ a (mod M)
    has a solution. For prime p, exactly (p+1)/2 residues exist.

    Args:
        M: The modulus (positive integer)

    Returns:
        Set of integers in {0, ..., M-1} that are quadratic residues mod M

    Example:
        >>> sorted(quadratic_residues(7))
        [0, 1, 2, 4]
    """
    return {(t * t) % M for t in range(M)}


def quadratic_residue_count(M: int) -> int:
    """Count quadratic residues modulo M."""
    return len(quadratic_residues(M))


# ============================================================================
# Algorithm 2: Perfect Cuboid Modular Sieve
# ============================================================================

def cuboid_sieve(M: int, *, face_only: bool = False,
                 parity: bool = False) -> list[tuple[int, int, int]]:
    """
    Enumerate all residue triples (x, y, z) mod M satisfying the
    perfect cuboid quadratic residue conditions.

    Time complexity: O(M^4) — M^3 triples × M checks per QR test
    Space complexity: O(M + |survivors|)

    The algorithm:
    1. Precompute quadratic residues mod M.
    2. For each triple (x, y, z) in {0, ..., M-1}^3:
       a. Optionally check parity (two even, one odd).
       b. Check if x²+y², x²+z², y²+z² are QR mod M (face diagonals).
       c. If not face_only, also check x²+y²+z² (space diagonal).
    3. Return surviving triples.

    Args:
        M: Modulus
        face_only: If True, only check face diagonal conditions
        parity: If True, also require residue-level parity constraint

    Returns:
        List of surviving triples (x, y, z)

    Example:
        >>> len(cuboid_sieve(7))
        55
        >>> len(cuboid_sieve(7, parity=True))
        27
    """
    qr = quadratic_residues(M)
    survivors = []

    for x, y, z in product(range(M), repeat=3):
        if parity:
            p = (x % 2, y % 2, z % 2)
            if p not in [(0, 0, 1), (0, 1, 0), (1, 0, 0)]:
                continue

        s1 = (x * x + y * y) % M
        s2 = (x * x + z * z) % M
        s3 = (y * y + z * z) % M

        if s1 not in qr or s2 not in qr or s3 not in qr:
            continue

        if not face_only:
            s4 = (x * x + y * y + z * z) % M
            if s4 not in qr:
                continue

        survivors.append((x, y, z))

    return survivors


# ============================================================================
# Algorithm 3: CRT Decomposition Analysis
# ============================================================================

def crt_decompose(M: int, factors: list[int]) -> dict:
    """
    Analyze how the sieve at modulus M relates to sieves at its factors
    via the Chinese Remainder Theorem.

    For M = p1 * p2 * ... * pk (pairwise coprime), the CRT gives
    ZMod M ≅ ZMod p1 × ... × ZMod pk.

    If the sieve conditions were independent across factors, the survivor
    count at M would be product(count(pi)) * M^3 / product(pi^3).
    Deviation from this indicates inter-prime interaction.

    Args:
        M: Composite modulus
        factors: Its pairwise coprime factors

    Returns:
        Dictionary with analysis results
    """
    assert reduce(lambda a, b: a * b, factors) == M
    assert all(gcd(a, b) == 1 for i, a in enumerate(factors)
               for b in factors[i+1:])

    factor_counts = {}
    for p in factors:
        survivors = cuboid_sieve(p)
        factor_counts[p] = len(survivors)

    # Predicted count if independent
    predicted = 1
    for p in factors:
        predicted *= factor_counts[p]
    # Normalize: predicted * M^3 / product(p^3)
    factor_cubes = reduce(lambda a, b: a * b, [p ** 3 for p in factors])
    predicted_normalized = predicted * M ** 3 // factor_cubes

    # Actual count
    actual = len(cuboid_sieve(M))

    return {
        "modulus": M,
        "factors": factors,
        "factor_counts": factor_counts,
        "predicted_independent": predicted_normalized,
        "actual": actual,
        "ratio": actual / max(predicted_normalized, 1),
        "interaction": "multiplicative" if actual == predicted_normalized
                       else ("sub-multiplicative" if actual < predicted_normalized
                             else "super-multiplicative"),
    }


# ============================================================================
# Algorithm 4: Density Estimator
# ============================================================================

def density_analysis(moduli: list[int]) -> list[dict]:
    """
    Compute sieve density for a sequence of moduli.

    The density is the fraction of residue triples that survive all
    quadratic residue conditions. Lower density means stronger
    obstruction to perfect cuboid existence.

    Args:
        moduli: List of moduli to analyze

    Returns:
        List of density records
    """
    results = []
    for M in moduli:
        survivors = len(cuboid_sieve(M))
        total = M ** 3
        results.append({
            "modulus": M,
            "survivors": survivors,
            "total": total,
            "density": survivors / total,
            "reduction_factor": total // max(survivors, 1),
        })
    return results


# ============================================================================
# Algorithm 5: Euler Brick Verifier
# ============================================================================

def verify_euler_brick(x: int, y: int, z: int) -> dict:
    """
    Verify whether (x, y, z) forms an Euler brick and/or perfect cuboid.

    An Euler brick has all face diagonals as integers.
    A perfect cuboid additionally has an integer space diagonal.

    Args:
        x, y, z: Edge lengths (positive integers)

    Returns:
        Verification dictionary with diagonal values and status
    """
    def is_perfect_square(n: int) -> tuple[bool, int]:
        s = isqrt(n)
        return s * s == n, s

    d1_sq = x * x + y * y
    d2_sq = x * x + z * z
    d3_sq = y * y + z * z
    space_sq = x * x + y * y + z * z

    d1_ok, d1 = is_perfect_square(d1_sq)
    d2_ok, d2 = is_perfect_square(d2_sq)
    d3_ok, d3 = is_perfect_square(d3_sq)
    sp_ok, sp = is_perfect_square(space_sq)

    return {
        "edges": (x, y, z),
        "face_diagonals": (d1 if d1_ok else None,
                           d2 if d2_ok else None,
                           d3 if d3_ok else None),
        "space_diagonal": sp if sp_ok else None,
        "is_euler_brick": d1_ok and d2_ok and d3_ok,
        "is_perfect_cuboid": d1_ok and d2_ok and d3_ok and sp_ok,
        "primitive": gcd(x, gcd(y, z)) == 1,
    }


# ============================================================================
# Algorithm 6: Survivor Classification
# ============================================================================

def classify_survivors(M: int) -> dict:
    """
    Classify surviving residue triples by their symmetry type.

    Survivors are grouped by:
    - Parity pattern (EEO, EOE, OEE, or other)
    - Whether they're related by permutation
    - Their CRT decomposition image

    Args:
        M: Modulus

    Returns:
        Classification dictionary
    """
    survivors = cuboid_sieve(M)

    # Group by parity
    parity_groups: dict[tuple[int, int, int], list] = {}
    for x, y, z in survivors:
        p = (x % 2, y % 2, z % 2)
        parity_groups.setdefault(p, []).append((x, y, z))

    # Count permutation orbits
    seen = set()
    orbits = []
    for trip in survivors:
        key = tuple(sorted(trip))
        if key not in seen:
            seen.add(key)
            orbits.append(key)

    return {
        "modulus": M,
        "total_survivors": len(survivors),
        "parity_distribution": {str(k): len(v) for k, v in parity_groups.items()},
        "permutation_orbits": len(orbits),
    }


# ============================================================================
# Main demonstration
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Perfect Cuboid Sieve — Algorithm Demonstrations")
    print("=" * 60)

    # Quadratic residues
    print("\n--- Quadratic Residues ---")
    for p in [3, 5, 7]:
        qr = sorted(quadratic_residues(p))
        print(f"  QR mod {p}: {qr} ({len(qr)}/{p})")

    # Density analysis
    print("\n--- Density Analysis ---")
    results = density_analysis([3, 5, 7, 15, 21, 35, 105])
    print(f"  {'Mod':>6} {'Survivors':>10} {'Total':>10} {'Density':>10} {'Factor':>8}")
    for r in results:
        print(f"  {r['modulus']:>6} {r['survivors']:>10,} {r['total']:>10,} "
              f"{r['density']:>10.4%} {r['reduction_factor']:>7}×")

    # CRT decomposition
    print("\n--- CRT Decomposition ---")
    crt = crt_decompose(105, [3, 5, 7])
    print(f"  Modulus: {crt['modulus']}")
    print(f"  Factor counts: {crt['factor_counts']}")
    print(f"  Predicted (if independent): {crt['predicted_independent']}")
    print(f"  Actual: {crt['actual']}")
    print(f"  Interaction: {crt['interaction']}")

    # Euler brick verification
    print("\n--- Euler Brick Verification ---")
    for edges in [(44, 117, 240), (240, 252, 275), (85, 132, 720)]:
        result = verify_euler_brick(*edges)
        status = "Perfect Cuboid" if result['is_perfect_cuboid'] else \
                 "Euler Brick" if result['is_euler_brick'] else "Neither"
        print(f"  {edges}: {status}, diags={result['face_diagonals']}")

    # Survivor classification
    print("\n--- Survivor Classification mod 7 ---")
    cls = classify_survivors(7)
    print(f"  Total survivors: {cls['total_survivors']}")
    print(f"  Parity distribution: {cls['parity_distribution']}")
    print(f"  Permutation orbits: {cls['permutation_orbits']}")
