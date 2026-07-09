"""
visualize.py -- Visualizations for the blown-up crown Crown(w, m).

Produces two figures:
  1. A Hasse-style diagram of Crown(w, m) showing the 2w stacks of m clones and
     the cross relations a(i) -> b(i+1).
  2. A log-log plot of the strict-alternating-cycle count m^{2w} against the
     poset size n = 2wm, exhibiting the slope-2w power law (Theta(n^{2w})).

Requires: matplotlib, numpy.  Run:  python3 visualize.py
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def hasse_diagram(w: int = 3, m: int = 2) -> None:
    """Draw the cover relations of Crown(w, m)."""
    fig, ax = plt.subplots(figsize=(2.2 * w, 5))
    # Position: each column i has an 'a' stack (lower, y in [0,1]) and a 'b' stack
    # (upper, y in [2,3]).  x-coordinate separates columns; a/b offset slightly.
    pos = {}
    for i in range(w):
        for j in range(m):
            pos[(i, False, j)] = (3 * i, 0.0 + 0.7 * j)          # a stack
            pos[(i, True, j)] = (3 * i + 1.0, 2.6 + 0.7 * j)     # b stack

    # chain covers within stacks
    for i in range(w):
        for s in (False, True):
            for j in range(m - 1):
                x0, y0 = pos[(i, s, j)]
                x1, y1 = pos[(i, s, j + 1)]
                ax.plot([x0, x1], [y0, y1], color="0.6", lw=1)
    # cross covers a(i) -> b(i+1): draw min-to-max representative to avoid clutter
    for i in range(w):
        x0, y0 = pos[(i, False, m - 1)]
        x1, y1 = pos[((i + 1) % w, True, 0)]
        ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                    arrowprops=dict(arrowstyle="->", color="crimson", lw=1.5,
                                    connectionstyle="arc3,rad=0.2"))

    for (i, s, j), (x, y) in pos.items():
        color = "#1f77b4" if not s else "#ff7f0e"
        ax.scatter([x], [y], s=140, color=color, zorder=3, edgecolor="k")
        label = f"{'b' if s else 'a'}{i},{j}"
        ax.text(x, y, label, ha="center", va="center", fontsize=6, color="white",
                zorder=4)

    ax.set_title(f"Blown-up crown Crown(w={w}, m={m})  ({2*w*m} elements, width {w})")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("crown_hasse.png", dpi=150)
    print("wrote crown_hasse.png")


def power_law_plot(w_values: List[int] = [2, 3, 4]) -> None:
    """Log-log plot of cycle count m^{2w} vs n = 2wm for several widths."""
    fig, ax = plt.subplots(figsize=(7, 5))
    ms = np.arange(1, 40)
    for w in w_values:
        n = 2 * w * ms
        cycles = ms.astype(float) ** (2 * w)
        ax.loglog(n, cycles, marker="o", ms=3, label=f"w = {w}  (slope {2*w})")
    ax.set_xlabel("poset size  n = 2wm")
    ax.set_ylabel("strict alternating cycles  = $m^{2w}$")
    ax.set_title("Cycle count grows as $\\Theta(n^{2w})$ (log-log: slope $2w$)")
    ax.legend()
    ax.grid(True, which="both", ls=":", alpha=0.5)
    fig.tight_layout()
    fig.savefig("crown_power_law.png", dpi=150)
    print("wrote crown_power_law.png")


if __name__ == "__main__":
    hasse_diagram(w=3, m=2)
    power_law_plot([2, 3, 4])
