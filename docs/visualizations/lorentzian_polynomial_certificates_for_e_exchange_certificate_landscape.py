#!/usr/bin/env python3
"""
Visualization 1: Exchange Certificate Landscape

Visualizes the exchange inequality landscape for log-concave sequences.
Shows how ratio monotonicity (from log-concavity) creates a "downhill"
landscape where greedy optimization finds the global optimum.

The heatmap shows a[i]*a[j+1] - a[i+1]*a[j] for all (i,j) pairs.
When this is ≤ 0 everywhere (blue), the exchange certificate holds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

sequences = {
    "Binomial C(8,k)": [comb(8, k) for k in range(9)],
    "Geometric r=1.5": [1.5**k for k in range(9)],
    "Non-log-concave": [1, 3, 2, 7, 1, 8, 2, 5, 3],
}

for ax, (name, seq) in zip(axes, sequences.items()):
    n = len(seq)
    matrix = np.zeros((n - 1, n - 1))
    for i in range(n - 1):
        for j in range(n - 1):
            if i <= j:
                matrix[i, j] = seq[i] * seq[j + 1] - seq[i + 1] * seq[j]
            else:
                matrix[i, j] = np.nan

    # Determine if exchange certificate holds
    valid = all(seq[i] * seq[j + 1] <= seq[i + 1] * seq[j] + 1e-10
                for i in range(n - 1) for j in range(i, n - 1))

    vmax = max(abs(np.nanmin(matrix)), abs(np.nanmax(matrix)))
    if vmax == 0:
        vmax = 1
    im = ax.imshow(matrix, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                   origin='upper', aspect='equal')
    ax.set_xlabel('j', fontsize=12)
    ax.set_ylabel('i', fontsize=12)
    status = "✓ DLC holds" if valid else "✗ DLC fails"
    ax.set_title(f'{name}\n{status}', fontsize=11, fontweight='bold')
    plt.colorbar(im, ax=ax, shrink=0.8, label='a[i]·a[j+1] − a[i+1]·a[j]')

plt.suptitle('Exchange Certificate Landscape: a[i]·a[j+1] − a[i+1]·a[j]',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('exchange_landscape.png', dpi=150, bbox_inches='tight')
print("Saved exchange_landscape.png")
