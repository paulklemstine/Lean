"""
The Topology of Impossible Objects: Escher Stairs and Klein Bottles
===================================================================

Numerical demonstrations of the holonomy theory of impossible figures.

A cyclic figure with ``n`` overlapping patches carries local reconciliation
data ``t[0], ..., t[n-1]`` valued in an abelian group.  The figure is
*realizable* (buildable as an honest object) if and only if its **holonomy**
-- the total increment accumulated once around the loop -- is the identity.

    * Additive model  (group = the reals):     holonomy = sum(t),   identity = 0
    * Orientation     (group = Z/2):            holonomy = sum(t) % 2, identity = 0
    * Multiplicative  (group = positive reals): monodromy = prod(t), identity = 1

This script verifies:
    - the Penrose triangle is impossible (holonomy = 3);
    - a closed everywhere-ascending staircase is impossible;
    - a Moebius / Klein gluing (odd number of flips) has no global orientation;
    - impossibility is GLOBAL, not local (uniform-impossible vs distinct-realizable);
    - the reconstructed gauge really induces the local data when holonomy vanishes;
    - the multiplicative (developable-surface) model and its contrarian example.

Self-contained: standard library only.
"""

from __future__ import annotations

from typing import List, Optional, Callable, TypeVar

T = TypeVar("T")


# ---------------------------------------------------------------------------
# Additive model (coefficients in the reals)
# ---------------------------------------------------------------------------

def holonomy(t: List[float]) -> float:
    """Total additive increment accumulated once around the cyclic figure."""
    return sum(t)


def is_realizable(t: List[float], tol: float = 1e-12) -> bool:
    """A figure is realizable iff its holonomy vanishes."""
    return abs(holonomy(t)) <= tol


def reconstruct_gauge(t: List[float]) -> Optional[List[float]]:
    """
    Return an explicit global height field h with h[i+1] - h[i] = t[i]
    (indices modulo n), or None if the figure is impossible.

    The gauge is the vector of partial sums: h[i] = t[0] + ... + t[i-1].
    """
    if not is_realizable(t):
        return None
    n = len(t)
    h = [0.0] * n
    running = 0.0
    for i in range(n):
        h[i] = running
        running += t[i]
    return h


def verify_gauge(t: List[float], h: List[float], tol: float = 1e-9) -> bool:
    """Check that h[i+1] - h[i] = t[i] cyclically."""
    n = len(t)
    return all(abs((h[(i + 1) % n] - h[i]) - t[i]) <= tol for i in range(n))


# ---------------------------------------------------------------------------
# Orientation model (coefficients in Z/2)
# ---------------------------------------------------------------------------

def holonomy_z2(flips: List[int]) -> int:
    """Total orientation flip around the loop, modulo 2."""
    return sum(f % 2 for f in flips) % 2


def is_orientable(flips: List[int]) -> bool:
    """A closed band is orientable iff its Z/2 holonomy is 0 (even flips)."""
    return holonomy_z2(flips) == 0


# ---------------------------------------------------------------------------
# Multiplicative model (coefficients in the positive reals -> developable)
# ---------------------------------------------------------------------------

def monodromy(t: List[float]) -> float:
    """Total multiplicative scaling accumulated once around the figure."""
    prod = 1.0
    for x in t:
        prod *= x
    return prod


def is_developable(t: List[float], tol: float = 1e-12) -> bool:
    """A scaling figure is developable iff its monodromy equals 1."""
    return abs(monodromy(t) - 1.0) <= tol


def reconstruct_scale_gauge(t: List[float]) -> Optional[List[float]]:
    """Partial-product gauge h with h[i+1] / h[i] = t[i], or None if impossible."""
    if not is_developable(t):
        return None
    n = len(t)
    h = [1.0] * n
    running = 1.0
    for i in range(n):
        h[i] = running
        running *= t[i]
    return h


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_penrose_triangle() -> None:
    print("=" * 68)
    print("Penrose triangle: three beams, each receding by one unit")
    print("=" * 68)
    t = [1.0, 1.0, 1.0]
    print(f"  local increments t = {t}")
    print(f"  holonomy          = {holonomy(t)}")
    print(f"  realizable?       = {is_realizable(t)}   (impossible: holonomy = 3)")
    print()


