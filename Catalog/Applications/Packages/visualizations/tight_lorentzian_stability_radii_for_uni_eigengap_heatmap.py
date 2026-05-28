"""
Visualization 1: Heatmap of Lorentzian stability radius across uniform matroid families.

Shows how the stability radius 1/(2m) = 1/(2(n-r+2)) varies with n and r,
revealing the spectral-dimensional structure of Lorentzian robustness.

The key insight: stability radius depends only on the leaf dimension m = n-r+2,
creating diagonal bands of equal robustness in the (n,r) parameter space.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# Compute stability data
max_n = 20
radius_matrix = np.full((max_n + 1, max_n + 1), np.nan)
gap_matrix = np.full((max_n + 1, max_n + 1), np.nan)

for n in range(4, max_n + 1):
    for r in range(2, n - 1):
        m = n - r + 2
        radius_matrix[r, n] = 1.0 / (2 * m)
        gap_matrix[r, n] = 1.0  # always 1

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Stability radius heatmap
ax1 = axes[0]
im1 = ax1.imshow(radius_matrix[2:max_n-1, 4:max_n+1],
                  aspect='auto', cmap='viridis', origin='lower',
                  extent=[4, max_n, 2, max_n-2])
ax1.set_xlabel('n (number of variables)', fontsize=12)
ax1.set_ylabel('r (matroid rank)', fontsize=12)
ax1.set_title('Lorentzian Stability Radius\n1/(2m) for U_{r,n}', fontsize=14)
plt.colorbar(im1, ax=ax1, label='Stability radius')

# Add diagonal lines for constant m
for m in range(3, 12):
    n_vals = np.arange(max(4, m), max_n + 1)
    r_vals = n_vals - m + 2
    valid = (r_vals >= 2) & (r_vals <= n_vals - 2)
    if np.any(valid):
        ax1.plot(n_vals[valid], r_vals[valid], 'w--', alpha=0.4, linewidth=0.8)
        mid = len(n_vals[valid]) // 2
        if mid < len(n_vals[valid]):
            ax1.text(n_vals[valid][mid], r_vals[valid][mid], f'm={m}',
                    color='white', fontsize=7, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.1', fc='black', alpha=0.3))

# Plot 2: Stability radius vs leaf dimension
ax2 = axes[1]
m_values = np.arange(3, 20)
radii = 1.0 / (2 * m_values)
gaps = np.ones_like(m_values, dtype=float)

ax2.semilogy(m_values, radii, 'bo-', markersize=6, linewidth=2, label='Stability radius 1/(2m)')
ax2.semilogy(m_values, gaps, 'rs--', markersize=6, linewidth=2, label='Spectral gap (always 1)')
ax2.semilogy(m_values, 1.0/m_values, 'g^-', markersize=5, linewidth=1.5, 
             label='Instability scale 1/m', alpha=0.7)

ax2.set_xlabel('Leaf dimension m = n - r + 2', fontsize=12)
ax2.set_ylabel('Scale', fontsize=12)
ax2.set_title('Stability Radius vs Leaf Dimension', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(m_values[::2])

plt.tight_layout()
plt.savefig('viz_eigengap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_eigengap_heatmap.png")
