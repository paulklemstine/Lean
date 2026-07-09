"""Visualise a 3-colouring of a graph, highlighting failing (monochromatic) edges."""
import matplotlib.pyplot as plt
import math


def plot_coloring() -> None:
    # 5-cycle with one improper edge (0,1 share a colour).
    n = 5
    edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]
    coloring = {0: 0, 1: 0, 2: 1, 3: 2, 4: 1}
    palette = ["#e74c3c", "#2ecc71", "#3498db"]
    pos = {i: (math.cos(2 * math.pi * i / n), math.sin(2 * math.pi * i / n))
           for i in range(n)}
    fig, ax = plt.subplots()
    for (u, v) in edges:
        bad = coloring[u] == coloring[v]
        ax.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]],
                color="red" if bad else "gray",
                lw=3 if bad else 1.2, zorder=1)
    for i in range(n):
        ax.scatter(*pos[i], s=600, color=palette[coloring[i]], zorder=2,
                   edgecolors="black")
        ax.annotate(str(i), pos[i], ha="center", va="center")
    ax.set_title("Improper 3-colouring: red edge is the caught challenge")
    ax.set_aspect("equal")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("coloring.png", dpi=150)


if __name__ == "__main__":
    plot_coloring()
