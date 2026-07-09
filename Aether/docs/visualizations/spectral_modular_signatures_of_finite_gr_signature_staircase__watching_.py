"""
Visualization: the spectral modular signature equals the number of connected
components, illustrated as we incrementally add edges to a graph.

Generates a figure with two synchronized panels:
  (left)  the graph drawn on a circle, components colored distinctly;
  (right) the running signature (= #components = Laplacian nullity) vs. #edges,
          a non-increasing staircase that bottoms out at 1 when connected.

Standard scientific Python (matplotlib, numpy). Saves spec_mod_sig.png.
"""

from __future__ import annotations

from typing import List, Set, Tuple
import math

import numpy as np
import matplotlib.pyplot as plt


def components(n: int, edges: Set[Tuple[int, int]]) -> List[int]:
    """Union-find component label per vertex; returns label list."""
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for u, v in edges:
        parent[find(u)] = find(v)
    roots = {}
    labels = []
    for x in range(n):
        r = find(x)
        roots.setdefault(r, len(roots))
        labels.append(roots[r])
    return labels


def signature(n: int, edges: Set[Tuple[int, int]]) -> int:
    return len(set(components(n, edges)))


def main() -> None:
    n = 9
    # an edge-addition schedule that gradually connects the graph
    schedule = [(0, 1), (2, 3), (4, 5), (6, 7), (1, 2), (3, 4),
                (5, 6), (7, 8), (8, 0)]

    pos = np.array([[math.cos(2 * math.pi * k / n),
                     math.sin(2 * math.pi * k / n)] for k in range(n)])

    fig, (axg, axs) = plt.subplots(1, 2, figsize=(12, 5.5))

    # final graph drawn with component colors
    edges: Set[Tuple[int, int]] = set(schedule)
    labels = components(n, edges)
    cmap = plt.get_cmap("tab10")
    for (u, v) in edges:
        axg.plot([pos[u, 0], pos[v, 0]], [pos[u, 1], pos[v, 1]],
                 color="0.6", lw=1.5, zorder=1)
    for k in range(n):
        axg.scatter(pos[k, 0], pos[k, 1], s=420, color=cmap(labels[k] % 10),
                    edgecolor="black", zorder=2)
        axg.text(pos[k, 0], pos[k, 1], str(k), ha="center", va="center",
                 fontsize=11, fontweight="bold", zorder=3)
    axg.set_title(f"Final graph: signature = {signature(n, edges)} component(s)")
    axg.set_aspect("equal")
    axg.axis("off")

    # staircase of signature vs number of edges
    xs = [0]
    ys = [signature(n, set())]
    acc: Set[Tuple[int, int]] = set()
    for i, e in enumerate(schedule, start=1):
        acc.add(e)
        xs.append(i)
        ys.append(signature(n, acc))
    axs.step(xs, ys, where="post", color="crimson", lw=2.5)
    axs.scatter(xs, ys, color="crimson", zorder=3)
    axs.set_xlabel("number of edges added")
    axs.set_ylabel("spectral modular signature  =  #components")
    axs.set_title("Signature is a non-increasing staircase")
    axs.set_xticks(xs)
    axs.set_yticks(range(1, n + 1))
    axs.grid(alpha=0.3)

    fig.suptitle("Component-Kernel Theorem:  specModSig(G) = #components(G)",
                 fontsize=14, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("spec_mod_sig.png", dpi=150)
    print("wrote spec_mod_sig.png")


if __name__ == "__main__":
    main()
