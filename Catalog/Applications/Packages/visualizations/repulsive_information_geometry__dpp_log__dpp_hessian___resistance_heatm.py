#!/usr/bin/env python3
"""
Visualization: DPP Log-Hessian and Effective Resistance Heatmaps

Visualizes the DPP log-Hessian matrix alongside the effective resistance matrix
derived from it, showing how the repulsion pattern translates into a distance geometry.
The Hessian (left) shows negative off-diagonal entries encoding repulsion strength.
The resistance matrix (right) shows the effective resistance distances.
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import pinv

def dpp_log_hessian(L):
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H

def effective_resistance_matrix(H):
    H_pinv = pinv(H)
    diag = np.diag(H_pinv)
    R = diag[:, None] + diag[None, :] - 2 * H_pinv
    return R

# Generate a structured DPP kernel (exponentially decaying correlations)
n = 8
rng = np.random.default_rng(42)
# Create a kernel with geometric decay: L[i,j] = rho^|i-j|
rho = 0.7
L = np.array([[rho ** abs(i - j) for j in range(n)] for i in range(n)])
# Add some noise
L = L + 0.1 * rng.standard_normal((n, n))
L = (L + L.T) / 2  # symmetrize

H = dpp_log_hessian(L)
R = effective_resistance_matrix(H)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: DPP Kernel L
im0 = axes[0].imshow(L, cmap='RdBu_r', aspect='equal')
axes[0].set_title('DPP Kernel L', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Column index j')
axes[0].set_ylabel('Row index i')
plt.colorbar(im0, ax=axes[0], shrink=0.8)

# Plot 2: Log-Hessian (Graph Laplacian)
vmax = np.max(np.abs(H))
im1 = axes[1].imshow(H, cmap='RdBu_r', vmin=-vmax, vmax=vmax, aspect='equal')
axes[1].set_title('DPP Log-Hessian H\n(Graph Laplacian)', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Column index j')
axes[1].set_ylabel('Row index i')
plt.colorbar(im1, ax=axes[1], shrink=0.8)

# Plot 3: Effective Resistance Matrix
im2 = axes[2].imshow(R, cmap='YlOrRd', aspect='equal')
axes[2].set_title('Effective Resistance\n(Repulsion Distance²)', fontsize=14, fontweight='bold')
axes[2].set_xlabel('Column index j')
axes[2].set_ylabel('Row index i')
plt.colorbar(im2, ax=axes[2], shrink=0.8)

plt.suptitle('From DPP Kernel to Resistance Distance',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
