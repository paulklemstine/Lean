"""
Certificate Tree Structure Visualization

Visualizes the key structural properties of certificate trees that were
formally verified:
1. Size = 2 * leaves - 1 (full binary tree property)
2. Leaves ≤ 2^depth (information-theoretic capacity)
3. Catalan number growth (tree shape enumeration)
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def catalan(n):
    """Compute n-th Catalan number."""
    return math.comb(2 * n, n) // (n + 1)


fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.suptitle('Formally Verified Properties of Certificate Trees',
             fontsize=15, fontweight='bold')

# ─── Panel 1: Size vs Leaves relationship ───
ax = axes[0]
leaves_range = np.arange(1, 65)
sizes = 2 * leaves_range - 1
internal = leaves_range - 1

ax.plot(leaves_range, sizes, 'b-', linewidth=2.5, label='Size = 2L − 1')
ax.plot(leaves_range, internal, 'r--', linewidth=2, label='Internal = L − 1')
ax.fill_between(leaves_range, internal, sizes, alpha=0.1, color='blue')

ax.set_xlabel('Number of Leaves (L)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Full Binary Tree Identity\n(Theorem: certSize = 2·certLeaves − 1)', fontsize=12)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(1, 64)

# ─── Panel 2: Information-theoretic capacity ───
ax = axes[1]
depths = np.arange(0, 12)
max_leaves = 2 ** depths

# Plot the bound
ax.semilogy(depths, max_leaves, 'r-', linewidth=2.5, label='Max leaves = 2^d')

# Plot some example trees
example_depths = [2, 3, 4, 5, 6, 7, 8, 9, 10]
for d in example_depths:
    # Random tree with depth d has between d+1 and 2^d leaves
    for _ in range(5):
        actual_leaves = np.random.randint(d + 1, 2 ** d + 1) if d > 0 else 1
        ax.plot(d, actual_leaves, 'bo', markersize=4, alpha=0.4)

ax.set_xlabel('Tree Depth (d)', fontsize=12)
ax.set_ylabel('Number of Leaves (log scale)', fontsize=12)
ax.set_title('Information Capacity Bound\n(Theorem: certLeaves ≤ 2^certDepth)', fontsize=12)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.5, 11.5)

# ─── Panel 3: Catalan numbers ───
ax = axes[2]
n_range = list(range(12))
catalan_vals = [catalan(n) for n in n_range]

ax.bar(n_range, catalan_vals, color='#4CAF50', alpha=0.7, edgecolor='black', linewidth=0.5)

# Add values on bars
for i, v in enumerate(catalan_vals):
    if v < 10000:
        ax.text(i, v + max(catalan_vals) * 0.02, str(v),
                ha='center', fontsize=8, fontweight='bold')

ax.set_xlabel('Number of Internal Nodes (n)', fontsize=12)
ax.set_ylabel('Number of Tree Shapes', fontsize=12)
ax.set_title('Catalan Numbers: Certificate Tree Shapes\n(Theorem: catalanNumber_pos)', fontsize=12)
ax.grid(True, alpha=0.3, axis='y')

# Add asymptotic formula
ax2 = ax.twinx()
asymptotic = [4 ** n / (math.sqrt(math.pi * max(n, 0.5)) * max(n, 0.5) ** 1.5) if n > 0 else 1
              for n in n_range]
ax2.plot(n_range, asymptotic, 'r--', linewidth=1.5, alpha=0.5,
         label='Asymptotic: 4ⁿ/(√π · n^(3/2))')
ax2.set_ylabel('Asymptotic approximation', color='red', fontsize=10)
ax2.legend(loc='upper left', fontsize=9)

plt.tight_layout()
plt.savefig('cert_tree_properties.png', dpi=150, bbox_inches='tight')
print("Saved cert_tree_properties.png")
