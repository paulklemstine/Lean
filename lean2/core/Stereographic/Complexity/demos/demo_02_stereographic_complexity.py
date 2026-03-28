#!/usr/bin/env python3
"""
Demo 2: Inverse N-Dimensional Stereographic Projection for Complexity Class Conversion
Visualizes how problems in ℝⁿ map to Sⁿ and how this might affect structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(20, 15))

# ──── Panel 1: 1D Stereographic Projection (ℝ → S¹) ────
ax1 = fig.add_subplot(2, 2, 1)
ax1.set_title('1D: Inverse Stereographic Projection ℝ → S¹\nProblem points compactify onto the circle', 
              fontsize=12, fontweight='bold')

# Draw the circle
theta = np.linspace(0, 2*np.pi, 300)
ax1.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2, alpha=0.5)

# Sample points on the real line and project to circle
t_values = np.linspace(-5, 5, 25)
for t in t_values:
    # Inverse stereographic: t → (2t/(1+t²), (t²-1)/(t²+1))
    x = 2*t / (1 + t**2)
    y = (t**2 - 1) / (t**2 + 1)
    color = plt.cm.plasma(0.5 + 0.5*np.tanh(t/3))
    ax1.plot(x, y, 'o', color=color, markersize=6, alpha=0.8)
    # Draw line from real axis
    ax1.plot([t/5, x], [-1.5, y], '-', color=color, alpha=0.2, linewidth=0.5)

# Draw the real line at bottom
ax1.plot([-1.5, 1.5], [-1.5, -1.5], 'w-', linewidth=2, alpha=0.3)
ax1.text(0, -1.7, 'ℝ (problem space)', ha='center', fontsize=10, color='white')
ax1.text(0, 1.3, 'S¹ (compactified)', ha='center', fontsize=10, color='#f0f0f0')

# North pole (infinity)
ax1.plot(0, 1, '*', color='#ff6b6b', markersize=15, zorder=5)
ax1.text(0.15, 1.1, '∞', fontsize=14, color='#ff6b6b', fontweight='bold')

ax1.set_xlim(-1.8, 1.8)
ax1.set_ylim(-2, 1.5)
ax1.set_aspect('equal')
ax1.set_facecolor('#0a0a1a')
ax1.axis('off')

# ──── Panel 2: 2D Stereographic (ℝ² → S²) ────
ax2 = fig.add_subplot(2, 2, 2, projection='3d')
ax2.set_title('2D: Inverse Stereographic ℝ² → S²\nGrid structure on the sphere', 
              fontsize=12, fontweight='bold')

# Draw sphere wireframe
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax2.plot_surface(xs, ys, zs, alpha=0.1, color='cyan')

# Project a grid from ℝ² to S²
grid = np.linspace(-3, 3, 15)
for xi in grid:
    points_x, points_y, points_z = [], [], []
    for yi in grid:
        r2 = xi**2 + yi**2
        px = 2*xi / (1 + r2)
        py = 2*yi / (1 + r2)
        pz = (r2 - 1) / (r2 + 1)
        points_x.append(px)
        points_y.append(py)
        points_z.append(pz)
    ax2.plot(points_x, points_y, points_z, '-', color='#e056a0', alpha=0.4, linewidth=0.5)

for yi in grid:
    points_x, points_y, points_z = [], [], []
    for xi in grid:
        r2 = xi**2 + yi**2
        px = 2*xi / (1 + r2)
        py = 2*yi / (1 + r2)
        pz = (r2 - 1) / (r2 + 1)
        points_x.append(px)
        points_y.append(py)
        points_z.append(pz)
    ax2.plot(points_x, points_y, points_z, '-', color='#56e0a0', alpha=0.4, linewidth=0.5)

# North pole
ax2.scatter([0], [0], [1], color='#ff6b6b', s=100, zorder=5, marker='*')

ax2.set_facecolor('#0a0a1a')
ax2.xaxis.pane.fill = False
ax2.yaxis.pane.fill = False
ax2.zaxis.pane.fill = False

# ──── Panel 3: Complexity Instance Mapping ────
ax3 = fig.add_subplot(2, 2, 3)
ax3.set_title('SAT Instance Mapping via Stereographic Projection\nBoolean cube maps to spherical constellation', 
              fontsize=12, fontweight='bold')

# 3-SAT with 3 variables: 8 possible assignments
# Encode as points in ℝ³ projected to ℝ² via first two coords
np.random.seed(42)
n_vars = 4
assignments = np.array([[int(b) for b in format(i, f'0{n_vars}b')] for i in range(2**n_vars)])

# Random SAT instance: satisfied assignments
satisfied = [0, 3, 5, 7, 10, 12, 15]  # some random satisfying assignments
unsatisfied = [i for i in range(2**n_vars) if i not in satisfied]

# Map to ℝ² using assignment values, then project to S¹ (use first principal component)
for idx in range(2**n_vars):
    a = assignments[idx]
    # Embed in ℝ² using assignment as coordinates
    x_raw = sum(a[i] * (2**i) for i in range(n_vars)) / (2**n_vars) * 6 - 3
    y_raw = sum((-1)**a[i] for i in range(n_vars))
    
    # Stereographic projection to unit circle
    r2 = x_raw**2 + y_raw**2
    sx = 2*x_raw / (1 + r2)
    sy = (r2 - 1) / (r2 + 1)
    
    if idx in satisfied:
        ax3.plot(sx, sy, 'o', color='#2ecc71', markersize=10, alpha=0.8, zorder=5)
        ax3.text(sx+0.05, sy+0.08, format(idx, f'0{n_vars}b'), fontsize=6, color='#2ecc71')
    else:
        ax3.plot(sx, sy, 'x', color='#e74c3c', markersize=8, alpha=0.5, zorder=5)

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax3.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=1, alpha=0.3)

ax3.legend([plt.Line2D([0],[0],marker='o',color='#2ecc71',ls=''),
            plt.Line2D([0],[0],marker='x',color='#e74c3c',ls='')],
           ['Satisfying', 'Unsatisfying'], loc='lower right', 
           facecolor='#1a1a2e', labelcolor='white')
ax3.set_xlim(-1.5, 1.5)
ax3.set_ylim(-1.5, 1.5)
ax3.set_aspect('equal')
ax3.set_facecolor('#0a0a1a')
ax3.axis('off')

# ──── Panel 4: N-dimensional projection properties ────
ax4 = fig.add_subplot(2, 2, 4)
ax4.set_title('Properties Preserved Under Stereographic Projection\nby Dimension N', 
              fontsize=12, fontweight='bold')

dims = np.arange(1, 11)
# Properties: conformality (always), volume distortion, symmetry group size
conformality = np.ones_like(dims, dtype=float)  # Always preserved
volume_distortion = 1.0 / (1 + 0.3 * dims)  # Increases with dimension
symmetry_group_dim = dims * (dims + 1) / 2  # dim(SO(n+1))
symmetry_group_dim = symmetry_group_dim / symmetry_group_dim.max()
search_space = 2.0**dims / 2.0**dims.max()  # Normalized

ax4.bar(dims - 0.3, conformality, 0.2, color='#2ecc71', alpha=0.8, label='Conformality')
ax4.bar(dims - 0.1, volume_distortion, 0.2, color='#e74c3c', alpha=0.8, label='Volume preservation')
ax4.bar(dims + 0.1, symmetry_group_dim, 0.2, color='#3498db', alpha=0.8, label='Symmetry group (normalized)')
ax4.bar(dims + 0.3, search_space, 0.2, color='#f39c12', alpha=0.8, label='Search space (normalized)')

ax4.set_xlabel('Dimension N', color='white', fontsize=12)
ax4.set_ylabel('Property Value', color='white', fontsize=12)
ax4.legend(facecolor='#1a1a2e', labelcolor='white', fontsize=9)
ax4.set_facecolor('#0a0a1a')
ax4.tick_params(colors='white')
ax4.spines['bottom'].set_color('white')
ax4.spines['left'].set_color('white')
ax4.spines['top'].set_visible(False)
ax4.spines['right'].set_visible(False)

fig.patch.set_facecolor('#0a0a1a')
plt.tight_layout()
plt.savefig('/workspace/request-project/demos/stereographic_complexity.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Saved: demos/stereographic_complexity.png")
