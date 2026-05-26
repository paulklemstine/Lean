#!/usr/bin/env python3
"""
Visualization: Min-Max Lipschitz Property

Illustrates the key analytic lemma: |min(a_i) - min(b_i)| ≤ max|a_i - b_i|.
This is the mathematical backbone of the max-envelope inequality.
Shows the Lipschitz property across many random examples.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


random.seed(77)
N = 2000
dims = [2, 3, 5, 10]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

for idx, d in enumerate(dims):
    ax = axes[idx // 2][idx % 2]

    min_dists = []
    max_coord_dists = []

    for _ in range(N):
        a = [random.randint(0, 20) for _ in range(d)]
        b = [random.randint(0, 20) for _ in range(d)]

        min_a, min_b = min(a), min(b)
        min_dist = abs(min_a - min_b)

        coord_dists = [abs(a[i] - b[i]) for i in range(d)]
        max_coord = max(coord_dists)

        min_dists.append(min_dist)
        max_coord_dists.append(max_coord)

    ax.scatter(max_coord_dists, min_dists, alpha=0.2, s=10, c='#1565C0')

    max_val = max(max(min_dists), max(max_coord_dists)) + 1
    ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, linewidth=2,
            label='y = x (Lipschitz bound)')
    ax.fill_between([0, max_val], [0, 0], [0, max_val],
                     alpha=0.03, color='blue')

    ax.set_xlabel('max|aᵢ − bᵢ| (L∞ distance)', fontsize=10)
    ax.set_ylabel('|min(aᵢ) − min(bᵢ)|', fontsize=10)
    ax.set_title(f'Min-Max Lipschitz (d = {d})', fontsize=12)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(-0.5, max_val)
    ax.set_ylim(-0.5, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

fig.suptitle('The Min-Max Lipschitz Lemma: min is 1-Lipschitz w.r.t. L∞',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_lipschitz.png', dpi=150, bbox_inches='tight')
print("Saved viz_lipschitz.png")
