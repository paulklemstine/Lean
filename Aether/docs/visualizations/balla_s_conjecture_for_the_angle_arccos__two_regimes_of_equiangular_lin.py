"""Visualization: growth of the absolute bound d^2 versus Balla's conjectured
linear ceiling max(28, 2(d-1)) for equiangular lines at angle arccos(1/3).

Requires matplotlib. Saves 'equiangular_bounds.png'.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def absolute_bound(d: int) -> int:
    """The unconditional absolute bound N <= d^2."""
    return d * d


def balla_third_bound(d: int) -> int:
    """Balla's conjectured sharp bound for alpha = 1/3: max(28, 2(d-1))."""
    return max(28, 2 * (d - 1))


def main() -> None:
    dims: List[int] = list(range(1, 41))
    absolute = [absolute_bound(d) for d in dims]
    balla = [balla_third_bound(d) for d in dims]

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.plot(dims, absolute, "o-", label=r"absolute bound $N \leq d^2$", color="#c0392b")
    ax.plot(dims, balla, "s-", label=r"Balla $\max(28, 2(d-1))$", color="#2980b9")
    ax.set_xlabel("dimension $d$", fontsize=12)
    ax.set_ylabel("maximum number of equiangular lines", fontsize=12)
    ax.set_title(r"Equiangular lines at angle $\arccos(1/3)$: two regimes", fontsize=13)
    ax.set_yscale("log")
    ax.legend(fontsize=11)
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("equiangular_bounds.png", dpi=150)
    print("saved equiangular_bounds.png")


if __name__ == "__main__":
    main()
