"""
Visualization: certified ceiling vs. true signless Laplacian spectral radius.

For each dimension r in {1,2,3,4} we plot, for a single r-simplex, the exact
spectral radius q_{r-1} = r+1 against the certified ceiling (r+1)*Delta = r+1,
illustrating sharpness (simplex_specRad). We also overlay the complete graphs
K_n (r=1) showing q(K_n) = 2(n-1) = 2*Delta, the tight classical bound.

Requires matplotlib and numpy.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, List

import numpy as np
import matplotlib.pyplot as plt


def spectral_radius(facets: List[FrozenSet[int]]) -> float:
    ridges = sorted({r for f in facets for r in f})
    idx = {r: i for i, r in enumerate(ridges)}
    B = np.zeros((len(ridges), len(facets)))
    for j, f in enumerate(facets):
        for r in f:
            B[idx[r], j] = 1.0
    Q = B @ B.T
    return float(np.max(np.linalg.eigvalsh(Q))) if Q.size else 0.0


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: simplex sharpness.
    rs = list(range(1, 6))
    q_simplex = [spectral_radius([frozenset(range(r + 1))]) for r in rs]
    ceiling = [r + 1 for r in rs]
    ax1.plot(rs, ceiling, "o--", label="ceiling $(r+1)\\,\\Delta$", color="crimson")
    ax1.plot(rs, q_simplex, "s-", label="$q_{r-1}$ (simplex)", color="navy")
    ax1.set_xlabel("dimension $r$")
    ax1.set_ylabel("spectral radius")
    ax1.set_title("Sharpness on the simplex: $q_{r-1}=r+1$")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: complete graphs K_n.
    ns = list(range(2, 8))
    q_kn = [spectral_radius([frozenset(e) for e in combinations(range(n), 2)]) for n in ns]
    two_delta = [2 * (n - 1) for n in ns]
    ax2.plot(ns, two_delta, "o--", label="$2\\Delta(K_n)$", color="crimson")
    ax2.plot(ns, q_kn, "s-", label="$q(K_n)$", color="navy")
    ax2.set_xlabel("vertices $n$")
    ax2.set_ylabel("spectral radius")
    ax2.set_title("Graph case ($r=1$): $q(K_n)=2\\Delta$")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Signless Laplacian spectral radius vs. certified ceiling")
    fig.tight_layout()
    fig.savefig("signless_laplacian_bounds.png", dpi=150)
    print("saved signless_laplacian_bounds.png")


if __name__ == "__main__":
    main()
