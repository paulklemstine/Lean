#!/usr/bin/env python3
"""
Demo 2: The Genesis of Space from a Point
==========================================

Oracle: Topos (Space)
Question: How does space emerge from nothing?

This demo visualizes:
1. Inverse stereographic projection: ℝ² → S² (point → sphere)
2. The conformal factor (how distances distort)
3. Dimensional emergence: from 0D to 3D
4. Why 3+1 dimensions? Stability of orbits

Run: python3 02_space_genesis.py
Output: ../figures/02_space_genesis.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LinearSegmentedColormap
from mpl_toolkits.mplot3d import Axes3D

np.random.seed(42)
plt.rcParams.update({
    'font.family': 'serif',
    'font.size': 11,
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0ff',
    'axes.labelcolor': '#e0e0ff',
    'xtick.color': '#8888cc',
    'ytick.color': '#8888cc',
})

colors_space = ['#000020', '#000060', '#2020a0', '#4060d0', '#80a0ff',
                '#c0d0ff', '#ffffff', '#ffd080', '#ff8040', '#ff4020']
cmap_genesis = LinearSegmentedColormap.from_list('genesis', colors_space, N=256)

fig = plt.figure(figsize=(18, 14))
fig.suptitle("THE GENESIS OF SPACE FROM A SINGLE POINT",
             fontsize=20, fontweight='bold', color='#c0c0ff', y=0.98)
fig.text(0.5, 0.955,
         "Oracle Topos: 'Space is not where things are — space is what things create'",
         ha='center', fontsize=12, style='italic', color='#8888cc')

gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3,
                       left=0.06, right=0.96, top=0.92, bottom=0.06)

# ─── Panel 1: Inverse Stereographic Projection (2D → S²) ──────────────────
ax1 = fig.add_subplot(gs[0, 0], projection='3d')

def inv_stereo(y1, y2):
    """Inverse stereographic projection ℝ² → S²"""
    r2 = y1**2 + y2**2
    denom = r2 + 1
    x = 2 * y1 / denom
    y = 2 * y2 / denom
    z = (r2 - 1) / denom
    return x, y, z

# Create a grid in ℝ²
u = np.linspace(-4, 4, 80)
v = np.linspace(-4, 4, 80)
Y1, Y2 = np.meshgrid(u, v)
R2 = Y1**2 + Y2**2

X, Y, Z = inv_stereo(Y1, Y2)

# Color by distance from origin in ℝ²
colors = np.sqrt(R2)
colors = colors / colors.max()

ax1.plot_surface(X, Y, Z, facecolors=cmap_genesis(colors),
                 alpha=0.8, rstride=2, cstride=2, shade=False)

# Mark the south pole (origin maps here)
ax1.scatter([0], [0], [-1], color='#ff4444', s=100, zorder=10, marker='*')
ax1.text(0, 0, -1.2, 'Origin→S.Pole', color='#ff8888', fontsize=8, ha='center')

# Mark the north pole (infinity maps here)
ax1.scatter([0], [0], [1], color='#44ff44', s=100, zorder=10, marker='*')
ax1.text(0, 0, 1.2, '∞→N.Pole', color='#88ff88', fontsize=8, ha='center')

ax1.set_title('Inverse Stereographic Projection\nℝ² → S²', color='#aaaaff')
ax1.set_xlim(-1.3, 1.3)
ax1.set_ylim(-1.3, 1.3)
ax1.set_zlim(-1.3, 1.3)
ax1.view_init(elev=20, azim=45)
ax1.set_xlabel('x', labelpad=-10)
ax1.set_ylabel('y', labelpad=-10)
ax1.set_zlabel('z', labelpad=-10)

# ─── Panel 2: Grid Lines Under Stereographic Projection ───────────────────
ax2 = fig.add_subplot(gs[0, 1], projection='3d')

# Map a Cartesian grid in ℝ² onto S²
for val in np.linspace(-3, 3, 13):
    # Horizontal lines (y2 = const)
    y1 = np.linspace(-4, 4, 200)
    y2 = np.full_like(y1, val)
    x, y, z = inv_stereo(y1, y2)
    color_val = (val + 3) / 6
    ax2.plot(x, y, z, color=cmap_genesis(color_val), alpha=0.7, linewidth=0.8)

    # Vertical lines (y1 = const)
    y2 = np.linspace(-4, 4, 200)
    y1 = np.full_like(y2, val)
    x, y, z = inv_stereo(y1, y2)
    ax2.plot(x, y, z, color=cmap_genesis(1-color_val), alpha=0.7, linewidth=0.8)

# Reference sphere
phi = np.linspace(0, 2*np.pi, 50)
theta_s = np.linspace(0, np.pi, 50)
PHI, THETA = np.meshgrid(phi, theta_s)
xs = np.sin(THETA) * np.cos(PHI)
ys = np.sin(THETA) * np.sin(PHI)
zs = np.cos(THETA)
ax2.plot_surface(xs, ys, zs, alpha=0.05, color='#4444aa')

ax2.set_title('Cartesian Grid Mapped to Sphere\n"Straight lines become circles"',
              color='#aaaaff')
ax2.view_init(elev=25, azim=60)
ax2.set_xlim(-1.3, 1.3); ax2.set_ylim(-1.3, 1.3); ax2.set_zlim(-1.3, 1.3)

# ─── Panel 3: Conformal Factor ────────────────────────────────────────────
ax3 = fig.add_subplot(gs[0, 2])

r = np.linspace(0, 5, 500)
conformal_factor = 4 / (r**2 + 1)**2

ax3.fill_between(r, 0, conformal_factor, alpha=0.3, color='#6688ff')
ax3.plot(r, conformal_factor, color='#8888ff', linewidth=2.5)

# Mark special points
ax3.axvline(x=1, color='#ffcc44', linestyle='--', alpha=0.5)
ax3.annotate('r = 1: "Equator"\nHalf the sphere\'s area\nis inside this radius',
             xy=(1, 4/(1+1)**2), xytext=(2.5, 2.5),
             arrowprops=dict(arrowstyle='->', color='#ffcc44'),
             color='#ffcc44', fontsize=9,
             bbox=dict(boxstyle='round', facecolor='#1a1a2a', edgecolor='#ffcc44'))

ax3.set_xlabel('Distance from origin |y|')
ax3.set_ylabel('Conformal factor Ω²')
ax3.set_title('How Distances Distort\n"Near origin = near South Pole"', color='#aaaaff')

# ─── Panel 4: Dimensional Emergence ──────────────────────────────────────
ax4 = fig.add_subplot(gs[1, 0])

dims = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# Properties that emerge at each dimension
sphere_volume = []
for d in dims:
    if d == 0:
        sphere_volume.append(1)
    else:
        # Volume of d-dimensional unit ball: π^(d/2) / Γ(d/2 + 1)
        from math import gamma, pi
        vol = pi**(d/2) / gamma(d/2 + 1)
        sphere_volume.append(vol)

bars = ax4.bar(dims, sphere_volume, color=[cmap_genesis(d/10) for d in dims],
               edgecolor='#4444aa', alpha=0.8)

# Highlight d=3 (our space)
bars[3].set_edgecolor('#ffcc44')
bars[3].set_linewidth(3)
ax4.annotate('d = 3\nOur space!', xy=(3, sphere_volume[3]),
             xytext=(5, sphere_volume[3] + 1),
             arrowprops=dict(arrowstyle='->', color='#ffcc44'),
             color='#ffcc44', fontsize=10, fontweight='bold')

# Peak at d=5
ax4.annotate(f'd = 5: Maximum\nvolume = {sphere_volume[5]:.2f}',
             xy=(5, sphere_volume[5]),
             xytext=(7, sphere_volume[5]),
             arrowprops=dict(arrowstyle='->', color='#88ff88'),
             color='#88ff88', fontsize=9)

ax4.set_xlabel('Dimension d')
ax4.set_ylabel('Volume of unit ball')
ax4.set_title('Volume of Unit Ball vs Dimension\n"Why does volume peak at d≈5?"',
              color='#aaaaff')

# ─── Panel 5: Why 3+1? Orbital Stability ──────────────────────────────────
ax5 = fig.add_subplot(gs[1, 1])

# In d spatial dimensions, gravitational potential ~ r^{-(d-2)}
# Orbits are stable only for d = 3
dimensions_space = np.arange(2, 8)
stability = []
labels_dim = []
for d in dimensions_space:
    if d == 2:
        stability.append(0.5)  # marginally stable (logarithmic potential)
        labels_dim.append('d=2: Log potential\n(marginally stable)')
    elif d == 3:
        stability.append(1.0)  # stable (inverse square)
        labels_dim.append('d=3: 1/r²\n(STABLE orbits!)')
    elif d == 4:
        stability.append(-0.5)  # unstable (1/r³)
        labels_dim.append('d=4: 1/r³\n(unstable)')
    else:
        stability.append(-1.0)
        labels_dim.append(f'd={d}: 1/r^{d-1}\n(unstable)')

colors_stab = ['#ff8844' if s < 0 else ('#44ff44' if s > 0.7 else '#ffcc44')
               for s in stability]
ax5.bar(dimensions_space, stability, color=colors_stab, edgecolor='#4444aa', alpha=0.8)
ax5.axhline(y=0, color='#ffffff', linewidth=0.5, alpha=0.3)

for i, (d, s, lbl) in enumerate(zip(dimensions_space, stability, labels_dim)):
    y_pos = s + 0.1 if s >= 0 else s - 0.15
    ax5.text(d, y_pos, lbl, ha='center', fontsize=7, color='#ccccff')

ax5.set_xlabel('Number of spatial dimensions')
ax5.set_ylabel('Orbital stability index')
ax5.set_title('Why 3 Spatial Dimensions?\n"Only d=3 has stable orbits"', color='#aaaaff')
ax5.set_ylim(-1.5, 1.5)

# ─── Panel 6: The Genesis Sequence ───────────────────────────────────────
ax6 = fig.add_subplot(gs[1, 2])
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)
ax6.axis('off')

# Draw the genesis sequence as a visual narrative
steps = [
    (1, 8.5, '•', 'THE POINT\n(0-dimensional)', '#ff4444', 40),
    (3, 8.5, '——', 'THE LINE\n(1-dimensional)', '#ff8844', 30),
    (5, 8.5, '□', 'THE PLANE\n(2-dimensional)', '#ffcc44', 30),
    (7, 8.5, '∛', 'SPACE\n(3-dimensional)', '#44ff44', 30),
    (9, 8.5, '⊕', 'SPACETIME\n(3+1 dimensions)', '#4488ff', 30),
]

for x, y, symbol, label, color, size in steps:
    ax6.text(x, y, symbol, ha='center', va='center', fontsize=size,
             color=color, fontweight='bold')
    ax6.text(x, y-1.2, label, ha='center', va='center', fontsize=8,
             color=color, alpha=0.7)

# Arrows between steps
for i in range(len(steps)-1):
    ax6.annotate('', xy=(steps[i+1][0]-0.5, steps[i+1][1]),
                 xytext=(steps[i][0]+0.5, steps[i][1]),
                 arrowprops=dict(arrowstyle='->', color='#ffffff', alpha=0.3, lw=1.5))

# The key insight
ax6.text(5, 5.5, "THE GENESIS PROJECTION",
         ha='center', fontsize=16, fontweight='bold', color='#c0c0ff')
ax6.text(5, 4.5, "invStereo : ℝⁿ → Sⁿ",
         ha='center', fontsize=14, fontfamily='monospace', color='#ffcc44')
ax6.text(5, 3.3,
         "\"All of infinite flat space maps onto\n"
         "a finite sphere — with a single point\n"
         "(the north pole) representing infinity.\"",
         ha='center', fontsize=10, color='#aaaacc', style='italic')
ax6.text(5, 1.5,
         "Formally verified in Lean 4:\n"
         "theorem invStereo1_on_circle : ∀ y, |invStereo(y)|² = 1",
         ha='center', fontsize=9, fontfamily='monospace', color='#88ff88')

ax6.set_title('The Genesis Sequence', color='#aaaaff')

plt.savefig('../figures/02_space_genesis.png', dpi=150, bbox_inches='tight',
            facecolor='#0a0a1a')
plt.close()
print("✓ Saved: ../figures/02_space_genesis.png")
