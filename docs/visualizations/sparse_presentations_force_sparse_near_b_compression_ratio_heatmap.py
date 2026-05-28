#!/usr/bin/env python3
"""
Visualization: Heatmap of Compression Ratios

Shows the ratio QLC / C(n, r-2) across different values of n and Δ,
revealing how sparsity in the bipartite presentation compresses the
near-basis geometry. Darker cells indicate stronger compression
(fewer near-bases relative to the ambient bound).
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import itertools
from math import comb


def find_max_matching(adj, n_right):
    match_l, match_r = {}, {}
    def augment(u, visited):
        for v in adj[u]:
            if v in visited: continue
            visited.add(v)
            if v not in match_r or augment(match_r[v], visited):
                match_l[u] = v; match_r[v] = u; return True
        return False
    for u in range(len(adj)):
        augment(u, set())
    return match_l


def is_independent(subset, adj, n_right):
    if not subset: return True
    sub_adj = [adj[v] for v in subset]
    return len(find_max_matching(sub_adj, n_right)) == len(subset)


def compute_qlc(adj, n_right, rank):
    target = rank - 2
    if target <= 0: return 1 if target == 0 else 0
    return sum(1 for s in itertools.combinations(range(len(adj)), target)
               if is_independent(s, adj, n_right))


ns = [4, 5, 6, 7, 8, 9, 10]
deltas = [2, 3, 4, 5, 6]

ratio_matrix = np.zeros((len(deltas), len(ns)))
qlc_matrix = np.zeros((len(deltas), len(ns)))
rank_matrix = np.zeros((len(deltas), len(ns)))

for i, delta in enumerate(deltas):
    for j, n in enumerate(ns):
        random.seed(42 + n * 100 + delta)
        adj = []
        for _ in range(n):
            deg = random.randint(1, min(delta, n))
            adj.append(sorted(random.sample(range(n), deg)))

        rank = len(find_max_matching(adj, n))
        qlc = compute_qlc(adj, n, rank)
        bound = comb(n, max(0, rank - 2))

        ratio_matrix[i, j] = qlc / max(1, bound)
        qlc_matrix[i, j] = qlc
        rank_matrix[i, j] = rank

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Compression ratio heatmap
im1 = axes[0].imshow(ratio_matrix, cmap='RdYlGn_r', aspect='auto',
                       vmin=0, vmax=1)
axes[0].set_xticks(range(len(ns)))
axes[0].set_xticklabels(ns)
axes[0].set_yticks(range(len(deltas)))
axes[0].set_yticklabels(deltas)
axes[0].set_xlabel('Number of vertices (n)', fontsize=12)
axes[0].set_ylabel('Maximum degree (Δ)', fontsize=12)
axes[0].set_title('Compression Ratio: QLC / C(n, r-2)', fontsize=13)

for i in range(len(deltas)):
    for j in range(len(ns)):
        color = 'white' if ratio_matrix[i, j] > 0.5 else 'black'
        axes[0].text(j, i, f'{ratio_matrix[i,j]:.2f}',
                     ha='center', va='center', color=color, fontsize=9)

plt.colorbar(im1, ax=axes[0], label='Ratio (0=max compression, 1=no compression)')

# Panel 2: Absolute QLC values
im2 = axes[1].imshow(qlc_matrix, cmap='viridis', aspect='auto')
axes[1].set_xticks(range(len(ns)))
axes[1].set_xticklabels(ns)
axes[1].set_yticks(range(len(deltas)))
axes[1].set_yticklabels(deltas)
axes[1].set_xlabel('Number of vertices (n)', fontsize=12)
axes[1].set_ylabel('Maximum degree (Δ)', fontsize=12)
axes[1].set_title('Quadratic Leaf Count (absolute)', fontsize=13)

for i in range(len(deltas)):
    for j in range(len(ns)):
        val = int(qlc_matrix[i, j])
        color = 'white' if qlc_matrix[i, j] < np.median(qlc_matrix) else 'black'
        axes[1].text(j, i, str(val), ha='center', va='center',
                     color=color, fontsize=9)

plt.colorbar(im2, ax=axes[1], label='QLC')

plt.tight_layout()
plt.savefig('heatmap.png', dpi=150, bbox_inches='tight')
print("Saved heatmap.png")
