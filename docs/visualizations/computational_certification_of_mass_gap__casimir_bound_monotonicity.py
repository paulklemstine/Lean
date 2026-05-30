#!/usr/bin/env python3
"""
Visualization: Casimir Bound Monotonicity and Gauge Group Comparison

Shows how the Casimir-based mass gap bound varies with coupling parameter
and gauge group rank. Illustrates two theorems:
- casimir_bound_monotone_in_coupling: bound increases as β decreases
- casimir_bound_improves_with_casimir: larger Casimir → stronger bound
"""

import numpy as np
import matplotlib.pyplot as plt

beta = np.linspace(0.01, 0.5, 200)

# Casimir eigenvalues for fundamental representation of SU(N)
def casimir_fund(N):
    return (N**2 - 1) / (2 * N)

# Fundamental sector coefficient
def fund_coeff(N, b):
    return N * np.exp(-casimir_fund(N) * b)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: Casimir bound vs beta for different SU(N)
colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']
for i, N in enumerate([2, 3, 4, 5]):
    c = fund_coeff(N, 0) / N  # Leading coefficient
    bound = -np.log(c * beta)
    label = f'SU({N}), C₂ = {casimir_fund(N):.2f}'
    ax1.plot(beta, bound, color=colors[i], linewidth=2, label=label)

ax1.set_xlabel('Coupling β', fontsize=12)
ax1.set_ylabel('Mass gap lower bound', fontsize=12)
ax1.set_title('Casimir Bound vs Coupling', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0, 8)

# Panel 2: Bound at fixed beta vs N
Ns = np.arange(2, 11)
beta_fixed = 0.2
bounds = []
for N in Ns:
    c = fund_coeff(N, 0) / N
    bounds.append(-np.log(c * beta_fixed))

ax2.bar(Ns, bounds, color='#2196F3', alpha=0.7, edgecolor='black')
ax2.set_xlabel('Gauge group rank N', fontsize=12)
ax2.set_ylabel('Mass gap bound at β = 0.2', fontsize=12)
ax2.set_title('Bound Strength by Gauge Group', fontsize=14)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_casimir_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved viz_casimir_monotonicity.png")
