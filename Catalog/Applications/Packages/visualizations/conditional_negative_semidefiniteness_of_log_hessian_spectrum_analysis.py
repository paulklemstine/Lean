#!/usr/bin/env python3
"""
Visualization: Log-Hessian Spectrum on the Zero-Sum Subspace

Visualizes the eigenvalue spectrum of log-Hessian matrices restricted
to the zero-sum subspace for various polynomial families. This is the
core diagnostic for the Lorentzian CondNSD conjecture: all eigenvalues
should be ≤ 0 (shown in blue), with any positive eigenvalue (red)
indicating a counterexample.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def log_hessian_at_one(value, gradient, hessian):
    c, g, H = value, gradient, hessian
    return H / c - np.outer(g, g) / c**2

def restrict_to_zero_sum(M):
    n = M.shape[0]
    if n <= 1:
        return np.array([[0.0]])
    basis = np.zeros((n, n - 1))
    for k in range(n - 1):
        basis[k, k] = 1.0
        basis[n - 1, k] = -1.0
    Q, _ = np.linalg.qr(basis, mode='reduced')
    return Q.T @ M @ Q

def uniform_matroid_eigs(n, k):
    val = comb(n, k)
    grad = np.full(n, comb(n-1, k-1), dtype=float)
    hess = np.full((n, n), comb(n-2, k-2), dtype=float)
    np.fill_diagonal(hess, 0)
    L = log_hessian_at_one(val, grad, hess)
    return np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))

def dpp_eigs(K):
    n = K.shape[0]
    I = np.eye(n)
    M = K @ np.linalg.inv(I + K)
    L = -(M * M)
    return np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))

def product_linears_eigs(w):
    n = len(w)
    L = np.zeros((n, n))
    for i in range(n):
        L[i, i] = -(w[i] / (1 + w[i]))**2
    return np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Uniform matroids
ax = axes[0]
matroids = [(5,2), (6,3), (7,3), (8,4), (6,2), (7,4)]
for idx, (n, k) in enumerate(matroids):
    eigs = uniform_matroid_eigs(n, k)
    y = idx
    for e in eigs:
        color = 'tab:blue' if e <= 1e-10 else 'tab:red'
        ax.plot(e, y, 'o', color=color, markersize=8, alpha=0.7)
ax.axvline(x=0, color='black', linewidth=0.8, linestyle='--', alpha=0.5)
ax.set_yticks(range(len(matroids)))
ax.set_yticklabels([f'U({k},{n})' for n, k in matroids])
ax.set_xlabel('Eigenvalue')
ax.set_title('Uniform Matroid Spectra')

# Panel 2: DPP partition functions
ax = axes[1]
np.random.seed(42)
dpp_names = []
for idx in range(6):
    n = np.random.randint(4, 8)
    if idx < 3:
        k = max(2, n // 2)
        Q = np.linalg.qr(np.random.randn(n, k), mode='reduced')[0]
        K = Q @ Q.T
        name = f'Proj(n={n},r={k})'
    else:
        A = np.random.randn(n, n)
        K = (A.T @ A) / n * 0.5
        name = f'PSD(n={n})'
    eigs = dpp_eigs(K)
    for e in eigs:
        color = 'tab:blue' if e <= 1e-10 else 'tab:red'
        ax.plot(e, idx, 'o', color=color, markersize=8, alpha=0.7)
    dpp_names.append(name)
ax.axvline(x=0, color='black', linewidth=0.8, linestyle='--', alpha=0.5)
ax.set_yticks(range(len(dpp_names)))
ax.set_yticklabels(dpp_names)
ax.set_xlabel('Eigenvalue')
ax.set_title('DPP Log-Hessian Spectra')

# Panel 3: Products of linear forms
ax = axes[2]
weight_sets = [
    np.ones(5),
    np.array([0.5, 1, 2, 3, 4]),
    np.array([0.1, 0.1, 10, 10, 0.5]),
    np.random.uniform(0.1, 5, size=6),
    np.random.uniform(0.01, 10, size=8),
    np.array([1, 1, 1, 1, 1, 1, 1]),
]
lin_names = ['[1]*5', '[.5,1,2,3,4]', '[.1,.1,10,10,.5]',
             'Rand(6)', 'Rand(8)', '[1]*7']
for idx, w in enumerate(weight_sets):
    eigs = product_linears_eigs(w)
    for e in eigs:
        color = 'tab:blue' if e <= 1e-10 else 'tab:red'
        ax.plot(e, idx, 'o', color=color, markersize=8, alpha=0.7)
ax.axvline(x=0, color='black', linewidth=0.8, linestyle='--', alpha=0.5)
ax.set_yticks(range(len(lin_names)))
ax.set_yticklabels(lin_names)
ax.set_xlabel('Eigenvalue')
ax.set_title('Product-of-Linears Spectra')

plt.suptitle('Log-Hessian Eigenvalues on Zero-Sum Subspace\n'
             '(Blue ≤ 0: CondNSD holds  |  Red > 0: conjecture violation)',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('spectrum_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectrum_analysis.png")
