#!/usr/bin/env python3
"""
Visualization: Contraction Operator Heatmap

Visualizes the matrices K, K², and K - K² side by side for a DPP
marginal kernel, showing that K - K² is positive semidefinite
with nonneg entries on the diagonal.
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv, eigvalsh

np.random.seed(42)

# Generate a random 8x8 PSD matrix
n = 8
A = np.random.randn(n, n)
L = A @ A.T
beta = 1.5

# Compute marginal kernel and contraction
I = np.eye(n)
K = beta * L @ inv(I + beta * L)
K_sq = K @ K
C = K - K_sq

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# K heatmap
im0 = axes[0].imshow(K, cmap='RdBu_r', vmin=-0.5, vmax=0.5, aspect='equal')
axes[0].set_title(r'Marginal Kernel $K = \beta L(I + \beta L)^{-1}$', fontsize=12)
axes[0].set_xlabel('Column index')
axes[0].set_ylabel('Row index')
plt.colorbar(im0, ax=axes[0], shrink=0.8)

# K² heatmap
im1 = axes[1].imshow(K_sq, cmap='RdBu_r', vmin=-0.5, vmax=0.5, aspect='equal')
axes[1].set_title(r'$K^2$', fontsize=12)
axes[1].set_xlabel('Column index')
plt.colorbar(im1, ax=axes[1], shrink=0.8)

# K - K² heatmap (should be PSD)
im2 = axes[2].imshow(C, cmap='YlOrRd', vmin=0, aspect='equal')
axes[2].set_title(r'Contraction $K - K^2 = P^\top(\beta L)P \succeq 0$', fontsize=12)
axes[2].set_xlabel('Column index')
plt.colorbar(im2, ax=axes[2], shrink=0.8)

# Annotate eigenvalues
eigs = eigvalsh(C)
axes[2].text(0.5, -0.15, f'Eigenvalues: [{", ".join(f"{e:.3f}" for e in eigs)}]',
             transform=axes[2].transAxes, ha='center', fontsize=8, style='italic')

fig.suptitle(f'Marginal Kernel Contraction Theorem (n={n}, β={beta})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('contraction_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
