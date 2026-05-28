"""
Visualization: Compression Ratios Across Matroid Families

This script creates a heatmap showing how the compression ratio
(actual quadratic leaves / ambient leaf count) varies across different
matroid families and parameters. The key insight is that sparse matroids
achieve significant compression, while uniform matroids show no compression.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


# ======== Self-contained algorithm implementations ========

def independent_sets_of_size(bases, n, k):
    result = []
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= B for B in bases):
            result.append(fs)
    return result


def count_leaves(bases, n, r):
    if r < 2:
        return 1
    return len(independent_sets_of_size(bases, n, r - 2))


def uniform_bases(n, r):
    return [frozenset(s) for s in combinations(range(n), r)]


def graphic_bases(edges, nv):
    ne = len(edges)
    rank = nv - 1
    bases = []
    for subset in combinations(range(ne), rank):
        adj = {v: set() for v in range(nv)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == nv:
            bases.append(frozenset(subset))
    return bases


# ======== Generate data ========

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Uniform matroid leaf counts vs C(n, r-2)
ns = range(4, 13)
rs = [3, 4, 5]
colors = ['#2196F3', '#FF5722', '#4CAF50']

ax1 = axes[0]
for r, color in zip(rs, colors):
    actual_vals = []
    expected_vals = []
    valid_ns = []
    for n in ns:
        if r <= n:
            bases = uniform_bases(n, r)
            actual = count_leaves(bases, n, r)
            expected = comb(n, r - 2)
            actual_vals.append(actual)
            expected_vals.append(expected)
            valid_ns.append(n)

    ax1.plot(valid_ns, expected_vals, 'o-', color=color, label=f'r={r}', linewidth=2)
    ax1.plot(valid_ns, actual_vals, 'x', color=color, markersize=10, markeredgewidth=2)

ax1.set_xlabel('n (ground set size)', fontsize=12)
ax1.set_ylabel('Quadratic leaf count', fontsize=12)
ax1.set_title('Uniform Matroid: Leaves = C(n, r−2)', fontsize=13)
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Compression ratios for graphic matroids
ax2 = axes[1]
graph_data = []

# Complete graphs K_n
for nv in range(4, 7):
    edges = [(i,j) for i in range(nv) for j in range(i+1,nv)]
    ne = len(edges)
    rank = nv - 1
    if rank < 2:
        continue
    bases = graphic_bases(edges, nv)
    if bases:
        actual = count_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 1
        graph_data.append((f'K_{nv}', ratio, 'Complete'))

# Cycle graphs C_n
for nv in range(4, 9):
    edges = [(i, (i+1)%nv) for i in range(nv)]
    ne = len(edges)
    rank = nv - 1
    if rank < 2:
        continue
    bases = graphic_bases(edges, nv)
    if bases:
        actual = count_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 1
        graph_data.append((f'C_{nv}', ratio, 'Cycle'))

# Path graphs P_n
for nv in range(4, 9):
    edges = [(i, i+1) for i in range(nv-1)]
    ne = len(edges)
    rank = nv - 1
    if rank < 2:
        continue
    bases = graphic_bases(edges, nv)
    if bases:
        actual = count_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 1
        graph_data.append((f'P_{nv}', ratio, 'Path'))

# Sort and plot
categories = {'Complete': '#E53935', 'Cycle': '#1E88E5', 'Path': '#43A047'}
for cat, color in categories.items():
    items = [(name, ratio) for name, ratio, c in graph_data if c == cat]
    if items:
        names, ratios = zip(*items)
        ax2.barh(list(names), list(ratios), color=color, alpha=0.8, label=cat, height=0.6)

ax2.set_xlabel('Compression ratio (actual / ambient)', fontsize=12)
ax2.set_title('Graphic Matroid Compression', fontsize=13)
ax2.legend(fontsize=11)
ax2.axvline(x=1.0, color='gray', linestyle='--', alpha=0.5)
ax2.set_xlim(0, 1.15)
ax2.grid(True, alpha=0.3, axis='x')

# Panel 3: Active variables vs compression
ax3 = axes[2]
n_total = 10
r_val = 4

# Create different matroids with varying numbers of active variables
data_points = []

# Single basis with k elements
for k in range(r_val, n_total + 1):
    single_basis = [frozenset(range(k))]
    actual = count_leaves(single_basis, n_total, r_val)
    active = len(set().union(*single_basis))
    data_points.append((active, actual))

# Multiple bases
for num_bases in range(1, 6):
    bases = []
    for start in range(num_bases):
        b = frozenset(range(start, start + r_val))
        if max(b) < n_total:
            bases.append(b)
    if bases:
        actual = count_leaves(bases, n_total, r_val)
        active = len(set().union(*bases))
        data_points.append((active, actual))

actives, actuals = zip(*sorted(set(data_points)))
ambient_val = comb(n_total, r_val - 2)

ax3.plot(actives, actuals, 'o-', color='#7B1FA2', linewidth=2, markersize=8,
         label='Actual leaves')
ax3.axhline(y=ambient_val, color='gray', linestyle='--', alpha=0.7,
            label=f'Ambient C({n_total},{r_val-2})={ambient_val}')

# Plot C(active, r-2) bound
act_range = range(r_val - 2, n_total + 1)
bounds = [comb(a, r_val - 2) for a in act_range]
ax3.plot(list(act_range), bounds, 's--', color='#FF9800', alpha=0.7,
         label=f'Bound C(active, {r_val-2})')

ax3.set_xlabel('Number of active variables', fontsize=12)
ax3.set_ylabel('Quadratic leaf count', fontsize=12)
ax3.set_title(f'Active Variables vs Leaves (n={n_total}, r={r_val})', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('compression_analysis.png', dpi=150, bbox_inches='tight')
print("Saved visualization to compression_analysis.png")
