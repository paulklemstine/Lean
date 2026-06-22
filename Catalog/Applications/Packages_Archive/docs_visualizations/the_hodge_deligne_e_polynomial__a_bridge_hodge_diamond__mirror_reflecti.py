"""
Visualization: Hodge diamonds, their mirrors, and the E-polynomial coefficient
symmetry imposed by the functional equations.

Produces a figure with three panels:
  (1) the Hodge diamond of the quintic threefold as a heatmap;
  (2) its mirror (reflection of the p-index), illustrating totalDim invariance
      and the (-1)^n Euler-characteristic sign flip;
  (3) the signed E-polynomial coefficient grid c_{p,q} = (-1)^(p+q) h^{p,q},
      annotated with the Serre/Poincare palindromic symmetry c_{p,q}=c_{n-p,n-q}.

Requires matplotlib + numpy. Run:  python visualization.py
"""

from __future__ import annotations

from typing import Dict, Tuple

import numpy as np
import matplotlib.pyplot as plt


def quintic_table() -> Tuple[int, Dict[Tuple[int, int], int]]:
    n = 3
    table = {
        (0, 0): 1, (3, 3): 1,
        (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1,
        (2, 1): 101, (1, 2): 101,
    }
    return n, table


def grid(n: int, table: Dict[Tuple[int, int], int]) -> np.ndarray:
    M = np.zeros((n + 1, n + 1), dtype=int)
    for (p, q), v in table.items():
        M[p, q] = v
    return M


def mirror_grid(M: np.ndarray) -> np.ndarray:
    # mirror reflects the p (row) index: h'^{p,q} = h^{n-p,q}
    return M[::-1, :].copy()


def signed_grid(M: np.ndarray) -> np.ndarray:
    n = M.shape[0] - 1
    S = np.zeros_like(M)
    for p in range(n + 1):
        for q in range(n + 1):
            S[p, q] = ((-1) ** (p + q)) * M[p, q]
    return S


def euler_char(M: np.ndarray) -> int:
    return int(signed_grid(M).sum())


def annotate(ax, M: np.ndarray) -> None:
    n = M.shape[0] - 1
    for p in range(n + 1):
        for q in range(n + 1):
            ax.text(q, p, str(M[p, q]), ha="center", va="center",
                    color="black", fontsize=11)
    ax.set_xticks(range(n + 1))
    ax.set_yticks(range(n + 1))
    ax.set_xlabel("q")
    ax.set_ylabel("p")


def main() -> None:
    n, table = quintic_table()
    M = grid(n, table)
    Mm = mirror_grid(M)
    S = signed_grid(M)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].imshow(M, cmap="Blues")
    annotate(axes[0], M)
    axes[0].set_title(f"Quintic Hodge diamond\nchi = {euler_char(M)}, "
                      f"totalDim = {int(M.sum())}")

    axes[1].imshow(Mm, cmap="Blues")
    annotate(axes[1], Mm)
    axes[1].set_title(f"Mirror (reflect p)\nchi = {euler_char(Mm)} = (-1)^n chi, "
                      f"totalDim = {int(Mm.sum())}")

    vmax = np.abs(S).max()
    axes[2].imshow(S, cmap="RdBu", vmin=-vmax, vmax=vmax)
    annotate(axes[2], S)
    axes[2].set_title("Signed E-poly coefficients\nc_{p,q} = c_{n-p,n-q} "
                      "(Poincare palindrome)")

    fig.suptitle("Hodge-Deligne E-polynomial: mirror & Serre symmetries",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("hodge_epolynomial.png", dpi=150)
    print("Saved hodge_epolynomial.png")


if __name__ == "__main__":
    main()
