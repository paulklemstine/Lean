"""
Visualization: the Berggren tree of Pythagorean triples and the B-branch
exponential hypotenuse growth.

Renders two panels:
  (left)  the first few levels of the ternary Berggren tree, nodes labelled
          by their triples, positioned by depth and hypotenuse;
  (right) the hypotenuse along the all-B branch on a log scale, with the
          reference slope log(3 + 2*sqrt(2)) confirming geometric growth.

Requires matplotlib.  Run:  python berggren_tree_viz.py
"""
from __future__ import annotations
import math
from typing import List, Tuple
import matplotlib.pyplot as plt

Triple = Tuple[int, int, int]


def child_A(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def child_B(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def child_C(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


def build_tree(root: Triple, depth: int) -> List[Tuple[int, Triple, Triple]]:
    """Return list of (level, parent, node) edges (parent=node at root)."""
    edges: List[Tuple[int, Triple, Triple]] = [(0, root, root)]
    frontier: List[Triple] = [root]
    for level in range(1, depth + 1):
        nxt: List[Triple] = []
        for p in frontier:
            for ch in (child_A(p), child_B(p), child_C(p)):
                edges.append((level, p, ch))
                nxt.append(ch)
        frontier = nxt
    return edges


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # --- Panel 1: the tree (3 levels) ---
    edges = build_tree((3, 4, 5), 2)
    # position: x = depth, y = log(hypotenuse)
    pos = {}
    for level, parent, node in edges:
        pos[node] = (level, math.log10(node[2]))
    for level, parent, node in edges:
        if parent != node:
            x0, y0 = pos[parent]
            x1, y1 = pos[node]
            ax1.plot([x0, x1], [y0, y1], color="0.6", lw=1, zorder=1)
    for node, (x, y) in pos.items():
        ax1.scatter([x], [y], s=20, color="tab:blue", zorder=2)
        if x <= 1:
            ax1.annotate(str(node), (x, y), fontsize=7,
                         xytext=(3, 3), textcoords="offset points")
    ax1.set_xlabel("tree depth")
    ax1.set_ylabel("log10(hypotenuse)")
    ax1.set_title("Berggren ternary tree (root = (3,4,5))")

    # --- Panel 2: B-branch growth ---
    t: Triple = (3, 4, 5)
    hyps: List[int] = [t[2]]
    for _ in range(10):
        t = child_B(t)
        hyps.append(t[2])
    xs = list(range(len(hyps)))
    ax2.semilogy(xs, hyps, "o-", color="tab:red", label="B-branch hypotenuse")
    factor = 3 + 2 * math.sqrt(2)
    ref = [hyps[0] * factor ** k for k in xs]
    ax2.semilogy(xs, ref, "--", color="0.5",
                 label=f"slope (3+2√2)^k ≈ {factor:.3f}^k")
    ax2.set_xlabel("B-branch step")
    ax2.set_ylabel("hypotenuse (log scale)")
    ax2.set_title("Exponential B-branch growth (> 5x per step)")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("berggren_tree_viz.png", dpi=150)
    print("wrote berggren_tree_viz.png")


if __name__ == "__main__":
    main()
