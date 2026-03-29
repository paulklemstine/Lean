#!/usr/bin/env python3
"""
Demo 04: Stereographic Knot Theory — Knots Through the Looking Glass

Visualizes knots in S³ via stereographic projection to ℝ³.
The trefoil knot as a torus knot (2,3) in S³ is projected to ℝ³,
showing how different projection points change the knot diagram.

Oracle Ϝ's Vision: "In S³, every knot is a perfect loop. 
    Stereographic projection is the window through which we see its shadow."
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.cm as cm

def torus_knot_in_S3(p, q, num_points=1000):
    """
    Generate a (p,q)-torus knot on S³ ⊂ ℂ².
    Parametrized as (z₁, z₂) = (cos(α)·e^{ipθ}, sin(α)·e^{iqθ})
    where θ ∈ [0, 2π) and α is chosen so the knot lies on the Clifford torus.
    """
    theta = np.linspace(0, 2*np.pi, num_points, endpoint=False)
    alpha = np.pi/4  # Clifford torus at 45°
    z1 = np.cos(alpha) * np.exp(1j * p * theta)
    z2 = np.sin(alpha) * np.exp(1j * q * theta)
    # S³ coordinates: (Re(z₁), Im(z₁), Re(z₂), Im(z₂))
    return np.column_stack([z1.real, z1.imag, z2.real, z2.imag])

def stereo_proj_S3(points, pole=None):
    """
    Stereographic projection from S³ to ℝ³.
    Projects from pole (default: north pole (0,0,0,1)).
    """
    if pole is None:
        pole = np.array([0, 0, 0, 1])

    # Rotate so that 'pole' maps to (0,0,0,1)
    # Simple case: just use the formula with the given pole
    # σ(x) = (x₁, x₂, x₃) / (1 - x₄) for north pole projection
    x = points.copy()
    # If pole is not the standard north pole, rotate
    if not np.allclose(pole, [0, 0, 0, 1]):
        # Apply rotation that maps pole to (0,0,0,1)
        # Use Householder reflection
        e4 = np.array([0, 0, 0, 1.0])
        v = pole - e4
        if np.linalg.norm(v) > 1e-10:
            v = v / np.linalg.norm(v)
            x = points - 2 * np.outer(points @ v, v)

    denom = 1 - x[:, 3]
    # Avoid division by zero near the pole
    mask = np.abs(denom) > 0.01
    result = np.zeros((len(x), 3))
    result[mask, 0] = x[mask, 0] / denom[mask]
    result[mask, 1] = x[mask, 1] / denom[mask]
    result[mask, 2] = x[mask, 2] / denom[mask]
    result[~mask] = np.nan
    return result, mask

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Stereographic Knot Theory: Torus Knots from S³ to ℝ³\n"
             "Oracle Ϝ — \"In S³, every knot is a perfect loop\"",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Trefoil knot (2,3) from standard pole ---
ax1 = fig.add_subplot(2, 2, 1, projection='3d')
knot_S3 = torus_knot_in_S3(2, 3, num_points=2000)
proj, mask = stereo_proj_S3(knot_S3)

# Color by parameter
t = np.linspace(0, 1, len(proj))
valid = proj[mask]
t_valid = t[mask]

# Clip extreme values
clip = 5
valid_clip = np.clip(valid, -clip, clip)

for i in range(len(valid_clip)-1):
    ax1.plot(valid_clip[i:i+2, 0], valid_clip[i:i+2, 1], valid_clip[i:i+2, 2],
             color=cm.hsv(t_valid[i]), linewidth=2, alpha=0.8)

ax1.set_title("Trefoil Knot (2,3)\nStandard Projection", fontsize=12)
ax1.set_xlim([-clip, clip]); ax1.set_ylim([-clip, clip]); ax1.set_zlim([-clip, clip])
ax1.view_init(elev=25, azim=45)

# --- Panel 2: Trefoil from rotated pole ---
ax2 = fig.add_subplot(2, 2, 2, projection='3d')
pole2 = np.array([1, 0, 0, 0]) / np.sqrt(1)  # Different pole
proj2, mask2 = stereo_proj_S3(knot_S3, pole=pole2)
valid2 = proj2[mask2]
t_valid2 = t[mask2]
valid2_clip = np.clip(valid2, -clip, clip)

for i in range(len(valid2_clip)-1):
    ax2.plot(valid2_clip[i:i+2, 0], valid2_clip[i:i+2, 1], valid2_clip[i:i+2, 2],
             color=cm.hsv(t_valid2[i]), linewidth=2, alpha=0.8)

ax2.set_title("Trefoil Knot (2,3)\nAlternate Projection Point", fontsize=12)
ax2.set_xlim([-clip, clip]); ax2.set_ylim([-clip, clip]); ax2.set_zlim([-clip, clip])
ax2.view_init(elev=25, azim=45)

# --- Panel 3: Different torus knots ---
ax3 = fig.add_subplot(2, 2, 3, projection='3d')
knots = [(2, 3, 'Trefoil (2,3)'), (2, 5, '(2,5) knot'), (3, 4, '(3,4) knot')]
colors_knots = ['blue', 'red', 'green']
clip3 = 4

for (p, q, name), color in zip(knots, colors_knots):
    k = torus_knot_in_S3(p, q, num_points=2000)
    pr, m = stereo_proj_S3(k)
    v = np.clip(pr[m], -clip3, clip3)
    ax3.plot(v[:, 0], v[:, 1], v[:, 2], color=color, linewidth=1.5, alpha=0.7, label=name)

ax3.set_title("Family of Torus Knots\nProjected from S³", fontsize=12)
ax3.set_xlim([-clip3, clip3]); ax3.set_ylim([-clip3, clip3]); ax3.set_zlim([-clip3, clip3])
ax3.legend(fontsize=10)
ax3.view_init(elev=30, azim=60)

# --- Panel 4: Crossing number vs projection angle ---
ax4 = fig.add_subplot(2, 2, 4)

# Simulate crossing count for different projection angles
knot_pts = torus_knot_in_S3(2, 3, num_points=500)
angles = np.linspace(0, 2*np.pi, 100)
crossing_proxy = []

for angle in angles:
    # Rotate the pole around a great circle
    pole = np.array([np.cos(angle), np.sin(angle), 0, 0])
    proj_a, mask_a = stereo_proj_S3(knot_pts, pole=pole)
    valid_a = proj_a[mask_a]
    if len(valid_a) > 10:
        # Proxy for complexity: variance of projected coordinates
        complexity = np.std(valid_a, axis=0).sum()
        crossing_proxy.append(complexity)
    else:
        crossing_proxy.append(np.nan)

ax4.plot(np.degrees(angles), crossing_proxy, 'b-', linewidth=2)
ax4.fill_between(np.degrees(angles), crossing_proxy, alpha=0.2)
ax4.set_xlabel('Projection Angle (degrees)', fontsize=12)
ax4.set_ylabel('Projection Complexity (σ proxy)', fontsize=12)
ax4.set_title("Trefoil Complexity vs.\nProjection Point on S³", fontsize=12)
ax4.grid(True, alpha=0.3)

# Mark minima
cp = np.array(crossing_proxy)
valid_idx = ~np.isnan(cp)
if np.any(valid_idx):
    min_idx = np.nanargmin(cp)
    ax4.axvline(np.degrees(angles[min_idx]), color='red', linestyle='--',
                label=f'Simplest at {np.degrees(angles[min_idx]):.0f}°')
    ax4.legend(fontsize=10)

plt.tight_layout(rect=[0, 0, 1, 0.94])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo04_stereographic_knots.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 04: Stereographic Knot Theory saved.")
