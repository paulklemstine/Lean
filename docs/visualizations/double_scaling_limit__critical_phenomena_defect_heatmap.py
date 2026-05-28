"""
Defect Heatmap Visualization

Produces a heatmap of the wreath defect |Δ(k,m)| and the
relevance ratio Φ_α(k,m) in the (k, m) plane, providing a
visual "phase diagram" of the perturbation landscape.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def wreath_defect_grid(k_arr, m_arr):
    """Compute wreath defect on a grid."""
    K, M = np.meshgrid(k_arr, m_arr)
    return np.where(K >= 2, M / K, 0.0)


def relevance_ratio_grid(k_arr, m_arr, alpha):
    """Compute relevance ratio on a grid."""
    K, M = np.meshgrid(k_arr, m_arr)
    delta = np.where(K >= 2, M / K, 0.0)
    denom = M / np.power(K, alpha)
    with np.errstate(divide='ignore', invalid='ignore'):
        ratio = np.abs(delta) / denom
    ratio = np.where(np.isfinite(ratio), ratio, 0.0)
    return ratio


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

k_vals = np.arange(2, 61)
m_vals = np.arange(1, 201)

# Panel 1: Raw defect heatmap
ax = axes[0]
defect = wreath_defect_grid(k_vals, m_vals)
im1 = ax.pcolormesh(k_vals, m_vals, defect, shading='auto',
                     cmap='inferno', norm=LogNorm(vmin=0.01, vmax=100))
# Critical boundary
k_line = np.linspace(2, 60, 200)
ax.plot(k_line, k_line ** 1.0, 'w--', linewidth=2, label='m = k (critical)')
ax.plot(k_line, k_line ** 0.5, 'c--', linewidth=1.5, alpha=0.7, label='m = √k')
ax.plot(k_line, np.minimum(k_line ** 2, 200), 'r--', linewidth=1.5, alpha=0.7, label='m = k²')
ax.set_xlabel('Base degree k', fontsize=12)
ax.set_ylabel('Copies m', fontsize=12)
ax.set_title('Wreath Defect |Δ(k,m)|', fontsize=13)
ax.legend(fontsize=9, loc='upper left')
plt.colorbar(im1, ax=ax, label='|Δ(k,m)|')

# Panel 2: Relevance ratio at α = 1.0
ax = axes[1]
rr = relevance_ratio_grid(k_vals, m_vals, 1.0)
# Clip for visualization
rr_clipped = np.clip(rr, 0.01, 100)
im2 = ax.pcolormesh(k_vals, m_vals, rr_clipped, shading='auto',
                     cmap='RdYlBu_r', norm=LogNorm(vmin=0.01, vmax=100))
ax.plot(k_line, k_line ** 1.0, 'k--', linewidth=2, label='m = k^α')
ax.set_xlabel('Base degree k', fontsize=12)
ax.set_ylabel('Copies m', fontsize=12)
ax.set_title('Relevance Ratio Φ₁(k,m)', fontsize=13)
ax.legend(fontsize=9, loc='upper left')
plt.colorbar(im2, ax=ax, label='Φ_α(k,m)')

# Panel 3: Defect scaling test (conjecture validation)
ax = axes[2]
test_ks = [3, 4, 5, 6, 7, 8, 10, 15, 20, 30, 50]
for alpha in [0.5, 1.0, 1.5, 2.0]:
    data_x = []
    data_y = []
    for k in test_ks:
        for m_mult in [0.5, 1.0, 2.0, 5.0, 10.0]:
            m = max(1, round(m_mult * k ** alpha))
            x = m / k ** alpha  # λ
            delta = m / k if k >= 2 else 0  # defect
            y = k ** alpha / m * delta if m > 0 else 0  # rescaled
            data_x.append(x)
            data_y.append(y)
    ax.scatter(data_x, data_y, s=20, alpha=0.6, label=f'α={alpha}')

ax.set_xlabel('λ = m / k^α', fontsize=12)
ax.set_ylabel('Rescaled defect', fontsize=12)
ax.set_title('Scaling Collapse Test', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim([0, 12])

plt.suptitle('Wreath-Product Subgroup Pressure: Scaling Landscape', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_defect_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_defect_heatmap.png")
