"""Visualization 2: The active-sites generating tree (m fixed).

Draws the first few levels of the active-sites generating tree, annotating each
node with its label. Nodes are placed by a simple recursive layout.
"""
from typing import List, Tuple
import matplotlib.pyplot as plt

def sites_rule(m: int, k: int) -> List[int]:
    return list(range(1, m * k + 2))

def main(m: int = 1, max_depth: int = 3) -> None:
    fig, ax = plt.subplots(figsize=(11, 6))
    positions = {}

    def layout(label: int, depth: int, x0: float, x1: float, parent: Tuple[float, float]):
        x = (x0 + x1) / 2.0
        y = -depth
        ax.scatter([x], [y], s=260, zorder=3, color="#3b6ea5")
        ax.text(x, y, str(label), ha="center", va="center", color="white", zorder=4, fontsize=8)
        if parent is not None:
            ax.plot([parent[0], x], [parent[1], y], color="#999", zorder=1)
        if depth < max_depth:
            kids = sites_rule(m, label)
            w = (x1 - x0) / max(len(kids), 1)
            for i, c in enumerate(kids):
                layout(c, depth + 1, x0 + i * w, x0 + (i + 1) * w, (x, y))

    layout(1, 0, 0.0, 1.0, None)
    ax.set_title(f"Active-sites generating tree (m = {m}) to depth {max_depth}")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("tree.png", dpi=150)
    print("wrote tree.png")

if __name__ == "__main__":
    main()
