"""
Visualization: Comparing CondNSD Across Polynomial Families

Shows eigenvalue spectra on the zero-sum subspace for three different
families of polynomials:
1. DPP partition functions (det(I + diag(x)A))
2. Products of linear forms (∏ ℓ_r(x))
3. Random nonneg multilinear polynomials (may violate CondNSD)

The contrast demonstrates that CondNSD is a structural property of
special polynomial families, not a generic phenomenon.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def log_hessian_product_linear(coefficients):
    m, n = coefficients.shape
    row_sums = coefficients.sum(axis=1)
    H = np.zeros((n, n))
    for r in range(m):
        s = row_sums[r]
        H -= np.outer(coefficients[r], coefficients[r]) / s**2
    return H


def dpp_resolvent_hessian(A):
    n = A.shape[0]
    L = A @ np.linalg.inv(np.eye(n) + A)
    return -(L ** 2)


def multilinear_log_hessian(coefficients, n):
    p_val = sum(coefficients.values())
    dp = np.zeros(n)
    for S, mu in coefficients.items():
        for i in S:
            dp[i] += mu
    d2p = np.zeros((n, n))
    for S, mu in coefficients.items():
        S_list = list(S)
        for a in range(len(S_list)):
            for b in range(a + 1, len(S_list)):
                i, j = S_list[a], S_list[b]
                d2p[i, j] += mu
                d2p[j, i] += mu
    return d2p / p_val - np.outer(dp, dp) / p_val**2


def zero_sum_eigenvalues(M):
    n = M.shape[0]
    e = np.ones(n) / np.sqrt(n)
    Q = np.eye(n) - np.outer(e, e)
    M_r = Q @ M @ Q
    evals = np.linalg.eigvalsh(M_r)
    idx = np.argsort(np.abs(evals))
    return np.sort(evals[idx[1:]])


np.random.seed(2025)
n = 6
n_samples = 50

# Collect max eigenvalues for each family
dpp_maxevals = []
prod_maxevals = []
rand_maxevals = []

for _ in range(n_samples):
    # DPP
    B = np.random.randn(n, n) * 0.8
    A = B @ B.T
    H_dpp = dpp_resolvent_hessian(A)
    dpp_maxevals.append(np.max(zero_sum_eigenvalues(H_dpp)))

    # Product of linear forms
    m = np.random.randint(2, 6)
    a = np.abs(np.random.randn(m, n)) + 0.05
    H_prod = log_hessian_product_linear(a)
    prod_maxevals.append(np.max(zero_sum_eigenvalues(H_prod)))

    # Random nonneg multilinear
    coeffs = {}
    for k in range(n + 1):
        for S in combinations(range(n), k):
            coeffs[frozenset(S)] = np.abs(np.random.randn()) + 0.01
    H_rand = multilinear_log_hessian(coeffs, n)
    rand_maxevals.append(np.max(zero_sum_eigenvalues(H_rand)))

fig, axes = plt.subplots(1, 3, figsize=(15, 5), sharey=True)

# Panel 1: DPP
axes[0].hist(dpp_maxevals, bins=25, color='#1976d2', alpha=0.85, edgecolor='black', linewidth=0.5)
axes[0].axvline(x=0, color='red', linewidth=2, linestyle='--', label='CondNSD boundary')
axes[0].set_title('DPP Hessians\n(Lorentzian)', fontsize=13, fontweight='bold')
axes[0].set_xlabel('Max zero-sum eigenvalue')
axes[0].set_ylabel('Count')
axes[0].legend(fontsize=9)

# Panel 2: Products
axes[1].hist(prod_maxevals, bins=25, color='#388e3c', alpha=0.85, edgecolor='black', linewidth=0.5)
axes[1].axvline(x=0, color='red', linewidth=2, linestyle='--', label='CondNSD boundary')
axes[1].set_title('Product of Linear Forms\n(Lorentzian)', fontsize=13, fontweight='bold')
axes[1].set_xlabel('Max zero-sum eigenvalue')
axes[1].legend(fontsize=9)

# Panel 3: Random
axes[2].hist(rand_maxevals, bins=25, color='#f57c00', alpha=0.85, edgecolor='black', linewidth=0.5)
axes[2].axvline(x=0, color='red', linewidth=2, linestyle='--', label='CondNSD boundary')
axes[2].set_title('Random Multilinear\n(not Lorentzian)', fontsize=13, fontweight='bold')
axes[2].set_xlabel('Max zero-sum eigenvalue')
axes[2].legend(fontsize=9)

n_violations = sum(1 for x in rand_maxevals if x > 1e-10)
axes[2].annotate(f'{n_violations}/{n_samples} violate\nCondNSD',
                  xy=(0.95, 0.85), xycoords='axes fraction',
                  fontsize=11, color='#d32f2f', fontweight='bold',
                  ha='right')

fig.suptitle('Max Eigenvalue on Zero-Sum Subspace: CondNSD Holds for Lorentzian Families',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_family_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_family_comparison.png")
