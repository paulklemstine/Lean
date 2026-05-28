#!/usr/bin/env python3
"""
Visualization: Graph Coloring Bridge — Antiferromagnetic Potts Model

Shows how the antiferromagnetic Potts model interpolates between
the uniform distribution over all configurations (β=0) and the
uniform distribution over proper graph colorings (β→-∞).
This visualizes the cross-domain bridge between statistical mechanics
and combinatorics.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def potts_partition_detailed(n, q, J, beta):
    """Return Z, weights, and coloring statistics."""
    configs = list(product(range(q), repeat=n))
    energies = []
    mono_counts = []
    is_proper = []

    for sigma in configs:
        sigma_arr = np.array(sigma)
        total = sum(J[i, j] for i in range(n) for j in range(n) if sigma_arr[i] == sigma_arr[j])
        energies.append(beta * total)

        # Count monochromatic edges
        mono = sum(1 for i in range(n) for j in range(i+1, n)
                   if sigma[i] == sigma[j] and J[i, j] > 0)
        mono_counts.append(mono)

        # Check proper coloring
        proper = all(sigma[i] != sigma[j]
                     for i in range(n) for j in range(i+1, n) if J[i, j] > 0)
        is_proper.append(proper)

    energies = np.array(energies)
    max_E = np.max(energies)
    weights = np.exp(energies - max_E)
    Z = np.sum(weights)
    weights /= Z

    return {
        'configs': configs,
        'weights': weights,
        'mono_counts': np.array(mono_counts),
        'is_proper': np.array(is_proper),
        'Z': Z * np.exp(max_E),
    }


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# ─── Graph: Path P₄ (4 vertices, 3 edges) ───
n = 4
q = 3
# Path graph adjacency
J_path = np.zeros((4, 4))
for i in range(3):
    J_path[i, i+1] = 1.0
    J_path[i+1, i] = 1.0

# ─── Graph: Cycle C₄ (4 vertices, 4 edges) ───
J_cycle = J_path.copy()
J_cycle[0, 3] = 1.0
J_cycle[3, 0] = 1.0

# ─── Graph: Complete K₄ (4 vertices, 6 edges) ───
J_complete = np.ones((4, 4)) - np.eye(4)

graphs = [
    (J_path, "Path P₄", 3),
    (J_cycle, "Cycle C₄", 4),
    (J_complete, "Complete K₄", 6),
]

betas = np.linspace(-8, 3, 60)

for col, (J, name, n_edges) in enumerate(graphs):
    # Top row: Weight distribution evolution
    ax_top = axes[0, col]

    proper_probs = []
    entropy_vals = []
    avg_mono = []

    for beta_val in betas:
        result = potts_partition_detailed(n, q, J, beta_val)
        weights = result['weights']
        is_proper = result['is_proper']
        mono = result['mono_counts']

        p_proper = np.sum(weights[is_proper])
        proper_probs.append(p_proper)

        # Shannon entropy
        H = -np.sum(weights[weights > 1e-15] * np.log(weights[weights > 1e-15]))
        entropy_vals.append(H)

        avg_mono.append(np.sum(weights * mono))

    ax_top.plot(betas, proper_probs, 'b-', linewidth=2, label='P(proper coloring)')
    ax_top.fill_between(betas, 0, proper_probs, alpha=0.1, color='blue')
    ax_top.axvline(x=0, color='gray', linestyle='--', alpha=0.4)
    ax_top.set_xlabel('β', fontsize=11)
    ax_top.set_ylabel('Probability', fontsize=11)
    ax_top.set_title(f'{name} ({n_edges} edges, q={q})', fontsize=13)
    ax_top.set_ylim(-0.05, 1.05)

    # Count proper colorings
    n_proper = sum(1 for s in product(range(q), repeat=n)
                   if all(s[i] != s[j] for i in range(n) for j in range(i+1, n) if J[i, j] > 0))
    n_total = q ** n
    ax_top.axhline(y=n_proper / n_total, color='green', linestyle=':',
                    alpha=0.5, label=f'uniform = {n_proper}/{n_total}')
    ax_top.legend(fontsize=9, loc='lower left')

    # Bottom row: Expected monochromatic edges
    ax_bot = axes[1, col]
    ax_bot.plot(betas, avg_mono, 'r-', linewidth=2)
    ax_bot.fill_between(betas, 0, avg_mono, alpha=0.1, color='red')
    ax_bot.axvline(x=0, color='gray', linestyle='--', alpha=0.4)
    ax_bot.set_xlabel('β', fontsize=11)
    ax_bot.set_ylabel('E[monochromatic edges]', fontsize=11)
    ax_bot.set_title(f'{name}: mono edge suppression', fontsize=13)

    # Annotate
    ax_bot.annotate('Antiferromagnetic\n(coloring regime)',
                     xy=(-6, 0.1), fontsize=9, color='blue', ha='center')
    ax_bot.annotate('Ferromagnetic\n(clustering)',
                     xy=(2, max(avg_mono) * 0.8), fontsize=9, color='red', ha='center')

plt.suptitle('Graph Coloring ↔ Antiferromagnetic Potts Model Bridge',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_graph_coloring.png', dpi=150, bbox_inches='tight')
print("Saved viz_graph_coloring.png")
