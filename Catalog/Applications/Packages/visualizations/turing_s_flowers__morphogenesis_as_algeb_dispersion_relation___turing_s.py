"""
Visualization 1: The Dispersion Relation — Heart of Turing Instability

This plot shows the dispersion relation h(q) for a reaction-diffusion system.
When h(q) dips below zero, the corresponding wavenumber is unstable, creating
spatial patterns. The shape of this curve determines whether spots, stripes,
or labyrinths emerge.

The key insight: h(q) is a quadratic in q = k², so pattern formation reduces
to analyzing a parabola — the simplest algebraic curve.
"""

import numpy as np
import matplotlib.pyplot as plt

# System parameters (activator-inhibitor, Gierer-Meinhardt type)
Du, Dv = 0.01, 1.0
a, b, c, d = 0.5, -1.0, 1.0, -1.5

alpha = Du * Dv
beta = a * Dv + d * Du
gamma = a * d - b * c
disc = beta**2 - 4 * alpha * gamma

q = np.linspace(0, 80, 500)
h = alpha * q**2 - beta * q + gamma

# Critical points
q_min = beta / (2 * alpha)
h_min = gamma - beta**2 / (4 * alpha)

# Roots
if disc > 0:
    q1 = (beta - np.sqrt(disc)) / (2 * alpha)
    q2 = (beta + np.sqrt(disc)) / (2 * alpha)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Dispersion relation
ax = axes[0]
ax.plot(q, h, 'b-', linewidth=2.5, label='$h(q) = \\alpha q^2 - \\beta q + \\gamma$')
ax.axhline(y=0, color='k', linewidth=0.8, linestyle='-')
ax.fill_between(q, h, 0, where=(h < 0), alpha=0.3, color='red',
                label='Unstable band')
ax.plot(q_min, h_min, 'ro', markersize=10, zorder=5,
        label=f'Minimum at $q_c = {q_min:.1f}$')

if disc > 0:
    ax.axvline(x=q1, color='gray', linewidth=0.8, linestyle='--', alpha=0.7)
    ax.axvline(x=q2, color='gray', linewidth=0.8, linestyle='--', alpha=0.7)
    ax.annotate(f'$q_1 = {q1:.1f}$', xy=(q1, 0), xytext=(q1-8, 0.15),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='gray'))
    ax.annotate(f'$q_2 = {q2:.1f}$', xy=(q2, 0), xytext=(q2+8, 0.15),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='gray'))

ax.set_xlabel('Wavenumber² ($q = k^2$)', fontsize=12)
ax.set_ylabel('$h(q)$', fontsize=12)
ax.set_title('Dispersion Relation: When Biology Makes Patterns', fontsize=13)
ax.legend(fontsize=10, loc='upper right')
ax.set_ylim(-0.5, 1.5)
ax.grid(True, alpha=0.3)

# Annotations
ax.annotate('Patterns form here!\n(modes grow exponentially)',
            xy=((q1 + q2)/2, h_min/2), fontsize=10, ha='center',
            color='red', fontweight='bold')

# Right: Parameter space
ax2 = axes[1]
Du_vals = np.logspace(-3, -0.5, 100)
Dv_vals = np.logspace(-1, 1, 100)
Du_grid, Dv_grid = np.meshgrid(Du_vals, Dv_vals)

# Compute Turing instability region
trJ = a + d
detJ = a * d - b * c
beta_grid = a * Dv_grid + d * Du_grid
disc_grid = beta_grid**2 - 4 * Du_grid * Dv_grid * detJ

turing_mask = (trJ < 0) & (detJ > 0) & (beta_grid > 0) & (disc_grid > 0)

ax2.contourf(Du_grid, Dv_grid, turing_mask.astype(float),
             levels=[-0.5, 0.5, 1.5], colors=['#f0f0f0', '#ff6b6b'], alpha=0.7)
ax2.contour(Du_grid, Dv_grid, turing_mask.astype(float),
            levels=[0.5], colors=['red'], linewidths=2)

# Mark our example system
ax2.plot(Du, Dv, 'k*', markersize=15, zorder=5, label='Example system')

ax2.set_xlabel('$D_u$ (activator diffusion)', fontsize=12)
ax2.set_ylabel('$D_v$ (inhibitor diffusion)', fontsize=12)
ax2.set_title('Turing Space: Where Patterns Live', fontsize=13)
ax2.set_xscale('log')
ax2.set_yscale('log')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Add text annotation
ax2.annotate('Turing\ninstability\nregion', xy=(0.01, 2.0),
             fontsize=12, color='red', fontweight='bold', ha='center')

plt.tight_layout()
plt.savefig('viz_dispersion.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_dispersion.png")
