#!/usr/bin/env python3
"""
Visualization: Stability Heatmap for Period Matrix Perturbations

Shows the ratio |x^T(Q(ℓ)-Q(ℓ'))x| / bound as a heatmap over
different perturbation directions, visualizing how tight the
stability bound (periodMatrix_stability_quadratic) is in practice.

The heatmap axes represent two independent perturbation magnitudes
applied to different edge-length subsets.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import det, eigvalsh


def compute_period_matrix(C, lengths):
    CR = C.astype(float)
    return CR.T @ np.diag(lengths) @ CR


# Theta graph (genus 2, 3 edges)
C = np.array([[1, 1], [-1, 0], [0, -1]], dtype=int)
m, g = C.shape

base_lengths = np.array([1.0, 1.5, 2.0])
x = np.array([1.0, -0.7])

# Base values
Q_base = compute_period_matrix(C, base_lengths)
xQx_base = float(x @ Q_base @ x)

# Perturbation grid
n_grid = 80
delta1_range = np.linspace(-0.9, 0.9, n_grid)
delta2_range = np.linspace(-0.9, 0.9, n_grid)

ratio_grid = np.zeros((n_grid, n_grid))
det_grid = np.zeros((n_grid, n_grid))

for i, d1 in enumerate(delta1_range):
    for j, d2 in enumerate(delta2_range):
        perturbed = base_lengths + np.array([d1, d2, 0.0])
        if min(perturbed) <= 0:
            ratio_grid[j, i] = np.nan
            det_grid[j, i] = np.nan
            continue
        
        Q_pert = compute_period_matrix(C, perturbed)
        
        # Actual quadratic form difference
        actual = abs(float(x @ (Q_pert - Q_base) @ x))
        
        # Stability bound
        flows = C.astype(float) @ x
        bound = float(np.sum(np.abs(perturbed - base_lengths) * flows**2))
        
        ratio_grid[j, i] = actual / bound if bound > 1e-15 else 0
        det_grid[j, i] = det(Q_pert)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle("Stability Analysis: Period Matrix Under Edge-Length Perturbation",
             fontsize=14, fontweight='bold')

# Plot 1: Stability ratio
im1 = ax1.imshow(ratio_grid, extent=[delta1_range[0], delta1_range[-1],
                                      delta2_range[0], delta2_range[-1]],
                 origin='lower', cmap='RdYlGn_r', vmin=0, vmax=1,
                 aspect='auto')
ax1.set_xlabel('δℓ₁ (perturbation of edge 1)', fontsize=11)
ax1.set_ylabel('δℓ₂ (perturbation of edge 2)', fontsize=11)
ax1.set_title('Tightness Ratio: |x^T ΔQ x| / bound\n(green = loose, red = tight)', fontsize=11)
cb1 = plt.colorbar(im1, ax=ax1, label='ratio')
ax1.plot(0, 0, 'w*', markersize=15, markeredgecolor='black', markeredgewidth=1.5)
ax1.annotate('base', (0.05, 0.05), fontsize=9, color='white',
             fontweight='bold')

# Plot 2: Determinant landscape
im2 = ax2.imshow(det_grid, extent=[delta1_range[0], delta1_range[-1],
                                    delta2_range[0], delta2_range[-1]],
                 origin='lower', cmap='viridis', aspect='auto')
ax2.set_xlabel('δℓ₁ (perturbation of edge 1)', fontsize=11)
ax2.set_ylabel('δℓ₂ (perturbation of edge 2)', fontsize=11)
ax2.set_title('Jacobian Volume: det(Q) under perturbation', fontsize=11)
cb2 = plt.colorbar(im2, ax=ax2, label='det(Q)')
ax2.plot(0, 0, 'w*', markersize=15, markeredgecolor='black', markeredgewidth=1.5)

# Add contour lines
valid_mask = ~np.isnan(det_grid)
if np.any(valid_mask):
    det_clean = np.where(valid_mask, det_grid, 0)
    ax2.contour(delta1_range, delta2_range, det_clean, 
                levels=8, colors='white', alpha=0.4, linewidths=0.8)

plt.tight_layout()
plt.savefig('stability_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved stability_heatmap.png")
