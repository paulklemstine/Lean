#!/usr/bin/env python3
"""
Demo 1: 2D Stereographic Projection — The Classical Picture
============================================================

Visualizes stereographic projection from S¹ to ℝ and from S² to ℝ².
Shows how points on the sphere map to the plane, and how circles map to circles.

Oracle Λ's first experiment.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

# ─── Core Functions ───

def stereo_project_2d(x, y, z):
    """Stereographic projection from S² to ℝ² (from north pole (0,0,1))."""
    denom = 1 - z
    mask = np.abs(denom) > 1e-10
    u = np.where(mask, x / denom, np.nan)
    v = np.where(mask, y / denom, np.nan)
    return u, v

def inv_stereo_2d(u, v):
    """Inverse stereographic projection from ℝ² to S²."""
    D = 1 + u**2 + v**2
    x = 2 * u / D
    y = 2 * v / D
    z = (D - 2) / D
    return x, y, z

def stereo_project_1d(x, y):
    """Stereographic projection from S¹ to ℝ (from north pole (0,1))."""
    return x / (1 - y)

def inv_stereo_1d(t):
    """Inverse stereographic projection from ℝ to S¹."""
    D = 1 + t**2
    return 2*t/D, (1 - t**2)/D

# ─── Figure 1: The 1D Case (S¹ → ℝ) ───

fig = plt.figure(figsize=(18, 14))
gs = gridspec.GridSpec(2, 2, hspace=0.3, wspace=0.3)

ax1 = fig.add_subplot(gs[0, 0])
theta = np.linspace(-np.pi + 0.1, np.pi - 0.1, 200)
circle_x = np.cos(theta)
circle_y = np.sin(theta)
ax1.plot(circle_x, circle_y, 'b-', linewidth=2, label='S¹')
ax1.plot(0, 1, 'r*', markersize=15, label='North pole (projection center)')

# Project some points
sample_theta = np.linspace(-2.5, 2.5, 15)
for th in sample_theta:
    px, py = np.cos(th), np.sin(th)
    t = stereo_project_1d(px, py)
    if abs(t) < 4:
        ax1.plot([0, px], [1, py], 'g-', alpha=0.3, linewidth=0.5)
        ax1.plot([px], [py], 'ko', markersize=4)
        # Extended line to the real line (y = -1.3 for visualization)
        ax1.plot([t], [-1.3], 'r^', markersize=6)
        ax1.plot([px, t], [py, -1.3], 'g--', alpha=0.3, linewidth=0.5)

ax1.axhline(y=-1.3, color='red', linewidth=2, alpha=0.5, label='ℝ (target line)')
ax1.set_xlim(-4.5, 4.5)
ax1.set_ylim(-2, 1.5)
ax1.set_aspect('equal')
ax1.set_title('Stereographic Projection: S¹ → ℝ', fontsize=14, fontweight='bold')
ax1.legend(loc='upper right', fontsize=9)
ax1.grid(True, alpha=0.3)

# ─── Figure 2: Inverse Stereo Maps (ℝ → S¹) ───

ax2 = fig.add_subplot(gs[0, 1])
t_vals = np.linspace(-5, 5, 500)
x_vals, y_vals = inv_stereo_1d(t_vals)

# Color by parameter t
colors = plt.cm.viridis(np.linspace(0, 1, len(t_vals)))
for i in range(len(t_vals)-1):
    ax2.plot(x_vals[i:i+2], y_vals[i:i+2], color=colors[i], linewidth=3)

ax2.plot(0, 1, 'r*', markersize=15, zorder=5)
ax2.annotate('North pole\n(t → ±∞)', xy=(0, 1), xytext=(0.5, 1.3),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='red'))

# Mark special points
special_t = [0, 1, -1, 2, -2]
special_labels = ['t=0\n(0,1)', 't=1\n(1,0)', 't=-1\n(-1,0)', 't=2', 't=-2']
for t, label in zip(special_t, special_labels):
    sx, sy = inv_stereo_1d(t)
    ax2.plot(sx, sy, 'ko', markersize=8, zorder=5)
    ax2.annotate(label, xy=(sx, sy), xytext=(sx+0.15, sy-0.2), fontsize=8)

ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Inverse Stereographic: ℝ → S¹\n(colored by parameter t)', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)

# ─── Figure 3: S² → ℝ² projection of latitude circles ───

ax3 = fig.add_subplot(gs[1, 0])

# Draw circles of latitude on S² and their stereographic images
latitudes = np.linspace(-80, 80, 17) * np.pi / 180
phi = np.linspace(0, 2*np.pi, 200)

cmap = plt.cm.coolwarm
for i, lat in enumerate(latitudes):
    # Circle of latitude on S²
    cx = np.cos(lat) * np.cos(phi)
    cy = np.cos(lat) * np.sin(phi)
    cz = np.sin(lat) * np.ones_like(phi)

    # Project
    u, v = stereo_project_2d(cx, cy, cz)
    color = cmap(i / len(latitudes))
    ax3.plot(u, v, color=color, linewidth=1.5, alpha=0.8)

# Mark origin
ax3.plot(0, 0, 'k+', markersize=15, markeredgewidth=2)
ax3.annotate('South pole\nimage', xy=(0, 0), xytext=(0.5, -0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='black'))

ax3.set_xlim(-6, 6)
ax3.set_ylim(-6, 6)
ax3.set_aspect('equal')
ax3.set_title('S² → ℝ²: Latitude Circles\n(blue=south, red=north)', fontsize=14, fontweight='bold')
ax3.grid(True, alpha=0.3)

# ─── Figure 4: Conformal Factor Heatmap ───

ax4 = fig.add_subplot(gs[1, 1])

u_grid = np.linspace(-4, 4, 400)
v_grid = np.linspace(-4, 4, 400)
U, V = np.meshgrid(u_grid, v_grid)
D = 1 + U**2 + V**2
conformal_factor = 2 / D

im = ax4.pcolormesh(U, V, conformal_factor, cmap='magma', shading='auto')
plt.colorbar(im, ax=ax4, label='Conformal factor 2/(1+|y|²)')
ax4.contour(U, V, conformal_factor, levels=[0.1, 0.2, 0.5, 0.8, 1.0, 1.5],
           colors='white', linewidths=0.5, alpha=0.5)
ax4.set_xlabel('u')
ax4.set_ylabel('v')
ax4.set_aspect('equal')
ax4.set_title('Conformal Distortion Map\nHow stereographic projection stretches space',
             fontsize=14, fontweight='bold')

fig.suptitle('N-Dimensional Stereographic Projection: Classical Foundations',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo1_2d_stereographic.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 1 saved: demo1_2d_stereographic.png")
