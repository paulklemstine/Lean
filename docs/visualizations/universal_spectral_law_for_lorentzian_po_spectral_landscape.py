#!/usr/bin/env python3
"""
Visualization: Spectral Landscape of Lorentzian Stability

Shows how the stability radius varies with dimension and spectral gap,
illustrating the universal law ρ = γ_min / (n · M).

Produces a heatmap of stability radius as a function of (n, γ_min/M).
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
n_values = np.arange(2, 21)
gamma_over_M = np.linspace(0.01, 2.0, 100)

# Compute stability radius grid
N, G = np.meshgrid(n_values, gamma_over_M)
rho = G / N  # ρ = (γ/M) / n since M cancels

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap
im = axes[0].pcolormesh(N, G, rho, cmap='viridis', shading='auto')
axes[0].set_xlabel('Dimension n', fontsize=12)
axes[0].set_ylabel('Normalized gap γ_min / M', fontsize=12)
axes[0].set_title('Stability Radius ρ = γ_min / (n · M)', fontsize=14)
cbar = plt.colorbar(im, ax=axes[0])
cbar.set_label('Stability radius ρ', fontsize=11)

# Add contour lines
contour = axes[0].contour(N, G, rho, levels=[0.01, 0.02, 0.05, 0.1, 0.2, 0.5],
                          colors='white', linewidths=0.8)
axes[0].clabel(contour, inline=True, fontsize=8, fmt='%.2f')

# Line plot: stability vs dimension for fixed gap
axes[1].set_xlabel('Dimension n', fontsize=12)
axes[1].set_ylabel('Stability radius ρ', fontsize=12)
axes[1].set_title('Stability Decay with Dimension', fontsize=14)

for g_val in [0.1, 0.5, 1.0, 2.0]:
    rho_line = g_val / n_values
    axes[1].plot(n_values, rho_line, 'o-', label=f'γ_min/M = {g_val}', markersize=4)

# Add theoretical 1/n curve
axes[1].plot(n_values, 1.0 / n_values, 'k--', alpha=0.5, label='1/n reference')

axes[1].set_yscale('log')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_landscape.png', dpi=150, bbox_inches='tight')
print("Saved spectral_landscape.png")
