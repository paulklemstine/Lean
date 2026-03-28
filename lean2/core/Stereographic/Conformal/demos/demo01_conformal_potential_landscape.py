#!/usr/bin/env python3
"""
Demo 01: Conformal Potential Landscape
=======================================
Visualizes the conformal potential Φ(y) = log((1+|y|²)/2) that arises from 
inverse stereographic projection. This potential creates a natural "gravity well"
at the south pole of the sphere, with logarithmic growth toward the north pole.

The conformal factor λ = 2/(1+|y|²) acts as a Boltzmann weight, making the
south pole region energetically favorable.

Oracle Σ's Discovery: This potential is precisely the Yamabe flow potential
in stereographic coordinates.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D

def conformal_factor(y1, y2):
    """λ(y) = 2 / (1 + |y|²)"""
    return 2.0 / (1.0 + y1**2 + y2**2)

def conformal_potential(y1, y2):
    """Φ(y) = log((1 + |y|²) / 2) = -log(λ)"""
    return np.log((1.0 + y1**2 + y2**2) / 2.0)

def inverse_stereo_2d(y1, y2):
    """Inverse stereographic projection R² → S²"""
    D = 1.0 + y1**2 + y2**2
    x1 = 2 * y1 / D
    x2 = 2 * y2 / D
    x3 = (D - 2) / D
    return x1, x2, x3

def gradient_field(y1, y2):
    """∇Φ = 2y / (1 + |y|²) — the conformal gradient"""
    D = 1.0 + y1**2 + y2**2
    return 2 * y1 / D, 2 * y2 / D

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Conformal Potential Landscape of Inverse Stereographic Projection",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: 3D potential surface ---
ax1 = fig.add_subplot(2, 2, 1, projection='3d')
Y = np.linspace(-4, 4, 200)
Y1, Y2 = np.meshgrid(Y, Y)
Phi = conformal_potential(Y1, Y2)
surf = ax1.plot_surface(Y1, Y2, Phi, cmap=cm.magma, alpha=0.85,
                        rstride=4, cstride=4, linewidth=0)
ax1.set_xlabel('y₁', fontsize=12)
ax1.set_ylabel('y₂', fontsize=12)
ax1.set_zlabel('Φ(y)', fontsize=12)
ax1.set_title('Conformal Potential Φ(y) = log((1+|y|²)/2)', fontsize=13)
ax1.view_init(elev=25, azim=-60)

# --- Panel 2: Conformal factor heat map with gradient flow ---
ax2 = fig.add_subplot(2, 2, 2)
Y_fine = np.linspace(-4, 4, 400)
Y1f, Y2f = np.meshgrid(Y_fine, Y_fine)
Lambda = conformal_factor(Y1f, Y2f)
im = ax2.imshow(Lambda, extent=[-4, 4, -4, 4], origin='lower', cmap='inferno',
                vmin=0, vmax=2)
plt.colorbar(im, ax=ax2, label='λ(y) = 2/(1+|y|²)')

# Gradient flow lines (flow toward origin = south pole)
Y_coarse = np.linspace(-3.8, 3.8, 16)
Y1c, Y2c = np.meshgrid(Y_coarse, Y_coarse)
GX, GY = gradient_field(Y1c, Y2c)
ax2.streamplot(Y_coarse, Y_coarse, -GX, -GY, color='white', linewidth=0.8,
               density=1.5, arrowsize=1.2)
ax2.set_xlabel('y₁', fontsize=12)
ax2.set_ylabel('y₂', fontsize=12)
ax2.set_title('Conformal Factor λ with Gradient Flow Lines', fontsize=13)
ax2.set_aspect('equal')

# --- Panel 3: Radial profile of conformal factor for different dimensions ---
ax3 = fig.add_subplot(2, 2, 3)
r = np.linspace(0, 6, 500)
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
dims = [1, 2, 4, 8, 16]
for n, c in zip(dims, colors):
    lambda_n = (2 / (1 + r**2))**n
    ax3.plot(r, lambda_n, color=c, linewidth=2.5, label=f'N={n}')
    # Mark the "half-power" radius
    r_half = np.sqrt(2**(1/n) - 1)
    ax3.axvline(r_half, color=c, linestyle=':', alpha=0.4, linewidth=1)

ax3.set_xlabel('r = |y|', fontsize=12)
ax3.set_ylabel('λᴺ (volume distortion)', fontsize=12)
ax3.set_title('Volume Distortion by Dimension\n(Concentration of Measure)', fontsize=13)
ax3.legend(fontsize=11, loc='upper right')
ax3.set_yscale('log')
ax3.set_ylim(1e-12, 3)
ax3.grid(True, alpha=0.3)
ax3.annotate('Higher dimensions →\nmore concentrated at origin',
             xy=(3, 1e-6), fontsize=10, fontstyle='italic', color='gray')

# --- Panel 4: Equipotential curves on the sphere ---
ax4 = fig.add_subplot(2, 2, 4, projection='3d')

# Draw sphere wireframe
u_sphere = np.linspace(0, 2 * np.pi, 60)
v_sphere = np.linspace(0, np.pi, 30)
xs = np.outer(np.cos(u_sphere), np.sin(v_sphere))
ys = np.outer(np.sin(u_sphere), np.sin(v_sphere))
zs = np.outer(np.ones_like(u_sphere), np.cos(v_sphere))
ax4.plot_wireframe(xs, ys, zs, color='lightblue', alpha=0.15, linewidth=0.3)

# Equipotential circles (concentric circles in R² → latitude lines on S²)
for r_val in [0.3, 0.6, 1.0, 1.5, 2.5, 4.0]:
    theta = np.linspace(0, 2 * np.pi, 200)
    y1_circ = r_val * np.cos(theta)
    y2_circ = r_val * np.sin(theta)
    x1, x2, x3 = inverse_stereo_2d(y1_circ, y2_circ)
    color_val = conformal_potential(r_val, 0)
    ax4.plot(x1, x2, x3, linewidth=2.0,
             color=cm.magma(min(1.0, color_val / 3.0)),
             label=f'r={r_val:.1f}, Φ={color_val:.2f}' if r_val in [0.3, 1.0, 4.0] else '')

# Mark south pole
ax4.scatter([0], [0], [-1], color='gold', s=100, zorder=5, marker='*')
ax4.text(0, 0, -1.2, 'South Pole\n(Φ minimum)', fontsize=8, ha='center', color='gold')

# Mark north pole
ax4.scatter([0], [0], [1], color='red', s=100, zorder=5, marker='x')
ax4.text(0, 0, 1.15, 'North Pole\n(Φ → ∞)', fontsize=8, ha='center', color='red')

ax4.set_title('Equipotential Circles on S²\n(Darker = Lower Potential)', fontsize=13)
ax4.legend(fontsize=8, loc='lower left')
ax4.set_box_aspect([1, 1, 1])

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('/workspace/request-project/demos/demo01_conformal_potential_landscape.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 01 saved: demos/demo01_conformal_potential_landscape.png")
