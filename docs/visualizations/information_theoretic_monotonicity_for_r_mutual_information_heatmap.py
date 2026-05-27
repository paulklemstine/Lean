"""
Visualization 1: Mutual Information Heatmap for Robustly Lorentzian Measures

Visualizes the pairwise mutual information matrix for uniform matroid distributions,
showing how negative dependence suppresses information sharing between coordinates.
The chi-squared certified bound is overlaid for comparison.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def binary_entropy(p):
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * log(p) + (1 - p) * log(1 - p))


def shannon_entropy(weights):
    return -sum(w * log(w) for w in weights if w > 0)


def uniform_matroid_mi_matrix(n, k):
    """Compute MI matrix for uniform matroid U(k,n)."""
    subsets = [frozenset(s) for s in combinations(range(n), k)]
    w = 1.0 / len(subsets)

    def coord_prob(i):
        return sum(w for s in subsets if i in s)

    def pair_prob(i, j):
        return sum(w for s in subsets if i in s and j in s)

    mi = np.zeros((n, n))
    chi2 = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                mi[i, j] = binary_entropy(coord_prob(i))
                continue
            pi, pj = coord_prob(i), coord_prob(j)
            pij = pair_prob(i, j)
            p11, p10, p01 = pij, pi - pij, pj - pij
            p00 = 1 - pi - pj + pij
            vals = [max(v, 0) for v in [p00, p01, p10, p11]]
            mi[i, j] = max(binary_entropy(pi) + binary_entropy(pj) - shannon_entropy(vals), 0)
            cov = pij - pi * pj
            denom = pi * (1 - pi) * pj * (1 - pj)
            chi2[i, j] = cov ** 2 / denom if denom > 0 else 0
    return mi, chi2


fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('Mutual Information Under Lorentzian Negativity', fontsize=14, fontweight='bold')

configs = [(5, 1), (5, 2), (6, 3), (6, 1), (6, 2), (7, 3)]
for idx, (n, k) in enumerate(configs):
    ax = axes[idx // 3, idx % 3]
    mi, chi2 = uniform_matroid_mi_matrix(n, k)
    np.fill_diagonal(mi, 0)  # Zero out self-MI for clearer display
    im = ax.imshow(mi, cmap='YlOrRd', interpolation='nearest', vmin=0)
    ax.set_title(f'U({k},{n})\nmax MI = {mi.max():.4f}', fontsize=10)
    ax.set_xlabel('Coordinate j')
    ax.set_ylabel('Coordinate i')
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

plt.tight_layout()
plt.savefig('viz_mi_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_mi_heatmap.png")
