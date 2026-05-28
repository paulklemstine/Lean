"""
Visualization: Hessian Heatmap and Eigenvalue Spectrum

Visualizes the DPP resolvent Hessian matrix as a heatmap alongside
the eigenvalue spectrum on the zero-sum subspace, showing that all
eigenvalues are nonpositive (conditional negative semidefiniteness).
"""

import numpy as np
import matplotlib.pyplot as plt


def dpp_resolvent_hessian(A):
    n = A.shape[0]
    L = A @ np.linalg.inv(np.eye(n) + A)
    H = -(L ** 2)
    return L, H


def check_cond_neg_semidef(M):
    n = M.shape[0]
    e = np.ones(n) / np.sqrt(n)
    Q = np.eye(n) - np.outer(e, e)
    M_restricted = Q @ M @ Q
    eigenvalues = np.linalg.eigvalsh(M_restricted)
    idx = np.argsort(np.abs(eigenvalues))
    restricted = eigenvalues[idx[1:]]
    return np.sort(restricted)


# Generate a representative PSD kernel
np.random.seed(2025)
n = 8
B = np.random.randn(n, n) * 0.7
A = B @ B.T

L, H = dpp_resolvent_hessian(A)
evals = check_cond_neg_semidef(H)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Resolvent matrix L
im1 = axes[0].imshow(L, cmap='RdBu_r', aspect='equal',
                       vmin=-np.max(np.abs(L)), vmax=np.max(np.abs(L)))
axes[0].set_title('Resolvent L = A(I+A)⁻¹', fontsize=13, fontweight='bold')
axes[0].set_xlabel('Column index')
axes[0].set_ylabel('Row index')
plt.colorbar(im1, ax=axes[0], shrink=0.8)

# Panel 2: Hessian H = -L²
im2 = axes[1].imshow(H, cmap='RdBu_r', aspect='equal',
                       vmin=np.min(H), vmax=-np.min(H))
axes[1].set_title('Log-Hessian H = −L²ᵢⱼ', fontsize=13, fontweight='bold')
axes[1].set_xlabel('Column index')
axes[1].set_ylabel('Row index')
plt.colorbar(im2, ax=axes[1], shrink=0.8)

# Panel 3: Eigenvalue spectrum on zero-sum subspace
colors = ['#d32f2f' if e > 1e-10 else '#1976d2' for e in evals]
bars = axes[2].bar(range(len(evals)), evals, color=colors, width=0.6, edgecolor='black', linewidth=0.5)
axes[2].axhline(y=0, color='black', linewidth=1, linestyle='-')
axes[2].set_title('Zero-Sum Eigenvalues\n(all ≤ 0 ⟹ CondNSD)', fontsize=13, fontweight='bold')
axes[2].set_xlabel('Eigenvalue index')
axes[2].set_ylabel('Eigenvalue')
axes[2].set_xticks(range(len(evals)))

# Add annotation
max_eval = np.max(evals)
axes[2].annotate(f'max = {max_eval:.2e}',
                  xy=(np.argmax(evals), max_eval),
                  xytext=(np.argmax(evals) + 0.5, max_eval + 0.01 * abs(np.min(evals))),
                  fontsize=10, color='#1976d2',
                  arrowprops=dict(arrowstyle='->', color='#1976d2'))

fig.suptitle('DPP Resolvent Geometry: Hessian Structure (n=8)',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_hessian_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hessian_heatmap.png")
