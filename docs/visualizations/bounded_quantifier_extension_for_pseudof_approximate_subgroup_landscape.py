"""
Visualization: Approximate Subgroup Landscape

Heatmap showing the doubling constant K = |A+A|/|A| for subsets of Z/nZ
across different group sizes and subset sizes. Highlights regions where
approximate subgroups (K ≤ 3) emerge.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)

def product_set(A, B, n):
    return {(a + b) % n for a in A for b in B}

def inverse_set(A, n):
    return {(-a) % n for a in A}

# Generate heatmap data
group_sizes = list(range(6, 51, 2))
subset_fracs = np.linspace(0.1, 0.9, 20)

# For each (n, fraction), sample random symmetric sets and record average K
heatmap_data = np.zeros((len(group_sizes), len(subset_fracs)))
heatmap_min = np.full((len(group_sizes), len(subset_fracs)), np.inf)

for i, n in enumerate(group_sizes):
    for j, frac in enumerate(subset_fracs):
        target_size = max(2, int(frac * n))
        k_values = []
        
        for _ in range(50):
            elts = random.sample(range(n), min(target_size, n))
            A = set(elts) | inverse_set(set(elts), n)
            A.add(0)
            
            AA = product_set(A, A, n)
            K = len(AA) / len(A) if len(A) > 0 else n
            k_values.append(K)
        
        heatmap_data[i, j] = np.mean(k_values)
        heatmap_min[i, j] = np.min(k_values)

# Plot
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Left: average doubling constant
ax1 = axes[0]
im1 = ax1.imshow(heatmap_data.T, aspect='auto', origin='lower',
                  extent=[group_sizes[0], group_sizes[-1], 
                          subset_fracs[0], subset_fracs[-1]],
                  cmap='RdYlGn_r', vmin=1, vmax=5)
ax1.set_xlabel('Group size n', fontsize=12)
ax1.set_ylabel('Subset fraction |A|/n', fontsize=12)
ax1.set_title('Average Doubling Constant K', fontsize=14)
plt.colorbar(im1, ax=ax1, label='K = |A+A|/|A|')

# Overlay contour at K=2 and K=3
X, Y = np.meshgrid(group_sizes, subset_fracs)
contour = ax1.contour(X, Y, heatmap_data.T, levels=[2, 3], 
                       colors=['blue', 'red'], linewidths=2)
ax1.clabel(contour, inline=True, fontsize=10, fmt='K=%.0f')

# Right: minimum doubling constant (best case)
ax2 = axes[1]
im2 = ax2.imshow(heatmap_min.T, aspect='auto', origin='lower',
                  extent=[group_sizes[0], group_sizes[-1],
                          subset_fracs[0], subset_fracs[-1]],
                  cmap='RdYlGn_r', vmin=1, vmax=5)
ax2.set_xlabel('Group size n', fontsize=12)
ax2.set_ylabel('Subset fraction |A|/n', fontsize=12)
ax2.set_title('Minimum Doubling Constant (Best Case)', fontsize=14)
plt.colorbar(im2, ax=ax2, label='min K')

contour2 = ax2.contour(X, Y, heatmap_min.T, levels=[1, 1.5, 2], 
                        colors=['green', 'blue', 'red'], linewidths=2)
ax2.clabel(contour2, inline=True, fontsize=10, fmt='K=%.1f')

plt.tight_layout()
plt.savefig('approx_subgroups_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: approx_subgroups_landscape.png")
