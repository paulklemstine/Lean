"""
Numerical / computational demonstration of the set-level quotient model of the
cubical circle (S^1) and torus (T^2).

This script mirrors the Lean development:

  * The cubical interval is modeled by floats in [0, 1].
  * The circle S^1 is the interval with endpoints 0 ~ 1 glued.
  * The torus T^2 is the square [0,1]^2 with opposite edges glued.
  * Each space carries a recursion principle (eliminator) that requires the
    "toll" equations enforced by the gluing.
  * We exhibit the equivalence T^2 ~= S^1 x S^1 via explicit mutually inverse
    maps `to_circles` and `of_circles`, and verify the round-trip identities
    numerically.

Everything is self-contained and uses only the standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Tuple, TypeVar

X = TypeVar("X")

EPS = 1e-12


# ----------------------------------------------------------------------------
# The cubical interval and its endpoints
# ----------------------------------------------------------------------------

def in_interval(t: float) -> bool:
    """Membership test for the unit interval I = [0, 1]."""
    return -EPS <= t <= 1.0 + EPS


I0: float = 0.0  # the 0 endpoint
I1: float = 1.0  # the 1 endpoint


def endpoints_ne() -> bool:
    """Proposition `endpoints_ne`: the two endpoints are distinct."""
    return abs(I0 - I1) > EPS


# ----------------------------------------------------------------------------
# The cubical circle  S^1 = I / (0 ~ 1)
# ----------------------------------------------------------------------------
#
# A point of S^1 is represented by a canonical interval representative in [0, 1),
# i.e. we normalize the endpoint 1 down to 0, since loop(1) = loop(0) = base.

@dataclass(frozen=True)
class Circle:
    """A point of the cubical circle, stored as a canonical representative."""
    rep: float  # canonical representative in [0, 1)


def loop(t: float) -> Circle:
    """The canonical interval map (loop) into the circle.

    Sends every interval point t to its class; the endpoint 1 is identified
    with 0 (the gluing 0 ~ 1), realizing loop_zero / loop_one / loop_endpoints.
    """
    assert in_interval(t)
    if abs(t - 1.0) <= EPS:
        return Circle(0.0)
    return Circle(t)


BASE: Circle = loop(0.0)  # the base point = common image of the two endpoints


def circle_rec(f: Callable[[float], X], h: bool) -> Callable[[Circle], X]:
    """Recursion principle `Circle.rec'`.

    Given an interval map f : I -> X whose endpoints agree (the toll
    h : f(0) == f(1)), induces a map S^1 -> X with computation rule
    rec(loop t) = f t  and  rec(base) = f 0.
    """
    if not h:
        raise ValueError("circle_rec: endpoint toll f(0) = f(1) not satisfied")

    def induced(c: Circle) -> X:
        return f(c.rep)

    return induced


# ----------------------------------------------------------------------------
# The cubical torus  T^2 = (I x I) / (opposite edges glued)
# ----------------------------------------------------------------------------

@dataclass(frozen=True)
class Torus:
    """A point of the cubical torus, stored as a canonical square representative."""
    x: float  # canonical first coordinate in [0, 1)
    y: float  # canonical second coordinate in [0, 1)


def torus_mk(p: Tuple[float, float]) -> Torus:
    """The canonical square map into the torus.

    Glues bottom~top  ((x,0)~(x,1))  and  left~right  ((0,y)~(1,y))  by
    normalizing each coordinate's endpoint 1 down to 0.
    """
    x, y = p
    assert in_interval(x) and in_interval(y)
    nx = 0.0 if abs(x - 1.0) <= EPS else x
    ny = 0.0 if abs(y - 1.0) <= EPS else y
    return Torus(nx, ny)


def torus_rec(
    f: Callable[[Tuple[float, float]], X],
    hh: bool,
    hv: bool,
) -> Callable[[Torus], X]:
    """Recursion principle `Torus.rec'`.

    Given a square map f together with the two edge tolls
    hh : f(x,0) == f(x,1)  and  hv : f(0,y) == f(1,y),
    induces a map T^2 -> X with computation rule rec(mk p) = f p.
    """
    if not (hh and hv):
        raise ValueError("torus_rec: edge tolls not satisfied")

    def induced(t: Torus) -> X:
        return f((t.x, t.y))

    return induced


# ----------------------------------------------------------------------------
# The equivalence  T^2 ~= S^1 x S^1
# ----------------------------------------------------------------------------

def to_circles(t: Torus) -> Tuple[Circle, Circle]:
    """`toCircles`: a torus point goes to its (longitude, meridian) pair."""
    return (loop(t.x), loop(t.y))


def of_circles(pair: Tuple[Circle, Circle]) -> Torus:
    """`ofCircles`: a pair of circle points reassembles a torus point."""
    c1, c2 = pair
    return torus_mk((c1.rep, c2.rep))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_circle_endpoints() -> None:
    print("=== Circle: endpoint gluing (loop_zero / loop_one / loop_endpoints) ===")
    print(f"  endpoints_ne (0 != 1 in I)?  {endpoints_ne()}")
    print(f"  loop(0) == base ?            {loop(0.0) == BASE}")
    print(f"  loop(1) == base ?            {loop(1.0) == BASE}")
    print(f"  loop(0) == loop(1) ?         {loop(0.0) == loop(1.0)}")
    print()


def demo_circle_rec() -> None:
    print("=== Circle recursion principle (rec_base / rec_loop) ===")
    # f(t) = cos(2 pi t) has f(0) = f(1) = 1, so it descends to the circle.
    import math
    f = lambda t: round(math.cos(2 * math.pi * t), 10)
    toll = abs(f(0.0) - f(1.0)) <= 1e-9
    g = circle_rec(f, toll)
    for t in (0.0, 0.25, 0.5, 0.75):
        print(f"  g(loop({t})) = f({t}) = {g(loop(t))}")
    print(f"  g(base) = f(0) = {g(BASE)}")
    print()


def demo_torus_edges() -> None:
    print("=== Torus: opposite-edge gluing (mk_horiz / mk_vert) ===")
    samples = [0.0, 0.3, 0.7]
    horiz = all(torus_mk((x, 0.0)) == torus_mk((x, 1.0)) for x in samples)
    vert = all(torus_mk((0.0, y)) == torus_mk((1.0, y)) for y in samples)
    print(f"  mk(x,0) == mk(x,1) for all sampled x ?  {horiz}")
    print(f"  mk(0,y) == mk(1,y) for all sampled y ?  {vert}")
    print()


def demo_equivalence() -> None:
    print("=== Equivalence  T^2 ~= S^1 x S^1  (left_inv / right_inv) ===")
    torus_pts = [torus_mk((x, y))
                 for x in (0.0, 0.2, 0.6)
                 for y in (0.0, 0.4, 0.9)]
    left_ok = all(of_circles(to_circles(t)) == t for t in torus_pts)
    print(f"  ofCircles(toCircles(t)) == t  for all sampled t ?  {left_ok}")

    circle_pairs = [(loop(x), loop(y))
                    for x in (0.0, 0.2, 0.6)
                    for y in (0.0, 0.4, 0.9)]
    right_ok = all(to_circles(of_circles(p)) == p for p in circle_pairs)
    print(f"  toCircles(ofCircles(p)) == p  for all sampled p ?  {right_ok}")
    print()


def main() -> None:
    demo_circle_endpoints()
    demo_circle_rec()
    demo_torus_edges()
    demo_equivalence()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
