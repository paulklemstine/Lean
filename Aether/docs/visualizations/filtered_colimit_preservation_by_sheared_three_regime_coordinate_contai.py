"""Visualization: coordinate-containment heatmaps for the three regimes."""
from __future__ import annotations
from typing import Sequence
import numpy as np
import matplotlib.pyplot as plt


def containment_matrix(f: Sequence[int], max_stage: int) -> np.ndarray:
    return np.array([[1 if 0 <= f[k] <= M else 0 for k in range(len(f))]
                     for M in range(max_stage + 1)])


def main() -> None:
    max_stage = 12
    examples = [
        (list(range(5)) + [0] * 3, "Finite tuple — commutes"),
        (list(range(13)), "Identity sequence — FAILS"),
        ([3, 7, 2] + [0] * 10, "Eventually-0 (sheared) — commutes"),
    ]
    fig, axes = plt.subplots(1, 3, figsize=(13, 4))
    for ax, (f, title) in zip(axes, examples):
        mat = containment_matrix(f, max_stage)
        ax.imshow(mat, aspect="auto", cmap="Greens", origin="lower", vmin=0, vmax=1)
        full = np.where(mat.all(axis=1))[0]
        if full.size:
            ax.axhline(full[0], color="crimson", lw=2)
            ax.set_title(f"{title}\n(first full stage M={full[0]})", fontsize=9)
        else:
            ax.set_title(f"{title}\n(no single stage)", fontsize=9)
        ax.set_xlabel("coordinate k"); ax.set_ylabel("stage M")
    fig.suptitle("Coordinate containment across stages S_M = {0,...,M}")
    fig.tight_layout(); fig.savefig("regimes_heatmap.png", dpi=130)
    print("wrote regimes_heatmap.png")


if __name__ == "__main__":
    main()
