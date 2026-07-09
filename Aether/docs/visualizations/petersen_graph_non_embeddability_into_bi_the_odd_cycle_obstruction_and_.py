"""
Visualization: the Petersen graph with its 5-cycle obstruction highlighted,
alongside a bipartite hypercube Q_3 two-colored by the parity character.
Requires matplotlib. Saves 'petersen_obstruction.png'.
"""
import math
from itertools import combinations, product
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def petersen_layout() -> Tuple[Dict, List[Tuple]]:
    outer = [frozenset(c) for c in [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]]
    inner = [frozenset(c) for c in [(0, 2), (1, 3), (2, 4), (3, 0), (4, 1)]]
    pos: Dict = {}
    for i, v in enumerate(outer):
        a = math.pi / 2 + 2 * math.pi * i / 5
        pos[v] = (math.cos(a), math.sin(a))
    for i, v in enumerate(inner):
        a = math.pi / 2 + 2 * math.pi * i / 5
        pos[v] = (0.5 * math.cos(a), 0.5 * math.sin(a))
    verts = [frozenset(c) for c in combinations(range(5), 2)]
    edges = [(u, v) for u, v in combinations(verts, 2) if u.isdisjoint(v)]
    return pos, edges


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

    pos, edges = petersen_layout()
    for u, v in edges:
        ax1.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]], color="0.7", zorder=1)
    # highlight one odd 5-cycle
    cyc = [frozenset(c) for c in [(0, 1), (2, 3), (0, 4), (1, 2), (3, 4)]]
    for i in range(len(cyc)):
        u, v = cyc[i], cyc[(i + 1) % len(cyc)]
        if u.isdisjoint(v):
            ax1.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]],
                     color="crimson", lw=2.5, zorder=2)
    for v, (x, y) in pos.items():
        ax1.scatter([x], [y], s=260, color="steelblue", zorder=3)
        ax1.text(x, y, "".join(map(str, sorted(v))), color="white",
                 ha="center", va="center", fontsize=9, zorder=4)
    ax1.set_title("Petersen graph: an odd 5-cycle (red) forces 3 colors")
    ax1.axis("off"); ax1.set_aspect("equal")

    # Q_3 two-colored by parity
    k = 3
    coords = list(product([0, 1], repeat=k))
    def p3(v): return (v[0] + v[1] * 1.6 + 0.4 * v[2], v[1] + 0.4 * v[2])
    for a in coords:
        for b in coords:
            if sum(x != y for x, y in zip(a, b)) == 1 and a < b:
                xa, ya = p3(a); xb, yb = p3(b)
                ax2.plot([xa, xb], [ya, yb], color="0.7", zorder=1)
    for v in coords:
        x, y = p3(v)
        col = "darkorange" if sum(v) % 2 else "seagreen"
        ax2.scatter([x], [y], s=320, color=col, zorder=2)
        ax2.text(x, y, "".join(map(str, v)), color="white",
                 ha="center", va="center", fontsize=8, zorder=3)
    ax2.set_title("Hypercube Q_3: bipartite via parity character")
    ax2.axis("off"); ax2.set_aspect("equal")

    fig.tight_layout()
    fig.savefig("petersen_obstruction.png", dpi=140)
    print("saved petersen_obstruction.png")


if __name__ == "__main__":
    main()
