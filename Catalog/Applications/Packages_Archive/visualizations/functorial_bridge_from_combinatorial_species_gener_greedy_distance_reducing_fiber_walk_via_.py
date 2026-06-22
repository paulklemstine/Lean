from __future__ import annotations
from typing import List, Optional, Tuple

Table = List[List[int]]


def basic_move(m: int, n: int, i: int, ip: int, j: int, jp: int) -> Table:
    """B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}."""
    b = [[0] * n for _ in range(m)]
    b[i][jp] += 1
    b[ip][j] += 1
    b[i][j] -= 1
    b[ip][jp] -= 1
    return b


def find_good_indices(u: Table, v: Table) -> Optional[Tuple[int, int, int, int]]:
    """Three-stage sign-pattern pigeonhole; None iff u == v."""
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]
    c1 = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if c1 is None:
        return None
    i, j = c1
    jp = next(c for c in range(n) if d[i][c] < 0)   # row i sums to 0
    ip = next(r for r in range(m) if d[r][jp] > 0)  # column j' sums to 0
    return i, ip, j, jp


def greedy_connect(u: Table, v: Table) -> List[Tuple[int, int, int, int]]:
    """Return the list of 2x2 swaps (i,i',j,j') connecting u to v.

    Precondition: u, v non-negative with equal margins. Each swap strictly
    decreases the L1 distance and preserves non-negativity, so the loop
    terminates in at most D(u, v) iterations.
    """
    m, n = len(u), len(u[0])
    cur = [row[:] for row in u]
    moves: List[Tuple[int, int, int, int]] = []
    while cur != v:
        idx = find_good_indices(cur, v)
        assert idx is not None
        i, ip, j, jp = idx
        b = basic_move(m, n, i, ip, j, jp)
        cur = [[cur[a][c] + b[a][c] for c in range(n)] for a in range(m)]
        moves.append((i, ip, j, jp))
    return moves
