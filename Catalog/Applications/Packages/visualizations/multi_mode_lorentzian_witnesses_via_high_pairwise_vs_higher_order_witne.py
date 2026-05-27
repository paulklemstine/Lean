#!/usr/bin/env python3
"""
Visualization: Pairwise vs. Higher-Order Witness Comparison

Creates a scatter plot comparing the maximum pairwise leaf witness
against the tripartite leaf witness for randomly generated DPP polynomials.
Points above the diagonal demonstrate multipartite separation.

Output: witness_comparison.png
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ── Self-contained polynomial infrastructure ──

class MvPoly:
    def __init__(self, n, terms=None):
        self.n = n
        self.terms = {k: v for k, v in (terms or {}).items() if abs(v) > 1e-15}

    def partial(self, var):
        r = MvPoly(self.n)
        for exp, c in self.terms.items():
            if exp[var] > 0:
                ne = list(exp); ne[var] -= 1; ne = tuple(ne)
                r.terms[ne] = r.terms.get(ne, 0) + c * exp[var]
        return r

    def eval_ones(self):
        return sum(self.terms.values())


def build_dpp(K):
    n = K.shape[0]
    p = MvPoly(n)
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            minor = 1.0 if len(S) == 0 else np.linalg.det(K[np.ix_(list(S), list(S))])
            exp = tuple(1 if i in S else 0 for i in range(n))
            p.terms[exp] = p.terms.get(exp, 0) + minor
    p.terms = {k: v for k, v in p.terms.items() if abs(v) > 1e-15}
    return p


def deriv_leaf(p, A):
    r = p
    for v in sorted(set(range(p.n)) - A):
        r = r.partial(v)
    return r


def hessian_ones(p, A):
    idx = sorted(A)
    k = len(idx)
    H = np.zeros((k, k))
    for a, i in enumerate(idx):
        pi = p.partial(i)
        for b, j in enumerate(idx):
            H[a, b] = pi.partial(j).eval_ones()
    return H


def leaf_witness(p, A):
    leaf = deriv_leaf(p, A)
    H = hessian_ones(leaf, A)
    return max(np.linalg.eigvalsh(H)[-1], 0) if H.shape[0] > 0 else 0

def pw_witness(p, i, j):
    leaf = deriv_leaf(p, {i, j})
    return leaf.partial(i).partial(j).eval_ones() ** 2


# ── Generate comparison data ──

np.random.seed(2024)
n_vars = 6
n_trials = 300

higher_witnesses = []
max_pairwise_witnesses = []
subset_sizes = []

for trial in range(n_trials):
    G = np.random.randn(n_vars, max(2, np.random.randint(1, n_vars + 1)))
    K = G @ G.T / n_vars

    Z = build_dpp(K)

    for A_tuple in combinations(range(n_vars), 3):
        A_set = set(A_tuple)
        hw = leaf_witness(Z, A_set)

        pws = [pw_witness(Z, i, j) for i, j in combinations(A_tuple, 2)]
        mpw = max(pws) if pws else 0

        higher_witnesses.append(hw)
        max_pairwise_witnesses.append(mpw)
        subset_sizes.append(3)

higher_witnesses = np.array(higher_witnesses)
max_pairwise_witnesses = np.array(max_pairwise_witnesses)

# ── Plot ──

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Scatter plot
mask_nonzero = (max_pairwise_witnesses > 1e-10) & (higher_witnesses > 1e-10)
hw_nz = higher_witnesses[mask_nonzero]
mpw_nz = max_pairwise_witnesses[mask_nonzero]

scatter = ax1.scatter(mpw_nz, hw_nz, c=hw_nz / (mpw_nz + 1e-15),
                       cmap='plasma', alpha=0.5, s=15, edgecolors='none')
cbar = plt.colorbar(scatter, ax=ax1)
cbar.set_label('Ratio (higher / pairwise)', fontsize=10)

# Diagonal line
lim = max(hw_nz.max(), mpw_nz.max()) * 1.1
ax1.plot([0, lim], [0, lim], 'k--', alpha=0.3, linewidth=1)
ax1.set_xlabel('Max Pairwise Witness', fontsize=12)
ax1.set_ylabel('Tripartite Leaf Witness', fontsize=12)
ax1.set_title('Pairwise vs. Higher-Order Witnesses\n(|A|=3, n=6)', fontsize=13, fontweight='bold')
ax1.set_xlim(0, lim)
ax1.set_ylim(0, lim)

# Ratio histogram
ratios = hw_nz / (mpw_nz + 1e-15)
ax2.hist(np.log10(ratios + 1e-15), bins=60, density=True, alpha=0.7,
         color='#9C27B0', edgecolor='white', linewidth=0.5)
ax2.axvline(x=0, color='red', linestyle='--', linewidth=1.5, alpha=0.8, label='Equal (ratio=1)')
ax2.set_xlabel('log₁₀(Higher / Pairwise)', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Distribution of Witness Ratios', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)

n_above = np.sum(ratios > 1.0)
n_below = np.sum(ratios <= 1.0)
ax2.text(0.95, 0.95, f'Higher > Pairwise: {n_above}\nHigher ≤ Pairwise: {n_below}',
         transform=ax2.transAxes, fontsize=10, verticalalignment='top',
         horizontalalignment='right',
         bbox=dict(boxstyle='round', facecolor='lavender', alpha=0.8))

fig.suptitle('Multipartite Separation: When Higher-Order Witnesses See More',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('witness_comparison.png', dpi=150, bbox_inches='tight')
print("Saved witness_comparison.png")
