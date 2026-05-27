"""
Visualization: Recursion Tree Pruning by Support Geometry

Illustrates the central insight: when recognizing a matroid basis polynomial
as Lorentzian, the derivative recursion tree is pruned by the matroid's
independent-set structure. Branches that would exist in the naive algorithm
are killed by the support geometry.

This visualization shows a concrete example: a small matroid with bases
{0,1,2} and {0,3,4} on ground set [5]. The recursion tree for the degree-3
basis polynomial has potential branches for all 1-element subsets (r-2=1),
but only the independent ones ({0}, {1}, {2}, {3}, {4}) survive.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


fig, ax = plt.subplots(figsize=(14, 8))

# ── Define the matroid ──
# Bases: {0,1,2} and {0,3,4}
# Independent 1-sets (r-2=1): {0}, {1}, {2}, {3}, {4} — all survive!
# But for a different matroid, some might not.

# Let's use a more interesting example:
# Ground set [6], rank 3
# Bases: {0,1,2}, {0,1,3}, {0,2,3}, {1,2,3}  (these are all 3-subsets of {0,1,2,3})
# Independent 1-sets: subsets of some basis = any singleton from {0,1,2,3}
# Elements 4,5 are NOT in any basis, so {4} and {5} are NOT independent

bases = [{0,1,2}, {0,1,3}, {0,2,3}, {1,2,3}]
n = 6
r = 3
all_singletons = [{i} for i in range(n)]
indep_singletons = [S for S in all_singletons if any(S <= B for B in bases)]
dep_singletons = [S for S in all_singletons if not any(S <= B for B in bases)]

# ── Draw the tree ──

# Root node
root_x, root_y = 7, 7.5
ax.add_patch(plt.Circle((root_x, root_y), 0.4, color='#2C3E50', zorder=5))
ax.text(root_x, root_y, 'B_M', ha='center', va='center', fontsize=11,
        fontweight='bold', color='white', zorder=6)
ax.text(root_x, root_y + 0.7, 'Basis Generating\nPolynomial (deg 3)',
        ha='center', va='center', fontsize=9, color='#2C3E50')

# Level 1: All possible derivative directions
y_level1 = 5.0
x_positions = np.linspace(1.5, 12.5, n)

for idx, i in enumerate(range(n)):
    x = x_positions[idx]
    S = {i}
    is_indep = S in indep_singletons

    # Draw edge from root
    color = '#27AE60' if is_indep else '#E74C3C'
    linestyle = '-' if is_indep else '--'
    alpha = 1.0 if is_indep else 0.4

    ax.plot([root_x, x], [root_y - 0.4, y_level1 + 0.35],
            color=color, linewidth=2, linestyle=linestyle, alpha=alpha, zorder=3)

    # Draw node
    if is_indep:
        ax.add_patch(plt.Circle((x, y_level1), 0.35, color='#27AE60', zorder=5))
        ax.text(x, y_level1, f'∂_{i}', ha='center', va='center',
                fontsize=10, color='white', fontweight='bold', zorder=6)
        # Label
        ax.text(x, y_level1 - 0.6, f'{{{i}}} ⊆ basis\n✓ survives',
                ha='center', va='center', fontsize=7, color='#27AE60')

        # Level 2: Quadratic leaves (the actual certificate checks)
        y_level2 = 2.5
        ax.add_patch(mpatches.FancyBboxPatch(
            (x - 0.5, y_level2 - 0.3), 1.0, 0.6,
            boxstyle="round,pad=0.1", facecolor='#EAF2E3',
            edgecolor='#27AE60', linewidth=1.5, zorder=4))
        ax.text(x, y_level2, 'Quadratic\nLeaf ✓', ha='center', va='center',
                fontsize=7, color='#27AE60', fontweight='bold', zorder=5)
        ax.plot([x, x], [y_level1 - 0.35, y_level2 + 0.3],
                color='#27AE60', linewidth=1.5, zorder=3)
    else:
        ax.add_patch(plt.Circle((x, y_level1), 0.35, color='#E74C3C',
                                alpha=0.4, zorder=5))
        ax.text(x, y_level1, f'∂_{i}', ha='center', va='center',
                fontsize=10, color='white', fontweight='bold', zorder=6, alpha=0.6)
        # X mark
        ax.text(x, y_level1 - 0.6, f'{{{i}}} ⊄ any basis\n✗ pruned!',
                ha='center', va='center', fontsize=7, color='#E74C3C')

# ── Legend and annotations ──
ax.text(7, 1.2,
        f'Bases: {{0,1,2}}, {{0,1,3}}, {{0,2,3}}, {{1,2,3}}   |   '
        f'Ground set: [6]   |   Rank: 3\n'
        f'Ambient leaf count: C(6,1) = 6   |   '
        f'Actual (independent) leaves: {len(indep_singletons)}   |   '
        f'Pruned: {len(dep_singletons)}',
        ha='center', va='center', fontsize=10,
        bbox=dict(boxstyle='round,pad=0.5', facecolor='#F8F9FA',
                  edgecolor='#BDC3C7', linewidth=1.5))

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#27AE60', label='Surviving branch (S independent)'),
    mpatches.Patch(facecolor='#E74C3C', alpha=0.4, label='Pruned branch (S dependent)'),
]
ax.legend(handles=legend_elements, loc='upper left', fontsize=10,
          framealpha=0.9)

ax.set_xlim(0, 14)
ax.set_ylim(0.5, 9)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Recursion Tree Pruning by Matroid Support Geometry\n'
             'Only independent subsets produce nonzero derivative branches',
             fontsize=14, fontweight='bold', pad=10)

plt.tight_layout()
plt.savefig('viz_recursion_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_recursion_tree.png")
