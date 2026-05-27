"""
Visualization: Scaling Curves — Dynamic vs Rebuild Cost
========================================================

Shows how dynamic certificate update cost scales with the number of
variables and degree, compared to full rebuild. Demonstrates the
polynomial-time savings of dynamic certification for sparse updates.
"""

import numpy as np
import matplotlib.pyplot as plt


def affected_count(alpha, k):
    """Count multiindices beta with sum(beta)=k, beta_i <= alpha_i."""
    n = len(alpha)
    count = [0]
    def _bt(idx, rem):
        if idx == n:
            if rem == 0:
                count[0] += 1
            return
        for v in range(min(alpha[idx], rem) + 1):
            _bt(idx + 1, rem - v)
    _bt(0, k)
    return count[0]


def dynamic_cost(alpha, d):
    return sum(affected_count(alpha, k) for k in range(d - 1))


# ── Scaling with number of variables ────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

# Panel 1: Cost vs n for fixed degree d=4
ax = axes[0, 0]
ns = range(3, 13)
d = 4

rebuild_costs = [n ** d for n in ns]

# Sparse: concentrated in 1 variable
sparse_costs = [dynamic_cost(tuple([d] + [0]*(n-1)), d) for n in ns]
# Moderate: spread across 2 variables
moderate_costs = [dynamic_cost(tuple([d//2, d-d//2] + [0]*(n-2)), d) for n in ns]
# Balanced: spread across all variables (only possible if d >= n)
balanced_costs = []
for n in ns:
    base = d // n
    rem = d - base * n
    alpha = tuple([base + (1 if i < rem else 0) for i in range(n)])
    balanced_costs.append(dynamic_cost(alpha, d))

ax.semilogy(list(ns), rebuild_costs, 'r-o', linewidth=2, markersize=6, label='Rebuild (n^d)')
ax.semilogy(list(ns), sparse_costs, 'b-s', linewidth=2, markersize=5, label='Dynamic (sparse α)')
ax.semilogy(list(ns), moderate_costs, 'g-^', linewidth=2, markersize=5, label='Dynamic (moderate α)')
ax.semilogy(list(ns), balanced_costs, 'm-v', linewidth=2, markersize=5, label='Dynamic (balanced α)')
ax.set_xlabel('Number of Variables (n)', fontsize=12)
ax.set_ylabel('Certificate Cost (log scale)', fontsize=12)
ax.set_title(f'Scaling with Variables (d={d})', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Speedup ratio
ax2 = axes[0, 1]
sparse_speedup = [r/d_c if d_c > 0 else 0 for r, d_c in zip(rebuild_costs, sparse_costs)]
moderate_speedup = [r/d_c if d_c > 0 else 0 for r, d_c in zip(rebuild_costs, moderate_costs)]
balanced_speedup = [r/d_c if d_c > 0 else 0 for r, d_c in zip(rebuild_costs, balanced_costs)]

ax2.plot(list(ns), sparse_speedup, 'b-s', linewidth=2, markersize=5, label='Sparse')
ax2.plot(list(ns), moderate_speedup, 'g-^', linewidth=2, markersize=5, label='Moderate')
ax2.plot(list(ns), balanced_speedup, 'm-v', linewidth=2, markersize=5, label='Balanced')
ax2.set_xlabel('Number of Variables (n)', fontsize=12)
ax2.set_ylabel('Speedup (Rebuild / Dynamic)', fontsize=12)
ax2.set_title(f'Dynamic Speedup Factor (d={d})', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Cost vs degree for fixed n=6
ax3 = axes[1, 0]
n = 6
ds = range(3, 9)

rebuild_d = [n ** d for d in ds]
sparse_d = [dynamic_cost(tuple([d] + [0]*(n-1)), d) for d in ds]
moderate_d = [dynamic_cost(tuple([d//2, d-d//2] + [0]*(n-2)), d) for d in ds]

ax3.semilogy(list(ds), rebuild_d, 'r-o', linewidth=2, markersize=6, label='Rebuild (n^d)')
ax3.semilogy(list(ds), sparse_d, 'b-s', linewidth=2, markersize=5, label='Dynamic (sparse)')
ax3.semilogy(list(ds), moderate_d, 'g-^', linewidth=2, markersize=5, label='Dynamic (moderate)')
ax3.set_xlabel('Degree (d)', fontsize=12)
ax3.set_ylabel('Certificate Cost (log scale)', fontsize=12)
ax3.set_title(f'Scaling with Degree (n={n})', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Affected fraction by depth
ax4 = axes[1, 1]
n, d = 8, 6
alpha_sparse = tuple([d] + [0]*(n-1))
alpha_moderate = tuple([d//2, d-d//2] + [0]*(n-2))
alpha_balanced = tuple([d//n + (1 if i < d % n else 0) for i in range(n)])

depths = range(d - 1)
from math import comb
total_at_depth = [comb(k + n - 1, n - 1) for k in depths]

sparse_frac = [affected_count(alpha_sparse, k) / t if t > 0 else 0
               for k, t in zip(depths, total_at_depth)]
mod_frac = [affected_count(alpha_moderate, k) / t if t > 0 else 0
            for k, t in zip(depths, total_at_depth)]
bal_frac = [affected_count(alpha_balanced, k) / t if t > 0 else 0
            for k, t in zip(depths, total_at_depth)]

x = np.arange(len(depths))
w = 0.25
ax4.bar(x - w, sparse_frac, w, label='Sparse', color='steelblue', alpha=0.8)
ax4.bar(x, mod_frac, w, label='Moderate', color='forestgreen', alpha=0.8)
ax4.bar(x + w, bal_frac, w, label='Balanced', color='mediumpurple', alpha=0.8)
ax4.set_xlabel('Derivative Depth (k)', fontsize=12)
ax4.set_ylabel('Affected Fraction', fontsize=12)
ax4.set_title(f'Affected Fraction by Depth (n={n}, d={d})', fontsize=13, fontweight='bold')
ax4.set_xticks(x)
ax4.set_xticklabels([f'{k}' for k in depths])
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_scaling_curves.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_scaling_curves.png")
