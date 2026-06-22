"""Hasse diagrams of the two orders of Belnap's FOUR, side by side.

Renders the truth order (F < N,B < T) and the knowledge order (N < F,T < B)
as the famous "double diamond", highlighting that they are perpendicular.
Requires matplotlib.  Run:  python3 four_orders.py
"""
from __future__ import annotations
import matplotlib.pyplot as plt

# (x, y) layout for each value in each diamond
TRUTH = {"F": (0, 0), "N": (-1, 1), "B": (1, 1), "T": (0, 2)}
TRUTH_EDGES = [("F", "N"), ("F", "B"), ("N", "T"), ("B", "T")]

KNOW = {"N": (0, 0), "F": (-1, 1), "T": (1, 1), "B": (0, 2)}
KNOW_EDGES = [("N", "F"), ("N", "T"), ("F", "B"), ("T", "B")]

COLOR = {"N": "#9aa0a6", "F": "#d93025", "T": "#1a73e8", "B": "#9334e6"}

def draw(ax, pos, edges, title: str) -> None:
    for a, b in edges:
        (x1, y1), (x2, y2) = pos[a], pos[b]
        ax.plot([x1, x2], [y1, y2], color="#bbb", lw=2, zorder=1)
    for v, (x, y) in pos.items():
        ax.scatter([x], [y], s=1600, color=COLOR[v], zorder=2)
        ax.text(x, y, v, ha="center", va="center", color="white",
                fontsize=18, fontweight="bold", zorder=3)
    ax.set_title(title, fontsize=14)
    ax.set_xlim(-1.8, 1.8); ax.set_ylim(-0.5, 2.5); ax.axis("off")

fig, (axL, axR) = plt.subplots(1, 2, figsize=(11, 5))
draw(axL, TRUTH, TRUTH_EDGES, "Truth order  ≤_t   (F at bottom, T at top)")
draw(axR, KNOW, KNOW_EDGES, "Knowledge order  ≤_k   (N at bottom, B at top)")
fig.suptitle("Belnap's FOUR: two perpendicular lattice orders (a bilattice)",
             fontsize=15)
fig.tight_layout()
fig.savefig("four_orders.png", dpi=140)
print("wrote four_orders.png")
