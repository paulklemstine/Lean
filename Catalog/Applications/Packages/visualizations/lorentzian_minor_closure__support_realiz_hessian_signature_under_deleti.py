#!/usr/bin/env python3
"""
Visualization: Hessian Signature Under Minor Operations

Shows how the eigenvalue spectrum of the Hessian matrix changes under
deletion and contraction operations on a Lorentzian polynomial support.
The key insight: deletion zeros out a row/column, preserving the
at-most-one-positive-eigenvalue property.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

np.random.seed(42)

def random_lorentzian_hessian(n: int) -> np.ndarray:
    """Generate a random symmetric matrix with at most one positive eigenvalue."""
    v = np.random.randn(n)
    v /= np.linalg.norm(v)
    neg_part = np.random.randn(n, n)
    neg_part = neg_part @ neg_part.T
    lam = np.random.uniform(0.5, 2.0)
    mu = np.random.uniform(1.0, 3.0)
    H = lam * np.outer(v, v) - mu * neg_part
    return (H + H.T) / 2

def zero_row_col(H: np.ndarray, i: int) -> np.ndarray:
    """Zero out row i and column i."""
    H_new = H.copy()
    H_new[i, :] = 0
    H_new[:, i] = 0
    return H_new

# Generate examples
n = 5
fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.3)

titles = []
matrices = []
eigenvalues_list = []

# Original Hessian
H_orig = random_lorentzian_hessian(n)
evals_orig = np.sort(np.linalg.eigvalsh(H_orig))[::-1]
titles.append(f'Original Hessian ({n}×{n})')
matrices.append(H_orig)
eigenvalues_list.append(evals_orig)

# After deleting coordinate 0
H_del0 = zero_row_col(H_orig, 0)
evals_del0 = np.sort(np.linalg.eigvalsh(H_del0))[::-1]
titles.append('After deletion at coord 0')
matrices.append(H_del0)
eigenvalues_list.append(evals_del0)

# After deleting coordinate 2
H_del2 = zero_row_col(H_orig, 2)
evals_del2 = np.sort(np.linalg.eigvalsh(H_del2))[::-1]
titles.append('After deletion at coord 2')
matrices.append(H_del2)
eigenvalues_list.append(evals_del2)

# After two deletions
H_del02 = zero_row_col(zero_row_col(H_orig, 0), 2)
evals_del02 = np.sort(np.linalg.eigvalsh(H_del02))[::-1]
titles.append('After 2 deletions (0 & 2)')
matrices.append(H_del02)
eigenvalues_list.append(evals_del02)

# Different random Hessian
H2 = random_lorentzian_hessian(n)
evals_h2 = np.sort(np.linalg.eigvalsh(H2))[::-1]
titles.append('Another Lorentzian Hessian')
matrices.append(H2)
eigenvalues_list.append(evals_h2)

H2_del = zero_row_col(H2, 1)
evals_h2_del = np.sort(np.linalg.eigvalsh(H2_del))[::-1]
titles.append('After deletion at coord 1')
matrices.append(H2_del)
eigenvalues_list.append(evals_h2_del)

for idx in range(6):
    ax = fig.add_subplot(gs[idx // 3, idx % 3])

    evals = eigenvalues_list[idx]
    colors = ['#4CAF50' if ev > 1e-10 else ('#F44336' if ev < -1e-10 else '#9E9E9E')
              for ev in evals]

    bars = ax.bar(range(len(evals)), evals, color=colors, edgecolor='black', linewidth=0.5)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_title(titles[idx], fontsize=11, fontweight='bold')
    ax.set_xlabel('Eigenvalue index')
    ax.set_ylabel('Value')
    ax.set_xticks(range(len(evals)))

    pos_count = sum(1 for ev in evals if ev > 1e-10)
    neg_count = sum(1 for ev in evals if ev < -1e-10)
    ax.text(0.98, 0.98, f'+: {pos_count}, −: {neg_count}',
           transform=ax.transAxes, ha='right', va='top',
           fontsize=9, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.suptitle('Hessian Eigenvalue Spectrum Under Deletion\n'
            '(Deletion preserves ≤1 positive eigenvalue)',
            fontsize=14, fontweight='bold', y=1.02)

plt.savefig('hessian_signature.png', dpi=150, bbox_inches='tight')
print("Saved hessian_signature.png")
