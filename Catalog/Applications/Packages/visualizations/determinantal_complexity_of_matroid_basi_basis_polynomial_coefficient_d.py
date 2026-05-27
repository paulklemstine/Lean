"""
Visualization: Determinantal Complexity Heatmap

Visualizes the basis polynomial coefficients (squared minor determinants)
for a matrix A as a heatmap over all r-subsets, showing how the "weight"
of the basis polynomial is distributed across different bases.

This makes the abstract notion of determinantal complexity tangible:
a low-complexity polynomial concentrates its weight on few bases,
while a high-complexity one spreads it across many.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def minor_det(A, cols):
    """Compute det of submatrix."""
    return np.linalg.det(A[:, list(cols)])


def basis_polynomial_coeffs(A):
    """Compute {S: (det A_S)^2} for all r-subsets S."""
    r, n = A.shape
    coeffs = {}
    for S in combinations(range(n), r):
        d = minor_det(A, S)
        coeffs[S] = d ** 2
    return coeffs


def eval_basis_poly(A, w):
    """Evaluate basis polynomial at weights w."""
    return np.linalg.det(A @ np.diag(w) @ A.T)


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Example 1: Uniform matroid U(2,4) — all subsets equally weighted
np.random.seed(42)
A1 = np.array([[1, 0, 1, 1],
               [0, 1, 1, -1]], dtype=float)
coeffs1 = basis_polynomial_coeffs(A1)
subsets1 = sorted(coeffs1.keys())
values1 = [coeffs1[s] for s in subsets1]
labels1 = [str(s) for s in subsets1]

bars1 = axes[0].bar(range(len(values1)), values1, color='steelblue', alpha=0.8)
axes[0].set_xticks(range(len(labels1)))
axes[0].set_xticklabels(labels1, rotation=45, fontsize=8)
axes[0].set_title(f'U(2,4)-like: dc ≤ 2\n(6 nonzero coefficients)', fontsize=11)
axes[0].set_ylabel('(det A_S)²', fontsize=10)
axes[0].set_xlabel('Basis S', fontsize=10)

# Example 2: Graphic matroid — sparser support
A2 = np.array([[1, 1, 1, 0, 0, 0],
               [1, 0, 0, 1, 1, 0],
               [0, 1, 0, 1, 0, 1]], dtype=float)
coeffs2 = basis_polynomial_coeffs(A2)
subsets2 = sorted(coeffs2.keys())
values2 = [coeffs2[s] for s in subsets2]
labels2 = [str(s) for s in subsets2]

bars2 = axes[1].bar(range(len(values2)), values2, color='coral', alpha=0.8)
axes[1].set_xticks(range(len(labels2)))
axes[1].set_xticklabels(labels2, rotation=45, fontsize=7)
axes[1].set_title(f'K4 graphic: dc ≤ 3\n({len(subsets2)} nonzero coefficients)', fontsize=11)
axes[1].set_ylabel('(det A_S)²', fontsize=10)
axes[1].set_xlabel('Basis S', fontsize=10)

# Example 3: Block diagonal — factored structure
A_left = np.array([[1, 1]], dtype=float)
A_right = np.array([[1, 0, 1],
                    [0, 1, 1]], dtype=float)
A3 = np.zeros((3, 5))
A3[0, :2] = A_left[0]
A3[1:, 2:] = A_right
coeffs3 = basis_polynomial_coeffs(A3)
subsets3 = sorted(coeffs3.keys())
values3 = [coeffs3[s] for s in subsets3]
labels3 = [str(s) for s in subsets3]

bars3 = axes[2].bar(range(len(values3)), values3, color='seagreen', alpha=0.8)
axes[2].set_xticks(range(len(labels3)))
axes[2].set_xticklabels(labels3, rotation=45, fontsize=7)
axes[2].set_title(f'Block diagonal: dc ≤ 1+2 = 3\n({len(subsets3)} nonzero coefficients)', fontsize=11)
axes[2].set_ylabel('(det A_S)²', fontsize=10)
axes[2].set_xlabel('Basis S', fontsize=10)

fig.suptitle('Basis Polynomial Coefficient Distribution\n(Determinantal Complexity Visualization)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_complexity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_heatmap.png")
