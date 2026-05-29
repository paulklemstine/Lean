"""
Visualization: Universality Under Monotone Transport

This script visualizes the universality theorem: cycle-birth CDFs are
invariant under monotone transport of edge weights. Three different
weight distributions (Uniform, Exponential, Normal) produce identical
cycle-birth CDFs after quantile normalization.

The top row shows raw CDFs (different for each distribution).
The bottom row shows CDFs after monotone transport to uniform scale (identical).
"""

import numpy as np
import matplotlib.pyplot as plt


# ============================================================
# Inline implementations (self-contained)
# ============================================================

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


def erdos_renyi(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


def compute_cycle_births(n, edges, weights):
    order = np.argsort(weights)
    uf = UnionFind(n)
    cb_indices = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            cb_indices.append(idx)
    return cb_indices


def rank_transform(weights, cb_indices, all_weights):
    """Transform cycle-birth weights to rank scale."""
    sorted_all = np.sort(all_weights)
    ranks = np.searchsorted(sorted_all, weights[cb_indices], side='right') / len(all_weights)
    return ranks


# ============================================================
# Generate data
# ============================================================

rng = np.random.default_rng(42)
n = 200
p = 0.2
num_trials = 8

# Generate a fixed graph structure
edges = erdos_renyi(n, p, rng)
m = len(edges)

distributions = {
    'Uniform[0,1]': lambda: rng.uniform(0, 1, m),
    'Exponential(1)': lambda: rng.exponential(1.0, m),
    'Normal(0,1)': lambda: rng.standard_normal(m),
}

dist_colors = {'Uniform[0,1]': '#2196F3', 'Exponential(1)': '#FF5722', 'Normal(0,1)': '#4CAF50'}

# ============================================================
# Create figure
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Universality of Cycle-Birth Distributions Under Monotone Transport',
             fontsize=16, fontweight='bold', y=0.98)

for col, (dist_name, gen_weights) in enumerate(distributions.items()):
    ax_raw = axes[0, col]
    ax_transport = axes[1, col]

    for trial in range(num_trials):
        weights = gen_weights()
        cb_indices = compute_cycle_births(n, edges, weights)

        if len(cb_indices) == 0:
            continue

        # Raw CDF
        cb_raw = np.sort(weights[cb_indices])
        raw_cdf = np.arange(1, len(cb_raw) + 1) / len(cb_raw)
        ax_raw.step(cb_raw, raw_cdf, color=dist_colors[dist_name],
                   alpha=0.4, linewidth=0.8, where='post')

        # Transported CDF (rank transform)
        cb_ranks = rank_transform(weights, cb_indices, weights)
        cb_ranks_sorted = np.sort(cb_ranks)
        transport_cdf = np.arange(1, len(cb_ranks_sorted) + 1) / len(cb_ranks_sorted)
        ax_transport.step(cb_ranks_sorted, transport_cdf, color=dist_colors[dist_name],
                         alpha=0.4, linewidth=0.8, where='post')

    # Labels and formatting
    ax_raw.set_title(f'{dist_name}\n(Raw weights)', fontsize=12, fontweight='bold')
    ax_raw.set_xlabel('Weight', fontsize=10)
    ax_raw.set_ylabel('Empirical CDF', fontsize=10)
    ax_raw.set_ylim(-0.05, 1.05)
    ax_raw.grid(True, alpha=0.3)

    ax_transport.set_title(f'{dist_name}\n(After monotone transport)', fontsize=12, fontweight='bold')
    ax_transport.set_xlabel('Rank (uniform scale)', fontsize=10)
    ax_transport.set_ylabel('Empirical CDF', fontsize=10)
    ax_transport.set_xlim(-0.05, 1.05)
    ax_transport.set_ylim(-0.05, 1.05)
    ax_transport.grid(True, alpha=0.3)

    # Add diagonal reference line to transported plots
    ax_transport.plot([0, 1], [0, 1], 'k--', alpha=0.3, linewidth=1, label='y = x')

# Add annotations
axes[0, 0].set_ylabel('Raw CDF', fontsize=12, fontweight='bold')
axes[1, 0].set_ylabel('Transported CDF', fontsize=12, fontweight='bold')

fig.text(0.5, 0.49, '↓  Monotone transport (probability integral transform)  ↓',
         ha='center', fontsize=13, fontweight='bold', color='#666666')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.subplots_adjust(hspace=0.45)
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
