#!/usr/bin/env python3
"""
Visualization 1: Concentration of Cycle-Birth CDFs

Shows how the empirical cycle-birth CDF concentrates as graph size n increases.
Multiple independent trials of G(n,p) with random weights are overlaid, showing
that the CDFs cluster tightly around a common curve. The spread decreases with n,
illustrating the concentration theorem (subgaussian tails from bounded differences).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inlined algorithms ───

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
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

def compute_cycle_births(n, edges, weights):
    order = sorted(range(len(edges)), key=lambda i: weights[i])
    uf = UnionFind(n)
    births = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            births.append(weights[idx])
    return births

def gnp_graph(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges

# ─── Generate data ───

rng = np.random.default_rng(42)
p = 0.15
ns = [30, 100, 300]
num_trials = 15
colors = ['#e74c3c', '#3498db', '#2ecc71']

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for ax_idx, n in enumerate(ns):
    ax = axes[ax_idx]
    for trial in range(num_trials):
        edges = gnp_graph(n, p, rng)
        if not edges:
            continue
        weights = rng.random(len(edges))
        births = compute_cycle_births(n, edges, weights)
        if births:
            sorted_b = np.sort(births)
            cdf_y = np.arange(1, len(sorted_b) + 1) / len(sorted_b)
            ax.step(sorted_b, cdf_y, alpha=0.4, color=colors[ax_idx], linewidth=0.8)

    ax.set_title(f'n = {n}', fontsize=14, fontweight='bold')
    ax.set_xlabel('Edge Weight Threshold', fontsize=11)
    ax.set_ylabel('Empirical CDF', fontsize=11)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Add annotation about spread
    ax.text(0.05, 0.92, f'{num_trials} independent trials',
            transform=ax.transAxes, fontsize=9, color='gray')

fig.suptitle('Concentration of Cycle-Birth CDFs in G(n, 0.15)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")
