#!/usr/bin/env python3
"""
Visualization: Dimensional Hierarchy of Gravitational Orbits
Shows the Goldilocks nature of 3D for gravity.
"""

import math
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_dimensional_data():
    """Compute orbital properties for dimensions 1-7."""
    data = []
    for n in range(1, 8):
        bp = 4 - n  # Bertrand parameter
        force_exp = 1 - n
        stable = bp > 0
        if stable:
            ratio = 1.0 / math.sqrt(bp)
            # Check if bp is a perfect square
            sqrt_bp = round(math.sqrt(bp))
            closed = (sqrt_bp * sqrt_bp == bp)
        else:
            ratio = None
            closed = False
        goldilocks = stable and closed
        data.append({
            'n': n, 'bp': bp, 'stable': stable,
            'closed': closed, 'goldilocks': goldilocks,
            'ratio': ratio, 'force_exp': force_exp,
        })
    return data


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

data = compute_dimensional_data()

# Panel 1: Bertrand parameter vs dimension
ax1 = axes[0, 0]
dims = [d['n'] for d in data]
bps = [d['bp'] for d in data]
colors = ['gold' if d['goldilocks'] else '#4CAF50' if d['stable'] else '#F44336' for d in data]
bars = ax1.bar(dims, bps, color=colors, edgecolor='black', linewidth=0.8)
ax1.axhline(y=0, color='black', linewidth=1)
ax1.set_xlabel('Spatial Dimension n', fontsize=12)
ax1.set_ylabel('Bertrand Parameter (4-n)', fontsize=12)
ax1.set_title('Stability Discriminant by Dimension', fontsize=12)
ax1.set_xticks(dims)
legend_patches = [
    mpatches.Patch(color='gold', label='Goldilocks (stable + closed)'),
    mpatches.Patch(color='#4CAF50', label='Stable but non-closing'),
    mpatches.Patch(color='#F44336', label='Unstable'),
]
ax1.legend(handles=legend_patches, fontsize=9)
ax1.grid(True, alpha=0.3, axis='y')

# Panel 2: Apsidal angle ratio
ax2 = axes[0, 1]
stable_data = [d for d in data if d['stable']]
s_dims = [d['n'] for d in stable_data]
s_ratios = [d['ratio'] for d in stable_data]
s_colors = ['gold' if d['goldilocks'] else '#2196F3' for d in stable_data]
ax2.bar(s_dims, s_ratios, color=s_colors, edgecolor='black', linewidth=0.8)
ax2.axhline(y=1.0, color='red', linestyle='--', label='Rational (closed orbits)', linewidth=1.5)
for d in stable_data:
    label = f"{d['ratio']:.4f}" if d['ratio'] else ""
    ax2.annotate(label, xy=(d['n'], d['ratio']),
                ha='center', va='bottom', fontsize=9, fontweight='bold')
ax2.set_xlabel('Spatial Dimension n', fontsize=12)
ax2.set_ylabel('Apsidal Ratio 1/√(4-n)', fontsize=12)
ax2.set_title('Apsidal Angle Ratio (must be rational for closure)', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_xticks(s_dims)
ax2.grid(True, alpha=0.3)

# Panel 3: Force law exponents
ax3 = axes[1, 0]
force_exps = [d['force_exp'] for d in data]
ax3.plot(dims, force_exps, 'ko-', markersize=8, linewidth=2)
for d in data:
    label = f"r^{{{d['force_exp']}}}"
    ax3.annotate(label, xy=(d['n'], d['force_exp']),
                textcoords="offset points", xytext=(10, 5), fontsize=9)
ax3.set_xlabel('Spatial Dimension n', fontsize=12)
ax3.set_ylabel('Force Exponent (1-n)', fontsize=12)
ax3.set_title('Gravitational Force Law F ∝ r^(1-n)', fontsize=12)
ax3.grid(True, alpha=0.3)
ax3.set_xticks(dims)

# Panel 4: Summary table
ax4 = axes[1, 1]
ax4.axis('off')
table_data = []
headers = ['Dim', 'Force', 'Potential', 'Stable', 'Closed', 'Status']
for d in data:
    fe = d['force_exp']
    if d['n'] == 2:
        pot = "ln(r)"
    elif d['n'] == 1:
        pot = "r"
    else:
        pot = f"r^{2 - d['n']}"
    table_data.append([
        str(d['n']),
        f"r^{fe}",
        pot,
        '✓' if d['stable'] else '✗',
        '✓' if d['closed'] else '✗',
        '★ GOLDILOCKS' if d['goldilocks'] else 'Non-closing' if d['stable'] else 'Unstable'
    ])

table = ax4.table(cellText=table_data, colLabels=headers,
                   loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1.0, 1.5)

# Color the Goldilocks row
for j in range(len(headers)):
    table[3, j].set_facecolor('#FFF9C4')  # dim=3 is row index 3 (0-indexed header)
    table[2, j].set_facecolor('#E3F2FD')  # dim=2 (our pathological case)

ax4.set_title('Dimensional Classification of Gravitational Orbits', fontsize=12, pad=20)

plt.suptitle('The Goldilocks Dimension: Why 3D is Special for Gravity',
            fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('dimensional_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved dimensional_hierarchy.png")
