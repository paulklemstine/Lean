"""
Demo 1: The Stereographic Conformal Attractor
==============================================
Visualizes the dynamical system T(y) = 2y/(1+|y|²),
showing convergence of all non-zero orbits to the unit circle.

The radial map f(r) = 2r/(1+r²) has:
  - Unstable fixed point at r = 0
  - Attracting fixed point at r = 1
  - All orbits in (0,∞) converge to r = 1

Oracle Δ's discovery: inverse stereographic projection,
when iterated, creates a universal "sphericalization" —
every configuration in ℝ^N is drawn onto the unit sphere.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.collections import LineCollection
import matplotlib.gridspec as gridspec

# ─── Core Maps ───────────────────────────────────────────────
def stereo_iterate(y, n_steps=50):
    """Apply T(y) = 2y/(1+|y|²) iteratively."""
    trajectory = [y.copy()]
    for _ in range(n_steps):
        r2 = np.sum(y**2)
        y = 2 * y / (1 + r2)
        trajectory.append(y.copy())
    return np.array(trajectory)

def radial_map(r):
    """f(r) = 2r/(1+r²) — the radial component of the iteration."""
    return 2 * r / (1 + r**2)

# ─── Figure Setup ────────────────────────────────────────────
fig = plt.figure(figsize=(18, 12), facecolor='#0a0a1a')
gs = gridspec.GridSpec(2, 3, hspace=0.3, wspace=0.3)

# ── Panel 1: The Radial Map f(r) = 2r/(1+r²) ──────────────
ax1 = fig.add_subplot(gs[0, 0], facecolor='#0a0a1a')
r = np.linspace(0, 4, 500)
fr = radial_map(r)

ax1.plot(r, r, '--', color='#444466', linewidth=1, label='y = r (identity)')
ax1.plot(r, fr, color='#00ddff', linewidth=2.5, label='f(r) = 2r/(1+r²)')
ax1.plot([1], [1], 'o', color='#ff6600', markersize=10, zorder=5, label='Attracting fixed point')
ax1.plot([0], [0], 's', color='#ff3333', markersize=8, zorder=5, label='Repelling fixed point')

# Cobweb diagram
r_val = 2.5
for i in range(12):
    fr_val = radial_map(r_val)
    ax1.plot([r_val, r_val], [r_val, fr_val], '-', color='#ffaa00', alpha=0.5, linewidth=0.8)
    ax1.plot([r_val, fr_val], [fr_val, fr_val], '-', color='#ffaa00', alpha=0.5, linewidth=0.8)
    r_val = fr_val

r_val = 0.15
for i in range(12):
    fr_val = radial_map(r_val)
    ax1.plot([r_val, r_val], [r_val, fr_val], '-', color='#33ff99', alpha=0.5, linewidth=0.8)
    ax1.plot([r_val, fr_val], [fr_val, fr_val], '-', color='#33ff99', alpha=0.5, linewidth=0.8)
    r_val = fr_val

ax1.set_xlim(0, 3.5)
ax1.set_ylim(0, 2.0)
ax1.set_xlabel('r', color='white', fontsize=12)
ax1.set_ylabel('f(r)', color='white', fontsize=12)
ax1.set_title('Radial Cobweb: f(r) = 2r/(1+r²)', color='#00ddff', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax1.tick_params(colors='white')
for spine in ax1.spines.values():
    spine.set_color('#333355')

# ── Panel 2: 2D Phase Portrait ──────────────────────────────
ax2 = fig.add_subplot(gs[0, 1], facecolor='#0a0a1a')

# Unit circle (attractor)
theta = np.linspace(0, 2*np.pi, 200)
ax2.plot(np.cos(theta), np.sin(theta), color='#ff6600', linewidth=2.5, label='Unit circle (attractor)')

# Trajectories from various starting points
np.random.seed(42)
n_traj = 30
colors = plt.cm.plasma(np.linspace(0.2, 0.9, n_traj))

for i in range(n_traj):
    # Random starting points at various radii
    angle = np.random.uniform(0, 2*np.pi)
    radius = np.random.choice([np.random.uniform(0.05, 0.8), np.random.uniform(1.2, 4.0)])
    y0 = np.array([radius * np.cos(angle), radius * np.sin(angle)])
    traj = stereo_iterate(y0, n_steps=30)
    
    ax2.plot(traj[:, 0], traj[:, 1], '-', color=colors[i], alpha=0.6, linewidth=0.8)
    ax2.plot(traj[0, 0], traj[0, 1], 'o', color=colors[i], markersize=4, alpha=0.8)
    ax2.plot(traj[-1, 0], traj[-1, 1], '.', color=colors[i], markersize=2)

ax2.set_xlim(-3.5, 3.5)
ax2.set_ylim(-3.5, 3.5)
ax2.set_aspect('equal')
ax2.set_title('2D Phase Portrait: Orbits → S¹', color='#00ddff', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white', loc='upper right')
ax2.tick_params(colors='white')
for spine in ax2.spines.values():
    spine.set_color('#333355')

# ── Panel 3: Convergence Rate ────────────────────────────────
ax3 = fig.add_subplot(gs[0, 2], facecolor='#0a0a1a')

for r0 in [0.1, 0.3, 0.5, 0.7, 1.5, 2.0, 3.0, 5.0]:
    radii = [r0]
    r = r0
    for _ in range(40):
        r = radial_map(r)
        radii.append(r)
    color = '#33ff99' if r0 < 1 else '#ff6666'
    ax3.plot(radii, color=color, alpha=0.7, linewidth=1.5, label=f'r₀={r0}')

ax3.axhline(y=1, color='#ff6600', linestyle='--', linewidth=1.5, label='r = 1 (attractor)')
ax3.set_xlabel('Iteration n', color='white', fontsize=12)
ax3.set_ylabel('||T^n(y)||', color='white', fontsize=12)
ax3.set_title('Convergence Rate by Initial Radius', color='#00ddff', fontsize=13, fontweight='bold')
ax3.legend(fontsize=7, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white', ncol=2)
ax3.tick_params(colors='white')
for spine in ax3.spines.values():
    spine.set_color('#333355')

# ── Panel 4: Conformal Factor Landscape ──────────────────────
ax4 = fig.add_subplot(gs[1, 0], facecolor='#0a0a1a')

x_grid = np.linspace(-3, 3, 400)
y_grid = np.linspace(-3, 3, 400)
X, Y = np.meshgrid(x_grid, y_grid)
R2 = X**2 + Y**2
Lambda = 2 / (1 + R2)

im = ax4.imshow(Lambda, extent=[-3, 3, -3, 3], cmap='inferno', origin='lower', vmin=0, vmax=2)
ax4.contour(X, Y, Lambda, levels=[0.2, 0.5, 0.8, 1.0, 1.5, 1.8], colors='white', alpha=0.3, linewidths=0.5)
circle = plt.Circle((0, 0), 1, fill=False, color='#00ddff', linewidth=1.5, linestyle='--')
ax4.add_patch(circle)
plt.colorbar(im, ax=ax4, label='λ(y) = 2/(1+|y|²)', shrink=0.8)
ax4.set_title('Conformal Factor λ(y)', color='#00ddff', fontsize=13, fontweight='bold')
ax4.set_xlabel('y₁', color='white', fontsize=12)
ax4.set_ylabel('y₂', color='white', fontsize=12)
ax4.tick_params(colors='white')

# ── Panel 5: Iterated Grid Deformation ──────────────────────
ax5 = fig.add_subplot(gs[1, 1], facecolor='#0a0a1a')

# Start with a regular grid, apply T multiple times
grid_pts = []
for x in np.linspace(-2.5, 2.5, 15):
    for y in np.linspace(-2.5, 2.5, 15):
        grid_pts.append([x, y])
grid_pts = np.array(grid_pts)

iterations_to_show = [0, 1, 3, 8]
colors_iter = ['#ff3333', '#ffaa00', '#33ff99', '#00ddff']

for k, n_iter in enumerate(iterations_to_show):
    pts = grid_pts.copy()
    for _ in range(n_iter):
        r2 = np.sum(pts**2, axis=1, keepdims=True)
        pts = 2 * pts / (1 + r2)
    ax5.scatter(pts[:, 0], pts[:, 1], s=8, color=colors_iter[k], alpha=0.7, label=f'n={n_iter}')

ax5.plot(np.cos(theta), np.sin(theta), color='#ff6600', linewidth=1.5, alpha=0.5)
ax5.set_xlim(-3, 3)
ax5.set_ylim(-3, 3)
ax5.set_aspect('equal')
ax5.set_title('Grid Under Iteration T^n', color='#00ddff', fontsize=13, fontweight='bold')
ax5.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax5.tick_params(colors='white')
for spine in ax5.spines.values():
    spine.set_color('#333355')

# ── Panel 6: Lyapunov Exponent ───────────────────────────────
ax6 = fig.add_subplot(gs[1, 2], facecolor='#0a0a1a')

r_range = np.linspace(0.01, 5, 500)
# f'(r) = 2(1-r²)/(1+r²)²
df = 2 * (1 - r_range**2) / (1 + r_range**2)**2
lyap = np.log(np.abs(df))

ax6.plot(r_range, lyap, color='#ff00ff', linewidth=2)
ax6.axhline(y=0, color='#444466', linestyle='--', linewidth=1)
ax6.axvline(x=1, color='#ff6600', linestyle='--', linewidth=1, label='r = 1')
ax6.fill_between(r_range, lyap, 0, where=(lyap > 0), color='#ff333333', alpha=0.3, label='Expanding (λ > 0)')
ax6.fill_between(r_range, lyap, 0, where=(lyap < 0), color='#33ff9933', alpha=0.3, label='Contracting (λ < 0)')

ax6.set_xlabel('r', color='white', fontsize=12)
ax6.set_ylabel('log|f\'(r)| (Lyapunov exponent)', color='white', fontsize=12)
ax6.set_title('Stability Analysis', color='#00ddff', fontsize=13, fontweight='bold')
ax6.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax6.set_xlim(0, 4)
ax6.set_ylim(-5, 2)
ax6.tick_params(colors='white')
for spine in ax6.spines.values():
    spine.set_color('#333355')

fig.suptitle('THE STEREOGRAPHIC CONFORMAL ATTRACTOR\n'
             'Iterating T(y) = 2y/(1+|y|²): Universal Sphericalization',
             color='white', fontsize=16, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.94])
plt.savefig('/workspace/request-project/Stereographic/InverseNDim/demos/demo1_conformal_attractor.png',
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 1: Conformal Attractor — saved!")
