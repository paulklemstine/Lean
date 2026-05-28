"""
Visualization: Universality Under Monotone Transport

Demonstrates Theorem 4: the cycle-birth edge classification is invariant
under monotone transformation of edge weights. After quantile normalization,
cycle-birth CDFs from Uniform, Exponential, and Normal weight distributions
collapse onto the same curve.

This is the analogue of universality in random matrix theory, where the
eigenvalue distribution is insensitive to the distribution of matrix entries.
In tropical topology, only the ORDER of edge weights matters.
"""

import numpy as np
import matplotlib.pyplot as plt


# Self-contained implementations
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
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append(w)
        else:
            uf.union(u, v)
    return births


def quantile_transform(values):
    n = len(values)
    if n == 0:
        return np.array([])
    ranks = np.argsort(np.argsort(values))
    return (ranks + 0.5) / n


n = 300
p = 0.15
num_trials = 8
rng = np.random.default_rng(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left panel: Raw CDFs (different distributions look different)
ax = axes[0]
dist_configs = [
    ('uniform', '#2196F3', 'Uniform[0,1]'),
    ('exponential', '#FF5722', 'Exponential(1)'),
    ('normal', '#4CAF50', 'Normal(0,1)'),
]

for dist_name, color, label in dist_configs:
    for trial in range(num_trials):
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if rng.random() < p:
                    if dist_name == 'uniform':
                        w = rng.random()
                    elif dist_name == 'exponential':
                        w = rng.exponential(1.0)
                    else:
                        w = rng.normal(0, 1)
                    edges.append((i, j, w))

        births = compute_births(n, edges)
        if births:
            sorted_b = np.sort(births)
            cdf_y = np.arange(1, len(sorted_b) + 1) / len(sorted_b)
            lbl = label if trial == 0 else None
            ax.step(sorted_b, cdf_y, alpha=0.5, linewidth=1.0,
                    color=color, label=lbl)

ax.set_title('Raw Cycle-Birth CDFs\n(Different Weight Distributions)', fontsize=12, fontweight='bold')
ax.set_xlabel('Edge Weight', fontsize=11)
ax.set_ylabel('Empirical CDF', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Right panel: After quantile transform (universality!)
ax = axes[1]
rng2 = np.random.default_rng(42)  # Same seed for same graphs

for dist_name, color, label in dist_configs:
    for trial in range(num_trials):
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if rng2.random() < p:
                    if dist_name == 'uniform':
                        w = rng2.random()
                    elif dist_name == 'exponential':
                        w = rng2.exponential(1.0)
                    else:
                        w = rng2.normal(0, 1)
                    edges.append((i, j, w))

        births = compute_births(n, edges)
        if births:
            qt = quantile_transform(np.array(births))
            sorted_qt = np.sort(qt)
            cdf_y = np.arange(1, len(sorted_qt) + 1) / len(sorted_qt)
            lbl = label if trial == 0 else None
            ax.step(sorted_qt, cdf_y, alpha=0.5, linewidth=1.0,
                    color=color, label=lbl)

ax.set_title('After Quantile Transform\n(Universality: All Curves Collapse)', fontsize=12, fontweight='bold')
ax.set_xlabel('Quantile-Transformed Weight', fontsize=11)
ax.set_ylabel('Empirical CDF', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

fig.suptitle('Theorem 4: Monotone Transport Universality',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('universality_plot.png', dpi=150, bbox_inches='tight')
print("Saved universality_plot.png")
