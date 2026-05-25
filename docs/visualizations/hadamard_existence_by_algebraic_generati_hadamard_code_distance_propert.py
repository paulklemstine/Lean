#!/usr/bin/env python3
"""
Visualization 3: Hadamard Code Distance Properties

Visualizes the Hamming distance distribution between codewords of the
Hadamard code, showing the equidistance property: all pairs of distinct
rows have Hamming distance exactly n/2. This is the visual proof of the
coding-theory bridge theorem.
"""
import numpy as np
import matplotlib.pyplot as plt

def hadamard(k):
    H = np.array([[1]])
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H

fig, axes = plt.subplots(2, 3, figsize=(15, 9))

for idx, k in enumerate([2, 3, 4]):
    n = 2**k
    H = hadamard(k).astype(int)

    # Compute pairwise dot products (should be n on diagonal, 0 off-diagonal)
    gram = H @ H.T

    ax1 = axes[0, idx]
    im = ax1.imshow(gram, cmap='RdBu_r', vmin=-n, vmax=n, interpolation='nearest')
    ax1.set_title(f'H·Hᵀ (order {n})', fontsize=12, fontweight='bold')
    ax1.set_xlabel('Row j')
    ax1.set_ylabel('Row i')
    plt.colorbar(im, ax=ax1, shrink=0.8)

    # Hamming distance matrix
    bits = ((1 - H) // 2).astype(int)
    dist_matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = np.sum(bits[i] != bits[j])

    ax2 = axes[1, idx]
    im2 = ax2.imshow(dist_matrix, cmap='viridis', interpolation='nearest')
    ax2.set_title(f'Hamming Distance (order {n})', fontsize=12, fontweight='bold')
    ax2.set_xlabel('Row j')
    ax2.set_ylabel('Row i')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    # Annotate: off-diagonal should all be n/2
    off_diag = dist_matrix[np.triu_indices(n, k=1)]
    ax2.text(0.02, 0.02, f'All off-diag = {set(off_diag)}',
             transform=ax2.transAxes, fontsize=9, color='white',
             verticalalignment='bottom',
             bbox=dict(boxstyle='round', facecolor='black', alpha=0.5))

fig.suptitle('Hadamard Matrices: Orthogonality and Equidistant Codes',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('hadamard_codes.png', dpi=150, bbox_inches='tight')
print("Saved hadamard_codes.png")
