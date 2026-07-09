"""Visualization: opposite semicubes of Q_3 and the antipode matching between them."""
import matplotlib.pyplot as plt
from itertools import product

def main() -> None:
    n = 3
    verts = [tuple(b) for b in product((0, 1), repeat=n)]
    i = 0  # slice along coordinate 0
    left = [v for v in verts if v[i] == 0]
    right = [v for v in verts if v[i] == 1]
    fig, ax = plt.subplots(figsize=(8, 5))
    for k, v in enumerate(left):
        ax.text(0, k, "".join(map(str, v)), ha="center", va="center",
                bbox=dict(boxstyle="round", fc="#cde"))
    for k, v in enumerate(right):
        ax.text(3, k, "".join(map(str, v)), ha="center", va="center",
                bbox=dict(boxstyle="round", fc="#edc"))
    for k, v in enumerate(left):
        av = tuple(1 - b for b in v)
        j = right.index(av)
        ax.plot([0.3, 2.7], [k, j], "k-", alpha=0.5)
    ax.set_xlim(-1, 4); ax.set_ylim(-1, len(left))
    ax.set_title("Antipode matching S_0^0 <-> S_0^1 in Q_3")
    ax.axis("off")
    plt.tight_layout(); plt.savefig("semicube_matching.png", dpi=140)
    print("saved semicube_matching.png")

if __name__ == "__main__":
    main()
