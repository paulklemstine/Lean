"""
Visualization 1: Spectral Gap Landscape for Uniform Matroid Families

This script visualizes how the eigenvalue structure of the canonical leaf
Hessian (J - I) varies with the leaf dimension m = n - r + 2. The key
insight is that the spectral gap (= 1) is constant across all dimensions,
while the positive eigenvalue grows linearly with m.

The plot shows:
- Eigenvalues of J - I as a function of m
- The constant spectral gap of 1
- The normalized gap 1/(m-1) decaying with dimension
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute eigenvalue data
m_values = list(range(2, 21))
pos_eigenvalues = [m - 1 for m in m_values]
neg_eigenvalues = [-1 for _ in m_values]
normalized_gaps = [1.0 / (m - 1) for m in m_values]
stability_radii = [1.0 / m for m in m_values]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Spectral Structure of Uniform Matroid Leaf Hessians',
             fontsize=16, fontweight='bold')

# Panel 1: Eigenvalues vs dimension
ax1 = axes[0, 0]
ax1.plot(m_values, pos_eigenvalues, 'b-o', label=r'$\lambda_+ = m-1$', markersize=5)
ax1.axhline(y=-1, color='r', linestyle='--', linewidth=2, label=r'$\lambda_- = -1$')
ax1.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax1.fill_between(m_values, -1, 0, alpha=0.1, color='red', label='Gap region')
ax1.set_xlabel('Leaf dimension m', fontsize=12)
ax1.set_ylabel('Eigenvalue', fontsize=12)
ax1.set_title('Eigenvalues of J - I', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Normalized gap
ax2 = axes[0, 1]
ax2.plot(m_values, normalized_gaps, 'g-s', label=r'$|\lambda_-|/\lambda_+ = 1/(m-1)$',
         markersize=5, color='darkgreen')
ax2.set_xlabel('Leaf dimension m', fontsize=12)
ax2.set_ylabel('Normalized gap', fontsize=12)
ax2.set_title('Normalized Spectral Gap', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.1)

# Panel 3: Stability radius
ax3 = axes[1, 0]
ax3.plot(m_values, stability_radii, 'r-^', label=r'$\rho = 1/m$', markersize=5,
         color='darkred')
ax3.set_xlabel('Leaf dimension m', fontsize=12)
ax3.set_ylabel('Stability radius (entrywise)', fontsize=12)
ax3.set_title('Entrywise Stability Radius', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Panel 4: Heatmap of leaf Hessian for m=6
ax4 = axes[1, 1]
m_example = 6
H = np.ones((m_example, m_example)) - np.eye(m_example)
im = ax4.imshow(H, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax4.set_title(f'Leaf Hessian J - I (m={m_example})', fontsize=13)
ax4.set_xlabel('Column index', fontsize=12)
ax4.set_ylabel('Row index', fontsize=12)
for i in range(m_example):
    for j in range(m_example):
        ax4.text(j, i, f'{H[i,j]:.0f}', ha='center', va='center',
                fontsize=14, fontweight='bold',
                color='white' if abs(H[i,j]) > 0.5 else 'black')
plt.colorbar(im, ax=ax4, shrink=0.8)

plt.tight_layout()
plt.savefig('spectral_gap_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: spectral_gap_landscape.png")
