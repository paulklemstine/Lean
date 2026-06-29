"""
Visualization: the Markov graph of a 2x2x2 no-three-way fiber is a PATH GRAPH,
and the corner cell is a ruler along it. Renders a fiber as beads on a string,
annotating each vertex with its corner value and drawing the unit M3 edges.

Requires: matplotlib. Run: python markov_path_viz.py
"""
from __future__ import annotations
from itertools import product
from typing import Dict, List, Tuple
import matplotlib.pyplot as plt

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def m3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def add_smul(u: Table, t: int) -> Table:
    return {c: u[c] + t * m3(*c) for c in CELLS}


def fiber(u: Table) -> List[Table]:
    lower = max(-u[c] for c in CELLS if m3(*c) == 1)
    upper = min(u[c] for c in CELLS if m3(*c) == -1)
    return [add_smul(u, t) for t in range(lower, upper + 1)]


def main() -> None:
    u = {(0, 0, 0): 2, (0, 1, 1): 2, (1, 0, 1): 2, (1, 1, 0): 2,
         (0, 0, 1): 3, (0, 1, 0): 3, (1, 0, 0): 3, (1, 1, 1): 3}
    f = fiber(u)
    corners = [t[(0, 0, 0)] for t in f]
    xs = list(range(len(f)))

    fig, ax = plt.subplots(figsize=(11, 3.2))
    ax.plot(xs, [0] * len(xs), "-", color="#888", zorder=1)
    ax.scatter(xs, [0] * len(xs), s=900, color="#3b6ea5",
               edgecolor="#163a5f", zorder=2)
    for x, c in zip(xs, corners):
        ax.text(x, 0, str(c), ha="center", va="center",
                color="white", fontsize=12, fontweight="bold", zorder=3)
        ax.text(x, -0.22, f"table\n{x}", ha="center", va="top", fontsize=8)
    for x in xs[:-1]:
        ax.text(x + 0.5, 0.12, "+M3", ha="center", fontsize=8, color="#2a7")
    ax.set_title("Markov graph of a 2x2x2 fiber is a path; numbers = corner cell "
                 "u(0,0,0)\nGraph distance(u,v) = |corner(u) - corner(v)|")
    ax.set_ylim(-0.6, 0.5)
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("markov_path.png", dpi=140)
    print("wrote markov_path.png")


if __name__ == "__main__":
    main()
