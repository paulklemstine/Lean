"""
Markov Bases for Contingency Tables: Numerical Demonstrations
=============================================================

Self-contained Python demonstrations of the Fundamental Theorem of Markov Bases
for the two-way independence model on m x n integer contingency tables.

Mathematical setting
---------------------
A contingency table is an m x n grid of non-negative integers `u[i][j]`.
The *independence model* fixes the row margins (row sums) and column margins
(column sums). A *fiber* is the set of all non-negative integer tables sharing a
fixed pair of margins.

The *basic 2x2 swap move* on rows i != i' and columns j != j' is

        B(i, i', j, j') :  +1 at (i, j') and (i', j),
                           -1 at (i, j) and (i', j').

This file demonstrates, with concrete numbers, the four pillars of the proof:

  1. basic moves preserve all row and column margins (Lemma 3.1);
  2. the sign-pattern pigeonhole always finds an aligned 2x2 frame (Lemma 3.3);
  3. each aligned move strictly decreases the L1 distance to the target
     (Lemma 3.4);
  4. iterating connects any two tables in the same fiber (Theorem 4.1),
     never leaving the non-negative orthant.

Everything is inlined; only the standard library is used.
"""

from __future__ import annotations

from itertools import product
from typing import List, Optional, Tuple

Table = List[List[int]]
Move = Tuple[int, int, int, int]  # (i, i', j, j')


# ---------------------------------------------------------------------------
# Core definitions
# ---------------------------------------------------------------------------
def row_sums(u: Table) -> List[int]:
    """Row margins: rowSum(u)[i] = sum_j u[i][j]."""
    return [sum(row) for row in u]


def col_sums(u: Table) -> List[int]:
    """Column margins: colSum(u)[j] = sum_i u[i][j]."""
    m, n = len(u), len(u[0])
    return [sum(u[i][j] for i in range(m)) for j in range(n)]


def same_margins(u: Table, v: Table) -> bool:
    """True iff u and v lie in the same fiber (equal row and column margins)."""
    return row_sums(u) == row_sums(v) and col_sums(u) == col_sums(v)


def is_nonneg(u: Table) -> bool:
    """True iff every cell is non-negative."""
    return all(x >= 0 for row in u for x in row)


def l1_distance(u: Table, v: Table) -> int:
    """L1 distance D(u, v) = sum over cells of |u[i][j] - v[i][j]|."""
    m, n = len(u), len(u[0])
    return sum(abs(u[i][j] - v[i][j]) for i in range(m) for j in range(n))


def apply_move(u: Table, move: Move) -> Table:
    """Return u + B(i, i', j, j') as a fresh table."""
    i, ip, j, jp = move
    w = [row[:] for row in u]
    w[i][jp] += 1
    w[ip][j] += 1
    w[i][j] -= 1
    w[ip][jp] -= 1
    return w


# ---------------------------------------------------------------------------
# The three-stage sign-pattern pigeonhole (Lemma 3.3)
# ---------------------------------------------------------------------------
def find_aligned_frame(u: Table, v: Table) -> Optional[Move]:
    """
    Find a 2x2 frame (i, i', j, j') with i != i', j != j' and the sign pattern
        v[i][j]   < u[i][j],
        u[i][j']  < v[i][j'],
        v[i'][j'] < u[i'][j'].
    Returns None iff u == v.  This is the constructive content of Lemma 3.3.
    """
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]

    # Stage 1 (all-cells sum is 0): find a cell with u > v.
    pos = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if pos is None:
        return None  # equal margins + no positive cell => u == v
    i, j = pos

    # Stage 2 (row i sums to 0): find a column j' in row i with u < v.
    jp = next((jj for jj in range(n) if d[i][jj] < 0), None)
    assert jp is not None, "row margin forces a negative entry"

    # Stage 3 (column j' sums to 0): find a row i' in column j' with u > v.
    ip = next((ii for ii in range(m) if d[ii][jp] > 0), None)
    assert ip is not None, "column margin forces a positive entry"

    # Distinctness is automatic from the opposite signs.
    assert i != ip and j != jp
    return (i, ip, j, jp)


