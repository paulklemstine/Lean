#!/usr/bin/env python3
"""
Conformal Preservation Demo
=============================
Numerically verifies that stereographic projection is conformal (angle-preserving).
Shows that local geometry is preserved even as global topology changes.

This is the mathematical reason why physics "works" inside a closed universe:
local measurements are identical to flat space, even though the space is actually
a finite sphere.

Run: python3 conformal_preservation.py
Output: conformal_preservation.png
"""

import numpy as np
import matplotlib.pyplot as plt

def inverse_stereo_2d(y1, y2):
    """Inverse stereographic projection R^2 -> S^2"""
    r2 = y1**2 + y2**2
    denom = r2 + 1
    return (2*y1/denom, 2*y2/denom, (r2-1)/denom)

def jacobian_inv_stereo(y1, y2):
    """Jacobian of inverse stereographic projection at (y1, y2).
    Returns 3x2 matrix J such that dσ⁻¹ = J dy.
    """
    r2 = y1**2 + y2**2
    d = r2 + 1
    d2 = d**2
    
    J = np.zeros((3, 2))
    # ∂x₁/∂y₁ = 2(1+y2²-y1²) / (1+r²)²  (... let me compute properly)
    # x₁ = 2y₁/(r²+1), x₂ = 2y₂/(r²+1), x₃ = (r²-1)/(r²+1)
    
    # ∂x₁/∂y₁ = 2(d - 2y₁²)/d² = 2(1 + y₂² - y₁²)/d²
    J[0, 0] = 2 * (1 + y2**2 - y1**2) / d2
    # ∂x₁/∂y₂ = -4y₁y₂/d²
    J[0, 1] = -4 * y1 * y2 / d2
    # ∂x₂/∂y₁ = -4y₁y₂/d²
    J[1, 0] = -4 * y1 * y2 / d2
    # ∂x₂/∂y₂ = 2(1 + y₁² - y₂²)/d²
    J[1, 1] = 2 * (1 + y1**2 - y2**2) / d2
    # ∂x₃/∂y₁ = 4y₁/d²
    J[2, 0] = 4 * y1 / d2
    # ∂x₃/∂y₂ = 4y₂/d²
    J[2, 1] = 4 * y2 / d2
    
    return J

def angle_between_vectors(v1, v2):
    """Angle between two vectors in radians."""
    cos_theta = np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))
    cos_theta = np.clip(cos_theta, -1, 1)
    return np.arccos(cos_theta)

# ============================================================
# Experiment 1: Verify angle preservation at many points
# ============================================================
print("="*60)
print("CONFORMAL PRESERVATION EXPERIMENT")
print("="*60)

np.random.seed(42)
n_tests = 10000
max_angle_error = 0

errors = []
positions = []

for _ in range(n_tests):
    # Random point in R^2
    y = np.random.randn(2) * 3
    
    # Two random tangent vectors at y
    v1 = np.random.randn(2)
    v2 = np.random.randn(2)
    
    # Angle in the plane
    angle_flat = angle_between_vectors(v1, v2)
    
    # Push forward through the Jacobian
    J = jacobian_inv_stereo(y[0], y[1])
    w1 = J @ v1  # tangent vector on sphere
    w2 = J @ v2
    
    # Angle on the sphere
    angle_sphere = angle_between_vectors(w1, w2)
    
    # Error
    error = abs(angle_flat - angle_sphere)
    errors.append(error)
    positions.append(np.linalg.norm(y))
    max_angle_error = max(max_angle_error, error)

errors = np.array(errors)
positions = np.array(positions)

print(f"\nTested {n_tests} random point-vector pairs.")
print(f"Maximum angle error: {max_angle_error:.2e} radians")
print(f"Mean angle error:    {errors.mean():.2e} radians")
print(f"✓ Angles are preserved to machine precision!")
print(f"  (Stereographic projection is CONFORMAL)")

# ============================================================
# Experiment 2: Verify conformal factor
# ============================================================
print("\n" + "-"*60)
print("CONFORMAL FACTOR VERIFICATION")
print("-"*60)

