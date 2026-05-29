#!/usr/bin/env python3
"""
Visualization 1: Fixed-Point Variety Dimension Heatmap
=====================================================
Visualizes the fixed-point variety dimension (log₂ of fixed point count)
for all 256 ECA rules arranged in a 16×16 grid. The color intensity
reveals the algebraic complexity landscape of cellular automata.

Rules are arranged with rule number = row * 16 + column.
Hot colors = more fixed points (higher dimension).
Cold colors = fewer fixed points.
Black = no fixed points.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import product
from math import log2


def eca_local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def transfer_matrix(r):
    T = np.zeros((4, 4), dtype=int)
    for row in range(4):
        si = (row >> 1) & 1
        sj = row & 1
        for sk in range(2):
            col = 2 * sj + sk
            if eca_local_rule(r, si, sj, sk) == sj:
                T[row, col] = 1
    return T


def count_fixed_points_transfer(r, n):
    T = transfer_matrix(r)
    Tn = np.linalg.matrix_power(T, n)
    return int(round(np.trace(Tn)))


n = 12
dim_grid = np.zeros((16, 16))

for r in range(256):
    row, col = divmod(r, 16)
    fp = count_fixed_points_transfer(r, n)
    dim_grid[row, col] = log2(fp) if fp > 0 else -1

fig, ax = plt.subplots(figsize=(10, 10))

# Use a diverging colormap where -1 (no fixed points) is black
cmap = plt.cm.inferno.copy()
cmap.set_under('black')

im = ax.imshow(dim_grid, cmap=cmap, vmin=0, vmax=n, interpolation='nearest')
ax.set_xlabel('Rule number mod 16', fontsize=12)
ax.set_ylabel('Rule number ÷ 16', fontsize=12)
ax.set_title(f'Fixed-Point Variety Dimension for All 256 ECA Rules (n={n} cells)',
             fontsize=14, fontweight='bold')

# Add rule numbers to cells
for r in range(256):
    row, col = divmod(r, 16)
    val = dim_grid[row, col]
    color = 'white' if val < n/2 else 'black'
    if val < 0:
        color = 'gray'
    ax.text(col, row, str(r), ha='center', va='center', fontsize=5.5, color=color)

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Variety dimension (log₂ |Fix|)', fontsize=11)

# Mark special rules
special = {0: 'R0', 90: 'R90', 110: 'R110', 204: 'R204', 150: 'R150', 30: 'R30'}
for r, label in special.items():
    row, col = divmod(r, 16)
    ax.plot(col, row, 'o', markeredgecolor='lime', markerfacecolor='none', 
            markersize=14, markeredgewidth=2)

plt.tight_layout()
plt.savefig('viz_dimension_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_dimension_heatmap.png")
