"""
Visualization: Pairwise Mutual Information Heatmap
====================================================

Displays the mutual information matrix for a uniform matroid U(3,6),
alongside the chi-squared upper bound and the covariance matrix.

Demonstrates that robust Lorentzian negativity suppresses pairwise
mutual information uniformly — the information-theoretic shadow of
discrete curvature.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log
from itertools import combinations


class FinsetLaw:
    def __init__(self, n, weights):
        self.n = n
        self.weights = weights
    
    @classmethod
    def uniform_matroid(cls, n, k):
        c = comb(n, k)
        return cls(n, {frozenset(s): 1.0/c for s in combinations(range(n), k)})


def coord_prob(mu, i):
    return sum(w for s, w in mu.weights.items() if i in s)

def pair_joint_prob(mu, i, j):
    return sum(w for s, w in mu.weights.items() if i in s and j in s)

def coord_cov(mu, i, j):
    return pair_joint_prob(mu, i, j) - coord_prob(mu, i) * coord_prob(mu, j)

def mutual_info_coord(mu, i, j):
    pi, pj = coord_prob(mu, i), coord_prob(mu, j)
    pij = pair_joint_prob(mu, i, j)
    table = [pij, pi - pij, pj - pij, 1 - pi - pj + pij]
    prods = [pi * pj, pi * (1-pj), (1-pi) * pj, (1-pi) * (1-pj)]
    return max(0, sum(p * log(p / q) for p, q in zip(table, prods) if p > 1e-30 and q > 1e-30))

def chi_sq(p, q, c):
    d = p * (1-p) * q * (1-q)
    return c**2 / d if d > 1e-30 else 0

# Compute matrices for U(3,6)
n = 6
mu = FinsetLaw.uniform_matroid(n, 3)

mi_matrix = np.zeros((n, n))
cov_matrix = np.zeros((n, n))
chi_sq_matrix = np.zeros((n, n))

for i in range(n):
    for j in range(n):
        if i != j:
            mi_matrix[i, j] = mutual_info_coord(mu, i, j)
            cov_matrix[i, j] = coord_cov(mu, i, j)
            pi, pj = coord_prob(mu, i), coord_prob(mu, j)
            chi_sq_matrix[i, j] = chi_sq(pi, pj, cov_matrix[i, j])

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Mutual Information
im1 = axes[0].imshow(mi_matrix * 1e4, cmap='YlOrRd', aspect='equal')
axes[0].set_title('Mutual Information (×10⁴)', fontweight='bold')
axes[0].set_xlabel('Coordinate j')
axes[0].set_ylabel('Coordinate i')
plt.colorbar(im1, ax=axes[0], shrink=0.8)
for i in range(n):
    for j in range(n):
        if i != j:
            axes[0].text(j, i, f'{mi_matrix[i,j]*1e4:.2f}', ha='center', va='center', fontsize=7)
        else:
            axes[0].text(j, i, '—', ha='center', va='center', fontsize=9, color='gray')

# Plot 2: Covariance
im2 = axes[1].imshow(cov_matrix, cmap='RdBu_r', aspect='equal',
                      vmin=-max(abs(cov_matrix.min()), abs(cov_matrix.max())),
                      vmax=max(abs(cov_matrix.min()), abs(cov_matrix.max())))
axes[1].set_title('Covariance (Negative Dependence)', fontweight='bold')
axes[1].set_xlabel('Coordinate j')
axes[1].set_ylabel('Coordinate i')
plt.colorbar(im2, ax=axes[1], shrink=0.8)
for i in range(n):
    for j in range(n):
        if i != j:
            axes[1].text(j, i, f'{cov_matrix[i,j]:.3f}', ha='center', va='center', fontsize=7)
        else:
            axes[1].text(j, i, '—', ha='center', va='center', fontsize=9, color='gray')

# Plot 3: MI vs χ² bound
im3 = axes[2].imshow(chi_sq_matrix * 1e4, cmap='YlOrRd', aspect='equal')
axes[2].set_title('χ² Upper Bound (×10⁴)', fontweight='bold')
axes[2].set_xlabel('Coordinate j')
axes[2].set_ylabel('Coordinate i')
plt.colorbar(im3, ax=axes[2], shrink=0.8)
for i in range(n):
    for j in range(n):
        if i != j:
            axes[2].text(j, i, f'{chi_sq_matrix[i,j]*1e4:.2f}', ha='center', va='center', fontsize=7)
        else:
            axes[2].text(j, i, '—', ha='center', va='center', fontsize=9, color='gray')

plt.suptitle('Pairwise Information Suppression in U(3,6)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_mi_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_mi_heatmap.png")
