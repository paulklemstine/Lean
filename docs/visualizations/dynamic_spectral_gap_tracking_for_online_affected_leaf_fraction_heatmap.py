"""
Visualization: Affected Leaf Fraction Heatmap

Visualizes how the fraction of certificate leaves affected by a rank-1
monomial update depends on the number of variables (n) and the sparsity
of the update (number of nonzero entries in the exponent vector α).

This illustrates the core locality insight: sparse updates in high dimensions
affect a vanishingly small fraction of the certificate tree.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def enumerate_multiindices(n: int, total: int):
    """Enumerate all multiindices β ∈ ℕ^n with Σ β_i = total."""
    if n == 0:
        return [()] if total == 0 else []
    if n == 1:
        return [(total,)]
    result = []
    for b0 in range(total + 1):
        for rest in enumerate_multiindices(n - 1, total - b0):
            result.append((b0,) + rest)
    return result


def affected_count(n: int, d: int, sparsity: int) -> int:
    """Count affected leaves for an update with `sparsity` nonzero entries."""
    target = d - 2
    if target < 0 or n <= 0:
        return 0
    # Alpha = (1, 1, ..., 1, 0, ..., 0) with `sparsity` ones
    alpha = tuple(1 if i < sparsity else 0 for i in range(n))
    all_leaves = enumerate_multiindices(n, target)
    return sum(1 for beta in all_leaves
               if all(beta[i] <= alpha[i] for i in range(n)))


def total_leaves(n: int, d: int) -> int:
    """Total number of (d-2)-leaves."""
    target = d - 2
    if target < 0 or n <= 0:
        return 0
    return comb(n + target - 1, target)


# Parameters
n_values = list(range(3, 10))
sparsity_values = list(range(1, 10))

# Compute heatmap
heatmap = np.zeros((len(sparsity_values), len(n_values)))

for i, s in enumerate(sparsity_values):
    for j, n in enumerate(n_values):
        d = n  # degree = n
        s_actual = min(s, n)
        total = total_leaves(n, d)
        if total > 0 and n <= 8:  # Only compute for manageable sizes
            aff = affected_count(n, d, s_actual)
            heatmap[i, j] = aff / total
        else:
            heatmap[i, j] = np.nan

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap
ax = axes[0]
im = ax.imshow(heatmap, aspect='auto', cmap='YlOrRd',
               interpolation='nearest', origin='lower')
ax.set_xticks(range(len(n_values)))
ax.set_xticklabels(n_values)
ax.set_yticks(range(len(sparsity_values)))
ax.set_yticklabels(sparsity_values)
ax.set_xlabel('Number of variables (n)', fontsize=12)
ax.set_ylabel('Sparsity of update (# nonzero entries)', fontsize=12)
ax.set_title('Affected Leaf Fraction\n(d = n, α = (1,...,1,0,...,0))', fontsize=13)
plt.colorbar(im, ax=ax, label='Fraction of affected leaves')

# Line plot: fraction vs n for different sparsities
ax2 = axes[1]
for s in [1, 2, 3, 4]:
    fractions = []
    ns = []
    for n in range(3, 9):
        d = n
        total = total_leaves(n, d)
        if total > 0:
            aff = affected_count(n, d, min(s, n))
            fractions.append(aff / total)
            ns.append(n)
    if ns:
        ax2.semilogy(ns, fractions, 'o-', label=f'sparsity = {s}', markersize=6)

ax2.set_xlabel('Number of variables (n)', fontsize=12)
ax2.set_ylabel('Affected leaf fraction (log scale)', fontsize=12)
ax2.set_title('Fraction Decay with Dimension\n(sparser updates → smaller fraction)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_affected_fraction.png', dpi=150, bbox_inches='tight')
print("Saved viz_affected_fraction.png")
