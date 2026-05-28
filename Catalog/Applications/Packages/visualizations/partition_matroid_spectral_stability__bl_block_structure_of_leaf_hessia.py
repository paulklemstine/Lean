#!/usr/bin/env python3
"""
Visualization 3: Block Structure of Partition Matroid Hessians

Shows the Hessian matrices for both leaf types as heatmaps, highlighting
the block structure that makes the spectral analysis tractable:
- Single-block: J - I (all-ones minus identity)
- Two-block: off-diagonal block [[0, J], [J^T, 0]]
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm


def build_single_block_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def build_two_block_hessian(n1, n2):
    n = n1 + n2
    H = np.zeros((n, n))
    H[:n1, n1:] = 1.0
    H[n1:, :n1] = 1.0
    return H


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Single-block Hessians
for idx, m in enumerate([3, 4, 5]):
    ax = axes[0, idx]
    H = build_single_block_hessian(m)
    norm = TwoSlopeNorm(vmin=-1, vcenter=0, vmax=1)
    im = ax.imshow(H, cmap='RdBu_r', norm=norm, aspect='equal')
    ax.set_title(f'Single-Block (m={m})\nJ − I', fontsize=12, fontweight='bold')

    # Add text values
    for i in range(m):
        for j in range(m):
            color = 'white' if abs(H[i, j]) > 0.5 else 'black'
            ax.text(j, i, f'{H[i,j]:.0f}', ha='center', va='center',
                   fontsize=10, color=color, fontweight='bold')

    # Mark diagonal
    for i in range(m):
        rect = plt.Rectangle((i-0.5, i-0.5), 1, 1, fill=False,
                            edgecolor='gold', linewidth=2)
        ax.add_patch(rect)

    ax.set_xticks(range(m))
    ax.set_yticks(range(m))
    eigs = np.linalg.eigvalsh(H)
    ax.set_xlabel(f'λ = {np.round(eigs, 1)}', fontsize=9)

# Row 2: Two-block Hessians
for idx, (n1, n2) in enumerate([(1, 2), (2, 3), (3, 3)]):
    ax = axes[1, idx]
    H = build_two_block_hessian(n1, n2)
    n = n1 + n2
    norm = TwoSlopeNorm(vmin=-0.5, vcenter=0, vmax=1)
    im = ax.imshow(H, cmap='RdBu_r', norm=norm, aspect='equal')
    ax.set_title(f'Two-Block (n₁={n1}, n₂={n2})\n[[0, J], [Jᵀ, 0]]',
                fontsize=12, fontweight='bold')

    # Add text values
    for i in range(n):
        for j in range(n):
            color = 'white' if abs(H[i, j]) > 0.5 else 'black'
            ax.text(j, i, f'{H[i,j]:.0f}', ha='center', va='center',
                   fontsize=10, color=color, fontweight='bold')

    # Mark blocks
    rect1 = plt.Rectangle((-0.5, -0.5), n1, n1, fill=False,
                          edgecolor='blue', linewidth=2, linestyle='--')
    rect2 = plt.Rectangle((n1-0.5, n1-0.5), n2, n2, fill=False,
                          edgecolor='blue', linewidth=2, linestyle='--')
    rect_cross1 = plt.Rectangle((n1-0.5, -0.5), n2, n1, fill=False,
                                edgecolor='red', linewidth=2)
    rect_cross2 = plt.Rectangle((-0.5, n1-0.5), n1, n2, fill=False,
                                edgecolor='red', linewidth=2)
    ax.add_patch(rect1)
    ax.add_patch(rect2)
    ax.add_patch(rect_cross1)
    ax.add_patch(rect_cross2)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    eigs = np.linalg.eigvalsh(H)
    ax.set_xlabel(f'λ = {np.round(eigs, 1)}', fontsize=9)

    # Label blocks
    if n1 > 1:
        ax.text(n1/2 - 0.5, n1/2 - 0.5, 'Block 1\n(zero)', fontsize=8,
               ha='center', va='center', color='blue', alpha=0.7)
    if n2 > 1:
        ax.text(n1 + n2/2 - 0.5, n1 + n2/2 - 0.5, 'Block 2\n(zero)', fontsize=8,
               ha='center', va='center', color='blue', alpha=0.7)

fig.suptitle('Block Structure of Partition Matroid Leaf Hessians',
            fontsize=16, fontweight='bold')

# Add colorbar
cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
cbar = fig.colorbar(im, cax=cbar_ax, label='Matrix entry value')

plt.tight_layout(rect=[0, 0, 0.9, 0.95])
plt.savefig('viz_block_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_block_structure.png")
