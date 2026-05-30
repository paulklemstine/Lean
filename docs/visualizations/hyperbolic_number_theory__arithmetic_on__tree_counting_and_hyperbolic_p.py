"""
Visualization: Tree Counting and the Hyperbolic Prime Number Theorem
=====================================================================

Visualizes the combinatorial structure underlying the counting
of "hyperbolic primes" — vertices in regular trees that serve as
analogues of prime numbers in hyperbolic arithmetic.

Shows:
1. Binary tree counting (2n+1 formula, formally proven)
2. General k-regular tree growth rates
3. The geometric sum bound (formally proven)
"""

import numpy as np
import matplotlib.pyplot as plt


def tree_count_at_depth(k, n):
    """Vertices at depth n in a k-regular tree."""
    if n == 0:
        return 1
    return k * (k - 1) ** (n - 1)


def tree_total(k, n):
    """Total vertices up to depth n."""
    return sum(tree_count_at_depth(k, d) for d in range(n + 1))


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# --- Panel 1: Binary tree formula ---
ax1 = axes[0]

n_max = 15
ns = list(range(n_max + 1))
totals = [tree_total(2, n) for n in ns]
formula = [2 * n + 1 for n in ns]

ax1.plot(ns, totals, 'bo-', markersize=8, linewidth=2, label='Actual count', zorder=5)
ax1.plot(ns, formula, 'r--', linewidth=2, label='Formula: 2n + 1')

# Shade the "proven" region
ax1.fill_between(ns, 0, formula, alpha=0.1, color='green')

ax1.set_xlabel('Depth n', fontsize=12)
ax1.set_ylabel('Total vertices', fontsize=12)
ax1.set_title('Binary Tree: Total = 2n + 1\n(Formally Proven)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Annotate
ax1.annotate('treeCount_binary:\nΣ treeCountAtDepth 2 i = 2n + 1',
             xy=(10, 21), fontsize=9,
             bbox=dict(boxstyle='round,pad=0.4', facecolor='lightgreen', alpha=0.8))

# --- Panel 2: k-regular tree growth ---
ax2 = axes[1]

n_max = 10
ns = list(range(n_max + 1))

for k in [2, 3, 4, 5]:
    totals = [tree_total(k, n) for n in ns]
    ax2.semilogy(ns, totals, 'o-', linewidth=2, markersize=6,
                 label=f'k = {k}')

    # Exponential bound
    bounds = [sum(k**i for i in range(n + 1)) for n in ns]
    ax2.semilogy(ns, bounds, '--', alpha=0.4, linewidth=1)

ax2.set_xlabel('Depth n', fontsize=12)
ax2.set_ylabel('Total vertices (log scale)', fontsize=12)
ax2.set_title('k-Regular Tree Growth\n(dashed = exponential bound, proven)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, which='both')

# --- Panel 3: Per-depth counts and "hyperbolic primes" ---
ax3 = axes[2]

k = 3
n_max = 8
ns = list(range(n_max + 1))
per_depth = [tree_count_at_depth(k, n) for n in ns]

# Color depth-1 points as "primes"
colors = ['gold' if n == 1 else 'steelblue' for n in ns]
bars = ax3.bar(ns, per_depth, color=colors, edgecolor='black', linewidth=0.5)

# Add exponential bound line
exp_bound = [k**n for n in ns]
ax3.plot(ns, exp_bound, 'r--', linewidth=2, label=f'Bound: {k}^n', zorder=5)

ax3.set_xlabel('Depth n', fontsize=12)
ax3.set_ylabel('Vertices at depth n', fontsize=12)
ax3.set_title(f'{k}-Regular Tree: Depth Counts\n(Gold = "Hyperbolic Primes")',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3, axis='y')

# Annotate primes
ax3.annotate('"Primes" = depth 1\n(generators of lattice)',
             xy=(1, per_depth[1]),
             xytext=(3, per_depth[1] * 1.5),
             fontsize=9,
             arrowprops=dict(arrowstyle='->', color='darkgoldenrod', linewidth=2),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

# Add counts as labels
for i, (n, c) in enumerate(zip(ns, per_depth)):
    ax3.text(n, c + max(per_depth) * 0.02, str(c),
             ha='center', fontsize=8, fontweight='bold')

plt.tight_layout()
plt.savefig('tree_counting.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: tree_counting.png")