# ---------------------------------------------------------------------------
# Distance-reduction connector (Algorithm A, Theorem 4.1)
# ---------------------------------------------------------------------------
def connect(u: Table, v: Table) -> List[Move]:
    """
    Return a list of basic moves transforming u into v, staying non-negative
    throughout.  Requires same_margins(u, v) and both non-negative.
    """
    assert same_margins(u, v), "tables must share margins (same fiber)"
    assert is_nonneg(u) and is_nonneg(v), "tables must be non-negative"
    moves: List[Move] = []
    cur = [row[:] for row in u]
    guard = 0
    while cur != v:
        frame = find_aligned_frame(cur, v)
        assert frame is not None
        cur = apply_move(cur, frame)
        assert is_nonneg(cur), "move must preserve non-negativity"
        moves.append(frame)
        guard += 1
        assert guard <= l1_distance(u, v) + 1, "must terminate within D(u,v) steps"
    return moves


# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------
def show(u: Table, label: str = "") -> None:
    if label:
        print(label)
    width = max((len(str(x)) for row in u for x in row), default=1)
    for row in u:
        print("   [" + " ".join(str(x).rjust(width) for x in row) + "]")
    print(f"      row sums = {row_sums(u)},  col sums = {col_sums(u)}")


# ===========================================================================
# DEMO 1 — Basic moves preserve margins (Lemma 3.1)
# ===========================================================================
def demo_margin_invariance() -> None:
    print("=" * 70)
    print("DEMO 1: Basic 2x2 moves preserve every row and column margin")
    print("=" * 70)
    u: Table = [
        [3, 1, 2],
        [0, 4, 1],
        [2, 2, 5],
    ]
    show(u, "Original table u:")
    for move in [(0, 1, 0, 1), (0, 2, 1, 2), (1, 2, 0, 2)]:
        w = apply_move(u, move)
        print(f"\n   After basic move B{move}:")
        show(w)
        print(f"      same margins as u?  {same_margins(u, w)}")
    print()


# ===========================================================================
# DEMO 2 — The sign-pattern pigeonhole always finds a frame (Lemma 3.3)
# ===========================================================================
def demo_pigeonhole() -> None:
    print("=" * 70)
    print("DEMO 2: The three-stage pigeonhole finds an aligned 2x2 frame")
    print("=" * 70)
    u: Table = [
        [5, 0, 1],
        [0, 3, 3],
        [1, 3, 2],
    ]
    v: Table = [
        [3, 2, 1],
        [2, 1, 3],
        [1, 3, 2],
    ]
    show(u, "Table u:")
    show(v, "Table v:")
    print(f"\n   same fiber?  {same_margins(u, v)}")
    frame = find_aligned_frame(u, v)
    print(f"   aligned frame (i, i', j, j') = {frame}")
    i, ip, j, jp = frame
    print(f"      v[{i}][{j}]   = {v[i][j]}  <  u[{i}][{j}]   = {u[i][j]}   (overshoot)")
    print(f"      u[{i}][{jp}]  = {u[i][jp]}  <  v[{i}][{jp}]  = {v[i][jp]}   (undershoot)")
    print(f"      v[{ip}][{jp}] = {v[ip][jp]}  <  u[{ip}][{jp}] = {u[ip][jp]}   (overshoot)")
    print()


