#!/usr/bin/env python3
"""
Visualization: Eigenvalue Deformation of Period Matrices

Shows how the eigenvalues of the period matrix Q = C^T diag(ℓ) C change
continuously as edge lengths are deformed. This visualizes the stability
theorem (periodMatrix_stability_quadratic) and the convergence to
discrete invariants as ℓ → 1.

The plot shows eigenvalue trajectories as a function of a deformation
parameter t ∈ [0, 1], with ℓ(t) = (1-t)·ℓ_random + t·1.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import eigvalsh


def compute_period_matrix(C, lengths):
    CR = C.astype(float)
    return CR.T @ np.diag(lengths) @ CR


# ──────────────────────────────────────────────────
# Graph definitions (self-contained)
# ──────────────────────────────────────────────────

def theta_graph():
    C = np.array([[1, 1], [-1, 0], [0, -1]], dtype=int)
    return C, "Theta Graph (genus 2)"

def banana_4():
    C = np.zeros((4, 3), dtype=int)
    for j in range(3):
        C[0, j] = 1; C[j+1, j] = -1
    return C, "Banana B₄ (genus 3)"

def complete_4():
    edges = list(__import__('itertools').combinations(range(4), 2))
    m = len(edges)
    tree = [(0,1),(0,2),(0,3)]
    non_tree = [e for e in edges if e not in tree]
    edge_idx = {e: i for i, e in enumerate(edges)}
    g = 3
    C = np.zeros((m, g), dtype=int)
    for j, (u, v) in enumerate(non_tree):
        C[edge_idx[(u,v)], j] = 1
        if u != 0: C[edge_idx[(0,u)], j] = -1
        if v != 0: C[edge_idx[(0,v)], j] = 1
    return C, "Complete K₄ (genus 3)"


# ──────────────────────────────────────────────────
# Plotting
# ──────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Eigenvalue Deformation: Period Matrices Under Edge-Length Perturbation",
             fontsize=14, fontweight='bold')

np.random.seed(42)
graphs = [theta_graph(), banana_4(), complete_4()]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']

for ax, (C, name) in zip(axes, graphs):
    m, g = C.shape
    
    # Random initial lengths
    ℓ_start = np.random.uniform(0.3, 3.0, m)
    ℓ_end = np.ones(m)
    
    n_steps = 200
    t_values = np.linspace(0, 1, n_steps)
    eig_trajectories = np.zeros((n_steps, g))
    
    for i, t in enumerate(t_values):
        ℓ = (1-t) * ℓ_start + t * ℓ_end
        Q = compute_period_matrix(C, ℓ)
        eig_trajectories[i] = eigvalsh(Q)
    
    for j in range(g):
        ax.plot(t_values, eig_trajectories[:, j], 
                color=colors[j % len(colors)], linewidth=2,
                label=f'λ_{j+1}')
    
    # Mark discrete values
    for j in range(g):
        ax.axhline(y=eig_trajectories[-1, j], color=colors[j % len(colors)],
                   linestyle='--', alpha=0.3)
    
    ax.set_xlabel('t (0 = random, 1 = uniform)', fontsize=11)
    ax.set_ylabel('Eigenvalue', fontsize=11)
    ax.set_title(name, fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eigenvalue_deformation.png', dpi=150, bbox_inches='tight')
print("Saved eigenvalue_deformation.png")
