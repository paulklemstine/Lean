"""
Visualization of Belnap's FOUR: the double Hasse diamond.

Draws the four values N, F, T, B as a diamond and overlays both orders:
  * the KNOWLEDGE order (bottom N -> top B), read vertically;
  * the TRUTH order (left F -> right T), read horizontally.
Negation is the left-right reflection (T <-> F); conflation is the
up-down reflection (N <-> B). Saves 'belnap_diamond.png'.

Requires: matplotlib.  Run:  python visualize.py
"""

from __future__ import annotations

from typing import Dict, Tuple

import matplotlib.pyplot as plt


def main() -> None:
    # Diamond coordinates: x = truth axis, y = knowledge axis.
    pos: Dict[str, Tuple[float, float]] = {
        "N": (0.0, -1.0),   # knowledge bottom (told nothing)
        "F": (-1.0, 0.0),   # truth bottom    (told false)
        "T": (1.0, 0.0),    # truth top       (told true)
        "B": (0.0, 1.0),    # knowledge top   (told both)
    }
    colors = {"N": "#9aa0a6", "F": "#4285f4", "T": "#34a853", "B": "#ea4335"}
    labels = {"N": "N\n(told nothing)", "F": "F\n(told false)",
              "T": "T\n(told true)", "B": "B\n(told both)"}

    knowledge_edges = [("N", "F"), ("N", "T"), ("F", "B"), ("T", "B")]

    fig, ax = plt.subplots(figsize=(7, 7))

    for a, b in knowledge_edges:
        (x0, y0), (x1, y1) = pos[a], pos[b]
        ax.plot([x0, x1], [y0, y1], color="#222", lw=1.5, zorder=1)

    for v, (x, y) in pos.items():
        ax.scatter([x], [y], s=2600, c=colors[v], edgecolors="black",
                   linewidths=1.5, zorder=2)
        ax.text(x, y, labels[v], ha="center", va="center",
                fontsize=11, fontweight="bold", color="white", zorder=3)

    # Axis annotations
    ax.annotate("knowledge order  <=_k", xy=(0, 1.35), ha="center",
                fontsize=12, fontweight="bold", color="#ea4335")
    ax.annotate("(more information up)", xy=(0, 1.2), ha="center",
                fontsize=9, color="#ea4335")
    ax.annotate("truth order  <=_t  (more true right)", xy=(0, -1.45),
                ha="center", fontsize=12, fontweight="bold", color="#34a853")

    ax.annotate("", xy=(0, 1.05), xytext=(0, -1.05),
                arrowprops=dict(arrowstyle="->", color="#ea4335", lw=1, ls=":"))
    ax.annotate("", xy=(1.05, 0), xytext=(-1.05, 0),
                arrowprops=dict(arrowstyle="->", color="#34a853", lw=1, ls=":"))

    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Belnap's FOUR as the bilattice 2 (x) 2\n"
                 "negation = left/right flip,  conflation = up/down flip",
                 fontsize=12)

    fig.tight_layout()
    fig.savefig("belnap_diamond.png", dpi=150)
    print("Saved belnap_diamond.png")


if __name__ == "__main__":
    main()
