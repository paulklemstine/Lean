#!/usr/bin/env python3
"""
Visualization 3: Legendre Duality and Thermodynamic Interpretation

Illustrates the geometric meaning of the Legendre transform connecting
pressure Λ(t) to rate function I(α). Shows supporting hyperplanes,
the duality between convex functions, and the thermodynamic phase diagram.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, exp


def pressure(q, t):
    return log((1 - q) + q * exp(t))

def pressure_deriv(q, t):
    mgf = (1 - q) + q * exp(t)
    return q * exp(t) / mgf

def rate_exact(q, alpha):
    if alpha <= 1e-12:
        return -log(1 - q)
    if alpha >= 1 - 1e-12:
        return -log(q)
    return alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / (1 - q))

def optimal_t(q, alpha):
    if alpha <= 1e-12 or alpha >= 1 - 1e-12:
        return None
    return log(alpha * (1 - q) / (q * (1 - alpha)))


q = 1/3  # Z/6Z

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Legendre transform geometry ---
ax = axes[0]
ts = np.linspace(-3, 6, 400)
Ls = [pressure(q, t) for t in ts]
ax.plot(ts, Ls, 'b-', linewidth=2.5, label='Λ(t)')

# Show supporting lines for specific α values
for alpha, color in [(0.2, '#4CAF50'), (0.5, '#FF9800'), (0.8, '#E91E63')]:
    t_star = optimal_t(q, alpha)
    if t_star is not None:
        # The supporting line: y = t*α - I(α)
        I_val = rate_exact(q, alpha)
        line_y = [t * alpha - I_val for t in ts]
        ax.plot(ts, line_y, '--', color=color, linewidth=1.2, alpha=0.7,
                label=f'slope α={alpha}')
        # Mark the tangent point
        ax.plot(t_star, pressure(q, t_star), 'o', color=color, markersize=8, zorder=5)
        # Mark the intercept = -I(α)
        ax.plot(0, -I_val, 'x', color=color, markersize=10, markeredgewidth=2)

ax.set_xlabel('t', fontsize=13)
ax.set_ylabel('Λ(t)', fontsize=13)
ax.set_title('Legendre Transform Geometry', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_ylim(-2, 5)
ax.annotate('I(α) = -intercept', xy=(0.1, -0.3), fontsize=9, color='gray')

# --- Panel 2: Convex duality ---
ax = axes[1]

# Rate function
alphas = np.linspace(0.001, 0.999, 400)
Is = [rate_exact(q, a) for a in alphas]
ax.plot(alphas, Is, 'r-', linewidth=2.5, label='I(α)')
ax.fill_between(alphas, 0, Is, alpha=0.1, color='red')

# Mark key points
ax.plot(q, 0, 'ko', markersize=10, zorder=5)
ax.annotate(f'I(q) = 0\nq = {q:.3f}', xy=(q, 0), xytext=(q + 0.15, 0.5),
            fontsize=11, fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='black'),
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# Show "typical" and "rare" regions
ax.axvspan(q - 0.05, q + 0.05, alpha=0.15, color='green', label='Typical (α ≈ q)')
ax.axvspan(0.7, 0.95, alpha=0.1, color='red', label='Rare (α >> q)')

ax.set_xlabel('α (deviation level)', fontsize=13)
ax.set_ylabel('I(α) (rate function)', fontsize=13)
ax.set_title('Rate Function: Cost of Rare Events', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 2.5)

# --- Panel 3: Thermodynamic phase diagram ---
ax = axes[2]

# Heatmap: -N * I(α) for different N and α
N_values = np.arange(1, 101)
alpha_values = np.linspace(0.01, 0.99, 100)
N_grid, A_grid = np.meshgrid(N_values, alpha_values)

log_prob_grid = np.zeros_like(N_grid, dtype=float)
for i, alpha in enumerate(alpha_values):
    I_val = rate_exact(q, alpha)
    for j, N in enumerate(N_values):
        log_prob_grid[i, j] = -N * I_val

# Clip for visualization
log_prob_grid = np.clip(log_prob_grid, -50, 0)

im = ax.pcolormesh(N_grid, A_grid, log_prob_grid, cmap='RdYlBu_r', shading='auto')
cbar = plt.colorbar(im, ax=ax, label='log P(D_N = α)', shrink=0.8)

# Mark the mean line
ax.axhline(y=q, color='white', linewidth=2, linestyle='--', label=f'Mean q={q:.3f}')

ax.set_xlabel('N (system size)', fontsize=13)
ax.set_ylabel('α (defect fraction)', fontsize=13)
ax.set_title('LDP Phase Diagram', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper right')

plt.tight_layout()
plt.savefig('viz_legendre_duality.png', dpi=150, bbox_inches='tight')
print("Saved viz_legendre_duality.png")
