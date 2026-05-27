#!/usr/bin/env python3
"""
Visualization: Word Metric Quasi-Isometry

Shows that the hybrid word metric is bi-Lipschitz equivalent to the
local word metric, confirming the geometric group theory bridge.

Self-contained — all functions are inlined.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import deque


def bfs_distances(elements, generators, group_op, source):
    """BFS to compute word distances from source."""
    idx = {g: i for i, g in enumerate(elements)}
    n = len(elements)
    dist = [-1] * n
    dist[idx[source]] = 0
    queue = deque([source])
    while queue:
        x = queue.popleft()
        for s in generators:
            y = group_op(x, s)
            j = idx[y]
            if dist[j] == -1:
                dist[j] = dist[idx[x]] + 1
                queue.append(y)
    return dist


def compute_all_distances(n):
    """Compute local and hybrid word distances on (Z/nZ)²."""
    elts = [(i, j) for i in range(n) for j in range(n)]
    op = lambda x, y: ((x[0]+y[0])%n, (x[1]+y[1])%n)

    S_L = [(1,0), (n-1,0), (0,1), (0,n-1)]
    S_G = [(1,1), (n-1,n-1)]
    S_H = list(set(S_L + S_G))

    origin = (0, 0)
    d_local = bfs_distances(elts, S_L, op, origin)
    d_hybrid = bfs_distances(elts, S_H, op, origin)

    return elts, d_local, d_hybrid


# Generate data for n = 15
n = 15
elts, d_local, d_hybrid = compute_all_distances(n)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle(f'Word Metric Comparison on (ℤ/{n}ℤ)²',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Local distances as heatmap
ax = axes[0]
D_local = np.zeros((n, n))
idx = {g: i for i, g in enumerate(elts)}
for (i, j) in elts:
    D_local[i, j] = d_local[idx[(i, j)]]
im = ax.imshow(D_local, cmap='viridis', origin='lower')
ax.set_title('Local Word Distance d_L(0, ·)', fontsize=11)
ax.set_xlabel('j')
ax.set_ylabel('i')
plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

# Panel 2: Hybrid distances as heatmap
ax = axes[1]
D_hybrid = np.zeros((n, n))
for (i, j) in elts:
    D_hybrid[i, j] = d_hybrid[idx[(i, j)]]
im = ax.imshow(D_hybrid, cmap='viridis', origin='lower')
ax.set_title('Hybrid Word Distance d_H(0, ·)', fontsize=11)
ax.set_xlabel('j')
ax.set_ylabel('i')
plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

# Panel 3: Scatter plot d_local vs d_hybrid with bi-Lipschitz bounds
ax = axes[2]
d_L_vals = np.array([d_local[i] for i in range(len(elts))])
d_H_vals = np.array([d_hybrid[i] for i in range(len(elts))])

ax.scatter(d_L_vals, d_H_vals, alpha=0.3, s=15, color='blue')
max_d = max(d_L_vals.max(), d_H_vals.max())
ax.plot([0, max_d], [0, max_d], 'k-', alpha=0.5, label='d_H = d_L')
ax.plot([0, max_d], [0, max_d/2], 'r--', alpha=0.5, label='d_H = d_L/2 (lower)')
ax.set_xlabel('d_local(0, x)', fontsize=12)
ax.set_ylabel('d_hybrid(0, x)', fontsize=12)
ax.set_title('Bi-Lipschitz Equivalence', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('viz_word_metric.png', dpi=150, bbox_inches='tight')
print("Saved viz_word_metric.png")
