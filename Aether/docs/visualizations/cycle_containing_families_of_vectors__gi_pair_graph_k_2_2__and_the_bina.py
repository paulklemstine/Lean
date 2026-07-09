"""Visualization: the bipartite pair graph and the binary maxima sequence.

Generates two figures:
  (1) the pair graph G(u, v) of the shattering pair u = 0011, v = 0101,
      highlighting the K_{2,2} four-cycle that certifies goodness;
  (2) the computed binary maxima M_2(k) for k = 2..7.

Requires only matplotlib. Run: python viz.py
"""

from __future__ import annotations

from itertools import product
from typing import List, Set, Tuple

import matplotlib.pyplot as plt

Vector = Tuple[int, ...]
Vertex = Tuple[str, int]
Edge = Tuple[Vertex, Vertex]


def pair_graph_edges(u: Vector, v: Vector) -> Set[Edge]:
    """Distinct edges L_{u_i} -- R_{v_i} of the bipartite pair graph."""
    return {(("L", ui), ("R", vi)) for ui, vi in zip(u, v)}


def plot_pair_graph(u: Vector, v: Vector, path: str = "pair_graph.png") -> None:
    """Draw G(u, v): left column L_0,L_1, right column R_0,R_1, with edges."""
    edges = pair_graph_edges(u, v)
    fig, ax = plt.subplots(figsize=(5, 5))
    left_x, right_x = 0.0, 2.0
    pos = {("L", 0): (left_x, 1.0), ("L", 1): (left_x, 0.0),
           ("R", 0): (right_x, 1.0), ("R", 1): (right_x, 0.0)}
    for (a, b) in edges:
        (x0, y0), (x1, y1) = pos[a], pos[b]
        ax.plot([x0, x1], [y0, y1], color="crimson", lw=2.5, zorder=1)
    for (side, sym), (x, y) in pos.items():
        ax.scatter([x], [y], s=900, color="#1f77b4", zorder=2)
        ax.text(x, y, f"{side}{sym}", color="white", ha="center",
                va="center", fontsize=12, fontweight="bold", zorder=3)
    ax.set_title(
        f"Pair graph of u={''.join(map(str,u))}, v={''.join(map(str,v))}\n"
        "(complete K(2,2): contains a 4-cycle)",
        fontsize=11)
    ax.axis("off")
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


def plot_sequence(path: str = "binary_maxima.png") -> None:
    """Bar chart of the computed binary maxima M_2(k), k = 2..7."""
    ks: List[int] = [2, 3, 4, 5, 6, 7]
    vals: List[int] = [1, 1, 3, 4, 10, 15]
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.bar([str(k) for k in ks], vals, color="#2ca02c")
    for k, val in zip(ks, vals):
        ax.text(str(k), val + 0.2, str(val), ha="center", fontsize=11)
    ax.axvspan(-0.5, 1.5, color="grey", alpha=0.15)
    ax.set_xlabel("length k")
    ax.set_ylabel("M_2(k)  (max cyclic family size)")
    ax.set_title("Binary maxima: collapse for k<=3, threshold at k=4")
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


if __name__ == "__main__":
    plot_pair_graph((0, 0, 1, 1), (0, 1, 0, 1))
    plot_sequence()
    print("Wrote pair_graph.png and binary_maxima.png")
