#!/usr/bin/env python3
"""
Visualization 3: Tropical Potential Surface and Descent Trajectories

Creates a heatmap of potential values on a 2D projection of the basis space,
showing how different starting points converge to the optimal basis through
exchange descent. Multiple trajectories are overlaid to illustrate the
basin of attraction structure.

This illustrates:
- The "landscape" metaphor for tropical optimization
- Convergence of multiple trajectories to the optimum
- The role of the depth certificate in controlling descent speed
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random

random.seed(42)

# Generate matroid
n, r = 7, 3
ground = list(range(n))
bases = [frozenset(c) for c in combinations(ground, r)]
basis_idx = {B: i for i, B in enumerate(bases)}

# Lorentzian valuation
val = {B: sum(i * i for i in B) for B in bases}
phi = {B: -val[B] for B in bases}

# 2D embedding: use PCA-like projection based on indicator vectors
indicators = np.zeros((len(bases), n))
for i, B in enumerate(bases):
    for e in B:
        indicators[i, e] = 1

# Simple 2D projection using first two principal directions
mean = indicators.mean(axis=0)
centered = indicators - mean
U, S, Vt = np.linalg.svd(centered, full_matrices=False)
coords = centered @ Vt[:2].T

# Greedy descent function
def greedy_descent_path(start_idx):
    path = [start_idx]
    current = start_idx
    for _ in range(100):
        B = bases[current]
        best_next = None
        best_phi = phi[B]
        for x in B:
            for y in ground:
                if y not in B:
                    Bn = (B - {x}) | {y}
                    if Bn in basis_idx and phi[Bn] < best_phi:
                        best_phi = phi[Bn]
                        best_next = basis_idx[Bn]
        if best_next is None:
            break
        path.append(best_next)
        current = best_next
    return path

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# --- Subplot 1: Potential heatmap with trajectories ---
phi_vals = np.array([phi[bases[i]] for i in range(len(bases))])
phi_norm = (phi_vals - phi_vals.min()) / (phi_vals.max() - phi_vals.min())

# Scatter plot of bases colored by potential
scatter = ax1.scatter(coords[:, 0], coords[:, 1], c=phi_vals,
                      cmap='RdYlGn_r', s=80, zorder=3,
                      edgecolors='gray', linewidth=0.5)
plt.colorbar(scatter, ax=ax1, label='Potential Φ', shrink=0.8)

# Draw multiple descent trajectories
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00',
          '#a65628', '#f781bf', '#999999']
num_trajectories = 8

# Pick diverse starting points
starts = sorted(range(len(bases)), key=lambda i: phi_vals[i], reverse=True)[:num_trajectories]

for t, start in enumerate(starts):
    path = greedy_descent_path(start)
    path_coords = coords[path]

    ax1.plot(path_coords[:, 0], path_coords[:, 1], '-',
             color=colors[t % len(colors)], linewidth=1.5, alpha=0.7, zorder=4)
    ax1.scatter(path_coords[0, 0], path_coords[0, 1],
                c=colors[t % len(colors)], s=150, marker='^', zorder=5,
                edgecolors='black', linewidth=1)

# Mark the optimal basis
opt_idx = min(range(len(bases)), key=lambda i: phi_vals[i])
ax1.scatter(coords[opt_idx, 0], coords[opt_idx, 1],
            c='lime', s=300, marker='*', zorder=6,
            edgecolors='darkgreen', linewidth=2, label='Optimal')

ax1.set_title('Descent Trajectories on Potential Landscape\n'
              'U(3,7) with Lorentzian valuation',
              fontsize=12, fontweight='bold')
ax1.set_xlabel('PC1', fontsize=10)
ax1.set_ylabel('PC2', fontsize=10)
ax1.legend(fontsize=9)

# --- Subplot 2: Potential vs step number for all trajectories ---
for t, start in enumerate(starts):
    path = greedy_descent_path(start)
    potentials = [phi[bases[i]] for i in path]
    steps = list(range(len(path)))

    ax2.plot(steps, potentials, 'o-', color=colors[t % len(colors)],
             linewidth=1.5, markersize=4, alpha=0.7,
             label=f'Start {set(bases[start])}' if t < 4 else None)

# Add theoretical bound line
max_phi = max(phi_vals)
min_phi = min(phi_vals)
gap = max_phi - min_phi
ax2.axhline(y=min_phi, color='green', linestyle='--', linewidth=2,
            alpha=0.5, label=f'Lower bound (lb={min_phi})')
ax2.fill_between([0, gap], [min_phi, min_phi], alpha=0.1, color='green')

ax2.set_title('Potential Decrease Along Descent Paths\n'
              'Each line = one trajectory',
              fontsize=12, fontweight='bold')
ax2.set_xlabel('Step number', fontsize=10)
ax2.set_ylabel('Potential Φ', fontsize=10)
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(alpha=0.3)

fig.suptitle('Tropical Exchange Descent: Landscape and Convergence',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_potential_surface.png', dpi=150, bbox_inches='tight')
print("Saved viz_potential_surface.png")
