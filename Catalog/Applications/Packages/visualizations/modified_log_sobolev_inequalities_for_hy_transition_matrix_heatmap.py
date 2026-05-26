#!/usr/bin/env python3
"""
Visualization: Transition Matrix Heatmap for the Hybrid Walk

Shows the structure of the transition matrix P for the hybrid
adjacent-transposition-plus-cycle walk on S_3 and S_4.

The heatmap reveals the sparsity pattern: each row has at most
n+1 nonzero entries (one per generator), creating a structured
sparse matrix that combines local and global connectivity.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def build_hybrid_walk(n):
    perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(perms)}
    N = len(perms)

    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / len(gens)
    return P, perms


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, n in enumerate([3, 4]):
    ax = axes[idx]
    P, perms = build_hybrid_walk(n)
    N = len(perms)

    im = ax.imshow(P, cmap='YlOrRd', interpolation='nearest', aspect='auto')
    ax.set_title(f'Transition Matrix $P$ for Hybrid Walk on $S_{n}$\n'
                 f'($|S_{n}|$ = {N}, {n+1} generators)',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('Target permutation index', fontsize=11)
    ax.set_ylabel('Source permutation index', fontsize=11)

    plt.colorbar(im, ax=ax, shrink=0.8, label='$P(\\sigma, \\tau)$')

    # Annotate sparsity
    nnz = np.count_nonzero(P)
    density = nnz / (N * N) * 100
    ax.text(0.02, 0.98, f'Nonzero: {nnz}/{N*N} ({density:.1f}%)',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.suptitle('Hybrid Walk: Local Swaps + Global Cycle Create Structured Connectivity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('transition_matrix_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved transition_matrix_visualization.png")
