#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs 1/r for Partition Matroids

Shows how the spectral gap of the basis exchange walk compares with the
theoretical 1/r prediction from Lorentzian curvature certificates.
Includes both exact numerical gaps and certified lower bounds.
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
        neighbors = []
        for block_idx in range(r):
            bs = block_sizes[block_idx]
            offset = sum(block_sizes[:block_idx])
            for e in range(bs):
                new_elem = offset + e
                if new_elem != b[block_idx]:
                    nb = list(b)
                    nb[block_idx] = new_elem
                    neighbors.append(tuple(nb))

        total_neighbors = sum(bs - 1 for bs in block_sizes)
        if total_neighbors > 0:
            for nb in neighbors:
                j = idx[nb]
                P[i, j] = 1.0 / (2 * total_neighbors)
            P[i, i] = 1.0 - sum(P[i, :])
        else:
            P[i, i] = 1.0
    return P, bases


def spectral_gap(P):
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    if len(eigenvalues) < 2:
        return 1.0
    return 1.0 - eigenvalues[1]


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Gap vs 1/r for binary partition matroids
ax = axes[0]
ranks = list(range(2, 9))
gaps_binary = []
predicted = []
for r in ranks:
    P, _ = partition_exchange_matrix([2] * r)
    gaps_binary.append(spectral_gap(P))
    predicted.append(1.0 / r)

ax.plot(ranks, gaps_binary, 'bo-', label='Numerical gap (n=2)', markersize=8)
ax.plot(ranks, predicted, 'r--', label='1/r prediction', linewidth=2)
ax.set_xlabel('Rank r', fontsize=12)
ax.set_ylabel('Spectral gap', fontsize=12)
ax.set_title('Binary Partition Matroids:\nGap = 1/r Exactly', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Gap vs 1/r for different block sizes
ax = axes[1]
for n in [2, 3, 4, 5]:
    ranks_n = list(range(2, min(8, 12 // n + 1)))
    gaps_n = []
    for r in ranks_n:
        P, _ = partition_exchange_matrix([n] * r)
        gaps_n.append(spectral_gap(P))
    one_over_r = [1.0 / r for r in ranks_n]
    ax.plot(ranks_n, gaps_n, 'o-', label=f'n={n}', markersize=7)

ax.plot(range(2, 8), [1.0 / r for r in range(2, 8)], 'k--',
        label='1/r', linewidth=2, alpha=0.5)
ax.set_xlabel('Rank r', fontsize=12)
ax.set_ylabel('Spectral gap', fontsize=12)
ax.set_title('Partition Matroids:\nGap vs Block Size', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Truncated certificate convergence
ax = axes[2]
kappa = 0.25
rho_values = [0.3, 0.5, 0.7, 0.9]
depths = np.arange(0, 21)

for rho in rho_values:
    bounds = [kappa * (1 - rho**k) for k in depths]
    ax.plot(depths, bounds, '-', label=f'ρ={rho}', linewidth=2)

ax.axhline(y=kappa, color='k', linestyle='--', label=f'κ={kappa}', alpha=0.7)
ax.set_xlabel('Depth k', fontsize=12)
ax.set_ylabel('Lower bound κ_k', fontsize=12)
ax.set_title('Truncated Certificate\nConvergence', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_certificates.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_certificates.png")
