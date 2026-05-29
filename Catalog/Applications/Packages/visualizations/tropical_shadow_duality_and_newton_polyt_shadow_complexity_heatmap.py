#!/usr/bin/env python3
"""
Visualization: Shadow Complexity Heatmap
==========================================

Visualizes the shadow complexity across all variable pairs as a heatmap.
Each cell (i,j) shows the size of the quadratic leaf shadow — the predicted
number of nonzero terms in ∂ᵢ∂ⱼp. This reveals the combinatorial structure
of second-derivative complexity from support data alone.

Uses matplotlib. Saves output as shadow_heatmap.png.
"""

import numpy as np
import matplotlib.pyplot as plt


def quad_leaf_shadow(support, i, j, n_vars):
    """Compute quadratic leaf shadow."""
    shadow = set()
    for alpha in support:
        alpha_list = list(alpha)
        if alpha_list[i] >= 1:
            alpha_list[i] -= 1
            if alpha_list[j] >= 1:
                alpha_list[j] -= 1
                shadow.add(tuple(alpha_list))
    return shadow


def generate_random_support(n_vars, n_terms, max_degree=5, seed=42):
    """Generate random support set."""
    rng = np.random.RandomState(seed)
    support = set()
    while len(support) < n_terms:
        exp = tuple(rng.randint(0, max_degree + 1, size=n_vars))
        support.add(exp)
    return support


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Hessian Shadow Complexity Maps',
             fontsize=15, fontweight='bold', y=1.02)

configs = [
    (3, 12, 4, 'n=3, |S|=12, deg≤4'),
    (4, 20, 5, 'n=4, |S|=20, deg≤5'),
    (5, 30, 4, 'n=5, |S|=30, deg≤4'),
]

for ax_idx, (n_vars, n_terms, max_deg, title) in enumerate(configs):
    ax = axes[ax_idx]
    support = generate_random_support(n_vars, n_terms, max_deg, seed=42 + ax_idx)

    # Compute shadow sizes
    matrix = np.zeros((n_vars, n_vars), dtype=int)
    for i in range(n_vars):
        for j in range(n_vars):
            shadow = quad_leaf_shadow(support, i, j, n_vars)
            matrix[i, j] = len(shadow)

    im = ax.imshow(matrix, cmap='YlOrRd', interpolation='nearest',
                   aspect='equal', vmin=0)

    # Annotate cells
    for i in range(n_vars):
        for j in range(n_vars):
            color = 'white' if matrix[i, j] > matrix.max() * 0.6 else 'black'
            ax.text(j, i, str(matrix[i, j]), ha='center', va='center',
                    fontsize=14, fontweight='bold', color=color)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlabel('j (second derivative)', fontsize=11)
    ax.set_ylabel('i (first derivative)', fontsize=11)
    ax.set_xticks(range(n_vars))
    ax.set_yticks(range(n_vars))
    ax.set_xticklabels([f'$x_{k}$' for k in range(n_vars)])
    ax.set_yticklabels([f'$x_{k}$' for k in range(n_vars)])
    plt.colorbar(im, ax=ax, shrink=0.8, label='Shadow size')

plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")
