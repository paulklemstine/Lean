#!/usr/bin/env python3
"""
Visualization: Certificate Inequality Heatmap

Shows the mixed directional log-concavity condition as a heatmap
for coefficient matrices of quadratic polynomials. Compares
Lorentzian vs non-Lorentzian examples, revealing how the
coefficient inequality pattern encodes spectral information.
"""

import numpy as np
import matplotlib.pyplot as plt


def multiindices(n, d):
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in multiindices(n - 1, d - first):
            result.append((first,) + rest)
    return result


def compute_inequality_matrix(A, n):
    """For a quadratic form matrix A, compute the inequality gap matrix.

    Gap(i,j) = A(i,j)² - A(i,i)*A(j,j)

    Positive gap means the mixed LC condition is satisfied for that pair.
    Lorentzian iff all gaps ≥ 0 (for 2×2 case).
    """
    gap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            gap[i, j] = A[i, j]**2 - A[i, i] * A[j, j]
    return gap


fig, axes = plt.subplots(2, 3, figsize=(15, 10))

examples = [
    ("Rank-1: u=[1,2,3]\n(Lorentzian ✓)",
     np.outer([1, 2, 3], [1, 2, 3])),
    ("Rank-1: u=[1,1,1]\n(Lorentzian ✓)",
     np.outer([1, 1, 1], [1, 1, 1])),
    ("Identity + rank-1\n(Lorentzian ✓)",
     np.outer([2, 1, 1], [2, 1, 1]) + 0.01 * np.eye(3)),
    ("Counterexample\n[[1,1,1],[1,1,-1],[1,-1,1]]\n(NOT Lorentzian ✗)",
     np.array([[1, 1, 1], [1, 1, -1], [1, -1, 1]], dtype=float)),
    ("Nonneg counterexample\n[[1,1,1],[1,1,10],[1,10,1]]\n(NOT Lorentzian ✗)",
     np.array([[1, 1, 1], [1, 1, 10], [1, 10, 1]], dtype=float)),
    ("Random Lorentzian\n(rank-1 + neg semidef)\n(Lorentzian ✓)",
     None),  # Will be generated
]

np.random.seed(42)
u = np.random.randn(3)
N = -np.random.randn(3, 3)
N = N @ N.T
examples[5] = (examples[5][0], np.outer(u, u) + 0.3 * N)

for idx, (title, A) in enumerate(examples):
    row, col = idx // 3, idx % 3
    ax = axes[row, col]

    n = A.shape[0]
    gap = compute_inequality_matrix(A, n)

    # Check Lorentzian
    eigs = np.linalg.eigvalsh(A)
    is_lor = np.sum(eigs > 1e-10) <= 1
    all_gaps_nonneg = np.all(gap >= -1e-10)

    # Heatmap
    vmax = max(abs(gap.max()), abs(gap.min()), 1e-6)
    im = ax.imshow(gap, cmap='RdYlGn', vmin=-vmax, vmax=vmax,
                    aspect='equal')
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Annotate cells
    for i in range(n):
        for j in range(n):
            color = 'white' if abs(gap[i, j]) > 0.5 * vmax else 'black'
            ax.text(j, i, f'{gap[i,j]:.2f}', ha='center', va='center',
                     fontsize=9, color=color, fontweight='bold')

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('j')
    ax.set_ylabel('i')

    status = "✓ Lor" if is_lor else "✗ NOT Lor"
    ineq_status = "gaps≥0" if all_gaps_nonneg else "gaps<0 exist"
    ax.set_title(f'{title}\n{status}, {ineq_status}', fontsize=9)

fig.suptitle('Mixed Log-Concavity Gap: A(i,j)² − A(i,i)·A(j,j)\n'
             'Green = gap ≥ 0 (inequality satisfied), '
             'Red = gap < 0 (violated)',
             fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_certificate_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_heatmap.png")
