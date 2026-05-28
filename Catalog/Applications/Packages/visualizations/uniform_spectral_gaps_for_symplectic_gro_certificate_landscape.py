#!/usr/bin/env python3
"""
Visualization: Certificate Landscape Heatmap

Shows the landscape of DL rank-aware certificates across the (rank, field_size)
parameter space. The heatmap displays the spectral gap bound 1 - C_n/q,
making visible the region where certificates produce good expanders.

The "expander frontier" — the boundary where gap > 0 — traces the curve
q > C_n, revealing how larger ranks require larger field sizes for
expansion. This is a visual manifestation of the Landazuri–Seitz bounds.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

# Parameters
ranks = np.arange(1, 11)  # n = 1, ..., 10
field_sizes = np.arange(3, 102, 2)  # odd integers 3, 5, ..., 101

# Character ratio constants: C_n = 2n (conjectural general form)
def C_n(n):
    return 2.0 * n

# Compute gap matrix
gap_matrix = np.zeros((len(ranks), len(field_sizes)))
for i, n in enumerate(ranks):
    for j, q in enumerate(field_sizes):
        gap = 1 - C_n(n) / q
        gap_matrix[i, j] = max(gap, -0.2)

# Custom colormap: red (bad) → white (zero) → blue (good)
colors_list = ['#D32F2F', '#FF8A80', '#FFFFFF', '#82B1FF', '#1565C0']
cmap = LinearSegmentedColormap.from_list('gap_cmap', colors_list, N=256)

fig, ax = plt.subplots(figsize=(12, 6))

im = ax.imshow(gap_matrix, aspect='auto', cmap=cmap,
               vmin=-0.2, vmax=1.0, origin='lower',
               extent=[field_sizes[0]-1, field_sizes[-1]+1, 0.5, len(ranks)+0.5])

# Contour at gap = 0 (the "expander frontier")
X, Y = np.meshgrid(field_sizes, ranks)
contour = ax.contour(X, Y, gap_matrix, levels=[0], colors='black',
                     linewidths=2, linestyles='--')
ax.clabel(contour, fmt='gap=0', fontsize=10)

# Contour at gap = 0.5
contour2 = ax.contour(X, Y, gap_matrix, levels=[0.5], colors='darkblue',
                      linewidths=1.5, linestyles=':')
ax.clabel(contour2, fmt='gap=0.5', fontsize=9)

cbar = plt.colorbar(im, ax=ax, label='Spectral gap bound (1 − Cₙ/q)')

ax.set_xlabel('Field size q', fontsize=13)
ax.set_ylabel('Rank n (group is Sp₂ₙ)', fontsize=13)
ax.set_title('Certificate Landscape: Where Symplectic Expansion Lives',
             fontsize=14, fontweight='bold')
ax.set_yticks(ranks)
ax.set_yticklabels([f'n={n}' for n in ranks])

# Annotate key groups
annotations = [
    (5, 1, 'SL₂(𝔽₅)'),
    (5, 2, 'Sp₄(𝔽₅)'),
    (7, 3, 'Sp₆(𝔽₇)'),
    (11, 4, 'Sp₈(𝔽₁₁)'),
]
for q, n, label in annotations:
    ax.annotate(label, (q, n), fontsize=8, fontweight='bold',
                color='white' if gap_matrix[n-1, (q-3)//2] > 0.3 else 'black',
                ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='yellow', alpha=0.7))

plt.tight_layout()
plt.savefig('certificate_landscape.png', dpi=150, bbox_inches='tight')
print("Saved certificate_landscape.png")
