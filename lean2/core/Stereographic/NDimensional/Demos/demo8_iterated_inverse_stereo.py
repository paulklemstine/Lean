#!/usr/bin/env python3
"""
Demo 8: Iterated Inverse Stereographic Projection — The Fractal Factory
=========================================================================

NEW LANDSCAPE: What happens when you apply inverse stereographic projection
repeatedly? Each application lifts ℝ^N to S^N, embeds S^N into ℝ^{N+1},
then projects again. The iteration creates self-similar structures.

Key Discovery: Iterated application of σ⁻¹ composed with embedding
creates a "dimensional cascade" — objects in ℝ^N get recursively lifted
to spheres of increasing dimension, then projected back down, accumulating
conformal distortion at each step.

Oracle Σ's experiment on recursive conformal structures.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable

# ─── Core Functions ───

def inv_stereo_1d(t):
    """Inverse stereographic: ℝ → S¹ ⊂ ℝ²"""
    D = 1 + t**2
    return 2*t/D, (t**2 - 1)/D

def inv_stereo_2d(u, v):
    """Inverse stereographic: ℝ² → S² ⊂ ℝ³"""
    D = 1 + u**2 + v**2
    return 2*u/D, 2*v/D, (u**2 + v**2 - 1)/D

def stereo_project_1d(x, y):
    """Stereographic: S¹ → ℝ"""
    denom = 1 - y
    return np.where(np.abs(denom) > 1e-10, x / denom, np.nan)

def iterated_inv_stereo(t, n_iters=5):
    """
    Iterated inverse stereographic projection.
    Start with t ∈ ℝ, apply inv_stereo to get (x,y) ∈ S¹,
    then treat x as a new parameter, apply again, etc.
    Track the trajectory of coordinates.
    """
    trajectory_x = [t]
    trajectory_y = [0]
    current = t
    for _ in range(n_iters):
        x, y = inv_stereo_1d(current)
        trajectory_x.append(x)
        trajectory_y.append(y)
        current = x  # Feed x-coordinate back
    return np.array(trajectory_x), np.array(trajectory_y)

def conformal_cascade(grid_points, n_iters=3):
    """
    Apply inverse stereographic projection to a grid,
    then stereographic project from a DIFFERENT pole,
    creating a Möbius-like transformation.
    """
    points = grid_points.copy()
    all_stages = [points.copy()]
    for k in range(n_iters):
        # Inverse stereo: ℝ → S¹
        x, y = inv_stereo_1d(points)
        # Re-project from a rotated pole (not north pole)
        # This is equivalent to a Möbius transformation
        angle = np.pi / (k + 2)
        cos_a, sin_a = np.cos(angle), np.sin(angle)
        # Rotate the sphere point
        x_rot = cos_a * x - sin_a * y
        y_rot = sin_a * x + cos_a * y
        # Project from the new "north pole"
        points = stereo_project_1d(x_rot, y_rot)
        all_stages.append(points.copy())
    return all_stages

# ─── Figure: Iterated Inverse Stereographic Landscapes ───

fig = plt.figure(figsize=(20, 16))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: Iteration orbits in the (x, y) plane
ax1 = fig.add_subplot(gs[0, 0])
t_samples = np.linspace(-3, 3, 50)
cmap = plt.cm.plasma
norm = Normalize(vmin=-3, vmax=3)

for t0 in t_samples:
    tx, ty = iterated_inv_stereo(t0, n_iters=20)
    color = cmap(norm(t0))
    ax1.plot(tx, ty, '-o', color=color, markersize=2, linewidth=0.7, alpha=0.6)

ax1.set_xlabel('x-coordinate', fontsize=12)
ax1.set_ylabel('y-coordinate', fontsize=12)
ax1.set_title('Iterated Inverse Stereographic Orbits\nEach curve: t₀ → σ⁻¹ → x → σ⁻¹ → x → ...',
             fontsize=13, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)

# Add unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k--', linewidth=1, alpha=0.4, label='S¹')
ax1.legend(fontsize=10)

# Panel 2: Conformal cascade — how a uniform grid gets distorted
ax2 = fig.add_subplot(gs[0, 1])
grid = np.linspace(-2, 2, 200)
stages = conformal_cascade(grid, n_iters=5)

colors_stage = plt.cm.Set1(np.linspace(0, 1, len(stages)))
for k, stage in enumerate(stages):
    valid = np.isfinite(stage) & (np.abs(stage) < 10)
    y_offset = k * 0.3
    ax2.scatter(stage[valid], np.full(np.sum(valid), y_offset),
               c=[colors_stage[k]], s=1, alpha=0.7)
    ax2.text(-9, y_offset, f'Iter {k}', fontsize=10, va='center',
            color=colors_stage[k], fontweight='bold')

ax2.set_xlabel('Position on ℝ', fontsize=12)
ax2.set_ylabel('Iteration level', fontsize=12)
ax2.set_title('Conformal Cascade\nUniform grid → iterated Möbius distortion',
             fontsize=13, fontweight='bold')
ax2.set_xlim(-10, 10)
ax2.grid(True, alpha=0.3)

# Panel 3: 2D iterated landscape — apply inv_stereo_2d to a grid
ax3 = fig.add_subplot(gs[1, 0])

u_grid = np.linspace(-2, 2, 80)
v_grid = np.linspace(-2, 2, 80)
U, V = np.meshgrid(u_grid, v_grid)

# Apply inverse stereographic to get points on S²
X, Y, Z = inv_stereo_2d(U.ravel(), V.ravel())

# Apply a second inverse stereographic from S² coordinates
# Use the first two coordinates as new input
X2, Y2, Z2 = inv_stereo_2d(X, Y)

# The resulting pattern shows conformal self-similarity
scatter = ax3.scatter(X2, Y2, c=Z2, cmap='twilight_shifted', s=1, alpha=0.7)
plt.colorbar(scatter, ax=ax3, label='z-coordinate (depth)')
ax3.set_xlabel('x', fontsize=12)
ax3.set_ylabel('y', fontsize=12)
ax3.set_title('2D Iterated Inverse Stereo Landscape\nσ⁻¹ ∘ π ∘ σ⁻¹ applied to grid',
             fontsize=13, fontweight='bold')
ax3.set_aspect('equal')

# Panel 4: Accumulation of conformal factor
ax4 = fig.add_subplot(gs[1, 1])

# Track how the conformal factor accumulates through iterations
t_vals = np.linspace(-5, 5, 1000)
cumulative_factor = np.ones_like(t_vals)
factors_per_iter = [np.ones_like(t_vals)]

for iteration in range(6):
    D = 1 + t_vals**2
    local_factor = 2.0 / D
    cumulative_factor *= local_factor
    factors_per_iter.append(cumulative_factor.copy())
    # Update t for next iteration
    x_new, y_new = inv_stereo_1d(t_vals)
    t_vals = x_new

for k, factors in enumerate(factors_per_iter):
    valid = np.isfinite(factors)
    ax4.semilogy(np.linspace(-5, 5, 1000)[valid], factors[valid],
                linewidth=1.5, label=f'Iteration {k}',
                alpha=0.8)

ax4.set_xlabel('Initial parameter t', fontsize=12)
ax4.set_ylabel('Cumulative conformal factor', fontsize=12)
ax4.set_title('Conformal Factor Accumulation\nHow distortion compounds through iterations',
             fontsize=13, fontweight='bold')
ax4.legend(fontsize=9, loc='upper right')
ax4.grid(True, alpha=0.3)

fig.suptitle('New Landscape: Iterated Inverse Stereographic Projection',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo8_iterated_inverse_stereo.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 8 saved: demo8_iterated_inverse_stereo.png")
