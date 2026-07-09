"""Visualization: the Collatz backward tree of preimages.

Generates a figure of the tree of a-step preimages converging onto a target,
highlighting the collision 1 -> 4 <- 8 and showing that the realizable branching
grows sub-exponentially (c^a with c < 2) rather than as the naive 2^a.

Requires: matplotlib.  Run: python collatz_backward_tree.py
"""
from typing import Dict, List
import matplotlib.pyplot as plt


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def preimages_one_step(k: int, bound: int) -> List[int]:
    """All n < bound with collatz_step(n) = k."""
    return [n for n in range(bound) if collatz_step(n) == k]


def build_tree(target: int, depth: int, bound: int) -> Dict[int, List[int]]:
    """Map each node to its one-step predecessors, breadth-first to given depth."""
    edges: Dict[int, List[int]] = {}
    frontier = [target]
    for _ in range(depth):
        nxt: List[int] = []
        for node in frontier:
            preds = preimages_one_step(node, bound)
            edges[node] = preds
            nxt.extend(preds)
        frontier = nxt
    return edges


def main() -> None:
    target, depth, bound = 4, 5, 2048
    edges = build_tree(target, depth, bound)

    # Assign layered positions.
    levels: Dict[int, int] = {target: 0}
    queue = [target]
    while queue:
        node = queue.pop(0)
        for child in edges.get(node, []):
            if child not in levels:
                levels[child] = levels[node] + 1
                queue.append(child)

    by_level: Dict[int, List[int]] = {}
    for node, lvl in levels.items():
        by_level.setdefault(lvl, []).append(node)

    pos = {}
    for lvl, nodes in by_level.items():
        nodes.sort()
        for i, node in enumerate(nodes):
            pos[node] = (i - (len(nodes) - 1) / 2.0, -lvl)

    fig, ax = plt.subplots(figsize=(11, 7))
    for node, preds in edges.items():
        if node not in pos:
            continue
        x0, y0 = pos[node]
        for p in preds:
            if p in pos:
                x1, y1 = pos[p]
                ax.plot([x0, x1], [y0, y1], color="#9bb", lw=0.8, zorder=1)
    for node, (x, y) in pos.items():
        special = node in (1, 8, 4)
        ax.scatter([x], [y], s=320 if special else 160,
                   color="#e4572e" if special else "#4d7298", zorder=2)
        ax.text(x, y, str(node), ha="center", va="center",
                color="white", fontsize=9, fontweight="bold", zorder=3)

    ax.set_title("Collatz backward tree onto 4: the collision 1 -> 4 <- 8\n"
                 "realizable branching grows like c^a (c < 2), not 2^a")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("collatz_backward_tree.png", dpi=150)
    print("wrote collatz_backward_tree.png")


if __name__ == "__main__":
    main()
