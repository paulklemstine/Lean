"""
Visualization: Noise Threshold Surface

Shows the noise threshold as a function of circuit depth and noise rate,
color-coded by whether the certified negative dependence is maintained.
This is the key practical output: the "safe operating region" for
noisy quantum fermion samplers.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

def certified_neg_dep_bound(d, eps):
    eta = 3 * d * eps / 2
    return 2 * (2 * eta + eta**2)

# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Phase diagram (d vs ε) for different δ values
eps_range = np.linspace(0.001, 0.1, 200)
d_range = np.arange(1, 201)

# For a given δ, the threshold is: 2(2η + η²) = δ where η = 3dε/2
# η = -1 + sqrt(1 + δ/2)
delta_values = [0.05, 0.1, 0.2, 0.3, 0.5]
colors = ['#E91E63', '#FF5722', '#FF9800', '#4CAF50', '#2196F3']

for delta, color in zip(delta_values, colors):
    max_eta = -1 + np.sqrt(1 + delta / 2)
    # η = 3dε/2, so d = 2η/(3ε)
    d_threshold = 2 * max_eta / (3 * eps_range)
    ax1.plot(eps_range * 100, d_threshold, color=color, linewidth=2,
             label=f'δ = {delta}')
    ax1.fill_between(eps_range * 100, 0, d_threshold, color=color, alpha=0.05)

ax1.set_xlabel('Noise Rate ε (%)', fontsize=12)
ax1.set_ylabel('Maximum Circuit Depth d', fontsize=12)
ax1.set_title('Safe Operating Region\nfor Certified Fermion Sampling', fontsize=13)
ax1.legend(title='Neg. dep. gap δ', fontsize=9)
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 200)
ax1.grid(True, alpha=0.3)
ax1.text(0.95, 0.95, 'CERTIFIED\nSAFE',
         transform=ax1.transAxes, fontsize=14, color='green',
         ha='right', va='top', alpha=0.5, fontweight='bold')
ax1.text(0.95, 0.05, 'UNCERTIFIED',
         transform=ax1.transAxes, fontsize=14, color='red',
         ha='right', va='bottom', alpha=0.5, fontweight='bold')

# Panel 2: Certified bound as heatmap
D, E = np.meshgrid(d_range, eps_range)
Bound = certified_neg_dep_bound(D, E)

# Use log scale for better visualization
log_bound = np.log10(Bound + 1e-10)

im = ax2.pcolormesh(E * 100, D, log_bound, cmap='hot_r', shading='auto')
cb = fig.colorbar(im, ax=ax2, label='log₁₀(Certified Bound)')

# Add contour lines
contour_levels = [0.01, 0.05, 0.1, 0.2, 0.5, 1.0]
CS = ax2.contour(E * 100, D, Bound, levels=contour_levels,
                  colors='white', linewidths=1)
ax2.clabel(CS, inline=True, fontsize=8, fmt='%.2f')

ax2.set_xlabel('Noise Rate ε (%)', fontsize=12)
ax2.set_ylabel('Circuit Depth d', fontsize=12)
ax2.set_title('Certified Negative Dependence\nDefect Bound', fontsize=13)

plt.suptitle('Noise Threshold for Certified Fermion Sampling',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_threshold_surface.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_threshold_surface.png")
