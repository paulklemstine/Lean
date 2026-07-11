"""
The Topology of Impossible Objects: Escher Stairs and Klein Bottles.

Numerical demonstrations of the homological theory of impossible figures.

A cyclic figure on ``n`` overlapping patches is a list ``t = [t_0, ..., t_{n-1}]``
of local increments valued in an abelian group ``A``.  Its *holonomy* is the total
increment accumulated once around the loop, ``hol(t) = sum(t_i)``.  The central
theorems demonstrated here are:

  * Realizability criterion: a figure is realizable (built from a global height
    assignment ``h`` via the coboundary ``(delta h)_i = h_{i+1} - h_i``) iff its
    holonomy vanishes.
  * Discrete Poincare lemma: when holonomy is zero, a witnessing gauge is the
    running partial sum of increments.
  * Holonomy is a complete invariant: two figures are cohomologous iff they have
    equal holonomy, whence H^1 of a cyclic figure is isomorphic to the
    coefficient group A.

We work over the integers Z, the reals R, and the two-element group Z/2 (the
orientation coefficients responsible for Moebius bands and Klein bottles).
"""

from __future__ import annotations

from typing import Callable, List, Optional, TypeVar

A = TypeVar("A")


# --------------------------------------------------------------------------- #
#  Core operations of the figure complex  C^0 --delta--> C^1 --hol--> A        #
# --------------------------------------------------------------------------- #
def holonomy(t: List[int], modulus: Optional[int] = None) -> int:
    """Total increment once around the cycle: hol(t) = sum(t_i).

    If ``modulus`` is given, the coefficient group is Z/modulus (e.g. modulus=2
    for orientation coefficients).
    """
    s = sum(t)
    return s % modulus if modulus is not None else s


def coboundary(h: List[int], modulus: Optional[int] = None) -> List[int]:
    """The figure forced by a gauge h: (delta h)_i = h_{i+1} - h_i (indices mod n)."""
    n = len(h)
    out = [h[(i + 1) % n] - h[i] for i in range(n)]
    return [x % modulus for x in out] if modulus is not None else out


def gauge_from_partial_sums(t: List[int], modulus: Optional[int] = None) -> List[int]:
    """Reconstruct a gauge h with delta h = t via partial sums (discrete Poincare).

    Valid precisely when holonomy(t) == 0.  h_0 = 0, h_i = t_0 + ... + t_{i-1}.
    """
    h = [0]
    for k in range(len(t) - 1):
        h.append(h[-1] + t[k])
    return [x % modulus for x in h] if modulus is not None else h


def is_realizable(t: List[int], modulus: Optional[int] = None) -> bool:
    """A figure is realizable iff its holonomy vanishes (Realizability Theorem)."""
    return holonomy(t, modulus) == 0


def cohomologous(t: List[int], s: List[int], modulus: Optional[int] = None) -> bool:
    """Two figures are cohomologous iff they have equal holonomy (complete invariant)."""
    return holonomy(t, modulus) == holonomy(s, modulus)


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_escher_staircase() -> None:
    """Escher's staircase: every flight rises, so holonomy is strictly positive."""
    print("=" * 68)
    print("Escher staircase  (coefficients in Z): every corner rises by 1")
    print("=" * 68)
    stairs = [1, 1, 1, 1]  # a rectangular loop, each flight climbs one unit
    h = holonomy(stairs)
    print(f"  increments      : {stairs}")
    print(f"  holonomy        : {h}")
    print(f"  realizable?     : {is_realizable(stairs)}  (impossible: cannot close up)")
    print()


def demo_realizable_loop() -> None:
    """A genuine loop of ups and downs that closes: holonomy zero, gauge recovered."""
    print("=" * 68)
    print("Honest staircase  (coefficients in Z): rises and falls that cancel")
    print("=" * 68)
    stairs = [2, -1, 3, -4]
    h = holonomy(stairs)
    print(f"  increments      : {stairs}")
    print(f"  holonomy        : {h}")
    print(f"  realizable?     : {is_realizable(stairs)}")
    gauge = gauge_from_partial_sums(stairs)
    print(f"  recovered gauge : {gauge}")
    print(f"  delta(gauge)    : {coboundary(gauge)}  (matches increments)")
    assert coboundary(gauge) == stairs
    print()


def demo_penrose_triangle() -> None:
    """Penrose triangle: n=3, a unit depth shift at one corner. Generator of H^1 = Z."""
    print("=" * 68)
    print("Penrose triangle  (coefficients in Z, n = 3)")
    print("=" * 68)
    p = [1, 0, 0]
    print(f"  increments      : {p}")
    print(f"  holonomy        : {holonomy(p)}  (nonzero -> impossible)")
    print("  As a class in H^1 = Z it maps to 1, hence GENERATES the group:")
    for k in range(-2, 3):
        kp = [k, 0, 0]
        print(f"    k = {k:>2}:  holonomy = {holonomy(kp):>2}   (the strength-k triangle)")
    print()


def demo_moebius_klein() -> None:
    """Orientation over Z/2: odd number of flips => nonzero class => non-orientable."""
    print("=" * 68)
    print("Orientation obstruction  (coefficients in Z/2): Moebius & Klein")
    print("=" * 68)
    cylinder = [0, 0, 1, 1]  # two flips -> even -> orientable
    moebius = [0, 0, 0, 1]  # one flip  -> odd  -> non-orientable
    for name, band in (("cylinder", cylinder), ("Moebius ", moebius)):
        h = holonomy(band, modulus=2)
        orient = "ORIENTABLE" if h == 0 else "NON-ORIENTABLE (one-sided)"
        print(f"  {name}: flips {band}  holonomy(Z/2) = {h}  -> {orient}")
    print("  A Klein bottle = two Moebius bands glued: odd-flip holonomy persists.")
    print()


def demo_complete_invariant() -> None:
    """Holonomy separates cohomology classes: t ~ s  <=>  hol(t) = hol(s)."""
    print("=" * 68)
    print("Holonomy is a complete invariant of the cohomology class")
    print("=" * 68)
    t = [3, -1, 2, 0]  # holonomy 4
    s = [1, 1, 1, 1]  # holonomy 4  -> cohomologous to t
    u = [1, 0, 0, 0]  # holonomy 1  -> different class
    print(f"  t = {t},  holonomy {holonomy(t)}")
    print(f"  s = {s},  holonomy {holonomy(s)}")
    print(f"  u = {u},  holonomy {holonomy(u)}")
    print(f"  t ~ s ? {cohomologous(t, s)}   (equal holonomy)")
    print(f"  t ~ u ? {cohomologous(t, u)}   (different holonomy)")
    # exhibit the witnessing coboundary t - s = delta h
    diff = [ti - si for ti, si in zip(t, s)]
    gauge = gauge_from_partial_sums(diff)
    print(f"  t - s = {diff},  holonomy {holonomy(diff)},  gauge {gauge}")
    assert coboundary(gauge) == diff
    print()


def demo_surjectivity() -> None:
    """Every group element is a holonomy: concentrate the increment on one corner."""
    print("=" * 68)
    print("Holonomy is surjective: every value is attained")
    print("=" * 68)
    for a in (-3, 0, 5, 42):
        t = [a] + [0] * 3
        print(f"  target {a:>3}:  figure {t}  ->  holonomy {holonomy(t)}")
    print()


def main() -> None:
    demo_escher_staircase()
    demo_realizable_loop()
    demo_penrose_triangle()
    demo_moebius_klein()
    demo_complete_invariant()
    demo_surjectivity()
    print("All demonstrations completed; all assertions passed.")


if __name__ == "__main__":
    main()
