"""Visualize logical compression P A P as a heatmap for a rank-1 basis
code, showing that a diagonal operator collapses to a single scalar
multiple of the projector (one bright pixel)."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

Matrix = np.ndarray


def main() -> None:
    dim, k = 6, 2
    P = np.zeros((dim, dim), dtype=complex)
    P[k, k] = 1.0
    D = np.diag(np.arange(1, dim + 1).astype(complex))   # diag(1,2,...,6)
    PAP = P @ D @ P

    fig, axes = plt.subplots(1, 2, figsize=(10, 4))
    for ax, M, title in ((axes[0], D, "operator D = diag(1..6)"),
                         (axes[1], PAP, f"compression P D P = {D[k,k].real:.0f} * P")):
        ax.imshow(np.abs(M), cmap="viridis")
        ax.set_title(title)
        ax.set_xticks(range(dim)); ax.set_yticks(range(dim))
    plt.suptitle("Detectability on the basis code |2><2|: collapse to a scalar")
    plt.tight_layout()
    plt.savefig("eastin_knill_compression.png", dpi=150)
    print("saved eastin_knill_compression.png")


if __name__ == "__main__":
    main()
