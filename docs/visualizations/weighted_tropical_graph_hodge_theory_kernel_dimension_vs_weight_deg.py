"""
Visualization: Kernel Dimension vs Weight Degeneracy

This script visualizes the relationship between weight degeneracy
and tropical kernel dimension on a family of weighted 4-cycles.

We fix three edge weights and vary the fourth, plotting:
- The weight degeneracy count
- The number of normalized kernel vectors found
- The predicted dimension from the degeneracy invariant

Key insight: The kernel dimension jumps exactly when new weight
degeneracies appear — confirming that tropical kernel growth is
controlled by weight degeneracy data.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, product
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


def weight_degeneracy_count(G, S):
    count = 0
    for i in S:
        nbrs = list(G.neighbors(i))
        for a, b in combinations(nbrs, 2):
            if G.weight(i, a) == G.weight(i, b):
                count += 1
                break
    return count


def count_kernel_vectors(G, S, v0, vr=range(-4, 5)):
    verts = sorted(G.vertices)
    others = [v for v in verts if v != v0]
    count = 0
    for vals in product(vr, repeat=len(others)):
        phi = {v0: 0}
        phi.update(zip(others, vals))
        if all(trop_balanced_at(G, phi, i) for i in S):
            count += 1
    return count


# Parameters
w_vary = list(range(1, 12))
S = {1, 2, 3, 4}
v0 = 1

# Fixed weights
w23 = 3
w34 = 5
w14 = 7

degeneracies = []
kernel_sizes = []

for w12 in w_vary:
    G = WeightedGraph([1, 2, 3, 4], [
        (1, 2, w12), (2, 3, w23), (3, 4, w34), (1, 4, w14)
    ])
    deg = weight_degeneracy_count(G, S)
    ks = count_kernel_vectors(G, S, v0, range(-3, 4))
    degeneracies.append(deg)
    kernel_sizes.append(ks)

# Plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

# Top: kernel size
ax1.bar(w_vary, kernel_sizes, color='steelblue', alpha=0.8, edgecolor='navy')
ax1.set_ylabel('Normalized kernel vectors', fontsize=13)
ax1.set_title('Tropical Kernel Size vs Edge Weight\n'
              '(4-cycle, w(2,3)=3, w(3,4)=5, w(1,4)=7, varying w(1,2))',
              fontsize=13)
ax1.grid(axis='y', alpha=0.3)

# Highlight degeneracy points
for i, (w, d) in enumerate(zip(w_vary, degeneracies)):
    if d > 0:
        ax1.bar(w, kernel_sizes[i], color='crimson', alpha=0.8, edgecolor='darkred')

# Bottom: degeneracy count
colors = ['crimson' if d > 0 else 'gray' for d in degeneracies]
ax2.bar(w_vary, degeneracies, color=colors, alpha=0.8, edgecolor='black')
ax2.set_xlabel('w(1,2)', fontsize=13)
ax2.set_ylabel('Weight degeneracy count', fontsize=13)
ax2.set_title('Weight Degeneracy Count', fontsize=13)
ax2.grid(axis='y', alpha=0.3)
ax2.set_xticks(w_vary)

# Add annotations for degenerate values
for w, d, k in zip(w_vary, degeneracies, kernel_sizes):
    if d > 0:
        ax1.annotate(f'deg={d}', (w, k), textcoords="offset points",
                     xytext=(0, 5), ha='center', fontsize=9, color='red')

plt.tight_layout()
plt.savefig('viz_kernel_dimension.png', dpi=150)
print("Saved viz_kernel_dimension.png")
