"""
Visualization: Chromatic Polynomial Bounds Heatmap

Creates a heatmap showing the ratio k^{(n)} / k^n (how close the chromatic
polynomial is to the naive upper bound) and the deficit bound verification.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def desc_factorial(k: int, n: int) -> int:
    """Compute falling factorial."""
    result = 1
    for i in range(n):
        result *= max(0, k - i)
    return result


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Ratio k^{(n)} / k^n
ax1 = axes[0]
n_range = range(1, 16)
k_range = range(1, 31)
ratio_matrix = np.zeros((len(list(n_range)), len(list(k_range))))

for i, n in enumerate(n_range):
    for j, k in enumerate(k_range):
        if k >= n and k > 0:
            df = desc_factorial(k, n)
            ratio_matrix[i, j] = df / (k ** n)
        else:
            ratio_matrix[i, j] = 0

im1 = ax1.imshow(ratio_matrix, aspect='auto', origin='lower',
                  extent=[0.5, 30.5, 0.5, 15.5],
                  cmap='viridis', vmin=0, vmax=1)
plt.colorbar(im1, ax=ax1, label='$k^{(n)} / k^n$')
ax1.set_xlabel('Number of colors $k$', fontsize=13)
ax1.set_ylabel('Graph size $n$', fontsize=13)
ax1.set_title('Chromatic Efficiency: $k^{(n)}/k^n$', fontsize=14, fontweight='bold')

# Draw the diagonal k = n (colorability threshold)
ax1.plot([1, 15], [1, 15], 'r--', linewidth=2, alpha=0.7, label='$k = n$ (threshold)')
ax1.legend(loc='upper right', fontsize=10)

# Right: Deficit ratio (k^n - k^{(n)}) / (C(n,2) * k^{n-1})
ax2 = axes[1]
deficit_matrix = np.zeros((len(list(range(2, 13))), len(list(range(2, 31)))))
n_range2 = range(2, 13)
k_range2 = range(2, 31)

for i, n in enumerate(n_range2):
    for j, k in enumerate(k_range2):
        if k >= n:
            deficit = k**n - desc_factorial(k, n)
            bound = comb(n, 2) * k**(n-1)
            if bound > 0:
                deficit_matrix[i, j] = deficit / bound
            else:
                deficit_matrix[i, j] = 0
        else:
            deficit_matrix[i, j] = np.nan

im2 = ax2.imshow(deficit_matrix, aspect='auto', origin='lower',
                  extent=[1.5, 30.5, 1.5, 12.5],
                  cmap='RdYlGn_r', vmin=0, vmax=1)
plt.colorbar(im2, ax=ax2, label='Deficit / Bound ratio')
ax2.set_xlabel('Number of colors $k$', fontsize=13)
ax2.set_ylabel('Graph size $n$', fontsize=13)
ax2.set_title('Deficit Bound: $(k^n - k^{(n)}) / (\\binom{n}{2} k^{n-1})$',
              fontsize=14, fontweight='bold')

# Add text annotation
ax2.text(20, 4, 'Ratio < 1\n(bound holds)', fontsize=11, 
         ha='center', va='center', color='darkgreen',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.tight_layout()
plt.savefig('bounds_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: bounds_heatmap.png")
