"""Visualization: the rainbow-triangle floor rtBound(n) against the total
triangle count C(n,3), illustrating the verified domination rtBound(n) <= C(n,3).

Generates 'rainbow_bound.png'. Requires matplotlib.
"""

from __future__ import annotations

from math import comb
from typing import List

import matplotlib.pyplot as plt


def rt_bound(n: int) -> int:
    """ceil((n-1)(n-3)/8) over N, with truncated subtraction."""
    a: int = n - 1 if n > 1 else 0
    b: int = n - 3 if n > 3 else 0
    return (a * b + 7) // 8


def main() -> None:
    ns: List[int] = list(range(3, 41))
    bound: List[int] = [rt_bound(n) for n in ns]
    total: List[int] = [comb(n, 3) for n in ns]
    quad: List[float] = [(n - 1) * (n - 3) / 8 for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(ns, total, "o-", color="#d1495b", label=r"$\binom{n}{3}$ (total triangles)")
    ax1.plot(ns, bound, "s-", color="#2e86ab", label=r"$\mathrm{rtBound}(n)$ (floor)")
    ax1.set_xlabel("n (vertices)")
    ax1.set_ylabel("count")
    ax1.set_title("Rainbow floor stays below total triangle count")
    ax1.legend()
    ax1.grid(alpha=0.3)

    ax2.plot(ns, bound, "s-", color="#2e86ab", label=r"$\mathrm{rtBound}(n)$")
    ax2.plot(ns, quad, "--", color="#6a994e", label=r"$(n-1)(n-3)/8$ (continuous)")
    ax2.set_xlabel("n (vertices)")
    ax2.set_ylabel("rainbow-triangle lower bound")
    ax2.set_title(r"$\mathrm{rtBound}(n) = \lceil (n-1)(n-3)/8 \rceil$ grows quadratically")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.suptitle("Rainbow Triangle Density Bound", fontsize=14, fontweight="bold")
    fig.tight_layout()
    fig.savefig("rainbow_bound.png", dpi=150)
    print("Saved rainbow_bound.png")


if __name__ == "__main__":
    main()
