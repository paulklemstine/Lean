#!/usr/bin/env python3
"""
Visualization: Convergence of Discretization Error and Certified Gap

Shows how coefficient distance, KL divergence, and certified Lorentzian gap
converge as grid spacing h → 0 for the standard 2D Gaussian.

Three panels:
1. Log-log plot of coefficient distance vs h (shows O(h²) scaling)
2. Log-log plot of KL divergence vs h (shows O(h⁴) scaling)
3. Certified gap lower bound approaching ψ as h → 0
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import erf

def compute_discretization_metrics(h, R=5.0, sigma=1.0):
    """Compute all metrics for a 2D Gaussian discretization at spacing h."""
    n_cells = int(np.ceil(2 * R / h))
    edges = np.linspace(-R, -R + n_cells * h, n_cells + 1)
    centers = (edges[:-1] + edges[1:]) / 2

    cdf_vals = 0.5 * (1 + erf(edges / (sigma * np.sqrt(2))))
    cell_1d = np.diff(cdf_vals)
    density_1d = np.exp(-centers**2 / (2*sigma**2)) / (np.sqrt(2*np.pi)*sigma)
    point_1d = density_1d * h

    cell_2d = np.outer(cell_1d, cell_1d).flatten()
    point_2d = np.outer(point_1d, point_1d).flatten()

    cell_norm = cell_2d / np.sum(cell_2d)
    point_norm = point_2d / np.sum(point_2d)

    cd = np.sum(np.abs(point_norm - cell_norm))
    mask = (point_norm > 0) & (cell_norm > 0)
    kl = np.sum(point_norm[mask] * np.log(point_norm[mask] / cell_norm[mask]))
    N = n_cells ** 2

    return cd, kl, N

# Compute metrics for range of h values
h_values = np.array([2.0, 1.5, 1.0, 0.75, 0.5, 0.375, 0.25, 0.2, 0.15, 0.125, 0.1, 0.08, 0.0625])
cd_values = []
kl_values = []
N_values = []

for h in h_values:
    cd, kl, N = compute_discretization_metrics(h)
    cd_values.append(cd)
    kl_values.append(kl)
    N_values.append(N)

cd_values = np.array(cd_values)
kl_values = np.array(kl_values)
N_values = np.array(N_values)

psi = 1.0 / np.sqrt(2 * np.pi)
A_values = cd_values / h_values
gap_values = np.maximum(0, psi - 2 * cd_values)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Coefficient Distance
ax = axes[0]
ax.loglog(h_values, cd_values, 'bo-', linewidth=2, markersize=6, label='CoeffDist')
# Reference lines
ax.loglog(h_values, 0.05 * h_values**2, 'r--', alpha=0.6, label='$O(h^2)$ ref')
ax.loglog(h_values, 0.3 * h_values, 'g--', alpha=0.6, label='$O(h)$ ref')
ax.set_xlabel('Grid spacing $h$', fontsize=12)
ax.set_ylabel('Coefficient distance', fontsize=12)
ax.set_title('Discretization Error vs Grid Spacing', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: KL Divergence
ax = axes[1]
ax.loglog(h_values, np.maximum(kl_values, 1e-18), 'rs-', linewidth=2, markersize=6, label='KL divergence')
ax.loglog(h_values, np.maximum(kl_values, 1e-18)[0] * (h_values/h_values[0])**4,
          'b--', alpha=0.6, label='$O(h^4)$ ref')
ax.set_xlabel('Grid spacing $h$', fontsize=12)
ax.set_ylabel('KL divergence', fontsize=12)
ax.set_title('KL Divergence vs Grid Spacing', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Certified Gap
ax = axes[2]
ax.plot(h_values, gap_values, 'go-', linewidth=2, markersize=6, label='Certified gap LB')
ax.axhline(y=psi, color='r', linestyle='--', linewidth=1.5, label=f'$\\psi = {psi:.4f}$')
ax.fill_between(h_values, gap_values, psi, alpha=0.15, color='orange',
                label='Gap deficit')
ax.set_xlabel('Grid spacing $h$', fontsize=12)
ax.set_ylabel('Lorentzian gap', fontsize=12)
ax.set_title('Certified Gap Convergence', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, max(h_values) * 1.05)

plt.suptitle('Continuous-to-Discrete Robustness Transfer: 2D Gaussian',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('convergence_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
