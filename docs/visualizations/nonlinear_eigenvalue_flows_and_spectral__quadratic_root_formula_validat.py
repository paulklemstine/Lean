#!/usr/bin/env python3
"""
Visualization: Quadratic Root Formula and Validation

Visualizes the quadratic branch specialization theorem: for θ(t) = a + bt + ct²
with a < 0, b ≥ 0, c > 0, the first positive root r = (-b + √(b²-4ac))/(2c)
is the exact stability boundary.

Produces a heatmap of stability radii across (a, c) parameter space,
and a scatter plot validating analytic vs numerical roots.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ── Panel 1: Heatmap of stability radius in (a, c) space ──
ax = axes[0]
a_vals = np.linspace(-5, -0.1, 200)
c_vals = np.linspace(0.1, 3, 200)
A, C = np.meshgrid(a_vals, c_vals)
b_fixed = 0.5

# r = (-b + sqrt(b² - 4ac)) / (2c)
disc = b_fixed**2 - 4*A*C
R = (-b_fixed + np.sqrt(disc)) / (2*C)

im = ax.pcolormesh(a_vals, c_vals, R, cmap='viridis', shading='auto')
cbar = plt.colorbar(im, ax=ax, label='Stability radius ρ')
ax.set_xlabel('Constant term a (< 0)', fontsize=11)
ax.set_ylabel('Quadratic coefficient c (> 0)', fontsize=11)
ax.set_title(f'Stability Radius Map\n(b = {b_fixed} fixed)', fontsize=12)

# Add contour lines
contours = ax.contour(a_vals, c_vals, R, levels=[0.5, 1.0, 2.0, 3.0, 5.0],
                       colors='white', linewidths=0.8, linestyles='--')
ax.clabel(contours, fmt='ρ=%.1f', fontsize=8, colors='white')

# ── Panel 2: Analytic vs numerical validation ──
ax = axes[1]

n_trials = 500
analytic_roots = []
numerical_roots = []

for _ in range(n_trials):
    a = -np.random.uniform(0.5, 5)
    b = np.random.uniform(0, 3)
    c = np.random.uniform(0.1, 2)

    # Analytic
    disc = b**2 - 4*a*c
    r_analytic = (-b + np.sqrt(disc)) / (2*c)

    # Numerical (bisection)
    t_lo, t_hi = 0, 20
    for _ in range(100):
        t_mid = (t_lo + t_hi) / 2
        val = a + b*t_mid + c*t_mid**2
        if val < 0:
            t_lo = t_mid
        else:
            t_hi = t_mid
    r_numerical = (t_lo + t_hi) / 2

    analytic_roots.append(r_analytic)
    numerical_roots.append(r_numerical)

analytic_roots = np.array(analytic_roots)
numerical_roots = np.array(numerical_roots)
errors = np.abs(analytic_roots - numerical_roots)

ax.scatter(analytic_roots, numerical_roots, s=8, alpha=0.5, c=errors,
           cmap='RdYlGn_r', vmin=0, vmax=errors.max())
lim = max(analytic_roots.max(), numerical_roots.max()) * 1.05
ax.plot([0, lim], [0, lim], 'r--', linewidth=1, alpha=0.7, label='Perfect agreement')
ax.set_xlabel('Analytic root', fontsize=11)
ax.set_ylabel('Numerical root (bisection)', fontsize=11)
ax.set_title(f'Root Validation ({n_trials} trials)\nMax error: {errors.max():.2e}', fontsize=12)
ax.legend(fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.2)

# ── Panel 3: Discriminant and root structure ──
ax = axes[2]
t = np.linspace(0, 4, 500)

# Show several quadratic branches with same a, different (b,c)
a_fixed = -2.0
params = [
    (0.0, 0.5, '#1f77b4'),   # Purely quadratic
    (0.5, 0.5, '#ff7f0e'),   # Small linear term
    (1.0, 0.5, '#2ca02c'),   # Medium linear term
    (2.0, 0.5, '#d62728'),   # Large linear term
    (0.5, 1.5, '#9467bd'),   # Large quadratic term
]

for b, c, color in params:
    theta = a_fixed + b*t + c*t**2
    disc = b**2 - 4*a_fixed*c
    r = (-b + np.sqrt(disc)) / (2*c)
    ax.plot(t, theta, color=color, linewidth=2,
            label=f'b={b}, c={c} → r={r:.2f}')
    ax.plot(r, 0, 'o', color=color, markersize=8, zorder=5)

ax.axhline(y=0, color='k', linewidth=0.8)
ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('θ(t)', fontsize=11)
ax.set_title(f'Quadratic Branches (a={a_fixed} fixed)\nVarying b and c', fontsize=12)
ax.legend(fontsize=8, loc='upper left')
ax.set_xlim(0, 3.5)
ax.set_ylim(-3, 8)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_quadratic_roots.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_quadratic_roots.png")
