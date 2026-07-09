"""Visualization: contraction defect of a labeling versus graph distance.

Plots, for a sample graph and an edge-gentle labeling, every pair (d_G, d_Q) as a
scatter point. The No-Stretching Theorem forces all points onto or below the
diagonal d_Q = d_G: the labeling never stretches. Requires matplotlib.
"""
from collections import deque
from itertools import combinations
import matplotlib.pyplot as plt


def bfs(adj, src):
    dist = {src: 0}
    q = deque([src])
    while q:
        u = q.popleft()
        for w in adj[u]:
            if w not in dist:
                dist[w] = dist[u] + 1
                q.append(w)
    return dist


def main():
    # A 6-cycle with a "folding" parity labeling into Q1 (v mod 2).
    n = 6
    edges = [(i, (i + 1) % n) for i in range(n)]
    adj = {v: [] for v in range(n)}
    for u, v in edges:
        adj[u].append(v); adj[v].append(u)
    label = {v: (v % 2,) for v in range(n)}
    dmat = {v: bfs(adj, v) for v in range(n)}

    xs, ys = [], []
    for u, v in combinations(range(n), 2):
        xs.append(dmat[u][v])
        ys.append(sum(1 for a, b in zip(label[u], label[v]) if a != b))

    lim = max(xs) + 1
    plt.figure(figsize=(6, 6))
    plt.plot([0, lim], [0, lim], "k--", label="$d_Q = d_G$ (isometry)")
    plt.fill_between([0, lim], [0, lim], 0, alpha=0.1, color="green",
                     label="no-stretching region $d_Q \\leq d_G$")
    plt.scatter(xs, ys, s=80, c="crimson", zorder=3, label="vertex pairs")
    plt.xlabel("graph distance $d_G(u,v)$")
    plt.ylabel("labeled distance $d_Q(\\ell u,\\ell v)$")
    plt.title("No-Stretching: all pairs lie on or below the diagonal")
    plt.legend(); plt.grid(True, alpha=0.3)
    plt.savefig("no_stretching_scatter.png", dpi=150, bbox_inches="tight")
    print("saved no_stretching_scatter.png")


if __name__ == "__main__":
    main()
