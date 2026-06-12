"""Visualization: the union law V(P (x) Q) = V(P) u V(Q) for tropical curves.

Renders three panels --- the tropical curve V(P), the tropical curve V(Q), and the
tropical curve of their product V(P (x) Q) --- showing that the last is exactly the
overlay of the first two.  Saves to 'tropical_union_law.png'.

Requires matplotlib and numpy.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

import numpy as np
import matplotlib.pyplot as plt

Monomial = Tuple[float, Tuple[float, float]]


def term_vals(monomials: List[Monomial], x: float, y: float) -> List[float]:
    return [c + ex * x + ey * y for c, (ex, ey) in monomials]


def corner_mask(monomials: List[Monomial], X: np.ndarray, Y: np.ndarray,
                tol: float) -> np.ndarray:
    """Boolean grid: True where the defining minimum is attained at least twice."""
    vals = np.stack([c + ex * X + ey * Y for c, (ex, ey) in monomials], axis=0)
    mn = vals.min(axis=0)
    near = np.abs(vals - mn) <= tol
    return near.sum(axis=0) >= 2


def trop_mul(P: List[Monomial], Q: List[Monomial]) -> List[Monomial]:
    return [(c1 + c2, (e1[0] + e2[0], e1[1] + e2[1]))
            for (c1, e1), (c2, e2) in product(P, Q)]


def main() -> None:
    P: List[Monomial] = [(0.0, (1.0, 0.0)), (0.0, (0.0, 1.0)), (0.0, (0.0, 0.0))]
    Q: List[Monomial] = [(1.0, (1.0, 0.0)), (0.0, (0.0, 0.0))]
    PQ = trop_mul(P, Q)

    n = 600
    lo, hi = -3.0, 3.0
    xs = np.linspace(lo, hi, n)
    ys = np.linspace(lo, hi, n)
    X, Y = np.meshgrid(xs, ys)
    tol = (hi - lo) / n * 1.5

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    for ax, mons, title in (
        (axes[0], P, "V(P): tropical line"),
        (axes[1], Q, "V(Q): tropical half-line"),
        (axes[2], PQ, "V(P (x) Q) = V(P) u V(Q)"),
    ):
        mask = corner_mask(mons, X, Y, tol)
        ax.imshow(mask, origin="lower", extent=(lo, hi, lo, hi),
                  cmap="Greys", interpolation="nearest")
        ax.set_title(title)
        ax.set_xlabel("x")
        ax.set_ylabel("y")
    fig.suptitle("Union law for tropical hypersurfaces", fontsize=14)
    fig.tight_layout()
    fig.savefig("tropical_union_law.png", dpi=120)
    print("saved tropical_union_law.png")


if __name__ == "__main__":
    main()
