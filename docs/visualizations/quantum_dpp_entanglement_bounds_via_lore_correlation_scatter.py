"""
Visualization: Correlation between Lorentzian Witness and Entanglement Entropy

Generates scatter plots showing the relationship between the maximum leaf
curvature witness (K_ij^2) and the minimum balanced entropy for random
PSD contraction kernels.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def binary_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermionic_entropy_matrix(K, A):
    if len(A) == 0:
        return 0.0
    idx = np.array(A)
    K_A = K[np.ix_(idx, idx)]
    eigs = np.clip(np.linalg.eigvalsh(K_A), 0, 1)
    return sum(binary_entropy(lam) for lam in eigs)


def balanced_bipartitions(n):
    return [list(c) for c in combinations(range(n), n // 2)]


def min_balanced_entropy(K):
    n = K.shape[0]
    bps = balanced_bipartitions(n)
    return min(fermionic_entropy_matrix(K, A) for A in bps) if bps else 0.0


def max_leaf_witness(K):
    n = K.shape[0]
    return max(K[i, j] ** 2 for i in range(n) for j in range(i + 1, n))


def random_psd_contraction(n, rng):
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0, 1, n)
    return Q @ np.diag(eigs) @ Q.T


def toeplitz_kernel(n, rho):
    K = np.array([[rho ** abs(i - j) for j in range(n)] for i in range(n)])
    max_eig = np.max(np.linalg.eigvalsh(K))
    return K / max_eig if max_eig > 0 else K


fig, axes = plt.subplots(2, 2, figsize=(14, 12))
rng = np.random.default_rng(42)
num_samples = 200

for idx, (n, ax) in enumerate(zip([3, 4, 5, 6], axes.flat)):
    entropies = []
    witnesses = []
    colors = []

    for _ in range(num_samples):
        # Mix kernel types
        choice = rng.integers(0, 3)
        if choice == 0:
            K = random_psd_contraction(n, rng)
            c = 'steelblue'
        elif choice == 1:
            rho = rng.uniform(0.1, 0.99)
            K = toeplitz_kernel(n, rho)
            c = 'coral'
        else:
            p = rng.uniform(0, 1, n)
            K = np.diag(p)
            c = 'forestgreen'

        S_min = min_balanced_entropy(K)
        w = max_leaf_witness(K)
        entropies.append(S_min)
        witnesses.append(w)
        colors.append(c)

    entropies = np.array(entropies)
    witnesses = np.array(witnesses)

    # Scatter plot
    for c, label in [('steelblue', 'Random'), ('coral', 'Toeplitz'),
                      ('forestgreen', 'Diagonal')]:
        mask = np.array(colors) == c
        ax.scatter(witnesses[mask], entropies[mask], c=c, alpha=0.5,
                   s=20, label=label, edgecolors='none')

    # Correlation
    corr = np.corrcoef(entropies, witnesses)[0, 1]

    ax.set_xlabel(r'Max leaf witness $\max_{i,j} K_{ij}^2$', fontsize=11)
    ax.set_ylabel(r'Min balanced entropy $\min_A S_A$', fontsize=11)
    ax.set_title(f'n = {n}  (ρ = {corr:.3f})', fontsize=13, fontweight='bold')
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Annotate the conjecture region
    if np.any(witnesses > 0.01):
        ax.axvline(x=0.01, color='red', linestyle=':', alpha=0.5)
        ax.text(0.02, ax.get_ylim()[1] * 0.9,
                'Witness > 0:\nentropy expected > 0',
                fontsize=8, color='red', alpha=0.7)

plt.suptitle('Lorentzian Witness vs. Entanglement Entropy\n'
             'Across Kernel Families and Dimensions',
             fontsize=15, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('correlation_scatter.png', dpi=150, bbox_inches='tight')
print("Saved correlation_scatter.png")
