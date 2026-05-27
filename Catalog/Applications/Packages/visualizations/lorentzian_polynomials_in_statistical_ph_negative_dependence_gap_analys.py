#!/usr/bin/env python3
"""
Visualization 3: Negative Dependence Gap as a Function of Off-Diagonal Coupling

Visualizes how the negative dependence gap (K_ii*K_jj - det K_{ij})
varies as the off-diagonal coupling K_ij changes. For symmetric PSD
matrices, this gap equals K_ij^2, forming a parabola.

Also shows how eigenvalue spread affects the overall negative dependence
structure across all pairs.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Gap = K_ij^2 as function of coupling
ax = axes[0]

# Fix K_ii = 2, K_jj = 3, vary K_ij
K_ii, K_jj = 2.0, 3.0
K_ij_vals = np.linspace(-np.sqrt(K_ii * K_jj), np.sqrt(K_ii * K_jj), 200)

# det K_{ij} = K_ii * K_jj - K_ij^2
det_vals = K_ii * K_jj - K_ij_vals**2
product_vals = np.full_like(K_ij_vals, K_ii * K_jj)
gap_vals = product_vals - det_vals  # = K_ij^2

ax.fill_between(K_ij_vals, det_vals, product_vals, alpha=0.2, color='green',
                label='Gap = $K_{ij}^2 \\geq 0$')
ax.plot(K_ij_vals, det_vals, 'b-', linewidth=2, label='$\\det K_{\\{i,j\\}} = K_{ii}K_{jj} - K_{ij}^2$')
ax.plot(K_ij_vals, product_vals, 'r--', linewidth=2, label='$K_{ii} \\cdot K_{jj}$')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

# Mark PSD boundary
ax.axvline(x=-np.sqrt(K_ii * K_jj), color='orange', linestyle=':', alpha=0.7)
ax.axvline(x=np.sqrt(K_ii * K_jj), color='orange', linestyle=':', alpha=0.7)
ax.text(np.sqrt(K_ii * K_jj) + 0.05, K_ii * K_jj * 0.5, 'PSD\nboundary',
        fontsize=8, color='orange')

ax.set_xlabel('$K_{ij}$ (off-diagonal coupling)', fontsize=11)
ax.set_ylabel('Probability / Weight', fontsize=11)
ax.set_title('Negative Dependence Gap\n$\\Pr[i \\in S] \\cdot \\Pr[j \\in S] - \\Pr[i,j \\in S] = K_{ij}^2$',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9, loc='lower center')
ax.grid(True, alpha=0.3)

# Plot 2: Eigenvalue spread vs max correlation ratio
ax = axes[1]

n = 6
spreads = np.logspace(-1, 2, 50)
max_ratios = []
mean_ratios = []

for spread in spreads:
    U, _ = np.linalg.qr(np.random.randn(n, n))
    eigenvalues = np.linspace(1, 1 + spread, n)
    K = U @ np.diag(eigenvalues) @ U.T
    K = (K + K.T) / 2
    
    ratios = []
    for i in range(n):
        for j in range(i + 1, n):
            product = K[i, i] * K[j, j]
            if product > 1e-15:
                pair = K[i, i] * K[j, j] - K[i, j] * K[j, i]
                ratios.append(pair / product)
    
    if ratios:
        max_ratios.append(max(ratios))
        mean_ratios.append(np.mean(ratios))
    else:
        max_ratios.append(1.0)
        mean_ratios.append(1.0)

ax.semilogx(spreads, max_ratios, 'b-', linewidth=2, label='Max ratio')
ax.semilogx(spreads, mean_ratios, 'g-', linewidth=2, label='Mean ratio')
ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Upper bound (=1)')
ax.fill_between(spreads, 0, 1, alpha=0.05, color='green')

ax.set_xlabel('Eigenvalue spread $\\lambda_{max} - \\lambda_{min}$', fontsize=11)
ax.set_ylabel('Correlation ratio', fontsize=11)
ax.set_title('Eigenvalue Spread vs\nCorrelation Ratio', fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.1)

# Plot 3: Rank vs negative dependence strength
ax = axes[2]

n = 8
ranks = range(1, n + 1)
avg_gaps = []
min_gaps = []

for rank in ranks:
    gaps_for_rank = []
    for trial in range(50):
        A = np.random.randn(rank, n)
        K = A.T @ A
        
        for i in range(n):
            for j in range(i + 1, n):
                product = K[i, i] * K[j, j]
                pair = K[i, i] * K[j, j] - K[i, j] * K[j, i]
                gap = product - pair  # = K_ij^2
                if product > 1e-10:
                    gaps_for_rank.append(gap / product)
    
    avg_gaps.append(np.mean(gaps_for_rank))
    min_gaps.append(np.percentile(gaps_for_rank, 5))

ax.bar(list(ranks), avg_gaps, alpha=0.7, color='steelblue', label='Mean relative gap')
ax.plot(list(ranks), min_gaps, 'ro-', markersize=6, label='5th percentile gap')

ax.set_xlabel('Rank of K', fontsize=11)
ax.set_ylabel('Relative gap  $(K_{ii}K_{jj} - \\det K_{ij}) / (K_{ii}K_{jj})$', fontsize=10)
ax.set_title(f'Matrix Rank vs\nNegative Dependence Strength (n={n})', fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')
ax.set_xticks(list(ranks))

fig.suptitle('Geometry of Negative Dependence in Determinantal Point Processes',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_negative_dependence.png', dpi=150, bbox_inches='tight')
print("Saved viz_negative_dependence.png")
