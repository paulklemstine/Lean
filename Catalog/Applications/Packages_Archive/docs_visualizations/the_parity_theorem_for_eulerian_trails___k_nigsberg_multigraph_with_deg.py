"""
Visualization of the Eulerian-trail parity theorem on the Koenigsberg multigraph.

Draws the four landmasses and seven bridges, annotates each vertex with its degree,
colors odd-degree vertices, and reports the Theorem E verdict.  Requires matplotlib.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

Vertex = int
Edge = Tuple[Vertex, Vertex]


def degree(ends: List[Edge], n_vertices: int) -> Dict[Vertex, int]:
    deg = {v: 0 for v in range(n_vertices)}
    for (u, w) in ends:
        deg[u] += 1
        deg[w] += 1
    return deg


def main() -> None:
    # A=0 big island, B=1 small island, N=2 north bank, S=3 south bank
    pos: Dict[Vertex, Tuple[float, float]] = {
        0: (0.0, 0.0), 1: (2.0, 0.0), 2: (1.0, 1.5), 3: (1.0, -1.5),
    }
    names = {0: "A", 1: "B", 2: "N", 3: "S"}
    ends: List[Edge] = [(0, 2), (0, 2), (0, 3), (0, 3), (0, 1), (1, 2), (1, 3)]
    deg = degree(ends, 4)

    fig, ax = plt.subplots(figsize=(7, 7))

    # Draw bridges; multiple edges get curved so they are distinguishable.
    seen: Dict[Tuple[int, int], int] = {}
    for (u, w) in ends:
        key = (min(u, w), max(u, w))
        k = seen.get(key, 0)
        seen[key] = k + 1
        rad = 0.0 if k == 0 else 0.3 * (1 if k % 2 else -1) * ((k + 1) // 2)
        arrow = FancyArrowPatch(
            pos[u], pos[w], connectionstyle=f"arc3,rad={rad}",
            arrowstyle="-", lw=2, color="#3b6ea5",
        )
        ax.add_patch(arrow)

    for v, (x, y) in pos.items():
        odd = deg[v] % 2 == 1
        ax.scatter([x], [y], s=2200,
                   color="#e2574c" if odd else "#5cb85c",
                   edgecolors="black", zorder=3)
        ax.text(x, y, f"{names[v]}\ndeg={deg[v]}",
                ha="center", va="center", fontsize=11, fontweight="bold",
                zorder=4)

    odd_count = sum(1 for v in range(4) if deg[v] % 2 == 1)
    verdict = ("NO Eulerian trail (Theorem E: %d > 2 odd vertices)" % odd_count)
    ax.set_title("Seven Bridges of Koenigsberg\n" + verdict, fontsize=13)
    ax.set_xlim(-1.2, 3.2)
    ax.set_ylim(-2.4, 2.4)
    ax.set_aspect("equal")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("koenigsberg.png", dpi=140)
    print("Saved koenigsberg.png ;", verdict)


if __name__ == "__main__":
    main()
