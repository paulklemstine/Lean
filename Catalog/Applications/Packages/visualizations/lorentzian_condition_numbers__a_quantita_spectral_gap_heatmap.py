#!/usr/bin/env python3
"""
Visualization: Spectral Gap Heatmap and Stability Landscape

Shows the stability landscape of the Lorentzian property in perturbation space.
Green regions preserve the Lorentzian signature; red regions break it.
The certified safe radius appears as a blue square inside the green region.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Rectangle


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def has_lorentzian_signature(H, tol=1e-10):
    return int(np.sum(np.linalg.eigvalsh(H) > tol)) <= 1

def spectral_gap_of_perturbed(H, E):
    """Return spectral gap of H+E, or 0 if not Lorentzian."""
    combined = H + E
    eigs = np.linalg.eigvalsh(combined)
    if np.sum(eigs > 1e-10) > 1:
        return -1.0  # Not Lorentzian
    neg = eigs[eigs < -1e-12]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Stability Landscapes: Where Lorentzianity Survives', 
             fontsize=13, fontweight='bold')

for idx, m in enumerate([4, 6, 10]):
    ax = axes[idx]
    H = leaf_hessian(m)
    n_grid = 80
    max_eps = 1.5
    x_range = np.linspace(-max_eps, max_eps, n_grid)
    y_range = np.linspace(-max_eps, max_eps, n_grid)
    
    landscape = np.zeros((n_grid, n_grid))
    
    for i, ex in enumerate(x_range):
        for j, ey in enumerate(y_range):
            E = np.zeros((m, m))
            # Perturb entries (0,1) and (1,2) symmetrically
            E[0, 1] = ex; E[1, 0] = ex
            E[1, 2] = ey; E[2, 1] = ey
            gap = spectral_gap_of_perturbed(H, E)
            landscape[j, i] = gap
    
    # Mask non-Lorentzian regions
    lorentzian_mask = landscape >= 0
    
    im = ax.imshow(landscape, extent=[-max_eps, max_eps, -max_eps, max_eps],
                    origin='lower', cmap='RdYlGn', vmin=-0.5, vmax=1.5,
                    aspect='equal')
    
    # Draw certified radius
    r = 1.0 / m**2
    rect = Rectangle((-r, -r), 2*r, 2*r, fill=False, 
                      edgecolor='blue', linewidth=2, linestyle='--')
    ax.add_patch(rect)
    
    # Draw spectral gap = 1 circle (approximate)
    circle = Circle((0, 0), 1.0, fill=False, edgecolor='white', 
                     linewidth=1.5, linestyle=':')
    ax.add_patch(circle)
    
    ax.set_xlabel('ε₁ (entry perturbation)')
    ax.set_ylabel('ε₂ (entry perturbation)')
    ax.set_title(f'm = {m}, certified radius = 1/{m}² = {r:.4f}')
    ax.set_xlim(-max_eps, max_eps)
    ax.set_ylim(-max_eps, max_eps)

plt.colorbar(im, ax=axes, label='Residual spectral gap (negative = broken)', shrink=0.8)
plt.tight_layout()
plt.savefig('viz_spectral_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_heatmap.png")
