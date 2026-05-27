#!/usr/bin/env python3
"""
Visualization 1: Pairwise Mutual Information Heatmap

Visualizes the pairwise mutual information matrix I(X_i; X_j) for a
uniform matroid distribution, alongside the certified chi-squared upper bound.
Demonstrates that Lorentzian negativity suppresses pairwise information,
with MI always below the χ² bound from kl_le_chi_sq_four.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def compute_mi_and_bounds(n, r):
    """Compute MI matrix and chi-squared bounds for U(n,r)."""
    # Build uniform matroid
    total = comb(n, r)
    subsets = list(combinations(range(n), r))
    weights = {frozenset(s): 1.0/total for s in subsets}

    def coord_prob(i):
        return sum(w for s, w in weights.items() if i in s)

    def pair_joint(i, j):
        return sum(w for s, w in weights.items() if i in s and j in s)

    def coord_cov(i, j):
        return pair_joint(i, j) - coord_prob(i) * coord_prob(j)

    def pairwise_mi(i, j):
        p, q = coord_prob(i), coord_prob(j)
        rv = pair_joint(i, j)
        mi = 0.0
        for pxy, pxpy in [(rv, p*q), (p-rv, p*(1-q)),
                           (q-rv, (1-p)*q), (1-p-q+rv, (1-p)*(1-q))]:
            if pxy > 1e-15 and pxpy > 1e-15:
                mi += pxy * log(pxy / pxpy)
        return max(0, mi)

    mi_matrix = np.zeros((n, n))
    chisq_matrix = np.zeros((n, n))

    for i in range(n):
        for j in range(n):
            if i != j:
                mi_matrix[i, j] = pairwise_mi(i, j)
                c = coord_cov(i, j)
                p, q = coord_prob(i), coord_prob(j)
                denom = p * (1-p) * q * (1-q)
                chisq_matrix[i, j] = c**2 / denom if denom > 0 else 0

    return mi_matrix, chisq_matrix


fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('Pairwise Mutual Information vs χ² Bound\nfor Uniform Matroid Distributions',
             fontsize=14, fontweight='bold')

configs = [(4, 2), (5, 2), (6, 3)]

for idx, (n, r) in enumerate(configs):
    mi, chisq = compute_mi_and_bounds(n, r)

    # MI heatmap
    ax1 = axes[0, idx]
    im1 = ax1.imshow(mi, cmap='YlOrRd', aspect='equal')
    ax1.set_title(f'MI: U({n},{r})', fontsize=11)
    ax1.set_xlabel('Coordinate j')
    ax1.set_ylabel('Coordinate i')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # Chi-squared bound heatmap
    ax2 = axes[1, idx]
    im2 = ax2.imshow(chisq, cmap='YlOrRd', aspect='equal')
    ax2.set_title(f'χ² bound: U({n},{r})', fontsize=11)
    ax2.set_xlabel('Coordinate j')
    ax2.set_ylabel('Coordinate i')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    # Annotate with values
    for i in range(n):
        for j in range(n):
            if i != j and n <= 5:
                ax1.text(j, i, f'{mi[i,j]:.4f}', ha='center', va='center', fontsize=7)
                ax2.text(j, i, f'{chisq[i,j]:.4f}', ha='center', va='center', fontsize=7)

plt.tight_layout()
plt.savefig('viz_mi_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_mi_heatmap.png")
