"""
Visualization: Integrality Gap Landscape

Plots the theoretical upper bound on the integrality gap τ/τ* as a function
of the pair codegree K and uniformity d. Shows how the gap decreases from d
as K decreases, illustrating the sub-d barrier-breaking phenomenon.

Uses matplotlib to create a heatmap and contour plot.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
d_values = np.arange(3, 11)  # d from 3 to 10
K_values = np.arange(1, 21)  # K from 1 to 20

# Compute gap bounds: d - 1/(2d(K+1))
D, K = np.meshgrid(d_values, K_values)
gap_bound = D - 1.0 / (2.0 * D * (K + 1))

# Normalize: show gap/d (fraction of classical bound)
gap_ratio = gap_bound / D

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Heatmap of gap bound
ax1 = axes[0]
im = ax1.imshow(gap_bound, aspect='auto', origin='lower',
                extent=[d_values[0]-0.5, d_values[-1]+0.5,
                        K_values[0]-0.5, K_values[-1]+0.5],
                cmap='RdYlGn_r')
ax1.set_xlabel('Uniformity d', fontsize=13)
ax1.set_ylabel('Pair Codegree Bound K', fontsize=13)
ax1.set_title('Integrality Gap Upper Bound\n$d - \\frac{1}{2d(K+1)}$', fontsize=14)
plt.colorbar(im, ax=ax1, label='Gap bound')

# Add contour lines
CS = ax1.contour(D, K, gap_bound, levels=[3, 4, 5, 6, 7, 8, 9],
                 colors='black', linewidths=0.8)
ax1.clabel(CS, inline=True, fontsize=9)

# Right: Gap improvement as percentage
ax2 = axes[1]
for d in [3, 4, 5, 7, 10]:
    improvement = 100 * (1 - (d - 1.0 / (2.0 * d * (K_values + 1))) / d)
    ax2.plot(K_values, improvement, 'o-', markersize=4, label=f'd = {d}')

ax2.set_xlabel('Pair Codegree Bound K', fontsize=13)
ax2.set_ylabel('Gap Improvement (%)', fontsize=13)
ax2.set_title('Improvement Over Classical d Bound\n$(1 - \\frac{\\text{gap bound}}{d}) \\times 100\\%$', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 20.5)

plt.tight_layout()
plt.savefig('viz_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_landscape.png")
