#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs. Polynomial Parameters

Shows how the spectral gap (magnitude of max eigenvalue on zero-sum subspace)
varies with polynomial parameters, illustrating the strength of negative
dependence across different families.
"""

import numpy as np
import matplotlib.pyplot as plt
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

def spectral_gap(L):
    R = restrict_to_zero_sum(L)
    eigs = np.linalg.eigvalsh(R)
    return -max(eigs)  # positive when CondNSD holds


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Uniform matroids — gap vs n for fixed k
ax = axes[0]
for k in [2, 3, 4]:
    ns = range(k + 1, 15)
    gaps = []
    ns_list = []
    for n in ns:
        val = comb(n, k)
        grad = np.full(n, comb(n-1, k-1), dtype=float)
        hess = np.full((n, n), comb(n-2, k-2), dtype=float)
        np.fill_diagonal(hess, 0)
        L = log_hessian_at_one(val, grad, hess)
        gaps.append(spectral_gap(L))
        ns_list.append(n)
    ax.plot(ns_list, gaps, 'o-', label=f'k={k}', markersize=5)
ax.set_xlabel('n (ground set size)')
ax.set_ylabel('Spectral gap')
ax.set_title('Uniform Matroid U(k,n)\nSpectral Gap vs n')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: DPP — gap vs kernel spectral norm
ax = axes[1]
np.random.seed(42)
norms = []
gaps = []
for trial in range(50):
    n = 6
    A = np.random.randn(n, n)
    scale = np.random.uniform(0.01, 5.0)
    K = scale * (A.T @ A) / n
    I_n = np.eye(n)
    M = K @ np.linalg.inv(I_n + K)
    L = -(M * M)
    norms.append(np.linalg.norm(K, ord=2))
    gaps.append(spectral_gap(L))
ax.scatter(norms, gaps, alpha=0.6, s=30, c='tab:orange')
ax.set_xlabel('||K||₂ (spectral norm)')
ax.set_ylabel('Spectral gap')
ax.set_title('DPP (n=6)\nSpectral Gap vs Kernel Norm')
ax.grid(True, alpha=0.3)

# Panel 3: Products of linears — gap vs weight variance
ax = axes[2]
variances = []
gaps = []
for trial in range(80):
    n = 6
    mean_w = np.random.uniform(0.5, 2.0)
    spread = np.random.uniform(0, 3.0)
    w = np.maximum(0.01, mean_w + spread * np.random.randn(n))
    L = np.zeros((n, n))
    for i in range(n):
        L[i, i] = -(w[i] / (1 + w[i]))**2
    variances.append(np.var(w))
    gaps.append(spectral_gap(L))
ax.scatter(variances, gaps, alpha=0.6, s=30, c='tab:green')
ax.set_xlabel('Var(weights)')
ax.set_ylabel('Spectral gap')
ax.set_title('Product of Linears (n=6)\nSpectral Gap vs Weight Variance')
ax.grid(True, alpha=0.3)

plt.suptitle('Spectral Gap Analysis: Measuring Negative Dependence Strength',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_analysis.png")
