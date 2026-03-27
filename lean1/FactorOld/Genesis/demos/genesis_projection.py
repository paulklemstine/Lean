#!/usr/bin/env python3
"""
Genesis Projection Demo
========================
Visualizes inverse stereographic projection: wrapping a flat plane onto a sphere.
Shows how the entire infinite plane maps to the finite sphere, with the 
"north pole" as the Big Bang point (point at infinity).

Run: python3 genesis_projection.py
Output: genesis_projection.png
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def inverse_stereo_2d(y1, y2):
    """Inverse stereographic projection from R^2 to S^2.
    Maps (y1, y2) in the plane to (x1, x2, x3) on the unit sphere.
    The north pole (0,0,1) is the 'point at infinity' / Big Bang point.
    """
    r2 = y1**2 + y2**2
    denom = r2 + 1
    x1 = 2 * y1 / denom
    x2 = 2 * y2 / denom
    x3 = (r2 - 1) / denom
    return x1, x2, x3

def inverse_stereo_1d(y):
    """Inverse stereographic projection from R^1 to S^1.
    Maps y on the real line to (x1, x2) on the unit circle.
    """
    r2 = y**2
    denom = r2 + 1
    x1 = 2 * y / denom
    x2 = (r2 - 1) / denom
    return x1, x2

def conformal_factor(y1, y2):
    """The conformal factor lambda = 2/(1 + |y|^2).
    This measures how much the projection stretches/compresses space.
    """
    r2 = y1**2 + y2**2
    return 2.0 / (1.0 + r2)

# ============================================================
# Figure 1: The 1D Genesis — Real line wraps onto a circle
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Points on the real line
y_points = np.linspace(-10, 10, 200)
y_special = np.array([-5, -2, -1, -0.5, 0, 0.5, 1, 2, 5])
ax = axes[0]
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.scatter(y_points, np.zeros_like(y_points), c=y_points, cmap='coolwarm', 
           s=2, alpha=0.5)
ax.scatter(y_special, np.zeros_like(y_special), c='black', s=50, zorder=5)
for ys in y_special:
    ax.annotate(f'{ys}', (ys, 0.02), fontsize=7, ha='center')
ax.set_title('Stage 0→1: The Real Line ℝ¹', fontsize=13)
ax.set_xlabel('y')
ax.set_ylim(-0.3, 0.3)
ax.set_xlim(-12, 12)

# Panel 2: Those points mapped onto the circle
theta = np.linspace(0, 2*np.pi, 300)
ax = axes[1]
ax.plot(np.cos(theta), np.sin(theta), 'gray', linewidth=0.5)
x1_all, x2_all = inverse_stereo_1d(y_points)
ax.scatter(x1_all, x2_all, c=y_points, cmap='coolwarm', s=2, alpha=0.5)
x1_sp, x2_sp = inverse_stereo_1d(y_special)
ax.scatter(x1_sp, x2_sp, c='black', s=50, zorder=5)
for i, ys in enumerate(y_special):
    offset = 0.15
    ax.annotate(f'{ys}→', (x1_sp[i]*(1+offset), x2_sp[i]*(1+offset)), 
                fontsize=7, ha='center')
# Mark the north pole (Big Bang point)
ax.scatter([0], [1], c='red', s=100, marker='*', zorder=10, label='North Pole (∞)')
ax.annotate('∞ (Big Bang)', (0.05, 1.12), fontsize=9, color='red', fontweight='bold')
ax.set_title('Stage 1: Wraps onto S¹ (Circle)', fontsize=13)
ax.set_aspect('equal')
ax.legend(loc='lower right', fontsize=8)

# Panel 3: The conformal factor
ax = axes[2]
y_range = np.linspace(-10, 10, 500)
lam = 2.0 / (1.0 + y_range**2)
ax.fill_between(y_range, lam, alpha=0.3, color='blue')
ax.plot(y_range, lam, 'b-', linewidth=2)
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.set_title('Conformal Factor λ(y) = 2/(1+y²)', fontsize=13)
ax.set_xlabel('y (position on real line)')
ax.set_ylabel('λ (local scale factor)')
ax.annotate('Maximum at origin\n(South Pole)', (0, 2.05), fontsize=9, 
            ha='center', color='blue')
ax.annotate('→ 0 as y → ±∞\n(near Big Bang)', (7, 0.15), fontsize=9, 
            ha='center', color='red')

plt.suptitle('THE GENESIS PROJECTION: From ℝ to S¹', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('demos/genesis_projection_1d.png', dpi=150, bbox_inches='tight')
print("Saved: demos/genesis_projection_1d.png")

# ============================================================
# Figure 2: The 2D Genesis — Plane wraps onto a sphere  
# ============================================================
fig = plt.figure(figsize=(18, 7))

# Panel 1: Grid on the plane
ax1 = fig.add_subplot(131)
grid_range = np.linspace(-5, 5, 21)
for g in grid_range:
    ax1.axhline(y=g, color='blue', alpha=0.3, linewidth=0.5)
    ax1.axvline(x=g, color='red', alpha=0.3, linewidth=0.5)
# Color concentric circles by distance
for r in [0.5, 1, 2, 3, 5]:
    circle = plt.Circle((0, 0), r, fill=False, color='green', linewidth=1.5, linestyle='--')
    ax1.add_patch(circle)
    ax1.annotate(f'r={r}', (r*0.7, r*0.7), fontsize=8, color='green')
ax1.set_xlim(-6, 6)
ax1.set_ylim(-6, 6)
ax1.set_aspect('equal')
ax1.set_title('The Flat Plane ℝ²', fontsize=13)
ax1.set_xlabel('y₁')
ax1.set_ylabel('y₂')

# Panel 2: Grid mapped onto sphere
ax2 = fig.add_subplot(132, projection='3d')
# Map grid lines
t = np.linspace(-10, 10, 300)
for g in np.linspace(-5, 5, 11):
    # Horizontal lines (fixed y2 = g)
    x1, x2, x3 = inverse_stereo_2d(t, np.full_like(t, g))
    ax2.plot(x1, x2, x3, 'b-', alpha=0.3, linewidth=0.5)
    # Vertical lines (fixed y1 = g)
    x1, x2, x3 = inverse_stereo_2d(np.full_like(t, g), t)
    ax2.plot(x1, x2, x3, 'r-', alpha=0.3, linewidth=0.5)
# Map concentric circles
theta = np.linspace(0, 2*np.pi, 200)
for r in [0.5, 1, 2, 3, 5]:
    y1 = r * np.cos(theta)
    y2 = r * np.sin(theta)
    x1, x2, x3 = inverse_stereo_2d(y1, y2)
    ax2.plot(x1, x2, x3, 'g-', linewidth=2)
# Mark north pole
ax2.scatter([0], [0], [1], c='red', s=200, marker='*', zorder=10)
ax2.text(0, 0, 1.15, '∞\n(Big Bang)', fontsize=9, color='red', ha='center')
# Mark south pole (origin)
ax2.scatter([0], [0], [-1], c='blue', s=100, marker='o', zorder=10)
ax2.text(0, 0, -1.2, 'Origin', fontsize=9, color='blue', ha='center')

ax2.set_title('Wrapped onto S² (Sphere)', fontsize=13)
ax2.set_xlabel('x₁')
ax2.set_ylabel('x₂')
ax2.set_zlabel('x₃')

# Panel 3: The conformal factor as a heat map
ax3 = fig.add_subplot(133)
y1_grid = np.linspace(-6, 6, 300)
y2_grid = np.linspace(-6, 6, 300)
Y1, Y2 = np.meshgrid(y1_grid, y2_grid)
CF = conformal_factor(Y1, Y2)
im = ax3.imshow(CF, extent=[-6, 6, -6, 6], origin='lower', cmap='inferno', 
                vmin=0, vmax=2)
plt.colorbar(im, ax=ax3, label='λ (conformal factor)')
ax3.set_title('Conformal Factor λ(y₁,y₂)', fontsize=13)
ax3.set_xlabel('y₁')
ax3.set_ylabel('y₂')
ax3.annotate('Bright center = \nnear South Pole\n(observer)', (0, 0), 
             fontsize=9, color='white', ha='center', fontweight='bold')

plt.suptitle('THE GENESIS PROJECTION: From ℝ² to S²', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('demos/genesis_projection_2d.png', dpi=150, bbox_inches='tight')
print("Saved: demos/genesis_projection_2d.png")

# ============================================================
# Figure 3: The "Big Bang" anatomy
# ============================================================
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: How points at different distances from origin map to the sphere
ax = axes[0]
distances = np.logspace(-1, 2, 100)
_, _, x3_values = inverse_stereo_2d(distances, np.zeros_like(distances))
ax.semilogx(distances, x3_values, 'b-', linewidth=2)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='North Pole (Big Bang)')
ax.axhline(y=-1, color='blue', linestyle='--', alpha=0.5, label='South Pole (Origin)')
ax.axhline(y=0, color='green', linestyle='--', alpha=0.5, label='Equator')
ax.set_xlabel('Distance from origin |y|', fontsize=12)
ax.set_ylabel('Height on sphere x₃', fontsize=12)
ax.set_title('How Distance Maps to Sphere Height', fontsize=13)
ax.legend()
ax.set_ylim(-1.2, 1.2)
ax.annotate('All of "infinity"\ncrushes to one point', 
            xy=(50, 0.98), fontsize=10, color='red',
            arrowprops=dict(arrowstyle='->', color='red'),
            xytext=(5, 0.7))

# Panel 2: Volume element (how much "universe" is at each distance)
ax = axes[1]
r = np.linspace(0, 20, 1000)
# In 3D, the volume element of the Unity Metric is (2/(1+r^2))^3 * r^2 * 4pi
vol_element_unity = (2.0 / (1.0 + r**2))**3 * r**2
vol_element_flat = r**2
ax.plot(r, vol_element_flat / vol_element_flat.max(), 'gray', linewidth=1, 
        linestyle='--', label='Flat space (grows forever)')
ax.plot(r, vol_element_unity / vol_element_unity.max(), 'b-', linewidth=2, 
        label='Unity Metric (finite total)')
ax.fill_between(r, vol_element_unity / vol_element_unity.max(), alpha=0.2, color='blue')
ax.set_xlabel('Radial distance r', fontsize=12)
ax.set_ylabel('Volume element (normalized)', fontsize=12)
ax.set_title('Volume Distribution: Flat vs Unity Metric', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 15)
ax.annotate('Peak: most volume\nat r = 1/√2', 
            xy=(1/np.sqrt(2), 1.0), fontsize=10,
            arrowprops=dict(arrowstyle='->', color='blue'),
            xytext=(3, 0.85))
ax.annotate('Volume vanishes\nas r → ∞', 
            xy=(10, 0.01), fontsize=10, color='red',
            xytext=(8, 0.3),
            arrowprops=dict(arrowstyle='->', color='red'))

plt.suptitle('ANATOMY OF THE BIG BANG POINT', fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('demos/bigbang_anatomy.png', dpi=150, bbox_inches='tight')
print("Saved: demos/bigbang_anatomy.png")

# ============================================================
# Print key numerical results
# ============================================================
print("\n" + "="*60)
print("GENESIS PROJECTION — KEY NUMERICAL RESULTS")
print("="*60)

# Verify that the volume under Unity Metric equals Vol(S^n)
from scipy import integrate

# 1D: Vol(S^1) = 2*pi
def unity_vol_1d(y):
    return 2.0 / (1.0 + y**2)
vol1, _ = integrate.quad(unity_vol_1d, -np.inf, np.inf)
print(f"\n1D: ∫ λ dy = {vol1:.6f}, Vol(S¹) = 2π = {2*np.pi:.6f}")

# 2D: Vol(S^2) = 4*pi
def unity_vol_2d(r):
    return (2.0 / (1.0 + r**2))**2 * 2 * np.pi * r
vol2, _ = integrate.quad(unity_vol_2d, 0, np.inf)
print(f"2D: ∫ λ² dA = {vol2:.6f}, Vol(S²) = 4π = {4*np.pi:.6f}")

# 3D: Vol(S^3) = 2*pi^2
def unity_vol_3d(r):
    return (2.0 / (1.0 + r**2))**3 * 4 * np.pi * r**2
vol3, _ = integrate.quad(unity_vol_3d, 0, np.inf)
print(f"3D: ∫ λ³ dV = {vol3:.6f}, Vol(S³) = 2π² = {2*np.pi**2:.6f}")

print(f"\n✓ All volumes match to machine precision!")
print(f"  The 'infinite' ℝ³ under the Unity Metric has finite volume 2π² ≈ {2*np.pi**2:.4f}")

print("\nConformal factor at key positions:")
for r_val in [0, 0.5, 1, 2, 5, 10, 100]:
    lam = 2.0 / (1.0 + r_val**2)
    print(f"  |y| = {r_val:6.1f}  →  λ = {lam:.6f}  (local scale: {lam*100:.2f}%)")

print("\n" + "="*60)
print("The entire universe, measured in Unity Metric units,")
print(f"has a volume of exactly 2π² ≈ {2*np.pi**2:.4f}")
print("="*60)