# ===========================================================================
# DEMO 3 — Each aligned move strictly decreases the L1 distance (Lemma 3.4)
# ===========================================================================
def demo_distance_decrease() -> None:
    print("=" * 70)
    print("DEMO 3: Each aligned move strictly decreases the L1 distance")
    print("=" * 70)
    u: Table = [
        [5, 0, 1],
        [0, 3, 3],
        [1, 3, 2],
    ]
    v: Table = [
        [3, 2, 1],
        [2, 1, 3],
        [1, 3, 2],
    ]
    cur = [row[:] for row in u]
    step = 0
    print(f"   start: D(u, v) = {l1_distance(cur, v)}")
    while cur != v:
        frame = find_aligned_frame(cur, v)
        before = l1_distance(cur, v)
        cur = apply_move(cur, frame)
        after = l1_distance(cur, v)
        step += 1
        print(f"   step {step}: move B{frame}  ->  D = {before} - {before - after} = {after}"
              f"   (nonneg: {is_nonneg(cur)})")
    print(f"   reached the target in {step} moves.\n")


# ===========================================================================
# DEMO 4 — Connectivity of an entire fiber (Theorem 4.1)
# ===========================================================================
def enumerate_fiber(row_marg: List[int], col_marg: List[int]) -> List[Table]:
    """Brute-force enumerate all non-negative tables with the given margins."""
    m, n = len(row_marg), len(col_marg)
    total = sum(row_marg)
    if total != sum(col_marg):
        return []
    tables: List[Table] = []

    def backtrack(cells_done: int, u: Table) -> None:
        if cells_done == m * n:
            if row_sums(u) == row_marg and col_sums(u) == col_marg:
                tables.append([row[:] for row in u])
            return
        i, j = divmod(cells_done, n)
        # Upper bound for cell (i, j): cannot exceed remaining row or column room.
        used_row = sum(u[i][:j])
        cap = row_marg[i] - used_row
        for val in range(cap + 1):
            u[i][j] = val
            backtrack(cells_done + 1, u)
        u[i][j] = 0

    backtrack(0, [[0] * n for _ in range(m)])
    return tables


def demo_fiber_connectivity() -> None:
    print("=" * 70)
    print("DEMO 4: Every pair in a fiber is connected by basic 2x2 moves")
    print("=" * 70)
    row_marg = [3, 3]
    col_marg = [2, 2, 2]
    fiber = enumerate_fiber(row_marg, col_marg)
    print(f"   fiber with row sums {row_marg}, col sums {col_marg}")
    print(f"   contains {len(fiber)} tables.")
    # Verify every ordered pair is connectable and report the longest path.
    longest = 0
    worst: Tuple[Table, Table] = (fiber[0], fiber[0])
    for a in fiber:
        for b in fiber:
            moves = connect(a, b)
            if len(moves) > longest:
                longest, worst = len(moves), (a, b)
    print(f"   all {len(fiber) ** 2} ordered pairs are connected.")
    print(f"   greedy connector used at most {longest} moves; an extremal pair:")
    show(worst[0], "      from:")
    show(worst[1], "      to:")
    moves = connect(worst[0], worst[1])
    print(f"      via moves: {moves}")
    print(f"      L1 distance D = {l1_distance(worst[0], worst[1])} "
          f"(each aligned move drops D by 2 or 4)\n")


# ===========================================================================
# DEMO 5 — A random walk (MCMC sampler) explores a fiber (Algorithm B)
# ===========================================================================
def demo_random_walk() -> None:
    import random

    print("=" * 70)
    print("DEMO 5: Random basic-move walk samples a fiber (irreducibility)")
    print("=" * 70)
    random.seed(2024)
    start: Table = [
        [4, 0, 0],
        [0, 0, 4],
    ]
    m, n = len(start), len(start[0])
    fiber = enumerate_fiber(row_sums(start), col_sums(start))
    visited = set()
    cur = [row[:] for row in start]
    steps = 20000
    for _ in range(steps):
        i, ip = random.sample(range(m), 2)
        j, jp = random.sample(range(n), 2)
        sign = random.choice([+1, -1])
        move = (i, ip, j, jp) if sign == 1 else (ip, i, j, jp)
        w = apply_move(cur, move)
        if is_nonneg(w):
            cur = w
        visited.add(tuple(tuple(r) for r in cur))
    print(f"   fiber size              = {len(fiber)}")
    print(f"   distinct tables visited = {len(visited)} in {steps} random moves")
    print(f"   walk reached all tables? {len(visited) == len(fiber)}")
    print("   (irreducibility is exactly the Fundamental Theorem of Markov Bases)\n")


