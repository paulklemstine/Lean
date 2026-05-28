#!/usr/bin/env python3
"""
Visualization 1: Hessian Spectra of Partition Matroid Quadratic Leaves

Visualizes the eigenvalue spectra of both single-block and two-block
leaf Hessians, showing the key spectral dichotomy: single-block leaves
have one positive eigenvalue at (m-1) and (m-1) negative eigenvalues
at -1, while two-block leaves have eigenvalues ±√(n₁·n₂) and zeros.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def build_single_block_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def build_two_block_hessian(n1, n2):
    n = n1 + n2
    H = np.zeros((n, n))
    H[:n1, n1:] = 1.0
    H[n1:, :n1] = 1.0
    return H


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Single-block spectra
ax1 = axes[0]
cases_single = [2, 3, 4, 5, 6]
colors_single = plt.cm.Blues(np.linspace(0.4, 0.9, len(cases_single)))

for idx, m in enumerate(cases_single):
    H = build_single_block_hessian(m)
    eigs = np.linalg.eigvalsh(H)
    y_positions = np.full_like(eigs, idx)
    for e in eigs:
        color = 'red' if e > 0.1 else ('blue' if e < -0.1 else 'gray')
        ax1.scatter(e, idx, c=color, s=100, zorder=5, edgecolors='black', linewidth=0.5)

ax1.set_yticks(range(len(cases_single)))
ax1.set_yticklabels([f'm = {m}' for m in cases_single])
ax1.set_xlabel('Eigenvalue', fontsize=12)
ax1.set_title('Single-Block Leaves (J − I)', fontsize=14, fontweight='bold')
ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=-1, color='blue', linestyle=':', alpha=0.3, label='Gap = 1')
ax1.set_xlim(-2, 6)
ax1.grid(True, alpha=0.3)

# Add annotations
ax1.annotate('Positive eigenvalue\n= m − 1', xy=(4, 3.5), fontsize=9,
            color='red', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
ax1.annotate('Negative eigenvalue\n= −1 (gap = 1)', xy=(-1, 0.5), fontsize=9,
            color='blue', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.8))

# Panel 2: Two-block spectra
ax2 = axes[1]
cases_two = [(1, 1), (1, 2), (2, 2), (2, 3), (3, 3), (3, 4)]
for idx, (n1, n2) in enumerate(cases_two):
    H = build_two_block_hessian(n1, n2)
    eigs = np.linalg.eigvalsh(H)
    for e in eigs:
        color = 'red' if e > 0.1 else ('blue' if e < -0.1 else 'gray')
        size = 100 if abs(e) > 0.1 else 60
        ax2.scatter(e, idx, c=color, s=size, zorder=5, edgecolors='black', linewidth=0.5)

ax2.set_yticks(range(len(cases_two)))
ax2.set_yticklabels([f'n₁={n1}, n₂={n2}' for n1, n2 in cases_two])
ax2.set_xlabel('Eigenvalue', fontsize=12)
ax2.set_title('Two-Block Leaves (Off-Diagonal)', fontsize=14, fontweight='bold')
ax2.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax2.set_xlim(-5, 5)
ax2.grid(True, alpha=0.3)

ax2.annotate('+√(n₁·n₂)', xy=(3, 4.5), fontsize=9, color='red', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
ax2.annotate('−√(n₁·n₂)', xy=(-3, 4.5), fontsize=9, color='blue', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.8))
ax2.annotate('Rank 2:\nmany zeros', xy=(0.3, 1.5), fontsize=9, color='gray', ha='left',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgray', alpha=0.5))

# Legend
red_patch = mpatches.Patch(color='red', label='Positive eigenvalue')
blue_patch = mpatches.Patch(color='blue', label='Negative eigenvalue')
gray_patch = mpatches.Patch(color='gray', label='Zero eigenvalue')
fig.legend(handles=[red_patch, blue_patch, gray_patch],
          loc='lower center', ncol=3, fontsize=11,
          bbox_to_anchor=(0.5, -0.02))

fig.suptitle('Spectral Dichotomy of Partition Matroid Quadratic Leaves',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_hessian_spectra.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hessian_spectra.png")
