"""
Numerical demonstrations for the 2x2x2 no-three-way interaction model.

This script illustrates the three formally proved results:

  1. Legality            -- adding t * M3 preserves all two-way margins.
  2. Rank-one lattice    -- equal-margin tables differ by exactly
                            (v[0,0,0] - u[0,0,0]) * M3 ; {M3} is the Markov basis.
  3. Fiber connectivity  -- any two non-negative equal-margin tables are joined
                            by a walk of +/-M3 steps that stays non-negative.

A table is represented as a dict {(i,j,k): count} with i,j,k in {0,1}.
Everything is self-contained: no third-party libraries are required.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

Index = Tuple[int, int, int]
Table = Dict[Index, int]

CELLS: List[Index] = list(product((0, 1), repeat=3))


# --------------------------------------------------------------------------- #
# The alternating Markov move M3(i,j,k) = (-1)^(i+j+k).
# --------------------------------------------------------------------------- #
def M3(i: int, j: int, k: int) -> int:
    """The degree-4 alternating move: +1 on even-parity cells, -1 on odd."""
    return 1 if (i + j + k) % 2 == 0 else -1


def m3_table() -> Table:
    """M3 as a full table."""
    return {(i, j, k): M3(i, j, k) for (i, j, k) in CELLS}


# --------------------------------------------------------------------------- #
# Margins.
# --------------------------------------------------------------------------- #
def m12(u: Table) -> Dict[Tuple[int, int], int]:
    """(i,j) margins: sum over k."""
    return {(i, j): u[(i, j, 0)] + u[(i, j, 1)] for i in (0, 1) for j in (0, 1)}


def m13(u: Table) -> Dict[Tuple[int, int], int]:
    """(i,k) margins: sum over j."""
    return {(i, k): u[(i, 0, k)] + u[(i, 1, k)] for i in (0, 1) for k in (0, 1)}


def m23(u: Table) -> Dict[Tuple[int, int], int]:
    """(j,k) margins: sum over i."""
    return {(j, k): u[(0, j, k)] + u[(1, j, k)] for j in (0, 1) for k in (0, 1)}


def same_margins(u: Table, v: Table) -> bool:
    """True iff all three families of two-way margins agree."""
    return m12(u) == m12(v) and m13(u) == m13(v) and m23(u) == m23(v)


# --------------------------------------------------------------------------- #
# Table arithmetic.
# --------------------------------------------------------------------------- #
def add_scaled_M3(u: Table, t: int) -> Table:
    """Return u + t * M3."""
    return {c: u[c] + t * M3(*c) for c in CELLS}


def is_nonneg(u: Table) -> bool:
    return all(v >= 0 for v in u.values())


def lattice_coordinate(u: Table, v: Table) -> int:
    """Single integer t with v = u + t * M3 (valid when same_margins(u, v))."""
    return v[(0, 0, 0)] - u[(0, 0, 0)]


def show(u: Table) -> str:
    return "  ".join(f"{c}:{u[c]:+d}" for c in CELLS)


# --------------------------------------------------------------------------- #
# Demonstration 1: legality of the move.
# --------------------------------------------------------------------------- #
def demo_legality() -> None:
    print("=" * 70)
    print("DEMO 1 -- Legality: u + t*M3 preserves every two-way margin")
    print("=" * 70)
    u: Table = {(0, 0, 0): 3, (0, 0, 1): 1, (0, 1, 0): 2, (0, 1, 1): 5,
                (1, 0, 0): 4, (1, 0, 1): 0, (1, 1, 0): 6, (1, 1, 1): 2}
    print("base table u :", show(u))
    for t in (-2, 1, 3):
        w = add_scaled_M3(u, t)
        ok = same_margins(u, w)
        print(f"  t = {t:+d}:  u + t*M3 = {show(w)}")
        print(f"           margins preserved? {ok}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 2: rank-one lattice.
# --------------------------------------------------------------------------- #
def demo_rank_one() -> None:
    print("=" * 70)
    print("DEMO 2 -- Rank-one lattice: equal margins => difference is t*M3")
    print("=" * 70)
    u: Table = {(0, 0, 0): 3, (0, 0, 1): 1, (0, 1, 0): 2, (0, 1, 1): 5,
                (1, 0, 0): 4, (1, 0, 1): 0, (1, 1, 0): 6, (1, 1, 1): 2}
    # Build v in the same fiber by shifting along M3.
    v = add_scaled_M3(u, 2)
    assert same_margins(u, v)
    t = lattice_coordinate(u, v)
    reconstructed = add_scaled_M3(u, t)
    print("u           :", show(u))
    print("v           :", show(v))
    print(f"coordinate t = v[0,0,0]-u[0,0,0] = {t}")
    print("u + t*M3    :", show(reconstructed))
    print("v == u+t*M3 ?", reconstructed == v)
    print()


# --------------------------------------------------------------------------- #
# Demonstration 3: connecting walk (Fundamental Theorem of Markov Bases).
# --------------------------------------------------------------------------- #
def connecting_walk(u: Table, v: Table) -> List[Table]:
    """Explicit non-negative walk of +/-M3 steps from u to v.

    Precondition: same_margins(u, v), is_nonneg(u), is_nonneg(v).
    """
    assert same_margins(u, v) and is_nonneg(u) and is_nonneg(v)
    t = lattice_coordinate(u, v)
    step = 1 if t > 0 else -1
    walk = [u]
    current = u
    for _ in range(abs(t)):
        current = add_scaled_M3(current, step)
        assert is_nonneg(current), "discrete-convexity guarantee violated!"
        walk.append(current)
    assert current == v
    return walk


def demo_connectivity() -> None:
    print("=" * 70)
    print("DEMO 3 -- Fiber connectivity: a non-negative +/-M3 walk joins u to v")
    print("=" * 70)
    u: Table = {(0, 0, 0): 0, (0, 0, 1): 4, (0, 1, 0): 3, (0, 1, 1): 1,
                (1, 0, 0): 5, (1, 0, 1): 1, (1, 1, 0): 2, (1, 1, 1): 4}
    v = add_scaled_M3(u, 3)        # same fiber, three moves away
    assert is_nonneg(u) and is_nonneg(v)
    walk = connecting_walk(u, v)
    print(f"walk has {len(walk)} tables ({len(walk)-1} legal +/-M3 steps):")
    for s, tbl in enumerate(walk):
        print(f"  step {s}: {show(tbl)}  nonneg={is_nonneg(tbl)}")
    print("every intermediate table non-negative?",
          all(is_nonneg(t) for t in walk))
    print()


# --------------------------------------------------------------------------- #
# Demonstration 4: enumerate a whole fiber and confirm it is M3-connected.
# --------------------------------------------------------------------------- #
def enumerate_fiber(u: Table) -> List[Table]:
    """All non-negative tables sharing u's margins (i.e. u + t*M3, t feasible)."""
    fiber = []
    t = 0
    while is_nonneg(add_scaled_M3(u, t)):   # walk up
        fiber.append(add_scaled_M3(u, t))
        t += 1
    t = -1
    while is_nonneg(add_scaled_M3(u, t)):   # walk down
        fiber.insert(0, add_scaled_M3(u, t))
        t -= 1
    return fiber


def demo_fiber_is_an_interval() -> None:
    print("=" * 70)
    print("DEMO 4 -- The fiber is a single M3-interval (discrete convexity)")
    print("=" * 70)
    u: Table = {(0, 0, 0): 1, (0, 0, 1): 2, (0, 1, 0): 2, (0, 1, 1): 1,
                (1, 0, 0): 3, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 3}
    fiber = enumerate_fiber(u)
    print(f"fiber size = {len(fiber)} tables; listed by M3-coordinate:")
    base000 = fiber[0][(0, 0, 0)]
    for tbl in fiber:
        coord = tbl[(0, 0, 0)] - base000
        print(f"  t={coord}: {show(tbl)}")
    coords = [tbl[(0, 0, 0)] for tbl in fiber]
    contiguous = coords == list(range(min(coords), max(coords) + 1))
    print("M3-coordinates form a contiguous integer interval?", contiguous)
    print()


if __name__ == "__main__":
    demo_legality()
    demo_rank_one()
    demo_connectivity()
    demo_fiber_is_an_interval()
    print("All demonstrations completed.")
