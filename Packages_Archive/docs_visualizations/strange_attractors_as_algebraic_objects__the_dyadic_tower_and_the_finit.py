"""Visualization: the dyadic tower of denominators and the escapee witness.

Renders, with matplotlib, (a) the dyadic rationals in [0,1) grouped by their
2-adic denominator level, showing how each new level 1/2^n introduces points no
finite earlier level can reach, and (b) a bar chart contrasting the finite ranks
beta_1 of nerve graphs (finitely generated H^1 = Z^{beta_1}) with the
"unbounded" denominator growth of the dyadic solenoid's H^1 = Z[1/2].
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt


def dyadics_at_level(n: int) -> List[Fraction]:
    """Dyadic rationals in [0,1) whose reduced denominator is exactly 2^n."""
    if n == 0:
        return [Fraction(0, 1)]
    return [Fraction(k, 2 ** n) for k in range(1, 2 ** n, 2)]


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    levels = 6
    for n in range(levels):
        xs = [float(q) for q in dyadics_at_level(n)]
        ys = [n] * len(xs)
        ax1.scatter(xs, ys, s=40, label=f"den 2^{n}" if n < 4 else None)
    ax1.set_title("Dyadic tower Z[1/2] in [0,1):\neach level adds points no finite set below it can reach")
    ax1.set_xlabel("value")
    ax1.set_ylabel("2-adic level n  (denominator 2^n)")
    ax1.set_yticks(range(levels))
    ax1.legend(loc="upper right", fontsize=8)
    ax1.grid(True, alpha=0.3)

    graphs = [("K_{3,3}", 4), ("K_4", 3), ("CHSH", 1), ("tree", 0)]
    names = [g[0] for g in graphs] + ["solenoid\nZ[1/2]"]
    ranks = [g[1] for g in graphs] + [None]
    colors = ["#3a7bd5"] * len(graphs) + ["#d54a3a"]
    xpos = range(len(names))
    heights = [r if r is not None else 8 for r in ranks]
    bars = ax2.bar(xpos, heights, color=colors)
    bars[-1].set_hatch("///")
    ax2.set_xticks(list(xpos))
    ax2.set_xticklabels(names)
    ax2.set_ylabel("rank of H^1 (number of generators)")
    ax2.set_title("Finite graphs: H^1 = Z^{beta_1} (finite, f.g.)\nSolenoid: Z[1/2] needs infinitely many generators")
    ax2.annotate("infinite\n(not f.g.)", xy=(len(graphs), 8),
                 xytext=(len(graphs) - 0.3, 6.0), ha="center", color="#d54a3a")
    ax2.grid(True, axis="y", alpha=0.3)

    fig.tight_layout()
    fig.savefig("dyadic_solenoid_viz.png", dpi=150)
    print("wrote dyadic_solenoid_viz.png")


if __name__ == "__main__":
    main()
