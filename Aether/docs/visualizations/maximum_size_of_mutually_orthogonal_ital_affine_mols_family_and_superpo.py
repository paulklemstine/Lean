"""Visualize a complete family of mutually orthogonal Italian squares.

Renders, for a prime order p, the p-1 affine squares S_a(i,j)=(a*i+j) mod p as
color-coded heatmaps, plus the superposition grid of two of them annotated with
the ordered pairs (each appearing exactly once). Requires matplotlib + numpy.

    python visualize_mols.py
"""
from typing import Dict, List
import numpy as np
import matplotlib.pyplot as plt


def affine_square(p: int, a: int) -> List[List[int]]:
    return [[(a * i + j) % p for j in range(p)] for i in range(p)]


def affine_family(p: int) -> Dict[int, List[List[int]]]:
    return {a: affine_square(p, a) for a in range(1, p)}


def main(p: int = 5) -> None:
    fam = affine_family(p)
    slopes = sorted(fam)
    ncols = len(slopes) + 1
    fig, axes = plt.subplots(1, ncols, figsize=(3.2 * ncols, 3.4))

    for ax, a in zip(axes[:-1], slopes):
        arr = np.array(fam[a])
        ax.imshow(arr, cmap="viridis")
        for i in range(p):
            for j in range(p):
                ax.text(j, i, str(arr[i, j]), ha="center", va="center", color="w")
        ax.set_title(f"$S_{{{a}}}(i,j)={a}i+j$")
        ax.set_xticks([]); ax.set_yticks([])

    # superposition of the first two squares
    L = np.array(fam[slopes[0]]); M = np.array(fam[slopes[1]])
    ax = axes[-1]
    ax.imshow(np.zeros((p, p)), cmap="Greys", vmin=0, vmax=1)
    for i in range(p):
        for j in range(p):
            ax.text(j, i, f"{L[i,j]},{M[i,j]}", ha="center", va="center", fontsize=8)
    ax.set_title(f"Superposition $S_{{{slopes[0]}}}\,/\,S_{{{slopes[1]}}}$")
    ax.set_xticks([]); ax.set_yticks([])

    fig.suptitle(f"Order {p}: {p-1} mutually orthogonal Italian squares (bound n-1)")
    fig.tight_layout()
    fig.savefig("mols_order_{}.png".format(p), dpi=150)
    print("saved mols_order_{}.png".format(p))


if __name__ == "__main__":
    main(5)
