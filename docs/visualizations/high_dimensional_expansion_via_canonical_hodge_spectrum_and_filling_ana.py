#!/usr/bin/env python3
"""
Visualization: Hodge Laplacian Spectrum and Canonical Filling Congestion

Shows how the spectral gap and filling weight scale with the number of vertices
in the complete 2-complex. This illustrates the main theorem: canonical fillings
provide quantitative certificates for high-dimensional spectral expansion.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def build_and_analyze(n):
    """Build complete 2-complex and compute spectral/filling data."""
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

    L_up = b2 @ b2.T
    eigs = np.linalg.eigvalsh(L_up)
    pos_eigs = eigs[eigs > 1e-10]
    gap = np.min(pos_eigs) if len(pos_eigs) > 0 else 0

    U, S, Vt = np.linalg.svd(b1)
    rank = np.sum(S > 1e-10)
    cycles = Vt[rank:, :]

    W = 0
    for i in range(cycles.shape[0]):
        z = cycles[i]
        F, _, _, _ = np.linalg.lstsq(b2, z, rcond=None)
        W += np.sum(F**2)

    return {
        'n': n, 'gap': gap, 'W': W,
        'certified': 1/W if W > 0 else 0,
        'product': gap * W,
        'all_eigs': eigs
    }


# Compute data
ns = list(range(4, 10))
data = [build_and_analyze(n) for n in ns]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Canonical Filling Method: Spectral Gap Certification\nfor Complete 2-Complexes',
             fontsize=14, fontweight='bold')

# Plot 1: Spectral gap vs n
ax = axes[0, 0]
gaps = [d['gap'] for d in data]
ax.plot(ns, gaps, 'bo-', linewidth=2, markersize=8)
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('Spectral gap λ₁⁺', fontsize=12)
ax.set_title('Upper Laplacian Spectral Gap', fontsize=12)
ax.grid(True, alpha=0.3)
ax.set_xticks(ns)

# Plot 2: Filling weight vs n
ax = axes[0, 1]
weights = [d['W'] for d in data]
ax.plot(ns, weights, 'rs-', linewidth=2, markersize=8)
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('Total filling weight W', fontsize=12)
ax.set_title('Canonical Filling Weight', fontsize=12)
ax.grid(True, alpha=0.3)
ax.set_xticks(ns)

# Plot 3: Certified bound vs actual gap
ax = axes[1, 0]
certs = [d['certified'] for d in data]
ax.plot(ns, gaps, 'bo-', linewidth=2, markersize=8, label='Actual gap λ₁⁺')
ax.plot(ns, certs, 'r^--', linewidth=2, markersize=8, label='Certified bound 1/W')
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('Spectral gap', fontsize=12)
ax.set_title('Certified vs Actual Spectral Gap', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xticks(ns)
ax.set_yscale('log')

# Plot 4: Full spectrum heatmap
ax = axes[1, 1]
all_eigs_padded = []
max_len = max(len(d['all_eigs']) for d in data)
for d in data:
    e = np.sort(d['all_eigs'])
    padded = np.full(max_len, np.nan)
    padded[:len(e)] = e
    all_eigs_padded.append(padded)

for i, d in enumerate(data):
    eigs = np.sort(d['all_eigs'])
    ax.scatter([d['n']] * len(eigs), eigs, c='blue', s=30, alpha=0.6)
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Upper Laplacian Spectrum', fontsize=12)
ax.grid(True, alpha=0.3)
ax.set_xticks(ns)

plt.tight_layout()
plt.savefig('viz_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectrum.png")
