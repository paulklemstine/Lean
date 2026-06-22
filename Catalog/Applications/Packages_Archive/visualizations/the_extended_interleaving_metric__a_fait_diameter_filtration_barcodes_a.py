"""
Visualization: Stability of the Vietoris-Rips diameter filtration.

Generates a figure with two panels:
  (left)  The birth-scale barcodes of two diameter filtrations built from
          slightly perturbed distance matrices, side by side.
  (right) The extended interleaving distance estimate as a function of the
          perturbation epsilon, overlaid with the certified 1-Lipschitz upper
          bound ofReal(epsilon) -- illustrating Theorems 5.1/6.1.

Requires: matplotlib, numpy.  Run:  python _viz.py
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence

import matplotlib.pyplot as plt
import numpy as np

Simplex = FrozenSet[int]
WeightTable = Dict[Simplex, float]
Matrix = Sequence[Sequence[float]]


def diam_weight_of(d: Matrix, sigma: Simplex) -> float:
    vals: List[float] = [0.0]
    for x in sigma:
        for y in sigma:
            vals.append(d[x][y])
    return max(vals)


def diam_filtration_of(d: Matrix, n: int) -> WeightTable:
    table: WeightTable = {}
    for k in range(1, n + 1):
        for verts in combinations(range(n), k):
            table[frozenset(verts)] = diam_weight_of(d, frozenset(verts))
    return table


def cloud(n: int, off_diag: float) -> List[List[float]]:
    return [[0.0 if i == j else off_diag for j in range(n)] for i in range(n)]


def sup_matrix_distance(d1: Matrix, d2: Matrix, n: int) -> float:
    return max(abs(d1[i][j] - d2[i][j]) for i in range(n) for j in range(n))


def is_interleaved(F: WeightTable, G: WeightTable, delta: float,
                   grid: Sequence[float]) -> bool:
    if delta < 0:
        return False
    simplices = set(F) | set(G)
    for t in grid:
        for s in simplices:
            wf, wg = F.get(s, math.inf), G.get(s, math.inf)
            if wf <= t and not wg <= t + delta:
                return False
            if wg <= t and not wf <= t + delta:
                return False
    return True


def e_interleaving_dist(F: WeightTable, G: WeightTable,
                        step: float = 1e-3) -> float:
    births = sorted({b for b in list(F.values()) + list(G.values())
                     if math.isfinite(b)})
    grid = births if births else [0.0]
    delta = 0.0
    while delta <= 50.0:
        if is_interleaved(F, G, delta, grid):
            return delta
        delta += step
    return math.inf


def main() -> None:
    n = 3
    base = cloud(n, 1.0)
    F = diam_filtration_of(base, n)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: barcodes for base vs perturbed
    pert = cloud(n, 1.1)
    G = diam_filtration_of(pert, n)
    rows = sorted(set(F) | set(G), key=lambda z: (len(z), sorted(z)))
    for i, s in enumerate(rows):
        ax1.plot([F[s], 5], [i + 0.15] * 2, lw=4, color="#2c7fb8",
                 label="cloud (side 1.0)" if i == 0 else None)
        ax1.plot([G[s], 5], [i - 0.15] * 2, lw=4, color="#de2d26",
                 label="cloud (side 1.1)" if i == 0 else None)
    ax1.set_yticks(range(len(rows)))
    ax1.set_yticklabels([str(sorted(s)) for s in rows])
    ax1.set_xlabel("birth scale t")
    ax1.set_title("Diameter-filtration barcodes (shifted by <= 0.1)")
    ax1.legend()

    # Panel 2: estimated distance vs certified bound
    eps_vals = np.linspace(0.0, 1.0, 21)
    est, bound = [], []
    for e in eps_vals:
        Gp = diam_filtration_of(cloud(n, 1.0 + e), n)
        est.append(e_interleaving_dist(F, Gp, step=1e-2))
        bound.append(sup_matrix_distance(base, cloud(n, 1.0 + e), n))
    ax2.plot(eps_vals, bound, "--", color="#000000",
             label="certified bound ofReal(eps)")
    ax2.plot(eps_vals, est, "o-", color="#31a354",
             label="estimated eInterleavingDist")
    ax2.set_xlabel("perturbation eps")
    ax2.set_ylabel("extended interleaving distance")
    ax2.set_title("Stability: distance <= ofReal(eps)  (Thm 5.1/6.1)")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("interleaving_stability.png", dpi=150)
    print("saved interleaving_stability.png")


if __name__ == "__main__":
    main()
