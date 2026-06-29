"""Visualize Hodge diamonds and the mirror reflection of the E-polynomial.

Produces a two-panel figure:
  (left)  the Hodge diamonds of the quintic threefold and its mirror, drawn as
          rotated grids with the h^{p,q} entries annotated;
  (right) the E-polynomial coefficient arrays as heatmaps, showing that the
          mirror reflects the p-axis.
Requires matplotlib + numpy.
"""
import numpy as np
import matplotlib.pyplot as plt


def diamond_array(n, h):
    A = np.zeros((n + 1, n + 1), dtype=int)
    for (p, q), val in h.items():
        A[p, q] = val
    return A


def mirror_h(n, h):
    return {(p, q): h.get((n - p, q), 0)
            for p in range(n + 1) for q in range(n + 1)}


def main():
    n = 3
    quintic = {(0, 0): 1, (3, 3): 1, (0, 3): 1, (3, 0): 1,
               (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101}
    mq = mirror_h(n, quintic)

    A = diamond_array(n, quintic)
    B = diamond_array(n, mq)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    for ax, M, title in ((axes[0], A, "Quintic  (chi = -200)"),
                         (axes[1], B, "Mirror quintic  (chi = +200)")):
        im = ax.imshow(M, cmap="viridis", origin="lower")
        for p in range(n + 1):
            for q in range(n + 1):
                ax.text(q, p, str(M[p, q]), ha="center", va="center",
                        color="white" if M[p, q] < 50 else "black", fontsize=11)
        ax.set_xlabel("q"); ax.set_ylabel("p"); ax.set_title(title)
        ax.set_xticks(range(n + 1)); ax.set_yticks(range(n + 1))
        fig.colorbar(im, ax=ax, fraction=0.046)
    fig.suptitle("Mirror symmetry reflects the p-axis: h^{p,q} -> h^{n-p,q}")
    fig.tight_layout()
    fig.savefig("hodge_mirror.png", dpi=150)
    print("wrote hodge_mirror.png")


if __name__ == "__main__":
    main()
