#!/usr/bin/env python3
"""
Visualization: Information-Theoretic Bridge

Shows the cross-domain connection between L¹ coefficient distance,
χ² divergence, and KL divergence for discretized Gaussian measures.

Verifies the theoretical chain: KL ≤ χ² ≤ (1/m) * coeffDist²
and demonstrates O(h²) scaling of the KL bound.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import erf

def compute_all_divergences(h, R=5.0, sigma=1.0):
    """Compute coeffDist, χ², KL, and (1/m)*coeffDist² for 2D Gaussian."""
    n_cells = int(np.ceil(2*R/h))
    edges = np.linspace(-R, -R+n_cells*h, n_cells+1)
    centers = (edges[:-1] + edges[1:]) / 2

    cdf = 0.5*(1+erf(edges/(sigma*np.sqrt(2))))
    cell_1d = np.diff(cdf)
    d_1d = np.exp(-centers**2/(2*sigma**2)) / (np.sqrt(2*np.pi)*sigma)
    point_1d = d_1d * h

    cell_2d = np.outer(cell_1d, cell_1d).flatten()
    point_2d = np.outer(point_1d, point_1d).flatten()

    nu = cell_2d / np.sum(cell_2d)
    mu = point_2d / np.sum(point_2d)

    cd = np.sum(np.abs(mu - nu))
    mask = nu > 0
    chi2 = np.sum((mu[mask] - nu[mask])**2 / nu[mask])
    m = np.min(nu[mask])
    pinsker_bound = (1.0/m) * cd**2

    mask2 = (mu > 0) & (nu > 0)
    kl = np.sum(mu[mask2] * np.log(mu[mask2] / nu[mask2]))

    return cd, chi2, kl, pinsker_bound, m

h_values = np.array([1.5, 1.0, 0.75, 0.5, 0.375, 0.25, 0.2, 0.15, 0.125, 0.1, 0.08])

cds, chi2s, kls, bounds, ms = [], [], [], [], []
for h in h_values:
    cd, chi2, kl, bound, m = compute_all_divergences(h)
    cds.append(cd)
    chi2s.append(chi2)
    kls.append(max(kl, 1e-20))
    bounds.append(bound)
    ms.append(m)

cds = np.array(cds)
chi2s = np.array(chi2s)
kls = np.array(kls)
bounds = np.array(bounds)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Divergence chain
ax = axes[0]
ax.loglog(h_values, cds, 'bo-', linewidth=2, markersize=5, label='CoeffDist (L¹)')
ax.loglog(h_values, chi2s, 'rs-', linewidth=2, markersize=5, label='χ² divergence')
ax.loglog(h_values, kls, 'g^-', linewidth=2, markersize=5, label='KL divergence')
ax.set_xlabel('Grid spacing $h$', fontsize=12)
ax.set_ylabel('Divergence', fontsize=12)
ax.set_title('Divergence Hierarchy', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Bound verification
ax = axes[1]
ax.loglog(h_values, kls, 'g^-', linewidth=2, markersize=6, label='KL')
ax.loglog(h_values, chi2s, 'rs-', linewidth=2, markersize=6, label='χ²')
ax.loglog(h_values, bounds, 'kD-', linewidth=2, markersize=6, label='$(1/m) \\cdot$CoeffDist$^2$')
ax.fill_between(h_values, kls, bounds, alpha=0.1, color='green')
ax.set_xlabel('Grid spacing $h$', fontsize=12)
ax.set_ylabel('Divergence', fontsize=12)
ax.set_title('Bound Chain: KL ≤ χ² ≤ (1/m)·‖·‖₁²', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Ratios
ax = axes[2]
ax.semilogx(h_values, chi2s / np.maximum(kls, 1e-20), 'rs-',
            linewidth=2, markersize=5, label='χ²/KL')
ax.semilogx(h_values, bounds / np.maximum(chi2s, 1e-20), 'bo-',
            linewidth=2, markersize=5, label='Bound/χ²')
ax.axhline(y=1, color='k', linestyle='--', alpha=0.5)
ax.set_xlabel('Grid spacing $h$', fontsize=12)
ax.set_ylabel('Ratio', fontsize=12)
ax.set_title('Tightness of Information Bounds', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Information-Theoretic Bridge: L¹ → χ² → KL',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('kl_bridge_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
