"""Visualization: the metric ladder and the stability bound.

Generates two panels:
  (1) The Vietoris-Rips persistence "barcode" sketch of two point clouds and how
      a shift delta interleaves them.
  (2) The 1-Lipschitz stability line: estimated interleaving distance vs.
      sup-norm distortion of the distance matrix, lying on or below y = x.

Requires only matplotlib + numpy.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def diam_weight(d: Dict[Tuple[int, int], float], sigma: Tuple[int, ...]) -> float:
    best = 0.0
    for x, y in combinations(sigma, 2):
        best = max(best, d[(x, y)])
    return best


def matrix(n: int, off: float) -> Dict[Tuple[int, int], float]:
    return {(i, j): (0.0 if i == j else off) for i in range(n) for j in range(n)}


def edges(n: int) -> List[Tuple[int, int]]:
    return list(combinations(range(n), 2))


def main() -> None:
    n = 3
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: edge birth scales for two clouds (off-diagonal 1.0 vs 1.1).
    d1, d2 = matrix(n, 1.0), matrix(n, 1.1)
    e = edges(n)
    b1 = [diam_weight(d1, s) for s in e]
    b2 = [diam_weight(d2, s) for s in e]
    y = np.arange(len(e))
    ax1.hlines(y - 0.12, 0, b1, color="#2563eb", lw=6, label="cloud 1 (births)")
    ax1.hlines(y + 0.12, 0, b2, color="#dc2626", lw=6, label="cloud 2 (births)")
    ax1.set_yticks(y)
    ax1.set_yticklabels([f"edge {s}" for s in e])
    ax1.set_xlabel("birth scale t")
    ax1.set_title("Vietoris-Rips births: a 0.1-interleaving")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # Panel 2: 1-Lipschitz stability — distance <= distortion.
    eps_grid = np.linspace(0, 1, 50)
    est = []
    for eps in eps_grid:
        da, db = matrix(n, 1.0), matrix(n, 1.0 + eps)
        # estimated interleaving distance = sup-norm distortion (tight here)
        dist = max(abs(da[(i, j)] - db[(i, j)]) for i in range(n) for j in range(n))
        est.append(dist)
    ax2.plot(eps_grid, eps_grid, "--", color="gray", label="y = x (1-Lipschitz bound)")
    ax2.plot(eps_grid, est, color="#16a34a", lw=2.5, label="interleaving distance")
    ax2.set_xlabel("sup-norm distortion of distance matrix")
    ax2.set_ylabel("interleaving distance")
    ax2.set_title("Stability: persistence is 1-Lipschitz in the data")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("interleaving_quotient_viz.png", dpi=150)
    print("Saved interleaving_quotient_viz.png")


if __name__ == "__main__":
    main()
