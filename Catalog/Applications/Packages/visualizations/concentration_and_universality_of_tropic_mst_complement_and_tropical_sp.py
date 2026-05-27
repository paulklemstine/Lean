#!/usr/bin/env python3
"""
Visualization 3: MST Complement Theorem and Tropical Spectral Law

Shows the partition of edges into MST (forest) edges and cycle-birth edges.
Left: histogram comparing weight distributions of MST vs cycle-birth edges.
Right: the empirical cycle-birth CDF (the "tropical spectral measure") across
multiple graph sizes, showing convergence to a limiting law.
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

def classify_edges(n, edges, weights):
    order = sorted(range(len(edges)), key=lambda i: weights[i])
    uf = UnionFind(n)
    births = []
    mst = set()
    cb = set()
    for idx in order:
        u, v = edges[idx]
        if uf.union(u, v):
            mst.add(idx)
        else:
            births.append(weights[idx])
            cb.add(idx)
    return births, mst, cb

def gnp_graph(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges

# ─── Generate data ───

rng = np.random.default_rng(55)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Left panel: MST vs cycle-birth weight distributions
n, p = 200, 0.2
edges = gnp_graph(n, p, rng)
weights = rng.random(len(edges))
births, mst, cb = classify_edges(n, edges, weights)

mst_w = [weights[i] for i in mst]
cb_w = [weights[i] for i in cb]

ax1.hist(mst_w, bins=25, alpha=0.6, color='#3498db', label=f'MST edges ({len(mst)})',
         density=True, edgecolor='white')
ax1.hist(cb_w, bins=25, alpha=0.6, color='#e74c3c', label=f'Cycle births ({len(cb)})',
         density=True, edgecolor='white')
ax1.axvline(x=np.mean(mst_w), color='#2980b9', linestyle='--', linewidth=2,
            label=f'MST mean = {np.mean(mst_w):.3f}')
ax1.axvline(x=np.mean(cb_w), color='#c0392b', linestyle='--', linewidth=2,
            label=f'CB mean = {np.mean(cb_w):.3f}')
ax1.set_title(f'Edge Weight Distributions: MST vs Cycle Births\nG({n},{p}), '
              f'm={len(edges)}, β₁={len(cb)}', fontsize=12, fontweight='bold')
ax1.set_xlabel('Edge Weight', fontsize=11)
ax1.set_ylabel('Density', fontsize=11)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.2)

# Right panel: Tropical spectral law convergence
ns = [50, 100, 200, 500]
colors = ['#f39c12', '#e74c3c', '#9b59b6', '#2c3e50']
num_trials = 5

for n_val, color in zip(ns, colors):
    for trial in range(num_trials):
        edges = gnp_graph(n_val, 0.15, rng)
        if not edges:
            continue
        w = rng.random(len(edges))
        b, _, _ = classify_edges(n_val, edges, w)
        if b:
            sorted_b = np.sort(b)
            cdf = np.arange(1, len(sorted_b) + 1) / len(sorted_b)
            label = f'n={n_val}' if trial == 0 else None
            ax2.step(sorted_b, cdf, color=color, alpha=0.5, linewidth=1.0, label=label)

ax2.set_title('Tropical Spectral Law: Convergence of Cycle-Birth CDFs',
              fontsize=12, fontweight='bold')
ax2.set_xlabel('Edge Weight', fontsize=11)
ax2.set_ylabel('Empirical CDF (normalized by β₁)', fontsize=11)
ax2.legend(fontsize=10, loc='lower right')
ax2.set_xlim(0, 1)
ax2.set_ylim(0, 1.05)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_mst_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_mst_complement.png")
