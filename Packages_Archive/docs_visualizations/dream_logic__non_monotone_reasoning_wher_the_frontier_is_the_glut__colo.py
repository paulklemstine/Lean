"""
Visualization: The Contradiction Set as a Frontier
==================================================

Plots a closed interval [0,1] on the real line together with its
paraconsistent valuation:
  - green  : interior points  (value `true`,  robustly inside)
  - red    : exterior points  (value `false`, robustly outside)
  - gold   : frontier points  (value `both`,  the gluts / dialetheias)

This illustrates the bridge theorem `val_both_iff_frontier`: a point is a
glut exactly when it lies on the boundary of the set.

Run:  python3 _viz.py    (saves dream_logic_frontier.png)
Requires matplotlib and numpy.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def belnap_value(x: float, a: float = 0.0, b: float = 1.0) -> str:
    """Pointwise valuation of [a, b]: 'true', 'false', or 'both'."""
    if a < x < b:
        return "true"
    if x < a or x > b:
        return "false"
    return "both"


def main() -> None:
    a, b = 0.0, 1.0
    xs = np.linspace(-0.6, 1.6, 4001)
    colors = {"true": "#2e7d32", "false": "#c62828", "both": "#f9a825"}

    fig, ax = plt.subplots(figsize=(11, 2.6))
    for x in xs:
        v = belnap_value(float(x), a, b)
        ax.plot([x], [0], marker="|", markersize=24,
                color=colors[v], alpha=0.6)

    # Mark the two frontier gluts explicitly.
    for fx in (a, b):
        ax.plot([fx], [0], marker="o", markersize=14,
                color=colors["both"], markeredgecolor="black", zorder=5)
        ax.annotate("glut (both)", (fx, 0.0), textcoords="offset points",
                    xytext=(0, 18), ha="center", fontsize=10, weight="bold")

    ax.set_yticks([])
    ax.set_xlabel("real line")
    ax.set_title("Dream Logic: valuation of the closed interval [0,1]\n"
                 "interior = true (green), exterior = false (red), "
                 "frontier = both (gold)")
    handles = [plt.Line2D([0], [0], color=c, lw=6, label=k)
               for k, c in colors.items()]
    ax.legend(handles=handles, loc="upper center", ncol=3, frameon=False,
              bbox_to_anchor=(0.5, -0.35))
    fig.tight_layout()
    fig.savefig("dream_logic_frontier.png", dpi=150, bbox_inches="tight")
    print("Saved dream_logic_frontier.png")


if __name__ == "__main__":
    main()
