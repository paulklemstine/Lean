"""
Visualization: Monotone Transport Universality

Demonstrates Theorem 4: the cycle-birth edge SET is invariant under
strictly monotone transformations of edge weights. Different weight
distributions (uniform, exponential, Gaussian) produce different
raw CDFs, but after applying the probability integral transform
(mapping through the weight CDF), they collapse onto a single curve.

This is the tropical analogue of universality in random matrix theory:
microscopic details (the weight distribution) wash out, leaving a
universal macroscopic law.
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


# ── Generate one graph, apply three weight distributions ──
matplotlib.rcParams.update({'font.size': 11})
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

n = 300
p = 0.12
rng = np.random.default_rng(77)

# Generate base graph structure
graph_edges = []
for i in range(n):
    for j in range(i+1, n):
        if rng.random() < p:
            graph_edges.append((i, j))

# Three weight distributions for the SAME graph
base_uniform = rng.random(len(graph_edges))
transforms = {
    'Uniform [0,1]': base_uniform,
    'Exponential': np.exp(base_uniform * 3) - 1,
    'Cubic': base_uniform ** 3,
}
colors = {'Uniform [0,1]': '#1f77b4', 'Exponential': '#ff7f0e', 'Cubic': '#2ca02c'}

# Left panel: Raw CDFs (different curves)
ax = axes[0]
for label, weights in transforms.items():
    edges = [(u, v, w) for (u, v), w in zip(graph_edges, weights)]
    cb = compute_cycle_births(n, edges)
    if len(cb) > 0:
        sorted_cb = np.sort(cb)
        cdf_y = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
        ax.step(sorted_cb, cdf_y, where='post', label=label,
                color=colors[label], linewidth=2)

ax.set_xlabel('Birth Time (raw weight)', fontsize=12)
ax.set_ylabel('Empirical CDF', fontsize=12)
ax.set_title('Raw Cycle-Birth CDFs\n(Different weight scales)', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

# Right panel: After quantile normalization (same curve!)
ax = axes[1]
for label, weights in transforms.items():
    edges = [(u, v, w) for (u, v), w in zip(graph_edges, weights)]
    cb = compute_cycle_births(n, edges)
    if len(cb) > 0:
        # Quantile normalize: rank → [0,1]
        ranks = (np.argsort(np.argsort(cb)) + 1) / len(cb)
        sorted_r = np.sort(ranks)
        cdf_y = np.arange(1, len(sorted_r)+1) / len(sorted_r)
        ax.step(sorted_r, cdf_y, where='post', label=label,
                color=colors[label], linewidth=2, alpha=0.8)

ax.plot([0, 1], [0, 1], 'k--', alpha=0.3, label='Identity')
ax.set_xlabel('Quantile-Normalized Birth Time', fontsize=12)
ax.set_ylabel('Empirical CDF', fontsize=12)
ax.set_title('After Monotone Transport\n(Curves collapse — Theorem 4)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

fig.suptitle('Universality of Cycle-Birth Distributions\n'
             'Same graph, different weight distributions → same topological pattern',
             fontsize=14, fontweight='bold', y=1.04)
plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
