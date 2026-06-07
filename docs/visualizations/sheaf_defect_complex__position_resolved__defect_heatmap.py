#!/usr/bin/env python3
"""
Visualization: Defect Heatmap for Database Consistency

Shows the spatial distribution of consistency defects across a database grid.
Hot spots (high defect) indicate positions where databases strongly disagree.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def disagree(db1, db2, r, c):
    v1, v2 = db1[r][c], db2[r][c]
    if v1 is not None and v2 is not None and v1 != v2:
        return 1
    return 0


def position_defect(dbs, r, c):
    n = len(dbs)
    total = 0
    for i in range(n):
        for j in range(n):
            total += disagree(dbs[i], dbs[j], r, c)
    return total


def create_partial_db(n_rows, n_cols, values, missing_rate):
    db = []
    for _ in range(n_rows):
        row = []
        for _ in range(n_cols):
            if random.random() < missing_rate:
                row.append(None)
            else:
                row.append(random.choice(list(values)))
        db.append(row)
    return db


random.seed(42)
n_rows, n_cols = 10, 10
n_dbs = 6

dbs = [create_partial_db(n_rows, n_cols, range(5), 0.3) for _ in range(n_dbs)]

# Compute defect matrix
defect_matrix = np.zeros((n_rows, n_cols))
for r in range(n_rows):
    for c in range(n_cols):
        defect_matrix[r][c] = position_defect(dbs, r, c)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Heatmap of position defects
im1 = axes[0].imshow(defect_matrix, cmap='YlOrRd', interpolation='nearest')
axes[0].set_title('Position Defect Heatmap', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Column')
axes[0].set_ylabel('Row')
plt.colorbar(im1, ax=axes[0], label='Defect Count')

# Binary hot spots (threshold = median)
threshold = np.median(defect_matrix)
hot_spots = (defect_matrix > threshold).astype(float)
im2 = axes[1].imshow(hot_spots, cmap='RdGy_r', interpolation='nearest',
                      vmin=0, vmax=1)
axes[1].set_title(f'Hot Spots (defect > {threshold:.0f})', fontsize=14,
                  fontweight='bold')
axes[1].set_xlabel('Column')
axes[1].set_ylabel('Row')
plt.colorbar(im2, ax=axes[1], label='Hot Spot')

# Defect distribution histogram
defect_values = defect_matrix.flatten()
axes[2].hist(defect_values, bins=range(int(max(defect_values)) + 2),
             color='steelblue', edgecolor='white', alpha=0.8)
axes[2].axvline(x=threshold, color='red', linestyle='--', linewidth=2,
                label=f'Threshold = {threshold:.0f}')
axes[2].set_title('Defect Distribution', fontsize=14, fontweight='bold')
axes[2].set_xlabel('Position Defect')
axes[2].set_ylabel('Count')
axes[2].legend()

total = int(np.sum(defect_matrix))
laplacian = int(np.sum(defect_matrix ** 2))
fig.suptitle(f'Sheaf Defect Complex Analysis ({n_dbs} databases, {n_rows}×{n_cols} grid)\n'
             f'Total Defect = {total}, Laplacian = {laplacian}, '
             f'Laplacian/Total = {laplacian/total:.2f}',
             fontsize=13, y=1.02)

plt.tight_layout()
plt.savefig('defect_heatmap.png', dpi=150, bbox_inches='tight')
print(f"Saved defect_heatmap.png")
print(f"Total defect: {total}")
print(f"Defect Laplacian: {laplacian}")
print(f"Ratio (Laplacian/Total): {laplacian/total:.2f}")
