"""
Visualization: the L1 potential strictly descends along the greedy 2x2-swap walk
connecting two equal-margin contingency tables.

Generates 'markov_walk_descent.png': the staircase of D(u_t, v) versus step t,
illustrating the distance-reduction proof of the Fundamental Theorem of Markov
Bases for the two-way independence model.

Requires matplotlib.  Run:  python _viz.py
"""

from __future__ import annotations

from typing import List, Optional, Tuple

import matplotlib.pyplot as plt

Table = List[List[int]]


def basic_move(m: int, n: int, i: int, ip: int, j: int, jp: int) -> Table:
    b = [[0] * n for _ in range(m)]
    b[i][jp] += 1
    b[ip][j] += 1
    b[i][j] -= 1
    b[ip][jp] -= 1
    return b


def add(u: Table, b: Table) -> Table:
    m, n = len(u), len(u[0])
    return [[u[i][j] + b[i][j] for j in range(n)] for i in range(m)]


def l1(u: Table, v: Table) -> int:
    m, n = len(u), len(u[0])
    return sum(abs(u[i][j] - v[i][j]) for i in range(m) for j in range(n))


def find_good_indices(u: Table, v: Table) -> Optional[Tuple[int, int, int, int]]:
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]
    cell1 = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if cell1 is None:
        return None
    i, j = cell1
    jp = next(c for c in range(n) if d[i][c] < 0)
    ip = next(r for r in range(m) if d[r][jp] > 0)
    return i, ip, j, jp


def greedy_distances(u: Table, v: Table) -> List[int]:
    m, n = len(u), len(u[0])
    cur = [row[:] for row in u]
    ds = [l1(cur, v)]
    while cur != v:
        idx = find_good_indices(cur, v)
        assert idx is not None
        i, ip, j, jp = idx
        cur = add(cur, basic_move(m, n, i, ip, j, jp))
        ds.append(l1(cur, v))
    return ds


def main() -> None:
    u = [[5, 0, 0, 0], [0, 4, 0, 1], [0, 0, 3, 2], [0, 1, 2, 3]]
    v = [[0, 1, 2, 2], [2, 0, 1, 2], [1, 2, 0, 2], [2, 2, 2, 0]]
    # Force equal margins by construction: use a permutation-style rearrangement.
    # (Here we simply pick v with the same margins as u.)
    assert [sum(r) for r in u] == [sum(r) for r in v]
    assert [sum(u[i][j] for i in range(4)) for j in range(4)] == \
           [sum(v[i][j] for i in range(4)) for j in range(4)]

    ds = greedy_distances(u, v)
    steps = list(range(len(ds)))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.step(steps, ds, where="post", linewidth=2.5, color="#1f77b4")
    ax.scatter(steps, ds, zorder=3, color="#d62728")
    ax.set_xlabel("step t (number of 2x2 swaps applied)")
    ax.set_ylabel(r"$D(u_t,\, v)$  ($\ell^1$ distance to target)")
    ax.set_title("Distance-reduction proof in action:\n"
                 "each basic 2x2 swap strictly lowers the potential")
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, max(ds) + 1)
    fig.tight_layout()
    fig.savefig("markov_walk_descent.png", dpi=150)
    print("Wrote markov_walk_descent.png  (walk length:", len(ds) - 1, "swaps)")


if __name__ == "__main__":
    main()


"""
demo.py - Numerical demonstration of the Markov basis of the two-way
independence model.

This script demonstrates, with concrete integer contingency tables, the results
formalized and machine-checked in the companion development:

  * Theorem (Margin invariance): adding a basic 2x2 move preserves every row and
    column sum.
  * Theorem (Faithfulness): the L1 distance D(u, v) is zero iff u == v.
  * Theorem (Sign-pattern pigeonhole): for any two distinct equal-margin tables
    there is a 2x2 rectangle aligned with the sign pattern of u - v.
  * Theorem (Distance decrease): the aligned swap strictly decreases D.
  * Theorem (Fundamental Theorem of Markov Bases): a greedy walk of basic 2x2
    swaps connects any two non-negative equal-margin tables, staying non-negative
    throughout.
  * Theorem (Reversibility): the reverse of a swap is the row-swapped swap.

The code is self-contained: it uses only the Python standard library.

Run:  python demo.py
"""

from __future__ import annotations

from typing import List, Optional, Tuple

Table = List[List[int]]
Cell = Tuple[int, int]


