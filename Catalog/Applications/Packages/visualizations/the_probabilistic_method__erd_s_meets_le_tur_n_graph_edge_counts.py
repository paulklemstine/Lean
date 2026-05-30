"""
Visualization: Turán Graph Edge Counts

Plots the Turán edge count T(n,r) as a function of n for various r,
showing how the density of the densest K_{r+1}-free graph approaches
(1-1/r) as n grows.

This visualizes Turán's theorem: the extremal number ex(n, K_{r+1}).
"""

import math
import matplotlib.pyplot as plt
import numpy as np

def turan_edge_count(n, r):
    """Compute the number of edges in the Turán graph T(n,r)."""
    if r == 0:
        return 0
    q, s = divmod(n, r)
    sum_sq = s * (q + 1) ** 2 + (r - s) * q ** 2
    return (n * n - sum_sq) // 2

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Edge counts for different r
n_values = np.arange(3, 51)
for r, color in [(2, '#e74c3c'), (3, '#3498db'), (4, '#2ecc71'), (5, '#9b59b6')]:
    edges = [turan_edge_count(n, r) for n in n_values]
    complete = [n * (n - 1) // 2 for n in n_values]
    axes[0].plot(n_values, edges, '-', color=color, linewidth=2, label=f'T(n,{r})')

complete = [n * (n - 1) // 2 for n in n_values]
axes[0].plot(n_values, complete, 'k--', linewidth=1, alpha=0.5, label='K_n')
axes[0].set_xlabel('n (vertices)', fontsize=13)
axes[0].set_ylabel('Edges', fontsize=13)
axes[0].set_title('Turán Edge Counts ex(n, K_{r+1})', fontsize=14)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)

# Plot 2: Density ratio T(n,r) / C(n,2) approaching (1-1/r)
n_values_large = np.arange(5, 101)
for r, color in [(2, '#e74c3c'), (3, '#3498db'), (4, '#2ecc71'), (5, '#9b59b6')]:
    density = [2 * turan_edge_count(n, r) / (n * (n - 1)) if n > 1 else 0 for n in n_values_large]
    axes[1].plot(n_values_large, density, '-', color=color, linewidth=2, label=f'r={r}')
    # Asymptotic limit
    axes[1].axhline(y=1 - 1/r, color=color, linestyle=':', alpha=0.5)

axes[1].set_xlabel('n (vertices)', fontsize=13)
axes[1].set_ylabel('Edge density', fontsize=13)
axes[1].set_title('Density → (1 - 1/r) as n → ∞', fontsize=14)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)
axes[1].set_ylim(0, 1.05)

# Plot 3: Heatmap of T(n,r) for small n and r
n_range = range(2, 21)
r_range = range(1, 11)
data = np.zeros((len(list(r_range)), len(list(n_range))))
for i, r in enumerate(r_range):
    for j, n in enumerate(n_range):
        data[i, j] = turan_edge_count(n, r)

im = axes[2].imshow(data, aspect='auto', cmap='YlOrRd', origin='lower')
axes[2].set_xlabel('n (vertices)', fontsize=13)
axes[2].set_ylabel('r (parts)', fontsize=13)
axes[2].set_title('Turán Edge Count Heatmap', fontsize=14)
axes[2].set_xticks(range(0, len(list(n_range)), 3))
axes[2].set_xticklabels(list(n_range)[::3])
axes[2].set_yticks(range(len(list(r_range))))
axes[2].set_yticklabels(list(r_range))
plt.colorbar(im, ax=axes[2], label='Edges')

plt.tight_layout()
plt.savefig('turan_graphs.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved turan_graphs.png")
