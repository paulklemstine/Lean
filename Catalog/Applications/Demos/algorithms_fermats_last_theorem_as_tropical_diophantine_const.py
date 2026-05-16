#!/usr/bin/env python3
"""
Algorithms for Tropical Fermat Hypersurface Analysis

Implements:
1. Tropical zero set membership testing
2. Tropical wall classification
3. Primitive lattice point enumeration
4. Scale-orbit computation
5. Tropical combinatorial type classification
"""

from math import gcd
from typing import List, Tuple, Set, Optional
from dataclasses import dataclass
from enum import Enum, auto


class TropicalWall(Enum):
    """The three walls of the tropical hyperplane arrangement in ℤ³."""
    H_XY = auto()  # x = y ≤ z
    H_XZ = auto()  # x = z ≤ y
    H_YZ = auto()  # y = z ≤ x
    VERTEX = auto()  # x = y = z (intersection of all three)


@dataclass(frozen=True)
class TropicalPoint:
    """A point in ℤ³ with its tropical classification."""
    x: int
    y: int
    z: int
    walls: Tuple[TropicalWall, ...]

    @property
    def is_on_hypersurface(self) -> bool:
        return len(self.walls) > 0

    @property
    def is_vertex(self) -> bool:
        return TropicalWall.VERTEX in self.walls


def trop_zero_test(n: int, x: int, y: int, z: int) -> bool:
    """Test membership in TropZero(F_n).

    Algorithm: O(1) time, O(1) space.
    By Theorem A, equivalent to testing coordinate pairwise equality at minimum.

    Args:
        n: Positive integer exponent
        x, y, z: Integer coordinates

    Returns:
        True if (x,y,z) ∈ TropZero(F_n)
    """
    assert n >= 1, "Exponent must be positive"
    # By Theorem A, we can ignore n entirely
    m = min(x, y, z)
    count = (x == m) + (y == m) + (z == m)
    return count >= 2


def classify_tropical_point(x: int, y: int, z: int) -> TropicalPoint:
    """Classify a point by which walls of the tropical hyperplane it lies on.

    Algorithm: O(1) time, O(1) space.

    Args:
        x, y, z: Integer coordinates

    Returns:
        TropicalPoint with wall classification
    """
    walls = []
    if x == y == z:
        walls.append(TropicalWall.VERTEX)
    else:
        if x == y and x <= z:
            walls.append(TropicalWall.H_XY)
        if x == z and x <= y:
            walls.append(TropicalWall.H_XZ)
        if y == z and y <= x:
            walls.append(TropicalWall.H_YZ)
    return TropicalPoint(x, y, z, tuple(walls))


def enumerate_primitive_points_on_wall(
    wall: TropicalWall, L: int
) -> List[Tuple[int, int, int]]:
    """Enumerate all primitive lattice points on a given wall within [-L, L]³.

    Algorithm: O(L² log L) time (due to gcd computations), O(output) space.

    For wall H_xy: points (a, a, b) with a ≤ b, gcd(a, b) = 1.
    For wall H_xz: points (a, b, a) with a ≤ b, gcd(a, b) = 1.
    For wall H_yz: points (b, a, a) with a ≤ b, gcd(a, b) = 1.

    Args:
        wall: Which wall to enumerate
        L: Box bound

    Returns:
        List of primitive lattice points on the wall
    """
    points = []
    for a in range(0, L + 1):
        for b in range(a, L + 1):
            if gcd(a, b) == 1:
                if wall == TropicalWall.H_XY:
                    points.append((a, a, b))
                elif wall == TropicalWall.H_XZ:
                    points.append((a, b, a))
                elif wall == TropicalWall.H_YZ:
                    points.append((b, a, a))
    return points


def scale_orbit(x: int, y: int, z: int, max_k: int) -> List[Tuple[int, int, int]]:
    """Compute the scale orbit of a point up to scale factor max_k.

    Algorithm: O(max_k) time, O(max_k) space.

    By Theorem C1, all points in the orbit lie in TropZero(F_n) if the
    original point does.

    Args:
        x, y, z: Base point coordinates
        max_k: Maximum scale factor

    Returns:
        List of scaled points [(kx, ky, kz) for k = 1, ..., max_k]
    """
    return [(k * x, k * y, k * z) for k in range(1, max_k + 1)]


