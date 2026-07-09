"""
Visualization: the exchange rate between girth and optimal expansion.

Draws three small left-2-regular bipartite graphs side by side and annotates
each with its maximum pairwise neighbor-overlap, whether it has a 4-cycle
(girth < 6), and whether it is a 2-optimal small-set expander.  This makes
visible the strict chain  optimal (share 0)  <  girth>=6 (share <=1).

Requires: matplotlib.   Run:  python visualization.py
"""
from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Tuple

import matplotlib.pyplot as plt

Graph = Dict[int, FrozenSet[int]]


def max_overlap(g: Graph) -> int:
    return max((len(g[u] & g[v]) for u, v in combinations(g, 2)), default=0)


def draw(ax, g: Graph, title: str) -> None:
    lefts = sorted(g)
    rights = sorted({r for u in g for r in g[u]})
    lx, rx = 0.0, 1.0
    ly = {u: 1.0 - i / max(1, len(lefts) - 1) for i, u in enumerate(lefts)}
    ry = {r: 1.0 - i / max(1, len(rights) - 1) for i, r in enumerate(rights)}
    for u in lefts:
        for r in g[u]:
            ax.plot([lx, rx], [ly[u], ry[r]], color="#888", lw=1.2, zorder=1)
    for u in lefts:
        ax.scatter([lx], [ly[u]], s=320, color="#2c7fb8", zorder=2)
        ax.text(lx - 0.08, ly[u], f"u{u}", ha="right", va="center")
    for r in rights:
        ax.scatter([rx], [ry[r]], s=320, color="#de2d26", zorder=2)
        ax.text(rx + 0.08, ry[r], f"w{r}", ha="left", va="center")
    ov = max_overlap(g)
    ax.set_title(f"{title}\nmax overlap={ov}  4-cycle={ov>=2}  "
                 f"optimal={ov==0}", fontsize=9)
    ax.set_xlim(-0.4, 1.4)
    ax.set_ylim(-0.2, 1.2)
    ax.axis("off")


def main() -> None:
    graphs: List[Tuple[str, Graph]] = [
        ("disjoint stars", {0: frozenset({0, 1}), 1: frozenset({2, 3})}),
        ("counterexample", {0: frozenset({0, 1}), 1: frozenset({1, 2})}),
        ("4-cycle", {0: frozenset({0, 1}), 1: frozenset({0, 1})}),
    ]
    fig, axes = plt.subplots(1, 3, figsize=(12, 4))
    for ax, (title, g) in zip(axes, graphs):
        draw(ax, g, title)
    fig.suptitle("Girth vs. optimal expansion: share 0 (optimal) "
                 "< share <=1 (girth>=6)", fontsize=11)
    fig.tight_layout()
    fig.savefig("girth_expansion.png", dpi=150)
    print("wrote girth_expansion.png")


if __name__ == "__main__":
    main()
