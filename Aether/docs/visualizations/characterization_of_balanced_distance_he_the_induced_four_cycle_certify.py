import matplotlib.pyplot as plt
from itertools import combinations

def main() -> None:
    cyc = [0, 2, 1, 3]
    pos = {0: (0, 1), 2: (1, 0), 1: (0, -1), 3: (-1, 0), 4: (2, 1), 5: (2, -1)}
    fig, ax = plt.subplots(figsize=(6, 6))
    # all octahedron edges faint
    for u, v in combinations(range(6), 2):
        if u // 2 != v // 2:
            ax.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]],
                    color="#dddddd", lw=1, zorder=1)
    # cycle edges bold
    for i in range(4):
        u, v = cyc[i], cyc[(i + 1) % 4]
        ax.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]],
                color="#d62728", lw=3, zorder=2)
    # diagonals (non-edges) dashed
    for u, v in [(0, 1), (2, 3)]:
        ax.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]],
                color="#1f77b4", lw=2, ls="--", zorder=2)
    for v in range(6):
        ax.scatter(*pos[v], s=500, color="#333333", zorder=3)
        ax.text(*pos[v], str(v), ha="center", va="center", color="white", zorder=4)
    ax.set_title("Induced C4 on (0,2,1,3): red = cycle edges, dashed = non-edges")
    ax.set_aspect("equal"); ax.axis("off")
    plt.tight_layout(); plt.savefig("induced_c4.png", dpi=150)
    print("saved induced_c4.png")

if __name__ == "__main__":
    main()
