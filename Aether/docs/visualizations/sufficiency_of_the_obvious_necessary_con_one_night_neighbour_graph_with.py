"""Render the one-night neighbour graph: cycles drawn as regular polygons
with antipodal couple chords. Requires matplotlib."""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt


def draw(m: List[int]) -> None:
    fig, axes = plt.subplots(1, len(m), figsize=(4 * len(m), 4))
    if len(m) == 1:
        axes = [axes]
    for ax, mi in zip(axes, m):
        n2 = 2 * mi
        pts = [(math.cos(2 * math.pi * a / n2), math.sin(2 * math.pi * a / n2))
               for a in range(n2)]
        for a in range(n2):
            x0, y0 = pts[a]; x1, y1 = pts[(a + 1) % n2]
            ax.plot([x0, x1], [y0, y1], "b-", lw=2)              # cycle edge
            xa, ya = pts[(a + mi) % n2]
            ax.plot([x0, xa], [y0, ya], "r--", lw=1, alpha=0.6)  # couple chord
        for x, y in pts:
            ax.plot(x, y, "ko", ms=8)
        ax.set_title(f"round table size {n2}")
        ax.set_aspect("equal"); ax.axis("off")
    plt.suptitle("Blue: round-table cycle   Red dashed: antipodal couples")
    plt.tight_layout()
    plt.savefig("night_graph.png", dpi=150)
    print("wrote night_graph.png")


if __name__ == "__main__":
    draw([2, 3, 4])
