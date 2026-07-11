"""
Non-Desarguesian Worlds: The Dickson Nearfield of Order 9 and its Plane
=======================================================================

Self-contained numerical demonstration of the results:

  * GF(9) = GF(3)[alpha] with alpha^2 = -1 = 2, realized on Z/3 x Z/3.
  * The Frobenius automorphism sigma(a + b*alpha) = a - b*alpha (= x^3).
  * The Dickson product `dmul`, which twists the left factor by Frobenius
    exactly when the right factor is a non-square.
  * Verification, by exhaustive finite computation, that the Dickson product
    is a quasifield (two-sided unit, right distributivity, unique two-sided
    division, planar/Veblen axiom) and a NEARFIELD (associative), yet is
    NEITHER commutative NOR left-distributive -- hence not a division ring.
  * Construction of the coordinatized affine plane of order 9 (81 points,
    90 lines) and verification of its incidence axioms.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Optional, Tuple

# An element of GF(9) is a pair (a, b) meaning a + b*alpha, with a, b in Z/3.
Elem = Tuple[int, int]

ELEMENTS: List[Elem] = [(a, b) for a in range(3) for b in range(3)]
ZERO: Elem = (0, 0)
ONE: Elem = (1, 0)
ALPHA: Elem = (0, 1)


# ---------------------------------------------------------------------------
# The field GF(9)
# ---------------------------------------------------------------------------
def add(x: Elem, y: Elem) -> Elem:
    """Additive group of GF(9): componentwise addition mod 3."""
    return ((x[0] + y[0]) % 3, (x[1] + y[1]) % 3)


def neg(x: Elem) -> Elem:
    """Additive inverse mod 3."""
    return ((-x[0]) % 3, (-x[1]) % 3)


def sub(x: Elem, y: Elem) -> Elem:
    return add(x, neg(y))


def gf9_mul(x: Elem, y: Elem) -> Elem:
    """Field multiplication: (a+b.alpha)(c+d.alpha) = (ac+2bd) + (ad+bc).alpha."""
    a, b = x
    c, d = y
    return ((a * c + 2 * b * d) % 3, (a * d + b * c) % 3)


def frobenius(x: Elem) -> Elem:
    """Frobenius sigma(a + b*alpha) = a - b*alpha = a + 2b*alpha  (= x^3)."""
    a, b = x
    return (a, (2 * b) % 3)


# ---------------------------------------------------------------------------
# Squares / non-squares and the Dickson product
# ---------------------------------------------------------------------------
def is_nonzero_square(b: Elem) -> bool:
    """True iff b = c*c for some nonzero c in GF(9)."""
    return any(c != ZERO and gf9_mul(c, c) == b for c in ELEMENTS)


def dmul(a: Elem, b: Elem) -> Elem:
    """Dickson nearfield product.

    Multiply as in the field when the right factor `b` is zero or a nonzero
    square; otherwise pre-apply Frobenius to the left factor `a`.
    """
    if b == ZERO or is_nonzero_square(b):
        return gf9_mul(a, b)
    return gf9_mul(frobenius(a), b)


def fmt(x: Elem) -> str:
    """Pretty-print a + b*alpha."""
    a, b = x
    if b == 0:
        return str(a)
    if a == 0:
        return ("" if b == 1 else str(b)) + "a"
    return f"{a}+{'' if b == 1 else b}a"


# ---------------------------------------------------------------------------
# Verification of the quasifield / nearfield axioms
# ---------------------------------------------------------------------------
def check_unit() -> bool:
    return all(dmul(x, ONE) == x and dmul(ONE, x) == x for x in ELEMENTS)


def check_zero() -> bool:
    return all(dmul(x, ZERO) == ZERO and dmul(ZERO, x) == ZERO for x in ELEMENTS)


def check_right_distrib() -> bool:
    return all(
        dmul(add(a, b), c) == add(dmul(a, c), dmul(b, c))
        for a in ELEMENTS
        for b in ELEMENTS
        for c in ELEMENTS
    )


def check_unique_left_division() -> bool:
    """For a != 0, x |-> a*x is a bijection."""
    for a in ELEMENTS:
        if a == ZERO:
            continue
        images = [dmul(a, x) for x in ELEMENTS]
        if sorted(set(images)) != sorted(ELEMENTS):
            return False
    return True


def check_unique_right_division() -> bool:
    """For a != 0, x |-> x*a is a bijection."""
    for a in ELEMENTS:
        if a == ZERO:
            continue
        images = [dmul(x, a) for x in ELEMENTS]
        if sorted(set(images)) != sorted(ELEMENTS):
            return False
    return True


def check_planar() -> bool:
    """For a != b, x |-> x*a - x*b is a bijection (Veblen axiom)."""
    for a in ELEMENTS:
        for b in ELEMENTS:
            if a == b:
                continue
            images = [sub(dmul(x, a), dmul(x, b)) for x in ELEMENTS]
            if sorted(set(images)) != sorted(ELEMENTS):
                return False
    return True


def check_associative() -> bool:
    return all(
        dmul(dmul(a, b), c) == dmul(a, dmul(b, c))
        for a in ELEMENTS
        for b in ELEMENTS
        for c in ELEMENTS
    )


def left_distrib_failures() -> List[Tuple[Elem, Elem, Elem]]:
    return [
        (a, b, c)
        for a in ELEMENTS
        for b in ELEMENTS
        for c in ELEMENTS
        if dmul(a, add(b, c)) != add(dmul(a, b), dmul(a, c))
    ]


def commutativity_failures() -> List[Tuple[Elem, Elem]]:
    return [(a, b) for a in ELEMENTS for b in ELEMENTS if dmul(a, b) != dmul(b, a)]


# ---------------------------------------------------------------------------
# The coordinatized affine plane of order 9
# ---------------------------------------------------------------------------
Point = Tuple[Elem, Elem]
# A line is ("ord", m, b) meaning y = x*m + b, or ("ver", c) meaning x = c.
Line = Tuple

POINTS: List[Point] = [(x, y) for x in ELEMENTS for y in ELEMENTS]


def all_lines() -> List[Line]:
    lines: List[Line] = [("ord", m, b) for m in ELEMENTS for b in ELEMENTS]
    lines += [("ver", c) for c in ELEMENTS]
    return lines


def on_line(p: Point, L: Line) -> bool:
    x, y = p
    if L[0] == "ord":
        _, m, b = L
        return y == add(dmul(x, m), b)
    _, c = L
    return x == c


def line_through(p: Point, q: Point) -> Optional[Line]:
    """The unique line through two distinct points, found by search."""
    for L in all_lines():
        if on_line(p, L) and on_line(q, L):
            return L
    return None


def check_two_points_unique_line() -> bool:
    lines = all_lines()
    for i, p in enumerate(POINTS):
        for q in POINTS[i + 1:]:
            common = [L for L in lines if on_line(p, L) and on_line(q, L)]
            if len(common) != 1:
                return False
    return True


def check_playfair() -> bool:
    """Through any point there is a unique parallel to any given line."""
    def parallel(L1: Line, L2: Line) -> bool:
        if L1[0] == "ord" and L2[0] == "ord":
            return L1[1] == L2[1]  # same slope
        if L1[0] == "ver" and L2[0] == "ver":
            return True
        return False

    lines = all_lines()
    for L in lines:
        for p in POINTS:
            through = [M for M in lines if on_line(p, M) and parallel(L, M)]
            if len(through) != 1:
                return False
    return True


# ---------------------------------------------------------------------------
# Main driver
# ---------------------------------------------------------------------------
def main() -> None:
    line = "=" * 70
    print(line)
    print("  THE DICKSON NEARFIELD OF ORDER 9 AND ITS NON-DESARGUESIAN PLANE")
    print(line)

    squares = [b for b in ELEMENTS if b != ZERO and is_nonzero_square(b)]
    nonsquares = [b for b in ELEMENTS if b != ZERO and not is_nonzero_square(b)]
    print("\nNonzero squares of GF(9):    ", ", ".join(fmt(s) for s in squares))
    print("Non-squares of GF(9):        ", ", ".join(fmt(s) for s in nonsquares))

    print("\n--- Quasifield / nearfield axioms (exhaustive checks) ---")
    checks = [
        ("two-sided unit                 ", check_unit()),
        ("absorbing zero                 ", check_zero()),
        ("right distributivity           ", check_right_distrib()),
        ("unique left division           ", check_unique_left_division()),
        ("unique right division          ", check_unique_right_division()),
        ("planar (Veblen) axiom          ", check_planar()),
        ("ASSOCIATIVITY (=> nearfield)   ", check_associative()),
    ]
    for name, ok in checks:
        print(f"  [{'PASS' if ok else 'FAIL'}] {name}")

    print("\n--- The obstructions to being a division ring ---")
    ld = left_distrib_failures()
    nc = commutativity_failures()
    print(f"  left distributivity holds : {len(ld) == 0}  "
          f"({len(ld)} failing triples)")
    a, b, c = ld[0]
    lhs = dmul(a, add(b, c))
    rhs = add(dmul(a, b), dmul(a, c))
    print(f"    witness: a={fmt(a)}, b={fmt(b)}, c={fmt(c)}")
    print(f"      a*(b+c)      = {fmt(lhs)}")
    print(f"      a*b + a*c    = {fmt(rhs)}   -> differ, so NOT left-distributive")
    print(f"  commutativity holds       : {len(nc) == 0}  "
          f"({len(nc)} failing pairs)")
    a2, b2 = nc[0]
    print(f"    witness: ({fmt(a2)})*({fmt(b2)}) = {fmt(dmul(a2, b2))}  vs  "
          f"({fmt(b2)})*({fmt(a2)}) = {fmt(dmul(b2, a2))}")

    print("\n--- The coordinatized affine plane of order 9 ---")
    print(f"  number of points : {len(POINTS)}   (expected 81 = 9^2)")
    print(f"  number of lines  : {len(all_lines())}   (expected 90 = 9^2 + 9)")
    print(f"  [{'PASS' if check_two_points_unique_line() else 'FAIL'}] "
          "any two distinct points lie on a unique line")
    print(f"  [{'PASS' if check_playfair() else 'FAIL'}] "
          "Playfair's parallel axiom")

    # points-per-line and lines-per-point
    L0 = ("ord", ALPHA, ONE)
    pts_on_L0 = [p for p in POINTS if on_line(p, L0)]
    lines_through_origin = [L for L in all_lines() if on_line((ZERO, ZERO), L)]
    print(f"  points on a sample line   : {len(pts_on_L0)}   (expected 9)")
    print(f"  lines through the origin   : {len(lines_through_origin)}   "
          "(expected 10)")

    print("\n" + line)
    print("  CONCLUSION: the Dickson product is an associative, right-")
    print("  distributive quasifield with two-sided division -- a nearfield --")
    print("  but it is NOT left-distributive and NOT commutative, hence NOT a")
    print("  division ring. Its affine plane of order 9 (81 points, 90 lines)")
    print("  is therefore NON-DESARGUESIAN, the smallest such plane.")
    print(line)


if __name__ == "__main__":
    main()
