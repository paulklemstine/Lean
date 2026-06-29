"""
visualize.py — Visualize skew conference and Hadamard matrices as +-1 / 0 grids.

Standalone: uses matplotlib only. Renders, for a prime q = 3 (mod 4):
  (left)  the skew conference matrix C of order q+1   (blue=-1, white=0, red=+1)
  (right) the Hadamard matrix H = I + C of order q+1  (blue=-1, red=+1)

Run:  python3 visualize.py
Saves: hadamard_paley.png
"""

from __future__ import annotations

from typing import List, Set

import matplotlib.pyplot as plt
import numpy as np

Matrix = List[List[int]]


def quadratic_residues(q: int) -> Set[int]:
    return {(x * x) % q for x in range(1, q)}


def chi(x: int, q: int, qr: Set[int]) -> int:
    r = x % q
    return 0 if r == 0 else (1 if r in qr else -1)


def bordered_conference(q: int) -> Matrix:
    qr = quadratic_residues(q)
    Q = [[chi(a - b, q, qr) for b in range(q)] for a in range(q)]
    n = q + 1
    C = [[0] * n for _ in range(n)]
    for j in range(1, n):
        C[0][j] = 1
    for i in range(1, n):
        C[i][0] = -1
    for i in range(1, n):
        for j in range(1, n):
            C[i][j] = Q[i - 1][j - 1]
    return C


def add_identity(C: Matrix) -> Matrix:
    n = len(C)
    return [[C[i][j] + (1 if i == j else 0) for j in range(n)] for i in range(n)]


def main(q: int = 11) -> None:
    C = bordered_conference(q)
    H = add_identity(C)
    fig, axes = plt.subplots(1, 2, figsize=(11, 5))
    for ax, M, title in (
        (axes[0], C, f"Skew conference C (order {q + 1})"),
        (axes[1], H, f"Hadamard H = I + C (order {q + 1})"),
    ):
        ax.imshow(np.array(M), cmap="RdBu", vmin=-1, vmax=1)
        ax.set_title(title)
        ax.set_xticks([]); ax.set_yticks([])
    fig.suptitle(f"Paley I core for q = {q}:  C*C = (1 - n)I  ->  H*H^T = n I",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("hadamard_paley.png", dpi=150)
    print("saved hadamard_paley.png")


if __name__ == "__main__":
    main(11)
