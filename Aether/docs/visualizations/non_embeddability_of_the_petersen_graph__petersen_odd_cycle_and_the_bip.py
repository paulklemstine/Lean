"""Standalone visualization: the Petersen graph drawn in its classic
pentagon/pentagram layout, highlighting the odd 5-cycle that certifies
non-bipartiteness, plus a checkerboard rendering of the bipartite integer
lattice host. Requires matplotlib."""
import math
from itertools import combinations
import matplotlib.pyplot as plt


def petersen_layout():
    outer = [frozenset(s) for s in [(0, 1), (2, 3), (4, 0), (1, 2), (3, 4)]]
    verts = [frozenset(s) for s in combinations(range(5), 2)]
    pos = {}
    for i, v in enumerate(outer):
        ang = math.pi / 2 + 2 * math.pi * i / 5
        pos[v] = (math.cos(ang), math.sin(ang))
    inner = [v for v in verts if v not in outer]
    for i, v in enumerate(inner):
        ang = math.pi / 2 + 2 * math.pi * i / 5
        pos[v] = (0.5 * math.cos(ang), 0.5 * math.sin(ang))
    return verts, pos


def main():
    verts, pos = petersen_layout()
    edges = [(a, b) for a, b in combinations(verts, 2) if a.isdisjoint(b)]
    cycle = [frozenset(s) for s in
             [(0, 1), (2, 3), (4, 0), (1, 2), (3, 4), (0, 1)]]
    cyc_edges = {frozenset({cycle[i], cycle[i + 1]}) for i in range(5)}

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

    for a, b in edges:
        col = "crimson" if frozenset({a, b}) in cyc_edges else "0.7"
        lw = 3 if frozenset({a, b}) in cyc_edges else 1
        ax1.plot([pos[a][0], pos[b][0]], [pos[a][1], pos[b][1]], color=col, lw=lw)
    for v, (x, y) in pos.items():
        ax1.plot(x, y, "o", ms=16, color="steelblue")
        ax1.text(x, y, "".join(map(str, sorted(v))), ha="center", va="center",
                 color="white", fontsize=8)
    ax1.set_title("Petersen graph K(5,2): odd 5-cycle (red) => not bipartite")
    ax1.set_aspect("equal"); ax1.axis("off")

    n = 6
    for i in range(n):
        for j in range(n):
            ax2.add_patch(plt.Rectangle((i, j), 1, 1,
                          color="0.85" if (i + j) % 2 else "0.35"))
    ax2.set_xlim(0, n); ax2.set_ylim(0, n); ax2.set_aspect("equal"); ax2.axis("off")
    ax2.set_title("Bipartite integer lattice: parity of coordinate sum")

    plt.tight_layout()
    plt.savefig("petersen_tropical.png", dpi=150)
    print("saved petersen_tropical.png")


if __name__ == "__main__":
    main()
