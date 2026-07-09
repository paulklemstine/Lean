import matplotlib.pyplot as plt
import numpy as np

def visualize_chord_arcs(n: int = 14, a: int = 1, b: int = 8) -> None:
    ang = [2 * np.pi * v / n for v in range(n)]
    xs = [np.cos(t) for t in ang]; ys = [np.sin(t) for t in ang]
    fig, ax = plt.subplots(figsize=(6, 6))
    for v in range(n):
        w = (v + 1) % n
        ax.plot([xs[v], xs[w]], [ys[v], ys[w]], color="lightgray", lw=1, zorder=1)
    # forward arc a->b in blue
    k = (b - a) % n
    for j in range(k):
        v, w = (a + j) % n, (a + j + 1) % n
        ax.plot([xs[v], xs[w]], [ys[v], ys[w]], color="tab:blue", lw=3, zorder=2)
    ax.plot([xs[a], xs[b]], [ys[a], ys[b]], color="tab:red", lw=2.5,
            ls="--", zorder=3, label=f"chord (span {k})")
    ax.scatter(xs, ys, s=120, color="white", edgecolor="black", zorder=4)
    for v in range(n):
        ax.text(xs[v], ys[v], str(v), ha="center", va="center", zorder=5)
    ax.set_title(f"n={n}: forward arc length {k+1}, backward {n-k+1}, sum {n+2}")
    ax.set_aspect("equal"); ax.axis("off"); ax.legend()
    plt.tight_layout(); plt.savefig("chord_arcs.png", dpi=150)

if __name__ == "__main__":
    visualize_chord_arcs()
