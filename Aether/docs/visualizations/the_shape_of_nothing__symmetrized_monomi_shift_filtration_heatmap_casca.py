"""Visualize the shift filtration: how the nonzero band of a product of
strictly upper triangular matrices marches off the diagonal until it vanishes.

Produces a grid of heatmaps, one per partial product M_1, M_1 M_2, ...,
M_1...M_n, showing the support (nonzero entries) shrinking with each factor.
Requires matplotlib + numpy.
"""
from typing import List
import numpy as np
import matplotlib.pyplot as plt


def strict_upper(n: int, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    a = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            a[i, j] = int(rng.integers(1, 6))
    return a


def main() -> None:
    n = 6
    mats: List[np.ndarray] = [strict_upper(n, seed=s) for s in range(n)]
    partials: List[np.ndarray] = []
    acc = np.eye(n, dtype=int)
    for m in mats:
        acc = acc @ m
        partials.append(acc.copy())

    fig, axes = plt.subplots(1, n, figsize=(2.4 * n, 2.6))
    for k, (ax, P) in enumerate(zip(axes, partials), start=1):
        ax.imshow((P != 0).astype(int), cmap="viridis", vmin=0, vmax=1)
        ax.set_title(f"product of {k}\n(shift {k})", fontsize=9)
        ax.set_xticks([]); ax.set_yticks([])
    fig.suptitle("Shift filtration: nonzero band marches off the diagonal "
                 f"(n = {n}); the n-th product is zero", fontsize=11)
    fig.tight_layout()
    fig.savefig("shift_filtration.png", dpi=140)
    print("wrote shift_filtration.png")


if __name__ == "__main__":
    main()
