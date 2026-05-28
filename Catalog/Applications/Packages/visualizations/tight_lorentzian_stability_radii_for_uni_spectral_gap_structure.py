#!/usr/bin/env python3
"""
Visualization: Spectral Gap Structure of Uniform Matroid Leaf Hessians

This script visualizes the eigenvalue structure of the canonical leaf Hessian
J - I for the uniform matroid, showing how the spectral gap controls
Lorentzian stability under perturbation.

Panel 1: Heatmap of the leaf Hessian J - I
Panel 2: Eigenvalue spectrum showing the gap
Panel 3: Stability radius as a function of leaf dimension m
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def find_diagonal_threshold(m, tol=1e-8):
    H = leaf_hessian(m)
    lo, hi = 0.0, 5.0
    for _ in range(100):
        mid = (lo + hi) / 2
        eigs = np.linalg.eigvalsh(H + mid * np.eye(m))
        if np.sum(eigs > 1e-12) <= 1:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Heatmap of leaf Hessian
m = 8
H = leaf_hessian(m)
im = axes[0].imshow(H, cmap='RdBu_r', vmin=-1, vmax=1, interpolation='nearest')
axes[0].set_title(f'Leaf Hessian (J − I), m = {m}', fontsize=13)
axes[0].set_xlabel('Column index j')
axes[0].set_ylabel('Row index i')
plt.colorbar(im, ax=axes[0], shrink=0.8)

# Panel 2: Eigenvalue spectrum for several m values
for m_val in [4, 6, 8, 12, 16]:
    eigs = np.linalg.eigvalsh(leaf_hessian(m_val))
    axes[1].scatter([m_val] * len(eigs), eigs, s=30, alpha=0.7,
                     label=f'm={m_val}' if m_val in [4, 8, 16] else None)

axes[1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[1].axhline(y=-1, color='red', linestyle=':', alpha=0.7, label='λ = −1 (gap)')
axes[1].set_xlabel('Leaf dimension m', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title('Eigenvalue Spectrum of J − I', fontsize=13)
axes[1].legend(fontsize=9)

# Panel 3: Stability radii vs m
ms = list(range(3, 20))
thresholds_diag = [find_diagonal_threshold(m) for m in ms]
entry_bounds = [1.0 / m**2 for m in ms]
amgm_bounds = [1.0 / m for m in ms]
theoretical = [1.0] * len(ms)

axes[2].plot(ms, theoretical, 'k-', linewidth=2, label='Spectral gap = 1')
axes[2].plot(ms, thresholds_diag, 'bo-', markersize=5, label='Diagonal threshold')
axes[2].plot(ms, amgm_bounds, 'r^--', markersize=5, label='AM-GM bound (1/m)')
axes[2].plot(ms, entry_bounds, 'gs--', markersize=4, label='Entry bound (1/m²)')
axes[2].set_xlabel('Leaf dimension m', fontsize=12)
axes[2].set_ylabel('Stability radius', fontsize=12)
axes[2].set_title('Stability Radii vs Dimension', fontsize=13)
axes[2].legend(fontsize=9)
axes[2].set_yscale('log')
axes[2].set_ylim(0.001, 2)

plt.tight_layout()
plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_analysis.png")
