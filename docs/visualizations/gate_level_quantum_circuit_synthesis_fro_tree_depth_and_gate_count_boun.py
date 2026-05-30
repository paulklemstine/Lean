#!/usr/bin/env python3
"""
Visualization: Certificate Tree Depth vs Gate Count Bounds

Shows the relationship between tree depth, branch count, and leaf count
for certificate trees of various sizes. Verifies the structural identity
leafCount = branchCount + 1 and the exponential depth bound.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def tree_stats(n, r):
    """
    Compute certificate tree statistics for U(r,n) via recursion.

    Returns (depth, branch_count, leaf_count, size).
    """
    memo = {}

    def _stats(n_elts, rank):
        if (n_elts, rank) in memo:
            return memo[(n_elts, rank)]
        if rank == 0 or rank == n_elts:
            result = (0, 0, 1, 1)  # depth, branches, leaves, size
        elif rank > n_elts or rank < 0:
            result = (0, 0, 1, 1)
        else:
            d_del = _stats(n_elts - 1, rank)
            d_con = _stats(n_elts - 1, rank - 1)
            depth = 1 + max(d_del[0], d_con[0])
            branches = 1 + d_del[1] + d_con[1]
            leaves = d_del[2] + d_con[2]
            size = 1 + d_del[3] + d_con[3]
            result = (depth, branches, leaves, size)
        memo[(n_elts, rank)] = result
        return result

    return _stats(n, r)


# ============================================================
# Generate data
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Certificate Tree Structure: Depth, Gates, and Bounds',
             fontsize=14, fontweight='bold')

# Panel 1: Structural identity verification
ax1 = axes[0]
ns = range(2, 16)
for r in [2, 3, 4, 5]:
    diffs = []
    n_vals = []
    for n in ns:
        if r <= n:
            stats = tree_stats(n, r)
            diffs.append(stats[2] - stats[1])  # leafCount - branchCount
            n_vals.append(n)
    ax1.plot(n_vals, diffs, 'o-', label=f'rank {r}', markersize=5)

ax1.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Expected = 1')
ax1.set_xlabel('Ground set size n')
ax1.set_ylabel('leafCount − branchCount')
ax1.set_title('Structural Identity: lc = bc + 1')
ax1.legend()
ax1.set_ylim(0, 2)

# Panel 2: Depth vs branch count
ax2 = axes[1]
for r in [2, 3, 4, 5]:
    depths = []
    branches = []
    for n in range(r, 16):
        stats = tree_stats(n, r)
        depths.append(stats[0])
        branches.append(stats[1])
    ax2.plot(branches, depths, 'o-', label=f'rank {r}', markersize=5)

# Add y=x line
max_bc = max(tree_stats(15, r)[1] for r in [2, 3, 4, 5])
ax2.plot([0, max_bc], [0, max_bc], 'k--', alpha=0.3, label='depth = bc')
ax2.set_xlabel('Branch count (= gate count)')
ax2.set_ylabel('Tree depth (= circuit depth)')
ax2.set_title('Depth ≤ Branch Count')
ax2.legend()

# Panel 3: Branch count vs 2^(depth+1) bound
ax3 = axes[2]
for r in [2, 3, 4, 5]:
    ratios = []
    n_vals = []
    for n in range(r, 16):
        stats = tree_stats(n, r)
        bound = 2 ** (stats[0] + 1)
        ratios.append(stats[1] / bound)
        n_vals.append(n)
    ax3.plot(n_vals, ratios, 'o-', label=f'rank {r}', markersize=5)

ax3.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Bound = 1')
ax3.set_xlabel('Ground set size n')
ax3.set_ylabel('branchCount / 2^(depth+1)')
ax3.set_title('Exponential Bound: bc < 2^(d+1)')
ax3.legend()

plt.tight_layout()
plt.savefig('tree_depth_bounds.png', dpi=150, bbox_inches='tight')
print("Saved tree_depth_bounds.png")
