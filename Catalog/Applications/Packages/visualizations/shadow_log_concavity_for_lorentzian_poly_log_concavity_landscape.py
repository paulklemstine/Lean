"""
Visualization: Log-Concavity Landscape

A surface/heatmap showing the log-concavity ratio C(n,k)²/(C(n,k-1)·C(n,k+1))
across all valid (n, k) pairs. This visualizes the fundamental arithmetic
inequality underlying shadow log-concavity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# ─── Compute log-concavity ratios ────────────────────────────────────────────

N_MAX = 20
data = np.full((N_MAX + 1, N_MAX + 1), np.nan)

for n in range(2, N_MAX + 1):
    for k in range(1, n):
        denom = comb(n, k - 1) * comb(n, k + 1)
        if denom > 0:
            ratio = comb(n, k) ** 2 / denom
            data[n, k] = ratio

# ─── Plot ─────────────────────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Heatmap
masked_data = np.ma.masked_invalid(data)
im = ax1.imshow(masked_data, origin='lower', aspect='auto',
                cmap='viridis', interpolation='nearest',
                vmin=1.0, vmax=3.0)
ax1.set_xlabel('k', fontsize=12)
ax1.set_ylabel('n', fontsize=12)
ax1.set_title('Log-concavity ratio C(n,k)² / [C(n,k-1)·C(n,k+1)]\n'
              'All values ≥ 1 (log-concavity holds everywhere)',
              fontsize=11, fontweight='bold')
plt.colorbar(im, ax=ax1, label='Ratio (≥ 1 means log-concave)')

# Add contour showing ratio = 1 line (minimum)
ax1.contour(masked_data, levels=[1.0, 1.5, 2.0, 2.5],
            colors='white', linewidths=0.5, origin='lower')

# Panel 2: Slices for specific n values
n_values = [5, 8, 12, 16, 20]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

for n_val, color in zip(n_values, colors):
    ks = list(range(1, n_val))
    ratios = []
    for k in ks:
        denom = comb(n_val, k-1) * comb(n_val, k+1)
        if denom > 0:
            ratios.append(comb(n_val, k)**2 / denom)
        else:
            ratios.append(np.nan)
    ax2.plot(ks, ratios, 'o-', color=color, label=f'n={n_val}',
             markersize=5, linewidth=1.5)

ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=1, alpha=0.7,
            label='Ratio = 1 (tight log-concavity)')
ax2.set_xlabel('k', fontsize=12)
ax2.set_ylabel('C(n,k)² / [C(n,k-1)·C(n,k+1)]', fontsize=12)
ax2.set_title('Log-concavity ratio by k for various n\n'
              'Minimum at k = ⌊n/2⌋ (where C(n,k) is largest)',
              fontsize=11, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(alpha=0.3)
ax2.set_ylim(0.9, 4.0)

fig.suptitle('The Arithmetic Core of Shadow Log-Concavity:\n'
             'Binomial Coefficient Log-Concavity Landscape',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('logconcavity_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved logconcavity_landscape.png")
