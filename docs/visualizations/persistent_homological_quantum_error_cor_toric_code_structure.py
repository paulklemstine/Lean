#!/usr/bin/env python3
"""
Visualization: Toric Code Structure

Shows the CW-decomposition of the torus and the corresponding
CSS code structure, illustrating how topology determines code parameters.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import LineCollection

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ============================================================
# Panel 1: Toric Code Grid (L=3)
# ============================================================
ax1 = axes[0]
L = 3

# Draw grid with periodic boundary indicators
for i in range(L + 1):
    # Horizontal lines
    ax1.plot([0, L], [i, i], 'b-', linewidth=1.5, alpha=0.6)
    # Vertical lines
    ax1.plot([i, i], [0, L], 'b-', linewidth=1.5, alpha=0.6)

# Mark vertices
for i in range(L):
    for j in range(L):
        ax1.plot(j + 0.5, i + 0.5, 'ko', markersize=8, zorder=5)

# Mark faces (plaquettes) with shading
for i in range(L):
    for j in range(L):
        rect = plt.Rectangle((j, i), 1, 1, facecolor='lightblue',
                              edgecolor='none', alpha=0.3)
        ax1.add_patch(rect)

# Mark a horizontal winding cycle
cycle_y = 1
for j in range(L):
    ax1.plot([j, j+1], [cycle_y, cycle_y], 'r-', linewidth=3, zorder=4)
ax1.annotate('Winding cycle\n(weight L)', xy=(L/2, cycle_y),
             xytext=(L/2 + 0.5, cycle_y + 1),
             fontsize=9, color='red',
             arrowprops=dict(arrowstyle='->', color='red'))

# Periodic boundary markers
for i in range(L):
    ax1.annotate('', xy=(0, i+0.5), xytext=(-0.3, i+0.5),
                 arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))
    ax1.annotate('', xy=(L, i+0.5), xytext=(L+0.3, i+0.5),
                 arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))

ax1.set_xlim(-0.5, L + 0.5)
ax1.set_ylim(-0.5, L + 1.5)
ax1.set_aspect('equal')
ax1.set_title(f'Toric Code Grid (L={L})\n[[{2*L**2}, 2, {L}]]',
              fontsize=12, fontweight='bold')
ax1.set_xlabel('Periodic boundary conditions', fontsize=10)

legend_elements = [
    mpatches.Patch(color='lightblue', alpha=0.5, label=f'{L}² faces (Z-stabs)'),
    plt.Line2D([0], [0], color='blue', linewidth=2, label=f'2·{L}² edges (qubits)'),
    plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='black',
               markersize=8, label=f'{L}² vertices (X-stabs)'),
    plt.Line2D([0], [0], color='red', linewidth=3, label='Logical operator'),
]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=8)

# ============================================================
# Panel 2: Scaling Laws
# ============================================================
ax2 = axes[1]
L_range = np.arange(2, 15)
n_vals = 2 * L_range**2
d_vals = L_range

# d vs n (actual)
ax2.plot(n_vals, d_vals, 'bo-', markersize=6, linewidth=2, label='d = L')

# d = √(n/2) curve
n_fine = np.linspace(8, 400, 100)
d_curve = np.sqrt(n_fine / 2)
ax2.plot(n_fine, d_curve, 'r--', linewidth=1.5, alpha=0.7, label='d = √(n/2)')

ax2.set_xlabel('Physical Qubits n', fontsize=11)
ax2.set_ylabel('Code Distance d', fontsize=11)
ax2.set_title('Topological Code Scaling\nd = O(√n)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# ============================================================
# Panel 3: Code Parameters Table
# ============================================================
ax3 = axes[2]
ax3.axis('off')

# Create table data
headers = ['L', 'n', 'k', 'd', 'Rate', 'Singleton']
table_data = []
for L in [2, 3, 4, 5, 6, 7, 8]:
    n = 2 * L**2
    k = 2
    d = L
    rate = f'{k/n:.4f}'
    singleton = '✓' if 2*d + k <= n + 2 else '✗'
    table_data.append([str(L), str(n), str(k), str(d), rate, singleton])

table = ax3.table(cellText=table_data, colLabels=headers,
                  loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1.2, 1.5)

# Style header
for j, header in enumerate(headers):
    table[0, j].set_facecolor('#4472C4')
    table[0, j].set_text_props(color='white', fontweight='bold')

# Alternate row colors
for i in range(1, len(table_data) + 1):
    for j in range(len(headers)):
        if i % 2 == 0:
            table[i, j].set_facecolor('#D6E4F0')

ax3.set_title('Toric Code Parameters\n[[2L², 2, L]]', fontsize=12,
              fontweight='bold', pad=20)

plt.tight_layout()
plt.savefig('torus_code.png', dpi=150, bbox_inches='tight')
print("Saved torus_code.png")
