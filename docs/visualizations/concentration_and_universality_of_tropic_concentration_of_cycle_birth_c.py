"""
Visualization: Concentration of Cycle-Birth CDFs.

This script visualizes the concentration phenomenon for cycle-birth CDFs
in Erdős-Rényi random graphs. As n increases, the empirical CDFs from
independent trials converge to a common limit, confirming that tropical
critical values behave like a concentrated spectral observable.

What it visualizes: Multiple overlaid empirical CDFs for different graph sizes,
showing convergence. This is the visual analogue of the semicircle law converging
for random matrix eigenvalues.
"""

import numpy as np
import matplotlib.pyplot as plt


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


def compute_cycle_births(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j, rng.random()))
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            births.append(w)
    return np.array(births)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Concentration of Tropical Critical Distributions\n'
             'Cycle-Birth CDFs in G(n, 0.15) with Uniform Weights',
             fontsize=14, fontweight='bold')

p = 0.15
n_values = [50, 100, 200, 500]
num_trials = 15
rng = np.random.default_rng(42)
grid = np.linspace(0, 1, 300)
colors = plt.cm.viridis(np.linspace(0.2, 0.8, num_trials))

for idx, n in enumerate(n_values):
    ax = axes[idx // 2, idx % 2]

    for trial in range(num_trials):
        births = compute_cycle_births(n, p, rng)
        if len(births) > 0:
            cdf = np.array([np.mean(births <= t) for t in grid])
            ax.plot(grid, cdf, color=colors[trial], alpha=0.5, linewidth=0.8)

    ax.set_title(f'n = {n}', fontsize=12, fontweight='bold')
    ax.set_xlabel('Weight threshold t')
    ax.set_ylabel('Empirical CDF F(t)')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

    # Add annotation about spread
    ax.text(0.05, 0.92, f'{num_trials} independent trials',
            transform=ax.transAxes, fontsize=9,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('concentration_plot.png', dpi=150, bbox_inches='tight')
print("Saved concentration_plot.png")
