#!/usr/bin/env python3
"""
Visualization: Eigenvalue Flow Phase Diagram

Visualizes the core mathematical concept: multiple eigenvalue branches flowing
through parameter space, with the stability boundary at the first zero crossing.
Shows how the minimum first root across all branches determines the phase
transition from stability to instability.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ── Panel 1: Affine vs Nonlinear comparison ──
ax = axes[0]
t = np.linspace(0, 4, 500)

# Affine branch
theta_aff = -2 + 1.2 * t
r_aff = 2.0 / 1.2

# Quadratic branch
theta_quad = -2 + 0.3 * t + 0.4 * t**2
disc = 0.3**2 + 4*2*0.4
r_quad = (-0.3 + np.sqrt(disc)) / (2*0.4)

# Cubic-like
theta_cub = -1.5 + 0.1*t + 0.02*t**2 + 0.3*t**3
idx_cub = np.where(theta_cub >= 0)[0]
r_cub = t[idx_cub[0]] if len(idx_cub) > 0 else 4.0

ax.plot(t, theta_aff, 'b-', linewidth=2.5, label='Affine: θ = -2 + 1.2t')
ax.plot(t, theta_quad, 'r-', linewidth=2.5, label='Quadratic: θ = -2 + 0.3t + 0.4t²')
ax.plot(t, theta_cub, 'g-', linewidth=2.5, label='Cubic: θ = -1.5 + 0.1t + 0.02t² + 0.3t³')

for r, c in [(r_aff, 'blue'), (r_quad, 'red'), (r_cub, 'green')]:
    ax.plot(r, 0, 'o', color=c, markersize=10, zorder=5)
    ax.axvline(x=r, color=c, linewidth=0.8, linestyle=':', alpha=0.5)

ax.axhline(y=0, color='k', linewidth=0.8)
ax.fill_between(t, -5, 0, alpha=0.04, color='blue')
ax.fill_between(t, 0, 15, alpha=0.04, color='red')
ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('θ(t)', fontsize=11)
ax.set_title('From Affine to Nonlinear:\nSame Principle, Richer Geometry', fontsize=12)
ax.legend(fontsize=8, loc='upper left')
ax.set_xlim(0, 3.5)
ax.set_ylim(-3, 8)
ax.grid(True, alpha=0.2)

# ── Panel 2: Multi-branch stability radius ──
ax = axes[1]
t = np.linspace(0, 5, 500)

branches = [
    (-3.0, 1.0, 0.15, '#1f77b4'),
    (-1.5, 0.2, 0.6,  '#ff7f0e'),
    (-4.0, 0.5, 0.3,  '#2ca02c'),
    (-2.5, 1.5, 0.08, '#d62728'),
    (-1.8, 0.8, 0.25, '#9467bd'),
]

roots = []
for a, b, c, color in branches:
    theta = a + b*t + c*t**2
    disc = b**2 - 4*a*c
    r = (-b + np.sqrt(disc)) / (2*c)
    roots.append(r)
    ax.plot(t, theta, color=color, linewidth=2)
    ax.plot(r, 0, 'o', color=color, markersize=8, zorder=5)

rho = min(roots)
critical_idx = roots.index(rho)
ax.axhline(y=0, color='k', linewidth=0.8)
ax.axvline(x=rho, color='purple', linewidth=2.5, linestyle='--',
           label=f'ρ = min root = {rho:.2f}')

# Shade stable region
ax.fill_between(t, -6, 20, where=(t < rho), alpha=0.06, color='green')
ax.fill_between(t, -6, 20, where=(t >= rho), alpha=0.06, color='red')

ax.annotate('STABLE', xy=(rho/2, -5), fontsize=14, fontweight='bold',
            color='green', ha='center', alpha=0.5)
ax.annotate('UNSTABLE', xy=(rho + (5-rho)/2, -5), fontsize=14, fontweight='bold',
            color='red', ha='center', alpha=0.5)

ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('Eigenvalue θ(t)', fontsize=11)
ax.set_title('Stability Radius = Earliest\nBranch Zero Crossing', fontsize=12)
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(0, 5)
ax.set_ylim(-6, 20)
ax.grid(True, alpha=0.2)

# ── Panel 3: Phase diagram in (branch, parameter) space ──
ax = axes[2]
n_branches = 8
np.random.seed(17)

branch_roots = []
for i in range(n_branches):
    a = -np.random.uniform(1, 5)
    b = np.random.uniform(0, 2)
    c = np.random.uniform(0.1, 1)
    disc = b**2 - 4*a*c
    r = (-b + np.sqrt(disc)) / (2*c)
    branch_roots.append(r)

rho = min(branch_roots)
critical = branch_roots.index(rho)

# Plot as horizontal bars
for i, r in enumerate(branch_roots):
    color = '#d62728' if i == critical else '#1f77b4'
    ax.barh(i, r, height=0.6, color=color, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.plot(r, i, 'ko', markersize=6, zorder=5)

ax.axvline(x=rho, color='red', linewidth=2.5, linestyle='--', label=f'ρ = {rho:.2f}')

# Legend
stable_patch = mpatches.Patch(color='#1f77b4', alpha=0.7, label='Other branches')
critical_patch = mpatches.Patch(color='#d62728', alpha=0.7, label='Critical branch')
ax.legend(handles=[stable_patch, critical_patch], fontsize=9, loc='upper right')

ax.set_xlabel('First positive root', fontsize=11)
ax.set_ylabel('Branch index j', fontsize=11)
ax.set_title('Phase Diagram: Branch Roots\nand Critical Branch', fontsize=12)
ax.set_yticks(range(n_branches))
ax.set_yticklabels([f'θ_{i+1}' for i in range(n_branches)])
ax.grid(True, alpha=0.2, axis='x')

plt.tight_layout()
plt.savefig('viz_eigenvalue_flows.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_eigenvalue_flows.png")
