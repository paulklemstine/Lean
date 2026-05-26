#!/usr/bin/env python3
"""
Visualization: DPP Pairwise Correlation Heatmap
================================================

Visualizes the pairwise correlation ratios det(K_{ij}) / (K_ii · K_jj)
for a DPP kernel K. Values close to 0 indicate strong repulsion (negative
dependence), while values close to 1 indicate weak repulsion.

This directly illustrates the Fischer inequality:
0 ≤ det(K_{ij}) ≤ K_ii · K_jj
which is proved in the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt


def random_psd_matrix(n, seed=42):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    return A.T @ A


def correlation_ratio_matrix(K):
    n = K.shape[0]
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                R[i, j] = 1.0
            else:
                prod = K[i, i] * K[j, j]
                if prod > 1e-15:
                    R[i, j] = (K[i, i] * K[j, j] - K[i, j] ** 2) / prod
                else:
                    R[i, j] = 0.0
    return R


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

titles = ["Diagonal (Independent)", "Rank-1 (Maximum Repulsion)", "Generic PSD"]
matrices = []

# Diagonal
w = np.array([1.0, 2.5, 0.5, 3.0, 1.5, 2.0, 0.8, 1.2])
matrices.append(np.diag(w))

# Rank-1
v = np.array([1.0, 0.5, -0.3, 0.8, -0.6, 0.4, 0.7, -0.2])
matrices.append(np.outer(v, v))

# Generic PSD
matrices.append(random_psd_matrix(8, seed=42))

for ax, K, title in zip(axes, matrices, titles):
    R = correlation_ratio_matrix(K)
    im = ax.imshow(R, cmap='RdYlGn_r', vmin=0, vmax=1, aspect='equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlabel("Item j")
    ax.set_ylabel("Item i")

    # Add text annotations
    n = R.shape[0]
    for i in range(n):
        for j in range(n):
            color = 'white' if R[i, j] < 0.3 or R[i, j] > 0.7 else 'black'
            ax.text(j, i, f'{R[i,j]:.2f}', ha='center', va='center',
                    color=color, fontsize=7)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))

fig.suptitle('DPP Pairwise Correlation Ratios: det(K_{ij}) / (K_ii · K_jj)\n'
             'Green = strong repulsion, Red = weak repulsion',
             fontsize=13, fontweight='bold', y=1.02)
plt.colorbar(im, ax=axes, label='Correlation Ratio', shrink=0.8)
plt.tight_layout()
plt.savefig('viz_correlation_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_correlation_heatmap.png")
