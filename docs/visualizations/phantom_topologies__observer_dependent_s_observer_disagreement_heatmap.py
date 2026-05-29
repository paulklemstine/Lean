"""
Visualization: Observer Disagreement Heatmap
=============================================
Shows pairwise disagreement between all topologies on a 3-element set.
Each cell represents the symmetric difference (number of sets where two
topologies disagree on openness). Reveals the metric structure of the
space of all topologies — a key insight of phantom topology theory.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, chain


def powerset(s):
    s = list(s)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def is_topology(X, opens):
    opens_set = {frozenset(o) for o in opens}
    X_frozen = frozenset(X)
    if frozenset() not in opens_set or X_frozen not in opens_set:
        return False
    for a in opens_set:
        for b in opens_set:
            if (a & b) not in opens_set:
                return False
    opens_list = list(opens_set)
    for subset_indices in powerset(list(range(len(opens_list)))):
        union = frozenset()
        for i in subset_indices:
            union = union | opens_list[i]
        if union not in opens_set:
            return False
    return True


def enumerate_topologies(X):
    all_subsets = [tuple(sorted(s)) for s in powerset(X)]
    topologies = []
    for r in range(len(all_subsets) + 1):
        for combo in combinations(all_subsets, r):
            candidate = list(combo)
            if is_topology(X, candidate):
                topologies.append({frozenset(o) for o in candidate})
    return topologies


# Enumerate all 29 topologies on {0, 1, 2}
X = [0, 1, 2]
tops = enumerate_topologies(X)
n = len(tops)

# Compute disagreement matrix
D = np.zeros((n, n), dtype=int)
for i in range(n):
    for j in range(n):
        D[i, j] = len(tops[i].symmetric_difference(tops[j]))

# Sort topologies by size (number of open sets)
sizes = [len(t) for t in tops]
order = np.argsort(sizes)
D_sorted = D[np.ix_(order, order)]
sizes_sorted = [sizes[o] for o in order]

fig, ax = plt.subplots(figsize=(10, 8))

im = ax.imshow(D_sorted, cmap='YlOrRd', interpolation='nearest')
ax.set_title(f'Disagreement Matrix: All {n} Topologies on {{0,1,2}}',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Topology index (sorted by size)', fontsize=11)
ax.set_ylabel('Topology index (sorted by size)', fontsize=11)

# Add colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Symmetric difference |τ₁ △ τ₂|', fontsize=11)

# Add size annotations on axis
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels([f'{sizes_sorted[i]}' for i in range(n)], fontsize=6)
ax.set_yticklabels([f'{sizes_sorted[i]}' for i in range(n)], fontsize=6)

# Add text showing some interesting statistics
max_dis = D.max()
avg_dis = D[np.triu_indices(n, k=1)].mean()
ax.text(0.02, 0.98, f'Max disagreement: {max_dis}\nAvg disagreement: {avg_dis:.1f}\n'
        f'Tick labels = |τ| (# open sets)',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_disagreement_heatmap.png', dpi=150, bbox_inches='tight')
print(f"Saved viz_disagreement_heatmap.png")
print(f"Number of topologies on {{0,1,2}}: {n}")
print(f"Max disagreement: {max_dis}")
print(f"Average disagreement: {avg_dis:.1f}")
