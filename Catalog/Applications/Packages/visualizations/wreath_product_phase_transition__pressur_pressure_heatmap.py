#!/usr/bin/env python3
"""
Visualization: Pressure Heatmap Over (k, m) Parameter Space

Displays a heatmap of the non-coordinate pressure fraction
P_noncoord / P_total across the (k, m) parameter space,
showing that the fraction shrinks as m grows (universality)
and as k grows (stronger suppression of non-coordinate subgroups).
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inline functions (self-contained) ───

def pressure_Sk(k):
    data = {
        3: [3, 2],
        4: [4, 2, 3],
        5: [5, 2, 10, 15, 6],
        6: [6, 2, 15, 20, 15, 10, 6],
        7: [7, 2, 21, 35, 21],
        8: [8, 2, 28, 56, 35, 28],
    }
    return sum(1.0 / i for i in data.get(k, [k, 2]))

def noncoord_est(k, m):
    if m <= 1:
        return 0.0
    kf = math.factorial(min(k, 10))  # cap for numerical stability
    return 0.5 * math.log(m) + m * (m - 1) / (2 * kf)

def noncoord_fraction(k, m):
    if m <= 1:
        return 0.0
    p_c = m * pressure_Sk(k)
    p_nc = noncoord_est(k, m)
    total = p_c + p_nc
    return p_nc / total if total > 0 else 0

# ─── Generate heatmap data ───
k_range = range(3, 9)
m_range = range(2, 101)

Z = np.zeros((len(k_range), len(m_range)))
for i, k in enumerate(k_range):
    for j, m in enumerate(m_range):
        Z[i, j] = noncoord_fraction(k, m)

# ─── Create figure ───
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5),
                                gridspec_kw={'width_ratios': [2, 1]})
fig.suptitle('Non-Coordinate Pressure Fraction in Wreath Products',
             fontsize=14, fontweight='bold')

# Heatmap
im = ax1.imshow(Z, aspect='auto', origin='lower',
               extent=[2, 100, 2.5, 8.5],
               cmap='YlOrRd_r', vmin=0, vmax=0.5)
ax1.set_xlabel('$m$ (number of copies)', fontsize=12)
ax1.set_ylabel('$k$ (symmetric group degree)', fontsize=12)
ax1.set_title('$P_{\\mathrm{noncoord}} / P_{\\mathrm{total}}$', fontsize=12)
ax1.set_yticks(range(3, 9))
cbar = plt.colorbar(im, ax=ax1, shrink=0.8)
cbar.set_label('Non-coordinate fraction', fontsize=10)

# Add contour lines
m_grid = np.array(list(m_range))
k_grid = np.array(list(k_range))
M, K = np.meshgrid(m_grid, k_grid)
contours = ax1.contour(M, K, Z, levels=[0.01, 0.05, 0.1, 0.2],
                       colors='black', linewidths=0.8, alpha=0.7)
ax1.clabel(contours, inline=True, fontsize=8, fmt='%.2f')

# Slice plot: fraction vs m for different k
for k in [3, 5, 7]:
    fracs = [noncoord_fraction(k, m) for m in m_range]
    ax2.plot(list(m_range), fracs, linewidth=2, label=f'$k={k}$')

ax2.set_xlabel('$m$', fontsize=12)
ax2.set_ylabel('Non-coord fraction', fontsize=12)
ax2.set_title('Fraction decay by $k$', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 0.5)

plt.tight_layout()
plt.savefig('pressure_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: pressure_heatmap.png")
