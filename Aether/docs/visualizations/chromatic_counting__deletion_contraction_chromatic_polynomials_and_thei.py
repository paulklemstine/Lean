"""
Visualization: chromatic polynomials and the tropical (log) envelope.

Generates two panels:
  (left)  the chromatic polynomial P(G, k) for several graph families, showing
          how the edgeless graph gives k^n and the complete graph gives the
          falling factorial, with paths/cycles in between;
  (right) the tropicalization log P(G, k) vs log k, exhibiting the convex,
          piecewise-linear envelope with integer slopes 0,1,...,|V|.

Self-contained; requires only numpy and matplotlib.
"""

from __future__ import annotations

import itertools
import math
from typing import FrozenSet, List, Set, Tuple

import matplotlib.pyplot as plt
import numpy as np

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


def complete_graph(n: int) -> Graph:
    return (n, frozenset(frozenset({u, v}) for u in range(n) for v in range(u + 1, n)))


def cycle_graph(n: int) -> Graph:
    return (n, frozenset(frozenset({i, (i + 1) % n}) for i in range(n)))


def path_graph(n: int) -> Graph:
    return (n, frozenset(frozenset({i, i + 1}) for i in range(n - 1)))


def edgeless_graph(n: int) -> Graph:
    return (n, frozenset())


def is_proper(graph: Graph, coloring: Tuple[int, ...]) -> bool:
    _, edges = graph
    return all(coloring[a] != coloring[b] for e in edges for a, b in [tuple(e)])


def chrom_count(graph: Graph, k: int) -> int:
    n, _ = graph
    if k <= 0:
        return 1 if n == 0 else 0
    return sum(1 for c in itertools.product(range(k), repeat=n) if is_proper(graph, c))


def main() -> None:
    families = [
        ("edgeless (k^4)", edgeless_graph(4)),
        ("path P4", path_graph(4)),
        ("cycle C4", cycle_graph(4)),
        ("cycle C5 (odd)", cycle_graph(5)),
        ("complete K4", complete_graph(4)),
    ]
    ks = list(range(1, 9))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for name, g in families:
        ys = [chrom_count(g, k) for k in ks]
        ax1.plot(ks, ys, "o-", label=name)
    ax1.set_title("Chromatic polynomial P(G, k)")
    ax1.set_xlabel("number of colors k")
    ax1.set_ylabel("proper colorings P(G, k)")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    for name, g in families:
        xs, ys = [], []
        for k in ks:
            c = chrom_count(g, k)
            if c > 0:
                xs.append(math.log(k))
                ys.append(math.log(c))
        ax2.plot(xs, ys, "s-", label=name)
    ax2.set_title("Tropicalization: log P(G, k) vs log k\n(piecewise-linear, integer slopes)")
    ax2.set_xlabel("log k")
    ax2.set_ylabel("log P(G, k)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("chromatic_visualization.png", dpi=140)
    print("saved chromatic_visualization.png")


if __name__ == "__main__":
    main()
