#!/usr/bin/env python3
"""
Visualization: Log-Hessian Matrix Heatmaps

Shows the structure of log-Hessian matrices for different polynomial families,
highlighting the interplay between the Hessian term (H/c) and the gradient
outer-product correction (-gg^T/c^2) that drives CondNSD.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def log_hessian_at_one(value, gradient, hessian):
    c, g, H = value, gradient, hessian
    return H / c - np.outer(g, g) / c**2


fig, axes = plt.subplots(2, 3, figsize=(14, 9))

# Example 1: Uniform matroid U(3,6)
n, k = 6, 3
val = comb(n, k)
grad = np.full(n, comb(n-1, k-1), dtype=float)
hess = np.full((n, n), comb(n-2, k-2), dtype=float)
np.fill_diagonal(hess, 0)
L = log_hessian_at_one(val, grad, hess)

ax = axes[0, 0]
im = ax.imshow(hess / val, cmap='RdBu_r', aspect='equal')
ax.set_title('H/c  (Hessian term)\nU(3,6)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[0, 1]
outer = np.outer(grad, grad) / val**2
im = ax.imshow(-outer, cmap='RdBu_r', aspect='equal')
ax.set_title('-gg^T/c²  (gradient correction)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[0, 2]
vmax = max(abs(L.min()), abs(L.max()))
im = ax.imshow(L, cmap='RdBu_r', aspect='equal', vmin=-vmax, vmax=vmax)
ax.set_title('L = H/c - gg^T/c²  (log-Hessian)')
plt.colorbar(im, ax=ax, shrink=0.8)

# Example 2: DPP with projection kernel
np.random.seed(42)
n = 6
Q = np.linalg.qr(np.random.randn(n, 3), mode='reduced')[0]
K = Q @ Q.T
I_n = np.eye(n)
M = K @ np.linalg.inv(I_n + K)
L_dpp = -(M * M)

ax = axes[1, 0]
im = ax.imshow(M, cmap='viridis', aspect='equal')
ax.set_title('Marginal kernel M\nProjection DPP (n=6, r=3)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[1, 1]
im = ax.imshow(M * M, cmap='viridis', aspect='equal')
ax.set_title('M ∘ M  (Hadamard square)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[1, 2]
vmax = max(abs(L_dpp.min()), abs(L_dpp.max()))
im = ax.imshow(L_dpp, cmap='RdBu_r', aspect='equal', vmin=-vmax, vmax=vmax)
ax.set_title('-(M ∘ M)  (DPP log-Hessian)')
plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Log-Hessian Decomposition: Hessian vs. Gradient Correction',
             fontsize=14, y=1.01)
plt.tight_layout()
plt.savefig('heatmap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved heatmap_analysis.png")
