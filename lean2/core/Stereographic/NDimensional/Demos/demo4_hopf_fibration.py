#!/usr/bin/env python3
"""
Demo 4: Hopf Fibration — The Most Beautiful Map in Mathematics
==============================================================

Visualizes the Hopf fibration S³ → S² by stereographically projecting
the fibers (circles in S³) to circles in ℝ³.

Each point on S² determines a great circle in S³ (a Hopf fiber).
Under stereographic projection S³ → ℝ³, these become circles that
fill all of ℝ³ and are pairwise linked.

Oracle Φ's crown jewel.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def hopf_fiber(theta, phi, num_points=200):
    """
    Compute a Hopf fiber corresponding to the point
    (sin(theta)cos(phi), sin(theta)sin(phi), cos(theta)) on S².

    The fiber is a great circle in S³ parameterized by t ∈ [0, 2π].
    """
    t = np.linspace(0, 2*np.pi, num_points)

    # Point on S²
    half_theta = theta / 2

    # The fiber in S³ ⊂ ℂ² ≅ ℝ⁴
    # (z₁, z₂) = (cos(θ/2) e^{it}, sin(θ/2) e^{i(t+φ)})
    z1_real = np.cos(half_theta) * np.cos(t)
    z1_imag = np.cos(half_theta) * np.sin(t)
    z2_real = np.sin(half_theta) * np.cos(t + phi)
    z2_imag = np.sin(half_theta) * np.sin(t + phi)

    return z1_real, z1_imag, z2_real, z2_imag

def stereo_4to3(x1, x2, x3, x4):
    """Stereographic projection S³ → ℝ³ from north pole (0,0,0,1)."""
    denom = 1 - x4
    denom = np.where(np.abs(denom) < 1e-10, np.nan, denom)
    return x1/denom, x2/denom, x3/denom

# ─── Create the Hopf fibration visualization ───

fig = plt.figure(figsize=(20, 10))

# === Panel 1: Fibers colored by base point latitude ===
ax1 = fig.add_subplot(121, projection='3d')

# Sample points on S² at different latitudes
n_lat = 8
n_lon = 12

for i, theta in enumerate(np.linspace(0.2, np.pi - 0.2, n_lat)):
    for j, phi in enumerate(np.linspace(0, 2*np.pi, n_lon, endpoint=False)):
        # Get the fiber
        x1, x2, x3, x4 = hopf_fiber(theta, phi, num_points=300)

        # Project to ℝ³
        u, v, w = stereo_4to3(x1, x2, x3, x4)

        # Color by latitude (theta)
        color = plt.cm.hsv(i / n_lat)
        alpha = 0.6

        mask = np.isfinite(u) & (np.abs(u) < 8) & (np.abs(v) < 8) & (np.abs(w) < 8)

        if np.sum(mask) > 10:
            ax1.plot(u[mask], v[mask], w[mask],
                    color=color, linewidth=0.8, alpha=alpha)

ax1.set_xlim(-4, 4)
ax1.set_ylim(-4, 4)
ax1.set_zlim(-4, 4)
ax1.set_title('Hopf Fibration: Fibers in ℝ³\n(colored by latitude on S²)',
             fontsize=14, fontweight='bold')
ax1.view_init(elev=25, azim=45)

# === Panel 2: Torus structure — fibers along a single latitude ===
ax2 = fig.add_subplot(122, projection='3d')

# Choose one latitude and show many fibers
theta_fixed = np.pi / 3  # 60° latitude

n_fibers = 40
colors_torus = plt.cm.rainbow(np.linspace(0, 1, n_fibers))

for j, phi in enumerate(np.linspace(0, 2*np.pi, n_fibers, endpoint=False)):
    x1, x2, x3, x4 = hopf_fiber(theta_fixed, phi, num_points=500)
    u, v, w = stereo_4to3(x1, x2, x3, x4)

    mask = np.isfinite(u) & (np.abs(u) < 6) & (np.abs(v) < 6) & (np.abs(w) < 6)

    if np.sum(mask) > 10:
        ax2.plot(u[mask], v[mask], w[mask],
                color=colors_torus[j], linewidth=1.2, alpha=0.7)

ax2.set_xlim(-4, 4)
ax2.set_ylim(-4, 4)
ax2.set_zlim(-4, 4)
ax2.set_title('Hopf Torus: Fibers at Fixed Latitude\n(each fiber is a circle linking all others)',
             fontsize=14, fontweight='bold')
ax2.view_init(elev=15, azim=60)

fig.suptitle('The Hopf Fibration via Stereographic Projection\n'
            'S³ → S²: Every point on S² determines a circle in S³, '
            'projected to ℝ³',
            fontsize=16, fontweight='bold', y=1.02)

plt.savefig('/workspace/request-project/Stereographic/Demos/demo4_hopf_fibration.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 4 saved: demo4_hopf_fibration.png")

# ─── Bonus: Single torus close-up ───

fig2, ax = plt.subplots(1, 1, figsize=(10, 10), subplot_kw={'projection': '3d'})

theta_val = np.pi / 4
n_fibers = 60
colors = plt.cm.twilight(np.linspace(0, 1, n_fibers))

for j, phi in enumerate(np.linspace(0, 2*np.pi, n_fibers, endpoint=False)):
    x1, x2, x3, x4 = hopf_fiber(theta_val, phi, num_points=500)
    u, v, w = stereo_4to3(x1, x2, x3, x4)
    mask = np.isfinite(u) & (np.abs(u) < 10) & (np.abs(v) < 10) & (np.abs(w) < 10)
    if np.sum(mask) > 10:
        ax.plot(u[mask], v[mask], w[mask],
               color=colors[j], linewidth=1.0, alpha=0.8)

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_zlim(-3, 3)
ax.set_title('Hopf Torus — 60 Linked Circles\nEach fiber links every other fiber exactly once',
            fontsize=14, fontweight='bold')
ax.view_init(elev=20, azim=30)

plt.savefig('/workspace/request-project/Stereographic/Demos/demo4_hopf_torus_closeup.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 4 bonus saved: demo4_hopf_torus_closeup.png")
