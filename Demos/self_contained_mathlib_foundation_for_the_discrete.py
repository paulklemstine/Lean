"""
Numerical demonstrations for the Fundamental Theorem of Markov Bases
(two-way independence model).

A two-way contingency table is an m x n grid of integers. Its *margins* are the
row sums and column sums. The *basic 2x2 swap move* B(i, i', j, j') adds the
balanced pinwheel

            col j   col j'
   row i  [  -1  ][  +1  ]
   row i' [  +1  ][  -1  ]

which leaves every margin unchanged. The Fundamental Theorem of Markov Bases
states that any two non-negative integer tables with the same margins are joined
by a walk of these moves that stays non-negative at every step.

This file implements every relevant object inline (tables, margins, basic moves,
the L1 distance, the sign-pattern pigeonhole search, and the distance-reduction
walk) and demonstrates the main theorems on concrete examples.

Run:  python demo.py
"""

from __future__ import annotations

import random
from typing import List, Optional, Tuple

# A table is a list of rows; each row is a list of integers.
Table = List[List[int]]
Indices = Tuple[int, int, int, int]  # (i, i', j, j')


# --------------------------------------------------------------------------- #
# Basic objects: margins, moves, distance
# --------------------------------------------------------------------------- #
def row_sum(u: Table, i: int) -> int:
    """Margin of row i: sum over columns."""
    return sum(u[i])


def col_sum(u: Table, j: int) -> int:
    """Margin of column j: sum over rows."""
    return sum(row[j] for row in u)


def margins(u: Table) -> Tuple[Tuple[int, ...], Tuple[int, ...]]:
    """All row margins and all column margins."""
    m, n = len(u), len(u[0])
    return (tuple(row_sum(u, i) for i in range(m)),
            tuple(col_sum(u, j) for j in range(n)))


def same_margins(u: Table, v: Table) -> bool:
    """Two tables lie in the same fiber iff all margins agree."""
    return margins(u) == margins(v)


def is_nonneg(u: Table) -> bool:
    """A table is non-negative iff every entry is >= 0."""
    return all(x >= 0 for row in u for x in row)


def basic_move(m: int, n: int, i: int, ip: int, j: int, jp: int) -> Table:
    """The basic 2x2 swap move B(i, i', j, j') as an m x n table."""
    B = [[0 for _ in range(n)] for _ in range(m)]
    B[i][jp] += 1
    B[ip][j] += 1
    B[i][j] -= 1
    B[ip][jp] -= 1
    return B


def add(u: Table, B: Table) -> Table:
    """Pointwise sum of two tables."""
    return [[u[i][j] + B[i][j] for j in range(len(u[0]))] for i in range(len(u))]


def apply_move(u: Table, idx: Indices) -> Table:
    """Apply the basic move with the given indices to u."""
    i, ip, j, jp = idx
    return add(u, basic_move(len(u), len(u[0]), i, ip, j, jp))


def distance(u: Table, v: Table) -> int:
    """L1 (taxicab) distance: total absolute cell discrepancy."""
    return sum(abs(u[i][j] - v[i][j])
               for i in range(len(u)) for j in range(len(u[0])))


# --------------------------------------------------------------------------- #
# Sign-pattern pigeonhole (Theorem 3.3) and one downhill step (Theorem 3.5)
# --------------------------------------------------------------------------- #
def find_aligned_move(u: Table, v: Table) -> Optional[Indices]:
    """
    Three-stage pigeonhole. For distinct equal-margin tables, return indices
    (i, i', j, j') with i != i', j != j' and the sign pattern

        v[i][j]   < u[i][j],     u[i][j']  < v[i][j'],     v[i'][j'] < u[i'][j'].

    Returns None only if u == v.
    """
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]

    # Step 1: a surplus cell (d > 0) must exist when u != v with equal margins.
    surplus = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0),
                   None)
    if surplus is None:
        return None
    i, j = surplus

    # Step 2: a deficit in row i (the row of d sums to 0).
    jp = next(jj for jj in range(n) if d[i][jj] < 0)

    # Step 3: a surplus in column jp (the column of d sums to 0).
    ip = next(ii for ii in range(m) if d[ii][jp] > 0)

    return (i, ip, j, jp)


def downhill_step(u: Table, v: Table) -> Optional[Table]:
    """One legal basic move bringing u strictly closer to v (or None if u==v)."""
    idx = find_aligned_move(u, v)
    if idx is None:
        return None
    return apply_move(u, idx)


