"""
Visualization: Lorentzian Certificate Matrix Eigenvalue Spectrum

Visualizes how the eigenvalues of the certificate matrix M_g(x) vary
as the evaluation point x changes along a path in the positive orthant.
Shows that all eigenvalues remain nonpositive for strongly Rayleigh polynomials.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def multiaffine_eval(coeffs, x):
    val = 0.0
    for subset, c in coeffs.items():
        term = c
        for i in subset:
            term *= x[i]
        val += term
    return val


def multiaffine_gradient(coeffs, x):
    n = len(x)
    grad = np.zeros(n)
    for i in range(n):
        for subset, c in coeffs.items():
            if i in subset:
                remaining = tuple(j for j in subset if j != i)
                term = c
                for j in remaining:
                    term *= x[j]
                grad[i] += term
    return grad


def multiaffine_hessian(coeffs, x):
    n = len(x)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                for subset, c in coeffs.items():
                    if i in subset and j in subset:
                        remaining = tuple(k for k in subset if k != i and k != j)
                        term = c
                        for k in remaining:
                            term *= x[k]
                        H[i, j] += term
    return H


def certificate_matrix(coeffs, x):
    g_val = multiaffine_eval(coeffs, x)
    grad = multiaffine_gradient(coeffs, x)
    hess = multiaffine_hessian(coeffs, x)
    return g_val * hess - np.outer(grad, grad)


def uniform_matroid_poly(n, r):
    coeffs = {}
    for subset in combinations(range(n), r):
        coeffs[subset] = 1.0
    return coeffs


def dpp_generating_poly(K):
    n = K.shape[0]
    coeffs = {}
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            if len(subset) == 0:
                coeffs[()] = 1.0
            else:
                sub_K = K[np.ix_(list(subset), list(subset))]
                coeffs[subset] = np.linalg.det(sub_K)
    return coeffs


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Eigenvalue paths for U_{2,4} ---
ax1 = axes[0]
coeffs = uniform_matroid_poly(4, 2)
t_values = np.linspace(0.1, 3.0, 100)
all_eigs = []

for t in t_values:
    x = np.array([t, 1.0, 1.5, 0.8])
    M = certificate_matrix(coeffs, x)
    eigs = np.sort(np.linalg.eigvalsh(M))[::-1]
    all_eigs.append(eigs)

all_eigs = np.array(all_eigs)
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
for i in range(4):
    ax1.plot(t_values, all_eigs[:, i], color=colors[i], linewidth=2,
             label=f'λ_{i+1}')

ax1.axhline(y=0, color='black', linewidth=1, linestyle='--', alpha=0.5)
ax1.set_xlabel('x₁ (other coordinates fixed)', fontsize=11)
ax1.set_ylabel('Eigenvalue', fontsize=11)
ax1.set_title('U_{2,4}: Certificate Eigenvalues\nvs. x₁', fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Heatmap of certificate matrix for DPP ---
ax2 = axes[1]
np.random.seed(42)
A = np.random.randn(4, 4)
K = A @ A.T / 4
coeffs_dpp = dpp_generating_poly(K)
x = np.ones(4)
M = certificate_matrix(coeffs_dpp, x)

im = ax2.imshow(M, cmap='RdBu_r', aspect='equal', vmin=np.min(M), vmax=-np.min(M))
ax2.set_title('DPP Certificate Matrix\nat x = (1,1,1,1)', fontsize=12)
ax2.set_xlabel('Column index j', fontsize=11)
ax2.set_ylabel('Row index i', fontsize=11)
plt.colorbar(im, ax=ax2, shrink=0.8)

# Add value annotations
for i in range(4):
    for j in range(4):
        ax2.text(j, i, f'{M[i,j]:.1f}', ha='center', va='center',
                fontsize=8, color='white' if abs(M[i,j]) > abs(np.max(M))*0.5 else 'black')

# --- Panel 3: Eigenvalue distribution across random points ---
ax3 = axes[2]
coeffs_u35 = uniform_matroid_poly(5, 3)
all_max_eigs = []
all_min_eigs = []

np.random.seed(123)
for trial in range(200):
    x = np.random.exponential(1.0, 5)
    M = certificate_matrix(coeffs_u35, x)
    eigs = np.linalg.eigvalsh(M)
    all_max_eigs.append(np.max(eigs))
    all_min_eigs.append(np.min(eigs))

ax3.hist(all_max_eigs, bins=30, alpha=0.7, color='#e74c3c', label='Max eigenvalue', edgecolor='black')
ax3.axvline(x=0, color='black', linewidth=2, linestyle='--', label='Zero line')
ax3.set_xlabel('Maximum eigenvalue of M_g(x)', fontsize=11)
ax3.set_ylabel('Count', fontsize=11)
ax3.set_title('U_{3,5}: Max Eigenvalue Distribution\n(200 random positive points)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('certificate_visualization.png', dpi=150, bbox_inches='tight')
print("Saved certificate_visualization.png")
