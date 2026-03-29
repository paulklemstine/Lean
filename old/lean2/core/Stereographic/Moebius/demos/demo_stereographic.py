#!/usr/bin/env python3
"""
Demo 1: Classical Stereographic Projection & Pole Swap

Visualizes:
1. The inverse stereographic projection from ℝ to S¹
2. The pole-swap (inversion z → 1/z) and its effect
3. How circles map to circles

Run: python3 demo_stereographic.py
Output: stereographic_projection.png, pole_swap.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.gridspec as gridspec

# --- Core Functions ---

def inv_stereo(t):
    """Inverse stereographic projection: ℝ → S¹."""
    x = 2 * t / (1 + t**2)
    y = (1 - t**2) / (1 + t**2)
    return x, y

def stereo_forward(x, y):
    """Forward stereographic projection: S¹ → ℝ."""
    return x / (1 + y)

def pole_swap(t):
    """Pole swap: t → 1/t."""
    return 1.0 / t

# --- Figure 1: Classical Stereographic Projection ---

fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: The projection geometry
ax1 = fig.add_subplot(gs[0, 0])
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=2, label='Unit circle S¹')

# Show projection lines from North Pole (0, -1) to points on circle
# Convention: North Pole at (0, -1) so South Pole at (0, 1)
# Standard: project from (0, -1), south pole is (0, 1) → maps to 0
north_pole = (0, -1)
ax1.plot(*north_pole, 'r^', markersize=15, label='North Pole (projection center)', zorder=5)
ax1.plot(0, 1, 'bs', markersize=12, label='South Pole → 0', zorder=5)

# Show a few projection lines
test_t = [-3, -1, -0.5, 0, 0.5, 1, 3]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(test_t)))
for t, c in zip(test_t, colors):
    px, py = inv_stereo(t)
    # Line from North Pole through (px, py) to the real line (y = -1.5)
    ax1.plot([north_pole[0], px, t], [north_pole[1], py, -1.5], '--', color=c, alpha=0.5)
    ax1.plot(px, py, 'o', color=c, markersize=8, zorder=4)
    ax1.plot(t, -1.5, 's', color=c, markersize=8, zorder=4)
    ax1.annotate(f't={t}', (t, -1.5), fontsize=7, ha='center', va='top')

ax1.axhline(y=-1.5, color='gray', linestyle='-', alpha=0.3, label='Real line')
ax1.set_xlim(-4, 4)
ax1.set_ylim(-2, 1.5)
ax1.set_aspect('equal')
ax1.set_title('Stereographic Projection from North Pole', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.3)

# Panel 2: The inverse map - where integers go on the circle
ax2 = fig.add_subplot(gs[0, 1])
ax2.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=2)

integers = range(-10, 11)
for k in integers:
    px, py = inv_stereo(k)
    size = 10 if k == 0 else 6
    color = 'red' if k == 0 else ('green' if k > 0 else 'orange')
    ax2.plot(px, py, 'o', color=color, markersize=size, zorder=5)
    if abs(k) <= 5:
        offset = 0.15
        ax2.annotate(str(k), (px*(1+offset), py*(1+offset)), fontsize=8,
                     ha='center', va='center', fontweight='bold')

ax2.plot(0, -1, 'k^', markersize=12, label='N pole (∞)', zorder=6)
ax2.plot(0, 1, 'rs', markersize=12, label='S pole (0)', zorder=6)
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Integer Crystallization on S¹', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Pole Swap Effect
ax3 = fig.add_subplot(gs[1, 0])
t_vals = np.linspace(-5, -0.05, 200)
t_vals2 = np.linspace(0.05, 5, 200)

# Plot t vs 1/t
ax3.plot(t_vals, 1/t_vals, 'b-', linewidth=2, label='Pole swap: t → 1/t')
ax3.plot(t_vals2, 1/t_vals2, 'b-', linewidth=2)

# Highlight fixed points
ax3.plot(1, 1, 'ro', markersize=12, label='Fixed point t=1', zorder=5)
ax3.plot(-1, -1, 'ro', markersize=12, label='Fixed point t=-1', zorder=5)
ax3.plot([-5, 5], [-5, 5], 'k--', alpha=0.3, label='Identity line')

# Show some specific mappings
pairs = [(2, 0.5), (3, 1/3), (-2, -0.5)]
for t, tinv in pairs:
    ax3.annotate('', xy=(tinv, tinv), xytext=(t, t),
                arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax3.plot(t, 1/t, 'gs', markersize=8, zorder=5)

ax3.set_xlim(-5, 5)
ax3.set_ylim(-5, 5)
ax3.set_xlabel('t (original coordinate)', fontsize=11)
ax3.set_ylabel('1/t (pole-swapped coordinate)', fontsize=11)
ax3.set_title('Pole Swap: Inversion z → 1/z', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_aspect('equal')

# Panel 4: Before/After comparison on the circle
ax4 = fig.add_subplot(gs[1, 1])
ax4.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=2, alpha=0.5)

# Show how specific points move under pole swap
sample_t = [0.5, 1, 2, 3, 5, -0.5, -1, -2, -3]
for t in sample_t:
    x1, y1 = inv_stereo(t)
    if abs(t) > 1e-10:
        t_swapped = 1/t
        x2, y2 = inv_stereo(t_swapped)
        ax4.plot(x1, y1, 'ro', markersize=8, zorder=5)
        ax4.plot(x2, y2, 'b^', markersize=8, zorder=5)
        ax4.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='purple', lw=1, alpha=0.6))

ax4.plot([], [], 'ro', markersize=8, label='Original point')
ax4.plot([], [], 'b^', markersize=8, label='After pole swap')

# Mark self-dual points
x_sd1, y_sd1 = inv_stereo(1)
x_sd2, y_sd2 = inv_stereo(-1)
ax4.plot(x_sd1, y_sd1, 'g*', markersize=15, label='Self-dual (t=±1)', zorder=6)
ax4.plot(x_sd2, y_sd2, 'g*', markersize=15, zorder=6)

ax4.set_xlim(-1.5, 1.5)
ax4.set_ylim(-1.5, 1.5)
ax4.set_aspect('equal')
ax4.set_title('Points Move Under Pole Swap', fontsize=13, fontweight='bold')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.suptitle('Classical Stereographic Projection & Pole Swap', fontsize=16, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/demos/stereographic_projection.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved stereographic_projection.png")

# --- Figure 2: Conformal property visualization ---

fig2, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Grid in the plane
ax = axes[0]
for u in np.linspace(-3, 3, 13):
    ax.axhline(y=u, color='blue', alpha=0.3, linewidth=0.8)
    ax.axvline(x=u, color='red', alpha=0.3, linewidth=0.8)
ax.set_xlim(-3.5, 3.5)
ax.set_ylim(-3.5, 3.5)
ax.set_title('Rectangular Grid in ℝ²', fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.grid(False)

# Right: Image on the sphere (projected to 2D circle view)
ax = axes[1]
theta_c = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta_c), np.sin(theta_c), 'k-', linewidth=2)

# Map horizontal lines (constant v)
for v in np.linspace(-3, 3, 13):
    u_line = np.linspace(-5, 5, 300)
    xs = []
    ys = []
    for u in u_line:
        t = u  # For 1D, just use the real part
        x, y = inv_stereo(t + 0.1*v)  # perturb slightly for visual effect
        xs.append(x)
        ys.append(y)
    ax.plot(xs, ys, 'b-', alpha=0.3, linewidth=0.8)

# Map vertical lines (constant u)
for u in np.linspace(-3, 3, 13):
    v_line = np.linspace(-5, 5, 300)
    xs = []
    ys = []
    for v in v_line:
        t = u + 0.1*v
        x, y = inv_stereo(t)
        xs.append(x)
        ys.append(y)
    ax.plot(xs, ys, 'r-', alpha=0.3, linewidth=0.8)

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_title('Image on S¹ (Conformal)', fontsize=13, fontweight='bold')
ax.set_aspect('equal')

plt.suptitle('Conformality: Angles Preserved Under Projection', fontsize=14, fontweight='bold')
plt.savefig('/workspace/request-project/demos/conformal_property.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved conformal_property.png")
