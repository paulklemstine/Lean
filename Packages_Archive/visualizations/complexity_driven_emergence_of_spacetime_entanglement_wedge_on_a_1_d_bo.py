"""Visualization: tropical entanglement wedge on a 1-D boundary/bulk layout."""
from __future__ import annotations
import matplotlib.pyplot as plt


def main() -> None:
    coord = {0: 1.0, 1: 3.0, 2: 6.0, 3: 8.0, 10: 0.0, 11: 4.0, 12: 5.0, 13: 9.0}
    d = lambda u, v: abs(coord[u] - coord[v])
    bulk, boundary, B = [0, 1, 2, 3], [10, 11, 12, 13], [10, 11]
    Bc = [b for b in boundary if b not in set(B)]
    dist = lambda S, v: min(d(v, b) for b in S)
    wedge = [v for v in bulk if dist(B, v) < dist(Bc, v)]

    fig, ax = plt.subplots(figsize=(10, 3))
    for v in bulk:
        col = "tab:green" if v in wedge else "tab:gray"
        ax.scatter(coord[v], 0.0, s=200, color=col, zorder=3)
        ax.annotate(f"v{v}", (coord[v], 0.06), ha="center")
    for b in boundary:
        col = "tab:blue" if b in set(B) else "tab:orange"
        ax.scatter(coord[b], -0.4, s=200, marker="s", color=col, zorder=3)
        ax.annotate(f"b{b}", (coord[b], -0.55), ha="center")
    ax.set_yticks([]); ax.set_title(f"Entanglement wedge of B={B}: bulk {wedge} (green)")
    fig.tight_layout(); fig.savefig("wedge.png", dpi=150)
    print("saved wedge.png  wedge =", wedge)


if __name__ == "__main__":
    main()
