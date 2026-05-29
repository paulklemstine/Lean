"""
Visualization: Concentration of Tropical Critical Distributions

This script visualizes the concentration phenomenon for cycle-birth CDFs
in random Erdős-Rényi graphs. Multiple independent trials of G(n,p) with
uniform random weights produce cycle-birth CDFs that concentrate around
a deterministic limit as n grows.

The plot shows overlaid empirical CDFs from independent trials at different
graph sizes, demonstrating tighter concentration at larger n.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


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
    cb_weights = []
    for idx in order:
        u, v = edges[idx]
        if not uf.union(u, v):
            cb_weights.append(weights[idx])
    return np.array(cb_weights)


# ============================================================
# Generate data
# ============================================================

rng = np.random.default_rng(42)
p = 0.15
n_values = [50, 100, 200, 500]
num_trials = 15
t_grid = np.linspace(0, 1, 300)

# ============================================================
# Create figure
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Concentration of Cycle-Birth CDFs in G(n, p)',
             fontsize=16, fontweight='bold', y=0.98)

colors = plt.cm.viridis(np.linspace(0.2, 0.8, num_trials))

for ax_idx, (ax, n) in enumerate(zip(axes.flat, n_values)):
    cdfs = []
    for trial in range(num_trials):
        edges = erdos_renyi(n, p, rng)
        if len(edges) == 0:
            continue
        weights = rng.uniform(0, 1, len(edges))
        cb = compute_cycle_births(n, edges, weights)
        if len(cb) > 0:
            cdf = np.searchsorted(np.sort(cb), t_grid, side='right') / len(cb)
            cdfs.append(cdf)
            ax.plot(t_grid, cdf, color=colors[trial], alpha=0.4, linewidth=0.8)

    if cdfs:
        mean_cdf = np.mean(cdfs, axis=0)
        ax.plot(t_grid, mean_cdf, 'k-', linewidth=2.5, label='Mean CDF')

        # Shade ±1 std
        std_cdf = np.std(cdfs, axis=0)
        ax.fill_between(t_grid, mean_cdf - std_cdf, mean_cdf + std_cdf,
                        alpha=0.2, color='steelblue', label='±1 std')

    ax.set_title(f'n = {n}  (p = {p})', fontsize=13, fontweight='bold')
    ax.set_xlabel('Threshold t', fontsize=11)
    ax.set_ylabel('Empirical CDF', fontsize=11)
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.05, 1.05)
    ax.legend(loc='lower right', fontsize=9)
    ax.grid(True, alpha=0.3)

    if cdfs:
        max_std = np.max(std_cdf)
        ax.text(0.05, 0.92, f'max std = {max_std:.3f}',
                transform=ax.transAxes, fontsize=10,
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")