def demo_escher_staircase() -> None:
    print("=" * 68)
    print("Escher staircase: a closed flight where every step ascends")
    print("=" * 68)
    for t in ([1.0, 2.0, 1.5, 0.5], [0.3] * 6):
        print(f"  ascending steps t = {t}")
        print(f"  holonomy          = {holonomy(t):.4f} > 0  ->  impossible")
    print()


def demo_global_not_local() -> None:
    print("=" * 68)
    print("Impossibility is GLOBAL, not local")
    print("=" * 68)
    uniform = [1.0, 1.0, 1.0]
    distinct = [1.0, 2.0, -3.0]
    print(f"  uniform data  t = {uniform}  (all equal) ->",
          "IMPOSSIBLE" if not is_realizable(uniform) else "realizable",
          f"(holonomy {holonomy(uniform)})")
    print(f"  distinct data t = {distinct} (all differ) ->",
          "impossible" if not is_realizable(distinct) else "REALIZABLE",
          f"(holonomy {holonomy(distinct)})")
    h = reconstruct_gauge(distinct)
    assert h is not None and verify_gauge(distinct, h)
    print(f"  reconstructed height field h = {h}  (verified: h[i+1]-h[i] = t[i])")
    print()


def demo_klein_mobius() -> None:
    print("=" * 68)
    print("Moebius band / Klein bottle: orientation flips modulo 2")
    print("=" * 68)
    mobius = [1]                # one self-gluing with a flip
    cylinder = [1, 1]           # two flips cancel
    klein = [1, 0, 1, 1]        # odd number of flips
    for name, flips in [("Moebius band", mobius),
                        ("plain cylinder", cylinder),
                        ("Klein loop", klein)]:
        ok = is_orientable(flips)
        print(f"  {name:16s} flips={flips!s:14s} holonomy={holonomy_z2(flips)} "
              f"-> {'orientable' if ok else 'NON-orientable'}")
    print()


def demo_developable() -> None:
    print("=" * 68)
    print("Multiplicative model: developable (flat) surfaces")
    print("=" * 68)
    g = 1.5
    scaling_triangle = [g, g, g]           # monodromy g^3 != 1
    cancelling = [g, 1.0 / g]              # both nontrivial, monodromy 1
    print(f"  scaling triangle t = {scaling_triangle}  monodromy = {monodromy(scaling_triangle):.4f}"
          f"  -> {'developable' if is_developable(scaling_triangle) else 'NOT developable'}")
    print(f"  cancelling pair  t = {cancelling}  monodromy = {monodromy(cancelling):.4f}"
          f"  -> {'DEVELOPABLE' if is_developable(cancelling) else 'not developable'}")
    print("    (contrarian: both factors != 1, yet the figure is developable)")
    h = reconstruct_scale_gauge(cancelling)
    print(f"    reconstructed scale gauge h = {h}")
    print()


def demo_surjectivity() -> None:
    print("=" * 68)
    print("Impossibility is a complete, real-valued invariant (H^1 = R)")
    print("=" * 68)
    for r in (-2.0, 0.0, 3.14, 100.0):
        t = [r, 0.0, 0.0]  # holonomy = r for any target r
        print(f"  target class r = {r:8.4f}  ->  figure with holonomy {holonomy(t):8.4f}"
              f"  ({'realizable' if is_realizable(t) else 'impossible'})")
    print()


def main() -> None:
    demo_penrose_triangle()
    demo_escher_staircase()
    demo_global_not_local()
    demo_klein_mobius()
    demo_developable()
    demo_surjectivity()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
