#!/usr/bin/env python3
"""
Demo 2: 3D Stereographic Projection — Sphere to Plane
======================================================

Visualizes how geometric structures on S² project to ℝ².
Shows the circle-preserving (conformal) property in action.

Oracle Λ's second experiment.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

def stereo_project(x, y, z):
    """Stereographic projection from S² to ℝ² (north pole = (0,0,1))."""
    denom = 1 - z
    mask = np.abs(denom) > 1e-10
    u = np.where(mask, x / denom, np.nan)
    v = np.where(mask, y / denom, np.nan)
    return u, v

def inv_stereo(u, v):
    """Inverse: ℝ² → S²."""
    D = 1 + u**2 + v**2
    return 2*u/D, 2*v/D, (D-2)/D

# ─── Figure: Side-by-side sphere and projected plane ───

fig = plt.figure(figsize=(20, 16))
gs = gridspec.GridSpec(2, 2, hspace=0.3, wspace=0.25)

# === Panel 1: Circles on the sphere ===
ax1 = fig.add_subplot(gs[0, 0], projection='3d')

# Draw wireframe sphere
u_sphere = np.linspace(0, 2*np.pi, 50)
v_sphere = np.linspace(0, np.pi, 30)
xs = np.outer(np.cos(u_sphere), np.sin(v_sphere))
ys = np.outer(np.sin(u_sphere), np.sin(v_sphere))
zs = np.outer(np.ones_like(u_sphere), np.cos(v_sphere))
ax1.plot_surface(xs, ys, zs, alpha=0.05, color='lightblue')

# Draw small circles at various positions
phi = np.linspace(0, 2*np.pi, 200)
circle_colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

# Circles on the sphere (small circles at various latitudes/orientations)
circles_on_sphere = []
for i, (lat, lon, r) in enumerate([
    (0.5, 0, 0.3),     # Small circle near equator
    (-0.3, 1.0, 0.4),  # Circle in southern hemisphere
    (0.7, 2.0, 0.2),   # Small circle near north
    (0.0, 3.0, 0.5),   # Circle on equator
    (-0.6, 4.0, 0.35), # Circle in deep south
]):
    # Generate circle on sphere via rotation
    # Start with circle in x-y plane
    cx = r * np.cos(phi)
    cy = r * np.sin(phi)
    cz = np.sqrt(np.maximum(0, 1 - cx**2 - cy**2))  # on upper hemisphere

    # Rotate to position (lat, lon)
    cos_lat, sin_lat = np.cos(lat), np.sin(lat)
    cos_lon, sin_lon = np.cos(lon), np.sin(lon)

    # Simple rotation: tilt around x-axis by lat, then rotate around z-axis by lon
    x1 = cx
    y1 = cy * cos_lat - cz * sin_lat
    z1 = cy * sin_lat + cz * cos_lat

    x2 = x1 * cos_lon - y1 * sin_lon
    y2 = x1 * sin_lon + y1 * cos_lon
    z2 = z1

    # Normalize to sphere
    norm = np.sqrt(x2**2 + y2**2 + z2**2)
    x2 /= norm; y2 /= norm; z2 /= norm

    ax1.plot(x2, y2, z2, color=circle_colors[i], linewidth=2.5, alpha=0.9)
    circles_on_sphere.append((x2, y2, z2))

ax1.plot([0], [0], [1], 'r*', markersize=15, zorder=10)
ax1.set_title('Circles on S²', fontsize=14, fontweight='bold')
ax1.set_xlim(-1.2, 1.2)
ax1.set_ylim(-1.2, 1.2)
ax1.set_zlim(-1.2, 1.2)
ax1.view_init(elev=25, azim=45)

# === Panel 2: Projected circles in ℝ² ===
ax2 = fig.add_subplot(gs[0, 1])

for i, (cx, cy, cz) in enumerate(circles_on_sphere):
    u, v = stereo_project(cx, cy, cz)
    mask = np.isfinite(u) & np.isfinite(v) & (np.abs(u) < 10) & (np.abs(v) < 10)
    ax2.plot(u[mask], v[mask], color=circle_colors[i], linewidth=2.5, alpha=0.9)

ax2.plot(0, 0, 'k+', markersize=15, markeredgewidth=2)
ax2.set_xlim(-5, 5)
ax2.set_ylim(-5, 5)
ax2.set_aspect('equal')
ax2.set_title('Stereographic Images in ℝ²\n(circles → circles!)', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)

# === Panel 3: Grid on sphere → curved grid in plane ===
ax3 = fig.add_subplot(gs[1, 0], projection='3d')
ax3.plot_surface(xs, ys, zs, alpha=0.05, color='lightblue')

# Draw longitude and latitude lines
for lon in np.linspace(0, 2*np.pi, 13)[:-1]:
    lat_range = np.linspace(-np.pi/2 + 0.1, np.pi/2 - 0.1, 100)
    gx = np.cos(lat_range) * np.cos(lon)
    gy = np.cos(lat_range) * np.sin(lon)
    gz = np.sin(lat_range)
    ax3.plot(gx, gy, gz, 'b-', alpha=0.5, linewidth=1)

for lat in np.linspace(-np.pi/3, np.pi/3, 7):
    lon_range = np.linspace(0, 2*np.pi, 100)
    gx = np.cos(lat) * np.cos(lon_range)
    gy = np.cos(lat) * np.sin(lon_range)
    gz = np.sin(lat) * np.ones_like(lon_range)
    ax3.plot(gx, gy, gz, 'r-', alpha=0.5, linewidth=1)

ax3.set_title('Coordinate Grid on S²', fontsize=14, fontweight='bold')
ax3.view_init(elev=25, azim=45)

# === Panel 4: Projected grid ===
ax4 = fig.add_subplot(gs[1, 1])

for lon in np.linspace(0, 2*np.pi, 13)[:-1]:
    lat_range = np.linspace(-np.pi/2 + 0.1, np.pi/2 - 0.15, 100)
    gx = np.cos(lat_range) * np.cos(lon)
    gy = np.cos(lat_range) * np.sin(lon)
    gz = np.sin(lat_range)
    u, v = stereo_project(gx, gy, gz)
    mask = np.isfinite(u) & (np.abs(u) < 8) & (np.abs(v) < 8)
    ax4.plot(u[mask], v[mask], 'b-', alpha=0.5, linewidth=1)

for lat in np.linspace(-np.pi/3, np.pi/3, 7):
    lon_range = np.linspace(0, 2*np.pi, 200)
    gx = np.cos(lat) * np.cos(lon_range)
    gy = np.cos(lat) * np.sin(lon_range)
    gz = np.sin(lat) * np.ones_like(lon_range)
    u, v = stereo_project(gx, gy, gz)
    ax4.plot(u, v, 'r-', alpha=0.5, linewidth=1)

ax4.set_xlim(-8, 8)
ax4.set_ylim(-8, 8)
ax4.set_aspect('equal')
ax4.set_title('Projected Grid in ℝ²\n(angles preserved — conformal!)', fontsize=14, fontweight='bold')
ax4.grid(True, alpha=0.2)

fig.suptitle('Stereographic Projection: Circle-Preserving & Conformal',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo2_3d_sphere_projection.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 2 saved: demo2_3d_sphere_projection.png")
