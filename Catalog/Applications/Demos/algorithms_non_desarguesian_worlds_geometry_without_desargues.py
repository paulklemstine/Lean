#!/usr/bin/env python3
"""
Algorithms for Non-Desarguesian Plane Construction and Analysis

Type-hinted implementations of the core algebraic algorithms:
1. Hall quasifield arithmetic
2. Nucleus computation
3. Coordinatized projective plane construction
4. Collineation group order computation
"""

from typing import Tuple, List, Set, Dict, Optional
from dataclasses import dataclass
from itertools import product


# Type aliases
GF = Tuple[int, int]  # Element of GF(q²) represented as pair over GF(q)


@dataclass
class QuasifieldConfig:
    """Configuration for a quasifield over GF(q) × GF(q)."""
    q: int  # Base field order (must be prime)
    nonsquare_coeff: int  # Coefficient making x² + nonsquare_coeff irreducible


def mod(x: int, q: int) -> int:
    """Reduce mod q to [0, q-1]."""
    return x % q


def gf_add(x: GF, y: GF, q: int) -> GF:
    """Componentwise addition mod q."""
    return (mod(x[0] + y[0], q), mod(x[1] + y[1], q))


def gf_neg(x: GF, q: int) -> GF:
    """Negation mod q."""
    return (mod(-x[0], q), mod(-x[1], q))


def gf_sub(x: GF, y: GF, q: int) -> GF:
    """Subtraction mod q."""
    return gf_add(x, gf_neg(y, q), q)


def field_mul(x: GF, y: GF, q: int, alpha_sq: int) -> GF:
    """Standard field multiplication in GF(q²) = GF(q)[α]/(α² - alpha_sq).
    (a + bα)(c + dα) = (ac + bd·alpha_sq) + (ad + bc)α"""
    return (
        mod(x[0] * y[0] + x[1] * y[1] * alpha_sq, q),
        mod(x[0] * y[1] + x[1] * y[0], q),
    )


def frobenius(x: GF, q: int) -> GF:
    """Frobenius automorphism: σ(a, b) = (a, (q-1)·b) = (a, -b)."""
    return (x[0], mod((q - 1) * x[1], q))


def hall_mul(x: GF, y: GF, q: int, alpha_sq: int) -> GF:
    """Hall multiplication.
    x ○ y = x · y if y ∈ GF(q), σ(x) · y otherwise."""
    if y[1] == 0:
        return (mod(x[0] * y[0], q), mod(x[1] * y[0], q))
    else:
        sx = frobenius(x, q)
        return field_mul(sx, y, q, alpha_sq)


def all_elements(q: int) -> List[GF]:
    """All elements of GF(q) × GF(q)."""
    return [(a, b) for a in range(q) for b in range(q)]


def compute_left_nucleus(q: int, alpha_sq: int) -> List[GF]:
    """Compute the left nucleus of the Hall quasifield.

    Algorithm: For each element a, check if a ○ (b ○ c) = (a ○ b) ○ c
    for ALL b, c. If so, a is in the left nucleus.

    Time complexity: O(q^6) — check q² elements against q⁴ pairs.
    """
    elements = all_elements(q)
    nucleus: List[GF] = []

    for a in elements:
        in_nuc = True
        for b in elements:
            if not in_nuc:
                break
            for c in elements:
                lhs = hall_mul(a, hall_mul(b, c, q, alpha_sq), q, alpha_sq)
                rhs = hall_mul(hall_mul(a, b, q, alpha_sq), c, q, alpha_sq)
                if lhs != rhs:
                    in_nuc = False
                    break
        if in_nuc:
            nucleus.append(a)

    return nucleus


def compute_middle_nucleus(q: int, alpha_sq: int) -> List[GF]:
    """Compute the middle nucleus."""
    elements = all_elements(q)
    nucleus: List[GF] = []

    for b in elements:
        in_nuc = True
        for a in elements:
            if not in_nuc:
                break
            for c in elements:
                lhs = hall_mul(a, hall_mul(b, c, q, alpha_sq), q, alpha_sq)
                rhs = hall_mul(hall_mul(a, b, q, alpha_sq), c, q, alpha_sq)
                if lhs != rhs:
                    in_nuc = False
                    break
        if in_nuc:
            nucleus.append(b)

    return nucleus


def compute_right_nucleus(q: int, alpha_sq: int) -> List[GF]:
    """Compute the right nucleus."""
    elements = all_elements(q)
    nucleus: List[GF] = []

    for c in elements:
        in_nuc = True
        for a in elements:
            if not in_nuc:
                break
            for b in elements:
                lhs = hall_mul(a, hall_mul(b, c, q, alpha_sq), q, alpha_sq)
                rhs = hall_mul(hall_mul(a, b, q, alpha_sq), c, q, alpha_sq)
                if lhs != rhs:
                    in_nuc = False
                    break
        if in_nuc:
            nucleus.append(c)

    return nucleus


