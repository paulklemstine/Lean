#!/usr/bin/env python3
"""
Visualization: Curvature-Gap Relationship Heatmap

Shows the relationship between the curvature certificate constant and
the spectral gap across different matroid parameters. Demonstrates the
1/r scaling law and the effect of block size on the gap.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iproduct


def partition_matroid_bases(block_sizes):
    blocks = []
    offset = 0
    for bs in block_sizes:
        blocks.append(list(range(offset, offset + bs)))
        offset += bs
    return list(iproduct(*blocks))


def partition_exchange_matrix(block_sizes):
    bases = partition_matroid_bases(block_sizes)
    n = len(bases)
    r = len(block_sizes)
    P = np.zeros((n, n))
    idx = {b: i for i, b in enumerate(bases)}

    for i, b in enumerate(bases):
        for block_idx in range(r):
            bs = block_sizes[block_idx]
            offset = sum(block_sizes[:block_idx])
            for e in range(bs):
                new_elem = offset + e
                if new_elem != b[block_idx]:
                    nb = list(b)
                    nb[block_idx] = new_elem
                    P[i, idx[tuple(nb)]] = 1.0 / (2 * sum(s - 1 for s in block_sizes))
        P[i, i] = 1.0 - sum(P[i, :])
    return P, bases


def spectral_gap(P):
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    if len(eigenvalues) < 2:
        return 1.0
    return 1.0 - eigenvalues[1]


fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Panel 1: Heatmap of gap · r (should be ≥ C for some universal C)
ranks = list(range(2, 7))
block_sizes_list = list(range(2, 7))
gap_times_r = np.zeros((len(block_sizes_list), len(ranks)))

for i, n in enumerate(block_sizes_list):
    for j, r in enumerate(ranks):
        if n ** r > 5000:  # skip too large
            gap_times_r[i, j] = np.nan
            continue
        P, _ = partition_exchange_matrix([n] * r)
        gap = spectral_gap(P)
        gap_times_r[i, j] = gap * r

ax = axes[0]
im = ax.imshow(gap_times_r, aspect='auto', cmap='viridis',
               interpolation='nearest', vmin=0, vmax=1.5)
ax.set_xticks(range(len(ranks)))
ax.set_xticklabels(ranks)
ax.set_yticks(range(len(block_sizes_list)))
ax.set_yticklabels(block_sizes_list)
ax.set_xlabel('Rank r', fontsize=12)
ax.set_ylabel('Block size n', fontsize=12)
ax.set_title('Gap × Rank (≥ C?)\nPartition Matroids', fontsize=13)

for i in range(len(block_sizes_list)):
    for j in range(len(ranks)):
        if not np.isnan(gap_times_r[i, j]):
            color = 'white' if gap_times_r[i, j] < 0.7 else 'black'
            ax.text(j, i, f'{gap_times_r[i, j]:.2f}',
                    ha='center', va='center', fontsize=9, color=color)

plt.colorbar(im, ax=ax, label='γ · r')

# Panel 2: Eigenvalue spectrum for a specific matroid
ax = axes[1]
configs = [
    ([2, 2, 2], 'r=3, n=2'),
    ([3, 3], 'r=2, n=3'),
    ([2, 2, 2, 2], 'r=4, n=2'),
]

for block_sizes, label in configs:
    P, _ = partition_exchange_matrix(block_sizes)
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    ax.plot(range(len(eigenvalues)), eigenvalues, 'o-', label=label,
            markersize=5, alpha=0.8)

ax.set_xlabel('Eigenvalue index', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Eigenvalue Spectrum of\nExchange Walk', fontsize=13)
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('curvature_gap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved curvature_gap_heatmap.png")
