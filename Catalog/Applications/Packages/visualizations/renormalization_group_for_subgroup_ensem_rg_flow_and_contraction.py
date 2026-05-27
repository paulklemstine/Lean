#!/usr/bin/env python3
"""
Visualization 2: RG Flow and Pressure Contraction

Shows how pressure evolves under repeated coarse-graining:
- Left: Geometric decay of pressure under contractive RG (|λ| < 1)
- Right: Fixed-point behavior where intensive pressure stabilizes
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# ── Panel 1: Pressure contraction trajectories ──
ax1 = axes[0]
n_steps = 20
scales = [0.3, 0.5, 0.7, 0.9, 0.95]
colors_contract = plt.cm.viridis(np.linspace(0.1, 0.9, len(scales)))

P0 = 10.0
ns = np.arange(n_steps + 1)

for scale, color in zip(scales, colors_contract):
    pressures = [scale**n * P0 for n in ns]
    ax1.plot(ns, pressures, 'o-', color=color, markersize=4, linewidth=1.5,
             label=f'$\\lambda = {scale}$')

ax1.axhline(y=0, color='red', linewidth=1.5, linestyle='--', alpha=0.7,
            label='Fixed point ($\\Pi = 0$)')
ax1.set_xlabel('RG iteration $n$', fontsize=12)
ax1.set_ylabel(r'Pressure $\Pi(\mathcal{R}^n(E))$', fontsize=12)
ax1.set_title('Pressure Contraction: $\\Pi_n = \\lambda^n \\cdot \\Pi_0$', fontsize=14)
ax1.legend(fontsize=10, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.5, P0 + 1)

# ── Panel 2: Intensive pressure convergence ──
ax2 = axes[1]
F1 = 2.5
n_max = 15
ns = np.arange(1, n_max + 1)

# Exact product model: F(n) = n * F(1)
intensive_exact = np.full_like(ns, F1, dtype=float)

# Perturbed models with corrections
np.random.seed(42)
perturbations = [
    ("Exact: $F(n) = n F_1$", lambda n: n * F1, '#2196F3'),
    ("$F(n) = n F_1 + 0.5\\sin(n)$", lambda n: n * F1 + 0.5 * np.sin(n), '#FF5722'),
    ("$F(n) = n F_1 + \\sqrt{n}$", lambda n: n * F1 + np.sqrt(n), '#4CAF50'),
    ("$F(n) = n F_1 + 2\\log(n+1)$", lambda n: n * F1 + 2 * np.log(n + 1), '#9C27B0'),
]

for label, fn, color in perturbations:
    intensive = np.array([fn(n) / n for n in ns])
    ax2.plot(ns, intensive, 'o-', color=color, markersize=5, linewidth=1.5,
             label=label)

ax2.axhline(y=F1, color='red', linewidth=1.5, linestyle='--', alpha=0.7,
            label=f'$F_1 = {F1}$')
ax2.set_xlabel('Scale $n$', fontsize=12)
ax2.set_ylabel(r'Intensive pressure $F(n)/n$', fontsize=12)
ax2.set_title('Thermodynamic Limit: $F(n)/n \\to F_1$', fontsize=14)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(F1 - 1, F1 + 3)

plt.suptitle('RG Flow Dynamics and Convergence to Fixed Points',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_rg_flow.png', dpi=150, bbox_inches='tight')
print("Saved viz_rg_flow.png")
