#!/usr/bin/env python3
"""
Visualization 3: Scaling of Dynamic vs Rebuild Certificate Cost

Shows how the dynamic-to-rebuild cost ratio scales with graph size for
graphic matroid (spanning tree) certificates. Demonstrates that the
locality theorem gives exponentially improving speedups as graph size grows.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def affected_count_dp(alpha, k):
    """Count affected multiindices via DP."""
    n = len(alpha)
    if k < 0:
        return 0
    dp = [0] * (k + 1)
    dp[0] = 1
    for i in range(n):
        new_dp = [0] * (k + 1)
        for j in range(k + 1):
            if dp[j] == 0:
                continue
            for v in range(min(alpha[i], k - j) + 1):
                new_dp[j + v] += dp[j]
        dp = new_dp
    return dp[k]


def dynamic_cert_cost(n, d, alpha):
    return n**2 * sum(affected_count_dp(alpha, k) for k in range(max(0, d - 1)))


def rebuild_cost(n, d):
    return n**d


# Scaling experiment: complete graphs K_m
vertex_counts = list(range(4, 16))
results = []

for n_v in vertex_counts:
    n_e = n_v * (n_v - 1) // 2  # edges in K_n
    d = n_v - 1  # spanning tree degree

    # Star tree: edges 0..n_v-2 are used
    alpha = tuple([1] * (n_v - 1) + [0] * (n_e - n_v + 1))

    dc = dynamic_cert_cost(n_e, d, alpha)
    rc = rebuild_cost(n_e, d)

    results.append({
        'n_v': n_v,
        'n_e': n_e,
        'd': d,
        'dynamic': dc,
        'rebuild': rc,
        'ratio': rc / max(dc, 1),
    })

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Costs on log scale
ax1 = axes[0]
ns = [r['n_v'] for r in results]
dyn_costs = [r['dynamic'] for r in results]
reb_costs = [r['rebuild'] for r in results]

ax1.semilogy(ns, reb_costs, 'ro-', label='Full Rebuild (n^d)', linewidth=2, markersize=6)
ax1.semilogy(ns, dyn_costs, 'bs-', label='Dynamic Update', linewidth=2, markersize=6)
ax1.set_xlabel('Number of Vertices', fontsize=12)
ax1.set_ylabel('Certificate Cost', fontsize=12)
ax1.set_title('Certificate Costs vs Graph Size', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Speedup ratio
ax2 = axes[1]
ratios = [r['ratio'] for r in results]
ax2.semilogy(ns, ratios, 'g^-', linewidth=2, markersize=8, color='darkgreen')
ax2.set_xlabel('Number of Vertices', fontsize=12)
ax2.set_ylabel('Speedup Ratio (Rebuild/Dynamic)', fontsize=12)
ax2.set_title('Dynamic Update Speedup', fontsize=13)
ax2.grid(True, alpha=0.3)
ax2.fill_between(ns, 1, ratios, alpha=0.15, color='green')

# Plot 3: Fraction of nodes affected
ax3 = axes[2]
fracs = [r['dynamic'] / max(r['rebuild'], 1) for r in results]
ax3.semilogy(ns, fracs, 'mD-', linewidth=2, markersize=6, color='purple')
ax3.set_xlabel('Number of Vertices', fontsize=12)
ax3.set_ylabel('Dynamic / Rebuild Cost Fraction', fontsize=12)
ax3.set_title('Cost Fraction (Lower = Better)', fontsize=13)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Full rebuild')
ax3.legend(fontsize=10)

plt.suptitle('Scaling: Dynamic vs Rebuild Certificate Cost\n'
             '(Complete graphs K_n, star tree monomial update)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")
