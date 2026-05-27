#!/usr/bin/env python3
"""
Visualization: Hessian Spectral Signatures of Derivative Leaves

Visualizes the eigenvalue distributions of mixed Hessian matrices
computed from derivative leaves of DPP polynomials. Demonstrates
the Lorentzian spectral constraint: at most one positive eigenvalue.

Output: hessian_spectrum.png
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


# ── Generate data ──

np.random.seed(42)
n = 5
n_trials = 200

all_eigs_2 = []
all_eigs_3 = []
all_eigs_4 = []

for trial in range(n_trials):
    G = np.random.randn(n, n)
    K = G @ G.T / n
    Z = build_dpp(K)

    for A in combinations(range(n), 2):
        leaf = deriv_leaf(Z, set(A))
        H = hessian_ones(leaf, set(A))
        all_eigs_2.extend(np.linalg.eigvalsh(H).tolist())

    for A in combinations(range(n), 3):
        leaf = deriv_leaf(Z, set(A))
        H = hessian_ones(leaf, set(A))
        all_eigs_3.extend(np.linalg.eigvalsh(H).tolist())

    for A in combinations(range(n), 4):
        leaf = deriv_leaf(Z, set(A))
        H = hessian_ones(leaf, set(A))
        all_eigs_4.extend(np.linalg.eigvalsh(H).tolist())

all_eigs_2 = np.array(all_eigs_2)
all_eigs_3 = np.array(all_eigs_3)
all_eigs_4 = np.array(all_eigs_4)

# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for ax, eigs, k, color in [
    (axes[0], all_eigs_2, 2, '#2196F3'),
    (axes[1], all_eigs_3, 3, '#FF9800'),
    (axes[2], all_eigs_4, 4, '#4CAF50'),
]:
    ax.hist(eigs, bins=80, density=True, alpha=0.7, color=color, edgecolor='white', linewidth=0.5)
    ax.axvline(x=0, color='red', linestyle='--', linewidth=1.5, alpha=0.8)
    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title(f'Leaf Hessian Eigenvalues (|A|={k})', fontsize=13, fontweight='bold')

    n_pos = np.sum(eigs > 1e-8)
    n_neg = np.sum(eigs < -1e-8)
    n_zero = len(eigs) - n_pos - n_neg
    ax.text(0.95, 0.95, f'n={len(eigs)}\npos: {n_pos}\nneg: {n_neg}\nzero: {n_zero}',
            transform=ax.transAxes, fontsize=9, verticalalignment='top',
            horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Lorentzian Spectral Signature: Derivative Leaf Hessians\n'
             f'(n={n} variables, {n_trials} random PSD kernels)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved hessian_spectrum.png")
