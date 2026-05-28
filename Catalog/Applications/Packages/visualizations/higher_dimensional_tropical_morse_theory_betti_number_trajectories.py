#!/usr/bin/env python3
"""
Visualization 1: Betti Number Trajectories Under Tropical Filtration

Visualizes how Betti numbers β₀, β₁, β₂ evolve as simplices are added
in weight order for the toric code. Each jump corresponds to a critical
simplex attachment — either creating a homology class or killing one.

The key insight: the final β₁ value equals the number of logical qubits
in the CSS quantum code derived from the complex.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def build_toric_filtration(L):
    """Build filtration steps for L×L toric code."""
    steps = []
    w = 0
    # Vertices
    for _ in range(L * L):
        steps.append((0, w, True)); w += 1
    # Edges: L²-1 merges + L²+1 cycle creations
    for _ in range(L*L - 1):
        steps.append((1, w, False)); w += 1
    for _ in range(L*L + 1):
        steps.append((1, w, True)); w += 1
    # Faces: L²-1 boundary kills + 1 cycle creation
    for _ in range(L*L - 1):
        steps.append((2, w, False)); w += 1
    steps.append((2, w, True))
    return steps


def compute_trajectories(steps):
    """Compute Betti number trajectories."""
    trajs = {0: [], 1: [], 2: []}
    current = {0: 0, 1: 0, 2: 0}
    weights = []

    for dim, weight, is_cycle in steps:
        if is_cycle:
            current[dim] += 1
        elif dim > 0:
            current[dim - 1] -= 1
        weights.append(weight)
        for d in range(3):
            trajs[d].append(current[d])

    return weights, trajs


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

colors = {0: '#e74c3c', 1: '#3498db', 2: '#2ecc71'}
labels = {0: r'$\beta_0$ (components)', 1: r'$\beta_1$ (logical qubits)',
          2: r'$\beta_2$ (cavities)'}

for idx, L in enumerate([3, 4, 5, 7]):
    ax = axes[idx // 2][idx % 2]
    steps = build_toric_filtration(L)
    weights, trajs = compute_trajectories(steps)

    for d in range(3):
        ax.step(weights, trajs[d], where='post', color=colors[d],
                label=labels[d], linewidth=2, alpha=0.85)

    ax.set_title(f'Toric Code {L}×{L}  [n={2*L*L}, k=2, d={L}]',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('Filtration weight', fontsize=10)
    ax.set_ylabel('Betti number', fontsize=10)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, max(trajs[0]) + 1)

    # Annotate final values
    for d in range(3):
        final = trajs[d][-1]
        ax.annotate(f'β_{d}={final}', xy=(weights[-1], final),
                    fontsize=9, color=colors[d], fontweight='bold',
                    xytext=(5, 5), textcoords='offset points')

fig.suptitle('Tropical Morse Filtration: Betti Number Trajectories\n'
             'Each jump = critical simplex attachment (cycle creation or boundary kill)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_betti_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved viz_betti_trajectories.png")
