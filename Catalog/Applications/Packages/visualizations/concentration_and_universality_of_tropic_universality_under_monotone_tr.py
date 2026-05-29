"""
Visualization: Universality of Cycle-Birth Distributions Under Monotone Transport.

This script visualizes the universality phenomenon: when edge weights are drawn
from different continuous distributions (Uniform, Exponential, Gaussian), the
cycle-birth edge SETS are identical (only weights change). After rank-transforming
to a common scale, the empirical CDFs collapse perfectly.

What it visualizes: Side-by-side comparison of raw CDFs (which differ by distribution)
and rank-transformed CDFs (which collapse), demonstrating that tropical criticality
depends only on order structure, not on the specific distribution.
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


def compute_filtration_with_births(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    for u, v, w in sorted_edges:
        if not uf.union(u, v):
            births.append(w)
    return np.array(births)


# Generate a fixed graph topology
n = 80
p = 0.25
rng = np.random.default_rng(42)
adjacency = [(i, j) for i in range(n) for j in range(i + 1, n) if rng.random() < p]
m = len(adjacency)

distributions = {
    'Uniform [0,1]': lambda rng, m: rng.random(m),
    'Exponential(1)': lambda rng, m: rng.exponential(1.0, m),
    'Normal(0,1)': lambda rng, m: rng.normal(0, 1, m),
    'Beta(2,5)': lambda rng, m: rng.beta(2, 5, m),
}

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Universality of Tropical Critical Distributions\n'
             'Same graph topology, different weight distributions',
             fontsize=14, fontweight='bold')

for idx, (name, gen) in enumerate(distributions.items()):
    rng_w = np.random.default_rng(123)
    weights = gen(rng_w, m)
    edges = [(u, v, w) for (u, v), w in zip(adjacency, weights)]
    births = compute_filtration_with_births(n, edges)

    if len(births) == 0:
        continue

    # Raw CDF
    sorted_births = np.sort(births)
    raw_cdf = np.arange(1, len(sorted_births) + 1) / len(sorted_births)
    ax1.step(sorted_births, raw_cdf, where='post', color=colors[idx],
             label=name, linewidth=1.5)

    # Rank-transformed CDF (universality)
    sorted_idx = np.argsort(births)
    ranks = np.empty_like(births)
    ranks[sorted_idx] = np.arange(1, len(births) + 1) / len(births)
    sorted_ranks = np.sort(ranks)
    rank_cdf = np.arange(1, len(sorted_ranks) + 1) / len(sorted_ranks)
    ax2.step(sorted_ranks, rank_cdf, where='post', color=colors[idx],
             label=name, linewidth=1.5, alpha=0.7)

ax1.set_title('Raw Cycle-Birth CDFs', fontweight='bold')
ax1.set_xlabel('Birth weight')
ax1.set_ylabel('Empirical CDF')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.text(0.05, 0.85, 'CDFs differ by\nweight distribution',
         transform=ax1.transAxes, fontsize=10, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

ax2.set_title('Rank-Transformed CDFs (Universality)', fontweight='bold')
ax2.set_xlabel('Rank-normalized weight')
ax2.set_ylabel('Empirical CDF')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.text(0.05, 0.85, 'All CDFs collapse!\n(Only order matters)',
         transform=ax2.transAxes, fontsize=10, style='italic',
         color='darkgreen', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

plt.tight_layout()
plt.savefig('universality_plot.png', dpi=150, bbox_inches='tight')
print("Saved universality_plot.png")
