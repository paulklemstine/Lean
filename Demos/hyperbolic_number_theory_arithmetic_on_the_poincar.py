"""
Numerical demonstrations for:

    Integer Structures on the Hyperbolic Disk
    A Rigorous Foundation for Arithmetic on Curved Space

Each demo corresponds to one of the proved results:

  1. The Cayley transform maps the upper half-plane bijectively onto the
     open unit disk, with an explicit two-sided inverse.
  2. The matrices T = [[1,2],[0,1]] and S = [[1,0],[2,1]] generate (and
     belong to) the principal congruence subgroup Gamma(2) of SL(2,Z).
  3. The Gamma(2)-orbit relation on Z^2 is an equivalence relation.
  4. Every Euclidean ball contains only finitely many lattice points.
  5. The hyperbolic midpoint on the imaginary axis is the geometric mean:
     equidistant, commutative, idempotent, but NOT associative.
  6. The cross-ratio is invariant under Moebius transformations.

The file is self-contained: run `python demo.py`.
"""

from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Iterable


# ---------------------------------------------------------------------------
# 1. The Cayley transform  C(z) = (z - i)/(z + i)  and its inverse
# ---------------------------------------------------------------------------

def cayley(z: complex) -> complex:
    """Map a point of the upper half-plane into the open unit disk."""
    return (z - 1j) / (z + 1j)


def inv_cayley(w: complex) -> complex:
    """Map a point of the unit disk back to the upper half-plane."""
    return 1j * (1 + w) / (1 - w)


def demo_cayley() -> None:
    print("=" * 70)
    print("1. Cayley transform: upper half-plane  <->  unit disk")
    print("=" * 70)
    samples = [1j, 2j, 1 + 1j, -3 + 0.5j, 10 + 4j]
    for z in samples:
        w = cayley(z)
        back = inv_cayley(w)
        print(f"  z = {z!s:>12}  ->  C(z) = {w:.4f}   |C(z)| = {abs(w):.4f}")
        assert abs(w) < 1 - 1e-12, "image must lie strictly inside the disk"
        assert abs(back - z) < 1e-9, "inverse must recover z"
    print("  All images satisfy |C(z)| < 1 and C^{-1}(C(z)) = z.  OK\n")


# ---------------------------------------------------------------------------
# 2. Generators of Gamma(2)
# ---------------------------------------------------------------------------

Mat = tuple[int, int, int, int]  # (a, b, c, d) for [[a, b], [c, d]]

T: Mat = (1, 2, 0, 1)
S: Mat = (1, 0, 2, 1)


def det(m: Mat) -> int:
    a, b, c, d = m
    return a * d - b * c


def in_gamma2(m: Mat) -> bool:
    """Test membership in Gamma(2): det 1 and congruent to I mod 2."""
    a, b, c, d = m
    return det(m) == 1 and (a % 2, b % 2, c % 2, d % 2) == (1, 0, 0, 1)


def mat_mul(p: Mat, q: Mat) -> Mat:
    a, b, c, d = p
    e, f, g, h = q
    return (a * e + b * g, a * f + b * h, c * e + d * g, c * f + d * h)


def mat_inv(m: Mat) -> Mat:
    """Inverse of a determinant-1 integer matrix."""
    a, b, c, d = m
    return (d, -b, -c, a)


def demo_generators() -> None:
    print("=" * 70)
    print("2. Generators T, S of the congruence subgroup Gamma(2)")
    print("=" * 70)
    for name, m in (("T", T), ("S", S)):
        print(f"  {name} = {m}   det = {det(m)}   in Gamma(2)? {in_gamma2(m)}")
        assert in_gamma2(m)
    print("  Both generators lie in Gamma(2).  OK\n")


# ---------------------------------------------------------------------------
# 3. The Gamma(2)-orbit relation on Z^2 is an equivalence relation
# ---------------------------------------------------------------------------

Vec = tuple[int, int]


def act(m: Mat, v: Vec) -> Vec:
    a, b, c, d = m
    x, y = v
    return (a * x + b * y, c * x + d * y)


def demo_orbit_relation() -> None:
    print("=" * 70)
    print("3. Gamma(2)-orbit relation on Z^2 (equivalence relation)")
    print("=" * 70)
    v: Vec = (1, 0)
    # reflexivity via identity
    I: Mat = (1, 0, 0, 1)
    assert act(I, v) == v
    # symmetry: if g.v = w then g^{-1}.w = v
    g = mat_mul(T, S)
    assert in_gamma2(g)
    w = act(g, v)
    assert act(mat_inv(g), w) == v
    # transitivity: g2.(g1.v) = (g2 g1).v
    g1, g2 = T, S
    assert act(g2, act(g1, v)) == act(mat_mul(g2, g1), v)
    print(f"  v = {v}")
    print(f"  reflexive:  I.v = {act(I, v)}")
    print(f"  symmetric:  g.v = {w},  g^-1.(g.v) = {act(mat_inv(g), w)}")
    print(f"  transitive: (S T).v = {act(mat_mul(S, T), v)}"
          f" = S.(T.v) = {act(S, act(T, v))}")
    print("  Reflexive, symmetric, transitive.  OK\n")