# --------------------------------------------------------------------------- #
#  Core table operations                                                      #
# --------------------------------------------------------------------------- #
def row_sum(u: Table, i: int) -> int:
    """Row margin: the sum of entries in row i."""
    return sum(u[i])


def col_sum(u: Table, j: int) -> int:
    """Column margin: the sum of entries in column j."""
    return sum(u[i][j] for i in range(len(u)))


def margins(u: Table) -> Tuple[Tuple[int, ...], Tuple[int, ...]]:
    """Return (row margins, column margins) of a table."""
    m, n = len(u), len(u[0])
    rows = tuple(row_sum(u, i) for i in range(m))
    cols = tuple(col_sum(u, j) for j in range(n))
    return rows, cols


def same_margins(u: Table, v: Table) -> bool:
    """True iff u and v share all row and column margins."""
    return margins(u) == margins(v)


def is_nonneg(u: Table) -> bool:
    """True iff every entry of u is non-negative."""
    return all(x >= 0 for row in u for x in row)


def basic_move(m: int, n: int, i: int, ip: int, j: int, jp: int) -> Table:
    """The basic 2x2 move B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}."""
    b = [[0] * n for _ in range(m)]
    b[i][jp] += 1
    b[ip][j] += 1
    b[i][j] -= 1
    b[ip][jp] -= 1
    return b


def add(u: Table, b: Table) -> Table:
    """Entrywise sum of two tables."""
    m, n = len(u), len(u[0])
    return [[u[i][j] + b[i][j] for j in range(n)] for i in range(m)]


def l1_distance(u: Table, v: Table) -> int:
    """The L1 potential D(u, v) = sum of |u_ab - v_ab| over all cells."""
    m, n = len(u), len(u[0])
    return sum(abs(u[i][j] - v[i][j]) for i in range(m) for j in range(n))


# --------------------------------------------------------------------------- #
#  Sign-pattern pigeonhole and greedy connection                             #
# --------------------------------------------------------------------------- #
def find_good_indices(u: Table, v: Table) -> Optional[Tuple[int, int, int, int]]:
    """Three-stage pigeonhole search.

    Returns (i, i', j, j') with i != i', j != j', and the sign pattern
      v[i][j]   < u[i][j],
      u[i][j']  < v[i][j'],
      v[i'][j'] < u[i'][j'],
    or None if u == v.
    """
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]

    # Stage 1: a cell where u overshoots v.
    cell1 = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if cell1 is None:
        return None
    i, j = cell1

    # Stage 2: in row i, a column where u undershoots v.
    jp = next((c for c in range(n) if d[i][c] < 0), None)
    assert jp is not None, "row sum zero forces a negative entry"

    # Stage 3: in column j', a row where u overshoots v.
    ip = next((r for r in range(m) if d[r][jp] > 0), None)
    assert ip is not None, "column sum zero forces a positive entry"

    return i, ip, j, jp


def greedy_connect(u: Table, v: Table) -> List[Table]:
    """Greedy distance-reducing walk of basic 2x2 swaps from u to v.

    Precondition: u, v non-negative with equal margins.
    Returns the list of tables visited, starting at u and ending at v; every
    table in the list is non-negative.
    """
    assert is_nonneg(u) and is_nonneg(v), "endpoints must be non-negative"
    assert same_margins(u, v), "endpoints must share margins"
    m, n = len(u), len(u[0])
    cur = [row[:] for row in u]
    path: List[Table] = [[row[:] for row in cur]]
    while cur != v:
        idx = find_good_indices(cur, v)
        assert idx is not None
        i, ip, j, jp = idx
        cur = add(cur, basic_move(m, n, i, ip, j, jp))
        assert is_nonneg(cur), "greedy walk must stay non-negative"
        path.append([row[:] for row in cur])
    return path


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def show(u: Table, label: str = "") -> None:
    """Pretty-print a table with its margins."""
    if label:
        print(label)
    m, n = len(u), len(u[0])
    for i in range(m):
        row = " ".join(f"{u[i][j]:3d}" for j in range(n))
        print(f"  [{row} ]  | row {row_sum(u, i)}")
    cols = " ".join(f"{col_sum(u, j):3d}" for j in range(n))
    print(f"   {cols}    (col margins)")


