#!/usr/bin/env python3
"""
Visualization 1: DPP Response Theory Heatmaps
==============================================
Visualizes the key matrices of the DPP fluctuation-dissipation principle:
- Marginal kernel K
- Covariance/susceptibility matrix χ
- Conductance network c_ij = K_ij²
- Susceptibility distance d_χ(i,j)

Shows how the same kernel gives rise to both statistical and
electrical network structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv

def compute_marginal_kernel(beta, L):
    n = L.shape[0]
    return (beta * L) @ inv(np.eye(n) + beta * L)

def compute_susceptibility(beta, L):
    K = compute_marginal_kernel(beta, L)
    n = K.shape[0]
    chi = -(K ** 2)
    for i in range(n):
        chi[i, i] = K[i, i] * (1 - K[i, i])
    return chi

np.random.seed(42)
n = 6
A = np.random.randn(n, 3)
L = A @ A.T
beta = 1.0

K = compute_marginal_kernel(beta, L)
chi = compute_susceptibility(beta, L)
c = K ** 2
d_chi = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        d_chi[i, j] = chi[i, i] + chi[j, j] - 2 * chi[i, j]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('DPP Fluctuation–Dissipation: Key Matrices', fontsize=16, fontweight='bold')

# Marginal kernel
im0 = axes[0, 0].imshow(K, cmap='RdBu_r', aspect='equal')
axes[0, 0].set_title('Marginal Kernel K', fontsize=13)
axes[0, 0].set_xlabel('j')
axes[0, 0].set_ylabel('i')
plt.colorbar(im0, ax=axes[0, 0], shrink=0.8)

# Covariance matrix
im1 = axes[0, 1].imshow(chi, cmap='RdBu_r', aspect='equal')
axes[0, 1].set_title('Covariance Matrix χ\n(= Susceptibility)', fontsize=13)
axes[0, 1].set_xlabel('j')
axes[0, 1].set_ylabel('i')
plt.colorbar(im1, ax=axes[0, 1], shrink=0.8)

# Conductance network
im2 = axes[1, 0].imshow(c, cmap='YlOrRd', aspect='equal')
axes[1, 0].set_title('Conductance Network c = K²\n(Electrical Weights)', fontsize=13)
axes[1, 0].set_xlabel('j')
axes[1, 0].set_ylabel('i')
plt.colorbar(im2, ax=axes[1, 0], shrink=0.8)

# Susceptibility distance
im3 = axes[1, 1].imshow(d_chi, cmap='viridis', aspect='equal')
axes[1, 1].set_title('Susceptibility Distance d_χ\n(Response Metric)', fontsize=13)
axes[1, 1].set_xlabel('j')
axes[1, 1].set_ylabel('i')
plt.colorbar(im3, ax=axes[1, 1], shrink=0.8)

plt.tight_layout()
plt.savefig('viz_heatmaps.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmaps.png")
