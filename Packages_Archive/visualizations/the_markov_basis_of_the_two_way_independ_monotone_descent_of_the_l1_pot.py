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
