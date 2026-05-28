"""
Visualization: Tropical Spectral Gap Heatmap

Visualizes the diagonal minor gaps Δ(i,j) for a random diagonally dominant
weight matrix. The minimum gap (tropical spectral gap) is highlighted.
This shows how the tropical shadow captures the "weakest link" in stability.
"""

import numpy as np
import matplotlib.pyplot as plt

# Create a random diagonally dominant weight matrix
np.random.seed(42)
n = 8
W = np.random.randn(n, n) * 0.5
W = (W + W.T) / 2
np.fill_diagonal(W, np.abs(W).sum(axis=1) + np.random.uniform(0.5, 2.0, n))

# Compute diagonal minor gaps
gaps = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            gaps[i, j] = W[i, i] + W[j, j] - 2 * W[i, j]
        else:
            gaps[i, j] = np.nan  # diagonal is meaningless

# Find minimum gap
min_gap = np.nanmin(gaps)
min_idx = np.unravel_index(np.nanargmin(gaps), gaps.shape)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: Weight matrix
ax1 = axes[0]
im1 = ax1.imshow(W, cmap='RdYlBu_r', aspect='equal')
ax1.set_title('Weight Matrix W\n(tropical shadow of coefficients)', fontsize=12)
ax1.set_xlabel('Index j')
ax1.set_ylabel('Index i')
plt.colorbar(im1, ax=ax1, label='w(i,j) = log(a[i,j])')
for i in range(n):
    for j in range(n):
        ax1.text(j, i, f'{W[i,j]:.1f}', ha='center', va='center', fontsize=7,
                color='white' if abs(W[i,j]) > 2 else 'black')

# Right: Gap heatmap
ax2 = axes[1]
gaps_display = gaps.copy()
gaps_display[np.isnan(gaps_display)] = 0
im2 = ax2.imshow(gaps_display, cmap='YlOrRd_r', aspect='equal')
ax2.set_title(f'Diagonal Minor Gaps Δ(i,j)\nTropical Spectral Gap = {min_gap:.3f}', fontsize=12)
ax2.set_xlabel('Index j')
ax2.set_ylabel('Index i')
plt.colorbar(im2, ax=ax2, label='Δ(i,j) = w(i,i) + w(j,j) - 2w(i,j)')

# Highlight minimum
rect = plt.Rectangle((min_idx[1]-0.5, min_idx[0]-0.5), 1, 1,
                      linewidth=3, edgecolor='blue', facecolor='none')
ax2.add_patch(rect)
ax2.annotate(f'Min gap\n({min_idx[0]},{min_idx[1]})',
            xy=(min_idx[1], min_idx[0]),
            xytext=(min_idx[1]+1.5, min_idx[0]-1.5),
            fontsize=9, color='blue', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))

# Mark diagonal as N/A
for i in range(n):
    ax2.text(i, i, 'N/A', ha='center', va='center', fontsize=7, color='gray')
    for j in range(n):
        if i != j:
            ax2.text(j, i, f'{gaps[i,j]:.1f}', ha='center', va='center', fontsize=7,
                    color='white' if gaps[i,j] < min_gap + 1 else 'black')

plt.suptitle('Tropical Shadow: From Weight Matrix to Stability Certificate',
            fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_heatmap.png")
