"""Visualize the extremal block coloring witnessing R(T_n,K_k) > (k-1)(n-1)."""
from itertools import combinations
import matplotlib.pyplot as plt
import numpy as np


def visualize_block_coloring(k: int = 4, n: int = 4) -> None:
    s, b = n - 1, k - 1
    N = b * s
    # place each block on its own circle cluster
    pos = {}
    for blk in range(b):
        cx, cy = np.cos(2 * np.pi * blk / b) * 3, np.sin(2 * np.pi * blk / b) * 3
        for j in range(s):
            ang = 2 * np.pi * j / s
            pos[blk * s + j] = (cx + np.cos(ang), cy + np.sin(ang))

    fig, ax = plt.subplots(figsize=(8, 8))
    for u, v in combinations(range(N), 2):
        x0, y0 = pos[u]
        x1, y1 = pos[v]
        if u // s == v // s:
            ax.plot([x0, x1], [y0, y1], color="crimson", lw=1.4, alpha=0.9)
        else:
            ax.plot([x0, x1], [y0, y1], color="royalblue", lw=0.25, alpha=0.25)
    for v, (x, y) in pos.items():
        ax.plot(x, y, "o", color="black", ms=8)
    ax.set_title(f"Block coloring: k={k}, n={n}, N=(k-1)(n-1)={N}\n"
                 f"red = {b} cliques of size {s} (no n-vertex tree), "
                 f"blue = complete {b}-partite (no K_{k})")
    ax.set_aspect("equal")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("block_coloring.png", dpi=150)
    print("saved block_coloring.png")


if __name__ == "__main__":
    visualize_block_coloring()
