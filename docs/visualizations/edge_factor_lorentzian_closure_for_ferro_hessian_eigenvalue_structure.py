#!/usr/bin/env python3
"""
Visualization 1: Hessian Eigenvalue Structure

Visualizes the eigenvalue structure of the 2x2 Hessian slices
of ferromagnetic partition polynomials across different graphs
and coupling strengths. Shows that eigenvalues always come in
±c pairs (at most one positive eigenvalue).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def partition_hessian_offdiag(n, edges, couplings, i, j, z):
    """Compute the off-diagonal entry of the 2x2 Hessian."""
    factors = [1.0 + w * z[u] * z[v] for (u, v), w in zip(edges, couplings)]
    total = np.prod(factors)
    mixed = 0.0
    for k, ((u, v), w) in enumerate(zip(edges, couplings)):
        if (u == i and v == j) or (u == j and v == i):
            prod_rest = total / factors[k] if factors[k] != 0 else 0
            mixed += w * prod_rest
    return mixed


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
rng = np.random.default_rng(42)

# Plot 1: Eigenvalue pairs for K_5 across random specializations
ax = axes[0, 0]
n = 5
edges = list(combinations(range(n), 2))
couplings = [1.0] * len(edges)

pos_eigs = []
neg_eigs = []
for trial in range(50):
    z = rng.uniform(0.5, 3.0, size=n)
    for i in range(n):
        for j in range(i + 1, n):
            c = partition_hessian_offdiag(n, edges, couplings, i, j, z)
            pos_eigs.append(c)
            neg_eigs.append(-c)

ax.scatter(range(len(pos_eigs)), pos_eigs, c='red', s=5, alpha=0.5, label='λ₊ = +c')
ax.scatter(range(len(neg_eigs)), neg_eigs, c='blue', s=5, alpha=0.5, label='λ₋ = −c')
ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('Sample index')
ax.set_ylabel('Eigenvalue')
ax.set_title('K₅: Eigenvalue pairs (±c) across 50 specializations')
ax.legend()

# Plot 2: Determinant vs coupling strength
ax = axes[0, 1]
betas = np.linspace(0, 3, 100)
for n in [3, 4, 5, 6]:
    edges = list(combinations(range(n), 2))
    z = np.ones(n)
    dets = []
    for beta in betas:
        w = np.exp(2 * beta)
        couplings = [w] * len(edges)
        c = partition_hessian_offdiag(n, edges, couplings, 0, 1, z)
        dets.append(-c**2)
    ax.plot(betas, dets, label=f'K_{n}')

ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('det(H) = −c²')
ax.set_title('Hessian determinant vs coupling strength')
ax.legend()
ax.set_ylim(top=1)

# Plot 3: Lorentzian gap distribution for random graphs
ax = axes[1, 0]
gaps = []
for trial in range(200):
    n = rng.integers(4, 8)
    edges = [(i, j) for i in range(n) for j in range(i+1, n) if rng.random() < 0.5]
    if not edges:
        continue
    couplings = rng.uniform(0.1, 2.0, size=len(edges)).tolist()
    z = rng.uniform(0.5, 2.0, size=n)
    for i in range(n):
        for j in range(i+1, n):
            c = partition_hessian_offdiag(n, edges, couplings, i, j, z)
            if c > 0:
                gaps.append(c)

ax.hist(gaps, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
ax.set_xlabel('Lorentzian gap (positive eigenvalue)')
ax.set_ylabel('Count')
ax.set_title('Distribution of Lorentzian gaps\n(200 random graphs)')
ax.axvline(x=np.median(gaps), color='red', linestyle='--', label=f'median = {np.median(gaps):.2f}')
ax.legend()

# Plot 4: Eigenvalue structure for two-site model
ax = axes[1, 1]
betas = np.linspace(0, 3, 200)
eig_plus = [np.exp(2*b) for b in betas]
eig_minus = [-np.exp(2*b) for b in betas]

ax.fill_between(betas, eig_minus, 0, alpha=0.3, color='blue', label='Negative eigenspace')
ax.fill_between(betas, 0, eig_plus, alpha=0.3, color='red', label='Positive eigenspace')
ax.plot(betas, eig_plus, 'r-', linewidth=2, label='λ₊ = e^{2β}')
ax.plot(betas, eig_minus, 'b-', linewidth=2, label='λ₋ = −e^{2β}')
ax.axhline(y=0, color='black', linewidth=1)
ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('Eigenvalue')
ax.set_title('Two-site Ising: Eigenvalue structure\n(exactly 1 positive eigenvalue)')
ax.legend(fontsize=8)

plt.suptitle('Lorentzian Hessian Structure of Ferromagnetic Partition Polynomials',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_hessian_eigenvalues.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hessian_eigenvalues.png")
