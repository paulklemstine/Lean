#!/usr/bin/env python3
"""
Visualization: Congestion Heatmap for the Complete 2-Complex on 5 Vertices

Shows the per-triangle congestion (how much each triangle is used by canonical
fillings) as a heatmap. Uniform congestion is optimal and indicates the
canonical filling distributes load evenly, analogous to balanced routing in networks.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def build_complete_complex(n):
    vertices = list(range(n))
    edges = list(combinations(vertices, 2))
    triangles = list(combinations(vertices, 3))
    edge_index = {e: i for i, e in enumerate(edges)}
    ne, nt = len(edges), len(triangles)

    b2 = np.zeros((ne, nt))
    for t_idx, (i, j, k) in enumerate(triangles):
        b2[edge_index[(j, k)], t_idx] += 1
        b2[edge_index[(i, k)], t_idx] -= 1
        b2[edge_index[(i, j)], t_idx] += 1

    b1 = np.zeros((n, ne))
    for e_idx, (i, j) in enumerate(edges):
        b1[j, e_idx] += 1
        b1[i, e_idx] -= 1

    return edges, triangles, b2, b1


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Canonical Filling Congestion Analysis', fontsize=14, fontweight='bold')

for idx, n in enumerate([4, 5, 6]):
    edges, triangles, b2, b1 = build_complete_complex(n)

    U, S, Vt = np.linalg.svd(b1)
    rank = np.sum(S > 1e-10)
    cycles = Vt[rank:, :]

    # Compute filling matrix (each row = filling for one cycle)
    filling_matrix = np.zeros((cycles.shape[0], len(triangles)))
    for i in range(cycles.shape[0]):
        z = cycles[i]
        F, _, _, _ = np.linalg.lstsq(b2, z, rcond=None)
        filling_matrix[i] = F

    # Congestion: squared filling coefficients
    congestion_matrix = filling_matrix ** 2

    ax = axes[idx]
    im = ax.imshow(congestion_matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    ax.set_xlabel(f'Triangle index (of {len(triangles)})', fontsize=10)
    ax.set_ylabel(f'Cycle index (of {cycles.shape[0]})', fontsize=10)
    ax.set_title(f'K_{n}: {len(edges)} edges, {len(triangles)} triangles', fontsize=11)
    plt.colorbar(im, ax=ax, label='|F(z)(τ)|²')

    # Per-triangle total congestion
    total_per_tri = np.sum(congestion_matrix, axis=0)
    max_cong = np.max(total_per_tri)
    min_cong = np.min(total_per_tri)
    ax.text(0.02, 0.98, f'Max cong: {max_cong:.3f}\nMin cong: {min_cong:.3f}',
            transform=ax.transAxes, va='top', fontsize=8,
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_congestion.png', dpi=150, bbox_inches='tight')
print("Saved viz_congestion.png")
