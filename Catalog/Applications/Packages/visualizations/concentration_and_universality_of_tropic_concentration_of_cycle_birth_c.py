"""
Visualization: Concentration of Cycle-Birth CDFs

Illustrates the key concentration phenomenon: as graph size n increases,
the empirical cycle-birth CDF concentrates around a deterministic limit.
Multiple independent trials of G(n,p) with uniform edge weights produce
CDFs that cluster ever more tightly.

This is the graphical manifestation of the bounded-differences / McDiarmid
concentration inequality applied to tropical critical values.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# ── Inline dependencies ──
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
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
    def connected(self, x, y):
        return self.find(x) == self.find(y)

def compute_cycle_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    cb_weights = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            cb_weights.append(w)
        else:
            uf.union(u, v)
    return np.array(cb_weights)

def generate_gnp(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    return edges


# ── Main visualization ──
matplotlib.rcParams.update({'font.size': 11})
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

p = 0.15
ns = [50, 150, 500]
num_trials = 8
rng = np.random.default_rng(42)
colors = plt.cm.viridis(np.linspace(0.2, 0.8, num_trials))

for ax_idx, n in enumerate(ns):
    ax = axes[ax_idx]
    for trial in range(num_trials):
        edges = generate_gnp(n, p, rng)
        cb = compute_cycle_births(n, edges)
        if len(cb) > 0:
            sorted_cb = np.sort(cb)
            cdf_y = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
            ax.step(sorted_cb, cdf_y, where='post', color=colors[trial],
                    alpha=0.7, linewidth=1.2)

    ax.set_xlabel('Edge Weight (Birth Time)', fontsize=12)
    ax.set_ylabel('Empirical CDF', fontsize=12)
    ax.set_title(f'n = {n},  p = {p}\n({num_trials} independent trials)', fontsize=13)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

fig.suptitle('Concentration of Cycle-Birth CDFs\n'
             'As n grows, the tropical spectral measure concentrates',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")
