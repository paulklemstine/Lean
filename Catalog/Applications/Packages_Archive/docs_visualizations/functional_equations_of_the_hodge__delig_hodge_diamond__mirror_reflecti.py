"""
Visualization: the Hodge diamond, its mirror, and the functional-equation check.

Renders, for a chosen example diamond, three panels:
  (1) the Hodge diamond h^{p,q} as a tilted heat grid;
  (2) the mirror diamond (mirror X)^{p,q} = X^{n-p,q};
  (3) a bar chart of |E(mirror X; u,v) - (-1)^n u^n E(X; 1/u, v)| at sample
      points, which is identically zero (Theorem 2).

Produces 'hodge_epolynomial_functional_equations.png'. Requires matplotlib.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

HodgeNumbers = Dict[Tuple[int, int], int]


def hpq(h: HodgeNumbers, p: int, q: int) -> int:
    return h.get((p, q), 0)


def mirror(n: int, h: HodgeNumbers) -> HodgeNumbers:
    return {(p, q): hpq(h, n - p, q)
            for p in range(n + 1) for q in range(n + 1)
            if hpq(h, n - p, q)}


def epoly(n: int, h: HodgeNumbers, u: Fraction, v: Fraction) -> Fraction:
    tot = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            sign = -1 if (p + q) % 2 else 1
            tot += sign * hpq(h, p, q) * (u ** p) * (v ** q)
    return tot


def grid(n: int, h: HodgeNumbers) -> np.ndarray:
    return np.array([[hpq(h, p, q) for q in range(n + 1)]
                     for p in range(n + 1)], dtype=float)


def main() -> None:
    # K3 surface as the showcase (n = 2).
    n = 2
    h: HodgeNumbers = {(0, 0): 1, (2, 0): 1, (0, 2): 1, (2, 2): 1, (1, 1): 20}
    hm = mirror(n, h)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    for ax, data, title in (
        (axes[0], grid(n, h), "Hodge diamond  $h^{p,q}$ (K3 surface)"),
        (axes[1], grid(n, hm), "Mirror diamond  $(\\mathrm{mirror}\\,X)^{p,q}$"),
    ):
        im = ax.imshow(data, cmap="viridis", origin="lower")
        for p in range(n + 1):
            for q in range(n + 1):
                ax.text(q, p, f"{int(data[p, q])}", ha="center", va="center",
                        color="white", fontsize=12, fontweight="bold")
        ax.set_xlabel("q")
        ax.set_ylabel("p")
        ax.set_xticks(range(n + 1))
        ax.set_yticks(range(n + 1))
        ax.set_title(title, fontsize=11)
        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    pts: List[Tuple[Fraction, Fraction]] = [
        (Fraction(2), Fraction(3)), (Fraction(5, 2), Fraction(-7, 3)),
        (Fraction(-3), Fraction(4)), (Fraction(1, 4), Fraction(9, 5)),
        (Fraction(7, 3), Fraction(-1, 2)),
    ]
    sign = -1 if n % 2 else 1
    residuals = []
    labels = []
    for i, (u, v) in enumerate(pts):
        lhs = epoly(n, hm, u, v)
        rhs = sign * (u ** n) * epoly(n, h, 1 / u, v)
        residuals.append(float(abs(lhs - rhs)))
        labels.append(f"pt{i+1}")

    axes[2].bar(labels, residuals, color="#c0392b")
    axes[2].set_ylim(-0.5, 1.0)
    axes[2].axhline(0, color="black", linewidth=0.8)
    axes[2].set_title("$|E(\\mathrm{mirror}\\,X) - (-1)^n u^n E(X;1/u,v)|$\n"
                      "(Theorem 2: identically 0)", fontsize=10)
    axes[2].set_ylabel("residual")

    fig.suptitle("Hodge--Deligne E-polynomial: mirror functional equation",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("hodge_epolynomial_functional_equations.png", dpi=150)
    print("wrote hodge_epolynomial_functional_equations.png")


if __name__ == "__main__":
    main()