# ---------------------------------------------------------------------------
# 4. Lattice discreteness: finitely many lattice points in a ball
# ---------------------------------------------------------------------------

def lattice_points_in_ball(center: tuple[float, float],
                           radius: float) -> list[Vec]:
    c1, c2 = center
    r = abs(radius)
    xs = range(math.ceil(c1 - r), math.floor(c1 + r) + 1)
    ys = range(math.ceil(c2 - r), math.floor(c2 + r) + 1)
    return [(m, n) for m, n in product(xs, ys)
            if (m - c1) ** 2 + (n - c2) ** 2 < radius ** 2]


def demo_discreteness() -> None:
    print("=" * 70)
    print("4. Discreteness: finitely many lattice points in any ball")
    print("=" * 70)
    for center, radius in (((0.0, 0.0), 1.5), ((0.3, -0.7), 3.0), ((0.0, 0.0), 5.0)):
        pts = lattice_points_in_ball(center, radius)
        print(f"  center {center}, radius {radius}: {len(pts)} lattice points")
    print("  Every count is finite, as guaranteed.  OK\n")


# ---------------------------------------------------------------------------
# 5. The hyperbolic midpoint on the imaginary axis (geometric mean)
# ---------------------------------------------------------------------------

def h_dist(a: float, b: float) -> float:
    """Hyperbolic distance between i*a and i*b."""
    return abs(math.log(a / b))


def h_mid(s: float, t: float) -> float:
    """Hyperbolic midpoint on the imaginary axis: the geometric mean."""
    return math.sqrt(s * t)


def demo_midpoint() -> None:
    print("=" * 70)
    print("5. Hyperbolic midpoint = geometric mean")
    print("=" * 70)
    s, t = 1.0, 16.0
    m = h_mid(s, t)
    print(f"  s = {s}, t = {t}, midpoint sqrt(s t) = {m}")
    print(f"  d(s, m) = {h_dist(s, m):.6f},  d(m, t) = {h_dist(m, t):.6f}"
          "   (equidistant)")
    assert abs(h_dist(s, m) - h_dist(m, t)) < 1e-12
    print(f"  commutative: m(s,t) = {h_mid(s, t)}, m(t,s) = {h_mid(t, s)}")
    print(f"  idempotent:  m(7,7) = {h_mid(7.0, 7.0)}")
    # non-associativity witness s=t=1, u=16
    left = h_mid(h_mid(1.0, 1.0), 16.0)
    right = h_mid(1.0, h_mid(1.0, 16.0))
    print(f"  NOT associative: m(m(1,1),16) = {left}, m(1,m(1,16)) = {right}")
    assert left != right
    print("  Equidistant, commutative, idempotent, non-associative.  OK\n")


# ---------------------------------------------------------------------------
# 6. Cross-ratio invariance under Moebius transformations
# ---------------------------------------------------------------------------

def cross_ratio(z1: complex, z2: complex, z3: complex, z4: complex) -> complex:
    return ((z1 - z3) * (z2 - z4)) / ((z1 - z4) * (z2 - z3))


def mobius(a: complex, b: complex, c: complex, d: complex, z: complex) -> complex:
    return (a * z + b) / (c * z + d)


def demo_cross_ratio() -> None:
    print("=" * 70)
    print("6. Cross-ratio invariance under Moebius transformations")
    print("=" * 70)
    pts = (0 + 0j, 1 + 0j, 2 + 1j, -1 + 3j)
    a, b, c, d = (2 + 1j, -1 + 0j, 1 + 0j, 3 - 1j)  # det = ad - bc != 0
    assert abs(a * d - b * c) > 1e-9
    orig = cross_ratio(*pts)
    moved = cross_ratio(*(mobius(a, b, c, d, z) for z in pts))
    print(f"  cross-ratio (original) = {orig:.6f}")
    print(f"  cross-ratio (Moebius)  = {moved:.6f}")
    assert abs(orig - moved) < 1e-9
    print("  Cross-ratio is preserved.  OK\n")


def main() -> None:
    demo_cayley()
    demo_generators()
    demo_orbit_relation()
    demo_discreteness()
    demo_midpoint()
    demo_cross_ratio()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
