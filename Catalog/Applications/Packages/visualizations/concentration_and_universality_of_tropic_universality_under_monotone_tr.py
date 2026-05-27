"""
Visualization: Universality Under Monotone Transport

Shows that cycle-birth CDFs from different weight distributions
(Uniform, Exponential, Normal) collapse onto a single curve after
rank normalization. This visualizes Theorem 4
(cycleBirthFlags_invariant_mapWeights).

Left panel: Raw CDFs differ across distributions.
Right panel: After quantile normalization, all CDFs agree.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ---- Inlined algorithms ----

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


def get_cycle_births_with_dist(n, p, dist, rng):
    edges = []
    edge_structure = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                edge_structure.append((i, j))

    weight_rng = np.random.default_rng(rng.integers(0, 2**32))
    for u, v in edge_structure:
        if dist == 'uniform':
            w = weight_rng.random()
        elif dist == 'exponential':
            w = weight_rng.exponential(1.0)
        elif dist == 'normal':
            w = weight_rng.normal(0.0, 1.0)
        edges.append((u, v, w))

    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    cb = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            cb.append(w)
    return cb


# ---- Main visualization ----

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Universality: Cycle-Birth CDFs Under Different Weight Distributions',
             fontsize=14, fontweight='bold')

n = 300
p = 0.15
num_trials = 5
dists = ['uniform', 'exponential', 'normal']
colors = {'uniform': '#2196F3', 'exponential': '#FF5722', 'normal': '#4CAF50'}
labels = {'uniform': 'Uniform[0,1]', 'exponential': 'Exponential(1)', 'normal': 'Normal(0,1)'}

for dist in dists:
    for trial in range(num_trials):
        rng = np.random.default_rng(42 + trial)
        cb = get_cycle_births_with_dist(n, p, dist, rng)
        if not cb:
            continue

        # Raw CDF
        sorted_cb = np.sort(cb)
        ecdf = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
        label = labels[dist] if trial == 0 else None
        ax1.step(sorted_cb, ecdf, alpha=0.5, linewidth=1.2,
                 color=colors[dist], label=label)

        # Rank-normalized CDF
        ranks = np.argsort(np.argsort(sorted_cb)) / len(sorted_cb)
        ecdf_norm = np.arange(1, len(sorted_cb)+1) / len(sorted_cb)
        ax2.step(np.sort(ranks), ecdf_norm, alpha=0.5, linewidth=1.2,
                 color=colors[dist], label=label if trial == 0 else None)

ax1.set_title('Raw Cycle-Birth CDFs', fontsize=12, fontweight='bold')
ax1.set_xlabel('Weight threshold', fontsize=11)
ax1.set_ylabel('Empirical CDF', fontsize=11)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.annotate('Different distributions\n→ different CDFs',
             xy=(0.5, 0.3), xycoords='axes fraction',
             fontsize=10, ha='center',
             bbox=dict(boxstyle='round', fc='lightyellow', alpha=0.8))

ax2.set_title('After Rank Normalization (Quantile Transform)', fontsize=12, fontweight='bold')
ax2.set_xlabel('Normalized rank', fontsize=11)
ax2.set_ylabel('Empirical CDF', fontsize=11)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.annotate('All distributions\ncollapse to one curve!',
             xy=(0.5, 0.3), xycoords='axes fraction',
             fontsize=10, ha='center', color='darkgreen',
             fontweight='bold',
             bbox=dict(boxstyle='round', fc='lightgreen', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
