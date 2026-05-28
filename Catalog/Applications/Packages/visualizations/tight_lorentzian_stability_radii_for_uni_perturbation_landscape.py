#!/usr/bin/env python3
"""
Visualization: Perturbation Landscape and Phase Boundary

This script visualizes how Lorentzian signature breaks down under
perturbation, showing the phase boundary between "Lorentzian" and
"non-Lorentzian" regimes for the uniform matroid leaf Hessian.

Panel 1: Quadratic form contour plot on 2D subspace
Panel 2: Phase diagram — Lorentzianity vs perturbation type and magnitude
Panel 3: Stability ratio ρ·C(n,r)/g across parameter space
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def check_lorentzian(H, tol=1e-10):
    eigs = np.linalg.eigvalsh(H)
    return int(np.sum(eigs > tol)) <= 1


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Quadratic form on 2D subspace for m=4
m = 4
H = leaf_hessian(m)

# Project onto 2D: v = α·(1,1,1,1)/2 + β·(1,-1,0,0)/√2
e_all = np.ones(m) / np.sqrt(m)
e_orth = np.zeros(m)
e_orth[0] = 1 / np.sqrt(2)
e_orth[1] = -1 / np.sqrt(2)

alphas = np.linspace(-3, 3, 200)
betas = np.linspace(-3, 3, 200)
A, B = np.meshgrid(alphas, betas)
Q = np.zeros_like(A)

for i in range(len(alphas)):
    for j in range(len(betas)):
        v = A[j, i] * e_all + B[j, i] * e_orth
        Q[j, i] = v @ H @ v

contour = axes[0].contourf(A, B, Q, levels=30, cmap='RdBu_r')
axes[0].contour(A, B, Q, levels=[0], colors='black', linewidths=2)
axes[0].set_xlabel('α (all-ones direction)', fontsize=11)
axes[0].set_ylabel('β (orthogonal direction)', fontsize=11)
axes[0].set_title('Quadratic Form Q(αe₊ + βe₋)', fontsize=13)
plt.colorbar(contour, ax=axes[0], shrink=0.8)

# Panel 2: Phase diagram
m_vals = range(3, 16)
t_vals = np.linspace(0, 2.5, 100)

phase = np.zeros((len(list(m_vals)), len(t_vals)))
for i, m in enumerate(m_vals):
    H = leaf_hessian(m)
    for j, t in enumerate(t_vals):
        # Diagonal perturbation
        H_pert = H + t * np.eye(m)
        phase[i, j] = 1 if check_lorentzian(H_pert) else 0

im2 = axes[1].imshow(phase, aspect='auto', origin='lower',
                       extent=[t_vals[0], t_vals[-1], 2.5, 15.5],
                       cmap='RdYlGn', interpolation='nearest')
axes[1].axvline(x=1.0, color='white', linestyle='--', linewidth=2, label='Gap = 1')
axes[1].set_xlabel('Diagonal perturbation t', fontsize=11)
axes[1].set_ylabel('Leaf dimension m', fontsize=11)
axes[1].set_title('Phase Diagram: Lorentzian (green) vs Not (red)', fontsize=13)
axes[1].legend(fontsize=10, loc='upper right')

# Panel 3: Stability ratio heatmap
max_n = 14
ns = range(4, max_n + 1)
ratios = {}

for n in ns:
    for r in range(2, n - 1):
        m = n - r + 2
        # For diagonal perturbation, threshold is exactly 1
        emp_rad = 1.0  # Exact for diagonal
        gap = 1.0
        binom = comb(n, r)
        ratio = emp_rad * binom / gap
        ratios[(n, r)] = ratio

# Create heatmap
max_r = max(r for n, r in ratios.keys())
min_r = 2
ratio_grid = np.full((max_n - 3, max_r - 1), np.nan)

for (n, r), ratio in ratios.items():
    ratio_grid[n - 4, r - 2] = np.log10(ratio)

im3 = axes[2].imshow(ratio_grid.T, aspect='auto', origin='lower',
                       extent=[3.5, max_n + 0.5, 1.5, max_r + 0.5],
                       cmap='viridis', interpolation='nearest')
axes[2].set_xlabel('n (total variables)', fontsize=11)
axes[2].set_ylabel('r (matroid rank)', fontsize=11)
axes[2].set_title('log₁₀(ρ · C(n,r) / g)', fontsize=13)
plt.colorbar(im3, ax=axes[2], shrink=0.8, label='log₁₀(ratio)')

plt.tight_layout()
plt.savefig('perturbation_landscape.png', dpi=150, bbox_inches='tight')
print("Saved perturbation_landscape.png")
