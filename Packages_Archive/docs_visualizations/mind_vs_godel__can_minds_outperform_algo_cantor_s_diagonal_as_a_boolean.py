"""
Visualization: Cantor's diagonal as a grid flip.

Renders a random Boolean evaluation matrix e[a][x], highlights the main
diagonal e[x][x], and overlays the flipped diagonal d(x) = NOT e[x][x] -- the
row that cannot appear in the matrix, proving non-surjectivity.

Run:  python viz_diagonal.py   (requires matplotlib, numpy)
"""
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    rng = np.random.default_rng(7)
    n = 8
    e = rng.integers(0, 2, size=(n, n))
    diag = np.array([e[i, i] for i in range(n)])
    flipped = 1 - diag

    fig, ax = plt.subplots(figsize=(6, 6))
    ax.imshow(e, cmap="Blues", vmin=0, vmax=1)
    for i in range(n):
        ax.add_patch(plt.Rectangle((i - 0.5, i - 0.5), 1, 1, fill=False,
                                   edgecolor="#d7301f", lw=2.5))
    ax.set_title("Cantor diagonal: flip the red diagonal to build a row\n"
                 "d(x) = NOT e[x][x] that no name realises")
    ax.set_xlabel("argument x")
    ax.set_ylabel("name a")
    plt.tight_layout()
    plt.savefig("cantor_diagonal.png", dpi=150)
    print("flipped diagonal d =", flipped.tolist())
    print("wrote cantor_diagonal.png")


if __name__ == "__main__":
    main()
