#!/usr/bin/env python3
"""
Visualization: The 17 Wallpaper Types — Rotation Order Distribution

Visualizes the crystallographic restriction theorem: only rotation orders
1, 2, 3, 4, 6 are compatible with 2D lattices. Shows the distribution
of the 17 wallpaper groups across these five rotation orders, with
their musical interpretations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Data: 17 wallpaper types grouped by rotation order
groups = {
    1: ['p1\n(free)', 'pm\n(palindrome)', 'pg\n(canon)', 'cm\n(round)'],
    2: ['p2\n(call &\nresponse)', 'pmm\n(bilateral\npalindrome)', 'pmg\n(inverted\ncanon)', 'pgg\n(double\ncanon)', 'cmm\n(round +\npalindrome)'],
    3: ['p3\n(3-bar\nblues)', 'p3m1\n(3-fold\nmirror)', 'p31m\n(3-fold\nglide)'],
    4: ['p4\n(4-bar\ncycle)', 'p4m\n(theme\nvariations)', 'p4g\n(inverted\nvariations)'],
    6: ['p6\n(whole-tone\nscale)', 'p6m\n(maximal\nsymmetry)'],
}

counts = {k: len(v) for k, v in groups.items()}

fig, axes = plt.subplots(1, 2, figsize=(16, 7), gridspec_kw={'width_ratios': [1, 2]})

# Left panel: bar chart of counts
ax1 = axes[0]
orders = list(counts.keys())
vals = list(counts.values())
colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0', '#F44336']
bars = ax1.bar(range(len(orders)), vals, color=colors, edgecolor='white', linewidth=2)
ax1.set_xticks(range(len(orders)))
ax1.set_xticklabels([str(o) for o in orders], fontsize=14)
ax1.set_xlabel('Maximum Rotation Order', fontsize=14)
ax1.set_ylabel('Number of Wallpaper Types', fontsize=14)
ax1.set_title('Crystallographic\nRestriction', fontsize=16, fontweight='bold')
ax1.set_ylim(0, 6.5)

# Add count labels
for bar, val in zip(bars, vals):
    ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
             str(val), ha='center', va='bottom', fontsize=16, fontweight='bold')

# Add total annotation
ax1.text(0.5, 0.95, f'Total: 4+5+3+3+2 = 17',
         transform=ax1.transAxes, ha='center', va='top',
         fontsize=12, style='italic',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

# Right panel: tile display of all 17 types
ax2 = axes[1]
ax2.set_xlim(-0.5, 5.5)
ax2.set_ylim(-0.5, 5.5)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('The 17 Wallpaper Groups\nand Their Musical Interpretations',
              fontsize=16, fontweight='bold')

# Place tiles
y_pos = {1: 4.5, 2: 3.0, 3: 1.5, 4: 0.5, 6: -0.5}
for idx, (order, names) in enumerate(groups.items()):
    color = colors[idx]
    y = 4.5 - idx * 1.2
    for j, name in enumerate(names):
        x = j * 1.1
        rect = plt.Rectangle((x - 0.45, y - 0.45), 0.9, 0.9,
                              facecolor=color, alpha=0.3,
                              edgecolor=color, linewidth=2)
        ax2.add_patch(rect)
        ax2.text(x, y, name, ha='center', va='center',
                fontsize=7, fontweight='bold')
    # Order label
    ax2.text(-0.8, y, f'n={order}', ha='right', va='center',
            fontsize=12, fontweight='bold', color=color)

plt.tight_layout()
plt.savefig('wallpaper_types.png', dpi=150, bbox_inches='tight')
print("Saved wallpaper_types.png")
