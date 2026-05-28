"""
Visualization: Double-Counting Edge Bound

Illustrates the Fisher-type inequality |E| · C(d,2) ≤ K · C(n,2)
by showing how the maximum number of edges grows with n and K
for different values of d. Also shows the empirical edge counts
from random hypergraphs to demonstrate tightness.

Uses matplotlib.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations
import random


def generate_bounded_codegree_hypergraph(n, d, K, max_edges=200):
    """Generate a random d-uniform hypergraph with pair codegree ≤ K."""
    edges = []
    pair_count = {}
    verts = list(range(n))
    random.shuffle(verts)
    attempts = 0
    while attempts < 5000 and len(edges) < max_edges:
        edge = set(random.sample(range(n), d))
        pairs = list(combinations(sorted(edge), 2))
        if all(pair_count.get(p, 0) < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] = pair_count.get(p, 0) + 1
        attempts += 1
    return edges


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ── Left: Theoretical bounds ──
ax = axes[0]
n_vals = np.arange(5, 51)

for d, K, ls in [(3, 1, '-'), (3, 2, '--'), (4, 1, '-'), (4, 2, '--'), (5, 1, ':')]:
    bounds = [K * comb(n, 2) / comb(d, 2) for n in n_vals]
    ax.plot(n_vals, bounds, ls, linewidth=2, label=f'd={d}, K={K}')

ax.set_xlabel('Number of vertices n', fontsize=13)
ax.set_ylabel('Maximum number of edges', fontsize=13)
ax.set_title('Edge Count Bound: $|E| \\leq \\frac{K \\cdot \\binom{n}{2}}{\\binom{d}{2}}$',
             fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 500)

# ── Right: Empirical vs theoretical ──
ax = axes[1]
random.seed(42)

d = 3
for K in [1, 2, 3]:
    n_range = list(range(6, 26, 2))
    theoretical = [K * comb(n, 2) / comb(d, 2) for n in n_range]
    empirical = []

    for n in n_range:
        counts = []
        for _ in range(20):
            edges = generate_bounded_codegree_hypergraph(n, d, K, max_edges=500)
            counts.append(len(edges))
        empirical.append(np.mean(counts))

    ax.plot(n_range, theoretical, '--', linewidth=2, alpha=0.6,
            color=f'C{K-1}', label=f'K={K} (bound)')
    ax.plot(n_range, empirical, 'o-', linewidth=1.5, markersize=5,
            color=f'C{K-1}', label=f'K={K} (empirical)')

ax.set_xlabel('Number of vertices n', fontsize=13)
ax.set_ylabel('Number of edges', fontsize=13)
ax.set_title('Empirical vs Theoretical Edge Count (d=3)\nDashes = bound, circles = random max',
             fontsize=14)
ax.legend(fontsize=10, ncol=2)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_edge_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_edge_bound.png")
