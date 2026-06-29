"""
Arithmetic-Height-Induced Ultrametrics — numerical demonstrations.

This self-contained script illustrates, with exact rational arithmetic, the
results of the package:

  Face I  (quantitative, real-valued, on Q):
      d(x, y) = |x - y|_p = p ^ (-v_p(x - y))
      * nonnegativity, reflexivity, identity of indiscernibles
      * symmetry
      * the STRONG (ultrametric) triangle inequality d(x,z) <= max(d(x,y), d(y,z))
      * every triangle is isosceles

  Face II (qualitative, N-valued, multiplicative, on Z):
      v(n) = 0 if p | n else 1
      * v(0) = 0, v(-n) = v(n)
      * multiplicativity v(m*n) = v(m)*v(n)            (Euclid's lemma)
      * strong triangle v(m+n) <= max(v(m), v(n))
      * residue-field representation v(n) = 1  <=>  (n mod p) != 0

  The rigidity obstruction (why the two faces are different):
      on a field, a multiplicative N-valued norm N with N(1)=1 is identically 1
      on nonzero elements.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from typing import List, Tuple


# --------------------------------------------------------------------------
# p-adic valuation and norm (Face I)
# --------------------------------------------------------------------------

def padic_val_int(p: int, n: int) -> float:
    """p-adic valuation of an integer n; returns +inf for n == 0."""
    if n == 0:
        return float("inf")
    count = 0
    n = abs(n)
    while n % p == 0:
        n //= p
        count += 1
    return count


def padic_val_rat(p: int, x: Fraction) -> float:
    """p-adic valuation of a rational x = a/b; v_p(a) - v_p(b)."""
    if x == 0:
        return float("inf")
    return padic_val_int(p, x.numerator) - padic_val_int(p, x.denominator)


def padic_norm(p: int, x: Fraction) -> Fraction:
    """p-adic norm |x|_p = p^(-v_p(x)), with |0|_p = 0. Exact rational."""
    if x == 0:
        return Fraction(0)
    v = int(padic_val_rat(p, x))
    if v >= 0:
        return Fraction(1, p ** v)
    return Fraction(p ** (-v), 1)


def hdist(p: int, x: Fraction, y: Fraction) -> Fraction:
    """The arithmetic-height depth distance d(x, y) = |x - y|_p."""
    return padic_norm(p, x - y)


# --------------------------------------------------------------------------
# Divisibility indicator (Face II)
# --------------------------------------------------------------------------

def val_int(p: int, n: int) -> int:
    """Divisibility depth on Z: 0 if p | n else 1."""
    return 0 if n % p == 0 else 1


def residue_nonzero(p: int, n: int) -> bool:
    """Image of n in Z/pZ is nonzero (the residue-field representation)."""
    return (n % p) != 0


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_face1_metric(p: int, points: List[Fraction]) -> None:
    print(f"\n=== Face I: depth distance d(x,y) = |x-y|_{p} on Q ===")
    print("Sample points:", [str(x) for x in points])

    # identity of indiscernibles & reflexivity
    for x in points:
        assert hdist(p, x, x) == 0
    print("reflexivity d(x,x)=0 .......... OK")

    # symmetry
    for x, y in combinations(points, 2):
        assert hdist(p, x, y) == hdist(p, y, x)
    print("symmetry d(x,y)=d(y,x) ........ OK")

    # identity of indiscernibles
    for x, y in product(points, repeat=2):
        assert (hdist(p, x, y) == 0) == (x == y)
    print("d(x,y)=0 iff x=y .............. OK")

    # a few explicit distances
    print("\nexplicit distances (note: high divisibility => small distance):")
    for x, y in [(Fraction(1), Fraction(26)), (Fraction(1), Fraction(6)),
                 (Fraction(0), Fraction(p ** 3)), (Fraction(1), Fraction(2))]:
        print(f"  d({x}, {y}) = {hdist(p, x, y)}")


def demo_strong_triangle(p: int, points: List[Fraction]) -> None:
    print(f"\n=== Strong (ultrametric) triangle inequality, p={p} ===")
    worst = None
    for x, y, z in product(points, repeat=3):
        lhs = hdist(p, x, z)
        rhs = max(hdist(p, x, y), hdist(p, y, z))
        assert lhs <= rhs, (x, y, z, lhs, rhs)
        slack = rhs - lhs
        if worst is None or slack > worst[0]:
            worst = (slack, x, y, z)
    print("d(x,z) <= max(d(x,y), d(y,z)) for all triples ... OK")
    print(f"largest slack max - direct = {worst[0]} at "
          f"x={worst[1]}, y={worst[2]}, z={worst[3]}")


def demo_all_triangles_isosceles(p: int, points: List[Fraction]) -> None:
    print(f"\n=== Every triangle is isosceles (ultrametric phenomenon), p={p} ===")
    checked = 0
    for x, y, z in combinations(points, 3):
        a = hdist(p, x, y)
        b = hdist(p, y, z)
        c = hdist(p, x, z)
        sides = sorted([a, b, c])
        # the two largest sides must be equal
        assert sides[1] == sides[2], (x, y, z, sides)
        checked += 1
    print(f"two largest sides equal in all {checked} triangles ... OK")


def demo_face2_carrier(p: int, sample: List[int]) -> None:
    print(f"\n=== Face II: divisibility carrier v(n)=[p does not divide n] on Z, p={p} ===")

    assert val_int(p, 0) == 0
    print("v(0) = 0 ...................... OK")

    for n in sample:
        assert val_int(p, -n) == val_int(p, n)
    print("v(-n) = v(n) .................. OK")

    for m, n in product(sample, repeat=2):
        assert val_int(p, m * n) == val_int(p, m) * val_int(p, n)
    print("v(m*n) = v(m)*v(n) (Euclid) ... OK")

    for m, n in product(sample, repeat=2):
        assert val_int(p, m + n) <= max(val_int(p, m), val_int(p, n))
    print("v(m+n) <= max(v(m), v(n)) ..... OK")

    for n in sample:
        assert (val_int(p, n) == 1) == residue_nonzero(p, n)
    print("v(n)=1 iff (n mod p)!=0 ....... OK")

    print("\nsample values:")
    for n in [0, p, 2 * p, 1, p + 1, p * p, 7]:
        print(f"  v({n}) = {val_int(p, n)}   (n mod {p} = {n % p})")


def demo_rigidity(p: int) -> None:
    print(f"\n=== Rigidity: on a field, a multiplicative N-valued norm is trivial ===")
    print("Try to extend the integer indicator v to a multiplicative N-valued norm on Q.")
    print("For any nonzero x in a field, N(x)*N(1/x) = N(1) = 1 in N forces N(x)=1.")
    # Demonstrate the contradiction numerically: v_p(p)=1 but v_p(1/p)=-1; an
    # N-valued multiplicative norm cannot record both because their product is N(1)=1.
    for x in [Fraction(p), Fraction(1, p), Fraction(p, 1) ** 2, Fraction(p, 7)]:
        # the only N-solution of N(x)*N(1/x)=1 is N(x)=1
        forced = 1
        print(f"  forced N({x}) = {forced}  (cannot encode depth v_p = "
              f"{int(padic_val_rat(p, x))})")
    print("=> quantitative depth needs the REAL-valued |.|_p (Face I), "
          "or a non-field carrier such as Z (Face II).")


def main() -> None:
    p = 5
    pts = [Fraction(a, b) for a, b in
           [(0, 1), (1, 1), (2, 1), (6, 1), (26, 1), (1, 5), (3, 25), (1, 2)]]
    demo_face1_metric(p, pts)
    demo_strong_triangle(p, pts)
    demo_all_triangles_isosceles(p, pts)
    demo_face2_carrier(p, list(range(-12, 13)))
    demo_rigidity(p)
    print("\nAll demonstrations passed.")


if __name__ == "__main__":
    main()
