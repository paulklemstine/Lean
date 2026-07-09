"""
Visualization of the Berggren ternary tree of primitive Pythagorean triples,
drawn via the linear lift on Euclid generator pairs (m, n) rooted at (2, 1):

    A: (m, n) -> (2m - n, m)
    B: (m, n) -> (2m + n, m)
    C: (m, n) -> (m + 2n, n)
    q(m, n) = (m^2 - n^2, 2mn, m^2 + n^2)

Produces 'berggren_tree.png': nodes labelled by their primitive triple, edges
coloured by branch (A red, B green, C blue), laid out by tree depth.

Run:  python visualize.py
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

Pair = Tuple[int, int]


def param_map(branch: str, m: int, n: int) -> Pair:
    if branch == "A":
        return (2 * m - n, m)
    if branch == "B":
        return (2 * m + n, m)
    return (m + 2 * n, n)  # C


def euclid_triple(m: int, n: int) -> Tuple[int, int, int]:
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def build_layout(max_depth: int) -> Tuple[Dict[Pair, Tuple[float, float]],
                                          List[Tuple[Pair, Pair, str]]]:
    """Assign (x, y) positions level by level; return node coords and edges."""
    colors = {"A": "A", "B": "B", "C": "C"}
    levels: List[List[Pair]] = [[(2, 1)]]
    edges: List[Tuple[Pair, Pair, str]] = []
    for _ in range(max_depth):
        nxt: List[Pair] = []
        for node in levels[-1]:
            for br in ("A", "B", "C"):
                child = param_map(br, *node)
                edges.append((node, child, colors[br]))
                nxt.append(child)
        levels.append(nxt)
    pos: Dict[Pair, Tuple[float, float]] = {}
    for depth, row in enumerate(levels):
        k = len(row)
        for i, node in enumerate(row):
            x = (i + 0.5) / k
            pos[node] = (x, -depth)
    return pos, edges


def main() -> None:
    max_depth = 3
    pos, edges = build_layout(max_depth)
    branch_color = {"A": "#d62728", "B": "#2ca02c", "C": "#1f77b4"}

    fig, ax = plt.subplots(figsize=(14, 8))
    for parent, child, br in edges:
        (x0, y0), (x1, y1) = pos[parent], pos[child]
        ax.plot([x0, x1], [y0, y1], color=branch_color[br], lw=1.5, alpha=0.7, zorder=1)

    for (m, n), (x, y) in pos.items():
        a, b, c = euclid_triple(m, n)
        ax.scatter([x], [y], s=20, color="black", zorder=2)
        ax.annotate(f"({a},{b},{c})", (x, y), fontsize=7, ha="center",
                    va="bottom", xytext=(0, 4), textcoords="offset points")

    handles = [plt.Line2D([0], [0], color=branch_color[b], lw=2,
                          label=f"branch {b}") for b in ("A", "B", "C")]
    ax.legend(handles=handles, loc="lower right")
    ax.set_title("Berggren tree of primitive Pythagorean triples "
                 "(lifted linear maps on Euclid seeds, root (3,4,5))")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("berggren_tree.png", dpi=150)
    print("wrote berggren_tree.png")


if __name__ == "__main__":
    main()
