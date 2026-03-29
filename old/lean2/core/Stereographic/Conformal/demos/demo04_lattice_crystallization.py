#!/usr/bin/env python3
"""
Demo 04: Lattice Crystallization on S² — From Perfect Grid to Spherical Quasicrystal
=====================================================================================
Maps the integer lattice Z² through inverse stereographic projection to create a 
"quasicrystal" on the sphere. Near the south pole, the lattice is nearly regular.
Far away, it compresses toward the north pole.

Oracle Ψ's Discovery: The transition zone at |y| ~ 1 (the equatorial belt)
shows the most interesting deformation — where cubic symmetry meets spherical symmetry.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D

def inverse_stereo(y1, y2):
    D = 1.0 + y1**2 + y2**2
    return 2*y1/D, 2*y2/D, (D-2)/D

def conformal_factor(y1, y2):
    return 2.0 / (1.0 + y1**2 + y2**2)

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Lattice Crystallization: Z² Lattice → Spherical Quasicrystal",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Z² lattice in the plane, colored by conformal distortion ---
ax1 = fig.add_subplot(2, 3, 1)
R_max = 8
pts_y1, pts_y2 = [], []
for i in range(-R_max, R_max+1):
    for j in range(-R_max, R_max+1):
        pts_y1.append(i * 0.5)
        pts_y2.append(j * 0.5)

pts_y1 = np.array(pts_y1)
pts_y2 = np.array(pts_y2)
lam = conformal_factor(pts_y1, pts_y2)

sc = ax1.scatter(pts_y1, pts_y2, c=lam, cmap='plasma', s=8, alpha=0.8)
plt.colorbar(sc, ax=ax1, label='Conformal factor λ')
ax1.set_title('Z² Lattice in R²\n(colored by conformal factor)', fontsize=12)
ax1.set_xlabel('y₁')
ax1.set_ylabel('y₂')
ax1.set_aspect('equal')

# Draw equator circle
theta = np.linspace(0, 2*np.pi, 100)
ax1.plot(np.cos(theta), np.sin(theta), 'r--', linewidth=1.5, label='|y|=1 (equator)')
ax1.legend(fontsize=9)

# --- Panel 2: Projected onto S² (3D view) ---
ax2 = fig.add_subplot(2, 3, 2, projection='3d')
x1, x2, x3 = inverse_stereo(pts_y1, pts_y2)
sc2 = ax2.scatter(x1, x2, x3, c=lam, cmap='plasma', s=5, alpha=0.7)
# Sphere wireframe
u_s = np.linspace(0, 2*np.pi, 40)
v_s = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u_s), np.sin(v_s))
ys = np.outer(np.sin(u_s), np.sin(v_s))
zs = np.outer(np.ones_like(u_s), np.cos(v_s))
ax2.plot_wireframe(xs, ys, zs, color='lightblue', alpha=0.08, linewidth=0.3)
ax2.set_title('Projected onto S²\n(Quasicrystal)', fontsize=12)
ax2.set_box_aspect([1, 1, 1])
ax2.view_init(elev=15, azim=-50)

# --- Panel 3: Nearest-neighbor distance vs latitude ---
ax3 = fig.add_subplot(2, 3, 3)

# For each lattice point on sphere, find nearest neighbor distance
from scipy.spatial import cKDTree
sphere_pts = np.column_stack([x1, x2, x3])
tree = cKDTree(sphere_pts)
dists, _ = tree.query(sphere_pts, k=2)  # k=2 because nearest is self
nn_dists = dists[:, 1]
latitudes = np.arcsin(np.clip(x3, -1, 1)) * 180 / np.pi

ax3.scatter(latitudes, nn_dists, c=lam, cmap='plasma', s=3, alpha=0.5)
ax3.set_xlabel('Latitude (degrees)', fontsize=12)
ax3.set_ylabel('Nearest-neighbor distance on S²', fontsize=12)
ax3.set_title('Crystallographic Order Parameter\nvs Latitude', fontsize=12)
ax3.axvline(0, color='red', linestyle='--', alpha=0.5, label='Equator')
ax3.legend()
ax3.grid(True, alpha=0.3)

# --- Panel 4: Grid lines on the sphere ---
ax4 = fig.add_subplot(2, 3, 4, projection='3d')
ax4.plot_wireframe(xs, ys, zs, color='lightblue', alpha=0.08, linewidth=0.3)

# Horizontal grid lines (constant y₂ = k)
for k in np.arange(-4, 4.5, 0.5):
    y1_line = np.linspace(-6, 6, 500)
    y2_line = np.full_like(y1_line, k)
    x1l, x2l, x3l = inverse_stereo(y1_line, y2_line)
    color_val = conformal_factor(0, k)
    ax4.plot(x1l, x2l, x3l, color=cm.coolwarm(color_val/2), linewidth=0.6, alpha=0.7)

# Vertical grid lines (constant y₁ = k)
for k in np.arange(-4, 4.5, 0.5):
    y2_line = np.linspace(-6, 6, 500)
    y1_line = np.full_like(y2_line, k)
    x1l, x2l, x3l = inverse_stereo(y1_line, y2_line)
    color_val = conformal_factor(k, 0)
    ax4.plot(x1l, x2l, x3l, color=cm.coolwarm(color_val/2), linewidth=0.6, alpha=0.7)

ax4.set_title('R² Grid Lines on S²\n(Straight lines → circles)', fontsize=12)
ax4.set_box_aspect([1, 1, 1])
ax4.view_init(elev=20, azim=-60)

# --- Panel 5: Hexagonal lattice → S² ---
ax5 = fig.add_subplot(2, 3, 5, projection='3d')
ax5.plot_wireframe(xs, ys, zs, color='lightblue', alpha=0.08, linewidth=0.3)

hex_y1, hex_y2 = [], []
for i in range(-10, 11):
    for j in range(-10, 11):
        hx = i + 0.5 * j
        hy = j * np.sqrt(3) / 2
        if hx**2 + hy**2 < 25:
            hex_y1.append(hx * 0.4)
            hex_y2.append(hy * 0.4)

hex_y1 = np.array(hex_y1)
hex_y2 = np.array(hex_y2)
hx1, hx2, hx3 = inverse_stereo(hex_y1, hex_y2)
hlam = conformal_factor(hex_y1, hex_y2)
ax5.scatter(hx1, hx2, hx3, c=hlam, cmap='viridis', s=8, alpha=0.8)
ax5.set_title('Hexagonal Lattice on S²\n(Graphene → Fullerene analogy)', fontsize=12)
ax5.set_box_aspect([1, 1, 1])
ax5.view_init(elev=30, azim=-40)

# --- Panel 6: Voronoi-like analysis ---
ax6 = fig.add_subplot(2, 3, 6)

# Coordination number analysis: how many nearest neighbors at each latitude
bins = np.linspace(-90, 90, 30)
bin_centers = (bins[:-1] + bins[1:]) / 2
mean_dists = []
for i in range(len(bins)-1):
    mask = (latitudes >= bins[i]) & (latitudes < bins[i+1])
    if mask.sum() > 0:
        mean_dists.append(np.mean(nn_dists[mask]))
    else:
        mean_dists.append(np.nan)

ax6.bar(bin_centers, mean_dists, width=5, color=cm.plasma(np.linspace(0.2, 0.8, len(bin_centers))),
        edgecolor='black', linewidth=0.3)
ax6.set_xlabel('Latitude (degrees)', fontsize=12)
ax6.set_ylabel('Mean NN distance', fontsize=12)
ax6.set_title('Average Crystal Spacing\nvs Latitude', fontsize=12)
ax6.axvline(0, color='red', linestyle='--', alpha=0.5, label='Equator')
ax6.legend()
ax6.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('/workspace/request-project/demos/demo04_lattice_crystallization.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 04 saved: demos/demo04_lattice_crystallization.png")
