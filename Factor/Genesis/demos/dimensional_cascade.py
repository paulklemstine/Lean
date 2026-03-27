#!/usr/bin/env python3
"""
Dimensional Cascade Demo
=========================
Visualizes the Dimensional Cascade: how dimensions emerge one by one
from a single point through iterated inverse stereographic projection.

Stage 0: {1}     — a single point (Unity)
Stage 1: S⁰      — two points {-1, +1} (Duality)
Stage 2: S¹      — the circle (Cycle)
Stage 3: S²      — the sphere (Surface)
Stage 4: S³      — the 3-sphere (Space) [shown via Hopf fibration slices]

Run: python3 dimensional_cascade.py
Output: dimensional_cascade.png
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def inverse_stereo(y_coords):
    """General inverse stereographic projection.
    y_coords: array of shape (..., n) — points in R^n
    Returns: array of shape (..., n+1) — points on S^n
    """
    r2 = np.sum(y_coords**2, axis=-1, keepdims=True)
    denom = r2 + 1
    spatial = 2 * y_coords / denom
    height = (r2 - 1) / denom
    return np.concatenate([spatial, height], axis=-1)

fig = plt.figure(figsize=(20, 12))

# ============================================================
# Stage 0: Unity — A single point
# ============================================================
ax0 = fig.add_subplot(231)
ax0.scatter([0], [0], s=300, c='gold', edgecolors='black', linewidth=2, zorder=5)
ax0.annotate('1', (0.05, 0.05), fontsize=20, fontweight='bold', color='darkgoldenrod')
ax0.set_xlim(-1, 1)
ax0.set_ylim(-1, 1)
ax0.set_aspect('equal')
ax0.set_title('Stage 0: UNITY\n{1} — One point', fontsize=14, fontweight='bold')
ax0.text(0, -0.5, '"In the beginning\nwas the One"', fontsize=10, 
         ha='center', style='italic', color='gray')
ax0.axis('off')

# ============================================================
# Stage 1: Duality — S⁰ = {-1, +1}
# ============================================================
ax1 = fig.add_subplot(232)
ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.scatter([-1, 1], [0, 0], s=300, c=['blue', 'red'], edgecolors='black', 
            linewidth=2, zorder=5)
ax1.annotate('-1', (-1, 0.1), fontsize=16, fontweight='bold', ha='center', color='blue')
ax1.annotate('+1', (1, 0.1), fontsize=16, fontweight='bold', ha='center', color='red')
# Arrow showing the "split"
ax1.annotate('', xy=(-0.5, 0), xytext=(0, 0.3),
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax1.annotate('', xy=(0.5, 0), xytext=(0, 0.3),
            arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax1.scatter([0], [0.3], s=100, c='gold', edgecolors='black', linewidth=1.5, zorder=5)
ax1.set_xlim(-2, 2)
ax1.set_ylim(-0.5, 1)
ax1.set_aspect('equal')
ax1.set_title('Stage 1: DUALITY\nS⁰ = {-1, +1}', fontsize=14, fontweight='bold')
ax1.text(0, -0.35, 'First symmetry breaking:\nopposites emerge', fontsize=10, 
         ha='center', style='italic', color='gray')
ax1.axis('off')

# ============================================================
# Stage 2: The Circle — S¹
# ============================================================
ax2 = fig.add_subplot(233)
theta = np.linspace(0, 2*np.pi, 300)
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Color the circle by "origin" — where each point came from on the real line
y_line = np.linspace(-20, 20, 300)
x1, x2 = [], []
for y in y_line:
    r2 = y**2
    x1.append(2*y / (r2 + 1))
    x2.append((r2 - 1) / (r2 + 1))
scatter = ax2.scatter(x1, x2, c=y_line, cmap='coolwarm', s=8, zorder=3)
plt.colorbar(scatter, ax=ax2, label='Origin on ℝ¹', shrink=0.7)

# Mark special points
ax2.scatter([0], [-1], c='gold', s=200, marker='o', edgecolors='black', 
            linewidth=2, zorder=10, label='South Pole (y=0)')
ax2.scatter([0], [1], c='red', s=200, marker='*', edgecolors='black', 
            linewidth=1, zorder=10, label='North Pole (y=∞)')
ax2.legend(loc='lower right', fontsize=8)
ax2.set_aspect('equal')
ax2.set_title('Stage 2: THE CIRCLE\nS¹ — ℝ¹ ∪ {∞}', fontsize=14, fontweight='bold')
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)

# ============================================================
# Stage 3: The Sphere — S²
# ============================================================
ax3 = fig.add_subplot(234, projection='3d')

# Draw the sphere wireframe
u = np.linspace(0, 2 * np.pi, 50)
v = np.linspace(0, np.pi, 30)
x_sphere = np.outer(np.cos(u), np.sin(v))
y_sphere = np.outer(np.sin(u), np.sin(v))
z_sphere = np.outer(np.ones_like(u), np.cos(v))
ax3.plot_surface(x_sphere, y_sphere, z_sphere, alpha=0.1, color='cyan')

# Map a grid from R^2 onto S^2
grid_vals = np.linspace(-5, 5, 15)
t = np.linspace(-10, 10, 200)
for g in grid_vals:
    y = np.stack([np.full_like(t, g), t], axis=-1)
    pts = inverse_stereo(y)
    color = plt.cm.coolwarm((g + 5) / 10)
    ax3.plot(pts[:, 0], pts[:, 1], pts[:, 2], color=color, alpha=0.4, linewidth=0.5)
    
    y2 = np.stack([t, np.full_like(t, g)], axis=-1)
    pts2 = inverse_stereo(y2)
    ax3.plot(pts2[:, 0], pts2[:, 1], pts2[:, 2], color=color, alpha=0.4, linewidth=0.5)

# Mark poles
ax3.scatter([0], [0], [1], c='red', s=200, marker='*', zorder=10)
ax3.scatter([0], [0], [-1], c='gold', s=200, marker='o', zorder=10)
ax3.text(0, 0, 1.2, 'Big Bang\n(∞)', fontsize=9, color='red', ha='center')

ax3.set_title('Stage 3: THE SPHERE\nS² — ℝ² ∪ {∞}', fontsize=14, fontweight='bold')
ax3.set_xlabel('x₁')
ax3.set_ylabel('x₂')
ax3.set_zlabel('x₃')

# ============================================================
# Stage 4: The 3-Sphere — S³ (shown via cross-sections)
# ============================================================
ax4 = fig.add_subplot(235, projection='3d')

# S³ ⊂ R⁴ can't be directly visualized. 
# We show "slices" — for fixed x₄, we get spheres of varying radii
# S³: x₁² + x₂² + x₃² + x₄² = 1
# For fixed x₄ = c, we get x₁² + x₂² + x₃² = 1 - c²

for c in np.linspace(-0.9, 0.9, 10):
    radius = np.sqrt(1 - c**2)
    u = np.linspace(0, 2*np.pi, 40)
    v = np.linspace(0, np.pi, 20)
    xs = radius * np.outer(np.cos(u), np.sin(v))
    ys = radius * np.outer(np.sin(u), np.sin(v))
    zs = radius * np.outer(np.ones_like(u), np.cos(v))
    alpha_val = 0.05 + 0.1 * (1 - abs(c))
    color = plt.cm.viridis((c + 1) / 2)
    ax4.plot_wireframe(xs, ys, zs, alpha=alpha_val, color=color, linewidth=0.3)

ax4.set_title('Stage 4: THE 3-SPHERE\nS³ — ℝ³ ∪ {∞}\n(shown as nested spherical slices)', 
              fontsize=14, fontweight='bold')
ax4.set_xlabel('x₁')
ax4.set_ylabel('x₂')
ax4.set_zlabel('x₃')
ax4.text2D(0.5, -0.05, 'Each shell is a slice at fixed x₄\nColor = x₄ value', 
           fontsize=9, ha='center', transform=ax4.transAxes, color='gray')

# ============================================================
# Stage ∞: The pattern
# ============================================================
ax5 = fig.add_subplot(236)
ax5.axis('off')

stages = [
    ("Stage 0", "{1}", "Unity", "1 point", "gold"),
    ("Stage 1", "S⁰", "Duality", "2 points", "orange"),
    ("Stage 2", "S¹", "Circle", "1-manifold", "green"),
    ("Stage 3", "S²", "Sphere", "2-manifold", "cyan"),
    ("Stage 4", "S³", "3-Sphere", "3-manifold\n(Our Universe?)", "blue"),
    ("Stage n", "Sⁿ", "n-Sphere", "n-manifold", "purple"),
]

for i, (stage, obj, name, desc, color) in enumerate(stages):
    y_pos = 0.9 - i * 0.15
    ax5.add_patch(plt.Circle((0.08, y_pos), 0.03, color=color, transform=ax5.transAxes))
    ax5.text(0.15, y_pos, f'{stage}:', fontsize=12, fontweight='bold', 
             transform=ax5.transAxes, va='center')
    ax5.text(0.35, y_pos, f'{obj}  ({name})', fontsize=12, 
             transform=ax5.transAxes, va='center')
    ax5.text(0.7, y_pos, desc, fontsize=10, color='gray',
             transform=ax5.transAxes, va='center')
    if i < len(stages) - 1:
        ax5.annotate('', xy=(0.08, y_pos - 0.06), xytext=(0.08, y_pos - 0.02),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=1.5),
                     transform=ax5.transAxes)

ax5.text(0.5, 0.02, 'Each stage: ℝⁿ  →  ℝⁿ ∪ {∞}  ≅  Sⁿ\n'
         'The "Big Bang" is always the added point at ∞',
         fontsize=11, ha='center', transform=ax5.transAxes,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

ax5.set_title('THE DIMENSIONAL CASCADE', fontsize=14, fontweight='bold')

plt.suptitle('THE DIMENSIONAL CASCADE: From Unity to Universe',
             fontsize=18, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('demos/dimensional_cascade.png', dpi=150, bbox_inches='tight')
print("Saved: demos/dimensional_cascade.png")
print("\nThe Dimensional Cascade:")
print("  {1} → S⁰ → S¹ → S² → S³ → ⋯")
print("  One point generates all of geometry.")
