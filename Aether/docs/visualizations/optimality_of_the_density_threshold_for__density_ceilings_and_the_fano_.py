"""
Visualization: the linear-hypergraph density threshold and its Steiner witnesses.

Produces a two-panel figure:

  (Left)  The density ceiling m <= C(n,2)/C(r,2) as a function of n for several
          edge sizes r, with Steiner-admissible orders (where equality is
          achievable) marked as filled dots sitting exactly on the curve.

  (Right) The pair-coverage matrix of the Fano plane S(2,3,7): a 7x7 grid whose
          (i,j) cell is shaded by the (unique) block covering the pair {i,j},
          visually certifying that every pair is covered exactly once.

Run:  python3 _viz.py   ->  writes density_threshold.png
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def steiner_admissible(n: int, r: int) -> bool:
    return (n - 1) % (r - 1) == 0 and (n * (n - 1)) % (r * (r - 1)) == 0


def fano_plane() -> List[FrozenSet[int]]:
    blocks = [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6},
        {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5},
    ]
    return [frozenset(b) for b in blocks]


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    # ---- Left panel: density ceilings ------------------------------------ #
    ns = np.arange(3, 41)
    for r in (3, 4, 5):
        ceiling = [comb(n, 2) / comb(r, 2) for n in ns]
        ax1.plot(ns, ceiling, label=f"r = {r}:  C(n,2)/C(r,2)", linewidth=2)
        adm_n = [n for n in ns if n >= r and steiner_admissible(n, r)]
        adm_y = [comb(n, 2) / comb(r, 2) for n in adm_n]
        ax1.scatter(adm_n, adm_y, s=45, zorder=5,
                    label=f"r = {r}:  Steiner-admissible (equality)")
    ax1.set_xlabel("number of vertices  n")
    ax1.set_ylabel("max edges  m")
    ax1.set_title("Density ceiling  m \u2264 C(n,2)/C(r,2)\n"
                  "dots = Steiner systems attaining equality")
    ax1.legend(fontsize=8, loc="upper left")
    ax1.grid(alpha=0.3)

    # ---- Right panel: Fano pair-coverage matrix -------------------------- #
    blocks = fano_plane()
    n = 7
    cover: Dict[Tuple[int, int], int] = {}
    for bi, b in enumerate(blocks):
        for i, j in combinations(sorted(b), 2):
            cover[(i, j)] = bi
    M = np.full((n, n), np.nan)
    for (i, j), bi in cover.items():
        M[i, j] = bi
        M[j, i] = bi
    im = ax2.imshow(M, cmap="tab10", vmin=0, vmax=9)
    ax2.set_title("Fano plane S(2,3,7): every pair covered once\n"
                  "cell {i,j} colored by its unique covering block")
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xlabel("vertex j")
    ax2.set_ylabel("vertex i")
    for i in range(n):
        for j in range(n):
            if not np.isnan(M[i, j]):
                ax2.text(j, i, str(int(M[i, j])), ha="center", va="center",
                         color="white", fontsize=8)
    fig.colorbar(im, ax=ax2, label="block index (0..6)", shrink=0.8)

    fig.tight_layout()
    fig.savefig("density_threshold.png", dpi=150)
    print("wrote density_threshold.png")


if __name__ == "__main__":
    main()
