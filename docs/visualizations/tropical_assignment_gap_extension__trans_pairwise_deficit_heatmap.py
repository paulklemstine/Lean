"""
Visualization 1: Assignment Gap Heatmap

Visualizes the pairwise deficit landscape for a weight matrix,
showing which transposition swaps are most/least costly. The
theorem says that under symmetric diagonal dominance, the
cheapest swap (smallest deficit) determines the full assignment gap.

Self-contained — all functions inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def pair_deficit(W, i, j):
    """W[i,i] + W[j,j] - 2*W[i,j]"""
    return W[i, i] + W[j, j] - 2 * W[i, j]


# Generate a symmetric diagonally dominant matrix
np.random.seed(42)
n = 6
G = np.random.randn(n, n)
W = (G + G.T) / 2 + 4 * np.eye(n)

# Compute pairwise deficit matrix
D = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            D[i, j] = pair_deficit(W, i, j)
        else:
            D[i, j] = 0  # diagonal is always 0

# Find minimum deficit (determines assignment gap)
min_val = np.inf
min_pair = (0, 0)
for i in range(n):
    for j in range(i + 1, n):
        if D[i, j] < min_val:
            min_val = D[i, j]
            min_pair = (i, j)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: Weight matrix
ax1 = axes[0]
im1 = ax1.imshow(W, cmap='RdYlBu_r', aspect='equal')
ax1.set_title('Weight Matrix W', fontsize=14, fontweight='bold')
ax1.set_xlabel('Column j')
ax1.set_ylabel('Row i')
for i in range(n):
    for j in range(n):
        ax1.text(j, i, f'{W[i,j]:.1f}', ha='center', va='center',
                fontsize=8, color='black' if abs(W[i,j]) < 3 else 'white')
plt.colorbar(im1, ax=ax1, label='W[i,j]')

# Right: Pairwise deficit heatmap
ax2 = axes[1]
# Mask diagonal
D_masked = np.ma.masked_where(np.eye(n, dtype=bool), D)
im2 = ax2.imshow(D_masked, cmap='YlOrRd', aspect='equal')
ax2.set_title('Pairwise Deficit d(i,j) = W[i,i]+W[j,j]−2W[i,j]',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('j')
ax2.set_ylabel('i')

for i in range(n):
    for j in range(n):
        if i != j:
            ax2.text(j, i, f'{D[i,j]:.1f}', ha='center', va='center',
                    fontsize=8)

# Highlight minimum deficit pair
i0, j0 = min_pair
rect = plt.Rectangle((j0 - 0.5, i0 - 0.5), 1, 1, linewidth=3,
                      edgecolor='blue', facecolor='none')
ax2.add_patch(rect)
rect2 = plt.Rectangle((i0 - 0.5, j0 - 0.5), 1, 1, linewidth=3,
                       edgecolor='blue', facecolor='none')
ax2.add_patch(rect2)

plt.colorbar(im2, ax=ax2, label='Deficit')

ax2.text(0.02, -0.12,
         f'Min deficit: d({i0},{j0}) = {min_val:.2f} (blue box)\n'
         f'Assignment gap = min deficit = {min_val:.2f}',
         transform=ax2.transAxes, fontsize=10, color='blue',
         fontweight='bold')

plt.suptitle('Tropical Assignment Gap: Pairwise Deficit Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
