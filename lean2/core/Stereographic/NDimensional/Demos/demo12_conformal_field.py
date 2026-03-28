#!/usr/bin/env python3
"""
Demo 12: Conformal Field Theory via Stereographic Projection
==============================================================

NEW LANDSCAPE: Conformal field theory (CFT) on the sphere S² is equivalent
to CFT in the plane via stereographic projection. The correlation functions
transform with specific conformal weights determined by the conformal factor.

Key Discovery: The stereographic projection provides a concrete bridge
between "radial quantization" (CFT on the cylinder S¹ × ℝ) and
"Euclidean CFT" (on ℝ²). The state-operator correspondence of CFT
is literally the stereographic projection.

Oracle Ω's physics landscape.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LogNorm

def conformal_factor(u, v):
    """λ = 2/(1+|y|²)"""
    return 2.0 / (1 + u**2 + v**2)

def two_point_function_plane(u1, v1, u2, v2, delta=1):
    """
    Two-point correlator ⟨O(z₁)O(z₂)⟩ = 1/|z₁-z₂|^{2Δ} in the plane.
    """
    dist_sq = (u1 - u2)**2 + (v1 - v2)**2
    return np.where(dist_sq > 1e-10, 1.0 / dist_sq**delta, np.nan)

def two_point_function_sphere(u1, v1, u2, v2, delta=1):
    """
    Two-point correlator on S² via stereographic projection.
    Includes conformal weight factors: λ₁^Δ · λ₂^Δ · G_plane.
    """
    lam1 = conformal_factor(u1, v1)
    lam2 = conformal_factor(u2, v2)
    G_plane = two_point_function_plane(u1, v1, u2, v2, delta)
    return lam1**delta * lam2**delta * G_plane

def operator_at_point(U, V, u0, v0, delta=1):
    """Field around operator insertion at (u0, v0) with dimension Δ."""
    dist_sq = (U - u0)**2 + (V - v0)**2
    return np.where(dist_sq > 0.01, 1.0 / dist_sq**delta, np.nan)

def radial_quantization_cylinder():
    """
    Radial quantization: the plane minus origin ℝ²\{0} ≅ S¹ × ℝ (cylinder)
    via z = e^{τ+iσ}, where τ = log|z|, σ = arg(z).
    
    Under stereographic projection, this becomes a map from the
    punctured sphere to the cylinder.
    """
    tau = np.linspace(-3, 3, 200)
    sigma = np.linspace(0, 2*np.pi, 200)
    TAU, SIGMA = np.meshgrid(tau, sigma)
    
    # Map to plane: z = e^{τ+iσ}
    r = np.exp(TAU)
    u = r * np.cos(SIGMA)
    v = r * np.sin(SIGMA)
    
    return TAU, SIGMA, u, v

# ─── Figure ───

fig = plt.figure(figsize=(20, 16))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: Correlator landscape — two operators on the plane
ax1 = fig.add_subplot(gs[0, 0])

u_grid = np.linspace(-4, 4, 400)
v_grid = np.linspace(-4, 4, 400)
U, V = np.meshgrid(u_grid, v_grid)

# Place two operators at (−1.5, 0) and (1.5, 0)
op1 = operator_at_point(U, V, -1.5, 0, delta=0.5)
op2 = operator_at_point(U, V, 1.5, 0, delta=0.5)

# The "field" is the product (two-point function landscape)
field = op1 * op2

im1 = ax1.pcolormesh(U, V, np.log10(np.abs(field) + 1e-10),
                    cmap='inferno', shading='auto', vmin=-4, vmax=2)
plt.colorbar(im1, ax=ax1, label='log₁₀|⟨O₁O₂⟩|')

ax1.plot(-1.5, 0, 'c*', markersize=15, markeredgecolor='white', markeredgewidth=1)
ax1.plot(1.5, 0, 'c*', markersize=15, markeredgecolor='white', markeredgewidth=1)
ax1.annotate('O₁', xy=(-1.5, 0), xytext=(-1.5, 0.5), fontsize=12, color='cyan',
            ha='center', fontweight='bold')
ax1.annotate('O₂', xy=(1.5, 0), xytext=(1.5, 0.5), fontsize=12, color='cyan',
            ha='center', fontweight='bold')

ax1.set_xlabel('u', fontsize=12)
ax1.set_ylabel('v', fontsize=12)
ax1.set_title('Two-Point Correlator Landscape\n⟨O(z₁)O(z₂)⟩ = 1/|z₁-z₂|²ᐩ',
             fontsize=12, fontweight='bold')
ax1.set_aspect('equal')

# Panel 2: Same correlator weighted by conformal factor (sphere version)
ax2 = fig.add_subplot(gs[0, 1])

# The sphere correlator includes conformal weight
lam = conformal_factor(U, V)
field_sphere = field * lam**2  # Weight by λ^{2Δ} for Δ=1

im2 = ax2.pcolormesh(U, V, np.log10(np.abs(field_sphere) + 1e-10),
                    cmap='inferno', shading='auto', vmin=-4, vmax=2)
plt.colorbar(im2, ax=ax2, label='log₁₀|⟨O₁O₂⟩_sphere|')

ax2.plot(-1.5, 0, 'c*', markersize=15, markeredgecolor='white', markeredgewidth=1)
ax2.plot(1.5, 0, 'c*', markersize=15, markeredgecolor='white', markeredgewidth=1)

# Show how the conformal factor suppresses the far field
ax2.contour(U, V, lam, levels=[0.1, 0.3, 0.5, 1.0, 1.5],
           colors='white', linewidths=0.5, alpha=0.4)

ax2.set_xlabel('u', fontsize=12)
ax2.set_ylabel('v', fontsize=12)
ax2.set_title('Sphere Correlator (Stereo Coords)\nWeighted by conformal factor λ²ᐩ',
             fontsize=12, fontweight='bold')
ax2.set_aspect('equal')

# Panel 3: Radial quantization — cylinder ↔ plane ↔ sphere
ax3 = fig.add_subplot(gs[1, 0])

TAU, SIGMA, u_cyl, v_cyl = radial_quantization_cylinder()

# On the cylinder, equal-time slices are circles
# On the plane, they are circles of radius e^τ
# Color by τ (time on cylinder)

for tau_val in np.linspace(-2, 2, 15):
    r = np.exp(tau_val)
    theta_c = np.linspace(0, 2*np.pi, 200)
    cx = r * np.cos(theta_c)
    cy = r * np.sin(theta_c)
    color = plt.cm.coolwarm((tau_val + 2) / 4)
    ax3.plot(cx, cy, color=color, linewidth=1.5, alpha=0.7)

# Mark origin (τ = -∞) and infinity (τ = +∞)
ax3.plot(0, 0, 'b*', markersize=15, label='Past (τ→-∞)')
ax3.annotate('τ → -∞\n(south pole)', xy=(0, 0), xytext=(1, -1),
            fontsize=10, color='blue',
            arrowprops=dict(arrowstyle='->', color='blue'))
ax3.annotate('τ → +∞\n(north pole)', xy=(5, 5), xytext=(3, 4),
            fontsize=10, color='red')

ax3.set_xlabel('u = eᵗ cos σ', fontsize=12)
ax3.set_ylabel('v = eᵗ sin σ', fontsize=12)
ax3.set_title('Radial Quantization\nEqual-time circles: S¹ × ℝ → ℝ²',
             fontsize=12, fontweight='bold')
ax3.set_aspect('equal')
ax3.set_xlim(-8, 8)
ax3.set_ylim(-8, 8)
ax3.grid(True, alpha=0.2)

# Panel 4: Conformal blocks — the OPE structure
ax4 = fig.add_subplot(gs[1, 1])

# Visualize how conformal blocks (partial waves) look in stereo coords
# For a scalar with dimension Δ, the conformal block in 2D is:
# G_Δ(z, z̄) ∝ z^Δ · ₂F₁(Δ, Δ; 2Δ; z) × (conjugate)
# For visualization, we show |z|^Δ patterns

r_grid = np.linspace(0.01, 3, 200)
theta_grid = np.linspace(0, 2*np.pi, 200)
R, THETA = np.meshgrid(r_grid, theta_grid)
Z_U = R * np.cos(THETA)
Z_V = R * np.sin(THETA)

# Different conformal dimensions
deltas = [0.5, 1.0, 1.5, 2.0]
fig4_sub = fig.add_subplot(gs[1, 1])

for i, delta in enumerate(deltas):
    # Conformal block ∝ r^Δ on the unit circle
    block = R**delta * np.cos(delta * THETA)  # Real part
    
    # Cross-section at θ=0
    ax4.plot(r_grid, r_grid**delta, linewidth=2.5,
            label=f'Δ = {delta}', alpha=0.8)

# Mark the unit circle (conformal boundary)
ax4.axvline(x=1, color='gray', linestyle='--', alpha=0.5, label='Unit circle')
ax4.axhline(y=1, color='gray', linestyle=':', alpha=0.3)

ax4.set_xlabel('Radial distance r = |z|', fontsize=12)
ax4.set_ylabel('Conformal block G_Δ(r)', fontsize=12)
ax4.set_title('Conformal Blocks at θ=0\nScaling dimensions Δ determine growth rate',
             fontsize=12, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.set_xlim(0, 3)
ax4.set_ylim(0, 5)

fig.suptitle('Conformal Field Theory Through the Stereographic Lens',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo12_conformal_field.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 12 saved: demo12_conformal_field.png")
