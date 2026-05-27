#!/usr/bin/env python3
"""
Visualization: Derivative Leaf Hierarchy Heatmap

Shows the hierarchical structure of leaf witnesses across different
subset sizes and specific subsets for a fixed DPP kernel.
Demonstrates how Lorentzian geometry organizes multi-mode correlations.

Output: leaf_hierarchy.png
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


def leaf_witness_full(p, A):
    """Returns (witness, eigenvalues, hessian)."""
    leaf = deriv_leaf(p, A)
    H = hessian_ones(leaf, A)
    eigs = np.linalg.eigvalsh(H)
    return max(eigs[-1], 0), eigs, H


# ── Build kernel with structured correlations ──

np.random.seed(42)
n = 6

# Block-structured kernel with 2 communities
K = np.zeros((n, n))
# Community 1: {0,1,2} — strong correlations
for i in range(3):
    K[i, i] = 2.0
for i, j in combinations(range(3), 2):
    K[i, j] = K[j, i] = 1.5

# Community 2: {3,4,5} — moderate correlations
for i in range(3, 6):
    K[i, i] = 1.5
for i, j in combinations(range(3, 6), 2):
    K[i, j] = K[j, i] = 0.8

# Cross-community: weak
K[0, 3] = K[3, 0] = 0.2
K[1, 4] = K[4, 1] = 0.15

# Make PSD
eigvals = np.linalg.eigvalsh(K)
if np.min(eigvals) < 0:
    K -= np.min(eigvals) * np.eye(n) - 0.01 * np.eye(n)

Z = build_dpp(K)

# ── Compute all witnesses ──

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Hessian heatmaps for selected subsets
selected_subsets = [
    ({0, 1, 2}, "Community 1: {0,1,2}"),
    ({3, 4, 5}, "Community 2: {3,4,5}"),
    ({0, 1, 3}, "Cross: {0,1,3}"),
    ({0, 3, 5}, "Cross: {0,3,5}"),
]

for idx, (A_set, label) in enumerate(selected_subsets):
    ax = axes[idx // 2][idx % 2]
    w, eigs, H = leaf_witness_full(Z, A_set)

    im = ax.imshow(H, cmap='RdBu_r', aspect='equal',
                   vmin=-np.abs(H).max(), vmax=np.abs(H).max())
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Annotate entries
    for i in range(H.shape[0]):
        for j in range(H.shape[1]):
            ax.text(j, i, f'{H[i,j]:.2f}', ha='center', va='center',
                    fontsize=10, fontweight='bold',
                    color='white' if abs(H[i,j]) > np.abs(H).max() * 0.6 else 'black')

    ax.set_title(f'{label}\nWitness={w:.2f}, λ={np.round(eigs, 2)}',
                 fontsize=11, fontweight='bold')
    labels = sorted(A_set)
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels([f'x{l}' for l in labels])
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels([f'x{l}' for l in labels])

fig.suptitle('Mixed Hessian Matrices of Derivative Leaves\n'
             f'(n={n}, Block-Structured DPP Kernel)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('leaf_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved leaf_hierarchy.png")
