"""
Visualization: Scaling Behavior of Support-Compressed Leaf Counts

This script shows how compressed leaf counts scale compared to naive
ambient counts across different matroid families, demonstrating the
practical impact of support geometry on Lorentzian certification complexity.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb, factorial


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


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Uniform matroid - exact match with C(n, r-2)
ax1 = axes[0, 0]
for r, color, marker in [(3, '#2196F3', 'o'), (4, '#FF5722', 's'), (5, '#4CAF50', '^')]:
    ns = list(range(r, 14))
    leaves = [comb(n, r - 2) for n in ns]
    ax1.plot(ns, leaves, f'{marker}-', color=color, label=f'r = {r}', linewidth=2, markersize=6)

ax1.set_xlabel('n (ground set size)', fontsize=12)
ax1.set_ylabel('Quadratic leaf count', fontsize=12)
ax1.set_title('Uniform Matroid U_{r,n}: Leaves = C(n, r−2)', fontsize=13)
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Single basis compression
ax2 = axes[0, 1]
n_val = 12
for r, color in [(4, '#2196F3'), (5, '#FF5722'), (6, '#4CAF50')]:
    basis_sizes = list(range(r, n_val + 1))
    leaf_counts = [comb(k, r - 2) for k in basis_sizes]
    ambient = comb(n_val, r - 2)
    ax2.plot(basis_sizes, leaf_counts, 'o-', color=color, linewidth=2,
             label=f'r={r}, ambient={ambient}')
    ax2.axhline(y=ambient, color=color, linestyle='--', alpha=0.3)

ax2.set_xlabel('Basis size (|B|)', fontsize=12)
ax2.set_ylabel('Leaf count C(|B|, r−2)', fontsize=12)
ax2.set_title(f'Single-Basis Compression (n={n_val})', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Graphic matroid compression for complete graphs
ax3 = axes[1, 0]
complete_data = []
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
        complete_data.append((nv, ne, actual, ambient))

if complete_data:
    nvs = [d[0] for d in complete_data]
    actuals = [d[2] for d in complete_data]
    ambients = [d[3] for d in complete_data]

    x_pos = np.arange(len(nvs))
    width = 0.35

    bars1 = ax3.bar(x_pos - width/2, actuals, width, label='Actual leaves',
                    color='#4CAF50', alpha=0.8)
    bars2 = ax3.bar(x_pos + width/2, ambients, width, label='Ambient C(|E|, r−2)',
                    color='#FF9800', alpha=0.8)

    ax3.set_xlabel('Graph', fontsize=12)
    ax3.set_ylabel('Leaf count', fontsize=12)
    ax3.set_title('Complete Graph Compression', fontsize=13)
    ax3.set_xticks(x_pos)
    ax3.set_xticklabels([f'K_{nv}' for nv in nvs])
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3, axis='y')

    # Add ratio labels
    for i, (a, b) in enumerate(zip(actuals, ambients)):
        ratio = a / b if b > 0 else 1
        ax3.text(i, max(a, b) + 2, f'{ratio:.3f}', ha='center',
                 fontsize=10, fontweight='bold')

# Panel 4: Theoretical bounds comparison
ax4 = axes[1, 1]
ns_theory = np.arange(5, 20)
r_theory = 4

ambient_bounds = [comb(int(n), r_theory - 2) for n in ns_theory]
# For a matroid with k active variables
for k_frac, color, label in [
    (1.0, '#9E9E9E', 'Ambient C(n, r−2)'),
    (0.7, '#FF9800', 'C(0.7n, r−2)'),
    (0.5, '#2196F3', 'C(0.5n, r−2)'),
    (0.3, '#4CAF50', 'C(0.3n, r−2)'),
]:
    vals = [comb(max(r_theory - 2, int(n * k_frac)), r_theory - 2) for n in ns_theory]
    ax4.plot(ns_theory, vals, '-', color=color, linewidth=2, label=label)

ax4.set_xlabel('n (ground set size)', fontsize=12)
ax4.set_ylabel('Leaf count bound', fontsize=12)
ax4.set_title(f'Compression by Active Variable Fraction (r={r_theory})', fontsize=13)
ax4.legend(fontsize=10)
ax4.set_yscale('log')
ax4.grid(True, alpha=0.3)

plt.suptitle('Support-Compressed Leaf Counting: Scaling Analysis', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('scaling_analysis.png', dpi=150, bbox_inches='tight')
print("Saved visualization to scaling_analysis.png")
