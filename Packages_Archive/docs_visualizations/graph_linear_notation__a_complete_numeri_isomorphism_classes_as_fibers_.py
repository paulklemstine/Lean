"""
Visualization: the gln invariant separates isomorphism classes on n=4 vertices.

Produces two figures:
  (1) A histogram of adjCode values colored by gln value, showing that each
      isomorphism class (one gln value) is a contiguous fiber of labeled codes.
  (2) The canonical adjacency matrix achieving gln for a chosen 4-vertex graph.

Requires: matplotlib, numpy.
"""

from __future__ import annotations

from itertools import combinations, permutations, product
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Matrix = Tuple[Tuple[int, ...], ...]


def adj_code(g: Matrix) -> int:
    n = len(g)
    return sum((1 << (i * n + j)) for i in range(n) for j in range(n) if g[i][j])


def permute_graph(sigma: Tuple[int, ...], g: Matrix) -> Matrix:
    n = len(g)
    return tuple(tuple(g[sigma[i]][sigma[j]] for j in range(n)) for i in range(n))


def gln(g: Matrix) -> int:
    n = len(g)
    return max(adj_code(permute_graph(s, g)) for s in permutations(range(n)))


def all_graphs(n: int) -> List[Matrix]:
    pairs = list(combinations(range(n), 2))
    out: List[Matrix] = []
    for bits in product((0, 1), repeat=len(pairs)):
        m = [[0] * n for _ in range(n)]
        for (i, j), b in zip(pairs, bits):
            m[i][j] = m[j][i] = b
        out.append(tuple(tuple(r) for r in m))
    return out


def main() -> None:
    n = 4
    graphs = all_graphs(n)
    codes = np.array([adj_code(g) for g in graphs])
    glns = np.array([gln(g) for g in graphs])
    classes = sorted(set(glns.tolist()))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    cmap = plt.get_cmap("turbo", len(classes))
    for idx, gval in enumerate(classes):
        mask = glns == gval
        ax1.scatter(codes[mask], np.full(mask.sum(), idx),
                    color=cmap(idx), s=40)
    ax1.set_title(f"All {len(graphs)} labeled graphs on n={n}\n"
                  f"grouped into {len(classes)} gln classes (= A000088(4)=11)")
    ax1.set_xlabel("adjCode (labeled binary encoding)")
    ax1.set_ylabel("isomorphism class index (distinct gln value)")
    ax1.grid(True, alpha=0.3)

    # Canonical matrix of the path 0-1-2-3.
    m = [[0] * n for _ in range(n)]
    for i, j in [(0, 1), (1, 2), (2, 3)]:
        m[i][j] = m[j][i] = 1
    g: Matrix = tuple(tuple(r) for r in m)
    best_code, best = -1, tuple(range(n))
    for s in permutations(range(n)):
        c = adj_code(permute_graph(s, g))
        if c > best_code:
            best_code, best = c, s
    canon = np.array(permute_graph(best, g))
    ax2.imshow(canon, cmap="Greys", vmin=0, vmax=1)
    ax2.set_title(f"Canonical matrix of path P4\ngln = {best_code}, perm = {best}")
    ax2.set_xticks(range(n)); ax2.set_yticks(range(n))
    for i in range(n):
        for j in range(n):
            ax2.text(j, i, canon[i, j], ha="center", va="center",
                     color="red" if canon[i, j] else "black")

    fig.tight_layout()
    fig.savefig("gln_visualization.png", dpi=150)
    print("Saved gln_visualization.png")


if __name__ == "__main__":
    main()
