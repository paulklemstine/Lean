#!/usr/bin/env python3
"""
Visualization 3: Certification Landscape

A heatmap showing the certification confidence (in bits = −log₂ of the
SharpFailureUpperBound) as a function of dimension n and gap ratio ε/σ.
The semicircle edge at ε/σ = 2 appears as a sharp boundary.
"""

import numpy as np
import matplotlib.pyplot as plt


def sharp_failure_upper_bound(C, sigma, eps, n):
    gap = max(eps - 2 * sigma, 0)
    if C * sigma**2 == 0:
        return 1.0
    return np.exp(-gap**2 * n / (C * sigma**2))


sigma = 1.0
C = 1.0

n_vals = np.arange(5, 505, 5)
ratio_vals = np.linspace(1.0, 4.0, 200)

# Compute bits of confidence
bits = np.zeros((len(ratio_vals), len(n_vals)))
for i, r in enumerate(ratio_vals):
    for j, n in enumerate(n_vals):
        bound = sharp_failure_upper_bound(C, sigma, r * sigma, n)
        if bound > 0:
            bits[i, j] = min(-np.log2(bound), 200)  # cap at 200 bits
        else:
            bits[i, j] = 200

fig, ax = plt.subplots(figsize=(12, 7))

im = ax.pcolormesh(n_vals, ratio_vals, bits, cmap='inferno', shading='auto',
                   vmin=0, vmax=150)
cbar = fig.colorbar(im, ax=ax, label='Bits of confidence (−log₂ bound)')

# Mark the edge
ax.axhline(y=2.0, color='cyan', linestyle='--', linewidth=2, alpha=0.8,
           label='Semicircle edge: ε/σ = 2')

# Contour lines for specific confidence levels
contour_levels = [10, 20, 50, 100]
CS = ax.contour(n_vals, ratio_vals, bits, levels=contour_levels,
                colors='white', linewidths=1, alpha=0.7)
ax.clabel(CS, inline=True, fontsize=10, fmt='%d bits')

ax.set_xlabel('Dimension n', fontsize=14)
ax.set_ylabel('Gap ratio ε / σ', fontsize=14)
ax.set_title('Certification Confidence Landscape\n'
             'Bits of confidence = −log₂(SharpFailureUpperBound)',
             fontsize=15)
ax.legend(loc='upper left', fontsize=12)

plt.tight_layout()
plt.savefig('certification_landscape.png', dpi=150, bbox_inches='tight')
print("Saved certification_landscape.png")
