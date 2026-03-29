#!/usr/bin/env python3
"""
Demo 4: 3D Sphere Visualization of Integer-Pole Projections

Visualizes:
1. The stereographic projection on a 3D sphere
2. Integer-pole coordinate grids on the sphere
3. The pole-swap as rotation
4. Dual universe comparison in 3D

Run: python3 demo_3d_sphere.py
Output: sphere_3d.png, coordinate_grids.png
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

# --- Core Functions ---

def inv_stereo_2d(u, v):
    """Inverse stereographic projection: ℝ² → S² (from South Pole)."""
    r2 = u**2 + v**2
    X = 2 * u / (1 + r2)
    Y = 2 * v / (1 + r2)
    Z = (r2 - 1) / (1 + r2)
    return X, Y, Z

def stereo_forward_2d(X, Y, Z):
    """Forward stereographic projection: S² → ℝ² (from North Pole (0,0,1))."""
    u = X / (1 - Z)
    v = Y / (1 - Z)
    return u, v

def T_nm_complex(z, n, m):
    """Integer-pole chart map for complex z."""
    return (n * z + m) / (z + 1)

# --- Figure 1: 3D Sphere with Projections ---

fig = plt.figure(figsize=(18, 14))

# Panel 1: Basic stereographic projection
ax1 = fig.add_subplot(2, 2, 1, projection='3d')

# Draw sphere
u_s = np.linspace(0, 2*np.pi, 50)
v_s = np.linspace(0, np.pi, 30)
X_s = np.outer(np.cos(u_s), np.sin(v_s))
Y_s = np.outer(np.sin(u_s), np.sin(v_s))
Z_s = np.outer(np.ones_like(u_s), np.cos(v_s))
ax1.plot_surface(X_s, Y_s, Z_s, alpha=0.1, color='cyan')

# Mark poles
ax1.scatter([0], [0], [1], color='red', s=100, marker='^', label='North (∞)', zorder=10)
ax1.scatter([0], [0], [-1], color='blue', s=100, marker='s', label='South (0)', zorder=10)

# Project integer points from the real line
for t in range(-5, 6):
    X, Y, Z = inv_stereo_2d(t, 0)
    ax1.scatter([X], [Y], [Z], color='green', s=40, zorder=5)
    # Draw projection line from North Pole
    ax1.plot([0, X, t], [0, Y, 0], [1, Z, -1.5], 'g--', alpha=0.3, linewidth=0.8)
    ax1.scatter([t], [0], [-1.5], color='green', s=20, marker='s', zorder=5)

ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_zlim(-1.5, 1.5)
ax1.set_xlabel('X')
ax1.set_ylabel('Y')
ax1.set_zlabel('Z')
ax1.set_title('Stereographic Projection\nIntegers on the Real Line → S²', fontsize=11, fontweight='bold')
ax1.legend(fontsize=8)

# Panel 2: Coordinate grid on sphere
ax2 = fig.add_subplot(2, 2, 2, projection='3d')
ax2.plot_surface(X_s, Y_s, Z_s, alpha=0.08, color='cyan')

# Draw coordinate lines (u = const and v = const)
for u_val in np.linspace(-3, 3, 13):
    v_range = np.linspace(-3, 3, 100)
    X_line, Y_line, Z_line = inv_stereo_2d(u_val * np.ones_like(v_range), v_range)
    ax2.plot(X_line, Y_line, Z_line, 'b-', alpha=0.4, linewidth=0.8)

for v_val in np.linspace(-3, 3, 13):
    u_range = np.linspace(-3, 3, 100)
    X_line, Y_line, Z_line = inv_stereo_2d(u_range, v_val * np.ones_like(u_range))
    ax2.plot(X_line, Y_line, Z_line, 'r-', alpha=0.4, linewidth=0.8)

ax2.scatter([0], [0], [1], color='red', s=100, marker='^', zorder=10)
ax2.scatter([0], [0], [-1], color='blue', s=100, marker='s', zorder=10)
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_zlim(-1.5, 1.5)
ax2.set_xlabel('X')
ax2.set_ylabel('Y')
ax2.set_zlabel('Z')
ax2.set_title('Coordinate Grid on S²\n(lines u=const, v=const)', fontsize=11, fontweight='bold')

# Panel 3: Same sphere, different charts
ax3 = fig.add_subplot(2, 2, 3, projection='3d')
ax3.plot_surface(X_s, Y_s, Z_s, alpha=0.08, color='cyan')

# Chart (3, 7): integer crystal lattice
# w_k = (3k + 7)/(k + 1)
for k in range(-15, 16):
    if k == -1:
        continue
    w_k = (3 * k + 7) / (k + 1)
    # Convert back to standard z
    z = (w_k - 7) / (3 - w_k) if abs(3 - w_k) > 0.01 else 100
    if abs(z) < 20:
        X, Y, Z = inv_stereo_2d(z, 0)
        size = max(10, 50 - abs(k) * 2)
        ax3.scatter([X], [Y], [Z], color=plt.cm.plasma(abs(k)/15),
                   s=size, zorder=5, alpha=0.8)

ax3.scatter([0], [0], [1], color='red', s=100, marker='^', label='N=3', zorder=10)
ax3.scatter([0], [0], [-1], color='blue', s=100, marker='s', label='S=7', zorder=10)
ax3.set_xlim(-1.5, 1.5)
ax3.set_ylim(-1.5, 1.5)
ax3.set_zlim(-1.5, 1.5)
ax3.set_title('Crystal Lattice (3,7)\non S²', fontsize=11, fontweight='bold')
ax3.legend(fontsize=8)

# Panel 4: Dual comparison
ax4 = fig.add_subplot(2, 2, 4, projection='3d')
ax4.plot_surface(X_s, Y_s, Z_s, alpha=0.08, color='cyan')

# Compare (3,7) and (7,3) crystal lattices
for k in range(-10, 11):
    if k == -1:
        continue
    # Chart (3,7)
    w1 = (3 * k + 7) / (k + 1)
    z1 = (w1 - 7) / (3 - w1) if abs(3 - w1) > 0.01 else 100
    if abs(z1) < 20:
        X1, Y1, Z1 = inv_stereo_2d(z1, 0)
        ax4.scatter([X1], [Y1], [Z1], color='red', s=30, alpha=0.6, zorder=5)

    # Chart (7,3)
    w2 = (7 * k + 3) / (k + 1)
    z2 = (w2 - 3) / (7 - w2) if abs(7 - w2) > 0.01 else 100
    if abs(z2) < 20:
        X2, Y2, Z2 = inv_stereo_2d(z2, 0)
        ax4.scatter([X2], [Y2], [Z2], color='blue', s=30, alpha=0.6, zorder=5)

ax4.plot([], [], [], 'ro', markersize=5, label='Universe(3,7)')
ax4.plot([], [], [], 'bo', markersize=5, label='Universe(7,3) [dual]')
ax4.set_xlim(-1.5, 1.5)
ax4.set_ylim(-1.5, 1.5)
ax4.set_zlim(-1.5, 1.5)
ax4.set_title('Dual Universes on S²', fontsize=11, fontweight='bold')
ax4.legend(fontsize=8)

plt.suptitle('3D Sphere: Integer-Pole Stereographic Projections',
             fontsize=16, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/demos/sphere_3d.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved sphere_3d.png")