def count_primitive_in_box(L: int) -> dict:
    """Count primitive lattice points on TropZero in [0, L]³.

    Algorithm: O(L²) time for each wall, O(1) auxiliary space.

    Returns:
        Dictionary with counts per wall and total
    """
    counts = {"H_xy": 0, "H_xz": 0, "H_yz": 0, "vertex": 0, "total": 0}
    seen = set()

    for a in range(0, L + 1):
        for b in range(a, L + 1):
            if gcd(a, b) == 1:
                for label, point in [
                    ("H_xy", (a, a, b)),
                    ("H_xz", (a, b, a)),
                    ("H_yz", (b, a, a)),
                ]:
                    if point not in seen:
                        seen.add(point)
                        counts[label] += 1
                        counts["total"] += 1
                        if a == b:
                            counts["vertex"] += 1

    return counts


def tropical_fermat_value(n: int, x: int, y: int, z: int) -> int:
    """Evaluate the tropical Fermat polynomial F_n(x, y, z) = min(nx, ny, nz).

    Algorithm: O(1) time, O(1) space.
    """
    return min(n * x, n * y, n * z)


def find_balanced_decomposition(
    n: int, target: int, L: int
) -> List[Tuple[int, int, int]]:
    """Find all (x, y, z) in [0, L]³ with F_n(x,y,z) = target AND in TropZero.

    This finds points where the tropical polynomial evaluates to a given value
    and the minimum is attained at least twice.

    Algorithm: O(L²) time, O(output) space.
    """
    results = []
    for x in range(0, L + 1):
        for y in range(0, L + 1):
            for z in range(0, L + 1):
                val = tropical_fermat_value(n, x, y, z)
                if val == target and trop_zero_test(n, x, y, z):
                    results.append((x, y, z))
    return results


# ─── Pseudocode for key algorithms ───────────────────────────────────────

PSEUDOCODE_TROP_ZERO = """
Algorithm: TropicalZeroTest(n, x, y, z)
Input: positive integer n, integers x, y, z
Output: boolean

1. Compute m ← min(x, y, z)           // O(1), by Theorem A we ignore n
2. Count c ← #{i ∈ {x,y,z} : i = m}  // O(1)
3. Return c ≥ 2                        // O(1)

Time complexity: O(1)
Space complexity: O(1)
Correctness: By Theorem A (tropFermat_zero_iff), membership in TropZero(F_n)
depends only on the coordinate order type, not on n.
"""

PSEUDOCODE_PRIMITIVE_ENUM = """
Algorithm: EnumeratePrimitiveTropicalPoints(L)
Input: box bound L
Output: set of primitive lattice points on TropZero ∩ [0,L]³

1. S ← ∅
2. For a = 0 to L:
3.   For b = a to L:
4.     If gcd(a, b) = 1:
5.       S ← S ∪ {(a,a,b), (a,b,a), (b,a,a)}   // one point per wall
6. Return S

Time complexity: O(L² log L)  // dominated by gcd computations
Space complexity: O(|S|) = O(L²/ζ(2)) ≈ O(6L²/π²)
Correctness: By Theorem B, each (a,a,b) with a ≤ b is in TropZero.
Primitive pairs (a,b) with gcd(a,b) = 1 give primitive points.
"""

PSEUDOCODE_SCALE_ORBIT = """
Algorithm: ScaleOrbit(p, K)
Input: point p = (x,y,z) ∈ TropZero, max scale K
Output: set of K distinct points in TropZero

1. O ← ∅
2. For k = 1 to K:
3.   O ← O ∪ {(kx, ky, kz)}
4. Return O

Time complexity: O(K)
Space complexity: O(K)
Correctness: By Theorem C1, scaling preserves TropZero membership.
By Theorem C2, for k ≥ 2, the scaled point differs from p (if p ≠ 0).
"""


if __name__ == "__main__":
    # Example usage
    print("Tropical Zero Test:")
    for p in [(3, 3, 7), (1, 2, 3), (5, 5, 5), (2, 8, 2)]:
        print(f"  {p}: {trop_zero_test(1, *p)}")

    print("\nClassification:")
    for p in [(3, 3, 7), (5, 5, 5), (2, 8, 2)]:
        tp = classify_tropical_point(*p)
        print(f"  {p}: walls = {[w.name for w in tp.walls]}")

    print("\nPrimitive points on H_xy up to L=10:")
    pts = enumerate_primitive_points_on_wall(TropicalWall.H_XY, 10)
    print(f"  Count: {len(pts)}")
    print(f"  First 10: {pts[:10]}")

    print("\nScale orbit of (1, 1, 2):")
    orbit = scale_orbit(1, 1, 2, 5)
    for p in orbit:
        print(f"  {p}: in TropZero = {trop_zero_test(1, *p)}")

    print("\nCounting in box [0, 100]³:")
    counts = count_primitive_in_box(100)
    print(f"  {counts}")
