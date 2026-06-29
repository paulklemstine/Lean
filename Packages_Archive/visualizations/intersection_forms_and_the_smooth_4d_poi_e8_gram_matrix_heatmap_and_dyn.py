"""Visualization: the E8 Dynkin diagram and Gram-matrix heatmap.

Renders (1) the E8 Cartan/Gram matrix as an annotated heatmap and (2) the
E8 Dynkin diagram whose Cartan matrix it is, side by side, saving to
`e8_form.png`.  Requires matplotlib.
"""
from typing import List
import matplotlib.pyplot as plt

E8: List[List[int]] = [
    [2, -1, 0, 0, 0, 0, 0, 0],
    [-1, 2, -1, 0, 0, 0, 0, 0],
    [0, -1, 2, -1, 0, 0, 0, 0],
    [0, 0, -1, 2, -1, 0, 0, 0],
    [0, 0, 0, -1, 2, -1, 0, -1],
    [0, 0, 0, 0, -1, 2, -1, 0],
    [0, 0, 0, 0, 0, -1, 2, 0],
    [0, 0, 0, 0, -1, 0, 0, 2],
]


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # Heatmap of the Gram matrix.
    ax1.imshow(E8, cmap="coolwarm", vmin=-2, vmax=2)
    for i in range(8):
        for j in range(8):
            ax1.text(j, i, str(E8[i][j]), ha="center", va="center",
                     color="black", fontsize=11)
    ax1.set_title("E8 Gram matrix (even diagonal = 2, det = 1)")
    ax1.set_xticks(range(8)); ax1.set_yticks(range(8))

    # Dynkin diagram of E8: a chain of 7 nodes with one node hanging off node 5.
    pos = {0: (0, 0), 1: (1, 0), 2: (2, 0), 3: (3, 0),
           4: (4, 0), 5: (5, 0), 6: (6, 0), 7: (4, 1)}
    edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (4, 7)]
    for a, b in edges:
        xa, ya = pos[a]; xb, yb = pos[b]
        ax2.plot([xa, xb], [ya, yb], "k-", zorder=1)
    for node, (x, y) in pos.items():
        ax2.scatter([x], [y], s=600, c="#3b6ea5", zorder=2)
        ax2.text(x, y, str(node), ha="center", va="center", color="white")
    ax2.set_title("E8 Dynkin diagram")
    ax2.axis("equal"); ax2.axis("off")

    fig.suptitle("E8: the even unimodular form that no smooth 4-manifold realizes",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("e8_form.png", dpi=150)
    print("wrote e8_form.png")


if __name__ == "__main__":
    main()
