#!/usr/bin/env python3
"""
Visualization: Eigenvalue Landscape on (Z/nZ)^2

Produces a side-by-side comparison of eigenvalue landscapes for the local
walk vs an augmented walk, showing how shortcuts reshape the spectral landscape.
All functions are self-contained (no local imports).
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def laplace_eigenvalue(n, S, k1, k2):
    total = 0.0
    for s1, s2 in S:
        inner = (k1 * s1 + k2 * s2) % n
        total += 1 - np.cos(2 * np.pi * inner / n)
    return total

def local_generators(n):
    return [(1, 0), (n-1, 0), (0, 1), (0, n-1)]

n = 20
S_local = local_generators(n)

# Augmentation: add diagonal generators
A = [(1, 1), (n-1, n-1), (2, 3), (n-2, n-3), (5, 0), (n-5, 0)]
S_aug = list(set(S_local + A))

# Compute eigenvalue landscapes
eigs_local = np.zeros((n, n))
eigs_aug = np.zeros((n, n))
for k1 in range(n):
    for k2 in range(n):
        eigs_local[k1, k2] = laplace_eigenvalue(n, S_local, k1, k2)
        eigs_aug[k1, k2] = laplace_eigenvalue(n, S_aug, k1, k2)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Local eigenvalue landscape
im0 = axes[0].imshow(eigs_local, cmap='magma', origin='lower', aspect='equal')
plt.colorbar(im0, ax=axes[0], shrink=0.8)
axes[0].set_title(f'Local Walk (|S|={len(S_local)})', fontsize=12)
axes[0].set_xlabel('$k_2$')
axes[0].set_ylabel('$k_1$')

# Augmented eigenvalue landscape
im1 = axes[1].imshow(eigs_aug, cmap='magma', origin='lower', aspect='equal')
plt.colorbar(im1, ax=axes[1], shrink=0.8)
axes[1].set_title(f'Augmented Walk (|S|={len(S_aug)})', fontsize=12)
axes[1].set_xlabel('$k_2$')
axes[1].set_ylabel('$k_1$')

# Difference (improvement)
diff = eigs_aug - eigs_local
im2 = axes[2].imshow(diff, cmap='RdYlGn', origin='lower', aspect='equal')
plt.colorbar(im2, ax=axes[2], shrink=0.8)
axes[2].set_title('Eigenvalue Improvement', fontsize=12)
axes[2].set_xlabel('$k_2$')
axes[2].set_ylabel('$k_1$')

gap_local = eigs_local[eigs_local > 1e-10].min()
gap_aug = eigs_aug[eigs_aug > 1e-10].min()

plt.suptitle(f'Eigenvalue Landscape on $(\\mathbb{{Z}}/{n}\\mathbb{{Z}})^2$\n'
             f'Gap: {gap_local:.4f} → {gap_aug:.4f} (ratio {gap_aug/gap_local:.2f}×)',
             fontsize=13, y=1.05)
plt.tight_layout()
plt.savefig('viz_eigenvalue_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_eigenvalue_landscape.png")