def compute_full_nucleus(q: int, alpha_sq: int) -> List[GF]:
    """Compute the full nucleus (intersection of all three)."""
    left = set(compute_left_nucleus(q, alpha_sq))
    mid = set(compute_middle_nucleus(q, alpha_sq))
    right = set(compute_right_nucleus(q, alpha_sq))
    return sorted(left & mid & right)


def is_right_distributive(q: int, alpha_sq: int) -> bool:
    """Check if Hall multiplication is right-distributive.

    Verifies: (a + b) ○ c = a ○ c + b ○ c for all a, b, c.
    """
    elements = all_elements(q)
    for a in elements:
        for b in elements:
            for c in elements:
                lhs = hall_mul(gf_add(a, b, q), c, q, alpha_sq)
                rhs = gf_add(
                    hall_mul(a, c, q, alpha_sq),
                    hall_mul(b, c, q, alpha_sq),
                    q,
                )
                if lhs != rhs:
                    return False
    return True


def is_left_distributive(q: int, alpha_sq: int) -> bool:
    """Check if Hall multiplication is left-distributive.

    Verifies: a ○ (b + c) = a ○ b + a ○ c for all a, b, c.
    """
    elements = all_elements(q)
    for a in elements:
        for b in elements:
            for c in elements:
                lhs = hall_mul(a, gf_add(b, c, q), q, alpha_sq)
                rhs = gf_add(
                    hall_mul(a, b, q, alpha_sq),
                    hall_mul(a, c, q, alpha_sq),
                    q,
                )
                if lhs != rhs:
                    return False
    return True


@dataclass
class ProjectivePlaneStats:
    """Statistics of a coordinatized projective plane."""
    order: int
    num_points: int
    num_lines: int
    is_right_distrib: bool
    is_left_distrib: bool
    is_associative: bool
    left_nucleus_size: int
    defect: int


def analyze_hall_plane(q: int, alpha_sq: int) -> ProjectivePlaneStats:
    """Full analysis of the Hall plane of order q².

    Pseudocode:
    1. Compute order = q²
    2. Count points and lines: n² + n + 1
    3. Check distributivity
    4. Find non-associativity witness
    5. Compute nucleus
    6. Calculate defect
    """
    n = q * q  # order of the plane
    num_pts = n * n + n + 1
    elements = all_elements(q)

    # Check associativity
    assoc = True
    for a in elements:
        if not assoc:
            break
        for b in elements:
            if not assoc:
                break
            for c in elements:
                if hall_mul(hall_mul(a, b, q, alpha_sq), c, q, alpha_sq) != \
                   hall_mul(a, hall_mul(b, c, q, alpha_sq), q, alpha_sq):
                    assoc = False
                    break

    left_nuc = compute_left_nucleus(q, alpha_sq)

    return ProjectivePlaneStats(
        order=n,
        num_points=num_pts,
        num_lines=num_pts,
        is_right_distrib=is_right_distributive(q, alpha_sq),
        is_left_distrib=is_left_distributive(q, alpha_sq),
        is_associative=assoc,
        left_nucleus_size=len(left_nuc),
        defect=n - len(left_nuc),
    )


def pgl_order(q: int) -> int:
    """Order of PGL(3, q)."""
    return q**3 * (q**3 - 1) * (q**2 - 1)


def hall_collineation_order(q: int) -> int:
    """Order of the collineation group of the Hall plane of order q²."""
    return q**2 * (q**2 - 1) * q * (q - 1)


def find_nonsquare(q: int) -> int:
    """Find a non-square element in GF(q) for constructing GF(q²).

    For q = 3: need α² + 1 irreducible, i.e., -1 is not a square.
    -1 ≡ 2 (mod 3), and 0² = 0, 1² = 1, 2² = 1, so 2 is not a square. Use alpha_sq = 2.
    """
    squares = {(x * x) % q for x in range(q)}
    for a in range(1, q):
        if a not in squares:
            return a
    raise ValueError(f"No non-square found in GF({q}) — q might not be prime")


if __name__ == "__main__":
    # Analyze the Hall plane of order 9
    q = 3
    alpha_sq = find_nonsquare(q)
    print(f"Using alpha² = {alpha_sq} (non-square in GF({q}))")

    stats = analyze_hall_plane(q, alpha_sq)
    print(f"\nHall Plane Analysis (q = {q}):")
    print(f"  Order: {stats.order}")
    print(f"  Points: {stats.num_points}")
    print(f"  Lines: {stats.num_lines}")
    print(f"  Right-distributive: {stats.is_right_distrib}")
    print(f"  Left-distributive: {stats.is_left_distrib}")
    print(f"  Associative: {stats.is_associative}")
    print(f"  Left nucleus size: {stats.left_nucleus_size}")
    print(f"  Defect: {stats.defect}")

    # Symmetry comparison
    print(f"\n  PGL(3, {stats.order}) order: {pgl_order(stats.order):,}")
    print(f"  Hall collineation order: {hall_collineation_order(q):,}")
    print(f"  Symmetry ratio: {pgl_order(stats.order) / hall_collineation_order(q):,.1f}")
