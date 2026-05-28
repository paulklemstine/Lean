#!/usr/bin/env python3
"""
Visualization: Hessian Spectral Encoding Bridge

Visualizes the cross-domain theorem: hessian_recovers_matrix.
Shows how matrix eigenvalue structure maps to Lorentzian signature
through the polynomial encoding P_A(x) = Σ A[i,j] x_i x_j.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Generate example matrices with different spectral signatures
examples = [
    ("Lorentzian\n(1 pos eigenvalue)",
     np.array([[3.0, 0, 0], [0, -1, 0], [0, 0, -2]]),
     True),
    ("Positive Definite\n(all pos, NOT Lorentzian)",
     np.array([[2.0, 0.5, 0], [0.5, 3, 0], [0, 0, 1]]),
     False),
    ("Two Positive\n(NOT Lorentzian)",
     np.array([[2.0, 0, 0], [0, 1, 0], [0, 0, -4]]),
     False),
    ("Negative Semi-Definite\n(Lorentzian, 0 pos)",
     np.array([[-1.0, 0, 0], [0, -2, 0], [0, 0, -1]]),
     True),
    ("Mixed with Off-Diag\n(Lorentzian)",
     np.array([[5.0, 1, 0], [1, -2, 0], [0, 0, -3]]),
     True),
    ("Mixed with Off-Diag\n(NOT Lorentzian)",
     np.array([[3.0, 2, 0], [2, 3, 0], [0, 0, -1]]),
     False),
]

for idx, (title, A, expected_lor) in enumerate(examples):
    ax = axes[idx // 3][idx % 3]

    # Compute Hessian = A + A^T = 2A for symmetric
    H = A + A.T
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > 1e-10)
    is_lorentzian = n_positive <= 1

    # Plot eigenvalue spectrum
    colors = ['green' if ev > 1e-10 else ('red' if ev < -1e-10 else 'gray')
              for ev in eigenvalues]

    bars = ax.bar(range(len(eigenvalues)), eigenvalues, color=colors, alpha=0.7,
                  edgecolor='black', linewidth=0.5)

    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xlabel('Eigenvalue index', fontsize=9)
    ax.set_ylabel('Eigenvalue', fontsize=9)

    status = "✓ Lorentzian" if is_lorentzian else "✗ NOT Lorentzian"
    color = 'darkgreen' if is_lorentzian else 'darkred'
    ax.text(0.5, 0.95, status, transform=ax.transAxes,
            fontsize=11, fontweight='bold', color=color,
            ha='center', va='top',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

    ax.text(0.5, 0.82, f'pos: {n_positive}, neg: {np.sum(eigenvalues < -1e-10)}',
            transform=ax.transAxes, fontsize=9, ha='center', va='top')

    for bar, ev in zip(bars, eigenvalues):
        ax.text(bar.get_x() + bar.get_width() / 2, ev,
                f'{ev:.1f}', ha='center',
                va='bottom' if ev >= 0 else 'top', fontsize=8)

plt.suptitle('Hessian Spectral Encoding: Matrix Eigenvalues → Lorentzian Signature\n'
             'H(P_A) = A + Aᵀ  |  Lorentzian ⟺ at most 1 positive eigenvalue',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('hessian_encoding.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved hessian_encoding.png")
