#!/usr/bin/env python3
"""
Visualization: Phase Diagram for Wreath-Product Perturbation Regimes

Visualizes the (k, m) plane colored by perturbation regime:
- IRRELEVANT (blue): m^a/k^b ≪ 1, wreath effects vanish
- MARGINAL (yellow): m^a/k^b ~ 1, crossover region
- RELEVANT (red): m^a/k^b ≫ 1, new universality class

The critical curve m = k^(b/a) separates regimes.
This is the finite-group analog of a renormalization-group phase diagram.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Parameters
C = 1.0
a = 1
b = 1
alpha_c = b / a  # Critical exponent

# Create grid
k_vals = np.arange(2, 101)
m_vals = np.arange(1, 201)
K, M = np.meshgrid(k_vals, m_vals)

# Compute scaling ratio
ratio = (M.astype(float) ** a) / (K.astype(float) ** b)
log_ratio = np.log10(ratio + 1e-10)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Continuous heatmap
ax1 = axes[0]
im = ax1.pcolormesh(K, M, log_ratio, cmap='RdYlBu_r',
                     vmin=-2, vmax=2, shading='auto')
# Critical curve m = k^(b/a)
k_curve = np.linspace(2, 100, 200)
m_curve = k_curve ** alpha_c
ax1.plot(k_curve, m_curve, 'k-', linewidth=2.5,
         label=f'Critical: $m = k^{{{alpha_c}}}$')
ax1.plot(k_curve, 0.1 * m_curve, 'k--', linewidth=1,
         alpha=0.5, label='Subcritical boundary')
ax1.plot(k_curve, 10 * m_curve, 'k--', linewidth=1,
         alpha=0.5, label='Supercritical boundary')
ax1.set_xlabel('Group rank k', fontsize=12)
ax1.set_ylabel('Multiplicity m', fontsize=12)
ax1.set_title(f'Scaling Ratio $\\log_{{10}}(m^{a}/k^{b})$', fontsize=13)
ax1.legend(loc='upper left', fontsize=9)
plt.colorbar(im, ax=ax1, label='$\\log_{10}(m^a/k^b)$')

# Right panel: Discrete regime classification
ax2 = axes[1]
regime_map = np.zeros_like(ratio)
regime_map[ratio < 0.1] = 0    # Irrelevant
regime_map[(ratio >= 0.1) & (ratio <= 10)] = 1  # Marginal
regime_map[ratio > 10] = 2     # Relevant

cmap = mcolors.ListedColormap(['#3498db', '#f1c40f', '#e74c3c'])
bounds = [-0.5, 0.5, 1.5, 2.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)
im2 = ax2.pcolormesh(K, M, regime_map, cmap=cmap, norm=norm,
                      shading='auto')
ax2.plot(k_curve, m_curve, 'k-', linewidth=2.5,
         label=f'$\\alpha_c = {alpha_c}$')
ax2.set_xlabel('Group rank k', fontsize=12)
ax2.set_ylabel('Multiplicity m', fontsize=12)
ax2.set_title('Perturbation Regime Classification', fontsize=13)
cbar2 = plt.colorbar(im2, ax=ax2, ticks=[0, 1, 2])
cbar2.ax.set_yticklabels(['Irrelevant', 'Marginal', 'Relevant'])
ax2.legend(loc='upper left', fontsize=10)

plt.suptitle('Double-Scaling Phase Diagram: $S_k \\wr S_m$',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved phase_diagram.png")
