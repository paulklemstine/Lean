#!/usr/bin/env python3
"""
Visualization 1: DPP Pairwise Correlation Ratio Heatmap

Visualizes the correlation ratio matrix for a DPP kernel, showing
the strength of negative dependence between all pairs of items.

The correlation ratio Pr[i,j∈S]/(Pr[i∈S]·Pr[j∈S]) is always ≤ 1
for DPPs (by the negative dependence theorem). Values close to 0
indicate strong repulsion; values close to 1 indicate near-independence.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    A = np.random.randn(rank, n)
    return A.T @ A

def correlation_ratio_matrix(K):
    n = K.shape[0]
    R = np.ones((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                product = K[i, i] * K[j, j]
                if product > 1e-15:
                    pair = K[i, i] * K[j, j] - K[i, j] * K[j, i]
                    R[i, j] = pair / product
                else:
                    R[i, j] = float('nan')
    return R

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Three types of kernels
titles = ['Diagonal PSD', 'Low-rank (rank 2)', 'Full-rank PSD']
n = 8

kernels = [
    np.diag(np.abs(np.random.randn(n)) + 0.1),
    random_psd_matrix(n, rank=2),
    random_psd_matrix(n)
]

for ax, K, title in zip(axes, kernels, titles):
    R = correlation_ratio_matrix(K)
    im = ax.imshow(R, cmap='RdYlBu_r', vmin=0, vmax=1, aspect='equal')
    ax.set_title(f'{title}\n(n={n})', fontsize=12, fontweight='bold')
    ax.set_xlabel('Item j')
    ax.set_ylabel('Item i')
    
    # Annotate values
    for i in range(n):
        for j in range(n):
            if i != j and not np.isnan(R[i, j]):
                color = 'white' if R[i, j] < 0.5 else 'black'
                ax.text(j, i, f'{R[i,j]:.2f}', ha='center', va='center',
                       fontsize=6, color=color)
            elif i == j:
                ax.text(j, i, '1.00', ha='center', va='center',
                       fontsize=6, color='black')
    
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))

plt.colorbar(im, ax=axes, label='Correlation Ratio  Pr[i,j∈S] / (Pr[i∈S]·Pr[j∈S])',
             fraction=0.02, pad=0.04)

fig.suptitle('DPP Pairwise Correlation Ratios (≤ 1 by Negative Dependence Theorem)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_correlation_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_correlation_heatmap.png")
