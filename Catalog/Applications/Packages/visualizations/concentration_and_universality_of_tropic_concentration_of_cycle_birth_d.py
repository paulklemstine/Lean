#!/usr/bin/env python3
"""
Visualization 1: Concentration of Cycle-Birth Distributions

Visualizes how empirical cycle-birth CDFs from independent random graph
trials converge as graph size increases, demonstrating the concentration
theorem (Theorem 3). Multiple trials are overlaid to show the narrowing
of the distribution "band" with increasing n.
"""

import numpy as np
import matplotlib.pyplot as plt


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True


def compute_cycle_births(n, edges, weights):
    order = np.argsort(weights)
    uf = UnionFind(n)
    births = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            births.append(weights[idx])
    return np.array(births)


def sample_gnp(n, p, rng):
    edges, weights = [], []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edges.append((i, j))
                weights.append(rng.random())
    return edges, np.array(weights)


fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Concentration of Cycle-Birth Distributions\n(Theorem 3: Bounded Differences → Subgaussian Concentration)',
             fontsize=14, fontweight='bold')

ns = [30, 60, 120, 250]
p = 0.2
num_trials = 15
rng = np.random.default_rng(42)

for ax, n in zip(axes.flat, ns):
    for trial in range(num_trials):
        edges, weights = sample_gnp(n, p, rng)
        if len(edges) == 0:
            continue
        births = compute_cycle_births(n, edges, weights)
        if len(births) > 0:
            sorted_births = np.sort(births)
            cdf_y = np.arange(1, len(sorted_births)+1) / len(sorted_births)
            ax.step(sorted_births, cdf_y, alpha=0.4, linewidth=1)

    ax.set_title(f'n = {n} ({num_trials} independent trials)', fontsize=11)
    ax.set_xlabel('Edge Weight (threshold t)')
    ax.set_ylabel('Empirical CDF F̂(t)')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")
