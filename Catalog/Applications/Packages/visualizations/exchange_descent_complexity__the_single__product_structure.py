#!/usr/bin/env python3
"""
Visualization: Product Family Structure and Iterated Amplification

Shows:
1. How descent length grows under iterated products (linear amplification)
2. The gap between achieved WDL and conjectured bounds d^(d-k)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

# ─── Data computation ───

# Panel 1: Iterated product amplification
# For linear family with base WDL = L, k copies give WDL = k * L
base_wdls = [3, 4, 5]
k_range = list(range(1, 11))

amplified = {}
for L in base_wdls:
    amplified[L] = [k * L for k in k_range]

# Panel 2: Gap analysis
# Compare achieved WDL with theoretical bounds
d_range = list(range(3, 18))
gap_data = {}
for k in [0, 1, 2]:
    gap_data[k] = {
        'd': d_range,
        'achieved': [d for d in d_range],  # Linear family: WDL = d
        'upper': [d ** max(0, d - k) for d in d_range],
        'lower_conj': [d ** max(0, d - k - 1) for d in d_range],
    }

# ─── Plotting ───

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle('Product Amplification & Single-Power Gap Analysis',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Iterated product
ax = axes[0]
colors = ['#e41a1c', '#377eb8', '#4daf4a']
markers = ['o', 's', '^']
for L, color, marker in zip(base_wdls, colors, markers):
    ax.plot(k_range, amplified[L], f'{marker}-', color=color,
            linewidth=2, markersize=6,
            label=f'Base WDL = {L}')
    # Add theory line
    ax.plot(k_range, [k * L for k in k_range], '--', color=color,
            alpha=0.5, linewidth=1)

ax.set_xlabel('Number of Product Copies k', fontsize=12)
ax.set_ylabel('Worst-Case Descent Length', fontsize=12)
ax.set_title('Iterated Product Amplification\n(WDL = k × base)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Gap analysis
ax = axes[1]
k_colors = {0: '#e41a1c', 1: '#377eb8', 2: '#4daf4a'}
for k in [0, 1, 2]:
    data = gap_data[k]
    # Plot log ratio: log(achieved) / log(upper)
    ratios = []
    for d, ach, up in zip(data['d'], data['achieved'], data['upper']):
        if d > 1 and ach > 0 and up > 0:
            # Effective exponent: log(WDL) / log(d)
            eff_exp = math.log(ach) / math.log(d)
            ratios.append(eff_exp)
        else:
            ratios.append(0)
    
    ax.plot(data['d'][:len(ratios)], ratios, 'o-',
            color=k_colors[k], linewidth=2, markersize=5,
            label=f'Effective exponent (k={k})')
    
    # Theoretical exponent d-k
    theory = [d - k for d in data['d']]
    ax.plot(data['d'], theory, '--', color=k_colors[k], alpha=0.4,
            linewidth=1.5)

ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Effective Exponent (log WDL / log d)', fontsize=12)
ax.set_title('Gap Analysis: Effective vs Conjectured Exponent\n'
             '(dashed = d−k conjecture)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('viz_product_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_product_structure.png")
