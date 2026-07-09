import matplotlib.pyplot as plt
from itertools import combinations
import math

def main() -> None:
    # place six vertices on a circle for a clear drawing
    n = 6
    pos = {v: (math.cos(2*math.pi*v/n), math.sin(2*math.pi*v/n)) for v in range(n)}
    pairs = [(0, 1), (2, 3), (4, 5)]
    colors = ["#e6194B", "#3cb44b", "#4363d8"]
    fig, ax = plt.subplots(figsize=(6, 6))
    # edges: different pairs
    for u, v in combinations(range(n), 2):
        if u // 2 != v // 2:
            ax.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]],
                    color="#999999", lw=1, zorder=1)
    # non-edges (matched pairs), dashed
    for k, (u, v) in enumerate(pairs):
        ax.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]],
                color=colors[k], lw=2.5, ls="--", zorder=2)
    for v in range(n):
        k = v // 2
        ax.scatter(*pos[v], s=600, color=colors[k], zorder=3, edgecolors="black")
        ax.text(*pos[v], str(v), ha="center", va="center",
                fontsize=13, color="white", zorder=4)
    ax.set_title("Octahedron co(3K2): solid = edges, dashed = unique non-neighbors")
    ax.set_aspect("equal"); ax.axis("off")
    plt.tight_layout(); plt.savefig("octahedron.png", dpi=150)
    print("saved octahedron.png")

if __name__ == "__main__":
    main()
