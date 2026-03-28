#!/usr/bin/env python3
"""
Omega Point Visualization — Inverse Stereographic Projection

Demonstrates that the inverse stereographic projection maps t → ±∞ to the
north pole (0, 1) of S¹: the "Omega Point."

Run: python3 omega_point_visualization.py
Outputs: omega_point.png
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

def inv_stereo_x(t):
    """x-coordinate: 2t / (t² + 1)"""
    return 2 * t / (t**2 + 1)

def inv_stereo_y(t):
    """y-coordinate: (t² - 1) / (t² + 1)"""
    return (t**2 - 1) / (t**2 + 1)

# ─── Figure 1: The Circle and Convergence ────────────────────────────
fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('The Omega Point Theorem: Infinity Maps to the North Pole',
             fontsize=16, fontweight='bold', y=1.02)

# Panel 1: Points on the circle colored by parameter t
ax1 = axes[0]
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)

t_vals = np.linspace(-20, 20, 200)
x_vals = inv_stereo_x(t_vals)
y_vals = inv_stereo_y(t_vals)

scatter = ax1.scatter(x_vals, y_vals, c=np.abs(t_vals), cmap='magma_r',
                      s=15, zorder=3, vmin=0, vmax=20)
plt.colorbar(scatter, ax=ax1, label='|t| (parameter value)')

# Mark the Omega Point
ax1.plot(0, 1, 'r*', markersize=20, zorder=5, label='Ω = (0, 1)')
ax1.annotate('Omega Point\n(North Pole)', xy=(0, 1), xytext=(0.4, 0.6),
             fontsize=11, fontweight='bold', color='red',
             arrowprops=dict(arrowstyle='->', color='red', lw=2))

# Mark a few specific oracle levels
for n in [0, 1, 2, 5, 10]:
    xn, yn = inv_stereo_x(n), inv_stereo_y(n)
    ax1.plot(xn, yn, 'bo', markersize=8, zorder=4)
    ax1.annotate(f'n={n}', xy=(xn, yn), fontsize=8,
                 xytext=(5, -10), textcoords='offset points')

ax1.set_xlim(-1.3, 1.3)
ax1.set_ylim(-1.3, 1.3)
ax1.set_aspect('equal')
ax1.set_title('Inverse Stereo: ℝ → S¹\nOracle Levels Approach Ω', fontsize=12)
ax1.legend(loc='lower left')
ax1.grid(True, alpha=0.3)

# Panel 2: x(t) and y(t) as functions of t
ax2 = axes[1]
t_range = np.linspace(-15, 15, 500)
ax2.plot(t_range, inv_stereo_x(t_range), 'b-', linewidth=2, label='x(t) = 2t/(t²+1)')
ax2.plot(t_range, inv_stereo_y(t_range), 'r-', linewidth=2, label='y(t) = (t²−1)/(t²+1)')
ax2.axhline(y=0, color='blue', linestyle='--', alpha=0.4, label='x → 0')
ax2.axhline(y=1, color='red', linestyle='--', alpha=0.4, label='y → 1')
ax2.set_xlabel('t (oracle parameter)', fontsize=12)
ax2.set_ylabel('Coordinate value', fontsize=12)
ax2.set_title('Components vs Parameter\nBoth Converge to Ω = (0, 1)', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-1.3, 1.3)

# Panel 3: Distance to Omega Point
ax3 = axes[2]
dist_to_omega = np.sqrt(inv_stereo_x(t_range)**2 + (inv_stereo_y(t_range) - 1)**2)
ax3.semilogy(t_range, dist_to_omega, 'purple', linewidth=2)
ax3.set_xlabel('t (oracle parameter)', fontsize=12)
ax3.set_ylabel('Distance to Ω (log scale)', fontsize=12)
ax3.set_title('Distance to Omega Point\nDecays as O(1/|t|)', fontsize=12)
ax3.grid(True, alpha=0.3, which='both')

# Add decay envelope
t_pos = np.linspace(1, 15, 100)
ax3.plot(t_pos, 2/t_pos, 'k--', alpha=0.5, label='2/|t| envelope')
ax3.plot(-t_pos, 2/t_pos, 'k--', alpha=0.5)
ax3.legend()

plt.tight_layout()
plt.savefig('omega_point.png', dpi=150, bbox_inches='tight')
print("✓ Saved: omega_point.png")


# ─── Figure 2: Oracle Hierarchy on the Sphere ────────────────────────
fig2, ax = plt.subplots(figsize=(8, 8))

# Draw the unit circle
theta = np.linspace(0, 2*np.pi, 300)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1)

# Plot oracle levels 0, 1, 2, ..., 30
max_n = 30
colors = plt.cm.viridis(np.linspace(0, 1, max_n + 1))
for n in range(max_n + 1):
    xn = inv_stereo_x(n)
    yn = inv_stereo_y(n)
    ax.plot(xn, yn, 'o', color=colors[n], markersize=10 - n*0.2, zorder=3)
    if n <= 5 or n == 10 or n == 20 or n == 30:
        ax.annotate(f'∅{"′" * n if n <= 3 else f"⁽{n}⁾"}',
                    xy=(xn, yn), fontsize=8,
                    xytext=(10, -5), textcoords='offset points')

# Omega Point
ax.plot(0, 1, 'r*', markersize=25, zorder=5)
ax.annotate('Ω (Omega Oracle)\n= North Pole = ∞',
            xy=(0, 1), xytext=(-0.7, 0.5),
            fontsize=12, fontweight='bold', color='red',
            arrowprops=dict(arrowstyle='->', color='red', lw=2))

# South pole
ax.plot(0, -1, 'gs', markersize=12, zorder=5)
ax.annotate('South Pole\n= Origin (∅)', xy=(0, -1), xytext=(0.2, -0.7),
            fontsize=10, color='green',
            arrowprops=dict(arrowstyle='->', color='green', lw=1.5))

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('The Arithmetic Oracle Hierarchy on S¹\n'
             'Each Oracle Level Spirals Toward the Omega Point',
             fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('oracle_hierarchy_sphere.png', dpi=150, bbox_inches='tight')
print("✓ Saved: oracle_hierarchy_sphere.png")


# ─── Figure 3: 3D Visualization (S²) ────────────────────────────────
fig3 = plt.figure(figsize=(10, 8))
ax3d = fig3.add_subplot(111, projection='3d')

# Draw sphere wireframe
u = np.linspace(0, 2*np.pi, 40)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax3d.plot_wireframe(xs, ys, zs, alpha=0.1, color='gray')

# 2D inverse stereographic projection onto S²
# Standard: (x,y) ↦ (2x, 2y, x²+y²-1) / (x²+y²+1)
def inv_stereo_3d(x, y):
    d = x**2 + y**2 + 1
    return 2*x/d, 2*y/d, (x**2 + y**2 - 1)/d

# Grid of points in the plane
grid = np.linspace(-5, 5, 20)
for gi in grid:
    # Lines of constant x
    t = np.linspace(-5, 5, 100)
    sx, sy, sz = inv_stereo_3d(gi, t)
    ax3d.plot(sx, sy, sz, 'b-', alpha=0.3, linewidth=0.5)
    # Lines of constant y
    sx, sy, sz = inv_stereo_3d(t, gi)
    ax3d.plot(sx, sy, sz, 'r-', alpha=0.3, linewidth=0.5)

# North pole (Omega Point)
ax3d.scatter([0], [0], [1], color='red', s=200, marker='*', zorder=5)
ax3d.text(0, 0, 1.15, 'Ω', fontsize=16, fontweight='bold', color='red',
          ha='center')

# Origin → south pole
sx, sy, sz = inv_stereo_3d(0, 0)
ax3d.scatter([sx], [sy], [sz], color='green', s=100, marker='o', zorder=5)
ax3d.text(sx, sy, sz-0.15, '0', fontsize=12, color='green', ha='center')

ax3d.set_title('Inverse Stereographic Projection ℝ² → S²\n'
               'All Grid Lines Converge at Ω (North Pole)',
               fontsize=13, fontweight='bold')
ax3d.set_xlabel('X')
ax3d.set_ylabel('Y')
ax3d.set_zlabel('Z')

plt.tight_layout()
plt.savefig('omega_point_3d.png', dpi=150, bbox_inches='tight')
print("✓ Saved: omega_point_3d.png")


print("\n" + "="*60)
print("OMEGA POINT THEOREM — NUMERICAL VERIFICATION")
print("="*60)
print("\nAs t → ∞, invStereo(t) → (0, 1) = Omega Point:")
for t in [1, 10, 100, 1000, 10000, 1e6]:
    x, y = inv_stereo_x(t), inv_stereo_y(t)
    d = np.sqrt(x**2 + (y-1)**2)
    print(f"  t = {t:>10.0f}  →  ({x:.10f}, {y:.10f})  dist = {d:.2e}")

print("\nAs t → -∞, invStereo(t) → (0, 1) = Omega Point:")
for t in [-1, -10, -100, -1000, -10000, -1e6]:
    x, y = inv_stereo_x(t), inv_stereo_y(t)
    d = np.sqrt(x**2 + (y-1)**2)
    print(f"  t = {t:>10.0f}  →  ({x:.10f}, {y:.10f})  dist = {d:.2e}")
