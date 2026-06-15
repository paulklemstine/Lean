"""Numerical demonstrations for the no-three-way interaction Markov basis.

This self-contained script illustrates the main results of the package:

  * ``M3``                         -- the single alternating Markov move.
  * Theorem 3.2  (move legality)   -- ``M3`` preserves all twelve two-way margins.
  * Theorem 4.1  (rank-one lattice)-- equal-margin tables differ by an integer
                                      multiple of ``M3``.
  * Lemma 5.3 / Theorem 5.4        -- a monotone walk of +-M3 steps connects two
                                      non-negative equal-margin tables while
                                      staying non-negative throughout.

A ``Table`` is a 2x2x2 array of integers, represented here as a nested tuple
``table[i][j][k]`` with ``i, j, k in {0, 1}``.

Run directly:  ``python demo.py``
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

# A 2x2x2 integer contingency table.
Table = Tuple[Tuple[Tuple[int, int], ...], ...]

CELLS: List[Tuple[int, int, int]] = list(product((0, 1), repeat=3))


# --------------------------------------------------------------------------- #
# Core constructions                                                          #
# --------------------------------------------------------------------------- #
def make_table(values: Dict[Tuple[int, int, int], int]) -> Table:
    """Build a Table from a dict mapping (i, j, k) -> count."""
    return tuple(
        tuple(tuple(values[(i, j, k)] for k in (0, 1)) for j in (0, 1))
        for i in (0, 1)
    )


def get(u: Table, i: int, j: int, k: int) -> int:
    return u[i][j][k]


def m3(i: int, j: int, k: int) -> int:
    """The alternating move M3(i, j, k) = (-1)^(i + j + k)."""
    return 1 if (i + j + k) % 2 == 0 else -1


M3: Table = make_table({c: m3(*c) for c in CELLS})


def add_scaled_m3(u: Table, t: int) -> Table:
    """Return u + t * M3 (pointwise)."""
    return make_table({c: get(u, *c) + t * m3(*c) for c in CELLS})


def is_nonneg(u: Table) -> bool:
    return all(get(u, *c) >= 0 for c in CELLS)


# --------------------------------------------------------------------------- #
# Margins (sufficient statistics of the no-three-way interaction model)        #
# --------------------------------------------------------------------------- #
def m12(u: Table) -> Dict[Tuple[int, int], int]:
    """(i, j)-margins: sum over k."""
    return {(i, j): get(u, i, j, 0) + get(u, i, j, 1) for i in (0, 1) for j in (0, 1)}


def m13(u: Table) -> Dict[Tuple[int, int], int]:
    """(i, k)-margins: sum over j."""
    return {(i, k): get(u, i, 0, k) + get(u, i, 1, k) for i in (0, 1) for k in (0, 1)}


def m23(u: Table) -> Dict[Tuple[int, int], int]:
    """(j, k)-margins: sum over i."""
    return {(j, k): get(u, 0, j, k) + get(u, 1, j, k) for j in (0, 1) for k in (0, 1)}


def same_margins(u: Table, v: Table) -> bool:
    """True iff u and v share all three families of two-way margins."""
    return m12(u) == m12(v) and m13(u) == m13(v) and m23(u) == m23(v)


# --------------------------------------------------------------------------- #
# Connectivity walk (Lemma 5.3 / Theorem 5.4)                                  #
# --------------------------------------------------------------------------- #
def connect_walk(u: Table, t: int) -> List[Table]:
    """Monotone walk of unit +-M3 steps from u to u + t * M3.

    Assumes u and u + t * M3 are both non-negative; by discrete convexity every
    intermediate table is non-negative as well. Returns the full sequence of
    tables visited (length |t| + 1).
    """
    step = 1 if t >= 0 else -1
    walk = [u]
    current = u
    for _ in range(abs(t)):
        current = add_scaled_m3(current, step)
        walk.append(current)
    return walk


def fiber_offset(u: Table, v: Table) -> int:
    """The integer t with v = u + t * M3 (Theorem 4.1); requires same margins."""
    return get(v, 0, 0, 0) - get(u, 0, 0, 0)


# --------------------------------------------------------------------------- #
# Pretty printing                                                             #
# --------------------------------------------------------------------------- #
def fmt(u: Table) -> str:
    rows = []
    for i in (0, 1):
        slab = "  ".join(
            f"[{get(u, i, j, 0):3d} {get(u, i, j, 1):3d}]" for j in (0, 1)
        )
        rows.append(f"i={i}: {slab}")
    return " | ".join(rows)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_move_is_alternating() -> None:
    print("=" * 72)
    print("M3: the single alternating Markov move  M3(i,j,k) = (-1)^(i+j+k)")
    print("=" * 72)
    for c in CELLS:
        print(f"  M3{c} = {m3(*c):+d}")
    print(f"  table form: {fmt(M3)}")
    print()


def demo_move_preserves_margins() -> None:
    print("=" * 72)
    print("Theorem 3.2: adding t * M3 preserves ALL twelve two-way margins")
    print("=" * 72)
    u = make_table(
        {(0, 0, 0): 3, (0, 0, 1): 1, (0, 1, 0): 2, (0, 1, 1): 4,
         (1, 0, 0): 5, (1, 0, 1): 0, (1, 1, 0): 1, (1, 1, 1): 2}
    )
    print(f"  u            = {fmt(u)}")
    for t in (1, 2, -1):
        v = add_scaled_m3(u, t)
        ok = same_margins(u, v)
        print(f"  u + ({t:+d})*M3  = {fmt(v)}   same margins? {ok}")
    print()


def demo_rank_one_lattice() -> None:
    print("=" * 72)
    print("Theorem 4.1: equal-margin tables differ by exactly (v000-u000)*M3")
    print("=" * 72)
    u = make_table(
        {(0, 0, 0): 2, (0, 0, 1): 2, (0, 1, 0): 3, (0, 1, 1): 1,
         (1, 0, 0): 4, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 5}
    )
    v = add_scaled_m3(u, 2)  # construct an equal-margin partner
    t = fiber_offset(u, v)
    reconstructed = add_scaled_m3(u, t)
    print(f"  u                 = {fmt(u)}")
    print(f"  v                 = {fmt(v)}")
    print(f"  same margins?       {same_margins(u, v)}")
    print(f"  inferred offset t = {t}")
    print(f"  u + t*M3          = {fmt(reconstructed)}")
    print(f"  matches v?          {reconstructed == v}")
    print()


def demo_fiber_connectivity() -> None:
    print("=" * 72)
    print("Theorem 5.4: a non-negative +-M3 walk connects equal-margin tables")
    print("=" * 72)
    u = make_table(
        {(0, 0, 0): 0, (0, 0, 1): 3, (0, 1, 0): 3, (0, 1, 1): 0,
         (1, 0, 0): 3, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 3}
    )
    v = add_scaled_m3(u, 3)
    assert same_margins(u, v) and is_nonneg(u) and is_nonneg(v)
    walk = connect_walk(u, fiber_offset(u, v))
    for step_no, w in enumerate(walk):
        print(f"  step {step_no}: {fmt(w)}   nonneg? {is_nonneg(w)}")
    print(f"  every table non-negative? {all(is_nonneg(w) for w in walk)}")
    print(f"  reached v?                {walk[-1] == v}")
    print()


def demo_enumerate_fiber() -> None:
    print("=" * 72)
    print("Fibers are integer intervals along the move line (discrete convexity)")
    print("=" * 72)
    base = make_table(
        {(0, 0, 0): 0, (0, 0, 1): 4, (0, 1, 0): 4, (0, 1, 1): 0,
         (1, 0, 0): 4, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 4}
    )
    feasible = [t for t in range(-10, 11) if is_nonneg(add_scaled_m3(base, t))]
    print(f"  feasible offsets t : {feasible}")
    print(f"  contiguous interval? {feasible == list(range(feasible[0], feasible[-1] + 1))}")
    print(f"  fiber size          : {len(feasible)} tables")
    print()


def main() -> None:
    demo_move_is_alternating()
    demo_move_preserves_margins()
    demo_rank_one_lattice()
    demo_fiber_connectivity()
    demo_enumerate_fiber()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
