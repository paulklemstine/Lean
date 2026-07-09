"""Visualize H_0 persistence: number of connected components decreasing
along a random proximity filtration, with the H_0 barcode beside it.
Requires matplotlib. Saves `h0_persistence.png`.
"""
from typing import Dict, List, Set, Tuple
import random
import matplotlib.pyplot as plt


def beta0(vertices, edges) -> int:
    parent = {v: v for v in vertices}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for a, b in edges:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb
    return len({find(v) for v in vertices})


def main() -> None:
    random.seed(7)
    n = 20
    verts = list(range(n))
    all_edges = [(a, b) for a in verts for b in verts if a < b]
    random.shuffle(all_edges)

    thresholds: List[int] = []
    betti: List[int] = []
    bars: List[Tuple[int, float]] = []   # (birth_step, death_step)
    parent = {v: v for v in verts}
    birth = {v: 0 for v in verts}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x

    edges: Set[Tuple[int, int]] = set()
    for step, e in enumerate(all_edges, start=1):
        a, b = e
        ra, rb = find(a), find(b)
        if ra != rb:
            young, old = (ra, rb) if birth[ra] >= birth[rb] else (rb, ra)
            bars.append((birth[young], step))
            parent[young] = old
        edges.add(e)
        thresholds.append(step)
        betti.append(beta0(verts, edges))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.step(thresholds, betti, where="post", color="crimson", lw=2)
    ax1.set_xlabel("filtration step (edges added)")
    ax1.set_ylabel(r"$\beta_0$ (number of components)")
    ax1.set_title(r"$H_0$ persistence: $\beta_0$ is monotone non-increasing")
    ax1.grid(alpha=0.3)

    for i, (b0, d0) in enumerate(sorted(bars)):
        ax2.plot([b0, d0], [i, i], color="steelblue", lw=2)
    # survivors
    surv_y = len(bars)
    for r in {find(v) for v in verts}:
        ax2.plot([birth[r], max(thresholds)], [surv_y, surv_y], color="darkgreen", lw=3)
        surv_y += 1
    ax2.set_xlabel("filtration step")
    ax2.set_ylabel("bar index")
    ax2.set_title(r"$H_0$ barcode (green = surviving dominant component)")
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("h0_persistence.png", dpi=150)
    print("saved h0_persistence.png")


if __name__ == "__main__":
    main()
