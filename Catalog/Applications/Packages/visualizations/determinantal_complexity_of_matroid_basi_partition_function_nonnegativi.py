"""
Visualization: Nonnegativity of the Partition Function

Demonstrates the key cross-domain theorem:
    eval(basisPoly(A), w) >= 0 for all w >= 0

This visualizes the partition function Z(w) = det(A * diag(w) * A^T)
as a function of two weights (with others fixed), showing it is
always nonneg in the positive quadrant.

This is the formal bridge between:
- Matroid theory (basis polynomials)
- Probability (partition functions)
- Linear algebra (positive semidefiniteness)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm


def eval_basis_poly(A, w):
    """Evaluate basis polynomial at weights w via Gram determinant."""
    return np.linalg.det(A @ np.diag(w) @ A.T)


# Setup
fig, axes = plt.subplots(1, 3, figsize=(18, 5), subplot_kw={'projection': '3d'})

# Three different matrices to show universality
matrices = [
    ("Rank 1 (1×3)", np.array([[1, 2, 3]], dtype=float)),
    ("Rank 2 (2×4)", np.array([[1, 0, 1, 1], [0, 1, 1, -1]], dtype=float)),
    ("Rank 3 (3×5)", np.array([[1, 0, 0, 1, 1], [0, 1, 0, 1, -1], [0, 0, 1, 0, 1]], dtype=float))
]

for idx, (title, A) in enumerate(matrices):
    r, n = A.shape
    
    # Vary the first two weights, fix others at 1
    w1_range = np.linspace(0, 3, 50)
    w2_range = np.linspace(0, 3, 50)
    W1, W2 = np.meshgrid(w1_range, w2_range)
    Z = np.zeros_like(W1)
    
    for i in range(W1.shape[0]):
        for j in range(W1.shape[1]):
            w = np.ones(n)
            w[0] = W1[i, j]
            w[1] = W2[i, j]
            Z[i, j] = eval_basis_poly(A, w)
    
    ax = axes[idx]
    surf = ax.plot_surface(W1, W2, Z, cmap=cm.viridis, alpha=0.8,
                           linewidth=0, antialiased=True)
    
    # Add the z=0 plane for reference
    ax.plot_surface(W1, W2, np.zeros_like(Z), alpha=0.1, color='red')
    
    ax.set_xlabel('w₁', fontsize=10)
    ax.set_ylabel('w₂', fontsize=10)
    ax.set_zlabel('Z(w)', fontsize=10)
    ax.set_title(f'{title}\nmin Z = {Z.min():.4f} ≥ 0 ✓', fontsize=11)
    ax.view_init(elev=25, azim=-60)

fig.suptitle('Partition Function Nonnegativity: Z(w) = det(A·D_w·Aᵀ) ≥ 0 for w ≥ 0\n'
             '(Theorem: eval_basisPolyOfMatrix_nonneg)',
             fontsize=13, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_nonnegativity.png', dpi=150, bbox_inches='tight')
print("Saved viz_nonnegativity.png")
