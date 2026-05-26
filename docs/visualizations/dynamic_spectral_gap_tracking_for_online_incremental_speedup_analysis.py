"""
Visualization: Incremental vs Full Recomputation Speedup

Shows the computational speedup of incremental certificate updates
over full recomputation as a function of problem size and update sparsity.

This visualizes the algorithmic consequence of the locality theorem:
sparse updates require recomputing only a small fraction of the certificate.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def total_leaves(n, d):
    target = d - 2
    if target < 0 or n <= 0:
        return 0
    return comb(n + target - 1, target)


def affected_upper_bound(n, d, sparsity):
    """Upper bound on affected leaves for update with given sparsity."""
    target = d - 2
    if target < 0:
        return 0
    # Product bound: (1+1)^sparsity * 1^(n-sparsity) = 2^sparsity
    # But need to filter by |β| = target
    # Better estimate: C(sparsity + target - 1, target) when sparsity < n
    return min(comb(sparsity + target - 1, target), total_leaves(n, d))


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Speedup vs n for fixed sparsity
ax = axes[0]
for s in [1, 2, 3]:
    ns = list(range(4, 13))
    speedups = []
    for n in ns:
        d = n
        total = total_leaves(n, d)
        affected = affected_upper_bound(n, d, s)
        speedups.append(total / max(1, affected))
    ax.semilogy(ns, speedups, 'o-', label=f'sparsity = {s}', markersize=6, linewidth=2)

ax.set_xlabel('Number of variables (n)', fontsize=12)
ax.set_ylabel('Speedup (total / affected)', fontsize=12)
ax.set_title('Incremental Speedup vs Dimension\n(d = n)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Speedup vs degree for fixed n
ax2 = axes[1]
n_fixed = 8
for s in [1, 2, 3]:
    ds = list(range(3, 10))
    speedups = []
    for d in ds:
        total = total_leaves(n_fixed, d)
        affected = affected_upper_bound(n_fixed, d, s)
        speedups.append(total / max(1, affected))
    ax2.plot(ds, speedups, 's-', label=f'sparsity = {s}', markersize=6, linewidth=2)

ax2.set_xlabel('Degree (d)', fontsize=12)
ax2.set_ylabel('Speedup (total / affected)', fontsize=12)
ax2.set_title(f'Incremental Speedup vs Degree\n(n = {n_fixed})', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Full recomp cost vs incremental cost
ax3 = axes[2]
ns = list(range(4, 10))
full_costs = []
incr_costs_s1 = []
incr_costs_s2 = []

for n in ns:
    d = n
    total = total_leaves(n, d)
    full_costs.append(total * n * n)

    aff1 = affected_upper_bound(n, d, 1)
    incr_costs_s1.append(aff1 * n * n)

    aff2 = affected_upper_bound(n, d, 2)
    incr_costs_s2.append(aff2 * n * n)

ax3.semilogy(ns, full_costs, 'k^-', label='Full recomputation', markersize=8, linewidth=2)
ax3.semilogy(ns, incr_costs_s1, 'go-', label='Incremental (sparsity=1)', markersize=6, linewidth=2)
ax3.semilogy(ns, incr_costs_s2, 'bs-', label='Incremental (sparsity=2)', markersize=6, linewidth=2)

ax3.set_xlabel('Number of variables (n)', fontsize=12)
ax3.set_ylabel('Computational cost (operations)', fontsize=12)
ax3.set_title('Certificate Update Cost\n(d = n)', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_speedup.png', dpi=150, bbox_inches='tight')
print("Saved viz_speedup.png")
