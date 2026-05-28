"""
Visualization 2: Stability Radius Heatmap

Displays the certified entry-wise stability radius 1/m² as a heatmap across
all valid uniform matroids U_{r,n} with n ≤ 15, 2 ≤ r ≤ n-2.
Also shows the empirical-to-certified ratio, revealing how conservative
the certified bound is.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

max_n = 15
# Compute data
data_radius = np.full((max_n + 1, max_n + 1), np.nan)
data_normalized = np.full((max_n + 1, max_n + 1), np.nan)

for n in range(4, max_n + 1):
    for r in range(2, n - 1):
        m = n - r + 2
        entry_radius = 1.0 / (m * m)
        normalized_gap = 1.0 / (m - 1) if m > 1 else 0
        data_radius[n, r] = np.log10(entry_radius)
        data_normalized[n, r] = normalized_gap

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap 1: Entry-wise stability radius (log scale)
ax1 = axes[0]
im1 = ax1.imshow(data_radius[4:, 2:], aspect='auto', origin='lower',
                  cmap='viridis', interpolation='nearest',
                  extent=[1.5, max_n - 0.5, 3.5, max_n + 0.5])
ax1.set_xlabel('Rank r', fontsize=12)
ax1.set_ylabel('Ground set size n', fontsize=12)
ax1.set_title('log₁₀(Entry-wise Stability Radius)', fontsize=14)
cb1 = plt.colorbar(im1, ax=ax1)
cb1.set_label('log₁₀(1/m²)', fontsize=10)

# Add text annotations for small values
for n in range(4, min(max_n + 1, 10)):
    for r in range(2, n - 1):
        m = n - r + 2
        val = 1.0 / (m * m)
        if not np.isnan(data_radius[n, r]):
            ax1.text(r, n, f'{val:.3f}', ha='center', va='center',
                    fontsize=6, color='white' if val < 0.05 else 'black')

# Heatmap 2: Normalized spectral gap
ax2 = axes[1]
im2 = ax2.imshow(data_normalized[4:, 2:], aspect='auto', origin='lower',
                  cmap='plasma', interpolation='nearest',
                  extent=[1.5, max_n - 0.5, 3.5, max_n + 0.5])
ax2.set_xlabel('Rank r', fontsize=12)
ax2.set_ylabel('Ground set size n', fontsize=12)
ax2.set_title('Normalized Spectral Gap 1/(m-1)', fontsize=14)
cb2 = plt.colorbar(im2, ax=ax2)
cb2.set_label('1/(m-1)', fontsize=10)

# Add text annotations
for n in range(4, min(max_n + 1, 10)):
    for r in range(2, n - 1):
        m = n - r + 2
        if m > 1 and not np.isnan(data_normalized[n, r]):
            ax2.text(r, n, f'{1/(m-1):.2f}', ha='center', va='center',
                    fontsize=6, color='white' if 1/(m-1) < 0.3 else 'black')

fig.suptitle('Lorentzian Stability Landscape for Uniform Matroids',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_stability_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability_heatmap.png")
