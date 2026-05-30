"""
Visualization: Erdős Ramsey Lower Bounds

Plots the Ramsey lower bound R(k,k) > 2^{k/2} alongside known exact values
and upper bounds, showing the exponential gap between lower and upper bounds.

This visualizes the core result of the probabilistic method: existence proofs
give surprisingly strong bounds, but the gap to exact values remains enormous.
"""

import math
import matplotlib.pyplot as plt
import numpy as np

# Known exact Ramsey numbers R(k,k)
exact_values = {
    1: 1,
    2: 2,
    3: 6,
    4: 18,
}

# Best known bounds
# R(5,5) ∈ [43, 48], R(6,6) ∈ [102, 165]
known_bounds = {
    5: (43, 48),
    6: (102, 165),
    7: (205, 540),
    8: (282, 1870),
}

k_values = np.arange(2, 15)

# Erdős probabilistic lower bound: largest n where 2*C(n,k) < 2^C(k,2)
erdos_lower = []
for k in k_values:
    threshold = 2 ** math.comb(int(k), 2)
    best_n = 1
    for n in range(1, 100000):
        if 2 * math.comb(n, int(k)) < threshold:
            best_n = n
        else:
            break
    erdos_lower.append(best_n)

# Simple upper bound: R(k,k) ≤ C(2k-2, k-1) + 1
upper_bounds = [math.comb(2 * int(k) - 2, int(k) - 1) + 1 for k in k_values]

# 2^{k/2} approximation
approx_lower = [2 ** (k / 2) for k in k_values]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Log scale comparison
ax1.semilogy(k_values, erdos_lower, 'bo-', linewidth=2, markersize=8, label='Erdős lower bound (proved)')
ax1.semilogy(k_values, approx_lower, 'g--', linewidth=1.5, label=r'$2^{k/2}$ approximation')
ax1.semilogy(k_values, upper_bounds, 'r^-', linewidth=2, markersize=8, label=r'Upper bound $\binom{2k-2}{k-1}+1$')

# Plot exact values
exact_k = list(exact_values.keys())
exact_v = list(exact_values.values())
ax1.semilogy(exact_k, exact_v, 'ks', markersize=12, label='Exact R(k,k)', zorder=5)

# Plot known bounds
for k, (lo, hi) in known_bounds.items():
    ax1.fill_between([k - 0.1, k + 0.1], [lo, lo], [hi, hi], alpha=0.3, color='orange')
    ax1.semilogy(k, (lo + hi) / 2, 'D', color='orange', markersize=8)

ax1.set_xlabel('k', fontsize=14)
ax1.set_ylabel('R(k,k)', fontsize=14)
ax1.set_title('Ramsey Numbers: Lower vs Upper Bounds', fontsize=15)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 14.5)

# Plot 2: The gap ratio (upper/lower) showing how much we don't know
gap_ratio = [u / l for u, l in zip(upper_bounds, erdos_lower)]
ax2.bar(k_values, gap_ratio, color='steelblue', alpha=0.7, edgecolor='black')
ax2.set_xlabel('k', fontsize=14)
ax2.set_ylabel('Upper / Lower bound ratio', fontsize=14)
ax2.set_title('The Ramsey Gap: What We Don\'t Know', fontsize=15)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3, axis='y')

# Annotate
for i, (k, ratio) in enumerate(zip(k_values, gap_ratio)):
    if k <= 8:
        ax2.text(k, ratio * 1.2, f'{ratio:.0f}x', ha='center', fontsize=9)

plt.tight_layout()
plt.savefig('ramsey_bounds.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved ramsey_bounds.png")
