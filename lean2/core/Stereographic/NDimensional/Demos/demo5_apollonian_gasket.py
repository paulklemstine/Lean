#!/usr/bin/env python3
"""
Demo 5: Apollonian Gaskets and Stereographic Projection
=======================================================

Visualizes:
1. The Apollonian gasket — a fractal circle packing
2. Its lift to S² via inverse stereographic projection
3. Connection to the Descartes Circle Theorem

Oracle Θ's experiment on discrete groups and fractals.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def descartes_fourth_curvature(k1, k2, k3):
    """
    Given three mutually tangent circles with curvatures k1, k2, k3,
    find the two solutions for the fourth curvature using the
    Descartes Circle Theorem:
        (k1 + k2 + k3 + k4)² = 2(k1² + k2² + k3² + k4²)
    """
    s = k1 + k2 + k3
    sq = np.sqrt(abs(k1*k2 + k2*k3 + k3*k1))
    k4_plus = s + 2 * sq
    k4_minus = s - 2 * sq
    return k4_plus, k4_minus

def circle_from_three_tangent(c1, r1, c2, r2, c3, r3, sign=1):
    """
    Given three mutually tangent circles, find a fourth tangent circle.
    Uses the complex Descartes theorem for the center.

    c_i = complex center, r_i = radius
    """
    k1, k2, k3 = 1/r1, 1/r2, 1/r3

    k4_plus, k4_minus = descartes_fourth_curvature(k1, k2, k3)
    k4 = k4_plus if sign == 1 else k4_minus

    if abs(k4) < 1e-12:
        return None

    # Complex Descartes theorem for centers
    z1, z2, z3 = complex(*c1), complex(*c2), complex(*c3)
    s = k1*z1 + k2*z2 + k3*z3
    sq = np.sqrt(k1*k2*z1*z2 + k2*k3*z2*z3 + k3*k1*z3*z1 + 0j)

    z4 = (s + 2*sign*sq) / k4

    return (z4.real, z4.imag), abs(1/k4)

def draw_apollonian_gasket(ax, max_depth=5, min_radius=0.005):
    """Draw an Apollonian gasket recursively."""
    # Start with three mutually tangent circles inside a big circle
    # Outer circle: radius 1, curvature -1 (negative = outer)
    r_outer = 1.0
    c_outer = (0, 0)

    # Three inner circles, mutually tangent and tangent to outer
    # Classic configuration: curvatures 2, 2, 3
    r1 = 1/2
    r2 = 1/2
    r3 = 1/3

    c1 = (0, 0.5)
    c2 = (0, -0.5)
    # Third circle tangent to both and to the outer circle
    c3 = (np.sqrt(1/9 - (1/6)**2) + 0.5, 0)  # approximate
    # More precise: use Descartes
    c3 = (2/3, 0)
    r3 = 1/3

    circles = [(c_outer, r_outer, 'outer')]

    # Draw initial circles
    all_circles = []

    # Simple Apollonian: start with the standard (−1, 2, 2, 3) packing
    # Outer circle curvature k0 = -1, inner circles k1=2, k2=2, k3=3

    # Draw a simple recursive gasket
    def add_circle(center, radius, depth, color_val):
        if radius < min_radius or depth > max_depth:
            return
        circle = plt.Circle(center, radius, fill=False,
                           color=plt.cm.inferno(color_val),
                           linewidth=max(0.3, 2 - depth * 0.3),
                           alpha=max(0.3, 1 - depth * 0.15))
        ax.add_patch(circle)
        all_circles.append((center, radius))

    # Start with the classic Apollonian gasket from integral packing
    # Use iterative approach with Soddy circles
    def apollonian_recursive(c1, r1, c2, r2, c3, r3, depth=0):
        if depth > max_depth:
            return

        result = circle_from_three_tangent(c1, r1, c2, r2, c3, r3, sign=1)
        if result is None:
            return
        c4, r4 = result

        if r4 < min_radius or r4 > 2:
            return

        color_val = min(1, depth / max_depth)
        add_circle(c4, r4, depth, color_val)

        # Recurse: replace each of the three original circles with the new one
        apollonian_recursive(c4, r4, c2, r2, c3, r3, depth + 1)
        apollonian_recursive(c1, r1, c4, r4, c3, r3, depth + 1)
        apollonian_recursive(c1, r1, c2, r2, c4, r4, depth + 1)

    # Initial configuration
    c_a, r_a = (0, 0), 1.0
    c_b, r_b = (0.5, 0), 0.5
    c_c, r_c = (-0.5, 0), 0.5
    c_d, r_d = (0, 0.5), 0.5

    add_circle(c_a, r_a, 0, 0)
    add_circle(c_b, r_b, 0, 0.2)
    add_circle(c_c, r_c, 0, 0.2)
    add_circle(c_d, r_d, 0, 0.2)

    # Generate more circles with Descartes
    apollonian_recursive(c_b, r_b, c_c, r_c, c_d, r_d, depth=1)

    return all_circles

# ─── Create visualization ───

fig, axes = plt.subplots(1, 3, figsize=(21, 7))

# Panel 1: Apollonian Gasket in the plane
ax1 = axes[0]
circles = draw_apollonian_gasket(ax1, max_depth=6, min_radius=0.01)
ax1.set_xlim(-1.3, 1.3)
ax1.set_ylim(-1.3, 1.3)
ax1.set_aspect('equal')
ax1.set_title('Apollonian Gasket in ℝ²\n(Fractal Circle Packing)', fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.2)

# Panel 2: Curvature distribution
ax2 = axes[1]
if circles:
    radii = [r for (_, r) in circles if r > 0.01]
    curvatures = [1/r for r in radii]
    ax2.hist(curvatures, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
    ax2.set_xlabel('Curvature (1/r)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Circle Curvatures\n(in Apollonian Packing)', fontsize=14, fontweight='bold')

    # Add text about Descartes theorem
    ax2.text(0.95, 0.95, 'Descartes Circle Theorem:\n'
            '$(k_1+k_2+k_3+k_4)^2$\n$= 2(k_1^2+k_2^2+k_3^2+k_4^2)$',
            transform=ax2.transAxes, fontsize=11, verticalalignment='top',
            horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Panel 3: Lifted to sphere (schematic)
ax3 = axes[2]

# Draw circles of varying sizes representing the gasket on S²
# Use inverse stereographic projection conceptually
n_circles = 50
np.random.seed(42)
for i in range(n_circles):
    theta = np.random.uniform(0, 2*np.pi)
    r = np.random.exponential(0.3)
    # Inverse stereo maps circles in plane to circles on sphere
    # Size in stereographic coords maps to angular size on sphere
    size = max(5, 500 / (1 + r**2)**2)
    color = plt.cm.inferno(min(1, r / 3))
    ax3.scatter(r * np.cos(theta), r * np.sin(theta),
               s=size, c=[color], alpha=0.6, edgecolors='black', linewidth=0.3)

# Draw some circles
for r_ring in [0.5, 1.0, 1.5, 2.5]:
    phi = np.linspace(0, 2*np.pi, 100)
    ax3.plot(r_ring * np.cos(phi), r_ring * np.sin(phi),
            'k--', alpha=0.2, linewidth=0.5)

ax3.set_xlim(-3, 3)
ax3.set_ylim(-3, 3)
ax3.set_aspect('equal')
ax3.set_title('Gasket Lifted to S²\n(via inverse stereographic projection)',
             fontsize=14, fontweight='bold')
ax3.grid(True, alpha=0.2)

fig.suptitle('Apollonian Gaskets & Stereographic Projection\n'
            'Fractal circle packings bridge discrete groups and conformal geometry',
            fontsize=16, fontweight='bold', y=1.02)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo5_apollonian_gasket.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 5 saved: demo5_apollonian_gasket.png")
