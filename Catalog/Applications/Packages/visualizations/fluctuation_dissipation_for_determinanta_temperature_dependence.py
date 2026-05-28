#!/usr/bin/env python3
"""
Visualization 3: Temperature Dependence of DPP Response
=========================================================
Shows how the DPP susceptibility, conductance, and effective
resistance evolve as β (inverse temperature) varies.

At low β: weak coupling, nearly independent items
At high β: strong coupling, strong repulsion
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv, pinv, eigvalsh

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

np.random.seed(42)
n = 5
A = np.random.randn(n, 3)
L = A @ A.T

betas = np.linspace(0.01, 5.0, 100)

# Track quantities
trace_K_vals = []
trace_chi_vals = []
total_repulsion_vals = []
max_susc_dist_vals = []
min_eig_chi_vals = []
kirchhoff_vals = []

for beta in betas:
    K = compute_marginal_kernel(beta, L)
    chi = compute_susceptibility(beta, L)
    c = K ** 2

    trace_K_vals.append(np.trace(K))
    trace_chi_vals.append(np.trace(chi))
    total_repulsion_vals.append(
        sum(abs(chi[i, j]) for i in range(n) for j in range(n) if i != j))

    d_chi = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d_chi[i, j] = chi[i, i] + chi[j, j] - 2 * chi[i, j]
    max_susc_dist_vals.append(d_chi.max())

    eigs = eigvalsh(chi)
    min_eig_chi_vals.append(eigs.min())

    Lap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                Lap[i, j] = -c[i, j]
                Lap[i, i] += c[i, j]
    G = pinv(Lap)
    kirch = sum(G[i, i] + G[j, j] - 2 * G[i, j]
                for i in range(n) for j in range(i + 1, n))
    kirchhoff_vals.append(kirch)

fig, axes = plt.subplots(2, 3, figsize=(16, 9))
fig.suptitle('Temperature Dependence of DPP Response Theory',
             fontsize=15, fontweight='bold')

# Plot 1: Expected subset size
axes[0, 0].plot(betas, trace_K_vals, color='#1976D2', linewidth=2)
axes[0, 0].set_xlabel('β (inverse temperature)')
axes[0, 0].set_ylabel('E[|S|] = tr(K)')
axes[0, 0].set_title('Expected Subset Size')
axes[0, 0].grid(True, alpha=0.3)
axes[0, 0].axhline(y=n, color='gray', linestyle=':', alpha=0.5, label=f'n={n}')
axes[0, 0].legend()

# Plot 2: Total variance
axes[0, 1].plot(betas, trace_chi_vals, color='#388E3C', linewidth=2)
axes[0, 1].set_xlabel('β')
axes[0, 1].set_ylabel('tr(χ)')
axes[0, 1].set_title('Total Variance (Fluctuation)')
axes[0, 1].grid(True, alpha=0.3)

# Plot 3: Total repulsion
axes[0, 2].plot(betas, total_repulsion_vals, color='#D32F2F', linewidth=2)
axes[0, 2].set_xlabel('β')
axes[0, 2].set_ylabel('∑|χ_ij| (i≠j)')
axes[0, 2].set_title('Total Repulsion (Dissipation)')
axes[0, 2].grid(True, alpha=0.3)

# Plot 4: Max susceptibility distance
axes[1, 0].plot(betas, max_susc_dist_vals, color='#7B1FA2', linewidth=2)
axes[1, 0].set_xlabel('β')
axes[1, 0].set_ylabel('max d_χ(i,j)')
axes[1, 0].set_title('Max Susceptibility Distance')
axes[1, 0].grid(True, alpha=0.3)

# Plot 5: Minimum eigenvalue of χ
axes[1, 1].plot(betas, min_eig_chi_vals, color='#F57C00', linewidth=2)
axes[1, 1].set_xlabel('β')
axes[1, 1].set_ylabel('λ_min(χ)')
axes[1, 1].set_title('Min Eigenvalue of χ')
axes[1, 1].axhline(y=0, color='gray', linestyle=':', alpha=0.5)
axes[1, 1].grid(True, alpha=0.3)

# Plot 6: Kirchhoff index
axes[1, 2].plot(betas, kirchhoff_vals, color='#00796B', linewidth=2)
axes[1, 2].set_xlabel('β')
axes[1, 2].set_ylabel('Kirchhoff Index')
axes[1, 2].set_title('Total Effective Resistance')
axes[1, 2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_temperature.png', dpi=150, bbox_inches='tight')
print("Saved viz_temperature.png")
