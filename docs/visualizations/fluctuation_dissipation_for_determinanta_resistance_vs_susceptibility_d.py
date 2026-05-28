#!/usr/bin/env python3
"""
Visualization 2: Resistance vs Susceptibility Distance
========================================================
Scatter plot comparing effective resistance R_eff(i,j) against
susceptibility distance d_χ(i,j) for all pairs across multiple
random DPP kernels. Demonstrates the proven inequality R_eff ≤ d_χ.

The diagonal line y=x shows where equality holds; all points
should lie below or on this line.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv, pinv

def compute_marginal_kernel(beta, L):
    n = L.shape[0]
    return (beta * L) @ inv(np.eye(n) + beta * L)

def compute_susceptibility(beta, L):
    K = compute_marginal_kernel(beta, L)
    n = K.shape[0]
    chi = -(K ** 2)
    for i in range(n):
        chi[i, i] = K[i, i] * (1 - K[i, i])
    return chi

def compute_eff_resistance_and_susc_dist(beta, L):
    K = compute_marginal_kernel(beta, L)
    chi = compute_susceptibility(beta, L)
    n = K.shape[0]
    c = K ** 2
    Lap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                Lap[i, j] = -c[i, j]
                Lap[i, i] += c[i, j]
    G = pinv(Lap)
    R_list, d_list = [], []
    for i in range(n):
        for j in range(i + 1, n):
            R = G[i, i] + G[j, j] - 2 * G[i, j]
            d = chi[i, i] + chi[j, j] - 2 * chi[i, j]
            R_list.append(R)
            d_list.append(d)
    return np.array(R_list), np.array(d_list)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Effective Resistance ≤ Susceptibility Distance (Proven Inequality)',
             fontsize=15, fontweight='bold')

betas = [0.5, 1.0, 2.0]
colors_map = {0.5: '#2196F3', 1.0: '#4CAF50', 2.0: '#FF5722'}

for idx, beta in enumerate(betas):
    ax = axes[idx]
    all_R, all_d = [], []
    for seed in range(30):
        np.random.seed(seed)
        n = np.random.choice([3, 4, 5, 6])
        A = np.random.randn(n, n)
        L = A @ A.T
        R, d = compute_eff_resistance_and_susc_dist(beta, L)
        all_R.extend(R)
        all_d.extend(d)

    all_R = np.array(all_R)
    all_d = np.array(all_d)

    ax.scatter(all_d, all_R, alpha=0.5, s=20, color=colors_map[beta],
               edgecolors='none')
    mx = max(all_d.max(), all_R.max()) * 1.1
    ax.plot([0, mx], [0, mx], 'k--', alpha=0.4, label='y = x')
    ax.set_xlabel('Susceptibility Distance d_χ(i,j)', fontsize=12)
    ax.set_ylabel('Effective Resistance R_eff(i,j)', fontsize=12)
    ax.set_title(f'β = {beta}', fontsize=13)
    ax.set_xlim(0, mx)
    ax.set_ylim(0, mx)
    ax.set_aspect('equal')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Count violations
    violations = np.sum(all_R > all_d + 1e-8)
    ax.text(0.05, 0.92, f'Violations: {violations}/{len(all_R)}',
            transform=ax.transAxes, fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('viz_resistance_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_resistance_comparison.png")
