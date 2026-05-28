#!/usr/bin/env python3
"""
Visualization 1: Pseudofinite Dimension Landscape

Visualizes how pseudofinite dimension dim(A) = log|A|/log|G| varies as a function
of subset size for different group sizes. Shows the fundamental relationship
between set size and dimension, and illustrates the key bounds (0 ≤ dim ≤ 1).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.family'] = 'serif'
matplotlib.rcParams['font.size'] = 11

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Dimension as function of |A|/|G| for different |G|
ax1 = axes[0]
group_sizes = [10, 100, 1000, 10000]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

for card_G, color in zip(group_sizes, colors):
    ratios = np.linspace(1/card_G, 1.0, 200)
    card_As = ratios * card_G
    dims = np.log(card_As) / np.log(card_G)
    ax1.plot(ratios, dims, color=color, linewidth=2, label=f'|G| = {card_G}')

ax1.set_xlabel('|A| / |G| (relative size)', fontsize=12)
ax1.set_ylabel('dim(A)', fontsize=12)
ax1.set_title('Dimension vs. Relative Size', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xlim(0, 1)
ax1.set_ylim(0, 1.05)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

# Panel 2: Coset cover bound illustration
ax2 = axes[1]
card_G = 1000
card_H_values = [10, 50, 100, 200]
C_values = range(1, 21)

for card_H, color in zip(card_H_values, colors):
    dim_H = np.log(card_H) / np.log(card_G)
    bounds = [dim_H + np.log(C) / np.log(card_G) for C in C_values]
    ax2.plot(C_values, bounds, color=color, linewidth=2,
             label=f'dim(H) = {dim_H:.2f}', marker='o', markersize=3)

ax2.set_xlabel('Number of cosets C', fontsize=12)
ax2.set_ylabel('Dimension bound', fontsize=12)
ax2.set_title('Coset Cover Bound\ndim(A) ≤ dim(H) + log(C)/log|G|',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='dim = 1')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.5)

# Panel 3: Dimension heatmap for (Z/pZ)^n
ax3 = axes[2]
primes = [2, 3, 5, 7, 11, 13]
n_values = range(1, 7)

dim_matrix = np.zeros((len(primes), len(n_values)))
for i, p in enumerate(primes):
    for j, n in enumerate(n_values):
        card_G = p ** n
        # Dimension of a "half-sized" subset
        card_A = max(1, card_G // 2)
        dim_matrix[i, j] = np.log(card_A) / np.log(card_G)

im = ax3.imshow(dim_matrix, cmap='viridis', aspect='auto', vmin=0.4, vmax=1.0)
ax3.set_xticks(range(len(n_values)))
ax3.set_xticklabels(n_values)
ax3.set_yticks(range(len(primes)))
ax3.set_yticklabels(primes)
ax3.set_xlabel('Exponent n', fontsize=12)
ax3.set_ylabel('Prime p', fontsize=12)
ax3.set_title('dim(⌊(ℤ/pℤ)ⁿ / 2⌋) in (ℤ/pℤ)ⁿ',
              fontsize=13, fontweight='bold')

# Add text annotations
for i in range(len(primes)):
    for j in range(len(n_values)):
        ax3.text(j, i, f'{dim_matrix[i,j]:.2f}',
                ha='center', va='center', color='white', fontsize=8,
                fontweight='bold')

cbar = plt.colorbar(im, ax=ax3, shrink=0.8)
cbar.set_label('Dimension', fontsize=10)

plt.tight_layout()
plt.savefig('viz_dimension_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_dimension_landscape.png")
