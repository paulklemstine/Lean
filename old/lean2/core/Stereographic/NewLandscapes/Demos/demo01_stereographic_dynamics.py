#!/usr/bin/env python3
"""
Demo 01: Stereographic Dynamics — Julia Sets on the Sphere

Maps the Julia set of f(z) = z² + c onto S² via inverse stereographic projection.
Reveals hidden structure: the point at infinity becomes visible, and the
Julia set forms beautiful closed curves on the sphere.

Oracle Ξ's Investigation: "On the sphere, chaos has nowhere to hide."
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.colors import Normalize
import matplotlib.cm as cm

def inv_stereo(u, v):
    """Inverse stereographic projection ℝ² → S²."""
    D = 1 + u**2 + v**2
    x = 2*u / D
    y = 2*v / D
    z = (D - 2) / D  # = (u² + v² - 1) / (u² + v² + 1)
    return x, y, z

def julia_escape_time(z, c, max_iter=100):
    """Compute escape time for the Julia set of z² + c."""
    for i in range(max_iter):
        if abs(z) > 2:
            return i
        z = z*z + c
    return max_iter

def draw_wireframe_sphere(ax, alpha=0.05):
    """Draw a transparent wireframe sphere."""
    u = np.linspace(0, 2*np.pi, 40)
    v = np.linspace(0, np.pi, 20)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones_like(u), np.cos(v))
    ax.plot_wireframe(x, y, z, color='gray', alpha=alpha, linewidth=0.3)

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Stereographic Dynamics: Julia Sets on S²\nOracle Ξ — \"On the sphere, chaos has nowhere to hide\"",
             fontsize=16, fontweight='bold', y=0.98)

# Four Julia sets with different c values
params = [
    (0 + 0j, "c = 0  (Unit Circle → Equator)", 'twilight'),
    (-1 + 0j, "c = -1  (Basilica)", 'magma'),
    (0 + 1j, "c = i  (Dendrite)", 'viridis'),
    (-0.12 + 0.74j, "c = -0.12+0.74i  (Douady Rabbit)", 'plasma'),
]

for idx, (c, title, cmap_name) in enumerate(params):
    ax = fig.add_subplot(2, 2, idx+1, projection='3d')

    # Sample points in the complex plane
    res = 300
    re = np.linspace(-2.5, 2.5, res)
    im = np.linspace(-2.5, 2.5, res)
    RE, IM = np.meshgrid(re, im)
    Z = RE + 1j * IM

    # Compute escape times
    escape = np.zeros_like(RE)
    for i in range(res):
        for j in range(res):
            escape[i, j] = julia_escape_time(Z[i, j], c, max_iter=50)

    # Find points near the Julia set (boundary of escape)
    # Use gradient to find the boundary
    grad_x = np.abs(np.diff(escape, axis=1))
    grad_y = np.abs(np.diff(escape, axis=0))

    # Points on or near the Julia set
    boundary_mask = np.zeros_like(escape, dtype=bool)
    boundary_mask[:, :-1] |= grad_x > 1
    boundary_mask[:-1, :] |= grad_y > 1

    # Also include points that never escape (filled Julia set interior)
    interior_mask = escape >= 50

    # Extract boundary and interior points
    julia_u = RE[boundary_mask]
    julia_v = IM[boundary_mask]
    julia_e = escape[boundary_mask]

    # Project to sphere
    sx, sy, sz = inv_stereo(julia_u, julia_v)

    draw_wireframe_sphere(ax, alpha=0.03)

    # Color by escape time
    norm = Normalize(vmin=0, vmax=50)
    colors = cm.get_cmap(cmap_name)(norm(julia_e))

    ax.scatter(sx, sy, sz, c=julia_e, cmap=cmap_name, s=0.3, alpha=0.6)

    # Mark the north pole (infinity)
    ax.scatter([0], [0], [1], color='red', s=80, marker='*', zorder=10,
               label='∞ (North Pole)')
    ax.scatter([0], [0], [-1], color='blue', s=80, marker='o', zorder=10,
               label='0 (South Pole)')

    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.set_xlim([-1.1, 1.1])
    ax.set_ylim([-1.1, 1.1])
    ax.set_zlim([-1.1, 1.1])
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.legend(fontsize=7, loc='lower left')
    ax.view_init(elev=25, azim=45 + idx*30)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo01_stereographic_dynamics.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 01: Stereographic Dynamics — Julia Sets on S² saved.")