def demo_margin_invariance() -> None:
    print("=" * 64)
    print("1. MARGIN INVARIANCE: a basic 2x2 move preserves all margins")
    print("=" * 64)
    u = [[40, 30, 60, 70],
         [55, 25, 80, 90],
         [35, 20, 50, 65]]
    show(u, "Original table u:")
    b = basic_move(3, 4, 0, 2, 1, 3)  # rows {0,2}, columns {1,3}
    w = add(u, b)
    show(w, "\nu + B(0,2,1,3):")
    print(f"\nSame margins preserved: {same_margins(u, w)}")
    assert same_margins(u, w)


def demo_faithfulness() -> None:
    print("\n" + "=" * 64)
    print("2. FAITHFULNESS: D(u, v) = 0  iff  u == v")
    print("=" * 64)
    u = [[2, 1], [0, 3]]
    v = [[2, 1], [0, 3]]
    w = [[1, 2], [1, 2]]
    print(f"D(u, u) = {l1_distance(u, v)}  (tables equal)   -> equal? {u == v}")
    print(f"D(u, w) = {l1_distance(u, w)}  (tables differ)  -> equal? {u == w}")
    assert (l1_distance(u, v) == 0) == (u == v)
    assert (l1_distance(u, w) == 0) == (u == w)


def demo_pigeonhole_and_decrease() -> None:
    print("\n" + "=" * 64)
    print("3. SIGN-PATTERN PIGEONHOLE + DISTANCE DECREASE")
    print("=" * 64)
    u = [[3, 0, 1], [0, 2, 2], [1, 2, 1]]
    v = [[1, 2, 1], [1, 1, 2], [2, 1, 1]]
    assert same_margins(u, v)
    idx = find_good_indices(u, v)
    assert idx is not None
    i, ip, j, jp = idx
    print(f"Found aligned rectangle rows ({i},{ip}), cols ({j},{jp}):")
    print(f"  v[{i}][{j}]={v[i][j]} < u[{i}][{j}]={u[i][j]}        (u overshoots)")
    print(f"  u[{i}][{jp}]={u[i][jp]} < v[{i}][{jp}]={v[i][jp]}        (u undershoots)")
    print(f"  v[{ip}][{jp}]={v[ip][jp]} < u[{ip}][{jp}]={u[ip][jp]}        (u overshoots)")
    before = l1_distance(u, v)
    w = add(u, basic_move(3, 3, i, ip, j, jp))
    after = l1_distance(w, v)
    print(f"\nD(u, v)       = {before}")
    print(f"D(u + B, v)   = {after}   (strictly smaller: {after < before})")
    assert after < before


def demo_full_connection() -> None:
    print("\n" + "=" * 64)
    print("4. FUNDAMENTAL THEOREM: greedy 2x2-swap walk connects the fiber")
    print("=" * 64)
    u = [[3, 0, 1], [0, 2, 2], [1, 2, 1]]
    v = [[1, 2, 1], [1, 1, 2], [2, 1, 1]]
    path = greedy_connect(u, v)
    print(f"Walk length: {len(path) - 1} basic 2x2 swaps")
    print(f"Initial distance D(u, v) = {l1_distance(u, v)}")
    for step, table in enumerate(path):
        d = l1_distance(table, v)
        nn = is_nonneg(table)
        print(f"  step {step}: D = {d:2d}   non-negative: {nn}")
    assert path[-1] == v
    print("Reached v exactly, staying non-negative throughout.  QED.")


def demo_reversibility() -> None:
    print("\n" + "=" * 64)
    print("5. REVERSIBILITY: B(i',i,j,j') = -B(i,i',j,j')")
    print("=" * 64)
    m, n = 3, 4
    b = basic_move(m, n, 0, 2, 1, 3)
    b_rev = basic_move(m, n, 2, 0, 1, 3)  # rows swapped
    neg_b = [[-b[i][j] for j in range(n)] for i in range(m)]
    print(f"B(0,2,1,3) + B(2,0,1,3) == 0 everywhere: "
          f"{b_rev == neg_b}")
    assert b_rev == neg_b
    u = [[40, 30, 60, 70], [55, 25, 80, 90], [35, 20, 50, 65]]
    there = add(u, b)
    back = add(there, b_rev)
    print(f"u --B--> w --B_rev--> u  recovered exactly: {back == u}")
    assert back == u


def main() -> None:
    demo_margin_invariance()
    demo_faithfulness()
    demo_pigeonhole_and_decrease()
    demo_full_connection()
    demo_reversibility()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
