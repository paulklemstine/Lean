#!/usr/bin/env python3
"""
Demo 7: Conformal Flow and Möbius Transformations in N Dimensions
=================================================================

Visualizes how Möbius transformations — the symmetry group of stereographic
projection — transform geometric patterns. Demonstrates Liouville's theorem:
in dimensions ≥ 3, ALL conformal maps are Möbius transformations.

Oracle Ω's experiment on symmetry and conformal field theory.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

def mobius_2d(z, a, b, c, d):
    """Möbius transformation (az + b)/(cz + d) on complex numbers."""
    return (a * z + b) / (c * z + d)

def inversion_nd(points, center=None, radius=1.0):
    """
    Inversion in an N-dimensional sphere.
    Maps x → center + radius² * (x - center) / ||x - center||²

    This is the fundamental building block of all Möbius transformations.
    """
    if center is None:
        center = np.zeros(points.shape[1])
    diff = points - center
    norms_sq = np.sum(diff**2, axis=1, keepdims=True)
    norms_sq = np.maximum(norms_sq, 1e-12)  # avoid division by zero
    return center + radius**2 * diff / norms_sq

# ─── Create visualization ───

fig = plt.figure(figsize=(20, 16))
gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

# === Panel 1: Möbius transformations of a grid ===
ax1 = fig.add_subplot(gs[0, 0])

# Create a grid in the complex plane
x = np.linspace(-3, 3, 30)
y = np.linspace(-3, 3, 30)

# Draw grid lines
for xi in x:
    z = xi + 1j * y
    w = mobius_2d(z, 1, 1j, 0.3j, 1)
    ax1.plot(w.real, w.imag, 'b-', alpha=0.4, linewidth=0.5)

for yi in y:
    z = x + 1j * yi
    w = mobius_2d(z, 1, 1j, 0.3j, 1)
    ax1.plot(w.real, w.imag, 'r-', alpha=0.4, linewidth=0.5)

ax1.set_xlim(-5, 5)
ax1.set_ylim(-5, 5)
ax1.set_aspect('equal')
ax1.set_title('Möbius Transform of Grid\nf(z) = (z + i)/(0.3iz + 1)', fontsize=13, fontweight='bold')
ax1.grid(True, alpha=0.2)

# === Panel 2: Iterated inversions → fractal ===
ax2 = fig.add_subplot(gs[0, 1])

# Start with a circle and apply multiple inversions
theta = np.linspace(0, 2*np.pi, 500)
circles_to_draw = []

# Initial circles
centers = [
    np.array([1.5, 0]),
    np.array([-1.5, 0]),
    np.array([0, 1.5]),
    np.array([0, -1.5]),
]
radius = 1.0

all_points = []
colors_list = []

for gen in range(5):  # generations
    new_points = []
    for k, center in enumerate(centers):
        pts = np.column_stack([
            center[0] + (radius / (2**gen)) * np.cos(theta),
            center[1] + (radius / (2**gen)) * np.sin(theta)
        ])

        # Apply inversion in unit circle
        inv_pts = inversion_nd(pts, radius=1.5)

        color = plt.cm.Set1(k / len(centers))
        ax2.plot(inv_pts[:, 0], inv_pts[:, 1],
                color=color, alpha=max(0.2, 0.8 - gen*0.15),
                linewidth=max(0.3, 1.5 - gen*0.3))

        # Apply inversion again for fractal effect
        if gen < 3:
            for c2 in centers:
                inv2 = inversion_nd(inv_pts, center=c2 * 0.5, radius=0.8)
                ax2.plot(inv2[:, 0], inv2[:, 1],
                        color=color, alpha=max(0.1, 0.4 - gen*0.1),
                        linewidth=max(0.2, 0.8 - gen*0.2))

# Draw inversion circle
ax2.plot(1.5 * np.cos(theta), 1.5 * np.sin(theta), 'k--', linewidth=1, alpha=0.5)
ax2.set_xlim(-4, 4)
ax2.set_ylim(-4, 4)
ax2.set_aspect('equal')
ax2.set_title('Iterated Inversions\n(Generating Möbius Fractals)', fontsize=13, fontweight='bold')

# === Panel 3: Circle-preserving property ===
ax3 = fig.add_subplot(gs[0, 2])

# Draw original circles
original_circles = [
    (0, 0, 1),
    (0.5, 0.5, 0.3),
    (-0.3, 0.7, 0.4),
    (0.8, -0.2, 0.25),
    (-0.6, -0.5, 0.35),
]

for cx, cy, r in original_circles:
    pts = np.column_stack([cx + r*np.cos(theta), cy + r*np.sin(theta)])
    ax3.plot(pts[:, 0], pts[:, 1], 'b-', alpha=0.4, linewidth=1)

    # Inversion
    inv_pts = inversion_nd(pts, center=np.array([1.2, 0.8]), radius=1.5)
    mask = (np.abs(inv_pts[:, 0]) < 6) & (np.abs(inv_pts[:, 1]) < 6)
    ax3.plot(inv_pts[mask, 0], inv_pts[mask, 1], 'r-', alpha=0.7, linewidth=1.5)

ax3.plot(1.2, 0.8, 'g*', markersize=15, zorder=5, label='Inversion center')
ax3.legend()
ax3.set_xlim(-5, 5)
ax3.set_ylim(-5, 5)
ax3.set_aspect('equal')
ax3.set_title('Circles → Circles\n(blue: original, red: inverted)', fontsize=13, fontweight='bold')
ax3.grid(True, alpha=0.2)

# === Panel 4: Conformal factor visualization ===
ax4 = fig.add_subplot(gs[1, 0])

u_grid = np.linspace(-3, 3, 200)
v_grid = np.linspace(-3, 3, 200)
U, V = np.meshgrid(u_grid, v_grid)

# Conformal factor of stereographic projection
D = 1 + U**2 + V**2
conf_factor = 4 / D**2  # |dσ/dy|² = 4/(1+|y|²)²

im = ax4.pcolormesh(U, V, np.log10(conf_factor), cmap='RdYlBu_r', shading='auto')
plt.colorbar(im, ax=ax4, label='log₁₀(conformal factor)')
ax4.contour(U, V, conf_factor, levels=[0.01, 0.1, 0.5, 1.0, 2.0, 3.0],
           colors='black', linewidths=0.5, alpha=0.5)
ax4.set_aspect('equal')
ax4.set_title('Metric Distortion Map\nlog₁₀(conformal factor of σ⁻¹)',
             fontsize=13, fontweight='bold')

# === Panel 5: Möbius group generators ===
ax5 = fig.add_subplot(gs[1, 1])

z_circle = np.exp(1j * theta)

# Different Möbius transformations
transforms = [
    ("Translation z+1", lambda z: z + 1),
    ("Rotation e^{iπ/4}z", lambda z: np.exp(1j*np.pi/4) * z),
    ("Dilation 2z", lambda z: 2 * z),
    ("Inversion 1/z", lambda z: 1/z),
    ("Generic (z+i)/(iz+1)", lambda z: (z + 1j) / (1j*z + 1)),
]

colors_mob = plt.cm.Set1(np.linspace(0, 1, len(transforms) + 1))

# Draw original circle
ax5.plot(z_circle.real, z_circle.imag, 'k-', linewidth=2, label='Unit circle')

for i, (name, f) in enumerate(transforms):
    w = f(z_circle)
    mask = np.isfinite(w) & (np.abs(w) < 5)
    ax5.plot(w[mask].real, w[mask].imag, '-', color=colors_mob[i+1],
            linewidth=1.5, alpha=0.8, label=name)

ax5.set_xlim(-4, 4)
ax5.set_ylim(-4, 4)
ax5.set_aspect('equal')
ax5.legend(fontsize=8, loc='upper left')
ax5.set_title('Möbius Group Generators\n(acting on the unit circle)', fontsize=13, fontweight='bold')
ax5.grid(True, alpha=0.2)

# === Panel 6: Liouville's theorem illustration ===
ax6 = fig.add_subplot(gs[1, 2])

# In dimension ≥ 3, ALL conformal maps are Möbius
# Illustrate with 3D inversion projected to 2D
text = """
Liouville's Theorem (1850)