# ===========================================================================
def main() -> None:
    demo_margin_invariance()
    demo_pigeonhole()
    demo_distance_decrease()
    demo_fiber_connectivity()
    demo_random_walk()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()


"""
Visualization: the Markov graph of a fiber under basic 2x2 moves.

Enumerates every non-negative table with fixed margins, draws one vertex per
table, and connects two vertices by an edge whenever they differ by a single
basic 2x2 swap move.  The resulting graph is exactly the object whose
connectivity is the Fundamental Theorem of Markov Bases for the two-way
independence model: this picture should always be a single connected component.

Requires: matplotlib, networkx.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

import matplotlib.pyplot as plt
import networkx as nx

Table = Tuple[Tuple[int, ...], ...]


def row_sums(u: Table) -> Tuple[int, ...]:
    return tuple(sum(r) for r in u)


def col_sums(u: Table) -> Tuple[int, ...]:
    m, n = len(u), len(u[0])
    return tuple(sum(u[i][j] for i in range(m)) for j in range(n))


def enumerate_fiber(row_marg: List[int], col_marg: List[int]) -> List[Table]:
    m, n = len(row_marg), len(col_marg)
    out: List[Table] = []

    def bt(k: int, u: List[List[int]]) -> None:
        if k == m * n:
            if list(row_sums(tuple(map(tuple, u)))) == row_marg and \
               list(col_sums(tuple(map(tuple, u)))) == col_marg:
                out.append(tuple(tuple(r) for r in u))
            return
        i, j = divmod(k, n)
        cap = row_marg[i] - sum(u[i][:j])
        for v in range(max(cap, 0) + 1):
            u[i][j] = v
            bt(k + 1, u)
        u[i][j] = 0

    bt(0, [[0] * n for _ in range(m)])
    return out


def differs_by_basic_move(a: Table, b: Table) -> bool:
    """True iff b = a + B(i,i',j,j') for some basic 2x2 move (degree-4 difference)."""
    m, n = len(a), len(a[0])
    diff = [(i, j, b[i][j] - a[i][j]) for i in range(m) for j in range(n)
            if a[i][j] != b[i][j]]
    if len(diff) != 4:
        return False
    plus = sorted((i, j) for i, j, d in diff if d == 1)
    minus = sorted((i, j) for i, j, d in diff if d == -1)
    if len(plus) != 2 or len(minus) != 2:
        return False
    rows = {i for i, _ in plus + minus}
    cols = {j for _, j in plus + minus}
    return len(rows) == 2 and len(cols) == 2


def build_and_draw(row_marg: List[int], col_marg: List[int]) -> None:
    fiber = enumerate_fiber(row_marg, col_marg)
    G = nx.Graph()
    for t in fiber:
        G.add_node(t)
    for a in fiber:
        for b in fiber:
            if a < b and differs_by_basic_move(a, b):
                G.add_edge(a, b)

    pos = nx.spring_layout(G, seed=7)
    plt.figure(figsize=(9, 7))
    nx.draw_networkx_edges(G, pos, alpha=0.4)
    nx.draw_networkx_nodes(G, pos, node_color="#3b6ea5", node_size=600)
    labels = {t: "\n".join(" ".join(map(str, r)) for r in t) for t in fiber}
    nx.draw_networkx_labels(G, pos, labels, font_size=7, font_color="white")
    plt.title(
        f"Markov graph of the fiber  (rows {row_marg}, cols {col_marg})\n"
        f"{G.number_of_nodes()} tables, {G.number_of_edges()} basic-move edges, "
        f"connected = {nx.is_connected(G)}"
    )
    plt.axis("off")
    plt.tight_layout()
    plt.savefig("markov_graph.png", dpi=150)
    print("Saved markov_graph.png")


if __name__ == "__main__":
    build_and_draw([3, 3], [2, 2, 2])
