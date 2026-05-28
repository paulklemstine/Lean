#!/usr/bin/env python3
"""
Visualization 2: Universality Under Monotone Transport (Theorem 4)

Shows that cycle-birth distributions from different edge-weight distributions
(Uniform, Exponential, Normal) collapse onto the same curve after probability
integral transform. This demonstrates Theorem 4: only the order of weights
matters for cycle-birth classification.
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


def rank_transform(values):
    """Probability integral transform via ranks."""
    if len(values) == 0:
        return np.array([])
    order = np.argsort(np.argsort(values))
    return (order + 0.5) / len(values)


rng = np.random.default_rng(123)
n = 150
p = 0.2

# Generate a fixed graph topology
graph_edges = []
for i in range(n):
    for j in range(i+1, n):
        if rng.random() < p:
            graph_edges.append((i, j))
m = len(graph_edges)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Universality: Cycle-Birth CDFs Under Different Weight Distributions\n'
             '(Theorem 4: Monotone Transport Preserves Classification)',
             fontsize=13, fontweight='bold')

# Panel 1: Raw CDFs (different distributions look different)
distributions = {
    'Uniform': lambda: rng.random(m),
    'Exponential': lambda: rng.exponential(1.0, m),
    'Normal': lambda: rng.normal(0, 1, m),
}
colors = {'Uniform': '#2196F3', 'Exponential': '#FF5722', 'Normal': '#4CAF50'}

ax = axes[0]
ax.set_title('Raw Birth Weights\n(Distributions differ)', fontsize=11)
for name, gen in distributions.items():
    for trial in range(5):
        weights = gen()
        births = compute_cycle_births(n, graph_edges, weights)
        if len(births) > 0:
            sb = np.sort(births)
            cdf_y = np.arange(1, len(sb)+1) / len(sb)
            ax.step(sb, cdf_y, color=colors[name], alpha=0.4, linewidth=1,
                    label=name if trial == 0 else None)
ax.set_xlabel('Raw Edge Weight')
ax.set_ylabel('Empirical CDF')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Rank-transformed CDFs (distributions collapse)
ax = axes[1]
ax.set_title('After Rank Transform\n(Distributions collapse!)', fontsize=11)
for name, gen in distributions.items():
    for trial in range(5):
        weights = gen()
        births = compute_cycle_births(n, graph_edges, weights)
        if len(births) > 0:
            transformed = rank_transform(births)
            sb = np.sort(transformed)
            cdf_y = np.arange(1, len(sb)+1) / len(sb)
            ax.step(sb, cdf_y, color=colors[name], alpha=0.4, linewidth=1,
                    label=name if trial == 0 else None)
ax.set_xlabel('Rank-Transformed Weight')
ax.set_ylabel('Empirical CDF')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

# Panel 3: Same graph, same topology → identical classifications
ax = axes[2]
ax.set_title('Classification Invariance\n(Same edges are cycle births)', fontsize=11)
# Show that the SAME edges are classified as cycle births
weights_u = rng.random(m)
weights_e = rng.exponential(1.0, m)

order_u = np.argsort(weights_u)
order_e = np.argsort(weights_e)

uf_u, uf_e = UnionFind(n), UnionFind(n)
class_u, class_e = [], []
for idx in order_u:
    u, v = graph_edges[idx]
    class_u.append(not uf_u.union(u, v))
for idx in order_e:
    u, v = graph_edges[idx]
    class_e.append(not uf_e.union(u, v))

# Count agreements: classification depends on weight ORDER, not values
# With different weights, the order changes, so classifications differ
# But with MONOTONE TRANSFORM of same weights, classifications are identical!
weights_sq = weights_u ** 2  # monotone transform
order_sq = np.argsort(weights_sq)
uf_sq = UnionFind(n)
class_sq = []
for idx in order_sq:
    u, v = graph_edges[idx]
    class_sq.append(not uf_sq.union(u, v))

# Rebuild class_u in order
class_u_ordered = [False] * m
uf_check = UnionFind(n)
for idx in order_u:
    u, v = graph_edges[idx]
    class_u_ordered[idx] = not uf_check.union(u, v)

class_sq_ordered = [False] * m
uf_check2 = UnionFind(n)
for idx in order_sq:
    u, v = graph_edges[idx]
    class_sq_ordered[idx] = not uf_check2.union(u, v)

agreement = sum(1 for a, b in zip(class_u_ordered, class_sq_ordered) if a == b)
ax.bar(['w', 'w²\n(monotone)'], [m, agreement],
       color=['#2196F3', '#4CAF50'], alpha=0.7)
ax.set_ylabel('Number of Edges')
ax.axhline(y=m, color='gray', linestyle='--', alpha=0.5)
ax.text(0.5, m * 0.95, f'{m} edges total', ha='center', fontsize=9, color='gray')
ax.text(1, agreement + m*0.02, f'{agreement}/{m}\nagreement', ha='center', fontsize=9)
ax.set_ylim(0, m * 1.15)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