# --------------------------------------------------------------------------- #
# The connecting walk (Theorem 3.6, constructive form)
# --------------------------------------------------------------------------- #
def connect_fibers(u: Table, v: Table) -> List[Table]:
    """
    Distance-reduction walk: a non-negative sequence of basic moves from u to v.
    Requires u, v non-negative with the same margins.
    """
    assert is_nonneg(u) and is_nonneg(v), "tables must be non-negative"
    assert same_margins(u, v), "tables must share margins"

    walk: List[Table] = [u]
    cur = [row[:] for row in u]
    while cur != v:
        nxt = downhill_step(cur, v)
        assert nxt is not None
        assert is_nonneg(nxt), "every intermediate table stays non-negative"
        assert distance(nxt, v) < distance(cur, v), "distance strictly decreases"
        cur = nxt
        walk.append(cur)
    return walk


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def show(u: Table, label: str = "") -> None:
    if label:
        print(label)
    for row in u:
        print("   " + " ".join(f"{x:3d}" for x in row))
    rs, cs = margins(u)
    print(f"   row margins = {rs}, col margins = {cs}")


def demo_margin_invariance() -> None:
    print("=" * 64)
    print("DEMO 1 - Margin invariance (Theorem 3.1)")
    print("=" * 64)
    u = [[2, 1, 0],
         [0, 3, 2],
         [1, 1, 4]]
    show(u, "Start table u:")
    idx = (0, 2, 0, 2)  # rows 0,2 ; cols 0,2
    w = apply_move(u, idx)
    show(w, f"\nAfter basic move B{idx}:")
    print(f"\n   margins preserved? {same_margins(u, w)}  (expected True)")


def demo_pigeonhole() -> None:
    print("\n" + "=" * 64)
    print("DEMO 2 - Sign-pattern pigeonhole (Theorem 3.3)")
    print("=" * 64)
    u = [[3, 0, 1],
         [0, 2, 2],
         [1, 2, 1]]
    v = [[1, 2, 1],
         [2, 0, 2],
         [1, 2, 1]]
    show(u, "Table u:")
    show(v, "\nTable v (same margins):")
    idx = find_aligned_move(u, v)
    print(f"\n   aligned frame (i, i', j, j') = {idx}")
    i, ip, j, jp = idx
    print(f"   v[i][j]={v[i][j]}  < u[i][j]={u[i][j]}   (surplus)")
    print(f"   u[i][j']={u[i][jp]} < v[i][j']={v[i][jp]}  (deficit)")
    print(f"   v[i'][j']={v[ip][jp]} < u[i'][j']={u[ip][jp]} (surplus)")
    print(f"   distinct rows? {i != ip}   distinct cols? {j != jp}")


def demo_connecting_walk() -> None:
    print("\n" + "=" * 64)
    print("DEMO 3 - Fundamental Theorem: connecting walk (Theorem 3.6)")
    print("=" * 64)
    u = [[4, 0, 0],
         [0, 4, 0],
         [0, 0, 4]]
    v = [[2, 1, 1],
         [1, 2, 1],
         [1, 1, 2]]
    show(u, "Start u (identity-like):")
    show(v, "\nTarget v (same margins):")
    print(f"\n   same margins? {same_margins(u, v)}   initial distance = "
          f"{distance(u, v)}")
    walk = connect_fibers(u, v)
    print(f"\n   walk length = {len(walk) - 1} moves")
    for k, t in enumerate(walk):
        print(f"   step {k}: distance to v = {distance(t, v)}")
    print(f"\n   reached target? {walk[-1] == v}  (expected True)")


def demo_reversibility_and_random_walk() -> None:
    print("\n" + "=" * 64)
    print("DEMO 4 - Reversibility & symmetric random walk (Theorems 3.7-3.8)")
    print("=" * 64)
    # reverse of B(i,i',j,j') is B(i',i,j,j'); their sum is zero.
    m, n = 3, 3
    B = basic_move(m, n, 0, 2, 1, 2)
    Brev = basic_move(m, n, 2, 0, 1, 2)
    zero = add(B, Brev)
    print(f"   B(0,2,1,2) + B(2,0,1,2) = all zeros? "
          f"{all(x == 0 for r in zero for x in r)}  (expected True)")

    # Symmetric random walk staying in the fiber explores connected tables.
    random.seed(0)
    start = [[2, 1, 1], [1, 2, 1], [1, 1, 2]]
    cur = [r[:] for r in start]
    visited = set()
    for _ in range(2000):
        i, ip = random.sample(range(m), 2)
        j, jp = random.sample(range(n), 2)
        cand = apply_move(cur, (i, ip, j, jp))
        if is_nonneg(cand):  # only legal (non-negative) moves accepted
            cur = cand
        visited.add(tuple(tuple(r) for r in cur))
    print(f"   random walk from a fixed table visited {len(visited)} distinct "
          f"tables in the fiber")
    print(f"   all share start's margins? "
          f"{all(margins([list(r) for r in t]) == margins(start) for t in visited)}")


def main() -> None:
    demo_margin_invariance()
    demo_pigeonhole()
    demo_connecting_walk()
    demo_reversibility_and_random_walk()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
