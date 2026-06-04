#!/usr/bin/env python3
"""
Visualization: EML vs PWL Approximation Spectrum

Generates a heatmap comparing EML and piecewise linear approximation
error surfaces for x² on [0,1].
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm

def eml_error(d, w):
    """EML spectrum error bound."""
    if w == 0 or d == 0:
        return 1.0
    return np.exp(1) / (3 * w * d)

def pwl_error(d, w):
    """Piecewise linear spectrum error bound."""
    if w == 0:
        return 1.0
    return 1.0 / (8 * w**2)

# Create grid
depths = np.arange(1, 51)
widths = np.arange(1, 51)
D, W = np.meshgrid(depths, widths)

# Compute error surfaces
EML_err = np.vectorize(eml_error)(D, W)
PWL_err = np.vectorize(pwl_error)(D, W)

# Ratio: EML/PWL (< 1 means EML is better)
ratio = EML_err / PWL_err

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: EML error surface
im1 = axes[0].pcolormesh(depths, widths, EML_err, norm=LogNorm(), cmap='viridis')
axes[0].set_xlabel('Depth d')
axes[0].set_ylabel('Width w')
axes[0].set_title('EML Error: exp(1)/(3wd)')
plt.colorbar(im1, ax=axes[0], label='Error bound')

# Isoperformance contours
for eps in [0.1, 0.01, 0.001]:
    contour_d = np.linspace(1, 50, 200)
    contour_w = np.exp(1) / (3 * eps * contour_d)
    mask = (contour_w >= 1) & (contour_w <= 50)
    axes[0].plot(contour_d[mask], contour_w[mask], 'w--', alpha=0.7,
                 label=f'ε={eps}')
axes[0].legend(fontsize=8)

# Plot 2: PWL error surface
im2 = axes[1].pcolormesh(depths, widths, PWL_err, norm=LogNorm(), cmap='viridis')
axes[1].set_xlabel('Depth d')
axes[1].set_ylabel('Width w')
axes[1].set_title('PWL Error: 1/(8w²)')
plt.colorbar(im2, ax=axes[1], label='Error bound')

# Plot 3: Ratio (EML advantage region)
im3 = axes[2].pcolormesh(depths, widths, ratio, norm=LogNorm(vmin=0.01, vmax=100),
                          cmap='RdBu_r')
axes[2].set_xlabel('Depth d')
axes[2].set_ylabel('Width w')
axes[2].set_title('EML/PWL Ratio (blue = EML better)')
plt.colorbar(im3, ax=axes[2], label='Error ratio')

# Crossover curve: 8w·exp(1)/3 = d
crossover_w = np.linspace(1, 50, 200)
crossover_d = 8 * crossover_w * np.exp(1) / 3
mask = crossover_d <= 50
axes[2].plot(crossover_d[mask], crossover_w[mask], 'k-', linewidth=2,
             label='Crossover: d = 8we/3')
axes[2].legend(fontsize=8)

plt.tight_layout()
plt.savefig('spectrum_comparison.png', dpi=150, bbox_inches='tight')
print("Saved spectrum_comparison.png")
