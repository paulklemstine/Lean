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
