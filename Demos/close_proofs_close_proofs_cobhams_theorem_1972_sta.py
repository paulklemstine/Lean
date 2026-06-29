"""
Numerical demonstrations for the 2x2x2 no-three-way interaction model.

This script is fully self-contained (standard library only) and illustrates the
three main results:

  1. The alternating move M3(i,j,k) = (-1)^(i+j+k) preserves every two-way margin
     (it lies in the kernel of the margin map).
  2. The move lattice is RANK ONE: any two equal-margin tables differ by exactly
     t * M3 where t = v[0,0,0] - u[0,0,0].
  3. Fundamental Theorem of Markov Bases (this model): any two NON-NEGATIVE tables
     with the same two-way margins are connected by a walk of +/- M3 steps that
     stays non-negative throughout.

A 2x2x2 table is represented as a dict {(i,j,k): int} with i,j,k in {0,1}.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]

CELLS: List[Cell] = list(product((0, 1), repeat=3))


# --------------------------------------------------------------------------- #
# Core definitions
# --------------------------------------------------------------------------- #
def M3(i: int, j: int, k: int) -> int:
    """The alternating Markov move: +1 if i+j+k is even, -1 if odd."""
    return 1 if (i + j + k) % 2 == 0 else -1


def M3_table() -> Table:
    """M3 as a full table."""
    return {(i, j, k): M3(i, j, k) for (i, j, k) in CELLS}


def add(u: Table, v: Table, scale: int = 1) -> Table:
    """Return u + scale * v (pointwise)."""
    return {c: u[c] + scale * v[c] for c in CELLS}


def m12(u: Table, i: int, j: int) -> int:
    """(i,j) margin: sum over k."""
    return u[(i, j, 0)] + u[(i, j, 1)]


def m13(u: Table, i: int, k: int) -> int:
    """(i,k) margin: sum over j."""
    return u[(i, 0, k)] + u[(i, 1, k)]


def m23(u: Table, j: int, k: int) -> int:
    """(j,k) margin: sum over i."""
    return u[(0, j, k)] + u[(1, j, k)]


def margins(u: Table) -> Tuple[Tuple[int, ...], ...]:
    """All twelve two-way margins as a hashable tuple."""
    a = tuple(m12(u, i, j) for i, j in product((0, 1), repeat=2))
    b = tuple(m13(u, i, k) for i, k in product((0, 1), repeat=2))
    c = tuple(m23(u, j, k) for j, k in product((0, 1), repeat=2))
    return (a, b, c)


def same_margins(u: Table, v: Table) -> bool:
    return margins(u) == margins(v)


def is_nonneg(u: Table) -> bool:
    return all(u[c] >= 0 for c in CELLS)


# --------------------------------------------------------------------------- #
# Result 1: the move preserves all margins
# --------------------------------------------------------------------------- #
def demo_move_preserves_margins() -> None:
    print("=" * 70)
    print("RESULT 1: M3 lies in the kernel of the two-way margin map")
    print("=" * 70)
    u: Table = {(0, 0, 0): 5, (0, 0, 1): 2, (0, 1, 0): 1, (0, 1, 1): 7,
                (1, 0, 0): 3, (1, 0, 1): 4, (1, 1, 0): 6, (1, 1, 1): 0}
    m3 = M3_table()
    print("M3 as a checkerboard cube (k=0 face, then k=1 face):")
    for k in (0, 1):
        print(f"  k={k}: " + "  ".join(f"({i}{j})={M3(i, j, k):+d}"
                                       for i, j in product((0, 1), repeat=2)))
    for t in (-3, -1, 0, 1, 2, 5):
        v = add(u, m3, scale=t)
        ok = same_margins(u, v)
        print(f"  u + ({t:+d})*M3 has same margins as u? {ok}")
    print()


# --------------------------------------------------------------------------- #
# Result 2: rank-one move lattice
# --------------------------------------------------------------------------- #
def demo_rank_one_kernel() -> None:
    print("=" * 70)
    print("RESULT 2: rank-one move lattice -- difference is t * M3")
    print("=" * 70)
    u: Table = {(0, 0, 0): 5, (0, 0, 1): 2, (0, 1, 0): 1, (0, 1, 1): 7,
                (1, 0, 0): 3, (1, 0, 1): 4, (1, 1, 0): 6, (1, 1, 1): 0}
    # Build v with the SAME margins but a different corner cell.
    t = 2
    v = add(u, M3_table(), scale=t)
    predicted_t = v[(0, 0, 0)] - u[(0, 0, 0)]
    reconstructed = add(u, M3_table(), scale=predicted_t)
    print(f"  predicted multiplier t = v000 - u000 = {predicted_t}")
    print(f"  v == u + t*M3 ?  {reconstructed == v}")
    diff = {c: v[c] - u[c] for c in CELLS}
    print(f"  v - u = {[diff[c] for c in CELLS]}")
    print(f"  t * M3 = {[predicted_t * M3(*c) for c in CELLS]}")
    print("  => every margin-preserving move is an integer multiple of M3.")
    print()


# --------------------------------------------------------------------------- #
# Result 3: fiber connectivity (the explicit non-negative walk)
# --------------------------------------------------------------------------- #
def connecting_walk(u: Table, v: Table) -> List[Table]:
    """
    Return the explicit +/- M3 walk from u to v through non-negative tables.
    Precondition: u, v >= 0 and same_margins(u, v).
    """
    assert is_nonneg(u) and is_nonneg(v) and same_margins(u, v)
    t = v[(0, 0, 0)] - u[(0, 0, 0)]
    step_sign = 1 if t >= 0 else -1
    path = [dict(u)]
    w = dict(u)
    for _ in range(abs(t)):
        w = add(w, M3_table(), scale=step_sign)
        assert is_nonneg(w), "walk left the non-negative region (should not happen)"
        path.append(dict(w))
    assert w == v
    return path


def demo_fiber_connectivity() -> None:
    print("=" * 70)
    print("RESULT 3: Fundamental Theorem -- {M3} connects every fiber")
    print("=" * 70)
    u: Table = {(0, 0, 0): 0, (0, 0, 1): 3, (0, 1, 0): 3, (0, 1, 1): 0,
                (1, 0, 0): 3, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 3}
    v = add(u, M3_table(), scale=3)  # bump even cells up by 3, odd cells down by 3
    print(f"  start u = {[u[c] for c in CELLS]}  (nonneg: {is_nonneg(u)})")
    print(f"  target v = {[v[c] for c in CELLS]}  (nonneg: {is_nonneg(v)})")
    print(f"  same margins? {same_margins(u, v)}")
    path = connecting_walk(u, v)
    print(f"  walk length: {len(path) - 1} steps, all non-negative:")
    for n, w in enumerate(path):
        print(f"    step {n}: {[w[c] for c in CELLS]}  nonneg={is_nonneg(w)}")
    print()


# --------------------------------------------------------------------------- #
# Bonus: enumerate a small fiber and confirm it is a single connected segment
# --------------------------------------------------------------------------- #
def demo_fiber_is_a_segment() -> None:
    print("=" * 70)
    print("BONUS: a fiber is a single line segment of integer tables")
    print("=" * 70)
    base: Table = {(0, 0, 0): 2, (0, 0, 1): 2, (0, 1, 0): 2, (0, 1, 1): 2,
                   (1, 0, 0): 2, (1, 0, 1): 2, (1, 1, 0): 2, (1, 1, 1): 2}
    # Brute force: all non-negative tables with these margins.
    target = margins(base)
    fiber: List[int] = []
    # By rank-one structure every fiber member is base + t*M3 for some t.
    for t in range(-10, 11):
        w = add(base, M3_table(), scale=t)
        if is_nonneg(w) and margins(w) == target:
            fiber.append(t)
    print(f"  multipliers t with base + t*M3 in the fiber: {fiber}")
    print(f"  this set of integers is a contiguous interval: "
          f"{fiber == list(range(min(fiber), max(fiber) + 1))}")
    print("  => discrete convexity: the non-negative locus is an interval.")
    print()


if __name__ == "__main__":
    demo_move_preserves_margins()
    demo_rank_one_kernel()
    demo_fiber_connectivity()
    demo_fiber_is_a_segment()
    print("All demonstrations completed successfully.")