In dimensions N ≥ 3, every
conformal diffeomorphism is a
Möbius transformation:

    f = T₁ ∘ I₁ ∘ T₂ ∘ I₂ ∘ ...

where each Tₖ is a translation/
rotation/dilation and each Iₖ is
an inversion in a sphere.

This means:
• Stereographic projection is
  essentially UNIQUE as a
  conformal map S^N → ℝ^N
• The symmetry group of S^N
  (as a conformal manifold) is
  the Möbius group ≅ SO(N+1,1)
• dim(Möbius group) = (N+1)(N+2)/2
"""

dimensions = [2, 3, 4, 5, 10, 100]
mob_dims = [(n+1)*(n+2)//2 for n in dimensions]

ax6_inner = ax6.inset_axes([0.55, 0.15, 0.4, 0.35])
ax6_inner.bar(range(len(dimensions)), mob_dims, color='steelblue', edgecolor='black')
ax6_inner.set_xticks(range(len(dimensions)))
ax6_inner.set_xticklabels([str(d) for d in dimensions], fontsize=8)
ax6_inner.set_xlabel('N', fontsize=8)
ax6_inner.set_ylabel('dim(Möb)', fontsize=8)
ax6_inner.set_title('Möbius group\ndimension', fontsize=9)

ax6.text(0.02, 0.98, text, transform=ax6.transAxes,
        fontsize=11, verticalalignment='top', fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax6.set_xlim(0, 1)
ax6.set_ylim(0, 1)
ax6.axis('off')
ax6.set_title("The Rigidity of Higher Dimensions", fontsize=13, fontweight='bold')

fig.suptitle('Möbius Transformations: The Symmetry Group of Stereographic Projection',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo7_conformal_flow.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 7 saved: demo7_conformal_flow.png")
