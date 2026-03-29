#!/usr/bin/env python3
"""
Demo 10: Stereographic Curvature Flow — How Shapes Evolve on Spheres
=====================================================================

NEW LANDSCAPE: Curvature flow (like mean curvature flow or Ricci flow)
on the sphere can be studied in stereographic coordinates. The conformal
factor 2/(1+|y|²) transforms the flow equations in a revealing way.

Key Discovery: Under stereographic projection, the round sphere's constant
curvature becomes a radially-dependent curvature in flat coordinates.
Curves evolving by curvature on S² become curves in ℝ² evolving by a
*weighted* curvature flow, where the weight is the conformal factor.

Also: visualization of the Gauss curvature of surfaces obtained by
inverse stereographic projection of various planar curves.

Oracle Ω's experiment on geometric flows via stereographic coordinates.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import Normalize

def inv_stereo_2d(u, v):
    """Inverse stereographic: ℝ² → S² ⊂ ℝ³"""
    D = 1 + u**2 + v**2
    return 2*u/D, 2*v/D, (u**2 + v**2 - 1)/D

def conformal_factor(u, v):
    """Conformal factor λ = 2/(1+|y|²) of stereographic projection."""
    return 2.0 / (1 + u**2 + v**2)

def gaussian_curvature_stereo(u, v):
    """
    The Gaussian curvature of S² in stereographic coordinates.
    K = 1 for the round sphere, but expressed in flat coords:
    K_flat = K_sphere / λ² where λ = conformal factor.
    Since K_sphere = 1 and λ = 2/D, K_flat = D²/4.
    
    But what we actually want: the metric is g = λ² δ, so
    the curvature of the metric g = (4/D²)δ is K = 1 everywhere
    (it's the round sphere). The "apparent curvature" in flat
    coords is different from the intrinsic curvature.
    """
    D = 1 + u**2 + v**2
    return np.ones_like(D)  # Intrinsic curvature = 1 always

def stereographic_area_element(u, v):
    """
    Area element dA_sphere = λ² du dv = 4/(1+|y|²)² du dv.
    This shows how area is distributed in stereographic coords.
    """
    D = 1 + u**2 + v**2
    return 4.0 / D**2

def evolve_curve_curvature_flow(x, y, dt=0.001, n_steps=50):
    """
    Evolve a curve in ℝ² by curvature flow weighted by the
    stereographic conformal factor. Points move in the normal
    direction proportionally to curvature × λ².
    """
    curves = [(x.copy(), y.copy())]
    
    for step in range(n_steps):
        n = len(x)
        # Compute curvature using finite differences
        dx = np.roll(x, -1) - np.roll(x, 1)
        dy = np.roll(y, -1) - np.roll(y, 1)
        d2x = np.roll(x, -1) - 2*x + np.roll(x, 1)
        d2y = np.roll(y, -1) - 2*y + np.roll(y, 1)
        
        ds = np.sqrt(dx**2 + dy**2)
        ds = np.where(ds < 1e-10, 1e-10, ds)
        
        # Curvature: κ = (dx·d2y - dy·d2x) / |ds|³
        kappa = (dx * d2y - dy * d2x) / ds**3
        
        # Normal direction
        nx = -dy / ds
        ny = dx / ds
        
        # Weight by conformal factor squared
        lam = conformal_factor(x, y)
        weight = lam**2
        
        # Move in normal direction
        x = x + dt * kappa * weight * nx
        y = y + dt * kappa * weight * ny
        
        if step % 5 == 0:
            curves.append((x.copy(), y.copy()))
    
    return curves

# ─── Figure ───

fig = plt.figure(figsize=(20, 16))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: Stereographic area element — how the sphere's area
# is distributed in the plane
ax1 = fig.add_subplot(gs[0, 0])

u_grid = np.linspace(-5, 5, 500)
v_grid = np.linspace(-5, 5, 500)
U, V = np.meshgrid(u_grid, v_grid)

area = stereographic_area_element(U, V)

im1 = ax1.pcolormesh(U, V, np.log10(area), cmap='viridis', shading='auto',
                     vmin=-3, vmax=0.5)
plt.colorbar(im1, ax=ax1, label='log₁₀(area element)')

# Contours of equal area distortion
ax1.contour(U, V, area, levels=[0.01, 0.05, 0.1, 0.5, 1.0, 2.0, 3.0],
           colors='white', linewidths=0.5, alpha=0.6)

# Mark where area element = 1 (no distortion)
ax1.contour(U, V, area, levels=[1.0], colors='red', linewidths=2)
ax1.annotate('No distortion\n(area = 1)', xy=(0, 0), xytext=(2, 2),
            fontsize=10, color='red', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='red'))

ax1.set_xlabel('u', fontsize=12)
ax1.set_ylabel('v', fontsize=12)
ax1.set_title('Spherical Area in Stereographic Coords\nRed: no distortion. Far from origin: extreme compression',
             fontsize=12, fontweight='bold')
ax1.set_aspect('equal')

# Panel 2: Curvature flow of curves
ax2 = fig.add_subplot(gs[0, 1])

# Start with an ellipse
n_pts = 200
theta = np.linspace(0, 2*np.pi, n_pts, endpoint=False)
x0 = 2.0 * np.cos(theta)
y0 = 0.8 * np.sin(theta)

curves = evolve_curve_curvature_flow(x0, y0, dt=0.002, n_steps=100)

n_curves = len(curves)
for k, (cx, cy) in enumerate(curves):
    alpha = 0.3 + 0.7 * (k / n_curves)
    color = plt.cm.cool(k / n_curves)
    ax2.plot(np.append(cx, cx[0]), np.append(cy, cy[0]),
            color=color, linewidth=1.0, alpha=alpha)

# Draw initial and final
ax2.plot(np.append(curves[0][0], curves[0][0][0]),
        np.append(curves[0][1], curves[0][1][0]),
        'b-', linewidth=2.5, label='Initial (ellipse)')
ax2.plot(np.append(curves[-1][0], curves[-1][0][0]),
        np.append(curves[-1][1], curves[-1][1][0]),
        'r-', linewidth=2.5, label='Final (approaching circle)')

ax2.set_xlabel('u', fontsize=12)
ax2.set_ylabel('v', fontsize=12)
ax2.set_title('Weighted Curvature Flow in Stereo Coords\nEllipse → circle (conformal-weighted)',
             fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-3, 3)
ax2.set_ylim(-3, 3)

# Panel 3: Inverse stereographic projection of various curves → curves on S²
ax3 = fig.add_subplot(gs[1, 0], projection='3d')

# Several plane curves, projected to S²
curves_2d = {
    'Circle r=1': (np.cos(theta), np.sin(theta)),
    'Circle r=2': (2*np.cos(theta), 2*np.sin(theta)),
    'Line y=0': (np.linspace(-5, 5, 200), np.zeros(200)),
    'Spiral': (theta/(2*np.pi) * np.cos(3*theta), theta/(2*np.pi) * np.sin(3*theta)),
    'Lemniscate': (np.cos(theta)/(1+np.sin(theta)**2) * 2,
                   np.sin(theta)*np.cos(theta)/(1+np.sin(theta)**2) * 2),
}

colors_3d = plt.cm.Set2(np.linspace(0, 1, len(curves_2d)))
for (name, (cu, cv)), color in zip(curves_2d.items(), colors_3d):
    sx, sy, sz = inv_stereo_2d(cu, cv)
    ax3.plot(sx, sy, sz, color=color, linewidth=2, label=name, alpha=0.8)

# Draw sphere wireframe
phi_w = np.linspace(0, 2*np.pi, 50)
theta_w = np.linspace(0, np.pi, 25)
for th in theta_w[::4]:
    ax3.plot(np.sin(th)*np.cos(phi_w), np.sin(th)*np.sin(phi_w),
            np.cos(th)*np.ones_like(phi_w), 'k-', linewidth=0.2, alpha=0.15)
for ph in phi_w[::6]:
    ax3.plot(np.sin(theta_w)*np.cos(ph), np.sin(theta_w)*np.sin(ph),
            np.cos(theta_w), 'k-', linewidth=0.2, alpha=0.15)

ax3.set_title('Plane Curves Lifted to S²\nvia Inverse Stereographic Projection',
             fontsize=12, fontweight='bold')
ax3.legend(fontsize=8, loc='upper left')
ax3.view_init(elev=25, azim=40)

# Panel 4: Conformal factor as function of distance — the "stereographic lens"
ax4 = fig.add_subplot(gs[1, 1])

r = np.linspace(0, 10, 1000)
lambda_vals = 2.0 / (1 + r**2)
area_vals = lambda_vals**2

# Also plot the arc length element
arclength_vals = lambda_vals

ax4.plot(r, lambda_vals, 'b-', linewidth=2.5, label='λ = 2/(1+r²) [scale factor]')
ax4.plot(r, area_vals, 'r-', linewidth=2.5, label='λ² = 4/(1+r²)² [area factor]')
ax4.plot(r, arclength_vals, 'g--', linewidth=2, label='λ [arclength factor]')

# Mark key radii
ax4.axvline(x=1, color='gray', linestyle=':', alpha=0.5)
ax4.annotate('r = 1\n(equator)', xy=(1, 1), xytext=(1.5, 1.2),
            fontsize=10, arrowprops=dict(arrowstyle='->'))

ax4.axvline(x=np.sqrt(3), color='gray', linestyle=':', alpha=0.5)
ax4.annotate('r = √3\n(30° from pole)', xy=(np.sqrt(3), 0.5), xytext=(2.5, 0.7),
            fontsize=10, arrowprops=dict(arrowstyle='->'))

ax4.fill_between(r, 0, area_vals, alpha=0.1, color='red')

ax4.set_xlabel('Distance from origin in ℝ² (r)', fontsize=12)
ax4.set_ylabel('Factor value', fontsize=12)
ax4.set_title('The Stereographic Lens Effect\nHow distances & areas shrink far from origin',
             fontsize=12, fontweight='bold')
ax4.legend(fontsize=10, loc='upper right')
ax4.grid(True, alpha=0.3)
ax4.set_xlim(0, 8)
ax4.set_ylim(0, 2.2)

fig.suptitle('Curvature, Area & Geometric Flow Through the Stereographic Lens',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo10_curvature_flow.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 10 saved: demo10_curvature_flow.png")
