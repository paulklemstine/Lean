"""
Visualization: Tropical Balance Heatmap

This script visualizes how tropical balance depends on edge weights
by showing a heatmap of balance status across a 2-parameter family
of weighted triangles.

For a triangle with vertices {1,2,3}, we fix w(2,3)=3 and vary
w(1,2) and w(1,3) from 1 to 10. The heatmap shows the number of
tropically balanced vertices (under the zero potential) as the
weights change.

Key insight: Balance (minimum attained twice) occurs exactly along
weight-degeneracy lines where w(1,2) = w(1,3) or similar equalities.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


class WeightedGraph:
    def __init__(self, vertices, edges):
        self.vertices = set(vertices)
        self.adj = defaultdict(set)
        self.weights = {}
        for u, v, w in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v):
        return self.adj[v]

    def weight(self, u, v):
        return self.weights.get((u, v), 0)


def trop_balanced_at(G, phi, i):
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False
    vals = [G.weight(i, j) + phi.get(j, 0) for j in nbrs]
    min_val = min(vals)
    return vals.count(min_val) >= 2


# Generate heatmap data
w23 = 3
w12_range = np.arange(1, 11)
w13_range = np.arange(1, 11)

balance_count = np.zeros((len(w13_range), len(w12_range)))
phi_zero = {1: 0, 2: 0, 3: 0}

for i, w13 in enumerate(w13_range):
    for j, w12 in enumerate(w12_range):
        G = WeightedGraph([1, 2, 3], [
            (1, 2, int(w12)), (1, 3, int(w13)), (2, 3, w23)
        ])
        count = sum(1 for v in [1, 2, 3] if trop_balanced_at(G, phi_zero, v))
        balance_count[i, j] = count

# Plot
fig, ax = plt.subplots(1, 1, figsize=(8, 7))

im = ax.imshow(balance_count, origin='lower', aspect='auto',
               extent=[0.5, 10.5, 0.5, 10.5],
               cmap='YlOrRd', vmin=0, vmax=3)

ax.set_xlabel('w(1,2)', fontsize=14)
ax.set_ylabel('w(1,3)', fontsize=14)
ax.set_title('Tropical Balance Count on Weighted Triangle\n'
             '(zero potential, w(2,3)=3 fixed)', fontsize=14)

cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Number of balanced vertices', fontsize=12)

# Mark the degeneracy lines
ax.plot([1, 10], [1, 10], 'w--', linewidth=2, label='w(1,2) = w(1,3)')
ax.axhline(y=3, color='cyan', linestyle='--', linewidth=1.5, alpha=0.7,
           label='w(1,3) = w(2,3) = 3')
ax.axvline(x=3, color='lime', linestyle='--', linewidth=1.5, alpha=0.7,
           label='w(1,2) = w(2,3) = 3')

ax.legend(loc='upper left', fontsize=10, framealpha=0.9)
ax.set_xticks(range(1, 11))
ax.set_yticks(range(1, 11))

plt.tight_layout()
plt.savefig('viz_balance_heatmap.png', dpi=150)
print("Saved viz_balance_heatmap.png")
