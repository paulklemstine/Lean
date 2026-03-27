"""
Demo 2: 3D Stereographic Projection — S² → ℝ²
================================================

Visualizes the full 2D stereographic projection from the sphere S² to the plane ℝ².
Shows how circles on the sphere map to circles (or lines) on the plane,
and demonstrates the conformal (angle-preserving) property.

Run: python demo2_sphere_projection.py
Outputs: sphere_projection_3d.png
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

# ─── Core Functions ───────────────────────────────────────────────

def stereo_project_3d(x, y, z):
    """σ: S² \ {N} → ℝ². Maps (x,y,z) on unit sphere to (u,v) = (x/(1-z), y/(1-z))."""
    u = x / (1 - z)
    v = y / (1 - z)
    return u, v

def stereo_inv_3d(u, v):
    """σ⁻¹: ℝ² → S² \ {N}. Maps (u,v) to the sphere."""
    denom = u**2 + v**2 + 1
    x = 2*u / denom
    y = 2*v / denom
    z = (u**2 + v**2 - 1) / denom
    return x, y, z

# ─── Verify round-trip on sphere ─────────────────────────────────

print("=" * 60)
print("3D STEREOGRAPHIC ROUND-TRIP VERIFICATION")
print("=" * 60)

# Random points on the sphere (excluding north pole)
np.random.seed(42)
for _ in range(5):
    phi = np.random.uniform(0, 2*np.pi)
    theta = np.random.uniform(0.1*np.pi, np.pi)  # avoid north pole
    x, y, z = np.sin(theta)*np.cos(phi), np.sin(theta)*np.sin(phi), np.cos(theta)
    u, v = stereo_project_3d(x, y, z)
    x2, y2, z2 = stereo_inv_3d(u, v)
    err = np.sqrt((x-x2)**2 + (y-y2)**2 + (z-z2)**2)
    norm = np.sqrt(x2**2 + y2**2 + z2**2)
    print(f"  ({x:.3f}, {y:.3f}, {z:.3f}) → ({u:.3f}, {v:.3f}) → "
          f"({x2:.3f}, {y2:.3f}, {z2:.3f})  [err={err:.2e}, ‖·‖={norm:.6f}]")

# Random points in the plane
print("\nPlane → Sphere → Plane:")
for _ in range(5):
    u, v = np.random.uniform(-5, 5, 2)
    x, y, z = stereo_inv_3d(u, v)
    u2, v2 = stereo_project_3d(x, y, z)
    err = np.sqrt((u-u2)**2 + (v-v2)**2)
    print(f"  ({u:.3f}, {v:.3f}) → ({x:.3f}, {y:.3f}, {z:.3f}) → "
          f"({u2:.3f}, {v2:.3f})  [err={err:.2e}]")

# ─── Visualization ───────────────────────────────────────────────

fig = plt.figure(figsize=(18, 10))

# --- Panel 1: Circles on the sphere and their projections ---
ax1 = fig.add_subplot(121, projection='3d')

# Draw the sphere (wireframe)
phi_s = np.linspace(0, 2*np.pi, 40)
theta_s = np.linspace(0, np.pi, 20)
phi_s, theta_s = np.meshgrid(phi_s, theta_s)
xs = np.sin(theta_s) * np.cos(phi_s)
ys = np.sin(theta_s) * np.sin(phi_s)
zs = np.cos(theta_s)
ax1.plot_wireframe(xs, ys, zs, alpha=0.1, color='blue')

# Draw latitude circles and project them
colors = plt.cm.plasma(np.linspace(0.1, 0.9, 7))
latitudes = [np.radians(lat) for lat in [-60, -30, 0, 30, 45, 60, 75]]

for i, lat in enumerate(latitudes):
    theta_lat = np.pi/2 - lat
    phi_c = np.linspace(0, 2*np.pi, 100)
    xc = np.sin(theta_lat) * np.cos(phi_c)
    yc = np.sin(theta_lat) * np.sin(phi_c)
    zc = np.cos(theta_lat) * np.ones_like(phi_c)

    ax1.plot(xc, yc, zc, color=colors[i], linewidth=2,
             label=f'lat {np.degrees(lat):.0f}°')

# North pole
ax1.scatter([0], [0], [1], color='red', s=100, zorder=5, marker='*')
ax1.text(0, 0, 1.15, 'N (∞)', fontsize=10, ha='center', color='red')

ax1.set_title('Unit Sphere S² with Latitude Circles', fontsize=13, fontweight='bold')
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_zlabel('z')

# --- Panel 2: Projected circles in the plane ---
ax2 = fig.add_subplot(122)

for i, lat in enumerate(latitudes):
    theta_lat = np.pi/2 - lat
    phi_c = np.linspace(0, 2*np.pi, 200)
    xc = np.sin(theta_lat) * np.cos(phi_c)
    yc = np.sin(theta_lat) * np.sin(phi_c)
    zc = np.cos(theta_lat) * np.ones_like(phi_c)

    uc, vc = stereo_project_3d(xc, yc, zc)
    ax2.plot(uc, vc, color=colors[i], linewidth=2,
             label=f'lat {np.degrees(lat):.0f}°')

# Draw some longitude circles too
for lon in np.linspace(0, np.pi, 6, endpoint=False):
    theta_c = np.linspace(0.05*np.pi, 0.95*np.pi, 200)
    xc = np.sin(theta_c) * np.cos(lon)
    yc = np.sin(theta_c) * np.sin(lon)
    zc = np.cos(theta_c)
    uc, vc = stereo_project_3d(xc, yc, zc)
    ax2.plot(uc, vc, 'gray', linewidth=0.5, alpha=0.5)

ax2.set_xlim(-8, 8)
ax2.set_ylim(-8, 8)
ax2.set_aspect('equal')
ax2.set_title('Stereographic Projections in ℝ²\n(circles → circles!)', fontsize=13, fontweight='bold')
ax2.set_xlabel('u = x/(1-z)')
ax2.set_ylabel('v = y/(1-z)')
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)

plt.suptitle('THE IDEMPOTENT LENS IN 3D:\nStereographic Projection S² → ℝ²',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('/workspace/request-project/python_demos/sphere_projection_3d.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("\n✓ Saved: sphere_projection_3d.png")
