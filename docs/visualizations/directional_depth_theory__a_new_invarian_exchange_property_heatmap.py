"""
Visualization: Exchange Property from Log-Concavity
=====================================================

Visualizes the exchange inequality a(i)*a(j+1) <= a(i+1)*a(j) as a
heatmap, showing how log-concavity guarantees this matroid-like property.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def compute_exchange_matrix(seq):
    """Compute the exchange ratio matrix: a(i)*a(j+1) / (a(i+1)*a(j))."""
    n = len(seq)
    matrix = np.full((n, n), np.nan)
    for i in range(n - 1):
        for j in range(i, n - 1):
            if seq[i + 1] * seq[j] > 0:
                ratio = seq[i] * seq[j + 1] / (seq[i + 1] * seq[j])
                matrix[i, j] = ratio
    return matrix


# Sequences to compare
N = 10
binom = [math.comb(N, k) for k in range(N + 1)]

# A non-log-concave sequence for contrast
irregular = [1, 5, 2, 8, 3, 7, 4, 6, 5, 4, 3]

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: Log-concave (binomial)
mat1 = compute_exchange_matrix(binom)
ax1 = axes[0]
im1 = ax1.imshow(mat1, cmap='RdYlGn_r', vmin=0, vmax=2, aspect='equal')
ax1.set_xlabel('j', fontsize=11)
ax1.set_ylabel('i', fontsize=11)
ax1.set_title(f'Exchange Ratios: C({N},k)\n(all ≤ 1 for i ≤ j)', fontsize=13)
plt.colorbar(im1, ax=ax1, label='a(i)·a(j+1) / (a(i+1)·a(j))')

# Add a line showing i = j boundary
ax1.plot([-0.5, N - 0.5], [-0.5, N - 0.5], 'k--', linewidth=1, alpha=0.5)

# Right: Non-log-concave
mat2 = compute_exchange_matrix(irregular)
ax2 = axes[1]
im2 = ax2.imshow(mat2, cmap='RdYlGn_r', vmin=0, vmax=2, aspect='equal')
ax2.set_xlabel('j', fontsize=11)
ax2.set_ylabel('i', fontsize=11)
ax2.set_title('Exchange Ratios: Irregular Sequence\n(violations appear as red)', fontsize=13)
plt.colorbar(im2, ax=ax2, label='a(i)·a(j+1) / (a(i+1)·a(j))')

ax2.plot([-0.5, len(irregular) - 1.5], [-0.5, len(irregular) - 1.5],
         'k--', linewidth=1, alpha=0.5)

plt.suptitle('Exchange Property: Log-Concave vs Irregular Sequences',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('exchange_property.png', dpi=150, bbox_inches='tight')
print("Saved exchange_property.png")
