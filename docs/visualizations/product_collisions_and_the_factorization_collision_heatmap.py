#!/usr/bin/env python3
"""
Visualization: Product collision heatmap for the set {6, 10, 21, 35}.

Shows the multiplication table of the generator set, highlighting
collisions where different pairs produce the same product.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def main():
    S = [6, 10, 21, 35]
    n = len(S)

    # Build multiplication table
    table = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            table[i, j] = S[i] * S[j]

    # Find collisions
    products = defaultdict(list)
    for i in range(n):
        for j in range(i, n):
            products[S[i] * S[j]].append((i, j))

    collision_mask = np.zeros((n, n), dtype=bool)
    for prod_val, pairs in products.items():
        if len(pairs) > 1:
            for i, j in pairs:
                collision_mask[i, j] = True
                collision_mask[j, i] = True

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Full multiplication table
    im1 = ax1.imshow(table, cmap='YlOrRd', aspect='equal')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels(S, fontsize=14)
    ax1.set_yticklabels(S, fontsize=14)
    ax1.set_title('Multiplication Table', fontsize=16)
    for i in range(n):
        for j in range(n):
            color = 'white' if table[i, j] > 400 else 'black'
            ax1.text(j, i, str(table[i, j]), ha='center', va='center',
                     fontsize=12, color=color, fontweight='bold')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # Right: Collision highlights
    display = np.where(collision_mask, table, 0).astype(float)
    display[display == 0] = np.nan

    ax2.imshow(np.ones((n, n)) * 0.9, cmap='Greys', vmin=0, vmax=1, aspect='equal')
    im2 = ax2.imshow(display, cmap='RdYlGn_r', aspect='equal', vmin=100, vmax=300)

    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xticklabels(S, fontsize=14)
    ax2.set_yticklabels(S, fontsize=14)
    ax2.set_title('Product Collisions (6×35 = 10×21 = 210)', fontsize=16)

    for i in range(n):
        for j in range(n):
            if collision_mask[i, j]:
                ax2.text(j, i, str(table[i, j]), ha='center', va='center',
                         fontsize=14, color='white', fontweight='bold',
                         bbox=dict(boxstyle='round,pad=0.3', facecolor='red', alpha=0.8))
            else:
                ax2.text(j, i, str(table[i, j]), ha='center', va='center',
                         fontsize=11, color='gray', alpha=0.5)

    plt.suptitle('Product Collisions in {6, 10, 21, 35}', fontsize=18, y=1.02)
    plt.tight_layout()
    plt.savefig('collision_heatmap.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved collision_heatmap.png")


if __name__ == "__main__":
    main()
