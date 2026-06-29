"""Visualize the chain semiring: max (addition) and min (multiplication) tables.

Generates a side-by-side heatmap of the Cayley tables for the finite chain
semiring on C_n = {0, ..., n}, highlighting idempotence on the diagonal and
the inverted multiplicative unit (the top row/column of the min table).

Run:  python _visualization.py   (writes chain_semiring_tables.png)
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def build_tables(n: int) -> tuple[np.ndarray, np.ndarray]:
    """Return the (n+1)x(n+1) max and min Cayley tables for C_n."""
    size = n + 1
    add_tbl = np.zeros((size, size), dtype=int)
    mul_tbl = np.zeros((size, size), dtype=int)
    for i in range(size):
        for j in range(size):
            add_tbl[i, j] = max(i, j)
            mul_tbl[i, j] = min(i, j)
    return add_tbl, mul_tbl


def plot_tables(n: int = 7, filename: str = "chain_semiring_tables.png") -> None:
    """Render and save the addition (max) and multiplication (min) tables."""
    add_tbl, mul_tbl = build_tables(n)
    fig, axes = plt.subplots(1, 2, figsize=(12, 5.5))

    for ax, tbl, title, cmap in (
        (axes[0], add_tbl, r"Addition  $x \oplus y = \max(x,y)$", "viridis"),
        (axes[1], mul_tbl, r"Multiplication  $x \otimes y = \min(x,y)$", "magma"),
    ):
        im = ax.imshow(tbl, cmap=cmap, origin="upper")
        ax.set_title(title, fontsize=13)
        ax.set_xticks(range(n + 1))
        ax.set_yticks(range(n + 1))
        ax.set_xlabel("y")
        ax.set_ylabel("x")
        for i in range(n + 1):
            for j in range(n + 1):
                ax.text(j, i, str(tbl[i, j]), ha="center", va="center",
                        color="white", fontsize=9)
        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    fig.suptitle(
        f"Finite Chain Semiring on C_{n} = " + "{0, ..., " + str(n) + "}\n"
        "0 = ⊥ is the additive identity;  ⊤ = " + str(n)
        + " is the multiplicative identity",
        fontsize=14,
    )
    fig.tight_layout(rect=(0, 0, 1, 0.92))
    fig.savefig(filename, dpi=150)
    print(f"saved {filename}")


if __name__ == "__main__":
    plot_tables(7)
