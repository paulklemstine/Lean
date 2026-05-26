#!/usr/bin/env python3
"""
Visualization: Spectral Bridge — Eigenvalues to Partition Function
===================================================================

Illustrates the cross-domain bridge theorem:
det(I + tK) = ∏_i (1 + t·λ_i)

Shows how the partition function (a combinatorial/probabilistic object)
is completely determined by the spectrum (a linear-algebraic object).
Left: individual eigenvalue contributions. Right: the product.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def random_psd_matrix(n, seed=42):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    return A.T @ A


def principal_minor(K, S):
    if len(S) == 0:
        return 1.0
    idx = list(S)
    return np.linalg.det(K[np.ix_(idx, idx)])


n = 5
K = random_psd_matrix(n, seed=42)
eigenvalues = np.sort(np.linalg.eigvalsh(K))

t_vals = np.linspace(0, 2, 200)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Individual eigenvalue factors
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, n))
for k, (lam, color) in enumerate(zip(eigenvalues, colors)):
    ax.plot(t_vals, 1 + lam * t_vals, color=color, linewidth=2,
            label=f'λ_{k+1} = {lam:.2f}')
ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('1 + λ_i · t', fontsize=12)
ax.set_title('Individual Eigenvalue Factors', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

# Panel 2: Partition function via product vs via principal minors
ax = axes[1]
z_product = np.array([np.prod(1 + eigenvalues * t) for t in t_vals])
z_det = np.array([np.linalg.det(np.eye(n) + t * K) for t in t_vals])

ax.plot(t_vals, z_product, 'b-', linewidth=2.5, label='∏(1 + λᵢt)')
ax.plot(t_vals, z_det, 'r--', linewidth=2, label='det(I + tK)')

# Also show the principal minor sum
z_minor = np.zeros_like(t_vals)
for k in range(n + 1):
    e_k = sum(principal_minor(K, list(S)) for S in combinations(range(n), k))
    z_minor += e_k * t_vals ** k
ax.plot(t_vals, z_minor, 'g:', linewidth=2, label='Σ eₖ(K)·tᵏ')

ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('Z_K(t,...,t)', fontsize=12)
ax.set_title('Three Equivalent Representations\nof the Partition Function', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Elementary symmetric polynomials (coefficients)
ax = axes[2]
e_k_vals = []
for k in range(n + 1):
    e_k = sum(principal_minor(K, list(S)) for S in combinations(range(n), k))
    e_k_vals.append(e_k)

bars = ax.bar(range(n + 1), e_k_vals, color=plt.cm.plasma(np.linspace(0.2, 0.8, n + 1)),
              edgecolor='black', linewidth=0.5)
ax.set_xlabel('Degree k', fontsize=12)
ax.set_ylabel('eₖ(K) = Σ_{|S|=k} det(K_S)', fontsize=12)
ax.set_title('Elementary Symmetric Functions\n(Principal Minor Sums)', fontsize=13, fontweight='bold')
ax.set_xticks(range(n + 1))

# Add value labels
for bar, val in zip(bars, e_k_vals):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + max(e_k_vals) * 0.02,
            f'{val:.1f}', ha='center', va='bottom', fontsize=9)

ax.grid(True, alpha=0.3, axis='y')

fig.suptitle('The Spectral Bridge: DPP Partition Function ↔ Eigenvalue Statistics',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_bridge.png")
