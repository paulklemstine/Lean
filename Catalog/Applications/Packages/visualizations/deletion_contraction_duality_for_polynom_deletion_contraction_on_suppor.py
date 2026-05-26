#!/usr/bin/env python3
"""
Visualization: Deletion–Contraction on Support Polytopes

Visualizes how deletion and contraction operations transform the Newton polytope
of an M-convex support set, showing the geometric meaning of these operations
as face restrictions and projections.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import numpy as np
from itertools import combinations


def indicator_vector(n, subset):
    v = [0] * n
    for i in subset:
        v[i] = 1
    return tuple(v)


def support_delete(S, i):
    return [m for m in S if m[i] == 0]


def support_contract(S, i):
    if not S:
        return []
    min_val = min(m[i] for m in S)
    return [tuple(m[j] - (min_val if j == i else 0) for j in range(len(m)))
            for m in S if m[i] == min_val]


def convex_hull_2d(points):
    """Simple 2D convex hull (gift wrapping)."""
    if len(points) <= 2:
        return list(range(len(points)))
    
    pts = np.array(points)
    n = len(pts)
    
    # Start from leftmost point
    start = np.argmin(pts[:, 0])
    hull = []
    current = start
    
    while True:
        hull.append(current)
        candidate = 0
        for i in range(n):
            if i == current:
                continue
            cross = np.cross(pts[candidate] - pts[current], pts[i] - pts[current])
            if candidate == current or cross > 0 or (cross == 0 and
                np.linalg.norm(pts[i] - pts[current]) > np.linalg.norm(pts[candidate] - pts[current])):
                candidate = i
        current = candidate
        if current == start:
            break
    
    return hull


fig = plt.figure(figsize=(18, 12))
fig.suptitle('Deletion–Contraction on M-Convex Support Sets', fontsize=16, fontweight='bold')

# === Panel 1: Original support (degree-3 simplex in 3 variables) ===
ax1 = fig.add_subplot(231, projection='3d')

d = 3
S_original = []
for a in range(d + 1):
    for b in range(d + 1 - a):
        c = d - a - b
        S_original.append((a, b, c))

pts = np.array(S_original)
ax1.scatter(pts[:, 0], pts[:, 1], pts[:, 2], c='royalblue', s=80, zorder=5, edgecolors='black', linewidth=0.5)

for p in S_original:
    ax1.text(p[0]+0.08, p[1]+0.08, p[2]+0.08, f'{p}', fontsize=5, alpha=0.7)

ax1.set_xlabel('x', fontsize=10)
ax1.set_ylabel('y', fontsize=10)
ax1.set_zlabel('z', fontsize=10)
ax1.set_title(f'Original S (degree-{d} simplex)\n|S| = {len(S_original)}', fontsize=11)

# === Panel 2: Deletion at x (coord 0) ===
ax2 = fig.add_subplot(232, projection='3d')

S_del_x = support_delete(S_original, 0)
pts_del = np.array(S_del_x) if S_del_x else np.empty((0, 3))

# Show original faded
ax2.scatter(pts[:, 0], pts[:, 1], pts[:, 2], c='lightgray', s=30, alpha=0.3, zorder=1)

if len(pts_del) > 0:
    ax2.scatter(pts_del[:, 0], pts_del[:, 1], pts_del[:, 2], c='crimson', s=80, zorder=5,
                edgecolors='black', linewidth=0.5)
    for p in S_del_x:
        ax2.text(p[0]+0.08, p[1]+0.08, p[2]+0.08, f'{p}', fontsize=5, alpha=0.7)

ax2.set_xlabel('x', fontsize=10)
ax2.set_ylabel('y', fontsize=10)
ax2.set_zlabel('z', fontsize=10)
ax2.set_title(f'Deletion D_x(S)\nx=0 face, |D| = {len(S_del_x)}', fontsize=11)

# === Panel 3: Contraction at x (coord 0) ===
ax3 = fig.add_subplot(233, projection='3d')

S_con_x = support_contract(S_original, 0)
pts_con = np.array(S_con_x) if S_con_x else np.empty((0, 3))

ax3.scatter(pts[:, 0], pts[:, 1], pts[:, 2], c='lightgray', s=30, alpha=0.3, zorder=1)

if len(pts_con) > 0:
    ax3.scatter(pts_con[:, 0], pts_con[:, 1], pts_con[:, 2], c='forestgreen', s=80, zorder=5,
                edgecolors='black', linewidth=0.5)
    for p in S_con_x:
        ax3.text(p[0]+0.08, p[1]+0.08, p[2]+0.08, f'{p}', fontsize=5, alpha=0.7)

ax3.set_xlabel('x', fontsize=10)
ax3.set_ylabel('y', fontsize=10)
ax3.set_zlabel('z', fontsize=10)
ax3.set_title(f'Contraction C_x(S)\n|C| = {len(S_con_x)}', fontsize=11)

# === Panel 4: Uniform matroid U(2,4) support ===
ax4 = fig.add_subplot(234)

n_mat = 4
k_mat = 2
bases = list(combinations(range(n_mat), k_mat))
S_matroid = [indicator_vector(n_mat, B) for B in bases]

# Project to 2D using first two principal coordinates
pts_mat = np.array(S_matroid, dtype=float)
# Simple 2D projection: use coordinates 0,1 vs 2,3
proj_x = pts_mat[:, 0] + 0.5 * pts_mat[:, 1]
proj_y = pts_mat[:, 2] + 0.5 * pts_mat[:, 3]

ax4.scatter(proj_x, proj_y, c='royalblue', s=100, zorder=5, edgecolors='black', linewidth=0.5)
for idx, p in enumerate(S_matroid):
    ax4.annotate(str(p), (proj_x[idx], proj_y[idx]),
                 textcoords="offset points", xytext=(5, 5), fontsize=6)

# Draw convex hull
if len(proj_x) >= 3:
    hull_pts = np.column_stack([proj_x, proj_y])
    hull_idx = convex_hull_2d(hull_pts.tolist())
    hull_idx.append(hull_idx[0])
    ax4.plot(proj_x[hull_idx], proj_y[hull_idx], 'b-', alpha=0.3, linewidth=1)
    ax4.fill(proj_x[hull_idx], proj_y[hull_idx], alpha=0.1, color='blue')

ax4.set_title(f'U(2,4) support\n|S| = {len(S_matroid)}', fontsize=11)
ax4.set_xlabel('Projection axis 1', fontsize=9)
ax4.set_ylabel('Projection axis 2', fontsize=9)

# === Panel 5: Deletion of coord 0 from U(2,4) ===
ax5 = fig.add_subplot(235)

S_mat_del = support_delete(S_matroid, 0)
pts_mat_del = np.array(S_mat_del, dtype=float) if S_mat_del else np.empty((0, n_mat))

ax5.scatter(proj_x, proj_y, c='lightgray', s=50, alpha=0.3, zorder=1)

if len(pts_mat_del) > 0:
    proj_x_del = pts_mat_del[:, 0] + 0.5 * pts_mat_del[:, 1]
    proj_y_del = pts_mat_del[:, 2] + 0.5 * pts_mat_del[:, 3]
    ax5.scatter(proj_x_del, proj_y_del, c='crimson', s=100, zorder=5,
                edgecolors='black', linewidth=0.5)
    for idx, p in enumerate(S_mat_del):
        ax5.annotate(str(p), (proj_x_del[idx], proj_y_del[idx]),
                     textcoords="offset points", xytext=(5, 5), fontsize=6)

ax5.set_title(f'U(2,4) deletion at coord 0\n|D| = {len(S_mat_del)}', fontsize=11)
ax5.set_xlabel('Projection axis 1', fontsize=9)
ax5.set_ylabel('Projection axis 2', fontsize=9)

# === Panel 6: Contraction of coord 0 from U(2,4) ===
ax6 = fig.add_subplot(236)

S_mat_con = support_contract(S_matroid, 0)
pts_mat_con = np.array(S_mat_con, dtype=float) if S_mat_con else np.empty((0, n_mat))

ax6.scatter(proj_x, proj_y, c='lightgray', s=50, alpha=0.3, zorder=1)

if len(pts_mat_con) > 0:
    proj_x_con = pts_mat_con[:, 0] + 0.5 * pts_mat_con[:, 1]
    proj_y_con = pts_mat_con[:, 2] + 0.5 * pts_mat_con[:, 3]
    ax6.scatter(proj_x_con, proj_y_con, c='forestgreen', s=100, zorder=5,
                edgecolors='black', linewidth=0.5)
    for idx, p in enumerate(S_mat_con):
        ax6.annotate(str(p), (proj_x_con[idx], proj_y_con[idx]),
                     textcoords="offset points", xytext=(5, 5), fontsize=6)

ax6.set_title(f'U(2,4) contraction at coord 0\n|C| = {len(S_mat_con)}', fontsize=11)
ax6.set_xlabel('Projection axis 1', fontsize=9)
ax6.set_ylabel('Projection axis 2', fontsize=9)

plt.tight_layout()
plt.savefig('viz_deletion_contraction.png', dpi=150, bbox_inches='tight')
print("Saved viz_deletion_contraction.png")
