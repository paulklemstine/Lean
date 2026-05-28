#!/usr/bin/env python3
"""
Visualization: Bosonic Partition Function — Arithmetic Statistics Bridge

Shows the identity between Cohen-Lenstra moments, bosonic partition functions,
and integer partition generating functions. This visualizes the cross-domain
theorem connecting number theory, statistical mechanics, and combinatorics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def cohen_lenstra_moment(p, k):
    """∏_{i=1}^{k} (1 - p^{-i})^{-1}"""
    result = 1.0
    for i in range(1, k + 1):
        result /= (1.0 - p ** (-i))
    return result


def partition_count(n, k):
    """Number of partitions of n into at most k parts (dynamic programming)."""
    dp = [[0] * (k + 1) for _ in range(n + 1)]
    for j in range(k + 1):
        dp[0][j] = 1
    for i in range(1, n + 1):
        for j in range(1, k + 1):
            dp[i][j] = dp[i][j-1]
            if i >= j:
                dp[i][j] += dp[i-j][j]
    return dp[n][k]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Cohen-Lenstra moments for various primes
ax = axes[0, 0]
k_range = range(1, 12)
for p in [2, 3, 5, 7, 11]:
    moments = [cohen_lenstra_moment(p, k) for k in k_range]
    ax.plot(list(k_range), moments, 'o-', linewidth=2, markersize=6,
            label=f'p = {p}')
ax.set_xlabel('k (number of factors)', fontsize=12)
ax.set_ylabel('M(p, k)', fontsize=12)
ax.set_title('Cohen-Lenstra Moments ∏(1 - p⁻ⁱ)⁻¹', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 2: Partition function connection
ax = axes[0, 1]
q_vals = np.linspace(0.1, 0.9, 100)
for k in [1, 2, 3, 5, 10]:
    gen_func = np.array([np.prod([1/(1 - q**i) for i in range(1, k+1)])
                         for q in q_vals])
    ax.plot(q_vals, gen_func, linewidth=2, label=f'k = {k}')
ax.set_xlabel('q', fontsize=12)
ax.set_ylabel('∏(1 - qⁱ)⁻¹', fontsize=12)
ax.set_title('Partition Generating Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 3: Heatmap of moments M(p, k)
ax = axes[1, 0]
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
k_range_heat = range(1, 8)
moment_matrix = np.array([[cohen_lenstra_moment(p, k) for k in k_range_heat]
                           for p in primes])
im = ax.imshow(np.log10(moment_matrix), aspect='auto', cmap='YlOrRd',
               interpolation='nearest')
ax.set_xticks(range(len(list(k_range_heat))))
ax.set_xticklabels([str(k) for k in k_range_heat])
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([str(p) for p in primes])
ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('Prime p', fontsize=12)
ax.set_title('log₁₀ M(p,k) — Moment Heatmap', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label='log₁₀(moment)')

# Panel 4: Convergence of partial products
ax = axes[1, 1]
for p in [2, 3, 5]:
    k_max = 30
    partial_prods = [cohen_lenstra_moment(p, k) for k in range(1, k_max + 1)]
    # The infinite product converges to ∏_{i=1}^∞ (1 - p^{-i})^{-1}
    limit = cohen_lenstra_moment(p, 50)  # Approximation of limit
    ratios = [pp / limit for pp in partial_prods]
    ax.plot(range(1, k_max + 1), ratios, 'o-', markersize=4, linewidth=1.5,
            label=f'p = {p} (limit ≈ {limit:.4f})')

ax.axhline(y=1.0, color='black', linestyle=':', alpha=0.5)
ax.set_xlabel('k (truncation level)', fontsize=12)
ax.set_ylabel('M(p,k) / M(p,∞)', fontsize=12)
ax.set_title('Convergence to Infinite Product', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.5, 1.05)

fig.suptitle('The Arithmetic–Physics–Combinatorics Bridge\n'
             'Cohen-Lenstra Moments = Bosonic Partition Functions = Partition Generating Functions',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('partition_bridge.png', dpi=150, bbox_inches='tight')
print("Saved partition_bridge.png")