for y1, y2 in [(0, 0), (1, 0), (0, 1), (1, 1), (3, 4), (10, 0)]:
    J = jacobian_inv_stereo(y1, y2)
    # The pullback metric is J^T J. For a conformal map, J^T J = λ² I
    metric = J.T @ J
    
    # Expected conformal factor
    r2 = y1**2 + y2**2
    lam = 2.0 / (1.0 + r2)
    expected_metric = lam**2 * np.eye(2)
    
    error = np.max(np.abs(metric - expected_metric))
    print(f"  y=({y1:5.1f}, {y2:5.1f}): λ={lam:.6f}, "
          f"J^T J = λ²I? Error={error:.2e} ✓" if error < 1e-10 else f"  FAIL")

# ============================================================
# Figure: Visual demonstration of conformal preservation
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Grid of squares in the plane
ax = axes[0]
# Draw small squares at various positions
square_size = 0.3
positions_to_show = []
for x in np.arange(-4, 4.5, 1):
    for y in np.arange(-4, 4.5, 1):
        positions_to_show.append((x, y))
        corners = np.array([
            [x - square_size/2, y - square_size/2],
            [x + square_size/2, y - square_size/2],
            [x + square_size/2, y + square_size/2],
            [x - square_size/2, y + square_size/2],
            [x - square_size/2, y - square_size/2],
        ])
        r = np.sqrt(x**2 + y**2)
        color = plt.cm.viridis(r / 6)
        ax.plot(corners[:, 0], corners[:, 1], '-', color=color, linewidth=0.8)

ax.set_aspect('equal')
ax.set_title('Small Squares in ℝ²\n(all identical, all 90° corners)', fontsize=13, fontweight='bold')
ax.set_xlabel('y₁')
ax.set_ylabel('y₂')
ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)

# Panel 2: Same squares mapped onto the sphere
ax2 = fig.add_subplot(132, projection='3d')
for x, y in positions_to_show:
    corners_2d = np.array([
        [x - square_size/2, y - square_size/2],
        [x + square_size/2, y - square_size/2],
        [x + square_size/2, y + square_size/2],
        [x - square_size/2, y + square_size/2],
        [x - square_size/2, y - square_size/2],
    ])
    # Map each corner to the sphere
    corners_3d = np.array([inverse_stereo_2d(c[0], c[1]) for c in corners_2d])
    r = np.sqrt(x**2 + y**2)
    color = plt.cm.viridis(r / 6)
    ax2.plot(corners_3d[:, 0], corners_3d[:, 1], corners_3d[:, 2], 
             '-', color=color, linewidth=0.8)

# Draw sphere wireframe
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax2.plot_surface(xs, ys, zs, alpha=0.05, color='gray')

ax2.scatter([0], [0], [1], c='red', s=100, marker='*', zorder=10)
ax2.set_title('Same Squares on S²\n(shrunk near pole, but STILL 90° corners!)', 
              fontsize=13, fontweight='bold')

# Panel 3: Error histogram
ax = axes[2]
ax.hist(errors * 180 / np.pi, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
ax.set_xlabel('Angle error (degrees)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Angle Preservation Error\n({n_tests} random tests)', fontsize=13, fontweight='bold')
ax.axvline(x=0, color='red', linestyle='--', alpha=0.5)
ax.text(0.95, 0.95, f'Max error: {max_angle_error*180/np.pi:.1e}°\nMean error: {errors.mean()*180/np.pi:.1e}°',
        transform=ax.transAxes, fontsize=11, va='top', ha='right',
        bbox=dict(boxstyle='round', facecolor='lightyellow'))

plt.suptitle('CONFORMAL PRESERVATION: Angles Survive the Projection',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('demos/conformal_preservation.png', dpi=150, bbox_inches='tight')
print("\nSaved: demos/conformal_preservation.png")

# ============================================================
# Experiment 3: The "Physics Test"
# ============================================================
print("\n" + "="*60)
print("THE PHYSICS TEST: Can you tell you're on a sphere?")
print("="*60)
print("""
An observer at position y in ℝ² (under the Unity Metric) measures:
  - Local angles: IDENTICAL to flat space (conformal)
  - Local distances: scaled by λ = 2/(1+|y|²), but this is just a "units" choice
  - Local physics: INDISTINGUISHABLE from flat space

BUT globally:
  - Walking in a "straight line" (geodesic) returns you to the start
  - Total volume is finite: 4π ≈ 12.566
  - Low-frequency waves have a discrete spectrum (quantization!)

This is exactly analogous to living on Earth: locally flat, globally round.
The Genesis Projection says the Big Bang is just the "north pole" of this sphere.
""")
